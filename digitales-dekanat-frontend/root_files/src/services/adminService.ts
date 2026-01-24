/**
 * Admin Service
 * =============
 *
 * Administrative Funktionen für Dekan:
 * - Datenbank Reset
 */

import api, { handleApiError } from './api';

export interface ResetPreview {
  semesterplanungen: number;
  geplante_module: number;
  wunsch_freie_tage: number;
  deputatsabrechnungen: number;
  deputats_lehrtaetigkeiten: number;
  deputats_lehrexporte: number;
  deputats_vertretungen: number;
  deputats_ermaessigungen: number;
  deputats_betreuungen: number;
  semester_auftraege: number;
  total_items: number;
}

export interface ResetResponse {
  success: boolean;
  message?: string;
  error?: string;
  deleted?: ResetPreview;
}

export interface PreviewResponse {
  success: boolean;
  preview?: ResetPreview;
  error?: string;
}

class AdminService {
  /**
   * Holt eine Vorschau der zu löschenden Daten
   */
  async getResetPreview(): Promise<PreviewResponse> {
    try {
      const response = await api.get<PreviewResponse>('/admin/reset-database/preview');
      return response.data;
    } catch (error) {
      throw new Error(handleApiError(error));
    }
  }

  /**
   * Führt den Datenbank-Reset durch
   * @param confirmationCode Muss 'RESET_BESTAETIGEN' sein
   */
  async resetDatabase(confirmationCode: string): Promise<ResetResponse> {
    try {
      const response = await api.post<ResetResponse>('/admin/reset-database', {
        confirmation_code: confirmationCode,
      });
      return response.data;
    } catch (error) {
      throw new Error(handleApiError(error));
    }
  }
}

const adminService = new AdminService();
export default adminService;
