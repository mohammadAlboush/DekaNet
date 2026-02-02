import api, { ApiResponse, handleApiError } from './api';
import { createContextLogger } from '../utils/logger';

const log = createContextLogger('DozentService');

/**
 * Dozent Service - ERWEITERT MIT CRUD
 * ====================================
 * WICHTIG: Alle URLs haben trailing slash um 308 Redirects zu vermeiden!
 */

export interface Dozent {
  id: number;
  titel?: string;
  vorname?: string;
  nachname: string;
  name_komplett: string;
  name_mit_titel?: string;
  email?: string;
  fachbereich?: string;
  aktiv: boolean;
  ist_platzhalter?: boolean;
  hat_benutzer_account?: boolean;
  anzahl_module?: number;
  created_at?: string;
}

export interface DozentPosition {
  id: number;
  bezeichnung: string;
  typ: 'platzhalter' | 'rolle' | 'gruppe';
  beschreibung?: string;
  fachbereich?: string;
  ist_platzhalter: true;
  anzahl_module?: number;
  module?: Array<{
    modul_id: number;
    kuerzel: string;
    bezeichnung_de: string;
    rolle: string;
  }>;
}

export interface DozentCreateData {
  titel?: string;
  vorname?: string;
  nachname: string;
  email?: string;
  fachbereich?: string;
  aktiv?: boolean;
}

export interface DozentUpdateData {
  titel?: string;
  vorname?: string;
  nachname?: string;
  email?: string;
  fachbereich?: string;
  aktiv?: boolean;
}

class DozentService {
  /**
   * Get all dozenten
   */
  async getAllDozenten(params?: {
    fachbereich?: string;
    aktiv?: boolean;
    mit_benutzer?: boolean;
    include_platzhalter?: boolean;
  }): Promise<ApiResponse<Dozent[]>> {
    try {
      log.debug('Fetching dozenten with params:', params);

      const queryParams = new URLSearchParams();
      if (params?.fachbereich) queryParams.append('fachbereich', params.fachbereich);
      if (params?.aktiv !== undefined) queryParams.append('aktiv', params.aktiv.toString());
      if (params?.mit_benutzer !== undefined) queryParams.append('mit_benutzer', params.mit_benutzer.toString());
      if (params?.include_platzhalter !== undefined) queryParams.append('include_platzhalter', params.include_platzhalter.toString());
      
      // WICHTIG: Trailing slash hinzugefügt!
      const url = `/dozenten/${queryParams.toString() ? `?${queryParams}` : ''}`;
      log.debug('Request URL:', url);
      
      const response = await api.get<ApiResponse<Dozent[]>>(url);
      
      log.debug('Response:', {
        success: response.data.success,
        dataLength: response.data.data?.length || 0
      });

      return response.data;
    } catch (error) {
      log.error('Error fetching dozenten:', error);
      throw new Error(handleApiError(error));
    }
  }

  /**
   * Get dozent details
   */
  async getDozentDetails(id: number): Promise<ApiResponse<any>> {
    try {
      log.debug('Fetching details for dozent:', id);

      const response = await api.get<ApiResponse<any>>(`/dozenten/${id}`);

      log.debug('Dozent details received');
      return response.data;
    } catch (error) {
      log.error('Error fetching dozent details:', error);
      throw new Error(handleApiError(error));
    }
  }

  /**
   * Search dozenten
   */
  async searchDozenten(query: string): Promise<ApiResponse<Dozent[]>> {
    try {
      log.debug('Searching dozenten with query:', query);

      const response = await api.get<ApiResponse<Dozent[]>>(`/dozenten/search?q=${query}`);

      log.debug('Search results:', response.data.data?.length || 0);
      return response.data;
    } catch (error) {
      log.error('Error searching dozenten:', error);
      throw new Error(handleApiError(error));
    }
  }

  /**
   * Get dozent module
   */
  async getDozentModule(id: number, po_id?: number): Promise<ApiResponse<any[]>> {
    try {
      log.debug('Fetching modules for dozent:', id);

      const params = po_id ? `?po_id=${po_id}` : '';
      const response = await api.get<ApiResponse<any[]>>(`/dozenten/${id}/module${params}`);

      log.debug('Modules received:', response.data.data?.length || 0);
      return response.data;
    } catch (error) {
      log.error('Error fetching modules:', error);
      throw new Error(handleApiError(error));
    }
  }

  /**
   * Create dozent (Dekan only)
   */
  async createDozent(data: DozentCreateData): Promise<ApiResponse<Dozent>> {
    try {
      log.debug('Creating dozent:', data.nachname);

      const response = await api.post<ApiResponse<Dozent>>('/dozenten/', data);

      log.debug('Dozent created:', response.data.data?.id);
      return response.data;
    } catch (error) {
      log.error('Error creating dozent:', error);
      throw new Error(handleApiError(error));
    }
  }

  /**
   * Update dozent (Dekan only)
   */
  async updateDozent(id: number, data: DozentUpdateData): Promise<ApiResponse<Dozent>> {
    try {
      log.debug('Updating dozent:', id);

      const response = await api.put<ApiResponse<Dozent>>(`/dozenten/${id}`, data);

      log.debug('Dozent updated');
      return response.data;
    } catch (error) {
      log.error('Error updating dozent:', error);
      throw new Error(handleApiError(error));
    }
  }

  /**
   * Delete dozent (Dekan only)
   */
  async deleteDozent(id: number, force: boolean = false): Promise<ApiResponse> {
    try {
      log.debug('Deleting dozent:', id, 'force:', force);

      const response = await api.delete<ApiResponse>(`/dozenten/${id}?force=${force}`);

      log.debug('Dozent deleted');
      return response.data;
    } catch (error) {
      log.error('Error deleting dozent:', error);
      throw new Error(handleApiError(error));
    }
  }

  /**
   * Get all dozent positions (Platzhalter/Rollen/Gruppen)
   */
  async getPositionen(typ?: string): Promise<ApiResponse<DozentPosition[]>> {
    try {
      log.debug('Fetching positionen');

      const params = typ ? `?typ=${typ}` : '';
      const response = await api.get<ApiResponse<DozentPosition[]>>(`/dozenten/positionen/${params}`);

      log.debug('Positionen received:', response.data.data?.length || 0);
      return response.data;
    } catch (error) {
      log.error('Error fetching positionen:', error);
      throw new Error(handleApiError(error));
    }
  }

  /**
   * Get position details
   */
  async getPositionDetails(id: number): Promise<ApiResponse<DozentPosition>> {
    try {
      log.debug('Fetching position details:', id);

      const response = await api.get<ApiResponse<DozentPosition>>(`/dozenten/positionen/${id}`);

      log.debug('Position details received');
      return response.data;
    } catch (error) {
      log.error('Error fetching position details:', error);
      throw new Error(handleApiError(error));
    }
  }
}

// Export singleton instance
export default new DozentService();