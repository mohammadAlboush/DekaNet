/**
 * Dashboard Service
 *
 * Handles fetching dashboard statistics including phase-based statistics
 */

import api, { ApiResponse } from './api';
import { Semester } from '../types/semester.types';
import { PlanungPhase } from '../types/planungPhase.types';

// ============================================================================
// Types
// ============================================================================

export interface DashboardStatistik {
  semester?: {
    aktiv: Semester | null;
    planungsphase: Semester | null;
  };
  planungen?: {
    gesamt: number;
    entwurf: number;
    eingereicht: number;
    freigegeben: number;
    abgelehnt: number;
  };
  dozenten?: {
    gesamt: number;
    aktiv: number;
  };
  module?: {
    gesamt: number;
    aktiv: number;
  };
}

export interface DozentDashboardData {
  planungen: {
    gesamt: number;
    entwurf: number;
    eingereicht: number;
    freigegeben: number;
    liste: unknown[];  // Simplified planung objects
  };
  aktuelle_planung: {
    id: number;
    semester_id: number;
    status: string;
    anzahl_module: number;
  } | null;
  module?: {
    gesamt: number;
    liste: unknown[];
  };
}

export interface DekanDashboardData {
  planungen: {
    gesamt: number;
    offen: number;
    freigegeben: number;
    abgelehnt: number;
    eingereicht: number;
    offene_liste?: unknown[];
  };
  semester?: {
    aktiv: Semester | null;
    planungsphase: PlanungPhase | null;
  };
  dozenten?: {
    gesamt: number;
    mit_planung: number;
    ohne_planung: number;
  };
}

export interface Notification {
  id: number;
  typ: 'info' | 'warnung' | 'erfolg' | 'fehler';
  titel: string;
  nachricht: string;
  gelesen: boolean;
  erstellt_am: string;
  link?: string;
}

export interface NotificationsResponse {
  notifications: Notification[];
  total: number;
  ungelesen: number;
}

export interface MarkGelesenResponse {
  erfolg: boolean;
}

export interface PhasenStatistikGesamt {
  anzahl_phasen: number;
  anzahl_planungen_gesamt: number;
  anzahl_einreichungen_gesamt: number;
  anzahl_genehmigt_gesamt: number;
  anzahl_abgelehnt_gesamt: number;
  anzahl_entwuerfe_gesamt: number;
  durchschnittliche_genehmigungsrate: number;
  aktive_phasen: number;
}

export interface PhaseStatistiken {
  gesamt_planungen: number;
  entwuerfe: number;
  eingereicht: number;
  freigegeben: number;
  abgelehnt: number;
  genehmigungsrate: number;
  sws: {
    gesamt: number;
    durchschnitt: number;
  };
}

export interface PhasenStatistik {
  phase_id: number;
  phase_name: string;
  semester_id: number;
  semester_name: string | null;
  startdatum: string | null;
  enddatum: string | null;
  ist_aktiv: boolean;
  geschlossen_am: string | null;
  dauer_tage: number;
  statistiken: PhaseStatistiken;
}

export interface PhasenStatistikResponse {
  gesamt: PhasenStatistikGesamt;
  phasen: PhasenStatistik[];
}

// ============================================================================
// API Functions
// ============================================================================

/**
 * Holt allgemeine Dashboard-Statistiken
 */
export const getStatistik = async (): Promise<ApiResponse<DashboardStatistik>> => {
  const response = await api.get('/dashboard/statistik');
  return response.data;
};

/**
 * Holt Statistiken pro Planungsphase
 *
 * @param semester_id - Optional: Filter nach Semester
 * @param limit - Optional: Anzahl der Phasen
 */
export const getPhasenStatistik = async (
  semester_id?: number,
  limit?: number
): Promise<ApiResponse<PhasenStatistikResponse>> => {
  const params: Record<string, string | number | boolean> = {};

  if (semester_id !== undefined) {
    params.semester_id = semester_id;
  }

  if (limit !== undefined) {
    params.limit = limit;
  }

  const response = await api.get('/dashboard/statistik/phasen', { params });
  return response.data;
};

/**
 * Holt Dekan-Dashboard-Daten
 */
export const getDekanDashboard = async (): Promise<ApiResponse<DekanDashboardData>> => {
  const response = await api.get('/dashboard/dekan');
  return response.data;
};

/**
 * Holt Dozenten-Dashboard-Daten
 */
export const getDozentDashboard = async (): Promise<ApiResponse<DozentDashboardData>> => {
  const response = await api.get('/dashboard/dozent');
  return response.data;
};

/**
 * Holt Benachrichtigungen
 *
 * @param ungelesen - Optional: Nur ungelesene Benachrichtigungen
 * @param limit - Optional: Anzahl der Benachrichtigungen
 */
export const getNotifications = async (
  ungelesen?: boolean,
  limit?: number
): Promise<ApiResponse<NotificationsResponse>> => {
  const params: Record<string, string | number | boolean> = {};

  if (ungelesen !== undefined) {
    params.ungelesen = ungelesen;
  }

  if (limit !== undefined) {
    params.limit = limit;
  }

  const response = await api.get('/dashboard/notifications', { params });
  return response.data;
};

/**
 * Markiert eine Benachrichtigung als gelesen
 *
 * @param notificationId - ID der Benachrichtigung
 */
export const markiereGelesen = async (
  notificationId: number
): Promise<ApiResponse<MarkGelesenResponse>> => {
  const response = await api.post(`/dashboard/notifications/${notificationId}/gelesen`);
  return response.data;
};

/**
 * Markiert alle Benachrichtigungen als gelesen
 */
export const markiereAlleGelesen = async (): Promise<ApiResponse<MarkGelesenResponse>> => {
  const response = await api.post('/dashboard/notifications/alle-gelesen');
  return response.data;
};

// ============================================================================
// Nicht zugeordnete Module
// ============================================================================

export interface ModulVerantwortlicher {
  dozent_id: number;
  name: string;
  email?: string;
}

export interface ModulPlanungStatus {
  hat_planung: boolean;
  planung_id?: number;
  dozent_id?: number;
  dozent_name?: string;
  status?: 'entwurf' | 'eingereicht' | 'genehmigt' | 'abgelehnt';
  eingereicht_am?: string;
}

export interface NichtZugeordnetesModul {
  id: number;
  kuerzel: string;
  bezeichnung_de: string;
  bezeichnung_en: string | null;
  leistungspunkte: number;
  turnus: string;
  sws_gesamt: number;
  po_id: number;
  // Erweiterte Felder für bessere Übersicht
  verantwortlicher?: ModulVerantwortlicher;
  lehrpersonen?: ModulVerantwortlicher[];
  planungen?: ModulPlanungStatus[]; // Wer hat dieses Modul in seiner Planung?
}

export interface NichtZugeordneteModuleStatistik {
  gesamt: number;
  nach_turnus: Record<string, number>;
  alle_module: number;
  geplante_module: number;
  zuordnungsquote: number;
}

export interface NichtZugeordneteModuleResponse {
  semester: Semester;
  planungsphase: PlanungPhase | null;
  planungsphase_aktiv: boolean;
  relevante_turnus: string[] | null;
  nicht_zugeordnete_module: NichtZugeordnetesModul[];
  statistik: NichtZugeordneteModuleStatistik;
}

/**
 * Holt nicht zugeordnete Module für aktuelles Semester
 *
 * @param semester_id - Optional: Spezifisches Semester
 * @param po_id - Optional: Filter nach Prüfungsordnung
 */
export const getNichtZugeordneteModule = async (
  semester_id?: number,
  po_id?: number
): Promise<ApiResponse<NichtZugeordneteModuleResponse>> => {
  const params: Record<string, string | number | boolean> = {};

  if (semester_id !== undefined) {
    params.semester_id = semester_id;
  }

  if (po_id !== undefined) {
    params.po_id = po_id;
  }

  const response = await api.get('/dashboard/nicht-zugeordnete-module', { params });
  return response.data;
};

// ============================================================================
// Dozenten Planungsfortschritt
// ============================================================================

export interface DozentPlanungsfortschritt {
  dozent_id: number;
  name: string;
  email?: string;
  anzahl_zu_planen: number;
  anzahl_geplant: number;
  anzahl_offen: number;
  prozent_geplant: number;
  status: 'vollständig' | 'teilweise' | 'offen';
  nicht_geplante_module: Array<{
    id: number;
    kuerzel: string;
    bezeichnung: string;
  }>;
}

export interface DozentenPlanungsfortschrittResponse {
  semester: Semester;
  planungsphase_aktiv: boolean;
  dozenten: DozentPlanungsfortschritt[];
  statistik: {
    gesamt_dozenten: number;
    vollstaendig: number;
    teilweise: number;
    offen: number;
    durchschnitt_prozent: number;
  };
}

/**
 * Holt Planungsfortschritt aller Dozenten
 *
 * @param semester_id - Optional: Spezifisches Semester
 */
export const getDozentenPlanungsfortschritt = async (
  semester_id?: number
): Promise<ApiResponse<DozentenPlanungsfortschrittResponse>> => {
  const params: Record<string, string | number | boolean> = {};

  if (semester_id !== undefined) {
    params.semester_id = semester_id;
  }

  const response = await api.get('/dashboard/dozenten-planungsfortschritt', { params });
  return response.data;
};

// ============================================================================
// Modulhandbücher
// ============================================================================

export interface ModulhandbuchModul {
  id: number;
  kuerzel: string;
  bezeichnung_de: string;
  bezeichnung_en: string | null;
  leistungspunkte: number | null;
  turnus: string | null;
  sws_gesamt: number;
  semester: number | null;
  kategorie: string | null;
  pflicht?: boolean;
  wahlpflicht?: boolean;
  verantwortlicher: string | null;
  lehrpersonen?: string[];
}

export interface ModulhandbuchStudiengang {
  id: number;
  kuerzel: string;
  bezeichnung: string;
  abschluss: string | null;
  fachbereich: string | null;
  regelstudienzeit: number | null;
  ects_gesamt: number | null;
  module: ModulhandbuchModul[];
  statistik: {
    anzahl_module: number;
    kategorien: Record<string, number>;
    ects_summe: number;
    turnus_verteilung: Record<string, number>;
    semester_verteilung: Record<string, number>;
  };
}

export interface ModulhandbucherResponse {
  studiengaenge: ModulhandbuchStudiengang[];
  nicht_zugeordnet: {
    module: ModulhandbuchModul[];
    anzahl: number;
  };
  gesamt_statistik: {
    alle_module: number;
    zugeordnet: number;
    nicht_zugeordnet: number;
    studiengaenge: number;
  };
}

/**
 * Holt Modulhandbücher-Daten (alle Module gruppiert nach Studiengang)
 */
export const getModulhandbuecher = async (): Promise<ApiResponse<ModulhandbucherResponse>> => {
  const response = await api.get('/dashboard/modulhandbuecher');
  return response.data;
};

export default {
  getStatistik,
  getPhasenStatistik,
  getDekanDashboard,
  getDozentDashboard,
  getNotifications,
  markiereGelesen,
  markiereAlleGelesen,
  getNichtZugeordneteModule,
  getDozentenPlanungsfortschritt,
  getModulhandbuecher,
};
