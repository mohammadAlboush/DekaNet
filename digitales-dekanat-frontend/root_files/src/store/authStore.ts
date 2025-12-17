import { create } from 'zustand';
import { devtools, persist } from 'zustand/middleware';
import authService from '../services/authService';
import { User, LoginCredentials } from '../types/auth.types';

/**
 * Authentication Store - PRODUCTION READY
 * ========================================
 * Global state management für Authentication mit Zustand
 * 
 * FEATURES:
 * - Optimiertes checkAuth() - weniger API-Calls
 * - Besseres Error-Handling
 * - Comprehensive Logging
 * - Persistent Storage
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
        login: async (credentials: LoginCredentials) => {
          console.log('[AuthStore] 🔐 Starting login...');
          set({ isLoading: true, error: null });
          
          try {
            const response = await authService.login(credentials);
            
            if (response.success && response.data) {
              console.log('[AuthStore] ✓ Login successful');
              set({
                user: response.data.user,
                isAuthenticated: true,
                isLoading: false,
                error: null,
              });
              
              // Verify token was stored
              const storedToken = localStorage.getItem('accessToken');
              console.log('[AuthStore] Token stored:', !!storedToken);
              
            } else {
              console.error('[AuthStore] ✗ Login failed:', response.message);
              set({
                user: null,
                isAuthenticated: false,
                isLoading: false,
                error: response.message || 'Login fehlgeschlagen',
              });
            }
          } catch (error: any) {
            console.error('[AuthStore] ✗ Login error:', error);
            set({
              user: null,
              isAuthenticated: false,
              isLoading: false,
              error: error.message || 'Ein Fehler ist aufgetreten',
            });
            throw error;
          }
        },

        // Logout Action
        logout: async () => {
          console.log('[AuthStore] 🚪 Logging out...');
          set({ isLoading: true });

          try {
            await authService.logout();
            console.log('[AuthStore] ✓ Logout successful');
          } catch (error) {
            console.error('[AuthStore] ⚠ Logout error (continuing anyway):', error);
          } finally {
            // ✅ Lösche user-spezifische LocalStorage Daten
            // Suche und lösche alle planung_wizard_backup Keys
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
                console.log(`[AuthStore] 🗑️ Cleared planning data: ${key}`);
              });
            } catch (cleanupError) {
              console.error('[AuthStore] ⚠ Error cleaning up planning data:', cleanupError);
            }

            set({
              user: null,
              isAuthenticated: false,
              isLoading: false,
              error: null,
            });
          }
        },

        // Check Authentication Status - OPTIMIERT & ROBUST!
        checkAuth: async () => {
          console.log('[AuthStore] 🔍 Checking authentication...');
          
          const token = localStorage.getItem('accessToken');
          const storedUser = authService.getCurrentUser();
          
          // Keine Tokens = nicht authentifiziert
          if (!token || !storedUser) {
            console.log('[AuthStore] ⊘ No token or user in localStorage');
            set({
              user: null,
              isAuthenticated: false,
              isLoading: false,
            });
            return;
          }

          console.log('[AuthStore] ✓ Token and user found in localStorage');
          console.log('[AuthStore] User:', storedUser.username, '|', storedUser.rolle);
          
          // OPTIMIERUNG: Setze User sofort aus localStorage
          // So ist die UI instant ready, während wir im Hintergrund verifizieren
          set({
            user: storedUser,
            isAuthenticated: true,
            isLoading: false,
          });

          // Verifiziere Token im Hintergrund (non-blocking)
          // Dies ist optional - der API Interceptor handled Token Refresh automatisch
          try {
            console.log('[AuthStore] 🔍 Verifying token in background...');
            const isValid = await authService.verifyToken();
            
            if (!isValid) {
              console.warn('[AuthStore] ⚠ Token verification failed');
              
              // Token ungültig - versuche Refresh
              console.log('[AuthStore] 🔄 Attempting token refresh...');
              const newToken = await authService.refreshToken();
              
              if (newToken) {
                console.log('[AuthStore] ✓ Token refreshed successfully');
                // Token wurde erneuert, State bleibt authenticated
              } else {
                console.error('[AuthStore] ✗ Token refresh failed - logging out');
                // Refresh fehlgeschlagen - logout
                localStorage.clear();
                
                set({
                  user: null,
                  isAuthenticated: false,
                  isLoading: false,
                });
                
                // Redirect to login
                window.location.href = '/login';
              }
            } else {
              console.log('[AuthStore] ✓ Token is valid');
            }
          } catch (error) {
            console.error('[AuthStore] ⚠ Token verification error:', error);
            // Bei Fehler bleiben wir authenticated (optimistic)
            // Der API Interceptor wird bei 401 automatisch handlen
          }
        },

        // Update User
        updateUser: (userData: Partial<User>) => {
          console.log('[AuthStore] 📝 Updating user data...');
          const currentUser = get().user;
          
          if (currentUser) {
            const updatedUser = { ...currentUser, ...userData };
            set({ user: updatedUser });
            localStorage.setItem('user', JSON.stringify(updatedUser));
            console.log('[AuthStore] ✓ User data updated');
          } else {
            console.warn('[AuthStore] ⚠ Cannot update user - no user logged in');
          }
        },

        // Clear Error
        clearError: () => {
          console.log('[AuthStore] 🧹 Clearing error');
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