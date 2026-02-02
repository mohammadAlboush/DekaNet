// Planungsphase Types
// SECURITY FIX: `any` Types durch konkrete Typen ersetzt (2026-01-24)
import { Semesterplanung } from './planung.types';

export type SemesterTyp = 'wintersemester' | 'sommersemester';

export interface PlanungPhase {
  id: number;
  semester_id: number;
  name: string; // z.B. "Sommersemester 2024 - Phase 1"
  startdatum: string; // ISO date string
  enddatum?: string; // Optional: Deadline wenn konfiguriert
  ist_aktiv: boolean;
  geschlossen_am?: string; // Wann wurde die Phase geschlossen
  geschlossen_von?: number; // User ID des Dekans der die Phase geschlossen hat
  // NEU: Strukturierte Semester-Info
  semester_typ?: SemesterTyp;
  semester_jahr?: number;
  anzahl_einreichungen: number; // Statistik: Wie viele Einreichungen
  anzahl_genehmigt: number; // Statistik: Wie viele genehmigt
  anzahl_abgelehnt: number; // Statistik: Wie viele abgelehnt
  created_at: string;
  updated_at: string;
}

// NEU: Vereinfachte DTO für Phase-Erstellung mit Dropdown-Auswahl
export interface CreatePlanungPhaseDto {
  semester_typ: SemesterTyp;
  semester_jahr: number;
  startdatum: string;  // ISO DateTime
  enddatum: string;    // ISO DateTime - PFLICHT
}

export interface ClosePlanungPhaseDto {
  archiviere_entwuerfe: boolean; // Falls true, werden Entwürfe archiviert statt gelöscht
  grund?: string; // Optionaler Grund für die Schließung
}

// Tracking für Einreichungen pro Professor
export interface ProfessorPhaseSubmission {
  id?: number;  // Optional: Submission ID (for list key)
  professor_id: number;
  planungphase_id: number;
  planung_id: number;
  eingereicht_am: string;
  status: 'eingereicht' | 'freigegeben' | 'abgelehnt';
  freigegeben_am?: string;
  abgelehnt_am?: string;
}

// Archivierte Planung
export interface ArchiviertePlanung {
  id: number;
  original_planung_id: number;
  planungphase_id: number;
  professor_id: number;
  professor_name: string;
  semester_name: string;
  phase_name: string;
  status_bei_archivierung: string;
  archiviert_am: string;
  archiviert_grund: 'phase_geschlossen' | 'manuell' | 'system';
  planung_daten: Partial<Semesterplanung>; // JSON der ursprünglichen Planung
}

// Filter für Archiv-Suche
export interface ArchivFilter {
  planungphase_id?: number;
  professor_id?: number;
  semester_id?: number;
  status?: string;
  von_datum?: string;
  bis_datum?: string;
  nur_eigene?: boolean; // Für Professoren: nur eigene archivierte Planungen
}

// Phase Statistiken
export interface PhaseStatistik {
  phase_id: number;
  phase_name: string;
  startdatum: string;
  enddatum?: string;
  dauer_tage: number;
  professoren_gesamt: number;
  professoren_eingereicht: number;
  einreichungsquote: number; // Prozent
  genehmigungsquote: number; // Prozent der eingereichten
  durchschnittliche_bearbeitungszeit: number; // In Stunden
  top_module: Array<{
    modul_name: string;
    anzahl: number;
  }>;
}

// Response Types
export interface PlanungPhaseListResponse {
  phasen: PlanungPhase[];
  total: number;
  aktive_phase?: PlanungPhase;
}

export interface PhaseSubmissionStatus {
  kann_einreichen: boolean;
  grund?: 'keine_aktive_phase' | 'bereits_eingereicht' | 'bereits_genehmigt' | 'phase_abgelaufen';
  aktive_phase?: PlanungPhase;
  letzte_einreichung?: ProfessorPhaseSubmission;
  verbleibende_zeit?: number; // In Minuten, falls Deadline gesetzt
}

export interface PhaseHistoryEntry {
  phase: PlanungPhase;
  statistik: PhaseStatistik;
  eigene_einreichung?: ProfessorPhaseSubmission;
}

// NEU: Response für /active-with-semester endpoint
export interface ActivePhaseWithSemesterResponse {
  success: boolean;
  phase: PlanungPhase | null;
  semester: {
    id: number;
    bezeichnung: string;
    kuerzel: string;
    start_datum: string;
    ende_datum: string;
    ist_aktiv: boolean;
    ist_planungsphase: boolean;
  } | null;
}