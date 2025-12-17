import api, { ApiResponse, handleApiError, debugTokenState } from './api';
import { User, LoginCredentials, LoginResponse, ChangePasswordData } from '../types/auth.types';
import { logger } from '../utils/logger';

/**
 * Authentication Service - PRODUCTION READY
 * ==========================================
 * 
 * FEATURES:
 * - Comprehensive logging
 * - Token validation
 * - Secure token storage
 * - Role-based access control
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
        hasTokens: !!(data.data?.access_token && data.data?.refresh_token)
      });

      if (data.success && data.data) {
        // Store tokens and user
        localStorage.setItem('accessToken', data.data.access_token);
        localStorage.setItem('refreshToken', data.data.refresh_token);
        localStorage.setItem('user', JSON.stringify(data.data.user));

        logger.info('AuthService', 'Login successful');
        logger.debug('AuthService', 'User logged in', {
          username: data.data.user.username,
          rolle: data.data.user.rolle
        });
        logger.debug('AuthService', 'Access Token stored', data.data.access_token.substring(0, 30) + '...');
        logger.debug('AuthService', 'Refresh Token stored', data.data.refresh_token.substring(0, 30) + '...');

        // Debug: Verify storage
        if (process.env.NODE_ENV === 'development') {
          setTimeout(() => {
            debugTokenState();
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
   */
  async logout(): Promise<void> {
    try {
      logger.info('AuthService', 'Logging out...');
      await api.post('/auth/logout');
      logger.info('AuthService', 'Logout API call successful');
    } catch (error) {
      logger.warn('AuthService', 'Logout API error (continuing anyway)', error);
    } finally {
      // IMMER localStorage clearen
      localStorage.removeItem('accessToken');
      localStorage.removeItem('refreshToken');
      localStorage.removeItem('user');
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
   */
  isAuthenticated(): boolean {
    const token = localStorage.getItem('accessToken');
    const user = this.getCurrentUser();
    const isAuth = !!token && !!user;

    logger.debug('AuthService', 'Authentication check', {
      hasToken: !!token,
      hasUser: !!user,
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
   */
  async verifyToken(): Promise<boolean> {
    try {
      const token = localStorage.getItem('accessToken');

      if (!token) {
        logger.debug('AuthService', 'No token to verify');
        return false;
      }

      logger.debug('AuthService', 'Verifying token...');
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
   */
  async refreshToken(): Promise<string | null> {
    const refreshToken = localStorage.getItem('refreshToken');

    if (!refreshToken) {
      logger.debug('AuthService', 'No refresh token available');
      return null;
    }

    try {
      logger.debug('AuthService', 'Refreshing token...');

      const response = await api.post<ApiResponse<{ access_token: string }>>('/auth/refresh', {}, {
        headers: {
          'Authorization': `Bearer ${refreshToken}`
        }
      });

      if (response.data.success && response.data.data) {
        const newAccessToken = response.data.data.access_token;
        localStorage.setItem('accessToken', newAccessToken);

        logger.info('AuthService', 'Token refreshed');
        logger.debug('AuthService', 'New token', newAccessToken.substring(0, 30) + '...');

        return newAccessToken;
      }

      logger.error('AuthService', 'Refresh failed - no token in response');
      return null;
    } catch (error) {
      logger.error('AuthService', 'Token refresh error', error);
      return null;
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