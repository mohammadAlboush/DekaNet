import { create } from 'zustand';
import { devtools } from 'zustand/middleware';
import auftragService from '../services/auftragService';
import { SemesterAuftrag } from '../types/auftrag.types';

/**
 * Auftrag Store - SYNCHRONISATION
 * ================================
 * Zentraler State für Semesteraufträge
 *
 * Features:
 * - Zentrale Datenhaltung
 * - Auto-Refresh nach Änderungen
 * - Event-basierte Synchronisation
 * - Wird von Dashboard UND Planung verwendet
 */

interface AuftragState {
  // State
  semesterAuftraege: Record<number, SemesterAuftrag[]>; // Key: semester_id
  isLoading: boolean;
  lastUpdate: number | null;

  // Actions
  loadAuftraege: (semesterId: number) => Promise<void>;
  addAuftrag: (semesterId: number, auftrag: SemesterAuftrag) => void;
  updateAuftrag: (semesterId: number, auftragId: number, data: Partial<SemesterAuftrag>) => void;
  removeAuftrag: (semesterId: number, auftragId: number) => void;
  clearAuftraege: (semesterId: number) => void;
  triggerRefresh: (semesterId: number) => Promise<void>;
}

const useAuftragStore = create<AuftragState>()(
  devtools(
    (set, get) => ({
      // Initial State
      semesterAuftraege: {},
      isLoading: false,
      lastUpdate: null,

      // Lade Aufträge für ein Semester
      loadAuftraege: async (semesterId: number) => {
        console.log('[AuftragStore] Loading auftraege for semester:', semesterId);
        set({ isLoading: true });

        try {
          const auftraege = await auftragService.getAuftraegeFuerSemester(semesterId);

          set((state) => ({
            semesterAuftraege: {
              ...state.semesterAuftraege,
              [semesterId]: auftraege,
            },
            isLoading: false,
            lastUpdate: Date.now(),
          }));

          console.log('[AuftragStore] ✓ Loaded', auftraege.length, 'auftraege');
        } catch (error) {
          console.error('[AuftragStore] ✗ Error loading auftraege:', error);
          set({ isLoading: false });
        }
      },

      // Füge neuen Auftrag hinzu
      addAuftrag: (semesterId: number, auftrag: SemesterAuftrag) => {
        console.log('[AuftragStore] Adding auftrag:', auftrag.id);

        set((state) => {
          const current = state.semesterAuftraege[semesterId] || [];
          return {
            semesterAuftraege: {
              ...state.semesterAuftraege,
              [semesterId]: [...current, auftrag],
            },
            lastUpdate: Date.now(),
          };
        });
      },

      // Aktualisiere existierenden Auftrag
      updateAuftrag: (semesterId: number, auftragId: number, data: Partial<SemesterAuftrag>) => {
        console.log('[AuftragStore] Updating auftrag:', auftragId, data);

        set((state) => {
          const current = state.semesterAuftraege[semesterId] || [];
          const updated = current.map((a) =>
            a.id === auftragId ? { ...a, ...data } : a
          );

          return {
            semesterAuftraege: {
              ...state.semesterAuftraege,
              [semesterId]: updated,
            },
            lastUpdate: Date.now(),
          };
        });
      },

      // Entferne Auftrag
      removeAuftrag: (semesterId: number, auftragId: number) => {
        console.log('[AuftragStore] Removing auftrag:', auftragId);

        set((state) => {
          const current = state.semesterAuftraege[semesterId] || [];
          const filtered = current.filter((a) => a.id !== auftragId);

          return {
            semesterAuftraege: {
              ...state.semesterAuftraege,
              [semesterId]: filtered,
            },
            lastUpdate: Date.now(),
          };
        });
      },

      // Lösche alle Aufträge für ein Semester
      clearAuftraege: (semesterId: number) => {
        console.log('[AuftragStore] Clearing auftraege for semester:', semesterId);

        set((state) => {
          const updated = { ...state.semesterAuftraege };
          delete updated[semesterId];

          return {
            semesterAuftraege: updated,
            lastUpdate: Date.now(),
          };
        });
      },

      // Trigger manuellen Refresh (nach Änderungen)
      triggerRefresh: async (semesterId: number) => {
        console.log('[AuftragStore] ⟳ Triggering refresh for semester:', semesterId);
        await get().loadAuftraege(semesterId);
      },
    }),
    { name: 'AuftragStore' }
  )
);

export default useAuftragStore;
