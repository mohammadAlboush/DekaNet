import api, { ApiResponse, handleApiError } from './api';
import {
  Semesterplanung,
  CreatePlanungData,
  AddModulData,
  GeplantesModul,
  RoomRequirement,
  SpecialRequests
} from '../types/planung.types';
import { createContextLogger } from '../utils/logger';

const log = createContextLogger('PlanungService');

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
      log.debug(' Fetching planungen with params:', params);

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
      log.debug(' Request URL:', url);

      const response = await api.get<ApiResponse<Semesterplanung[]>>(url);

      log.debug(' Response:', {
        success: response.data.success,
        dataLength: response.data.data?.length || 0
      });

      return response.data;
    } catch (error) {
      log.error(' Error fetching planungen:', error);
      throw new Error(handleApiError(error));
    }
  }

  /**
   * Get my planungen (Professor/Lehrbeauftragter)
   */
  async getMeinePlanungen(): Promise<ApiResponse<Semesterplanung[]>> {
    try {
      log.debug(' Fetching meine planungen...');
      
      const response = await api.get<ApiResponse<Semesterplanung[]>>('/planung');
      
      log.debug(' Meine Planungen:', response.data.data?.length || 0);
      return response.data;
    } catch (error) {
      log.error(' Error fetching meine planungen:', error);
      throw new Error(handleApiError(error));
    }
  }

  /**
   * Get current planung for active planning semester
   */
  async getMeineAktuellePlanung(): Promise<ApiResponse<Semesterplanung>> {
    try {
      log.debug(' Fetching aktuelle planung...');
      
      const response = await api.get<ApiResponse<Semesterplanung>>('/planung/meine');
      
      log.debug(' Aktuelle Planung:', response.data.data?.id || 'keine');
      return response.data;
    } catch (error) {
      log.error(' Error fetching aktuelle planung:', error);
      throw new Error(handleApiError(error));
    }
  }

  /**
   * Get single planung by ID
   */
  async getPlanung(id: number): Promise<ApiResponse<Semesterplanung>> {
    try {
      log.debug(' Fetching planung:', id);
      
      const response = await api.get<ApiResponse<Semesterplanung>>(`/planung/${id}`);
      
      log.debug(' Planung loaded:', response.data.data?.status);
      return response.data;
    } catch (error) {
      log.error(' Error fetching planung:', error);
      throw new Error(handleApiError(error));
    }
  }

  /**
   * Create new planung
   */
  async createPlanung(data: CreatePlanungData): Promise<ApiResponse<Semesterplanung>> {
    try {
      log.debug(' Creating planung:', data);
      
      const response = await api.post<ApiResponse<Semesterplanung>>('/planung', data);
      
      log.debug(' Planung created:', response.data.data?.id);
      return response.data;
    } catch (error) {
      log.error(' Error creating planung:', error);
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
      log.debug(' Updating planung:', id);
      
      const response = await api.put<ApiResponse<Semesterplanung>>(`/planung/${id}`, data);
      
      log.debug(' Planung updated');
      return response.data;
    } catch (error) {
      log.error(' Error updating planung:', error);
      throw new Error(handleApiError(error));
    }
  }

  /**
   * Delete planung
   */
  async deletePlanung(id: number, force: boolean = false): Promise<ApiResponse> {
    try {
      log.debug(' Deleting planung:', id, 'force:', force);
      
      const url = `/planung/${id}${force ? '?force=true' : ''}`;
      const response = await api.delete<ApiResponse>(url);
      
      log.debug(' Planung deleted');
      return response.data;
    } catch (error) {
      log.error(' Error deleting planung:', error);
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
      log.debug(' Adding module to planung:', planungId);
      
      const response = await api.post<ApiResponse<GeplantesModul>>(
        `/planung/${planungId}/modul`,
        data
      );
      
      log.debug(' Module added:', response.data.data?.id);
      return response.data;
    } catch (error) {
      log.error(' Error adding module:', error);
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
      log.debug(' Updating module:', moduleId);
      
      const response = await api.put<ApiResponse<GeplantesModul>>(
        `/planung/${planungId}/modul/${moduleId}`,
        data
      );
      
      log.debug(' Module updated');
      return response.data;
    } catch (error) {
      log.error(' Error updating module:', error);
      throw new Error(handleApiError(error));
    }
  }

  /**
   * Remove module from planung
   */
  async removeModule(planungId: number, moduleId: number): Promise<ApiResponse> {
    try {
      log.debug(' Removing module:', moduleId);
      
      const response = await api.delete<ApiResponse>(
        `/planung/${planungId}/modul/${moduleId}`
      );
      
      log.debug(' Module removed');
      return response.data;
    } catch (error) {
      log.error(' Error removing module:', error);
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
      log.debug(' Adding wunsch tag to planung:', planungId);
      
      const response = await api.post<ApiResponse>(
        `/planung/${planungId}/wunsch-tag`,
        data
      );
      
      log.debug(' Wunsch tag added');
      return response.data;
    } catch (error) {
      log.error(' Error adding wunsch tag:', error);
      throw new Error(handleApiError(error));
    }
  }

  /**
   * Remove wunsch-freier tag
   */
  async removeWunschTag(planungId: number, wunschId: number): Promise<ApiResponse> {
    try {
      log.debug(' Removing wunsch tag:', wunschId);

      const response = await api.delete<ApiResponse>(
        `/planung/${planungId}/wunsch-tag/${wunschId}`
      );

      log.debug(' Wunsch tag removed');
      return response.data;
    } catch (error) {
      log.error(' Error removing wunsch tag:', error);
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
      room_requirements?: RoomRequirement[];  // ✅ TYPESAFE
      special_requests?: SpecialRequests;     // ✅ TYPESAFE
      wunsch_freie_tage?: Array<{
        wochentag: string;
        zeitraum: string;
        prioritaet: string;
        grund?: string;
      }>;
    }
  ): Promise<ApiResponse<Semesterplanung>> {
    try {
      log.debug(' Updating zusatzinfos for planung:', planungId);
      log.debug(' Data:', data);

      const response = await api.put<ApiResponse<Semesterplanung>>(
        `/planung/${planungId}/zusatzinfos`,
        data
      );

      log.debug(' Zusatzinfos updated successfully');
      return response.data;
    } catch (error) {
      log.error(' Error updating zusatzinfos:', error);
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
      log.debug(' 📤 Submitting planung:', id);
      
      const response = await api.post<ApiResponse<Semesterplanung>>(
        `/planung/${id}/einreichen`
      );
      
      log.debug(' ✅ Planung submitted successfully');
      log.debug(' New status:', response.data.data?.status);
      
      return response.data;
    } catch (error) {
      log.error(' ❌ Error submitting planung:', error);
      throw new Error(handleApiError(error));
    }
  }

  /**
   * Approve planung (nur Dekan) (eingereicht → freigegeben)
   */
  async approvePlanung(id: number): Promise<ApiResponse<Semesterplanung>> {
    try {
      log.debug(' ✅ Approving planung:', id);
      
      const response = await api.post<ApiResponse<Semesterplanung>>(
        `/planung/${id}/freigeben`
      );
      
      log.debug(' ✅ Planung approved successfully');
      log.debug(' New status:', response.data.data?.status);
      
      return response.data;
    } catch (error) {
      log.error(' ❌ Error approving planung:', error);
      throw new Error(handleApiError(error));
    }
  }

  /**
   * Reject planung (nur Dekan) (eingereicht → abgelehnt)
   */
  async rejectPlanung(id: number, grund: string): Promise<ApiResponse<Semesterplanung>> {
    try {
      log.debug(' ❌ Rejecting planung:', id, 'Grund:', grund);
      
      const response = await api.post<ApiResponse<Semesterplanung>>(
        `/planung/${id}/ablehnen`,
        { grund }
      );
      
      log.debug(' ❌ Planung rejected');
      log.debug(' New status:', response.data.data?.status);
      
      return response.data;
    } catch (error) {
      log.error(' ❌ Error rejecting planung:', error);
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
      log.debug(' [DEKAN] Fetching all planungen:', params);

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

      log.debug(' [DEKAN] Planungen loaded:', response.data.data?.length || 0);
      return response.data;
    } catch (error) {
      log.error(' [DEKAN] Error fetching planungen:', error);
      throw new Error(handleApiError(error));
    }
  }

  /**
   * Get eingereichte planungen (Dekan)
   */
  async getEingereichtePlanungen(semester_id?: number): Promise<ApiResponse<Semesterplanung[]>> {
    try {
      log.debug(' [DEKAN] Fetching eingereichte planungen');
      
      const url = semester_id 
        ? `/planung/eingereicht?semester_id=${semester_id}`
        : '/planung/eingereicht';
      
      const response = await api.get<ApiResponse<Semesterplanung[]>>(url);
      
      log.debug(' [DEKAN] Eingereichte Planungen:', response.data.data?.length || 0);
      return response.data;
    } catch (error) {
      log.error(' [DEKAN] Error fetching eingereichte planungen:', error);
      throw new Error(handleApiError(error));
    }
  }

  /**
   * Calculate SWS for planung
   */
  async calculateSWS(planungId: number): Promise<ApiResponse<{ gesamt_sws: number }>> {
    try {
      log.debug(' Calculating SWS for planung:', planungId);
      
      const response = await api.post<ApiResponse<{ gesamt_sws: number }>>(
        `/planung/${planungId}/berechne-sws`
      );
      
      log.debug(' SWS calculated:', response.data.data?.gesamt_sws);
      return response.data;
    } catch (error) {
      log.error(' Error calculating SWS:', error);
      throw new Error(handleApiError(error));
    }
  }
}

export default new PlanungService();