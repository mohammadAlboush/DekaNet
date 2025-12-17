/**
 * Prüfungsordnungen Service
 * =========================
 */

import api, { ApiResponse, handleApiError } from './api';

export interface Pruefungsordnung {
  id: number;
  po_jahr: string;
  gueltig_von: string;
  gueltig_bis: string | null;
  beschreibung: string | null;
}

class POService {
  // Get all POs
  async getAll(): Promise<ApiResponse<Pruefungsordnung[]>> {
    try {
      const response = await api.get<ApiResponse<Pruefungsordnung[]>>('/pruefungsordnungen/');
      return response.data;
    } catch (error) {
      throw new Error(handleApiError(error));
    }
  }

  // Get PO by ID
  async getById(id: number): Promise<ApiResponse<Pruefungsordnung>> {
    try {
      const response = await api.get<ApiResponse<Pruefungsordnung>>(`/pruefungsordnungen/${id}`);
      return response.data;
    } catch (error) {
      throw new Error(handleApiError(error));
    }
  }

  // Get modules for PO
  async getModules(id: number, turnus?: string): Promise<ApiResponse<any[]>> {
    try {
      const params = turnus ? { turnus } : {};
      const response = await api.get<ApiResponse<any[]>>(`/pruefungsordnungen/${id}/module`, { params });
      return response.data;
    } catch (error) {
      throw new Error(handleApiError(error));
    }
  }
}

export default new POService();
