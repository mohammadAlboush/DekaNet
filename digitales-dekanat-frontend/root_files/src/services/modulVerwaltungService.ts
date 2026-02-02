import api, { ApiResponse, handleApiError } from './api';
import { createContextLogger } from '../utils/logger';

const log = createContextLogger('ModulVerwaltung');

/**
 * Modul-Verwaltung Service
 * ========================
 * Feature 3: Dekan kann Module zwischen Dozenten zuweisen
 *
 * WICHTIG: Alle Endpoints nur für Dekan-Rolle!
 */

// ========================================================================
// TYPES
// ========================================================================

export interface ModulMitDozenten {
  id: number;
  kuerzel: string;
  bezeichnung_de: string;
  bezeichnung_en?: string;
  leistungspunkte: number;
  aktiv: boolean;
  dozenten: ModulDozentZuordnung[];
}

export interface ModulDozentZuordnung {
  id: number; // zuordnung_id
  name: string;
  name_kurz: string;
  rolle: string; // 'verantwortlich', 'mitwirkend', etc.
  zuordnung_id: number;
  po_id: number;
  vertreter_id?: number;
  zweitpruefer_id?: number;
}

export interface DozentHinzufuegenData {
  po_id: number;
  dozent_id: number;
  rolle: string;
  bemerkung?: string;
}

export interface DozentErsetzenData {
  neuer_dozent_id: number;
  bemerkung?: string;
}

export interface DozentEntfernenData {
  bemerkung?: string;
}

export interface BulkTransferData {
  modul_ids: number[];
  von_dozent_id: number;
  zu_dozent_id: number;
  po_id: number;
  rolle?: string;
  bemerkung?: string;
}

export interface BulkTransferResult {
  erfolgreich: number[];
  fehlgeschlagen: Array<{
    modul_id: number;
    fehler: string;
  }>;
  gesamt: number;
  erfolgreich_count: number;
  fehlgeschlagen_count: number;
}

export interface AuditLogEntry {
  id: number;
  modul: {
    id: number;
    kuerzel: string;
    bezeichnung_de: string;
  } | null;
  aktion: string; // 'dozent_hinzugefuegt', 'dozent_entfernt', 'dozent_ersetzt'
  alter_dozent: {
    id: number;
    name: string;
  } | null;
  neuer_dozent: {
    id: number;
    name: string;
  } | null;
  alte_rolle?: string;
  neue_rolle?: string;
  geaendert_von: {
    id: number;
    name: string;
  } | null;
  bemerkung?: string;
  created_at: string;
}

// ========================================================================
// SERVICE CLASS
// ========================================================================

class ModulVerwaltungService {
  /**
   * Get all module with assigned dozenten
   */
  async getModuleMitDozenten(params?: {
    po_id?: number;
    nur_aktive?: boolean;
  }): Promise<ApiResponse<ModulMitDozenten[]>> {
    try {
      log.debug('Fetching module with params:', params);

      const queryParams = new URLSearchParams();
      if (params?.po_id) queryParams.append('po_id', params.po_id.toString());
      if (params?.nur_aktive !== undefined) {
        queryParams.append('nur_aktive', params.nur_aktive.toString());
      }

      const url = `/modul-verwaltung/${queryParams.toString() ? `?${queryParams}` : ''}`;
      log.debug('Request URL:', url);

      const response = await api.get<ApiResponse<ModulMitDozenten[]>>(url);

      log.debug('Response:', {
        success: response.data.success,
        moduleCount: response.data.data?.length || 0
      });

      return response.data;
    } catch (error) {
      log.error('Error fetching module:', error);
      throw new Error(handleApiError(error));
    }
  }

  /**
   * Add dozent to modul
   */
  async addDozentToModul(
    modulId: number,
    data: DozentHinzufuegenData
  ): Promise<ApiResponse<any>> {
    try {
      log.debug('Adding dozent to modul:', modulId, data);

      const response = await api.post<ApiResponse<any>>(
        `/modul-verwaltung/${modulId}/dozenten`,
        data
      );

      log.debug('Dozent added to modul');
      return response.data;
    } catch (error) {
      log.error('Error adding dozent:', error);
      throw new Error(handleApiError(error));
    }
  }

  /**
   * Remove dozent from modul
   */
  async removeDozentFromModul(
    zuordnungId: number,
    data?: DozentEntfernenData
  ): Promise<ApiResponse> {
    try {
      log.debug('Removing dozent:', zuordnungId);

      const response = await api.delete<ApiResponse>(
        `/modul-verwaltung/dozenten/${zuordnungId}`,
        { data } // Pass bemerkung in request body
      );

      log.debug('Dozent removed from modul');
      return response.data;
    } catch (error) {
      log.error('Error removing dozent:', error);
      throw new Error(handleApiError(error));
    }
  }

  /**
   * Replace dozent
   */
  async replaceDozent(
    zuordnungId: number,
    data: DozentErsetzenData
  ): Promise<ApiResponse<any>> {
    try {
      log.debug('Replacing dozent:', zuordnungId, data);

      const response = await api.put<ApiResponse<any>>(
        `/modul-verwaltung/dozenten/${zuordnungId}`,
        data
      );

      log.debug('Dozent replaced');
      return response.data;
    } catch (error) {
      log.error('Error replacing dozent:', error);
      throw new Error(handleApiError(error));
    }
  }

  /**
   * Bulk transfer module
   */
  async bulkTransferModule(
    data: BulkTransferData
  ): Promise<ApiResponse<BulkTransferResult>> {
    try {
      log.debug('Bulk transfer:', data);

      const response = await api.post<ApiResponse<BulkTransferResult>>(
        '/modul-verwaltung/bulk-transfer',
        data
      );

      log.debug('Bulk transfer completed:', response.data.data);
      return response.data;
    } catch (error) {
      log.error('Error in bulk transfer:', error);
      throw new Error(handleApiError(error));
    }
  }

  /**
   * Get audit log
   */
  async getAuditLog(params?: {
    modul_id?: number;
    dozent_id?: number;
    limit?: number;
  }): Promise<ApiResponse<AuditLogEntry[]>> {
    try {
      log.debug('Fetching audit log with params:', params);

      const queryParams = new URLSearchParams();
      if (params?.modul_id) queryParams.append('modul_id', params.modul_id.toString());
      if (params?.dozent_id) queryParams.append('dozent_id', params.dozent_id.toString());
      if (params?.limit) queryParams.append('limit', params.limit.toString());

      const url = `/modul-verwaltung/audit-log${queryParams.toString() ? `?${queryParams}` : ''}`;
      log.debug('Request URL:', url);

      const response = await api.get<ApiResponse<AuditLogEntry[]>>(url);

      log.debug('Audit log entries:', response.data.data?.length || 0);
      return response.data;
    } catch (error) {
      log.error('Error fetching audit log:', error);
      throw new Error(handleApiError(error));
    }
  }
}

// Export singleton instance
export default new ModulVerwaltungService();
