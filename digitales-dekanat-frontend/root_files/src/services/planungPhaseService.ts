import api from './api';
import mockService from './mockPlanungPhaseService';
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
  ProfessorPhaseSubmission
} from '../types/planungPhase.types';

// Set to true to use mock service (until backend is ready)
const USE_MOCK = false;

class PlanungPhaseService {
  // ========== Phasenverwaltung (Dekan) ==========

  /**
   * Startet eine neue Planungsphase
   */
  async startPhase(data: CreatePlanungPhaseDto): Promise<PlanungPhase> {
    if (USE_MOCK) {
      return mockService.startPhase(data);
    }
    const response = await api.post('/planungphase/start', data);
    return response.data;
  }

  /**
   * Schließt die aktive Planungsphase
   */
  async closePhase(phaseId: number, data: ClosePlanungPhaseDto): Promise<{
    phase: PlanungPhase;
    archivierte_planungen: number;
    geloeschte_entwuerfe: number;
  }> {
    if (USE_MOCK) {
      return mockService.closePhase(phaseId, data);
    }
    const response = await api.post(`/planungphase/${phaseId}/close`, data);
    return response.data;
  }

  /**
   * Holt alle Planungsphasen (aktuelle und historische)
   */
  async getAllPhases(semesterId?: number): Promise<PlanungPhaseListResponse> {
    if (USE_MOCK) {
      return mockService.getAllPhases(semesterId);
    }
    const params = semesterId ? { semester_id: semesterId } : {};
    const response = await api.get('/planungphase', { params });
    return response.data;
  }

  /**
   * Holt die aktive Planungsphase
   */
  async getActivePhase(): Promise<PlanungPhase | null> {
    if (USE_MOCK) {
      return mockService.getActivePhase();
    }
    const response = await api.get('/planungphase/active');
    return response.data.phase || null;
  }

  /**
   * Aktualisiert eine Planungsphase (z.B. Name oder Deadline ändern)
   */
  async updatePhase(phaseId: number, data: Partial<CreatePlanungPhaseDto>): Promise<PlanungPhase> {
    if (USE_MOCK) {
      return mockService.updatePhase(phaseId, data);
    }
    const response = await api.put(`/planungphase/${phaseId}`, data);
    return response.data;
  }

  // ========== Submission Tracking ==========

  /**
   * Prüft ob ein Professor in der aktuellen Phase einreichen kann
   */
  async checkSubmissionStatus(professorId?: number): Promise<PhaseSubmissionStatus> {
    if (USE_MOCK) {
      return mockService.checkSubmissionStatus(professorId);
    }
    const params = professorId ? { professor_id: professorId } : {};
    const response = await api.get('/planungphase/submission-status', { params });
    return response.data;
  }

  /**
   * Holt alle Einreichungen einer Phase
   */
  async getPhaseSubmissions(phaseId: number): Promise<ProfessorPhaseSubmission[]> {
    if (USE_MOCK) {
      return mockService.getPhaseSubmissions(phaseId);
    }
    const response = await api.get(`/planungphase/${phaseId}/submissions`);
    return response.data || [];
  }

  /**
   * Markiert eine Planung als eingereicht in der aktuellen Phase
   */
  async recordSubmission(planungId: number): Promise<ProfessorPhaseSubmission> {
    if (USE_MOCK) {
      return mockService.recordSubmission(planungId);
    }
    const response = await api.post('/planungphase/record-submission', { planung_id: planungId });
    return response.data;
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
    if (USE_MOCK) {
      return mockService.getArchivedPlanungen(filter);
    }
    const response = await api.get('/archiv/planungen', { params: filter });
    return response.data;
  }

  /**
   * Holt Details einer archivierten Planung
   */
  async getArchivedPlanungDetail(archivId: number): Promise<ArchiviertePlanung> {
    if (USE_MOCK) {
      return mockService.getArchivedPlanungDetail(archivId);
    }
    const response = await api.get(`/archiv/planungen/${archivId}`);
    return response.data;
  }

  /**
   * Exportiert archivierte Planungen als Excel
   */
  async exportArchiv(filter?: ArchivFilter): Promise<Blob> {
    const response = await api.get('/archiv/export', {
      params: filter,
      responseType: 'blob'
    });
    return response.data;
  }

  /**
   * Stellt eine archivierte Planung wieder her (nur Dekan)
   */
  async restoreArchivedPlanung(archivId: number): Promise<{
    success: boolean;
    planung_id: number;
  }> {
    const response = await api.post(`/archiv/planungen/${archivId}/restore`);
    return response.data;
  }

  // ========== Statistiken ==========

  /**
   * Holt Statistiken für eine Planungsphase
   */
  async getPhaseStatistics(phaseId: number): Promise<PhaseStatistik> {
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
  }

  /**
   * Holt die Historie aller Phasen mit Statistiken
   */
  async getPhaseHistory(professorId?: number): Promise<PhaseHistoryEntry[]> {
    if (USE_MOCK) {
      return mockService.getPhaseHistory(professorId);
    }
    const params = professorId ? { professor_id: professorId } : {};
    const response = await api.get('/planungphase/history', { params });
    return response.data.history || [];
  }

  /**
   * Generiert einen Phasenbericht als PDF
   */
  async generatePhaseReport(phaseId: number): Promise<Blob> {
    const response = await api.get(`/planungphase/${phaseId}/report`, {
      responseType: 'blob'
    });
    return response.data;
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
    const response = await api.get('/planungphase/dashboard');
    return response.data;
  }

  // ========== Benachrichtigungen ==========

  /**
   * Sendet Erinnerungen an Professoren ohne Einreichung
   */
  async sendReminders(phaseId: number, professorIds?: number[]): Promise<{
    gesendet: number;
    fehler: number;
  }> {
    const response = await api.post(`/planungphase/${phaseId}/reminders`, {
      professor_ids: professorIds
    });
    return response.data;
  }

  /**
   * Holt Benachrichtigungseinstellungen
   */
  async getNotificationSettings(): Promise<{
    deadline_reminder_days: number;
    auto_close_after_deadline: boolean;
    send_submission_confirmation: boolean;
  }> {
    const response = await api.get('/planungphase/notification-settings');
    return response.data;
  }

  /**
   * Aktualisiert Benachrichtigungseinstellungen
   */
  async updateNotificationSettings(settings: any): Promise<void> {
    await api.put('/planungphase/notification-settings', settings);
  }
}

export default new PlanungPhaseService();