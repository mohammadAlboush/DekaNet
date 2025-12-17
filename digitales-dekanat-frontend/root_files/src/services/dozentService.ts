import api, { ApiResponse, handleApiError } from './api';

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
  hat_benutzer_account?: boolean;
  anzahl_module?: number;
  created_at?: string;
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
  }): Promise<ApiResponse<Dozent[]>> {
    try {
      console.log('[DozentService] Fetching dozenten with params:', params);
      
      const queryParams = new URLSearchParams();
      if (params?.fachbereich) queryParams.append('fachbereich', params.fachbereich);
      if (params?.aktiv !== undefined) queryParams.append('aktiv', params.aktiv.toString());
      if (params?.mit_benutzer !== undefined) queryParams.append('mit_benutzer', params.mit_benutzer.toString());
      
      // WICHTIG: Trailing slash hinzugefügt!
      const url = `/dozenten/${queryParams.toString() ? `?${queryParams}` : ''}`;
      console.log('[DozentService] Request URL:', url);
      
      const response = await api.get<ApiResponse<Dozent[]>>(url);
      
      console.log('[DozentService] Response:', {
        success: response.data.success,
        dataLength: response.data.data?.length || 0
      });
      
      return response.data;
    } catch (error) {
      console.error('[DozentService] Error fetching dozenten:', error);
      throw new Error(handleApiError(error));
    }
  }

  /**
   * Get dozent details
   */
  async getDozentDetails(id: number): Promise<ApiResponse<any>> {
    try {
      console.log('[DozentService] Fetching details for dozent:', id);
      
      const response = await api.get<ApiResponse<any>>(`/dozenten/${id}`);
      
      console.log('[DozentService] Dozent details received');
      return response.data;
    } catch (error) {
      console.error('[DozentService] Error fetching dozent details:', error);
      throw new Error(handleApiError(error));
    }
  }

  /**
   * Search dozenten
   */
  async searchDozenten(query: string): Promise<ApiResponse<Dozent[]>> {
    try {
      console.log('[DozentService] Searching dozenten with query:', query);
      
      const response = await api.get<ApiResponse<Dozent[]>>(`/dozenten/search?q=${query}`);
      
      console.log('[DozentService] Search results:', response.data.data?.length || 0);
      return response.data;
    } catch (error) {
      console.error('[DozentService] Error searching dozenten:', error);
      throw new Error(handleApiError(error));
    }
  }

  /**
   * Get dozent module
   */
  async getDozentModule(id: number, po_id?: number): Promise<ApiResponse<any[]>> {
    try {
      console.log('[DozentService] Fetching modules for dozent:', id);
      
      const params = po_id ? `?po_id=${po_id}` : '';
      const response = await api.get<ApiResponse<any[]>>(`/dozenten/${id}/module${params}`);
      
      console.log('[DozentService] Modules received:', response.data.data?.length || 0);
      return response.data;
    } catch (error) {
      console.error('[DozentService] Error fetching modules:', error);
      throw new Error(handleApiError(error));
    }
  }

  /**
   * Create dozent (Dekan only)
   */
  async createDozent(data: DozentCreateData): Promise<ApiResponse<Dozent>> {
    try {
      console.log('[DozentService] Creating dozent:', data.nachname);
      
      const response = await api.post<ApiResponse<Dozent>>('/dozenten/', data);
      
      console.log('[DozentService] ✓ Dozent created:', response.data.data?.id);
      return response.data;
    } catch (error) {
      console.error('[DozentService] Error creating dozent:', error);
      throw new Error(handleApiError(error));
    }
  }

  /**
   * Update dozent (Dekan only)
   */
  async updateDozent(id: number, data: DozentUpdateData): Promise<ApiResponse<Dozent>> {
    try {
      console.log('[DozentService] Updating dozent:', id);
      
      const response = await api.put<ApiResponse<Dozent>>(`/dozenten/${id}`, data);
      
      console.log('[DozentService] ✓ Dozent updated');
      return response.data;
    } catch (error) {
      console.error('[DozentService] Error updating dozent:', error);
      throw new Error(handleApiError(error));
    }
  }

  /**
   * Delete dozent (Dekan only)
   */
  async deleteDozent(id: number, force: boolean = false): Promise<ApiResponse> {
    try {
      console.log('[DozentService] Deleting dozent:', id, 'force:', force);
      
      const response = await api.delete<ApiResponse>(`/dozenten/${id}?force=${force}`);
      
      console.log('[DozentService] ✓ Dozent deleted');
      return response.data;
    } catch (error) {
      console.error('[DozentService] Error deleting dozent:', error);
      throw new Error(handleApiError(error));
    }
  }
}

// Export singleton instance
export default new DozentService();