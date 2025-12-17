import api, { ApiResponse, handleApiError } from './api';
import { Modul, ModulDetails } from '../types/modul.types';

/**
 * Modul Service - VOLLSTÄNDIG ERWEITERTER SERVICE
 * ================================================
 * Unterstützt Bearbeitung aller Modul-Daten
 */

export interface ModulCreateData {
  kuerzel: string;
  po_id: number;
  bezeichnung_de: string;
  bezeichnung_en?: string;
  untertitel?: string;
  leistungspunkte?: number;
  turnus?: string;
  gruppengroesse?: string;
  teilnehmerzahl?: string;
  anmeldemodalitaeten?: string;
}

export interface ModulUpdateData {
  bezeichnung_de?: string;
  bezeichnung_en?: string;
  untertitel?: string;
  leistungspunkte?: number;
  turnus?: string;
  gruppengroesse?: string;
  teilnehmerzahl?: string;
  anmeldemodalitaeten?: string;
}

export interface LehrformData {
  lehrform_id: number;
  sws: number;
}

export interface DozentData {
  dozent_id: number;
  rolle: 'verantwortlicher' | 'lehrperson';
}

export interface LiteraturData {
  titel: string;
  autoren?: string;
  verlag?: string;
  jahr?: number;
  isbn?: string;
  typ?: string;
  pflichtliteratur?: boolean;
  sortierung?: number;
}

export interface PruefungData {
  pruefungsform?: string;
  pruefungsdauer_minuten?: number;
  pruefungsleistungen?: string;
  benotung?: string;
}

export interface LernergebnisseData {
  lernziele?: string;
  kompetenzen?: string;
  inhalt?: string;
}

export interface VoraussetzungenData {
  formal?: string;
  empfohlen?: string;
  inhaltlich?: string;
}

export interface ArbeitsaufwandData {
  kontaktzeit_stunden?: number;
  selbststudium_stunden?: number;
  pruefungsvorbereitung_stunden?: number;
  gesamt_stunden?: number;
}

class ModulService {
  /**
   * Get all modules
   */
  async getAllModules(params?: {
    po_id?: number;
    turnus?: string;
    search?: string;
    page?: number;
    per_page?: number;
  }): Promise<ApiResponse<Modul[]>> {
    try {
      console.log('[ModulService] Fetching modules with params:', params);
      
      const queryParams = new URLSearchParams();
      
      if (params?.po_id) {
        queryParams.append('po_id', params.po_id.toString());
      }
      if (params?.turnus) {
        queryParams.append('turnus', params.turnus);
      }
      if (params?.search) {
        queryParams.append('search', params.search);
      }
      if (params?.page) {
        queryParams.append('page', params.page.toString());
      }
      if (params?.per_page) {
        queryParams.append('per_page', params.per_page.toString());
      }
      
      const url = `/module/${queryParams.toString() ? `?${queryParams}` : ''}`;
      console.log('[ModulService] Request URL:', url);
      
      const response = await api.get<ApiResponse<Modul[]>>(url);
      
      console.log('[ModulService] Response:', {
        success: response.data.success,
        dataLength: response.data.data?.length || 0
      });
      
      return response.data;
    } catch (error) {
      console.error('[ModulService] Error fetching modules:', error);
      throw new Error(handleApiError(error));
    }
  }

  /**
   * Get module details
   */
  async getModulDetails(id: number): Promise<ApiResponse<ModulDetails>> {
    try {
      console.log('[ModulService] Fetching details for module:', id);
      
      const response = await api.get<ApiResponse<ModulDetails>>(`/module/${id}`);
      
      console.log('[ModulService] Module details received');
      return response.data;
    } catch (error) {
      console.error('[ModulService] Error fetching module details:', error);
      throw new Error(handleApiError(error));
    }
  }

  /**
   * Get module dozenten
   */
  async getModulDozenten(id: number, rolle?: string): Promise<ApiResponse<any[]>> {
    try {
      console.log('[ModulService] Fetching dozenten for module:', id);
      
      const url = rolle 
        ? `/module/${id}/dozenten?rolle=${rolle}`
        : `/module/${id}/dozenten`;
      
      const response = await api.get<ApiResponse<any[]>>(url);
      
      console.log('[ModulService] Dozenten received:', response.data.data?.length || 0);
      return response.data;
    } catch (error) {
      console.error('[ModulService] Error fetching dozenten:', error);
      throw new Error(handleApiError(error));
    }
  }

  /**
   * Get module lehrformen
   */
  async getModulLehrformen(id: number): Promise<ApiResponse<any[]>> {
    try {
      console.log('[ModulService] Fetching lehrformen for module:', id);
      
      const response = await api.get<ApiResponse<any[]>>(`/module/${id}/lehrformen`);
      
      console.log('[ModulService] Lehrformen received:', response.data.data?.length || 0);
      return response.data;
    } catch (error) {
      console.error('[ModulService] Error fetching lehrformen:', error);
      throw new Error(handleApiError(error));
    }
  }

  /**
   * Search modules
   */
  async searchModules(query: string, po_id?: number): Promise<ApiResponse<Modul[]>> {
    try {
      console.log('[ModulService] Searching modules with query:', query);
      
      const params = new URLSearchParams({ q: query });
      if (po_id) {
        params.append('po_id', po_id.toString());
      }
      
      const response = await api.get<ApiResponse<Modul[]>>(`/module/search?${params}`);
      
      console.log('[ModulService] Search results:', response.data.data?.length || 0);
      return response.data;
    } catch (error) {
      console.error('[ModulService] Error searching modules:', error);
      throw new Error(handleApiError(error));
    }
  }

  /**
   * Get module statistics
   */
  async getStatistik(po_id?: number): Promise<ApiResponse<any>> {
    try {
      console.log('[ModulService] Fetching statistics');
      
      const url = po_id 
        ? `/module/statistik?po_id=${po_id}`
        : '/module/statistik';
      
      const response = await api.get<ApiResponse<any>>(url);
      
      console.log('[ModulService] Statistics received');
      return response.data;
    } catch (error) {
      console.error('[ModulService] Error fetching statistics:', error);
      throw new Error(handleApiError(error));
    }
  }

  /**
   * Create module (Dekan only)
   */
  async createModule(data: ModulCreateData): Promise<ApiResponse<Modul>> {
    try {
      console.log('[ModulService] Creating module:', data.kuerzel);
      
      const response = await api.post<ApiResponse<Modul>>('/module/', data);
      
      console.log('[ModulService] ✓ Module created:', response.data.data?.id);
      return response.data;
    } catch (error) {
      console.error('[ModulService] Error creating module:', error);
      throw new Error(handleApiError(error));
    }
  }

  /**
   * Update module (Dekan only)
   */
  async updateModule(id: number, data: ModulUpdateData): Promise<ApiResponse<Modul>> {
    try {
      console.log('[ModulService] Updating module:', id);
      
      const response = await api.put<ApiResponse<Modul>>(`/module/${id}`, data);
      
      console.log('[ModulService] ✓ Module updated');
      return response.data;
    } catch (error) {
      console.error('[ModulService] Error updating module:', error);
      throw new Error(handleApiError(error));
    }
  }

  /**
   * Delete module (Dekan only)
   */
  async deleteModule(id: number, force: boolean = false): Promise<ApiResponse> {
    try {
      console.log('[ModulService] Deleting module:', id, 'force:', force);
      
      const response = await api.delete<ApiResponse>(`/module/${id}?force=${force}`);
      
      console.log('[ModulService] ✓ Module deleted');
      return response.data;
    } catch (error) {
      console.error('[ModulService] Error deleting module:', error);
      throw new Error(handleApiError(error));
    }
  }

  // =========================================================================
  // LEHRFORMEN
  // =========================================================================

  /**
   * Add lehrform to module
   */
  async addLehrform(modulId: number, data: LehrformData): Promise<ApiResponse> {
    try {
      console.log('[ModulService] Adding lehrform to module:', modulId);
      
      const response = await api.post<ApiResponse>(`/module/${modulId}/lehrformen`, data);
      
      console.log('[ModulService] ✓ Lehrform added');
      return response.data;
    } catch (error) {
      console.error('[ModulService] Error adding lehrform:', error);
      throw new Error(handleApiError(error));
    }
  }

  /**
   * Update lehrform SWS
   */
  async updateLehrform(modulId: number, lehrformZuordnungId: number, sws: number): Promise<ApiResponse> {
    try {
      console.log('[ModulService] Updating lehrform:', lehrformZuordnungId);
      
      const response = await api.put<ApiResponse>(
        `/module/${modulId}/lehrformen/${lehrformZuordnungId}`,
        { sws }
      );
      
      console.log('[ModulService] ✓ Lehrform updated');
      return response.data;
    } catch (error) {
      console.error('[ModulService] Error updating lehrform:', error);
      throw new Error(handleApiError(error));
    }
  }

  /**
   * Delete lehrform from module
   */
  async deleteLehrform(modulId: number, lehrformZuordnungId: number): Promise<ApiResponse> {
    try {
      console.log('[ModulService] Deleting lehrform:', lehrformZuordnungId);
      
      const response = await api.delete<ApiResponse>(
        `/module/${modulId}/lehrformen/${lehrformZuordnungId}`
      );
      
      console.log('[ModulService] ✓ Lehrform deleted');
      return response.data;
    } catch (error) {
      console.error('[ModulService] Error deleting lehrform:', error);
      throw new Error(handleApiError(error));
    }
  }

  // =========================================================================
  // DOZENTEN
  // =========================================================================

  /**
   * Add dozent to module
   */
  async addDozent(modulId: number, data: DozentData): Promise<ApiResponse> {
    try {
      console.log('[ModulService] Adding dozent to module:', modulId);
      
      const response = await api.post<ApiResponse>(`/module/${modulId}/dozenten`, data);
      
      console.log('[ModulService] ✓ Dozent added');
      return response.data;
    } catch (error) {
      console.error('[ModulService] Error adding dozent:', error);
      throw new Error(handleApiError(error));
    }
  }

  /**
   * Update dozent rolle
   */
  async updateDozent(modulId: number, dozentZuordnungId: number, rolle: string): Promise<ApiResponse> {
    try {
      console.log('[ModulService] Updating dozent:', dozentZuordnungId);
      
      const response = await api.put<ApiResponse>(
        `/module/${modulId}/dozenten/${dozentZuordnungId}`,
        { rolle }
      );
      
      console.log('[ModulService] ✓ Dozent updated');
      return response.data;
    } catch (error) {
      console.error('[ModulService] Error updating dozent:', error);
      throw new Error(handleApiError(error));
    }
  }

  /**
   * Delete dozent from module
   */
  async deleteDozent(modulId: number, dozentZuordnungId: number): Promise<ApiResponse> {
    try {
      console.log('[ModulService] Deleting dozent:', dozentZuordnungId);

      const response = await api.delete<ApiResponse>(
        `/module/${modulId}/dozenten/${dozentZuordnungId}`
      );

      console.log('[ModulService] ✓ Dozent deleted');
      return response.data;
    } catch (error) {
      console.error('[ModulService] Error deleting dozent:', error);
      throw new Error(handleApiError(error));
    }
  }

  /**
   * Update dozent rolle
   */
  async updateDozentRolle(modulId: number, dozentZuordnungId: number, rolle: string): Promise<ApiResponse> {
    try {
      console.log('[ModulService] Updating dozent rolle:', dozentZuordnungId, rolle);

      const response = await api.put<ApiResponse>(
        `/module/${modulId}/dozenten/${dozentZuordnungId}`,
        { rolle }
      );

      console.log('[ModulService] ✓ Dozent rolle updated');
      return response.data;
    } catch (error) {
      console.error('[ModulService] Error updating dozent rolle:', error);
      throw new Error(handleApiError(error));
    }
  }

  /**
   * Replace dozent with another dozent (keeps the same role)
   */
  async replaceDozent(modulId: number, oldDozentZuordnungId: number, newDozentId: number): Promise<ApiResponse> {
    try {
      console.log('[ModulService] Replacing dozent:', oldDozentZuordnungId, 'with', newDozentId);

      const response = await api.put<ApiResponse>(
        `/module/${modulId}/dozenten/${oldDozentZuordnungId}/replace`,
        { neuer_dozent_id: newDozentId }
      );

      console.log('[ModulService] ✓ Dozent replaced');
      return response.data;
    } catch (error) {
      console.error('[ModulService] Error replacing dozent:', error);
      throw new Error(handleApiError(error));
    }
  }

  // =========================================================================
  // LITERATUR
  // =========================================================================

  /**
   * Add literatur to module
   */
  async addLiteratur(modulId: number, data: LiteraturData): Promise<ApiResponse> {
    try {
      console.log('[ModulService] Adding literatur to module:', modulId);
      
      const response = await api.post<ApiResponse>(`/module/${modulId}/literatur`, data);
      
      console.log('[ModulService] ✓ Literatur added');
      return response.data;
    } catch (error) {
      console.error('[ModulService] Error adding literatur:', error);
      throw new Error(handleApiError(error));
    }
  }

  /**
   * Update literatur
   */
  async updateLiteratur(modulId: number, literaturId: number, data: LiteraturData): Promise<ApiResponse> {
    try {
      console.log('[ModulService] Updating literatur:', literaturId);
      
      const response = await api.put<ApiResponse>(
        `/module/${modulId}/literatur/${literaturId}`,
        data
      );
      
      console.log('[ModulService] ✓ Literatur updated');
      return response.data;
    } catch (error) {
      console.error('[ModulService] Error updating literatur:', error);
      throw new Error(handleApiError(error));
    }
  }

  /**
   * Delete literatur from module
   */
  async deleteLiteratur(modulId: number, literaturId: number): Promise<ApiResponse> {
    try {
      console.log('[ModulService] Deleting literatur:', literaturId);
      
      const response = await api.delete<ApiResponse>(
        `/module/${modulId}/literatur/${literaturId}`
      );
      
      console.log('[ModulService] ✓ Literatur deleted');
      return response.data;
    } catch (error) {
      console.error('[ModulService] Error deleting literatur:', error);
      throw new Error(handleApiError(error));
    }
  }

  // =========================================================================
  // PRÜFUNG
  // =========================================================================

  /**
   * Update pruefung
   */
  async updatePruefung(modulId: number, data: PruefungData): Promise<ApiResponse> {
    try {
      console.log('[ModulService] Updating pruefung for module:', modulId);
      
      const response = await api.put<ApiResponse>(`/module/${modulId}/pruefung`, data);
      
      console.log('[ModulService] ✓ Pruefung updated');
      return response.data;
    } catch (error) {
      console.error('[ModulService] Error updating pruefung:', error);
      throw new Error(handleApiError(error));
    }
  }

  // =========================================================================
  // LERNERGEBNISSE
  // =========================================================================

  /**
   * Update lernergebnisse
   */
  async updateLernergebnisse(modulId: number, data: LernergebnisseData): Promise<ApiResponse> {
    try {
      console.log('[ModulService] Updating lernergebnisse for module:', modulId);
      
      const response = await api.put<ApiResponse>(`/module/${modulId}/lernergebnisse`, data);
      
      console.log('[ModulService] ✓ Lernergebnisse updated');
      return response.data;
    } catch (error) {
      console.error('[ModulService] Error updating lernergebnisse:', error);
      throw new Error(handleApiError(error));
    }
  }

  // =========================================================================
  // VORAUSSETZUNGEN
  // =========================================================================

  /**
   * Update voraussetzungen
   */
  async updateVoraussetzungen(modulId: number, data: VoraussetzungenData): Promise<ApiResponse> {
    try {
      console.log('[ModulService] Updating voraussetzungen for module:', modulId);
      
      const response = await api.put<ApiResponse>(`/module/${modulId}/voraussetzungen`, data);
      
      console.log('[ModulService] ✓ Voraussetzungen updated');
      return response.data;
    } catch (error) {
      console.error('[ModulService] Error updating voraussetzungen:', error);
      throw new Error(handleApiError(error));
    }
  }

  // =========================================================================
  // ARBEITSAUFWAND
  // =========================================================================

  /**
   * Update arbeitsaufwand
   */
  async updateArbeitsaufwand(modulId: number, data: ArbeitsaufwandData): Promise<ApiResponse> {
    try {
      console.log('[ModulService] Updating arbeitsaufwand for module:', modulId);
      
      const response = await api.put<ApiResponse>(`/module/${modulId}/arbeitsaufwand`, data);
      
      console.log('[ModulService] ✓ Arbeitsaufwand updated');
      return response.data;
    } catch (error) {
      console.error('[ModulService] Error updating arbeitsaufwand:', error);
      throw new Error(handleApiError(error));
    }
  }

  // =========================================================================
  // OPTIONS (HILFSLISTEN)
  // =========================================================================

  /**
   * Get all lehrformen for selection
   */
  async getLehrformenOptions(): Promise<ApiResponse<any[]>> {
    try {
      const response = await api.get<ApiResponse<any[]>>('/module/options/lehrformen');
      return response.data;
    } catch (error) {
      throw new Error(handleApiError(error));
    }
  }

  /**
   * Get all dozenten for selection
   */
  async getDozentenOptions(): Promise<ApiResponse<any[]>> {
    try {
      const response = await api.get<ApiResponse<any[]>>('/module/options/dozenten');
      return response.data;
    } catch (error) {
      throw new Error(handleApiError(error));
    }
  }

  /**
   * Get all studiengaenge for selection
   */
  async getStudiengaengeOptions(): Promise<ApiResponse<any[]>> {
    try {
      const response = await api.get<ApiResponse<any[]>>('/module/options/studiengaenge');
      return response.data;
    } catch (error) {
      throw new Error(handleApiError(error));
    }
  }
}

// Export singleton instance
export default new ModulService();