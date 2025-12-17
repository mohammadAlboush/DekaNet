import api, { ApiResponse, handleApiError } from './api';
import { 
  Semesterplanung, 
  CreatePlanungData, 
  AddModulData,
  GeplantesModul 
} from '../types/planung.types';

/**
 * Planung Service - PRODUCTION READY
 * ===================================
 * Service für Semesterplanung mit vollständigem Workflow
 * 
 * FEATURES:
 * - Vollständiger CRUD
 * - Workflow (einreichen, freigeben, ablehnen)
 * - Modul-Management
 * - Wunsch-freie Tage
 * - Dekan-spezifische Endpoints
 */

class PlanungService {
  // =========================================================================
  // PLANUNG CRUD
  // =========================================================================

  /**
   * Get all planungen (role-aware)
   * - Professor/Lehrbeauftragter: Nur eigene Planungen
   * - Dekan: Alle Planungen
   */
  async getAllPlanungen(params?: {
    semester_id?: number;
    status?: string;
    nur_aktive_phase?: boolean;      // ✅ HINZUGEFÜGT
  }): Promise<ApiResponse<Semesterplanung[]>> {
    try {
      console.log('[PlanungService] Fetching planungen with params:', params);

      const queryParams = new URLSearchParams();
      if (params?.semester_id) {
        queryParams.append('semester_id', params.semester_id.toString());
      }
      if (params?.status) {
        queryParams.append('status', params.status);
      }
      if (params?.nur_aktive_phase) {
        queryParams.append('nur_aktive_phase', 'true');
      }

      const url = `/planung${queryParams.toString() ? `?${queryParams}` : ''}`;
      console.log('[PlanungService] Request URL:', url);

      const response = await api.get<ApiResponse<Semesterplanung[]>>(url);

      console.log('[PlanungService] Response:', {
        success: response.data.success,
        dataLength: response.data.data?.length || 0
      });

      return response.data;
    } catch (error) {
      console.error('[PlanungService] Error fetching planungen:', error);
      throw new Error(handleApiError(error));
    }
  }

  /**
   * Get my planungen (Professor/Lehrbeauftragter)
   */
  async getMeinePlanungen(): Promise<ApiResponse<Semesterplanung[]>> {
    try {
      console.log('[PlanungService] Fetching meine planungen...');
      
      const response = await api.get<ApiResponse<Semesterplanung[]>>('/planung');
      
      console.log('[PlanungService] Meine Planungen:', response.data.data?.length || 0);
      return response.data;
    } catch (error) {
      console.error('[PlanungService] Error fetching meine planungen:', error);
      throw new Error(handleApiError(error));
    }
  }

  /**
   * Get current planung for active planning semester
   */
  async getMeineAktuellePlanung(): Promise<ApiResponse<Semesterplanung>> {
    try {
      console.log('[PlanungService] Fetching aktuelle planung...');
      
      const response = await api.get<ApiResponse<Semesterplanung>>('/planung/meine');
      
      console.log('[PlanungService] Aktuelle Planung:', response.data.data?.id || 'keine');
      return response.data;
    } catch (error) {
      console.error('[PlanungService] Error fetching aktuelle planung:', error);
      throw new Error(handleApiError(error));
    }
  }

  /**
   * Get single planung by ID
   */
  async getPlanung(id: number): Promise<ApiResponse<Semesterplanung>> {
    try {
      console.log('[PlanungService] Fetching planung:', id);
      
      const response = await api.get<ApiResponse<Semesterplanung>>(`/planung/${id}`);
      
      console.log('[PlanungService] Planung loaded:', response.data.data?.status);
      return response.data;
    } catch (error) {
      console.error('[PlanungService] Error fetching planung:', error);
      throw new Error(handleApiError(error));
    }
  }

  /**
   * Create new planung
   */
  async createPlanung(data: CreatePlanungData): Promise<ApiResponse<Semesterplanung>> {
    try {
      console.log('[PlanungService] Creating planung:', data);
      
      const response = await api.post<ApiResponse<Semesterplanung>>('/planung', data);
      
      console.log('[PlanungService] Planung created:', response.data.data?.id);
      return response.data;
    } catch (error) {
      console.error('[PlanungService] Error creating planung:', error);
      throw new Error(handleApiError(error));
    }
  }

  /**
   * Update planung
   */
  async updatePlanung(
    id: number, 
    data: Partial<Semesterplanung>
  ): Promise<ApiResponse<Semesterplanung>> {
    try {
      console.log('[PlanungService] Updating planung:', id);
      
      const response = await api.put<ApiResponse<Semesterplanung>>(`/planung/${id}`, data);
      
      console.log('[PlanungService] Planung updated');
      return response.data;
    } catch (error) {
      console.error('[PlanungService] Error updating planung:', error);
      throw new Error(handleApiError(error));
    }
  }

  /**
   * Delete planung
   */
  async deletePlanung(id: number, force: boolean = false): Promise<ApiResponse> {
    try {
      console.log('[PlanungService] Deleting planung:', id, 'force:', force);
      
      const url = `/planung/${id}${force ? '?force=true' : ''}`;
      const response = await api.delete<ApiResponse>(url);
      
      console.log('[PlanungService] Planung deleted');
      return response.data;
    } catch (error) {
      console.error('[PlanungService] Error deleting planung:', error);
      throw new Error(handleApiError(error));
    }
  }

  // =========================================================================
  // MODULE MANAGEMENT
  // =========================================================================

  /**
   * Add module to planung
   */
  async addModule(
    planungId: number, 
    data: AddModulData
  ): Promise<ApiResponse<GeplantesModul>> {
    try {
      console.log('[PlanungService] Adding module to planung:', planungId);
      
      const response = await api.post<ApiResponse<GeplantesModul>>(
        `/planung/${planungId}/modul`,
        data
      );
      
      console.log('[PlanungService] Module added:', response.data.data?.id);
      return response.data;
    } catch (error) {
      console.error('[PlanungService] Error adding module:', error);
      throw new Error(handleApiError(error));
    }
  }

  /**
   * Update module in planung
   */
  async updateModule(
    planungId: number,
    moduleId: number,
    data: Partial<AddModulData>
  ): Promise<ApiResponse<GeplantesModul>> {
    try {
      console.log('[PlanungService] Updating module:', moduleId);
      
      const response = await api.put<ApiResponse<GeplantesModul>>(
        `/planung/${planungId}/modul/${moduleId}`,
        data
      );
      
      console.log('[PlanungService] Module updated');
      return response.data;
    } catch (error) {
      console.error('[PlanungService] Error updating module:', error);
      throw new Error(handleApiError(error));
    }
  }

  /**
   * Remove module from planung
   */
  async removeModule(planungId: number, moduleId: number): Promise<ApiResponse> {
    try {
      console.log('[PlanungService] Removing module:', moduleId);
      
      const response = await api.delete<ApiResponse>(
        `/planung/${planungId}/modul/${moduleId}`
      );
      
      console.log('[PlanungService] Module removed');
      return response.data;
    } catch (error) {
      console.error('[PlanungService] Error removing module:', error);
      throw new Error(handleApiError(error));
    }
  }

  // =========================================================================
  // WUNSCH-FREIE TAGE
  // =========================================================================

  /**
   * Add wunsch-freier tag
   */
  async addWunschTag(
    planungId: number,
    data: { datum: string; grund?: string; ganztags?: boolean }
  ): Promise<ApiResponse> {
    try {
      console.log('[PlanungService] Adding wunsch tag to planung:', planungId);
      
      const response = await api.post<ApiResponse>(
        `/planung/${planungId}/wunsch-tag`,
        data
      );
      
      console.log('[PlanungService] Wunsch tag added');
      return response.data;
    } catch (error) {
      console.error('[PlanungService] Error adding wunsch tag:', error);
      throw new Error(handleApiError(error));
    }
  }

  /**
   * Remove wunsch-freier tag
   */
  async removeWunschTag(planungId: number, wunschId: number): Promise<ApiResponse> {
    try {
      console.log('[PlanungService] Removing wunsch tag:', wunschId);

      const response = await api.delete<ApiResponse>(
        `/planung/${planungId}/wunsch-tag/${wunschId}`
      );

      console.log('[PlanungService] Wunsch tag removed');
      return response.data;
    } catch (error) {
      console.error('[PlanungService] Error removing wunsch tag:', error);
      throw new Error(handleApiError(error));
    }
  }

  /**
   * Update all additional information in one call
   * Saves anmerkungen, raumbedarf, room_requirements, special_requests, and wunsch_freie_tage
   */
  async updateZusatzinfos(
    planungId: number,
    data: {
      anmerkungen?: string;
      raumbedarf?: string;
      room_requirements?: any[];
      special_requests?: any;
      wunsch_freie_tage?: Array<{
        wochentag: string;
        zeitraum: string;
        prioritaet: string;
        grund?: string;
      }>;
    }
  ): Promise<ApiResponse<Semesterplanung>> {
    try {
      console.log('[PlanungService] Updating zusatzinfos for planung:', planungId);
      console.log('[PlanungService] Data:', data);

      const response = await api.put<ApiResponse<Semesterplanung>>(
        `/planung/${planungId}/zusatzinfos`,
        data
      );

      console.log('[PlanungService] Zusatzinfos updated successfully');
      return response.data;
    } catch (error) {
      console.error('[PlanungService] Error updating zusatzinfos:', error);
      throw new Error(handleApiError(error));
    }
  }

  // =========================================================================
  // WORKFLOW - CRITICAL ENDPOINTS
  // =========================================================================

  /**
   * Submit planung (entwurf → eingereicht)
   */
  async submitPlanung(id: number): Promise<ApiResponse<Semesterplanung>> {
    try {
      console.log('[PlanungService] 📤 Submitting planung:', id);
      
      const response = await api.post<ApiResponse<Semesterplanung>>(
        `/planung/${id}/einreichen`
      );
      
      console.log('[PlanungService] ✅ Planung submitted successfully');
      console.log('[PlanungService] New status:', response.data.data?.status);
      
      return response.data;
    } catch (error) {
      console.error('[PlanungService] ❌ Error submitting planung:', error);
      throw new Error(handleApiError(error));
    }
  }

  /**
   * Approve planung (nur Dekan) (eingereicht → freigegeben)
   */
  async approvePlanung(id: number): Promise<ApiResponse<Semesterplanung>> {
    try {
      console.log('[PlanungService] ✅ Approving planung:', id);
      
      const response = await api.post<ApiResponse<Semesterplanung>>(
        `/planung/${id}/freigeben`
      );
      
      console.log('[PlanungService] ✅ Planung approved successfully');
      console.log('[PlanungService] New status:', response.data.data?.status);
      
      return response.data;
    } catch (error) {
      console.error('[PlanungService] ❌ Error approving planung:', error);
      throw new Error(handleApiError(error));
    }
  }

  /**
   * Reject planung (nur Dekan) (eingereicht → abgelehnt)
   */
  async rejectPlanung(id: number, grund: string): Promise<ApiResponse<Semesterplanung>> {
    try {
      console.log('[PlanungService] ❌ Rejecting planung:', id, 'Grund:', grund);
      
      const response = await api.post<ApiResponse<Semesterplanung>>(
        `/planung/${id}/ablehnen`,
        { grund }
      );
      
      console.log('[PlanungService] ❌ Planung rejected');
      console.log('[PlanungService] New status:', response.data.data?.status);
      
      return response.data;
    } catch (error) {
      console.error('[PlanungService] ❌ Error rejecting planung:', error);
      throw new Error(handleApiError(error));
    }
  }

  // =========================================================================
  // DEKAN-SPEZIFISCHE ENDPOINTS
  // =========================================================================

  /**
   * Get all planungen (Dekan view)
   */
  async getAllPlanungenDekan(params?: {
    semester_id?: number;
    status?: string;
    nur_aktive_phase?: boolean;      // ✅ HINZUGEFÜGT
  }): Promise<ApiResponse<Semesterplanung[]>> {
    try {
      console.log('[PlanungService] [DEKAN] Fetching all planungen:', params);

      const queryParams = new URLSearchParams();
      if (params?.semester_id) {
        queryParams.append('semester_id', params.semester_id.toString());
      }
      if (params?.status) {
        queryParams.append('status', params.status);
      }
      if (params?.nur_aktive_phase) {
        queryParams.append('nur_aktive_phase', 'true');
      }

      const url = `/planung/dekan${queryParams.toString() ? `?${queryParams}` : ''}`;
      const response = await api.get<ApiResponse<Semesterplanung[]>>(url);

      console.log('[PlanungService] [DEKAN] Planungen loaded:', response.data.data?.length || 0);
      return response.data;
    } catch (error) {
      console.error('[PlanungService] [DEKAN] Error fetching planungen:', error);
      throw new Error(handleApiError(error));
    }
  }

  /**
   * Get eingereichte planungen (Dekan)
   */
  async getEingereichtePlanungen(semester_id?: number): Promise<ApiResponse<Semesterplanung[]>> {
    try {
      console.log('[PlanungService] [DEKAN] Fetching eingereichte planungen');
      
      const url = semester_id 
        ? `/planung/eingereicht?semester_id=${semester_id}`
        : '/planung/eingereicht';
      
      const response = await api.get<ApiResponse<Semesterplanung[]>>(url);
      
      console.log('[PlanungService] [DEKAN] Eingereichte Planungen:', response.data.data?.length || 0);
      return response.data;
    } catch (error) {
      console.error('[PlanungService] [DEKAN] Error fetching eingereichte planungen:', error);
      throw new Error(handleApiError(error));
    }
  }

  /**
   * Calculate SWS for planung
   */
  async calculateSWS(planungId: number): Promise<ApiResponse<{ gesamt_sws: number }>> {
    try {
      console.log('[PlanungService] Calculating SWS for planung:', planungId);
      
      const response = await api.post<ApiResponse<{ gesamt_sws: number }>>(
        `/planung/${planungId}/berechne-sws`
      );
      
      console.log('[PlanungService] SWS calculated:', response.data.data?.gesamt_sws);
      return response.data;
    } catch (error) {
      console.error('[PlanungService] Error calculating SWS:', error);
      throw new Error(handleApiError(error));
    }
  }
}

export default new PlanungService();