import { create } from 'zustand';
import { devtools } from 'zustand/middleware';
import { Semester } from '../types/semester.types';
import { Modul } from '../types/modul.types';
import { GeplantesModul, WunschFreierTag } from '../types/planung.types';
import useAuthStore from './authStore';

/**
 * Planung Store - State Management für Wizard mit LocalStorage Backup
 * ====================================================================
 * 
 * FEATURES:
 * - Auto-Save zu LocalStorage bei jedem Update
 * - Kein Datenverlust bei Browser-Crash
 * - Restore bei Wizard-Neustart
 * - Optimistic UI Updates
 * 
 * OPTION C: Auto-Save + LocalStorage Backup
 */

export interface WizardData {
  // Step 1: Semester
  semesterId: number | null;
  semester: Semester | null;
  
  // Step 2: Module Auswahl
  selectedModules: Modul[];
  
  // Step 3: Geplante Module (mit Details)
  geplantModule: GeplantesModul[];
  
  // Step 4: Mitarbeiter Zuordnung
  mitarbeiterZuordnung: Map<number, number[]>;
  
  // Step 5: Multiplikatoren (bereits in geplantModule enthalten)
  
  // Step 6: Zusatzinfos
  anmerkungen: string;
  raumbedarf: string;
  
  // Step 7: Wunsch-freie Tage
  wunschFreieTage: WunschFreierTag[];
  
  // Step 8: Zusammenfassung (keine neuen Daten)
  
  // Meta
  planungId: number | null;
  currentStep: number;
  isLoading: boolean;
  error: string | null;
  
  // Auto-Save Tracking
  lastSaved: Date | null;
  isDirty: boolean; // Hat unsaved changes
}

interface PlanungState extends WizardData {
  // Actions
  setWizardData: (data: Partial<WizardData>) => void;
  setSemester: (semester: Semester) => void;
  setSelectedModules: (modules: Modul[]) => void;
  addSelectedModule: (module: Modul) => void;
  removeSelectedModule: (moduleId: number) => void;
  setGeplantModule: (modules: GeplantesModul[]) => void;
  addGeplantesModul: (modul: GeplantesModul) => void;
  updateGeplantesModul: (modul: GeplantesModul) => void;
  removeGeplantesModul: (modulId: number) => void;
  setMitarbeiterZuordnung: (zuordnung: Map<number, number[]>) => void;
  setAnmerkungen: (text: string) => void;
  setRaumbedarf: (text: string) => void;
  addWunschTag: (tag: WunschFreierTag) => void;
  removeWunschTag: (tagId: number) => void;
  setPlanungId: (id: number) => void;
  setCurrentStep: (step: number) => void;
  nextStep: () => void;
  previousStep: () => void;
  setLoading: (loading: boolean) => void;
  setError: (error: string | null) => void;
  
  // LocalStorage Management
  saveToLocalStorage: () => void;
  loadFromLocalStorage: () => boolean;
  clearLocalStorage: () => void;
  markAsSaved: () => void;
  markAsDirty: () => void;
  
  // Reset
  resetWizard: () => void;
  
  // Computed
  getTotalSWS: () => number;
  isStepValid: (step: number) => boolean;
}

/**
 * Helper: Erstelle user-spezifischen LocalStorage Key
 * Dies verhindert, dass Daten zwischen Benutzern vermischt werden
 */
const getLocalStorageKey = (): string => {
  const user = useAuthStore.getState().user;
  if (!user || !user.id) {
    console.warn('[PlanungStore] ⚠ No user logged in, using fallback key');
    return 'planung_wizard_backup_anonymous';
  }
  return `planung_wizard_backup_user_${user.id}`;
};

const initialState: WizardData = {
  semesterId: null,
  semester: null,
  selectedModules: [],
  geplantModule: [],
  mitarbeiterZuordnung: new Map(),
  anmerkungen: '',
  raumbedarf: '',
  wunschFreieTage: [],
  planungId: null,
  currentStep: 0,
  isLoading: false,
  error: null,
  lastSaved: null,
  isDirty: false,
};

const usePlanungStore = create<PlanungState>()(
  devtools(
    (set, get) => ({
      ...initialState,

      // =====================================================================
      // WIZARD DATA MANAGEMENT
      // =====================================================================

      setWizardData: (data) => {
        console.log('[PlanungStore] 💾 Updating wizard data:', Object.keys(data));
        set((state) => {
          const newState = { ...state, ...data, isDirty: true };
          // Auto-Save to LocalStorage
          setTimeout(() => get().saveToLocalStorage(), 100);
          return newState;
        });
      },

      // Step 1: Semester
      setSemester: (semester) => {
        console.log('[PlanungStore] 📅 Setting semester:', semester.bezeichnung);
        set({ 
          semester, 
          semesterId: semester.id,
          isDirty: true 
        });
        setTimeout(() => get().saveToLocalStorage(), 100);
      },

      // Step 2: Module Selection
      setSelectedModules: (modules) => {
        console.log('[PlanungStore] 📚 Setting selected modules:', modules.length);
        set({ selectedModules: modules, isDirty: true });
        setTimeout(() => get().saveToLocalStorage(), 100);
      },

      addSelectedModule: (module) => {
        console.log('[PlanungStore] ➕ Adding module:', module.kuerzel);
        set((state) => ({
          selectedModules: [...state.selectedModules, module],
          isDirty: true
        }));
        setTimeout(() => get().saveToLocalStorage(), 100);
      },

      removeSelectedModule: (moduleId) => {
        console.log('[PlanungStore] ➖ Removing module:', moduleId);
        set((state) => ({
          selectedModules: state.selectedModules.filter((m) => m.id !== moduleId),
          isDirty: true
        }));
        setTimeout(() => get().saveToLocalStorage(), 100);
      },

      // Step 3: Geplante Module
      setGeplantModule: (modules) => {
        console.log('[PlanungStore] 📋 Setting geplant module:', modules.length);
        set({ geplantModule: modules, isDirty: true });
        setTimeout(() => get().saveToLocalStorage(), 100);
      },

      addGeplantesModul: (modul) => {
        console.log('[PlanungStore] ➕ Adding geplantes modul:', modul.modul_id);
        set((state) => ({
          geplantModule: [...state.geplantModule, modul],
          isDirty: true
        }));
        setTimeout(() => get().saveToLocalStorage(), 100);
      },

      updateGeplantesModul: (modul) => {
        console.log('[PlanungStore] ✏️ Updating geplantes modul:', modul.id);
        set((state) => ({
          geplantModule: state.geplantModule.map((m) =>
            m.id === modul.id ? modul : m
          ),
          isDirty: true
        }));
        setTimeout(() => get().saveToLocalStorage(), 100);
      },

      removeGeplantesModul: (modulId) => {
        console.log('[PlanungStore] 🗑️ Removing geplantes modul:', modulId);
        set((state) => ({
          geplantModule: state.geplantModule.filter((m) => m.modul_id !== modulId),
          isDirty: true
        }));
        setTimeout(() => get().saveToLocalStorage(), 100);
      },

      // Step 4: Mitarbeiter
      setMitarbeiterZuordnung: (zuordnung) => {
        console.log('[PlanungStore] 👥 Setting mitarbeiter zuordnung');
        set({ mitarbeiterZuordnung: zuordnung, isDirty: true });
        setTimeout(() => get().saveToLocalStorage(), 100);
      },

      // Step 6: Zusatzinfos
      setAnmerkungen: (text) => {
        set({ anmerkungen: text, isDirty: true });
        setTimeout(() => get().saveToLocalStorage(), 100);
      },

      setRaumbedarf: (text) => {
        set({ raumbedarf: text, isDirty: true });
        setTimeout(() => get().saveToLocalStorage(), 100);
      },

      // Step 7: Wunsch-freie Tage
      addWunschTag: (tag) => {
        console.log('[PlanungStore] 📆 Adding wunsch tag');
        set((state) => ({
          wunschFreieTage: [...state.wunschFreieTage, tag],
          isDirty: true
        }));
        setTimeout(() => get().saveToLocalStorage(), 100);
      },

      removeWunschTag: (tagId) => {
        console.log('[PlanungStore] 🗑️ Removing wunsch tag:', tagId);
        set((state) => ({
          wunschFreieTage: state.wunschFreieTage.filter((t) => t.id !== tagId),
          isDirty: true
        }));
        setTimeout(() => get().saveToLocalStorage(), 100);
      },

      // Meta actions
      setPlanungId: (id) => {
        console.log('[PlanungStore] 🆔 Setting planung ID:', id);
        set({ planungId: id });
      },

      setCurrentStep: (step) => {
        console.log('[PlanungStore] 📍 Setting current step:', step);
        set({ currentStep: step });
      },

      nextStep: () => {
        set((state) => ({ currentStep: state.currentStep + 1 }));
      },

      previousStep: () => {
        set((state) => ({ currentStep: Math.max(0, state.currentStep - 1) }));
      },

      setLoading: (loading) => {
        set({ isLoading: loading });
      },

      setError: (error) => {
        console.error('[PlanungStore] ❌ Error:', error);
        set({ error });
      },

      // =====================================================================
      // LOCALSTORAGE MANAGEMENT - AUTO-SAVE BACKUP
      // =====================================================================

      saveToLocalStorage: () => {
        try {
          const state = get();

          // Nur speichern wenn es was zu speichern gibt
          if (!state.isDirty) {
            return;
          }

          const user = useAuthStore.getState().user;
          if (!user || !user.id) {
            console.warn('[PlanungStore] ⚠ Cannot save - no user logged in');
            return;
          }

          const dataToSave = {
            userId: user.id, // ✅ Speichere User ID als Validierung
            semesterId: state.semesterId,
            semester: state.semester,
            selectedModules: state.selectedModules,
            geplantModule: state.geplantModule,
            mitarbeiterZuordnung: Array.from(state.mitarbeiterZuordnung.entries()),
            anmerkungen: state.anmerkungen,
            raumbedarf: state.raumbedarf,
            wunschFreieTage: state.wunschFreieTage,
            planungId: state.planungId,
            currentStep: state.currentStep,
            savedAt: new Date().toISOString(),
          };

          const storageKey = getLocalStorageKey();
          localStorage.setItem(storageKey, JSON.stringify(dataToSave));

          set({
            lastSaved: new Date(),
            isDirty: false
          });

          console.log(`[PlanungStore] 💾 Auto-saved to LocalStorage for user ${user.id}`);
        } catch (error) {
          console.error('[PlanungStore] ❌ Error saving to LocalStorage:', error);
        }
      },

      loadFromLocalStorage: () => {
        try {
          const user = useAuthStore.getState().user;
          if (!user || !user.id) {
            console.warn('[PlanungStore] ⚠ Cannot load - no user logged in');
            return false;
          }

          const storageKey = getLocalStorageKey();
          const saved = localStorage.getItem(storageKey);

          if (!saved) {
            console.log(`[PlanungStore] ℹ️ No saved data found for user ${user.id}`);
            return false;
          }

          const data = JSON.parse(saved);

          // ✅ WICHTIG: Validiere, dass die Daten zum aktuellen User gehören
          if (data.userId && data.userId !== user.id) {
            console.warn(`[PlanungStore] ⚠ Data belongs to different user (${data.userId}), clearing...`);
            localStorage.removeItem(storageKey);
            return false;
          }

          console.log(`[PlanungStore] 📂 Loading from LocalStorage for user ${user.id}...`);
          console.log('[PlanungStore] Saved at:', data.savedAt);

          set({
            semesterId: data.semesterId,
            semester: data.semester,
            selectedModules: data.selectedModules || [],
            geplantModule: data.geplantModule || [],
            mitarbeiterZuordnung: new Map(data.mitarbeiterZuordnung || []),
            anmerkungen: data.anmerkungen || '',
            raumbedarf: data.raumbedarf || '',
            wunschFreieTage: data.wunschFreieTage || [],
            planungId: data.planungId,
            currentStep: data.currentStep || 0,
            lastSaved: data.savedAt ? new Date(data.savedAt) : null,
            isDirty: false,
          });

          console.log('[PlanungStore] ✅ Data restored from LocalStorage');
          return true;
        } catch (error) {
          console.error('[PlanungStore] ❌ Error loading from LocalStorage:', error);
          return false;
        }
      },

      clearLocalStorage: () => {
        try {
          const storageKey = getLocalStorageKey();
          localStorage.removeItem(storageKey);
          console.log('[PlanungStore] 🗑️ LocalStorage cleared for current user');
        } catch (error) {
          console.error('[PlanungStore] ❌ Error clearing LocalStorage:', error);
        }
      },

      markAsSaved: () => {
        set({ 
          lastSaved: new Date(),
          isDirty: false 
        });
      },

      markAsDirty: () => {
        set({ isDirty: true });
      },

      // =====================================================================
      // RESET
      // =====================================================================

      resetWizard: () => {
        console.log('[PlanungStore] 🔄 Resetting wizard');
        get().clearLocalStorage();
        set(initialState);
      },

      // =====================================================================
      // COMPUTED VALUES
      // =====================================================================

      getTotalSWS: () => {
        const { geplantModule } = get();
        return geplantModule.reduce((sum, m) => sum + (m.sws_gesamt || 0), 0);
      },

      isStepValid: (step) => {
        const state = get();
        
        switch (step) {
          case 0: // Semester
            return state.semesterId !== null;
          case 1: // Module Auswahl
            return state.selectedModules.length > 0;
          case 2: // Module Hinzufügen
            return state.geplantModule.length > 0;
          case 3: // Mitarbeiter (optional)
            return true;
          case 4: // Multiplikatoren
            return state.geplantModule.every(m => m.sws_gesamt > 0);
          case 5: // Zusatzinfos (optional)
            return true;
          case 6: // Wunsch-freie Tage (optional)
            return true;
          case 7: // Zusammenfassung
            return state.geplantModule.length > 0 && state.getTotalSWS() > 0;
          default:
            return false;
        }
      },
    }),
    {
      name: 'PlanungStore',
    }
  )
);

export default usePlanungStore;