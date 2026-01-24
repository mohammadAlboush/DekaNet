import axios, { AxiosInstance, AxiosError, InternalAxiosRequestConfig } from 'axios';
import { logger } from '../utils/logger';

/**
 * API Configuration - SECURE COOKIE-BASED AUTHENTICATION
 * =======================================================
 *
 * VERSION: 3.0 - Sichere httpOnly Cookie-basierte Authentifizierung
 *
 * SECURITY FEATURES:
 * 1. ✅ Tokens werden als httpOnly Cookies gespeichert (XSS-sicher)
 * 2. ✅ CSRF-Protection durch Double Submit Cookie Pattern
 * 3. ✅ Keine sensiblen Daten in localStorage
 * 4. ✅ Automatisches Cookie-Handling durch Browser
 * 5. ✅ Refresh-Token Rotation
 *
 * WICHTIG:
 * - withCredentials: true sendet Cookies automatisch mit
 * - CSRF-Token muss bei state-ändernden Requests mitgesendet werden
 * - User-Daten werden weiterhin in localStorage für UI-Zwecke gespeichert
 */

const API_BASE_URL = '/api';

// CSRF Token Storage (aus Login-Response)
let csrfToken: string | null = null;

/**
 * Setzt das CSRF-Token (wird beim Login aufgerufen)
 */
export const setCsrfToken = (token: string | null): void => {
  csrfToken = token;
  if (token) {
    localStorage.setItem('csrf_token', token);
  } else {
    localStorage.removeItem('csrf_token');
  }
};

/**
 * Holt das CSRF-Token
 */
export const getCsrfToken = (): string | null => {
  if (!csrfToken) {
    csrfToken = localStorage.getItem('csrf_token');
  }
  return csrfToken;
};

// Axios Instance mit Cookie-Support
const api: AxiosInstance = axios.create({
  baseURL: API_BASE_URL,
  timeout: 15000,
  headers: {
    'Content-Type': 'application/json',
  },
  // ✅ KRITISCH: Sendet Cookies automatisch mit
  withCredentials: true,
});

// Token Refresh State
let isRefreshing = false;
let refreshPromise: Promise<boolean> | null = null;
let failedQueue: Array<{
  resolve: (success: boolean) => void;
  reject: (error: Error) => void;
}> = [];

/**
 * Process queued requests after token refresh
 */
const processQueue = (error: Error | null = null, success: boolean = false): void => {
  logger.debug('API', 'Processing queue', {
    queueLength: failedQueue.length,
    hasError: !!error,
    success
  });

  failedQueue.forEach((prom) => {
    if (error) {
      prom.reject(error);
    } else {
      prom.resolve(success);
    }
  });

  failedQueue = [];
  logger.debug('API', 'Queue processed and cleared');
};

/**
 * Refresh Access Token via Cookie
 * ✅ SECURITY: Refresh-Token wird als httpOnly Cookie gesendet
 */
const refreshAccessToken = async (): Promise<boolean> => {
  // If already refreshing, return the existing promise
  if (isRefreshing && refreshPromise) {
    logger.debug('API', 'Refresh already in progress, returning existing promise');
    return refreshPromise;
  }

  // Mark as refreshing and create promise
  isRefreshing = true;
  logger.debug('API', 'Starting token refresh...');

  refreshPromise = (async () => {
    try {
      // ✅ SECURITY: Cookie wird automatisch mitgesendet (withCredentials)
      const response = await axios.post(
        `${API_BASE_URL}/auth/refresh`,
        {},
        {
          withCredentials: true,
          headers: {
            'Content-Type': 'application/json',
            // CSRF-Token für Double Submit Cookie Pattern
            'X-CSRF-TOKEN': getCsrfToken() || '',
          }
        }
      );

      if (response.data?.success) {
        // Neues CSRF-Token speichern wenn vorhanden
        if (response.data?.data?.csrf_token) {
          setCsrfToken(response.data.data.csrf_token);
        }

        logger.info('API', 'Token refreshed successfully');
        processQueue(null, true);
        return true;
      }

      logger.error('API', 'Refresh response unsuccessful');
      processQueue(new Error('Token refresh failed'), false);
      return false;

    } catch (error) {
      logger.error('API', 'Token refresh failed', error);
      processQueue(error instanceof Error ? error : new Error('Token refresh failed'), false);
      return false;
    } finally {
      // Reset state
      isRefreshing = false;
      refreshPromise = null;
    }
  })();

  return refreshPromise;
};

// =====================================================================
// REQUEST INTERCEPTOR - CSRF TOKEN HANDLING
// =====================================================================
api.interceptors.request.use(
  async (config: InternalAxiosRequestConfig) => {
    const method = config.method?.toUpperCase();
    const url = config.url;

    logger.debug('API', `Request: ${method} ${url}`);

    // ✅ SECURITY: CSRF-Token nur bei state-ändernden Requests
    const stateChangingMethods = ['POST', 'PUT', 'DELETE', 'PATCH'];

    if (method && stateChangingMethods.includes(method)) {
      const token = getCsrfToken();
      if (token) {
        if (!config.headers) {
          config.headers = {} as InternalAxiosRequestConfig['headers'];
        }
        config.headers['X-CSRF-TOKEN'] = token;
        logger.debug('API', 'CSRF token attached to request');
      }
    }

    // Cookies werden automatisch durch withCredentials gesendet
    return config;
  },
  (error) => {
    logger.error('API', 'Request interceptor error', error);
    return Promise.reject(error);
  }
);

// =====================================================================
// RESPONSE INTERCEPTOR - HANDLES 401 RETRY WITH COOKIE REFRESH
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

      // Don't retry for auth endpoints
      if (url?.includes('/auth/refresh') || url?.includes('/auth/login')) {
        logger.error('API', 'Auth endpoint failed - clearing session');
        // Nur User-Daten löschen, keine Tokens (die sind in Cookies)
        localStorage.removeItem('user');
        localStorage.removeItem('csrf_token');
        setCsrfToken(null);
        window.location.href = '/login';
        return Promise.reject(error);
      }

      // Mark request as retry
      originalRequest._retry = true;

      try {
        logger.debug('API', 'Attempting to refresh token for retry...');

        // ✅ SECURITY: Refresh via Cookie (automatisch)
        const success = await refreshAccessToken();

        if (!success) {
          logger.error('API', 'Token refresh failed');
          localStorage.removeItem('user');
          localStorage.removeItem('csrf_token');
          setCsrfToken(null);
          window.location.href = '/login';
          return Promise.reject(new Error('Token refresh failed'));
        }

        logger.info('API', 'Token refreshed, retrying request...');

        // Retry Request - Cookies werden automatisch mitgesendet
        return api.request(originalRequest);

      } catch (refreshError) {
        logger.error('API', 'Token refresh in response interceptor failed', refreshError);
        localStorage.removeItem('user');
        localStorage.removeItem('csrf_token');
        setCsrfToken(null);
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

// ✅ TYPESAFE: `unknown` statt `any` mit Type Narrowing
export const handleApiError = (error: unknown): string => {
  if (axios.isAxiosError(error)) {
    const responseData = error.response?.data as { message?: string; errors?: string[] } | undefined;

    if (responseData?.message) {
      return responseData.message;
    }
    if (responseData?.errors?.[0]) {
      return responseData.errors[0];
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

  // Fallback für Error-Instanzen
  if (error instanceof Error) {
    return error.message;
  }

  return 'Ein unerwarteter Fehler ist aufgetreten';
};

/**
 * Debug-Funktion für Auth-Status
 * ✅ SECURITY: Zeigt nur sichere Informationen an (keine Tokens)
 */
export const debugAuthState = (): void => {
  const user = localStorage.getItem('user');
  const hasCsrfToken = !!getCsrfToken();

  logger.debug('API Debug', 'Auth State', {
    hasUser: !!user,
    hasCsrfToken,
    isRefreshing,
    // Tokens sind in httpOnly Cookies - nicht direkt zugreifbar
    tokenStorage: 'httpOnly cookies (secure)',
  });
};

// Legacy-Export für Abwärtskompatibilität
export const debugTokenState = debugAuthState;

export default api;