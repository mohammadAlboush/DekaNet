import api, { ApiResponse, handleApiError, debugAuthState, setCsrfToken, getCsrfToken } from './api';
import { User, LoginCredentials, LoginResponse, ChangePasswordData } from '../types/auth.types';
import { logger } from '../utils/logger';

/**
 * Authentication Service - SECURE COOKIE-BASED AUTH
 * ==================================================
 *
 * VERSION: 2.0 - Sichere httpOnly Cookie-basierte Authentifizierung
 *
 * SECURITY FEATURES:
 * ✅ Tokens werden als httpOnly Cookies gespeichert (XSS-sicher)
 * ✅ Nur User-Daten werden in localStorage gespeichert
 * ✅ CSRF-Protection durch Double Submit Cookie Pattern
 * ✅ Keine sensiblen Daten im Frontend-Code
 */

class AuthService {
  /**
   * Login
   */
  async login(credentials: LoginCredentials): Promise<LoginResponse> {
    try {
      logger.info('AuthService', 'Attempting login for', credentials.username);

      const response = await api.post<LoginResponse>('/auth/login', credentials);
      const data = response.data;

      logger.debug('AuthService', 'Response received', {
        success: data.success,
        hasData: !!data.data,
        hasUser: !!data.data?.user
      });

      if (data.success && data.data) {
        // ✅ SECURITY: Nur User-Daten speichern (keine Tokens!)
        // Tokens werden als httpOnly Cookies vom Backend gesetzt
        localStorage.setItem('user', JSON.stringify(data.data.user));

        // CSRF-Token für Double Submit Cookie Pattern speichern
        if (data.data.csrf_token) {
          setCsrfToken(data.data.csrf_token);
          logger.debug('AuthService', 'CSRF token stored');
        }

        logger.info('AuthService', 'Login successful');
        logger.debug('AuthService', 'User logged in', {
          username: data.data.user.username,
          rolle: data.data.user.rolle
        });

        // Debug: Verify storage
        if (process.env.NODE_ENV === 'development') {
          setTimeout(() => {
            debugAuthState();
          }, 100);
        }
      } else {
        logger.error('AuthService', 'Login failed - no data in response');
      }

      return data;
    } catch (error) {
      logger.error('AuthService', 'Login error', error);
      throw new Error(handleApiError(error));
    }
  }

  /**
   * Logout
   * ✅ SECURITY: Cookies werden vom Backend gelöscht
   */
  async logout(): Promise<void> {
    try {
      logger.info('AuthService', 'Logging out...');
      // API-Call löscht die httpOnly Cookies auf dem Server
      await api.post('/auth/logout');
      logger.info('AuthService', 'Logout API call successful');
    } catch (error) {
      logger.warn('AuthService', 'Logout API error (continuing anyway)', error);
    } finally {
      // ✅ SECURITY: Nur User-Daten und CSRF-Token löschen
      // Tokens sind in httpOnly Cookies und werden vom Backend gelöscht
      localStorage.removeItem('user');
      setCsrfToken(null);
      logger.info('AuthService', 'Local storage cleared');

      // Redirect zum Login
      window.location.href = '/login';
    }
  }

  /**
   * Get current user from localStorage
   */
  getCurrentUser(): User | null {
    const userStr = localStorage.getItem('user');

    if (!userStr) {
      logger.debug('AuthService', 'No user in localStorage');
      return null;
    }

    try {
      const user = JSON.parse(userStr) as User;
      logger.debug('AuthService', 'User loaded from localStorage', user.username);
      return user;
    } catch (error) {
      logger.error('AuthService', 'Error parsing user', error);
      return null;
    }
  }

  /**
   * Check if user is authenticated
   * ✅ SECURITY: Prüft nur User-Daten und CSRF-Token
   * Token-Validierung erfolgt serverseitig
   */
  isAuthenticated(): boolean {
    const user = this.getCurrentUser();
    const hasCsrf = !!getCsrfToken();
    // User muss existieren und CSRF-Token vorhanden sein
    const isAuth = !!user && hasCsrf;

    logger.debug('AuthService', 'Authentication check', {
      hasUser: !!user,
      hasCsrfToken: hasCsrf,
      isAuthenticated: isAuth
    });

    return isAuth;
  }

  /**
   * Get user profile from API
   */
  async getProfile(): Promise<ApiResponse<{ user: User }>> {
    try {
      logger.info('AuthService', 'Fetching profile...');
      const response = await api.get<ApiResponse<{ user: User }>>('/auth/profile');

      if (response.data.success && response.data.data) {
        // Update localStorage
        localStorage.setItem('user', JSON.stringify(response.data.data.user));
        logger.info('AuthService', 'Profile updated');
      }

      return response.data;
    } catch (error) {
      logger.error('AuthService', 'Get profile error', error);
      throw new Error(handleApiError(error));
    }
  }

  /**
   * Update user profile
   */
  async updateProfile(data: Partial<User>): Promise<ApiResponse<{ user: User }>> {
    try {
      logger.info('AuthService', 'Updating profile...');
      const response = await api.put<ApiResponse<{ user: User }>>('/auth/profile', data);

      if (response.data.success && response.data.data) {
        // Update localStorage
        localStorage.setItem('user', JSON.stringify(response.data.data.user));
        logger.info('AuthService', 'Profile updated');
      }

      return response.data;
    } catch (error) {
      logger.error('AuthService', 'Update profile error', error);
      throw new Error(handleApiError(error));
    }
  }

  /**
   * Change password
   */
  async changePassword(data: ChangePasswordData): Promise<ApiResponse> {
    try {
      logger.info('AuthService', 'Changing password...');
      const response = await api.post<ApiResponse>('/auth/change-password', data);
      logger.info('AuthService', 'Password changed');
      return response.data;
    } catch (error) {
      logger.error('AuthService', 'Change password error', error);
      throw new Error(handleApiError(error));
    }
  }

  /**
   * Verify token
   * ✅ SECURITY: Cookie wird automatisch mitgesendet
   */
  async verifyToken(): Promise<boolean> {
    try {
      // Keine Token-Prüfung mehr nötig - Cookie wird automatisch gesendet
      logger.debug('AuthService', 'Verifying token via cookie...');
      const response = await api.get<ApiResponse>('/auth/verify');
      const isValid = response.data.success;

      logger.debug('AuthService', 'Token verification', { isValid });
      return isValid;
    } catch (error) {
      logger.error('AuthService', 'Token verification failed', error);
      return false;
    }
  }

  /**
   * Refresh token
   * ✅ SECURITY: Refresh-Token als httpOnly Cookie
   */
  async refreshToken(): Promise<boolean> {
    try {
      logger.debug('AuthService', 'Refreshing token via cookie...');

      // Cookie wird automatisch mitgesendet (withCredentials)
      const response = await api.post<ApiResponse<{ csrf_token?: string }>>('/auth/refresh', {});

      if (response.data.success) {
        // Neues CSRF-Token speichern wenn vorhanden
        if (response.data.data?.csrf_token) {
          setCsrfToken(response.data.data.csrf_token);
        }

        logger.info('AuthService', 'Token refreshed successfully');
        return true;
      }

      logger.error('AuthService', 'Refresh failed');
      return false;
    } catch (error) {
      logger.error('AuthService', 'Token refresh error', error);
      return false;
    }
  }

  /**
   * Check user role
   */
  hasRole(role: string): boolean {
    const user = this.getCurrentUser();
    return user?.rolle === role;
  }

  /**
   * Check if user is Dekan
   */
  isDekan(): boolean {
    return this.hasRole('dekan');
  }

  /**
   * Check if user is Professor
   */
  isProfessor(): boolean {
    return this.hasRole('professor');
  }

  /**
   * Check if user is Lehrbeauftragter
   */
  isLehrbeauftragter(): boolean {
    return this.hasRole('lehrbeauftragter');
  }

  /**
   * Check if user is Dozent (Professor or Lehrbeauftragter)
   */
  isDozent(): boolean {
    return this.isProfessor() || this.isLehrbeauftragter();
  }
}

// Export singleton instance
export default new AuthService();