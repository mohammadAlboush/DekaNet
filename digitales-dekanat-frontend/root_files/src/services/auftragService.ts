// services/auftragService.ts - Aufträge API Service

import api from './api'; // Use configured API client with JWT interceptor
import {
  Auftrag,
  SemesterAuftrag,
  BeantragAuftragData,
  CreateAuftragData,
  UpdateAuftragData,
  AuftraegeResponse,
  SemesterAuftraegeResponse,
  SingleSemesterAuftragResponse,
  AuftragStatistik
} from '../types/auftrag.types';

/**
 * Auftrag Service
 *
 * API-Client für Semesteraufträge (Feature 2)
 */

class AuftragService {
  private baseUrl = '/auftraege'; // Relative URL for configured API client

  // =========================================================================
  // MASTER-LISTE (Dekan-Verwaltung)
  // =========================================================================

  /**
   * Holt alle Aufträge aus Master-Liste
   */
  async getAlleAuftraege(nurAktive: boolean = true): Promise<Auftrag[]> {
    const response = await api.get<AuftraegeResponse>(this.baseUrl, {
      params: { nur_aktive: nurAktive }
    });
    return response.data.data;
  }

  /**
   * Erstellt neuen Auftrag (nur Dekan)
   */
  async createAuftrag(data: CreateAuftragData): Promise<Auftrag> {
    const response = await api.post<{ success: boolean; data: Auftrag }>(
      this.baseUrl,
      data
    );
    return response.data.data;
  }

  /**
   * Aktualisiert Auftrag (nur Dekan)
   */
  async updateAuftrag(id: number, data: UpdateAuftragData): Promise<Auftrag> {
    const response = await api.put<{ success: boolean; data: Auftrag }>(
      `${this.baseUrl}/${id}`,
      data
    );
    return response.data.data;
  }

  /**
   * Löscht Auftrag (nur Dekan)
   */
  async deleteAuftrag(id: number): Promise<void> {
    await api.delete(`${this.baseUrl}/${id}`);
  }

  // =========================================================================
  // SEMESTER-AUFTRÄGE (Professor & Dekan)
  // =========================================================================

  /**
   * Holt Aufträge für ein Semester
   */
  async getAuftraegeFuerSemester(
    semesterId: number,
    dozentId?: number,
    status?: 'beantragt' | 'genehmigt' | 'abgelehnt'
  ): Promise<SemesterAuftrag[]> {
    const response = await api.get<SemesterAuftraegeResponse>(
      `${this.baseUrl}/semester/${semesterId}`,
      {
        params: {
          dozent_id: dozentId,
          status
        }
      }
    );
    return response.data.data;
  }

  /**
   * Professor beantragt Auftrag
   */
  async beantrageAuftrag(
    semesterId: number,
    data: BeantragAuftragData
  ): Promise<SemesterAuftrag> {
    const response = await api.post<SingleSemesterAuftragResponse>(
      `${this.baseUrl}/semester/${semesterId}/beantragen`,
      data
    );
    return response.data.data;
  }

  /**
   * Dekan genehmigt Auftrag
   */
  async genehmigAuftrag(semesterAuftragId: number): Promise<SemesterAuftrag> {
    const response = await api.put<SingleSemesterAuftragResponse>(
      `${this.baseUrl}/semester-auftrag/${semesterAuftragId}/genehmigen`
    );
    return response.data.data;
  }

  /**
   * Dekan lehnt Auftrag ab
   */
  async lehneAuftragAb(
    semesterAuftragId: number,
    grund?: string
  ): Promise<SemesterAuftrag> {
    const response = await api.put<SingleSemesterAuftragResponse>(
      `${this.baseUrl}/semester-auftrag/${semesterAuftragId}/ablehnen`,
      { grund }
    );
    return response.data.data;
  }

  /**
   * Aktualisiert Semester-Auftrag (SWS/Anmerkung)
   */
  async updateSemesterAuftrag(
    semesterAuftragId: number,
    data: { sws?: number; anmerkung?: string }
  ): Promise<SemesterAuftrag> {
    const response = await api.put<SingleSemesterAuftragResponse>(
      `${this.baseUrl}/semester-auftrag/${semesterAuftragId}`,
      data
    );
    return response.data.data;
  }

  /**
   * Löscht Semester-Auftrag
   */
  async deleteSemesterAuftrag(semesterAuftragId: number): Promise<void> {
    await api.delete(`${this.baseUrl}/semester-auftrag/${semesterAuftragId}`);
  }

  // =========================================================================
  // HELPER ENDPOINTS
  // =========================================================================

  /**
   * Holt meine Aufträge (aktueller User)
   */
  async getMeineAuftraege(semesterId?: number): Promise<SemesterAuftrag[]> {
    const response = await api.get<SemesterAuftraegeResponse>(
      `${this.baseUrl}/meine`,
      {
        params: { semester_id: semesterId }
      }
    );
    return response.data.data;
  }

  /**
   * Holt alle beantragten Aufträge (Dekan-View)
   */
  async getBeantrageAuftraege(semesterId?: number): Promise<SemesterAuftrag[]> {
    const response = await api.get<SemesterAuftraegeResponse>(
      `${this.baseUrl}/beantragt`,
      {
        params: { semester_id: semesterId }
      }
    );
    return response.data.data;
  }

  /**
   * Holt Statistiken
   */
  async getStatistik(semesterId?: number): Promise<AuftragStatistik> {
    const response = await api.get<{ success: boolean; data: AuftragStatistik }>(
      `${this.baseUrl}/statistik`,
      {
        params: { semester_id: semesterId }
      }
    );
    return response.data.data;
  }

  // =========================================================================
  // HELPER METHODS
  // =========================================================================

  /**
   * Berechnet Gesamt-SWS aus genehmigten Aufträgen
   */
  berechneGesamtSWS(auftraege: SemesterAuftrag[]): number {
    return auftraege
      .filter(a => a.status === 'genehmigt')
      .reduce((sum, a) => sum + a.sws, 0);
  }

  /**
   * Gruppiert Aufträge nach Status
   */
  gruppiereNachStatus(auftraege: SemesterAuftrag[]): {
    beantragt: SemesterAuftrag[];
    genehmigt: SemesterAuftrag[];
    abgelehnt: SemesterAuftrag[];
  } {
    return {
      beantragt: auftraege.filter(a => a.status === 'beantragt'),
      genehmigt: auftraege.filter(a => a.status === 'genehmigt'),
      abgelehnt: auftraege.filter(a => a.status === 'abgelehnt')
    };
  }
}

// Singleton Instance
const auftragService = new AuftragService();
export default auftragService;
