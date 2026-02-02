/**
 * Authentication Types
 */

export interface Rolle {
  id: number;
  name: string;
  beschreibung?: string;
}

export interface User {
  id: number;
  username: string;
  email: string;
  vorname?: string;
  nachname?: string;
  name_komplett: string;
  rolle: Rolle | string; // Unterstützt beide Formate
  dozent_id?: number;
  aktiv: boolean;
  letzter_login?: string;
  created_at: string;
}

export interface LoginCredentials {
  username: string;
  password: string;
}

/**
 * Login Response
 * SECURITY: Tokens werden als httpOnly Cookies gesetzt
 * Response enthält nur User und CSRF-Token
 */
export interface LoginResponse {
  success: boolean;
  message?: string;
  data?: {
    user: User;
    // CSRF-Token für Double Submit Cookie Pattern
    csrf_token?: string;
  };
  errors?: string[];
}

/**
 * Auth State
 * SECURITY: Keine Token-Speicherung im State
 * Tokens werden als httpOnly Cookies verwaltet
 */
export interface AuthState {
  user: User | null;
  isAuthenticated: boolean;
  isLoading: boolean;
}

export interface ChangePasswordData {
  old_password: string;
  new_password: string;
  confirm_password: string;
}

export type UserRole = 'dekan' | 'professor' | 'lehrbeauftragter';