// Mock Service for Testing - Replace with real API calls when backend is ready
import {
  PlanungPhase,
  PhaseSubmissionStatus,
  ArchiviertePlanung,
  PhaseHistoryEntry,
  ProfessorPhaseSubmission,
  PhaseStatistik
} from '../types/planungPhase.types';

// Mock-specific interfaces
interface StartPhaseData {
  semester_id: number;
  name: string;
  startdatum: string;
  enddatum?: string;
}

interface ClosePhaseData {
  grund?: string;
}

interface ClosePhaseResult {
  phase: PlanungPhase | undefined;
  archivierte_planungen: number;
  geloeschte_entwuerfe: number;
}

interface AllPhasesResult {
  phasen: PlanungPhase[];
  total: number;
  aktive_phase: PlanungPhase | null;
}

interface ArchivFilter {
  semester_id?: number;
  status?: string;
  page?: number;
  per_page?: number;
}

interface ArchivedPlanungenResult {
  planungen: ArchiviertePlanung[];
  total: number;
  pages: number;
}

interface ReminderResult {
  gesendet: number;
  fehler: number;
}

interface RestoreResult {
  success: boolean;
  planung_id: number;
}

interface PhaseDashboard {
  phase: PlanungPhase | null;
  einreichungen_heute: number;
  offene_reviews: number;
  durchschnittliche_bearbeitungszeit: number;
  deadline_warnung: boolean;
  professoren_ohne_einreichung: number[];
}

interface NotificationSettings {
  deadline_reminder_days: number;
  auto_close_after_deadline: boolean;
  send_submission_confirmation: boolean;
}

class MockPlanungPhaseService {
  private activePhase: PlanungPhase | null = null;
  private phases: PlanungPhase[] = [];
  private nextId = 1;

  // Mock active phase
  async getActivePhase(): Promise<PlanungPhase | null> {
    return this.activePhase;
  }

  // Mock start phase
  async startPhase(data: StartPhaseData): Promise<PlanungPhase> {
    const newPhase: PlanungPhase = {
      id: this.nextId++,
      semester_id: data.semester_id,
      name: data.name,
      startdatum: data.startdatum,
      enddatum: data.enddatum,
      ist_aktiv: true,
      anzahl_einreichungen: 0,
      anzahl_genehmigt: 0,
      anzahl_abgelehnt: 0,
      created_at: new Date().toISOString(),
      updated_at: new Date().toISOString(),
    };

    this.activePhase = newPhase;
    this.phases.push(newPhase);
    console.log('[MockPhaseService] Phase started:', newPhase);
    return newPhase;
  }

  // Mock close phase
  async closePhase(phaseId: number, _data: ClosePhaseData): Promise<ClosePhaseResult> {
    const phase = this.phases.find(p => p.id === phaseId);
    if (phase) {
      phase.ist_aktiv = false;
      phase.geschlossen_am = new Date().toISOString();
      this.activePhase = null;
    }

    return {
      phase: phase,
      archivierte_planungen: 0,
      geloeschte_entwuerfe: 0
    };
  }

  // Mock submission status
  async checkSubmissionStatus(_professorId?: number): Promise<PhaseSubmissionStatus> {
    if (!this.activePhase) {
      return {
        kann_einreichen: false,
        grund: 'keine_aktive_phase'
      };
    }

    return {
      kann_einreichen: true,
      aktive_phase: this.activePhase
    };
  }

  // Mock get all phases
  async getAllPhases(_semesterId?: number): Promise<AllPhasesResult> {
    return {
      phasen: this.phases,
      total: this.phases.length,
      aktive_phase: this.activePhase
    };
  }

  // Mock phase statistics
  async getPhaseStatistics(phaseId: number): Promise<PhaseStatistik> {
    return {
      phase_id: phaseId,
      phase_name: 'Test Phase',
      startdatum: new Date().toISOString(),
      dauer_tage: 30,
      professoren_gesamt: 10,
      professoren_eingereicht: 5,
      einreichungsquote: 50,
      genehmigungsquote: 80,
      durchschnittliche_bearbeitungszeit: 24,
      top_module: [
        { modul_name: 'Datenbanken', anzahl: 5 },
        { modul_name: 'Programmierung', anzahl: 4 }
      ]
    };
  }

  // Mock phase history
  async getPhaseHistory(_professorId?: number): Promise<PhaseHistoryEntry[]> {
    return [];
  }

  // Mock archived planungen
  async getArchivedPlanungen(_filter?: ArchivFilter): Promise<ArchivedPlanungenResult> {
    return {
      planungen: [],
      total: 0,
      pages: 0
    };
  }

  // Stub for other methods
  async updatePhase(phaseId: number, data: Partial<PlanungPhase>): Promise<PlanungPhase> {
    const phase = this.phases.find(p => p.id === phaseId);
    if (phase) {
      Object.assign(phase, data);
      return phase;
    }
    throw new Error('Phase not found');
  }

  async getPhaseSubmissions(_phaseId: number): Promise<ProfessorPhaseSubmission[]> {
    return [];
  }

  async recordSubmission(planungId: number): Promise<ProfessorPhaseSubmission> {
    return {
      professor_id: 1,
      planungphase_id: this.activePhase?.id || 1,
      planung_id: planungId,
      eingereicht_am: new Date().toISOString(),
      status: 'eingereicht'
    };
  }

  async sendReminders(_phaseId: number, _professorIds?: number[]): Promise<ReminderResult> {
    return { gesendet: 0, fehler: 0 };
  }

  async getArchivedPlanungDetail(_archivId: number): Promise<ArchiviertePlanung> {
    throw new Error('Not implemented');
  }

  async restoreArchivedPlanung(_archivId: number): Promise<RestoreResult> {
    return { success: false, planung_id: 0 };
  }

  async exportArchiv(_filter?: ArchivFilter): Promise<Blob> {
    return new Blob(['Mock Excel Data']);
  }

  async generatePhaseReport(_phaseId: number): Promise<Blob> {
    return new Blob(['Mock PDF Report']);
  }

  async getPhaseDashboard(): Promise<PhaseDashboard> {
    return {
      phase: this.activePhase,
      einreichungen_heute: 0,
      offene_reviews: 0,
      durchschnittliche_bearbeitungszeit: 0,
      deadline_warnung: false,
      professoren_ohne_einreichung: []
    };
  }

  async getNotificationSettings(): Promise<NotificationSettings> {
    return {
      deadline_reminder_days: 3,
      auto_close_after_deadline: false,
      send_submission_confirmation: true
    };
  }

  async updateNotificationSettings(settings: NotificationSettings): Promise<void> {
    console.log('[MockPhaseService] Notification settings updated:', settings);
  }
}

export default new MockPlanungPhaseService();