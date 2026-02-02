import { create } from 'zustand';
import { devtools, persist } from 'zustand/middleware';
import authService from '../services/authService';
import { setCsrfToken } from '../services/api';
import { User, LoginCredentials } from '../types/auth.types';
import { createContextLogger } from '../utils/logger';

const log = createContextLogger('AuthStore');

/**
 * Authentication Store - Secure Cookie-Based Auth
 * ================================================
 * Global state management für Authentication mit Zustand
 *
 * Sichere httpOnly Cookie-basierte Authentifizierung
 *
 * Security Features:
 * - Tokens werden als httpOnly Cookies gespeichert (XSS-sicher)
 * - Nur User-Daten werden in Store/localStorage gespeichert
 * - CSRF-Protection durch Double Submit Cookie Pattern
 */

interface AuthState {
  // State
  user: User | null;
  isAuthenticated: boolean;
  isLoading: boolean;
  error: string | null;

  // Actions
  login: (credentials: LoginCredentials) => Promise<void>;
  logout: () => Promise<void>;
  checkAuth: () => Promise<void>;
  updateUser: (user: Partial<User>) => void;
  clearError: () => void;
  setLoading: (loading: boolean) => void;
}

const useAuthStore = create<AuthState>()(
  devtools(
    persist(
      (set, get) => ({
        // Initial State
        user: null,
        isAuthenticated: false,
        isLoading: false,
        error: null,

        // Login Action
        // Tokens werden als httpOnly Cookies gespeichert
        login: async (credentials: LoginCredentials) => {
          log.debug('Starting login...');
          set({ isLoading: true, error: null });

          try {
            const response = await authService.login(credentials);

            if (response.success && response.data) {
              log.info('Login successful');
              set({
                user: response.data.user,
                isAuthenticated: true,
                isLoading: false,
                error: null,
              });

              // Tokens sind in httpOnly Cookies
              // Nur User ist in localStorage gespeichert
              log.debug('User stored in localStorage, tokens in httpOnly cookies');

            } else {
              log.error('Login failed', response.message);
              set({
                user: null,
                isAuthenticated: false,
                isLoading: false,
                error: response.message || 'Login fehlgeschlagen',
              });
            }
          } catch (error: unknown) {
            const errorMessage = error instanceof Error ? error.message : 'Ein Fehler ist aufgetreten';
            log.error('Login error', error);
            set({
              user: null,
              isAuthenticated: false,
              isLoading: false,
              error: errorMessage,
            });
            throw error;
          }
        },

        // Logout Action
        // Cookies werden vom Backend gelöscht
        logout: async () => {
          log.debug('Logging out...');
          set({ isLoading: true });

          try {
            await authService.logout();
            log.info('Logout successful');
          } catch (error) {
            log.warn('Logout error (continuing anyway)', error);
          } finally {
            // Lösche user-spezifische LocalStorage Daten
            // Keine Token-Löschung nötig (httpOnly Cookies)
            try {
              const keysToRemove: string[] = [];
              for (let i = 0; i < localStorage.length; i++) {
                const key = localStorage.key(i);
                if (key && key.startsWith('planung_wizard_backup_user_')) {
                  keysToRemove.push(key);
                }
              }
              keysToRemove.forEach(key => {
                localStorage.removeItem(key);
                log.debug(`Cleared planning data: ${key}`);
              });
            } catch (cleanupError) {
              log.warn('Error cleaning up planning data', cleanupError);
            }

            // User-Daten löschen (Tokens sind in Cookies, werden vom Backend gelöscht)
            localStorage.removeItem('user');
            setCsrfToken(null);

            set({
              user: null,
              isAuthenticated: false,
              isLoading: false,
              error: null,
            });
          }
        },

        // Check Authentication Status - Secure Cookie-Based
        // Tokens sind in httpOnly Cookies
        checkAuth: async () => {
          log.debug('Checking authentication...');

          const storedUser = authService.getCurrentUser();

          // Kein User = nicht authentifiziert
          if (!storedUser) {
            log.debug('No user in localStorage');
            set({
              user: null,
              isAuthenticated: false,
              isLoading: false,
            });
            return;
          }

          log.debug(`User found: ${storedUser.username} | ${storedUser.rolle}`);

          // OPTIMIERUNG: Setze User sofort aus localStorage
          // So ist die UI instant ready, während wir im Hintergrund verifizieren
          set({
            user: storedUser,
            isAuthenticated: true,
            isLoading: false,
          });

          // Verifiziere Token im Hintergrund (non-blocking)
          // Cookie wird automatisch mitgesendet
          try {
            log.debug('Verifying token in background...');
            const isValid = await authService.verifyToken();

            if (!isValid) {
              log.warn('Token verification failed');

              // Token ungültig - versuche Refresh
              log.debug('Attempting token refresh...');
              const success = await authService.refreshToken();

              if (success) {
                log.info('Token refreshed successfully');
                // Token wurde erneuert, State bleibt authenticated
              } else {
                log.error('Token refresh failed - logging out');
                // Refresh fehlgeschlagen - logout
                // Nur User-Daten löschen, keine Tokens
                localStorage.removeItem('user');
                setCsrfToken(null);

                set({
                  user: null,
                  isAuthenticated: false,
                  isLoading: false,
                });

                // Redirect to login
                window.location.href = '/login';
              }
            } else {
              log.debug('Token is valid');
            }
          } catch (error) {
            log.warn('Token verification error', error);
            // Bei Fehler bleiben wir authenticated (optimistic)
            // Der API Interceptor wird bei 401 automatisch handlen
          }
        },

        // Update User
        updateUser: (userData: Partial<User>) => {
          log.debug('Updating user data...');
          const currentUser = get().user;

          if (currentUser) {
            const updatedUser = { ...currentUser, ...userData };
            set({ user: updatedUser });
            localStorage.setItem('user', JSON.stringify(updatedUser));
            log.debug('User data updated');
          } else {
            log.warn('Cannot update user - no user logged in');
          }
        },

        // Clear Error
        clearError: () => {
          log.debug('Clearing error');
          set({ error: null });
        },

        // Set Loading
        setLoading: (loading: boolean) => {
          set({ isLoading: loading });
        },
      }),
      {
        name: 'auth-storage',
        partialize: (state) => ({ 
          user: state.user,
          isAuthenticated: state.isAuthenticated 
        }),
      }
    ),
    {
      name: 'AuthStore',
    }
  )
);

export default useAuthStore;