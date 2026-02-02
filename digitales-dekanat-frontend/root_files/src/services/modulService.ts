import api, { ApiResponse, handleApiError } from './api';
import { Modul, ModulDetails } from '../types/modul.types';
import { createContextLogger } from '../utils/logger';

const log = createContextLogger('ModulService');

/**
 * Modul Service - VOLLSTÄNDIG ERWEITERTER SERVICE
 * ================================================
 * Unterstützt Bearbeitung aller Modul-Daten
 */

// In-Memory Cache für statische Optionen
interface CacheEntry<T> {
  data: T;
  timestamp: number;
}

// Cache-Typen
interface LehrformOption {
  id: number;
  kuerzel: string;
  bezeichnung: string;
}

interface DozentOption {
  id: number;
  name_komplett: string;
  kuerzel?: string;
}

interface StudiengangOption {
  id: number;
  bezeichnung: string;
  kuerzel?: string;
}

type CacheData = LehrformOption[] | DozentOption[] | StudiengangOption[];

const optionsCache: {
  lehrformen?: CacheEntry<LehrformOption[]>;
  dozenten?: CacheEntry<DozentOption[]>;
  studiengaenge?: CacheEntry<StudiengangOption[]>;
} = {};

const CACHE_TTL = 5 * 60 * 1000; // 5 Minuten Cache-TTL

function getCached<T extends CacheData>(key: keyof typeof optionsCache): T | null {
  const entry = optionsCache[key];
  if (entry && (Date.now() - entry.timestamp) < CACHE_TTL) {
    return entry.data as T;
  }
  return null;
}

function setCache(key: 'lehrformen', data: LehrformOption[]): void;
function setCache(key: 'dozenten', data: DozentOption[]): void;
function setCache(key: 'studiengaenge', data: StudiengangOption[]): void;
function setCache(key: keyof typeof optionsCache, data: CacheData): void {
  if (key === 'lehrformen') {
    optionsCache.lehrformen = { data: data as LehrformOption[], timestamp: Date.now() };
  } else if (key === 'dozenten') {
    optionsCache.dozenten = { data: data as DozentOption[], timestamp: Date.now() };
  } else if (key === 'studiengaenge') {
    optionsCache.studiengaenge = { data: data as StudiengangOption[], timestamp: Date.now() };
  }
}

export interface ModulCreateData {
  kuerzel: string;
  po_id: number;
  bezeichnung_de: string;
  bezeichnung_en?: string;
  untertitel?: string;
  leistungspunkte?: number;
  turnus?: string;
  gruppengroesse?: string;
  teilnehmerzahl?: string;
  anmeldemodalitaeten?: string;
}

export interface ModulUpdateData {
  bezeichnung_de?: string;
  bezeichnung_en?: string;
  untertitel?: string;
  leistungspunkte?: number;
  turnus?: string;
  gruppengroesse?: string;
  teilnehmerzahl?: string;
  anmeldemodalitaeten?: string;
}

export interface LehrformData {
  lehrform_id: number;
  sws: number;
}

export interface DozentData {
  dozent_id: number;
  rolle: 'verantwortlicher' | 'lehrperson';
}

export interface LiteraturData {
  titel: string;
  autoren?: string;
  verlag?: string;
  jahr?: number;
  isbn?: string;
  typ?: string;
  pflichtliteratur?: boolean;
  sortierung?: number;
}

export interface PruefungData {
  pruefungsform?: string;
  pruefungsdauer_minuten?: number;
  pruefungsleistungen?: string;
  benotung?: string;
}

export interface LernergebnisseData {
  lernziele?: string;
  kompetenzen?: string;
  inhalt?: string;
}

export interface VoraussetzungenData {
  formal?: string;
  empfohlen?: string;
  inhaltlich?: string;
}

export interface ArbeitsaufwandData {
  kontaktzeit_stunden?: number;
  selbststudium_stunden?: number;
  pruefungsvorbereitung_stunden?: number;
  gesamt_stunden?: number;
}

class ModulService {
  /**
   * Get all modules (einfache Version)
   */
  async getAllModule(): Promise<Modul[]> {
    try {
      const response = await api.get<ApiResponse<Modul[]>>('/module/');
      return response.data.data || [];
    } catch (error) {
      log.error(' Error fetching modules:', error);
      return [];
    }
  }

  /**
   * Get all modules (mit params)
   */
  async getAllModules(params?: {
    po_id?: number;
    turnus?: string;
    search?: string;
    page?: number;
    per_page?: number;
  }): Promise<ApiResponse<Modul[]>> {
    try {
      log.debug(' Fetching modules with params:', params);
      
      const queryParams = new URLSearchParams();
      
      if (params?.po_id) {
        queryParams.append('po_id', params.po_id.toString());
      }
      if (params?.turnus) {
        queryParams.append('turnus', params.turnus);
      }
      if (params?.search) {
        queryParams.append('search', params.search);
      }
      if (params?.page) {
        queryParams.append('page', params.page.toString());
      }
      if (params?.per_page) {
        queryParams.append('per_page', params.per_page.toString());
      }
      
      const url = `/module/${queryParams.toString() ? `?${queryParams}` : ''}`;
      log.debug(' Request URL:', url);
      
      const response = await api.get<ApiResponse<Modul[]>>(url);
      
      log.debug(' Response:', {
        success: response.data.success,
        dataLength: response.data.data?.length || 0
      });
      
      return response.data;
    } catch (error) {
      log.error(' Error fetching modules:', error);
      throw new Error(handleApiError(error));
    }
  }

  /**
   * Get module details
   */
  async getModulDetails(id: number): Promise<ApiResponse<ModulDetails>> {
    try {
      log.debug(' Fetching details for module:', id);
      
      const response = await api.get<ApiResponse<ModulDetails>>(`/module/${id}`);
      
      log.debug(' Module details received');
      return response.data;
    } catch (error) {
      log.error(' Error fetching module details:', error);
      throw new Error(handleApiError(error));
    }
  }

  /**
   * Get module dozenten
   */
  async getModulDozenten(id: number, rolle?: string): Promise<ApiResponse<any[]>> {
    try {
      log.debug(' Fetching dozenten for module:', id);
      
      const url = rolle 
        ? `/module/${id}/dozenten?rolle=${rolle}`
        : `/module/${id}/dozenten`;
      
      const response = await api.get<ApiResponse<any[]>>(url);
      
      log.debug(' Dozenten received:', response.data.data?.length || 0);
      return response.data;
    } catch (error) {
      log.error(' Error fetching dozenten:', error);
      throw new Error(handleApiError(error));
    }
  }

  /**
   * Get module lehrformen
   */
  async getModulLehrformen(id: number): Promise<ApiResponse<any[]>> {
    try {
      log.debug(' Fetching lehrformen for module:', id);
      
      const response = await api.get<ApiResponse<any[]>>(`/module/${id}/lehrformen`);
      
      log.debug(' Lehrformen received:', response.data.data?.length || 0);
      return response.data;
    } catch (error) {
      log.error(' Error fetching lehrformen:', error);
      throw new Error(handleApiError(error));
    }
  }

  /**
   * Search modules
   */
  async searchModules(query: string, po_id?: number): Promise<ApiResponse<Modul[]>> {
    try {
      log.debug(' Searching modules with query:', query);
      
      const params = new URLSearchParams({ q: query });
      if (po_id) {
        params.append('po_id', po_id.toString());
      }
      
      const response = await api.get<ApiResponse<Modul[]>>(`/module/search?${params}`);
      
      log.debug(' Search results:', response.data.data?.length || 0);
      return response.data;
    } catch (error) {
      log.error(' Error searching modules:', error);
      throw new Error(handleApiError(error));
    }
  }

  /**
   * Get module statistics
   */
  async getStatistik(po_id?: number): Promise<ApiResponse<any>> {
    try {
      log.debug(' Fetching statistics');
      
      const url = po_id 
        ? `/module/statistik?po_id=${po_id}`
        : '/module/statistik';
      
      const response = await api.get<ApiResponse<any>>(url);
      
      log.debug(' Statistics received');
      return response.data;
    } catch (error) {
      log.error(' Error fetching statistics:', error);
      throw new Error(handleApiError(error));
    }
  }

  /**
   * Create module (Dekan only)
   */
  async createModule(data: ModulCreateData): Promise<ApiResponse<Modul>> {
    try {
      log.debug(' Creating module:', data.kuerzel);
      
      const response = await api.post<ApiResponse<Modul>>('/module/', data);
      
      log.debug(' ✓ Module created:', response.data.data?.id);
      return response.data;
    } catch (error) {
      log.error(' Error creating module:', error);
      throw new Error(handleApiError(error));
    }
  }

  /**
   * Update module (Dekan only)
   */
  async updateModule(id: number, data: ModulUpdateData): Promise<ApiResponse<Modul>> {
    try {
      log.debug(' Updating module:', id);
      
      const response = await api.put<ApiResponse<Modul>>(`/module/${id}`, data);
      
      log.debug(' ✓ Module updated');
      return response.data;
    } catch (error) {
      log.error(' Error updating module:', error);
      throw new Error(handleApiError(error));
    }
  }

  /**
   * Delete module (Dekan only)
   */
  async deleteModule(id: number, force: boolean = false): Promise<ApiResponse> {
    try {
      log.debug(' Deleting module:', id, 'force:', force);
      
      const response = await api.delete<ApiResponse>(`/module/${id}?force=${force}`);
      
      log.debug(' ✓ Module deleted');
      return response.data;
    } catch (error) {
      log.error(' Error deleting module:', error);
      throw new Error(handleApiError(error));
    }
  }

  // =========================================================================
  // LEHRFORMEN
  // =========================================================================

  /**
   * Add lehrform to module
   */
  async addLehrform(modulId: number, data: LehrformData): Promise<ApiResponse> {
    try {
      log.debug(' Adding lehrform to module:', modulId);
      
      const response = await api.post<ApiResponse>(`/module/${modulId}/lehrformen`, data);
      
      log.debug(' ✓ Lehrform added');
      return response.data;
    } catch (error) {
      log.error(' Error adding lehrform:', error);
      throw new Error(handleApiError(error));
    }
  }

  /**
   * Update lehrform SWS
   */
  async updateLehrform(modulId: number, lehrformZuordnungId: number, sws: number): Promise<ApiResponse> {
    try {
      log.debug(' Updating lehrform:', lehrformZuordnungId);
      
      const response = await api.put<ApiResponse>(
        `/module/${modulId}/lehrformen/${lehrformZuordnungId}`,
        { sws }
      );
      
      log.debug(' ✓ Lehrform updated');
      return response.data;
    } catch (error) {
      log.error(' Error updating lehrform:', error);
      throw new Error(handleApiError(error));
    }
  }

  /**
   * Delete lehrform from module
   */
  async deleteLehrform(modulId: number, lehrformZuordnungId: number): Promise<ApiResponse> {
    try {
      log.debug(' Deleting lehrform:', lehrformZuordnungId);
      
      const response = await api.delete<ApiResponse>(
        `/module/${modulId}/lehrformen/${lehrformZuordnungId}`
      );
      
      log.debug(' ✓ Lehrform deleted');
      return response.data;
    } catch (error) {
      log.error(' Error deleting lehrform:', error);
      throw new Error(handleApiError(error));
    }
  }

  // =========================================================================
  // DOZENTEN
  // =========================================================================

  /**
   * Add dozent to module
   */
  async addDozent(modulId: number, data: DozentData): Promise<ApiResponse> {
    try {
      log.debug(' Adding dozent to module:', modulId);
      
      const response = await api.post<ApiResponse>(`/module/${modulId}/dozenten`, data);
      
      log.debug(' ✓ Dozent added');
      return response.data;
    } catch (error) {
      log.error(' Error adding dozent:', error);
      throw new Error(handleApiError(error));
    }
  }

  /**
   * Update dozent rolle
   */
  async updateDozent(modulId: number, dozentZuordnungId: number, rolle: string): Promise<ApiResponse> {
    try {
      log.debug(' Updating dozent:', dozentZuordnungId);
      
      const response = await api.put<ApiResponse>(
        `/module/${modulId}/dozenten/${dozentZuordnungId}`,
        { rolle }
      );
      
      log.debug(' ✓ Dozent updated');
      return response.data;
    } catch (error) {
      log.error(' Error updating dozent:', error);
      throw new Error(handleApiError(error));
    }
  }

  /**
   * Delete dozent from module
   */
  async deleteDozent(modulId: number, dozentZuordnungId: number): Promise<ApiResponse> {
    try {
      log.debug(' Deleting dozent:', dozentZuordnungId);

      const response = await api.delete<ApiResponse>(
        `/module/${modulId}/dozenten/${dozentZuordnungId}`
      );

      log.debug(' ✓ Dozent deleted');
      return response.data;
    } catch (error) {
      log.error(' Error deleting dozent:', error);
      throw new Error(handleApiError(error));
    }
  }

  /**
   * Update dozent rolle
   */
  async updateDozentRolle(modulId: number, dozentZuordnungId: number, rolle: string): Promise<ApiResponse> {
    try {
      log.debug(' Updating dozent rolle:', dozentZuordnungId, rolle);

      const response = await api.put<ApiResponse>(
        `/module/${modulId}/dozenten/${dozentZuordnungId}`,
        { rolle }
      );

      log.debug(' ✓ Dozent rolle updated');
      return response.data;
    } catch (error) {
      log.error(' Error updating dozent rolle:', error);
      throw new Error(handleApiError(error));
    }
  }

  /**
   * Replace dozent with another dozent (keeps the same role)
   */
  async replaceDozent(modulId: number, oldDozentZuordnungId: number, newDozentId: number): Promise<ApiResponse> {
    try {
      log.debug(' Replacing dozent:', oldDozentZuordnungId, 'with', newDozentId);

      const response = await api.put<ApiResponse>(
        `/module/${modulId}/dozenten/${oldDozentZuordnungId}/replace`,
        { neuer_dozent_id: newDozentId }
      );

      log.debug(' ✓ Dozent replaced');
      return response.data;
    } catch (error) {
      log.error(' Error replacing dozent:', error);
      throw new Error(handleApiError(error));
    }
  }

  // =========================================================================
  // LITERATUR
  // =========================================================================

  /**
   * Add literatur to module
   */
  async addLiteratur(modulId: number, data: LiteraturData): Promise<ApiResponse> {
    try {
      log.debug(' Adding literatur to module:', modulId);
      
      const response = await api.post<ApiResponse>(`/module/${modulId}/literatur`, data);
      
      log.debug(' ✓ Literatur added');
      return response.data;
    } catch (error) {
      log.error(' Error adding literatur:', error);
      throw new Error(handleApiError(error));
    }
  }

  /**
   * Update literatur
   */
  async updateLiteratur(modulId: number, literaturId: number, data: LiteraturData): Promise<ApiResponse> {
    try {
      log.debug(' Updating literatur:', literaturId);
      
      const response = await api.put<ApiResponse>(
        `/module/${modulId}/literatur/${literaturId}`,
        data
      );
      
      log.debug(' ✓ Literatur updated');
      return response.data;
    } catch (error) {
      log.error(' Error updating literatur:', error);
      throw new Error(handleApiError(error));
    }
  }

  /**
   * Delete literatur from module
   */
  async deleteLiteratur(modulId: number, literaturId: number): Promise<ApiResponse> {
    try {
      log.debug(' Deleting literatur:', literaturId);
      
      const response = await api.delete<ApiResponse>(
        `/module/${modulId}/literatur/${literaturId}`
      );
      
      log.debug(' ✓ Literatur deleted');
      return response.data;
    } catch (error) {
      log.error(' Error deleting literatur:', error);
      throw new Error(handleApiError(error));
    }
  }

  // =========================================================================
  // PRÜFUNG
  // =========================================================================

  /**
   * Update pruefung
   */
  async updatePruefung(modulId: number, data: PruefungData): Promise<ApiResponse> {
    try {
      log.debug(' Updating pruefung for module:', modulId);
      
      const response = await api.put<ApiResponse>(`/module/${modulId}/pruefung`, data);
      
      log.debug(' ✓ Pruefung updated');
      return response.data;
    } catch (error) {
      log.error(' Error updating pruefung:', error);
      throw new Error(handleApiError(error));
    }
  }

  // =========================================================================
  // LERNERGEBNISSE
  // =========================================================================

  /**
   * Update lernergebnisse
   */
  async updateLernergebnisse(modulId: number, data: LernergebnisseData): Promise<ApiResponse> {
    try {
      log.debug(' Updating lernergebnisse for module:', modulId);
      
      const response = await api.put<ApiResponse>(`/module/${modulId}/lernergebnisse`, data);
      
      log.debug(' ✓ Lernergebnisse updated');
      return response.data;
    } catch (error) {
      log.error(' Error updating lernergebnisse:', error);
      throw new Error(handleApiError(error));
    }
  }

  // =========================================================================
  // VORAUSSETZUNGEN
  // =========================================================================

  /**
   * Update voraussetzungen
   */
  async updateVoraussetzungen(modulId: number, data: VoraussetzungenData): Promise<ApiResponse> {
    try {
      log.debug(' Updating voraussetzungen for module:', modulId);
      
      const response = await api.put<ApiResponse>(`/module/${modulId}/voraussetzungen`, data);
      
      log.debug(' ✓ Voraussetzungen updated');
      return response.data;
    } catch (error) {
      log.error(' Error updating voraussetzungen:', error);
      throw new Error(handleApiError(error));
    }
  }

  // =========================================================================
  // ARBEITSAUFWAND
  // =========================================================================

  /**
   * Update arbeitsaufwand
   */
  async updateArbeitsaufwand(modulId: number, data: ArbeitsaufwandData): Promise<ApiResponse> {
    try {
      log.debug(' Updating arbeitsaufwand for module:', modulId);
      
      const response = await api.put<ApiResponse>(`/module/${modulId}/arbeitsaufwand`, data);
      
      log.debug(' ✓ Arbeitsaufwand updated');
      return response.data;
    } catch (error) {
      log.error(' Error updating arbeitsaufwand:', error);
      throw new Error(handleApiError(error));
    }
  }

  // =========================================================================
  // OPTIONS (HILFSLISTEN) - MIT CACHING
  // =========================================================================

  /**
   * Get all lehrformen for selection (cached for 5 minutes)
   */
  async getLehrformenOptions(): Promise<ApiResponse<any[]>> {
    // Check cache first
    const cached = getCached<any[]>('lehrformen');
    if (cached) {
      log.debug(' Returning cached lehrformen');
      return { success: true, data: cached };
    }

    try {
      const response = await api.get<ApiResponse<any[]>>('/module/options/lehrformen');
      // Store in cache
      if (response.data.success && response.data.data) {
        setCache('lehrformen', response.data.data);
      }
      return response.data;
    } catch (error) {
      throw new Error(handleApiError(error));
    }
  }

  /**
   * Get all dozenten for selection (cached for 5 minutes)
   */
  async getDozentenOptions(): Promise<ApiResponse<any[]>> {
    // Check cache first
    const cached = getCached<any[]>('dozenten');
    if (cached) {
      log.debug(' Returning cached dozenten');
      return { success: true, data: cached };
    }

    try {
      const response = await api.get<ApiResponse<any[]>>('/module/options/dozenten');
      // Store in cache
      if (response.data.success && response.data.data) {
        setCache('dozenten', response.data.data);
      }
      return response.data;
    } catch (error) {
      throw new Error(handleApiError(error));
    }
  }

  /**
   * Get all studiengaenge for selection (cached for 5 minutes)
   */
  async getStudiengaengeOptions(): Promise<ApiResponse<any[]>> {
    // Check cache first
    const cached = getCached<any[]>('studiengaenge');
    if (cached) {
      log.debug(' Returning cached studiengaenge');
      return { success: true, data: cached };
    }

    try {
      const response = await api.get<ApiResponse<any[]>>('/module/options/studiengaenge');
      // Store in cache
      if (response.data.success && response.data.data) {
        setCache('studiengaenge', response.data.data);
      }
      return response.data;
    } catch (error) {
      throw new Error(handleApiError(error));
    }
  }

  /**
   * Clear options cache (call after data changes)
   */
  clearOptionsCache(): void {
    optionsCache.lehrformen = undefined;
    optionsCache.dozenten = undefined;
    optionsCache.studiengaenge = undefined;
    log.debug(' Options cache cleared');
  }
}

// Export singleton instance
export default new ModulService();