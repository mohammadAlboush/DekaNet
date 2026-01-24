// types/planung_types.ts - KORRIGIERTE VERSION
// ✅ SECURITY FIX: `any` Types durch konkrete Typen ersetzt (2026-01-24)

import { Semester } from './semester.types';
import { User } from './auth.types';
import { PlanungPhase } from './planungPhase.types';
import { Modul } from './modul.types';

// ✅ Interfaces für room_requirements und special_requests
export interface RoomRequirement {
  type: string;
  capacity: number;
  equipment?: string[];
}

export interface SpecialRequests {
  needsComputerRoom?: boolean;
  needsLab?: boolean;
  needsBeamer?: boolean;
  needsWhiteboard?: boolean;
  flexibleScheduling?: boolean;
  blockCourse?: boolean;
}

export interface Semesterplanung {
  created: boolean;
  anzahl_module: number;
  id: number;
  semester_id: number;
  benutzer_id: number;
  po_id: number;
  planungsphase_id?: number;          // ✅ HINZUGEFÜGT
  status: 'entwurf' | 'eingereicht' | 'freigegeben' | 'abgelehnt';
  eingereicht_am?: string;
  freigegeben_am?: string;
  freigegeben_von?: number;
  ablehnungsgrund?: string;
  notizen?: string;
  anmerkungen?: string;               // ✅ HINZUGEFÜGT
  raumbedarf?: string;                // ✅ HINZUGEFÜGT
  room_requirements?: RoomRequirement[] | string;  // ✅ KORRIGIERT: Kann Array oder String sein
  special_requests?: SpecialRequests | string;     // ✅ KORRIGIERT: Kann Objekt oder String sein
  gesamt_sws: number;
  created_at: string;
  updated_at: string;
  semester?: Semester;                 // ✅ TYPESAFE: Konkreter Typ statt any
  benutzer?: User;                     // ✅ TYPESAFE: Konkreter Typ statt any
  planungsphase?: PlanungPhase;        // ✅ TYPESAFE: Konkreter Typ statt any
  geplante_module?: GeplantesModul[];
  wunsch_freie_tage?: WunschFreierTag[];
}

export interface GeplantesModul {
  id: number;
  planung_id: number;
  modul_id: number;
  po_id: number;
  anzahl_vorlesungen: number;
  anzahl_uebungen: number;
  anzahl_praktika: number;
  anzahl_seminare: number;
  sws_vorlesung: number;
  sws_uebung: number;
  sws_praktikum: number;
  sws_seminar: number;
  sws_gesamt: number;
  bemerkung?: string;
  anmerkungen?: string;
  raumbedarf?: string;
  mitarbeiter_ids?: number[];
  modul?: Modul;                       // ✅ TYPESAFE: Konkreter Typ statt any
  // Raum-Planung pro Lehrform
  raum_vorlesung?: string;
  raum_uebung?: string;
  raum_praktikum?: string;
  raum_seminar?: string;
  // Kapazitäts-Anforderungen pro Lehrform
  kapazitaet_vorlesung?: number;
  kapazitaet_uebung?: number;
  kapazitaet_praktikum?: number;
  kapazitaet_seminar?: number;
  // Ausstattungs-Anforderungen pro Lehrform
  ausstattung_vorlesung?: string[];
  ausstattung_uebung?: string[];
  ausstattung_praktikum?: string[];
  ausstattung_seminar?: string[];
}

export interface WunschFreierTag {
  grund: string;
  datum: string | number | Date;
  id: number;
  planung_id: number;
  wochentag: number;
  ganztags: boolean;
  vormittag: boolean;
  nachmittag: boolean;
  zeitraum?: string;  // ✅ HINZUGEFÜGT: Optional für Anzeige (z.B. "Ganztags", "Vormittag")
}

export interface CreatePlanungData {
  semester_id: number;
  po_id?: number;  // Optional: Prüfungsordnung ID (defaults to user's PO or 1)
  notizen?: string;
}

// ✅ KORRIGIERT: Alle Felder die das Backend erwartet
export interface AddModulData {
  modul_id: number;
  po_id: number;
  anzahl_vorlesungen?: number;
  anzahl_uebungen?: number;
  anzahl_praktika?: number;
  anzahl_seminare?: number;
  bemerkung?: string;
  anmerkungen?: string;
  raumbedarf?: string;
  mitarbeiter_ids?: number[];
  // Raum-Planung pro Lehrform
  raum_vorlesung?: string;
  raum_uebung?: string;
  raum_praktikum?: string;
  raum_seminar?: string;
  // Kapazitäts-Anforderungen pro Lehrform
  kapazitaet_vorlesung?: number;
  kapazitaet_uebung?: number;
  kapazitaet_praktikum?: number;
  kapazitaet_seminar?: number;
}