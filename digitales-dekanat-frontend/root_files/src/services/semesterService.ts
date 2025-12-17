/**
 * Semester Service
 * ================
 * 
 * CRITICAL FIX: Trailing Slashes Required
 * ----------------------------------------
 * All API endpoints MUST use trailing slashes (e.g., '/semester/' not '/semester')
 * to match Flask route definitions and avoid 308 redirects that lose auth headers.
 * 
 * Problem: Flask routes defined as @route('/') expect trailing slash
 * Without it: /semester → 308 redirect → /semester/ (Authorization header lost!)
 * With it: /semester/ → 200 OK (Authorization header preserved)
 */

import api, { ApiResponse, handleApiError } from './api';
import { Semester } from '../types/semester.types';

class SemesterService {
  // Get all semesters
  async getAllSemesters(): Promise<ApiResponse<Semester[]>> {
    try {
      // CRITICAL: Use trailing slash to match Flask route and avoid 308 redirect that loses auth headers
      const response = await api.get<ApiResponse<Semester[]>>('/semester/');
      return response.data;
    } catch (error) {
      throw new Error(handleApiError(error));
    }
  }

  // Get active semester
  async getActiveSemester(): Promise<ApiResponse<Semester>> {
    try {
      const response = await api.get<ApiResponse<Semester>>('/semester/aktiv');
      return response.data;
    } catch (error) {
      throw new Error(handleApiError(error));
    }
  }

  // Get planning semester
  async getPlanningSemester(): Promise<ApiResponse<Semester>> {
    try {
      const response = await api.get<ApiResponse<Semester>>('/semester/planung');
      return response.data;
    } catch (error) {
      throw new Error(handleApiError(error));
    }
  }

  // Create semester (Dekan only)
  async createSemester(data: Partial<Semester>): Promise<ApiResponse<Semester>> {
    try {
      const response = await api.post<ApiResponse<Semester>>('/semester/', data);
      return response.data;
    } catch (error) {
      throw new Error(handleApiError(error));
    }
  }

  // Update semester
  async updateSemester(id: number, data: Partial<Semester>): Promise<ApiResponse<Semester>> {
    try {
      const response = await api.put<ApiResponse<Semester>>(`/semester/${id}`, data);
      return response.data;
    } catch (error) {
      throw new Error(handleApiError(error));
    }
  }

  // Activate semester
  async activateSemester(id: number, planungsphase: boolean = true): Promise<ApiResponse<Semester>> {
    try {
      const response = await api.post<ApiResponse<Semester>>(`/semester/${id}/aktivieren`, { planungsphase });
      return response.data;
    } catch (error) {
      throw new Error(handleApiError(error));
    }
  }

  // Control planning phase
  async controlPlanningPhase(id: number, action: 'oeffnen' | 'schliessen'): Promise<ApiResponse<Semester>> {
    try {
      const response = await api.post<ApiResponse<Semester>>(`/semester/${id}/planungsphase`, { aktion: action });
      return response.data;
    } catch (error) {
      throw new Error(handleApiError(error));
    }
  }

  // Delete semester
  async deleteSemester(id: number, force: boolean = false): Promise<ApiResponse> {
    try {
      const response = await api.delete<ApiResponse>(`/semester/${id}?force=${force}`);
      return response.data;
    } catch (error) {
      throw new Error(handleApiError(error));
    }
  }

  // Get auto semester suggestion
  async getAutoSuggestion(): Promise<ApiResponse<any>> {
    try {
      const response = await api.get<ApiResponse<any>>('/semester/auto-vorschlag');
      return response.data;
    } catch (error) {
      throw new Error(handleApiError(error));
    }
  }

  // Get all semesters (alias for compatibility)
  async getAll(): Promise<ApiResponse<Semester[]>> {
    return this.getAllSemesters();
  }
}

export default new SemesterService();