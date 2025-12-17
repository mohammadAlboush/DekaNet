import { create } from 'zustand';
import { persist } from 'zustand/middleware';
import {
  PlanungPhase,
  PhaseSubmissionStatus,
  ArchiviertePlanung,
  PhaseHistoryEntry,
  ProfessorPhaseSubmission,
  PhaseStatistik
} from '../types/planungPhase.types';
import planungPhaseService from '../services/planungPhaseService';

interface PlanungPhaseStore {
  // State
  activePhase: PlanungPhase | null;
  allPhases: PlanungPhase[];
  submissionStatus: PhaseSubmissionStatus | null;
  archivedPlanungen: ArchiviertePlanung[];
  phaseHistory: PhaseHistoryEntry[];
  currentPhaseStatistics: PhaseStatistik | null;
  phaseSubmissions: ProfessorPhaseSubmission[];
  loading: boolean;
  error: string | null;

  // Getters
  isPhaseActive: () => boolean;
  canSubmit: () => boolean;
  getTimeRemaining: () => number | null;
  hasSubmittedInCurrentPhase: () => boolean;

  // Actions - Phasenverwaltung
  fetchActivePhase: () => Promise<void>;
  startNewPhase: (name: string, semesterId: number, deadline?: string) => Promise<void>;
  closeCurrentPhase: (archiveEntwuerfe: boolean, grund?: string) => Promise<void>;
  updatePhase: (phaseId: number, updates: any) => Promise<void>;

  // Actions - Submission Management
  checkSubmissionStatus: (professorId?: number) => Promise<void>;
  recordNewSubmission: (planungId: number) => Promise<void>;
  fetchPhaseSubmissions: (phaseId: number) => Promise<void>;

  // Actions - Archiv
  fetchArchivedPlanungen: (filter?: any) => Promise<void>;
  restoreFromArchive: (archivId: number) => Promise<number>;
  exportArchive: (filter?: any) => Promise<void>;

  // Actions - Historie & Statistiken
  fetchPhaseHistory: (professorId?: number) => Promise<void>;
  fetchPhaseStatistics: (phaseId: number) => Promise<void>;
  generatePhaseReport: (phaseId: number) => Promise<void>;

  // Actions - Benachrichtigungen
  sendRemindersToProfs: (phaseId: number, professorIds?: number[]) => Promise<void>;

  // Utility
  clearError: () => void;
  resetStore: () => void;
}

const initialState = {
  activePhase: null,
  allPhases: [],
  submissionStatus: null,
  archivedPlanungen: [],
  phaseHistory: [],
  currentPhaseStatistics: null,
  phaseSubmissions: [],
  loading: false,
  error: null,
};

const usePlanungPhaseStore = create<PlanungPhaseStore>()(
  persist(
    (set, get) => ({
      ...initialState,

      // ========== Getters ==========
      isPhaseActive: () => {
        const state = get();
        return state.activePhase !== null && state.activePhase.ist_aktiv;
      },

      canSubmit: () => {
        const state = get();
        return state.submissionStatus?.kann_einreichen === true;
      },

      getTimeRemaining: () => {
        const state = get();
        if (!state.activePhase?.enddatum) return null;

        const deadline = new Date(state.activePhase.enddatum);
        const now = new Date();
        const diffMs = deadline.getTime() - now.getTime();

        return diffMs > 0 ? Math.floor(diffMs / 60000) : 0; // In Minuten
      },

      hasSubmittedInCurrentPhase: () => {
        const state = get();
        return state.submissionStatus?.letzte_einreichung !== undefined &&
               state.submissionStatus.letzte_einreichung.status === 'freigegeben';
      },

      // ========== Phasenverwaltung ==========
      fetchActivePhase: async () => {
        set({ loading: true, error: null });
        try {
          const phase = await planungPhaseService.getActivePhase();
          set({ activePhase: phase, loading: false });
        } catch (error: any) {
          set({
            error: error.response?.data?.message || 'Fehler beim Laden der aktiven Phase',
            loading: false
          });
        }
      },

      startNewPhase: async (name: string, semesterId: number, deadline?: string) => {
        set({ loading: true, error: null });
        try {
          const newPhase = await planungPhaseService.startPhase({
            name,
            semester_id: semesterId,
            startdatum: new Date().toISOString(),
            enddatum: deadline
          });

          set({
            activePhase: newPhase,
            loading: false
          });

          // Refresh all phases
          const response = await planungPhaseService.getAllPhases();
          set({ allPhases: response.phasen });

        } catch (error: any) {
          set({
            error: error.response?.data?.message || 'Fehler beim Starten der Planungsphase',
            loading: false
          });
          throw error;
        }
      },

      closeCurrentPhase: async (archiveEntwuerfe: boolean, grund?: string) => {
        const state = get();
        if (!state.activePhase) {
          set({ error: 'Keine aktive Phase zum Schließen' });
          return;
        }

        set({ loading: true, error: null });
        try {
          const result = await planungPhaseService.closePhase(state.activePhase.id, {
            archiviere_entwuerfe: archiveEntwuerfe,
            grund
          });

          set({
            activePhase: null,
            loading: false
          });

          // Refresh all phases
          const response = await planungPhaseService.getAllPhases();
          set({ allPhases: response.phasen });

          // Show success info
          console.log(`Phase geschlossen. ${result.archivierte_planungen} Planungen archiviert, ${result.geloeschte_entwuerfe} Entwürfe gelöscht.`);

        } catch (error: any) {
          set({
            error: error.response?.data?.message || 'Fehler beim Schließen der Planungsphase',
            loading: false
          });
          throw error;
        }
      },

      updatePhase: async (phaseId: number, updates: any) => {
        set({ loading: true, error: null });
        try {
          const updatedPhase = await planungPhaseService.updatePhase(phaseId, updates);

          const state = get();
          if (state.activePhase?.id === phaseId) {
            set({ activePhase: updatedPhase });
          }

          // Update in allPhases array
          set({
            allPhases: state.allPhases.map(p => p.id === phaseId ? updatedPhase : p),
            loading: false
          });

        } catch (error: any) {
          set({
            error: error.response?.data?.message || 'Fehler beim Aktualisieren der Phase',
            loading: false
          });
          throw error;
        }
      },

      // ========== Submission Management ==========
      checkSubmissionStatus: async (professorId?: number) => {
        set({ loading: true, error: null });
        try {
          const status = await planungPhaseService.checkSubmissionStatus(professorId);
          set({ submissionStatus: status, loading: false });
        } catch (error: any) {
          set({
            error: error.response?.data?.message || 'Fehler beim Prüfen des Einreichungsstatus',
            loading: false
          });
        }
      },

      recordNewSubmission: async (planungId: number) => {
        set({ loading: true, error: null });
        try {
          const submission = await planungPhaseService.recordSubmission(planungId);

          // Update submission status
          await get().checkSubmissionStatus();

          // Add to submissions list
          const state = get();
          set({
            phaseSubmissions: [...state.phaseSubmissions, submission],
            loading: false
          });

        } catch (error: any) {
          set({
            error: error.response?.data?.message || 'Fehler beim Aufzeichnen der Einreichung',
            loading: false
          });
          throw error;
        }
      },

      fetchPhaseSubmissions: async (phaseId: number) => {
        set({ loading: true, error: null });
        try {
          const submissions = await planungPhaseService.getPhaseSubmissions(phaseId);
          set({ phaseSubmissions: submissions, loading: false });
        } catch (error: any) {
          set({
            error: error.response?.data?.message || 'Fehler beim Laden der Einreichungen',
            loading: false
          });
        }
      },

      // ========== Archiv ==========
      fetchArchivedPlanungen: async (filter?: any) => {
        set({ loading: true, error: null });
        try {
          const response = await planungPhaseService.getArchivedPlanungen(filter);
          set({ archivedPlanungen: response.planungen, loading: false });
        } catch (error: any) {
          set({
            error: error.response?.data?.message || 'Fehler beim Laden der archivierten Planungen',
            loading: false
          });
        }
      },

      restoreFromArchive: async (archivId: number) => {
        set({ loading: true, error: null });
        try {
          const result = await planungPhaseService.restoreArchivedPlanung(archivId);

          // Remove from archived list
          const state = get();
          set({
            archivedPlanungen: state.archivedPlanungen.filter(a => a.id !== archivId),
            loading: false
          });

          return result.planung_id;
        } catch (error: any) {
          set({
            error: error.response?.data?.message || 'Fehler beim Wiederherstellen der Planung',
            loading: false
          });
          throw error;
        }
      },

      exportArchive: async (filter?: any) => {
        set({ loading: true, error: null });
        try {
          const blob = await planungPhaseService.exportArchiv(filter);

          // Download the file
          const url = window.URL.createObjectURL(blob);
          const a = document.createElement('a');
          a.href = url;
          a.download = `archiv_export_${new Date().toISOString().split('T')[0]}.xlsx`;
          document.body.appendChild(a);
          a.click();
          window.URL.revokeObjectURL(url);
          document.body.removeChild(a);

          set({ loading: false });
        } catch (error: any) {
          set({
            error: error.response?.data?.message || 'Fehler beim Exportieren des Archivs',
            loading: false
          });
        }
      },

      // ========== Historie & Statistiken ==========
      fetchPhaseHistory: async (professorId?: number) => {
        set({ loading: true, error: null });
        try {
          const history = await planungPhaseService.getPhaseHistory(professorId);
          set({ phaseHistory: history, loading: false });
        } catch (error: any) {
          set({
            error: error.response?.data?.message || 'Fehler beim Laden der Phasenhistorie',
            loading: false
          });
        }
      },

      fetchPhaseStatistics: async (phaseId: number) => {
        set({ loading: true, error: null });
        try {
          const statistics = await planungPhaseService.getPhaseStatistics(phaseId);
          set({ currentPhaseStatistics: statistics, loading: false });
        } catch (error: any) {
          set({
            error: error.response?.data?.message || 'Fehler beim Laden der Statistiken',
            loading: false
          });
        }
      },

      generatePhaseReport: async (phaseId: number) => {
        set({ loading: true, error: null });
        try {
          const blob = await planungPhaseService.generatePhaseReport(phaseId);

          // Download the PDF
          const url = window.URL.createObjectURL(blob);
          const a = document.createElement('a');
          a.href = url;
          a.download = `phasenbericht_${phaseId}_${new Date().toISOString().split('T')[0]}.pdf`;
          document.body.appendChild(a);
          a.click();
          window.URL.revokeObjectURL(url);
          document.body.removeChild(a);

          set({ loading: false });
        } catch (error: any) {
          set({
            error: error.response?.data?.message || 'Fehler beim Generieren des Berichts',
            loading: false
          });
        }
      },

      // ========== Benachrichtigungen ==========
      sendRemindersToProfs: async (phaseId: number, professorIds?: number[]) => {
        set({ loading: true, error: null });
        try {
          const result = await planungPhaseService.sendReminders(phaseId, professorIds);
          console.log(`${result.gesendet} Erinnerungen gesendet, ${result.fehler} Fehler`);
          set({ loading: false });
        } catch (error: any) {
          set({
            error: error.response?.data?.message || 'Fehler beim Senden der Erinnerungen',
            loading: false
          });
          throw error;
        }
      },

      // ========== Utility ==========
      clearError: () => set({ error: null }),

      resetStore: () => set(initialState),
    }),
    {
      name: 'planung-phase-storage',
      partialize: (state) => ({
        activePhase: state.activePhase,
        submissionStatus: state.submissionStatus,
      }),
    }
  )
);

export default usePlanungPhaseStore;