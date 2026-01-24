import api, { ApiResponse, handleApiError } from './api';
import { createContextLogger } from '../utils/logger';

const log = createContextLogger('TemplateService');

/**
 * Template Types
 * ==============
 */

export interface TemplateModul {
  id: number;
  template_id: number;
  modul_id: number;
  po_id: number;
  modul?: {
    id: number;
    kuerzel: string;
    bezeichnung_de: string;
    leistungspunkte: number;
  };
  anzahl_vorlesungen: number;
  anzahl_uebungen: number;
  anzahl_praktika: number;
  anzahl_seminare: number;
  mitarbeiter_ids?: number[];
  anmerkungen?: string;
  raumbedarf?: string;
  raum_vorlesung?: string;
  raum_uebung?: string;
  raum_praktikum?: string;
  raum_seminar?: string;
  kapazitaet_vorlesung?: number;
  kapazitaet_uebung?: number;
  kapazitaet_praktikum?: number;
  kapazitaet_seminar?: number;
}

export interface WunschFreierTag {
  wochentag: string;
  zeitraum: string;
  prioritaet: string;
  grund?: string;
}

export interface PlanungsTemplate {
  id: number;
  benutzer_id: number;
  semester_typ: 'winter' | 'sommer';
  name?: string;
  beschreibung?: string;
  ist_aktiv: boolean;
  wunsch_freie_tage?: WunschFreierTag[];
  anmerkungen?: string;
  raumbedarf?: string;
  anzahl_module: number;
  template_module?: TemplateModul[];
  benutzer?: {
    id: number;
    username: string;
    name_komplett: string;
  };
  created_at?: string;
  updated_at?: string;
}

export interface CreateTemplateData {
  semester_typ: 'winter' | 'sommer';
  name?: string;
  beschreibung?: string;
}

export interface UpdateTemplateData {
  name?: string;
  beschreibung?: string;
  ist_aktiv?: boolean;
  wunsch_freie_tage?: WunschFreierTag[];
  anmerkungen?: string;
  raumbedarf?: string;
}

export interface AddTemplateModulData {
  modul_id: number;
  po_id: number;
  anzahl_vorlesungen?: number;
  anzahl_uebungen?: number;
  anzahl_praktika?: number;
  anzahl_seminare?: number;
  mitarbeiter_ids?: number[];
  anmerkungen?: string;
  raumbedarf?: string;
  raum_vorlesung?: string;
  raum_uebung?: string;
  raum_praktikum?: string;
  raum_seminar?: string;
  kapazitaet_vorlesung?: number;
  kapazitaet_uebung?: number;
  kapazitaet_praktikum?: number;
  kapazitaet_seminar?: number;
}

/**
 * Wizard Template Types
 * =====================
 * Extended types for wizard integration
 */

export interface MitarbeiterInfo {
  id: number;
  username: string;
  name: string;
}

export interface WizardTemplateModul extends TemplateModul {
  mitarbeiter?: MitarbeiterInfo[];
  invalid_mitarbeiter?: number[];
}

export interface InvalidModul {
  id: number;
  modul_id: number;
  reason: string;
}

export interface WizardTemplate {
  id: number;
  benutzer_id: number;
  semester_typ: 'winter' | 'sommer';
  name?: string;
  beschreibung?: string;
  ist_aktiv: boolean;
  wunsch_freie_tage?: WunschFreierTag[];
  anmerkungen?: string;
  raumbedarf?: string;
  valid_modules: WizardTemplateModul[];
  invalid_modules: InvalidModul[];
  has_invalid_modules: boolean;
  created_at?: string;
  updated_at?: string;
}

/**
 * Template Service
 * ================
 * Service für Planungs-Templates
 *
 * FEATURES:
 * - Template CRUD
 * - Modul-Management
 * - Template aus Planung erstellen
 * - Template auf Planung anwenden
 */

class TemplateService {
  // =========================================================================
  // TEMPLATE CRUD
  // =========================================================================

  /**
   * Holt alle eigenen Templates
   */
  async getAllTemplates(): Promise<ApiResponse<PlanungsTemplate[]>> {
    try {
      const response = await api.get<ApiResponse<PlanungsTemplate[]>>('/templates');
      return response.data;
    } catch (error) {
      log.error(' Error fetching templates:', error);
      throw new Error(handleApiError(error));
    }
  }

  /**
   * Holt ein Template nach ID
   */
  async getTemplate(id: number): Promise<ApiResponse<PlanungsTemplate>> {
    try {
      const response = await api.get<ApiResponse<PlanungsTemplate>>(`/templates/${id}`);
      return response.data;
    } catch (error) {
      log.error(' Error fetching template:', error);
      throw new Error(handleApiError(error));
    }
  }

  /**
   * Holt Template für Semestertyp
   */
  async getTemplateForSemester(semesterTyp: 'winter' | 'sommer'): Promise<ApiResponse<PlanungsTemplate | null>> {
    try {
      const response = await api.get<ApiResponse<PlanungsTemplate | null>>(`/templates/semester/${semesterTyp}`);
      return response.data;
    } catch (error) {
      log.error(' Error fetching template for semester:', error);
      throw new Error(handleApiError(error));
    }
  }

  /**
   * Holt Template mit validierten Modulen für den Wizard
   * Validiert ob Module noch existieren und löst Mitarbeiter-Namen auf
   */
  async getTemplateForWizard(semesterTyp: 'winter' | 'sommer'): Promise<ApiResponse<WizardTemplate | null>> {
    try {
      const response = await api.get<ApiResponse<WizardTemplate | null>>(`/templates/for-wizard/${semesterTyp}`);
      return response.data;
    } catch (error) {
      log.error(' Error fetching wizard template:', error);
      throw new Error(handleApiError(error));
    }
  }

  /**
   * Erstellt ein neues Template
   */
  async createTemplate(data: CreateTemplateData): Promise<ApiResponse<PlanungsTemplate>> {
    try {
      const response = await api.post<ApiResponse<PlanungsTemplate>>('/templates', data);
      return response.data;
    } catch (error) {
      log.error(' Error creating template:', error);
      throw new Error(handleApiError(error));
    }
  }

  /**
   * Aktualisiert ein Template
   */
  async updateTemplate(id: number, data: UpdateTemplateData): Promise<ApiResponse<PlanungsTemplate>> {
    try {
      const response = await api.put<ApiResponse<PlanungsTemplate>>(`/templates/${id}`, data);
      return response.data;
    } catch (error) {
      log.error(' Error updating template:', error);
      throw new Error(handleApiError(error));
    }
  }

  /**
   * Löscht ein Template
   */
  async deleteTemplate(id: number): Promise<ApiResponse<void>> {
    try {
      const response = await api.delete<ApiResponse<void>>(`/templates/${id}`);
      return response.data;
    } catch (error) {
      log.error(' Error deleting template:', error);
      throw new Error(handleApiError(error));
    }
  }

  // =========================================================================
  // MODUL MANAGEMENT
  // =========================================================================

  /**
   * Fügt ein Modul zum Template hinzu
   */
  async addModul(templateId: number, data: AddTemplateModulData): Promise<ApiResponse<TemplateModul>> {
    try {
      const response = await api.post<ApiResponse<TemplateModul>>(`/templates/${templateId}/modul`, data);
      return response.data;
    } catch (error) {
      log.error(' Error adding modul:', error);
      throw new Error(handleApiError(error));
    }
  }

  /**
   * Aktualisiert ein Modul im Template
   */
  async updateModul(templateId: number, modulId: number, data: Partial<AddTemplateModulData>): Promise<ApiResponse<TemplateModul>> {
    try {
      const response = await api.put<ApiResponse<TemplateModul>>(`/templates/${templateId}/modul/${modulId}`, data);
      return response.data;
    } catch (error) {
      log.error(' Error updating modul:', error);
      throw new Error(handleApiError(error));
    }
  }

  /**
   * Entfernt ein Modul aus dem Template
   */
  async removeModul(templateId: number, modulId: number): Promise<ApiResponse<void>> {
    try {
      const response = await api.delete<ApiResponse<void>>(`/templates/${templateId}/modul/${modulId}`);
      return response.data;
    } catch (error) {
      log.error(' Error removing modul:', error);
      throw new Error(handleApiError(error));
    }
  }

  // =========================================================================
  // TEMPLATE <-> PLANUNG KONVERTIERUNG
  // =========================================================================

  /**
   * Erstellt ein neues Template aus einer bestehenden Planung
   */
  async createFromPlanung(planungId: number, semesterTyp: 'winter' | 'sommer', name?: string): Promise<ApiResponse<PlanungsTemplate>> {
    try {
      const response = await api.post<ApiResponse<PlanungsTemplate>>('/templates/aus-planung', {
        planung_id: planungId,
        semester_typ: semesterTyp,
        name
      });
      return response.data;
    } catch (error) {
      log.error(' Error creating from planung:', error);
      throw new Error(handleApiError(error));
    }
  }

  /**
   * Aktualisiert bestehendes Template aus Planung
   */
  async updateFromPlanung(templateId: number, planungId: number): Promise<ApiResponse<PlanungsTemplate>> {
    try {
      const response = await api.post<ApiResponse<PlanungsTemplate>>(`/templates/${templateId}/aus-planung/${planungId}`);
      return response.data;
    } catch (error) {
      log.error(' Error updating from planung:', error);
      throw new Error(handleApiError(error));
    }
  }

  /**
   * Wendet Template auf Planung an
   */
  async applyToPlanung(templateId: number, planungId: number, clearExisting: boolean = false): Promise<ApiResponse<any>> {
    try {
      const response = await api.post<ApiResponse<any>>(`/templates/${templateId}/auf-planung/${planungId}`, {
        clear_existing: clearExisting
      });
      return response.data;
    } catch (error) {
      log.error(' Error applying to planung:', error);
      throw new Error(handleApiError(error));
    }
  }

  // =========================================================================
  // HELPER METHODS
  // =========================================================================

  /**
   * Ermittelt Semestertyp aus Semesterkürzel
   */
  getSemesterTypFromKuerzel(kuerzel: string): 'winter' | 'sommer' {
    if (!kuerzel) return 'winter';
    const lowered = kuerzel.toLowerCase();
    if (lowered.includes('ws') || lowered.includes('winter')) {
      return 'winter';
    }
    return 'sommer';
  }

  /**
   * Formatiert Semestertyp für Anzeige
   */
  formatSemesterTyp(typ: 'winter' | 'sommer'): string {
    return typ === 'winter' ? 'Wintersemester' : 'Sommersemester';
  }
}

// Singleton Instance
const templateService = new TemplateService();
export default templateService;
