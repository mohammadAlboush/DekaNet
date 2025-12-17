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

export interface LoginResponse {
  success: boolean;
  message?: string;
  data?: {
    access_token: string;
    refresh_token: string;
    user: User;
  };
  errors?: string[];
}

export interface AuthState {
  user: User | null;
  accessToken: string | null;
  refreshToken: string | null;
  isAuthenticated: boolean;
  isLoading: boolean;
}

export interface ChangePasswordData {
  old_password: string;
  new_password: string;
  confirm_password: string;
}

export type UserRole = 'dekan' | 'professor' | 'lehrbeauftragter';