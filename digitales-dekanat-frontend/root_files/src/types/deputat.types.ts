// types/deputat.types.ts - Deputatsabrechnung TypeScript Types

/**
 * Deputats-Einstellungen (globale Konfiguration)
 */
export interface DeputatsEinstellungen {
  id: number;

  // SWS-Werte für Betreuungen
  sws_bachelor_arbeit: number;
  sws_master_arbeit: number;
  sws_doktorarbeit: number;
  sws_seminar_ba: number;
  sws_seminar_ma: number;
  sws_projekt_ba: number;
  sws_projekt_ma: number;

  // Obergrenzen
  max_sws_praxisseminar: number;
  max_sws_projektveranstaltung: number;
  max_sws_seminar_master: number;
  max_sws_betreuung: number;

  // Warnschwellen
  warn_ermaessigung_ueber: number;

  // Standard-Lehrverpflichtung
  default_netto_lehrverpflichtung: number;

  // Meta
  ist_aktiv: boolean;
  beschreibung: string | null;
  created_at: string;
  updated_at: string;
  erstellt_von: number | null;
  ersteller_name: string | null;
}

/**
 * Status einer Deputatsabrechnung
 */
export type DeputatStatus = 'entwurf' | 'eingereicht' | 'genehmigt' | 'abgelehnt';

/**
 * Kategorie einer Lehrtätigkeit
 */
export type LehrtaetigkeitKategorie =
  | 'lehrveranstaltung'
  | 'praxisseminar'
  | 'projektveranstaltung'
  | 'seminar_master';

/**
 * Wochentag
 */
export type Wochentag = 'montag' | 'dienstag' | 'mittwoch' | 'donnerstag' | 'freitag';

/**
 * Art der Vertretung
 */
export type VertretungArt = 'praxissemester' | 'forschungsfreisemester';

/**
 * Art der Betreuung
 */
export type BetreuungsArt =
  | 'bachelor'
  | 'master'
  | 'doktorarbeit'
  | 'seminar_ba'
  | 'seminar_ma'
  | 'projekt_ba'
  | 'projekt_ma';

/**
 * Status einer Betreuung
 */
export type BetreuungStatus = 'laufend' | 'abgeschlossen';

/**
 * Quelle eines Eintrags
 */
export type EntragQuelle = 'planung' | 'semesterauftrag' | 'manuell';

/**
 * Benutzer-Info (embedded in Abrechnung)
 */
export interface DeputatBenutzer {
  id: number;
  username: string;
  name_komplett: string;
  email: string;
}

/**
 * Planungsphase-Info (embedded in Abrechnung)
 */
export interface DeputatPlanungsphase {
  id: number;
  name: string;
  semester_id: number;
  semester_kuerzel: string | null;
}

/**
 * Lehrtätigkeit
 */
export interface DeputatsLehrtaetigkeit {
  id: number;
  deputatsabrechnung_id: number;
  bezeichnung: string;
  kategorie: LehrtaetigkeitKategorie;
  sws: number;
  wochentag: Wochentag | null;
  ist_block: boolean;
  quelle: EntragQuelle;
  geplantes_modul_id: number | null;
  created_at: string;
}

/**
 * Lehrexport
 */
export interface DeputatsLehrexport {
  id: number;
  deputatsabrechnung_id: number;
  fachbereich: string;
  fach: string;
  sws: number;
  created_at: string;
}

/**
 * Vertretung
 */
export interface DeputatsVertretung {
  id: number;
  deputatsabrechnung_id: number;
  art: VertretungArt;
  vertretene_person: string;
  fach_professor: string;
  sws: number;
  created_at: string;
}

/**
 * Ermäßigung
 */
export interface DeputatsErmaessigung {
  id: number;
  deputatsabrechnung_id: number;
  bezeichnung: string;
  sws: number;
  quelle: EntragQuelle;
  semester_auftrag_id: number | null;
  created_at: string;
}

/**
 * Betreuung
 */
export interface DeputatsBetreuung {
  id: number;
  deputatsabrechnung_id: number;
  student_name: string;
  student_vorname: string;
  student_name_komplett: string;
  titel_arbeit: string | null;
  betreuungsart: BetreuungsArt;
  status: BetreuungStatus;
  beginn_datum: string | null;
  ende_datum: string | null;
  sws: number;
  created_at: string;
}

/**
 * Berechnete Summen einer Deputatsabrechnung
 */
export interface DeputatSummen {
  // Lehrtätigkeiten Detail
  sws_lehrtaetigkeiten: number;
  sws_praxisseminar: number;
  sws_praxisseminar_angerechnet: number;
  sws_projektveranstaltung: number;
  sws_projektveranstaltung_angerechnet: number;
  sws_seminar_master: number;
  sws_seminar_master_angerechnet: number;
  sws_sonstige_lehre: number;

  // Weitere Kategorien
  sws_lehrexport: number;
  sws_vertretungen: number;
  sws_ermaessigungen: number;
  sws_betreuungen_roh: number;
  sws_betreuungen_angerechnet: number;

  // Summen
  gesamtdeputat: number;
  nettobelastung: number;
  netto_lehrverpflichtung: number;
  differenz: number;

  // Bewertung
  bewertung: 'erfuellt' | 'abweichung' | 'starke_abweichung';
  warnungen: string[];

  // Anzahlen
  anzahl_lehrtaetigkeiten: number;
  anzahl_lehrexporte: number;
  anzahl_vertretungen: number;
  anzahl_ermaessigungen: number;
  anzahl_betreuungen: number;
}

/**
 * Deputatsabrechnung (Hauptobjekt)
 */
export interface Deputatsabrechnung {
  id: number;
  planungsphase_id: number;
  benutzer_id: number;
  status: DeputatStatus;
  netto_lehrverpflichtung: number;
  bemerkungen: string | null;

  // Workflow
  eingereicht_am: string | null;
  genehmigt_am: string | null;
  genehmigt_von: number | null;
  abgelehnt_am: string | null;
  ablehnungsgrund: string | null;

  // Audit
  created_at: string;
  updated_at: string;

  // Embedded Objects
  benutzer?: DeputatBenutzer;
  planungsphase?: DeputatPlanungsphase;
  genehmiger?: { id: number; name_komplett: string };

  // Details (optional)
  lehrtaetigkeiten?: DeputatsLehrtaetigkeit[];
  lehrexporte?: DeputatsLehrexport[];
  vertretungen?: DeputatsVertretung[];
  ermaessigungen?: DeputatsErmaessigung[];
  betreuungen?: DeputatsBetreuung[];

  // Summen (optional)
  summen?: DeputatSummen;
}

/**
 * Statistik für Dekan-Übersicht
 */
export interface DeputatStatistik {
  gesamt: number;
  entwurf: number;
  eingereicht: number;
  genehmigt: number;
  abgelehnt: number;
  quote_eingereicht: number;
  quote_genehmigt: number;
}

// =========================================================================
// API RESPONSE TYPES
// =========================================================================

export interface DeputatResponse<T> {
  success: boolean;
  data: T;
  message?: string;
}

export interface DeputatListResponse {
  success: boolean;
  data: Deputatsabrechnung[];
  message?: string;
}

export interface DeputatImportResult {
  importiert: number;
  uebersprungen: number;
}

export interface DeputatImportResponse {
  success: boolean;
  data: Deputatsabrechnung;
  import_result: DeputatImportResult;
  message?: string;
}

// =========================================================================
// INPUT TYPES (für Create/Update)
// =========================================================================

export interface CreateDeputatData {
  planungsphase_id: number;
}

export interface UpdateDeputatData {
  netto_lehrverpflichtung?: number;
  bemerkungen?: string;
}

export interface CreateLehrtaetigkeitData {
  bezeichnung: string;
  sws: number;
  kategorie?: LehrtaetigkeitKategorie;
  wochentag?: Wochentag;
  ist_block?: boolean;
}

export interface UpdateLehrtaetigkeitData {
  bezeichnung?: string;
  sws?: number;
  kategorie?: LehrtaetigkeitKategorie;
  wochentag?: Wochentag | null;
  ist_block?: boolean;
}

export interface CreateLehrexportData {
  fachbereich: string;
  fach: string;
  sws: number;
}

export interface UpdateLehrexportData {
  fachbereich?: string;
  fach?: string;
  sws?: number;
}

export interface CreateVertretungData {
  art: VertretungArt;
  vertretene_person: string;
  fach_professor: string;
  sws: number;
}

export interface UpdateVertretungData {
  art?: VertretungArt;
  vertretene_person?: string;
  fach_professor?: string;
  sws?: number;
}

export interface CreateErmaessigungData {
  bezeichnung: string;
  sws: number;
}

export interface UpdateErmaessigungData {
  bezeichnung?: string;
  sws?: number;
}

export interface CreateBetreuungData {
  student_name: string;
  student_vorname: string;
  betreuungsart: BetreuungsArt;
  titel_arbeit?: string;
  status?: BetreuungStatus;
  beginn_datum?: string;
  ende_datum?: string;
}

export interface UpdateBetreuungData {
  student_name?: string;
  student_vorname?: string;
  betreuungsart?: BetreuungsArt;
  titel_arbeit?: string;
  status?: BetreuungStatus;
  beginn_datum?: string;
  ende_datum?: string;
}

export interface UpdateEinstellungenData {
  sws_bachelor_arbeit?: number;
  sws_master_arbeit?: number;
  sws_doktorarbeit?: number;
  sws_seminar_ba?: number;
  sws_seminar_ma?: number;
  sws_projekt_ba?: number;
  sws_projekt_ma?: number;
  max_sws_praxisseminar?: number;
  max_sws_projektveranstaltung?: number;
  max_sws_seminar_master?: number;
  max_sws_betreuung?: number;
  warn_ermaessigung_ueber?: number;
  default_netto_lehrverpflichtung?: number;
  beschreibung?: string;
}

// =========================================================================
// KONSTANTEN
// =========================================================================

export const LEHRTAETIGKEIT_KATEGORIEN: Record<LehrtaetigkeitKategorie, string> = {
  lehrveranstaltung: 'Lehrveranstaltung',
  praxisseminar: 'Praxisseminar',
  projektveranstaltung: 'Projektveranstaltung',
  seminar_master: 'Seminar (Master)',
};

export const WOCHENTAGE: Record<Wochentag, string> = {
  montag: 'Montag',
  dienstag: 'Dienstag',
  mittwoch: 'Mittwoch',
  donnerstag: 'Donnerstag',
  freitag: 'Freitag',
};

export const VERTRETUNG_ARTEN: Record<VertretungArt, string> = {
  praxissemester: 'Praxissemester',
  forschungsfreisemester: 'Forschungsfreisemester',
};

export const BETREUUNGS_ARTEN: Record<BetreuungsArt, string> = {
  bachelor: 'Bachelorarbeit',
  master: 'Masterarbeit',
  doktorarbeit: 'Doktorarbeit',
  seminar_ba: 'Seminar (Bachelor)',
  seminar_ma: 'Seminar (Master)',
  projekt_ba: 'Projekt (Bachelor)',
  projekt_ma: 'Projekt (Master)',
};

export const BETREUUNG_STATUS: Record<BetreuungStatus, string> = {
  laufend: 'Laufend',
  abgeschlossen: 'Abgeschlossen',
};

export const DEPUTAT_STATUS: Record<DeputatStatus, string> = {
  entwurf: 'Entwurf',
  eingereicht: 'Eingereicht',
  genehmigt: 'Genehmigt',
  abgelehnt: 'Abgelehnt',
};

export const DEPUTAT_STATUS_COLORS: Record<DeputatStatus, 'default' | 'info' | 'success' | 'error'> = {
  entwurf: 'default',
  eingereicht: 'info',
  genehmigt: 'success',
  abgelehnt: 'error',
};
