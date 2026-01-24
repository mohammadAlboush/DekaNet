import api, { handleApiError } from './api';
import mockService from './mockPlanungPhaseService';
import { createContextLogger } from '../utils/logger';
import {
  PlanungPhase,
  CreatePlanungPhaseDto,
  ClosePlanungPhaseDto,
  PlanungPhaseListResponse,
  PhaseSubmissionStatus,
  ArchiviertePlanung,
  ArchivFilter,
  PhaseStatistik,
  PhaseHistoryEntry,
  ProfessorPhaseSubmission,
  ActivePhaseWithSemesterResponse
} from '../types/planungPhase.types';
import { Semester } from '../types/semester.types';

// Set to true to use mock service (until backend is ready)
const USE_MOCK = false;

const log = createContextLogger('PlanungPhaseService');

// ✅ TYPESAFE: Konkrete Typen für Notification Settings
export interface NotificationSettings {
  erinnerung_aktiviert?: boolean;
  erinnerung_tage_vorher?: number;
  email_bei_einreichung?: boolean;
  email_bei_genehmigung?: boolean;
}

class PlanungPhaseService {
  // ========== Phasenverwaltung (Dekan) ==========

  /**
   * Startet eine neue Planungsphase mit strukturierter Semester-Auswahl
   * @param data - semester_typ, semester_jahr, startdatum, enddatum (Pflicht)
   * @returns Phase und automatisch erstelltes/gefundenes Semester
   */
  async startPhase(data: CreatePlanungPhaseDto): Promise<{ success: boolean; phase: PlanungPhase; semester: Semester }> {
    try {
      if (USE_MOCK) {
        // Mock returns just PlanungPhase, wrap it for compatibility
        const phase = await mockService.startPhase(data);
        return {
          success: true,
          phase,
          semester: { id: 1, bezeichnung: 'Mock Semester' } as Semester
        };
      }
      const response = await api.post('/planungphase/start', data);
      return response.data;
    } catch (error: unknown) {
      log.error('Error starting phase', error instanceof Error ? error : undefined);
      throw new Error(handleApiError(error));
    }
  }

  /**
   * Schließt die aktive Planungsphase
   */
  async closePhase(phaseId: number, data: ClosePlanungPhaseDto): Promise<{
    phase: PlanungPhase;
    archivierte_planungen: number;
    geloeschte_entwuerfe: number;
  }> {
    try {
      if (USE_MOCK) {
        return mockService.closePhase(phaseId, data);
      }
      const response = await api.post(`/planungphase/${phaseId}/close`, data);
      return response.data;
    } catch (error: unknown) {
      log.error('Error closing phase', error instanceof Error ? error : undefined);
      throw new Error(handleApiError(error));
    }
  }

  /**
   * Holt alle Planungsphasen (aktuelle und historische)
   */
  async getAllPhases(semesterId?: number): Promise<PlanungPhaseListResponse> {
    try {
      if (USE_MOCK) {
        return mockService.getAllPhases(semesterId);
      }
      const params = semesterId ? { semester_id: semesterId } : {};
      const response = await api.get('/planungphase', { params });
      return response.data;
    } catch (error: unknown) {
      log.error('Error getting all phases', error instanceof Error ? error : undefined);
      throw new Error(handleApiError(error));
    }
  }

  /**
   * Holt die aktive Planungsphase
   */
  async getActivePhase(): Promise<PlanungPhase | null> {
    try {
      if (USE_MOCK) {
        return mockService.getActivePhase();
      }
      const response = await api.get('/planungphase/active');
      return response.data.phase || null;
    } catch (error: unknown) {
      log.error('Error getting active phase', error instanceof Error ? error : undefined);
      throw new Error(handleApiError(error));
    }
  }

  /**
   * NEU: Holt aktive Phase MIT Semester-Daten (für Professor-Wizard)
   * @returns Phase und zugehöriges Semester oder null wenn keine aktive Phase
   */
  async getActivePhasWithSemester(): Promise<ActivePhaseWithSemesterResponse> {
    try {
      if (USE_MOCK) {
        // Mock fallback
        return { success: true, phase: null, semester: null };
      }
      const response = await api.get('/planungphase/active-with-semester');
      return response.data;
    } catch (error: unknown) {
      log.error('Error getting active phase with semester', error instanceof Error ? error : undefined);
      throw new Error(handleApiError(error));
    }
  }

  /**
   * Aktualisiert eine Planungsphase (z.B. Name oder Deadline ändern)
   */
  async updatePhase(phaseId: number, data: Partial<CreatePlanungPhaseDto>): Promise<PlanungPhase> {
    try {
      if (USE_MOCK) {
        return mockService.updatePhase(phaseId, data);
      }
      const response = await api.put(`/planungphase/${phaseId}`, data);
      return response.data;
    } catch (error: unknown) {
      log.error('Error updating phase', error instanceof Error ? error : undefined);
      throw new Error(handleApiError(error));
    }
  }

  // ========== Submission Tracking ==========

  /**
   * Prüft ob ein Professor in der aktuellen Phase einreichen kann
   */
  async checkSubmissionStatus(professorId?: number): Promise<PhaseSubmissionStatus> {
    try {
      if (USE_MOCK) {
        return mockService.checkSubmissionStatus(professorId);
      }
      const params = professorId ? { professor_id: professorId } : {};
      const response = await api.get('/planungphase/submission-status', { params });
      return response.data;
    } catch (error: unknown) {
      log.error('Error checking submission status', error instanceof Error ? error : undefined);
      throw new Error(handleApiError(error));
    }
  }

  /**
   * Holt alle Einreichungen einer Phase
   */
  async getPhaseSubmissions(phaseId: number): Promise<ProfessorPhaseSubmission[]> {
    try {
      if (USE_MOCK) {
        return mockService.getPhaseSubmissions(phaseId);
      }
      const response = await api.get(`/planungphase/${phaseId}/submissions`);
      // Handle both array format and wrapped format
      return response.data?.data || response.data || [];
    } catch (error: unknown) {
      log.error('Error getting phase submissions', error instanceof Error ? error : undefined);
      throw new Error(handleApiError(error));
    }
  }

  /**
   * Markiert eine Planung als eingereicht in der aktuellen Phase
   */
  async recordSubmission(planungId: number): Promise<ProfessorPhaseSubmission> {
    try {
      if (USE_MOCK) {
        return mockService.recordSubmission(planungId);
      }
      const response = await api.post('/planungphase/record-submission', { planung_id: planungId });
      return response.data;
    } catch (error: unknown) {
      log.error('Error recording submission', error instanceof Error ? error : undefined);
      throw new Error(handleApiError(error));
    }
  }

  // ========== Archiv ==========

  /**
   * Holt archivierte Planungen basierend auf Filtern
   */
  async getArchivedPlanungen(filter?: ArchivFilter): Promise<{
    planungen: ArchiviertePlanung[];
    total: number;
    pages: number;
  }> {
    try {
      if (USE_MOCK) {
        return mockService.getArchivedPlanungen(filter);
      }
      const response = await api.get('/archiv/planungen', { params: filter });
      return response.data;
    } catch (error: unknown) {
      log.error('Error getting archived planungen', error instanceof Error ? error : undefined);
      throw new Error(handleApiError(error));
    }
  }

  /**
   * Holt Details einer archivierten Planung
   */
  async getArchivedPlanungDetail(archivId: number): Promise<ArchiviertePlanung> {
    try {
      if (USE_MOCK) {
        return mockService.getArchivedPlanungDetail(archivId);
      }
      const response = await api.get(`/archiv/planungen/${archivId}`);
      return response.data;
    } catch (error: unknown) {
      log.error('Error getting archived planung detail', error instanceof Error ? error : undefined);
      throw new Error(handleApiError(error));
    }
  }

  /**
   * Exportiert archivierte Planungen als Excel
   */
  async exportArchiv(filter?: ArchivFilter): Promise<Blob> {
    try {
      const response = await api.get('/archiv/export', {
        params: filter,
        responseType: 'blob'
      });
      return response.data;
    } catch (error: unknown) {
      log.error('Error exporting archive', error instanceof Error ? error : undefined);
      throw new Error(handleApiError(error));
    }
  }

  /**
   * Stellt eine archivierte Planung wieder her (nur Dekan)
   */
  async restoreArchivedPlanung(archivId: number): Promise<{
    success: boolean;
    planung_id: number;
  }> {
    try {
      const response = await api.post(`/archiv/planungen/${archivId}/restore`);
      return response.data;
    } catch (error: unknown) {
      log.error('Error restoring archived planung', error instanceof Error ? error : undefined);
      throw new Error(handleApiError(error));
    }
  }

  // ========== Statistiken ==========

  /**
   * Holt Statistiken für eine Planungsphase
   */
  async getPhaseStatistics(phaseId: number): Promise<PhaseStatistik> {
    try {
      if (USE_MOCK) {
        return mockService.getPhaseStatistics(phaseId);
      }
      const response = await api.get(`/planungphase/${phaseId}/statistics`);
      return response.data || {
        professoren_gesamt: 0,
        professoren_eingereicht: 0,
        einreichungsquote: 0,
        genehmigungsquote: 0,
        durchschnittliche_bearbeitungszeit: 0,
        top_module: []
      };
    } catch (error: unknown) {
      log.error('Error getting phase statistics', error instanceof Error ? error : undefined);
      throw new Error(handleApiError(error));
    }
  }

  /**
   * Holt die Historie aller Phasen mit Statistiken
   */
  async getPhaseHistory(professorId?: number): Promise<PhaseHistoryEntry[]> {
    try {
      if (USE_MOCK) {
        return mockService.getPhaseHistory(professorId);
      }
      const params = professorId ? { professor_id: professorId } : {};
      const response = await api.get('/planungphase/history', { params });
      return response.data.history || [];
    } catch (error: unknown) {
      log.error('Error getting phase history', error instanceof Error ? error : undefined);
      throw new Error(handleApiError(error));
    }
  }

  /**
   * Generiert einen Phasenbericht als PDF
   */
  async generatePhaseReport(phaseId: number): Promise<Blob> {
    try {
      const response = await api.get(`/planungphase/${phaseId}/report`, {
        responseType: 'blob'
      });
      return response.data;
    } catch (error: unknown) {
      log.error('Error generating phase report', error instanceof Error ? error : undefined);
      throw new Error(handleApiError(error));
    }
  }

  // ========== Dashboard Daten ==========

  /**
   * Holt Dashboard-Daten für die aktuelle Phase
   */
  async getPhaseDashboard(): Promise<{
    phase: PlanungPhase | null;
    einreichungen_heute: number;
    offene_reviews: number;
    durchschnittliche_bearbeitungszeit: number;
    deadline_warnung: boolean;
    professoren_ohne_einreichung: Array<{
      id: number;
      name: string;
      email: string;
    }>;
  }> {
    try {
      const response = await api.get('/planungphase/dashboard');
      return response.data;
    } catch (error: unknown) {
      log.error('Error getting phase dashboard', error instanceof Error ? error : undefined);
      throw new Error(handleApiError(error));
    }
  }

  // ========== Benachrichtigungen ==========

  /**
   * Sendet Erinnerungen an Professoren ohne Einreichung
   */
  async sendReminders(phaseId: number, professorIds?: number[]): Promise<{
    gesendet: number;
    fehler: number;
  }> {
    try {
      const response = await api.post(`/planungphase/${phaseId}/reminders`, {
        professor_ids: professorIds
      });
      return response.data;
    } catch (error: unknown) {
      log.error('Error sending reminders', error instanceof Error ? error : undefined);
      throw new Error(handleApiError(error));
    }
  }

  /**
   * Holt Benachrichtigungseinstellungen
   */
  async getNotificationSettings(): Promise<{
    deadline_reminder_days: number;
    auto_close_after_deadline: boolean;
    send_submission_confirmation: boolean;
  }> {
    try {
      const response = await api.get('/planungphase/notification-settings');
      return response.data;
    } catch (error: unknown) {
      log.error('Error getting notification settings', error instanceof Error ? error : undefined);
      throw new Error(handleApiError(error));
    }
  }

  /**
   * Aktualisiert Benachrichtigungseinstellungen
   */
  async updateNotificationSettings(settings: NotificationSettings): Promise<void> {
    try {
      await api.put('/planungphase/notification-settings', settings);
    } catch (error: unknown) {
      log.error('Error updating notification settings', error instanceof Error ? error : undefined);
      throw new Error(handleApiError(error));
    }
  }
}

export default new PlanungPhaseService();