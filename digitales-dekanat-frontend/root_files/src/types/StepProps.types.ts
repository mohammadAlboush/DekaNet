
/**
 * Step Props Types
 * ================
 * Gemeinsame Type-Definitionen für alle Wizard Steps
 * 
 */

import { Semester } from './semester.types';
import { GeplantesModul, WunschFreierTag } from './planung.types';
import { Modul } from './modul.types';

/**
 * Wizard Data - gemeinsame Daten über alle Steps
 * 
 * WICHTIG: Verwendet | null statt | undefined für Konsistenz mit Store
 */
export interface WizardData {
  // Step 1: Semester
  semesterId: number | null;
  semester: Semester | null;
  
  // Step 2: Module Selection
  selectedModules: Modul[];
  
  // Step 3+: Geplante Module
  geplantModule: GeplantesModul[];
  
  // Step 4: Mitarbeiter
  mitarbeiterZuordnung: Map<number, number[]>;
  
  // Step 6: Zusatzinfos
  anmerkungen: string;
  raumbedarf: string;
  
  // Step 7: Wunsch-freie Tage
  wunschFreieTage: WunschFreierTag[];
  
  // Planung ID (wenn erstellt)
  planungId: number | null;
}

/**
 * Base Step Props - für alle Steps
 */
export interface BaseStepProps {
  data: WizardData;
  onUpdate: (data: Partial<WizardData>) => void;
  onNext?: () => void;
  onBack?: () => void;
  planungId?: number;
}

/**
 * Step 1: Semester Auswahl
 */
export interface StepSemesterAuswahlProps {
  data: WizardData;
  onUpdate: (data: Partial<WizardData>) => void;
  onNext: () => void;
  planungId?: number;
  setPlanungId: (id: number) => void;
}

/**
 * Step 2: Module Auswahl
 */
export interface StepModuleAuswahlProps {
  data: WizardData;
  onUpdate: (data: Partial<WizardData>) => void;
  onNext: () => void;
  onBack: () => void;
}

/**
 * Step 3: Module Hinzufügen
 */
export interface StepModuleHinzufuegenProps {
  data: WizardData;
  onUpdate: (data: Partial<WizardData>) => void;
  onNext: () => void;
  onBack: () => void;
  planungId?: number;
}

/**
 * Step 4: Mitarbeiter Zuordnen
 */
export interface StepMitarbeiterZuordnenProps {
  data: WizardData;
  onUpdate: (data: Partial<WizardData>) => void;
  onNext: () => void;
  onBack: () => void;
}

/**
 * Step 5: Multiplikatoren
 */
export interface StepMultiplikatorenProps {
  data: WizardData;
  onUpdate: (data: Partial<WizardData>) => void;
  onNext: () => void;
  onBack: () => void;
  planungId?: number;
}

/**
 * Step 6: Zusätzliche Infos
 */
export interface StepZusatzInfosProps {
  data: WizardData;
  onUpdate: (data: Partial<WizardData>) => void;
  onNext: () => void;
  onBack: () => void;
}

/**
 * Step 7: Wunsch-freie Tage
 */
export interface StepWunschFreieTageProps {
  data: WizardData;
  onUpdate: (data: Partial<WizardData>) => void;
  onNext: () => void;
  onBack: () => void;
  planungId?: number;
}

/**
 * Step 8: Zusammenfassung
 */
export interface StepZusammenfassungProps {
  data: WizardData;
  onBack: () => void;
  onSubmit: () => Promise<void>;
  planungId?: number;
}