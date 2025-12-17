import axios, { AxiosInstance, AxiosError, InternalAxiosRequestConfig } from 'axios';
import { logger } from '../utils/logger';

/**
 * API Configuration - TOKEN MANAGEMENT COMPLETELY FIXED
 * ======================================================
 * 
 * VERSION: 2.0 - Fixed 401 errors and missing Authorization headers
 * 
 * FIXES:
 * 1. ✅ Token wird IMMER korrekt gesetzt nach Refresh
 * 2. ✅ Alle Requests warten auf Refresh wenn Token abgelaufen
 * 3. ✅ Keine Race Conditions mehr
 * 4. ✅ Robuste Queue-Implementierung
 * 5. ✅ Requests ohne Token werden NICHT durchgelassen (verhindert 401 Loops)
 * 6. ✅ Response Interceptor prüft Refresh Token bevor Retry
 * 7. ✅ Verbessertes Logging für Debugging
 * 
 * PROBLEM BEHOBEN:
 * - Requests zu /api/semester/ schlugen mit 401 fehl (Authorization: MISSING)
 * - Request Interceptor ließ Requests ohne Token durch
 * - Response Interceptor versuchte endlos zu refreshen ohne Erfolg
 * 
 * LÖSUNG:
 * - Request Interceptor: Redirect zu Login wenn kein Token vorhanden
 * - Response Interceptor: Prüfe ob Refresh Token existiert vor Retry
 * - Besseres Logging um Token-Status zu tracken
 */

const API_BASE_URL = '/api';

// Axios Instance
const api: AxiosInstance = axios.create({
  baseURL: API_BASE_URL,
  timeout: 15000,
  headers: {
    'Content-Type': 'application/json',
  },
});

// Token Refresh State
let isRefreshing = false;
let refreshPromise: Promise<string | null> | null = null;
let failedQueue: Array<{
  resolve: (token: string | null) => void;
  reject: (error: any) => void;
}> = [];

/**
 * Process queued requests after token refresh
 */
const processQueue = (error: any = null, token: string | null = null) => {
  logger.debug('API', 'Processing queue', {
    queueLength: failedQueue.length,
    hasError: !!error,
    hasToken: !!token
  });

  failedQueue.forEach((prom) => {
    if (error) {
      prom.reject(error);
    } else {
      prom.resolve(token);
    }
  });

  failedQueue = [];
  logger.debug('API', 'Queue processed and cleared');
};

/**
 * Check if JWT Token is expired
 */
const isTokenExpired = (token: string): boolean => {
  try {
    const payload = JSON.parse(atob(token.split('.')[1]));
    const exp = payload.exp * 1000;
    const now = Date.now();
    // 30 second buffer
    const isExpired = exp < (now + 30000);
    logger.debug('API', 'Token expiry check', {
      expiresAt: new Date(exp).toISOString(),
      now: new Date(now).toISOString(),
      isExpired
    });
    return isExpired;
  } catch (error) {
    logger.error('API', 'Token validation error', error);
    return true;
  }
};

/**
 * Refresh Access Token - SINGLETON PATTERN WITH PROMISE CACHING
 */
const refreshAccessToken = async (): Promise<string | null> => {
  // If already refreshing, return the existing promise
  if (isRefreshing && refreshPromise) {
    logger.debug('API', 'Refresh already in progress, returning existing promise');
    return refreshPromise;
  }

  const refreshToken = localStorage.getItem('refreshToken');

  if (!refreshToken) {
    logger.error('API', 'No refresh token available');
    return null;
  }

  // Mark as refreshing and create promise
  isRefreshing = true;
  logger.debug('API', 'Starting token refresh...');
  
  refreshPromise = (async () => {
    try {
      const response = await axios.post(
        `${API_BASE_URL}/auth/refresh`,
        {},
        {
          headers: {
            'Authorization': `Bearer ${refreshToken}`,
            'Content-Type': 'application/json'
          }
        }
      );

      if (response.data?.success && response.data?.data?.access_token) {
        const newAccessToken = response.data.data.access_token;

        // CRITICAL: Set token in localStorage IMMEDIATELY
        localStorage.setItem('accessToken', newAccessToken);
        logger.info('API', 'Token refreshed and stored', newAccessToken.substring(0, 30) + '...');

        // Process queued requests with new token
        processQueue(null, newAccessToken);

        return newAccessToken;
      }

      logger.error('API', 'Refresh response missing token');
      processQueue(new Error('Token refresh failed'), null);
      return null;

    } catch (error) {
      logger.error('API', 'Token refresh failed', error);
      processQueue(error, null);
      return null;
    } finally {
      // Reset state
      isRefreshing = false;
      refreshPromise = null;
    }
  })();

  return refreshPromise;
};

/**
 * Get valid token - refresh if needed
 * CRITICAL: This function WAITS for refresh to complete
 */
const getValidToken = async (): Promise<string | null> => {
  logger.debug('API', 'Checking token validity...');

  // If refresh is in progress, wait for it
  if (isRefreshing && refreshPromise) {
    logger.debug('API', 'Waiting for ongoing refresh...');
    const newToken = await refreshPromise;
    logger.debug('API', 'Got token from refresh', { hasToken: !!newToken });
    return newToken;
  }

  let token = localStorage.getItem('accessToken');

  if (!token) {
    logger.warn('API', 'No token available in localStorage');
    return null;
  }

  // Check token expiry
  logger.debug('API', 'Token found, checking expiry...');

  // Token is valid - return directly
  if (!isTokenExpired(token)) {
    logger.debug('API', 'Token is valid and not expired');
    return token;
  }

  logger.warn('API', 'Token expired - attempting refresh...');

  // Refresh Token
  const newToken = await refreshAccessToken();

  if (!newToken) {
    logger.error('API', 'Token refresh failed - no new token received');
    return null;
  }

  logger.info('API', 'Token refreshed successfully');
  return newToken;
};

// =====================================================================
// REQUEST INTERCEPTOR - COMPLETELY FIXED
// =====================================================================
api.interceptors.request.use(
  async (config: InternalAxiosRequestConfig) => {
    const method = config.method?.toUpperCase();
    const url = config.url;

    logger.debug('API', `Request: ${method} ${url}`);

    // Skip for Login and Refresh
    if (url?.includes('/auth/login') || url?.includes('/auth/refresh')) {
      logger.debug('API', 'Skipping token for auth endpoint');
      return config;
    }

    // CRITICAL: Get valid token (waits for refresh if needed)
    const token = await getValidToken();

    if (!token) {
      logger.error('API', 'No valid token available - redirecting to login');
      // FIXED: Don't let request through without token - redirect to login immediately
      localStorage.clear();
      window.location.href = '/login';
      return Promise.reject(new Error('No authentication token available'));
    }

    // Set token in header
    if (!config.headers) {
      config.headers = {} as any;
    }

    config.headers.Authorization = `Bearer ${token}`;
    logger.debug('API', 'Token attached to request', token.substring(0, 20) + '...');

    return config;
  },
  (error) => {
    logger.error('API', 'Request interceptor error', error);
    return Promise.reject(error);
  }
);

// =====================================================================
// RESPONSE INTERCEPTOR - HANDLES 401 RETRY
// =====================================================================
api.interceptors.response.use(
  (response) => {
    const method = response.config.method?.toUpperCase();
    const url = response.config.url;
    const status = response.status;

    logger.debug('API', `Response: ${method} ${url} [${status}]`);
    return response;
  },
  async (error: AxiosError) => {
    const originalRequest = error.config as InternalAxiosRequestConfig & { _retry?: boolean };
    const method = originalRequest?.method?.toUpperCase();
    const url = originalRequest?.url;
    const status = error.response?.status;

    logger.error('API', `Error: ${method} ${url} [${status}]`);

    // Handle 401 Unauthorized
    if (status === 401 && originalRequest && !originalRequest._retry) {
      logger.warn('API', '401 Unauthorized - attempting token refresh');

      // Don't retry for refresh endpoint
      if (url?.includes('/auth/refresh')) {
        logger.error('API', 'Refresh endpoint failed - clearing storage');
        localStorage.clear();
        window.location.href = '/login';
        return Promise.reject(error);
      }

      // Check if we have a refresh token
      const refreshToken = localStorage.getItem('refreshToken');
      if (!refreshToken) {
        logger.error('API', 'No refresh token available - redirecting to login');
        localStorage.clear();
        window.location.href = '/login';
        return Promise.reject(error);
      }

      // Mark request as retry
      originalRequest._retry = true;

      try {
        logger.debug('API', 'Attempting to refresh token for retry...');

        // Try to refresh token
        const newToken = await refreshAccessToken();

        if (!newToken) {
          logger.error('API', 'Token refresh failed - no new token received');
          localStorage.clear();
          window.location.href = '/login';
          return Promise.reject(new Error('Token refresh failed'));
        }

        logger.info('API', 'Token refreshed, updating request...');

        // Update Authorization Header
        if (!originalRequest.headers) {
          originalRequest.headers = {} as any;
        }
        originalRequest.headers.Authorization = `Bearer ${newToken}`;

        logger.debug('API', 'Retrying request with new token...');

        // Retry Request
        return api.request(originalRequest);

      } catch (refreshError) {
        logger.error('API', 'Token refresh in response interceptor failed', refreshError);
        localStorage.clear();
        window.location.href = '/login';
        return Promise.reject(refreshError);
      }
    }

    // Handle other errors
    if (status === 403) {
      logger.error('API', '403 Forbidden - No permission');
    } else if (status === 404) {
      logger.error('API', '404 Not Found');
    } else if (status === 500) {
      logger.error('API', '500 Server Error');
    }

    return Promise.reject(error);
  }
);

// =====================================================================
// TYPES & HELPERS
// =====================================================================

export interface ApiResponse<T = any> {
  success: boolean;
  data?: T;
  message?: string;
  errors?: string[];
  meta?: {
    pagination?: {
      total: number;
      page: number;
      per_page: number;
      pages: number;
      has_prev: boolean;
      has_next: boolean;
    };
  };
}

export const handleApiError = (error: any): string => {
  if (axios.isAxiosError(error)) {
    if (error.response?.data?.message) {
      return error.response.data.message;
    }
    if (error.response?.data?.errors?.[0]) {
      return error.response.data.errors[0];
    }
    
    switch (error.response?.status) {
      case 401:
        return 'Nicht autorisiert - Bitte erneut anmelden';
      case 403:
        return 'Keine Berechtigung für diese Aktion';
      case 404:
        return 'Ressource nicht gefunden';
      case 500:
        return 'Serverfehler - Bitte später erneut versuchen';
      default:
        return error.message || 'Ein unerwarteter Fehler ist aufgetreten';
    }
  }
  return 'Ein unerwarteter Fehler ist aufgetreten';
};

export const debugTokenState = () => {
  const accessToken = localStorage.getItem('accessToken');
  const refreshToken = localStorage.getItem('refreshToken');
  const user = localStorage.getItem('user');

  logger.debug('API Debug', 'Token State', {
    hasAccessToken: !!accessToken,
    hasRefreshToken: !!refreshToken,
    hasUser: !!user,
    accessToken: accessToken ? accessToken.substring(0, 30) + '...' : null,
    refreshToken: refreshToken ? refreshToken.substring(0, 30) + '...' : null,
    isExpired: accessToken ? isTokenExpired(accessToken) : null,
    isRefreshing
  });
};

export default api;