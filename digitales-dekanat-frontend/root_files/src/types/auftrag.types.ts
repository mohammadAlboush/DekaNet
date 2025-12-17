// types/auftrag.types.ts - Auftrag & SemesterAuftrag Types

/**
 * Auftrag (Master-Liste)
 *
 * Beispiele:
 * - Dekanin (5.0 SWS)
 * - Prodekan (4.5 SWS)
 * - Studiengangsbeauftragter IS (0.5 SWS)
 */
export interface Auftrag {
  id: number;
  name: string;
  beschreibung?: string;
  standard_sws: number;
  ist_aktiv: boolean;
  sortierung?: number;
}

/**
 * SemesterAuftrag
 *
 * Zuordnung: Auftrag → Dozent pro Semester
 *
 * Workflow:
 * - Professor beantragt: status = 'beantragt'
 * - Dekan genehmigt: status = 'genehmigt'
 * - Dekan lehnt ab: status = 'abgelehnt'
 */
export interface SemesterAuftrag {
  id: number;
  semester_id: number;
  auftrag_id: number;
  dozent_id: number;
  sws: number;
  status: 'beantragt' | 'genehmigt' | 'abgelehnt';
  anmerkung?: string;
  created_at: string;
  genehmigt_am?: string;

  // Populated by include_details
  auftrag?: Auftrag;
  dozent?: {
    id: number;
    name: string;
  };
  semester?: {
    id: number;
    kuerzel: string;
    bezeichnung: string;
  };
  beantragt_von?: {
    id: number;
    name: string;
  };
  genehmigt_von?: {
    id: number;
    name: string;
  };
}

/**
 * Request-Typen
 */

export interface BeantragAuftragData {
  auftrag_id: number;
  sws?: number; // Optional, sonst wird standard_sws verwendet
  anmerkung?: string;
}

export interface CreateAuftragData {
  name: string;
  standard_sws?: number;
  beschreibung?: string;
  sortierung?: number;
}

export interface UpdateAuftragData {
  name?: string;
  standard_sws?: number;
  beschreibung?: string;
  ist_aktiv?: boolean;
  sortierung?: number;
}

/**
 * Response-Typen
 */

export interface AuftraegeResponse {
  success: boolean;
  data: Auftrag[];
  message?: string;
}

export interface SemesterAuftraegeResponse {
  success: boolean;
  data: SemesterAuftrag[];
  message?: string;
}

export interface SingleSemesterAuftragResponse {
  success: boolean;
  data: SemesterAuftrag;
  message?: string;
}

export interface AuftragStatistik {
  gesamt: number;
  beantragt: number;
  genehmigt: number;
  abgelehnt: number;
  gesamt_sws_genehmigt: number;
}

/**
 * Wizard-Integration
 */

export interface PlanungMitAuftraegen {
  module_sws: number;
  auftraege_sws: number;
  gesamt_sws: number;
  auftraege: SemesterAuftrag[];
}
