// services/deputatService.ts - Deputatsabrechnung API Service

import api from './api';
import {
  DeputatsEinstellungen,
  Deputatsabrechnung,
  DeputatsLehrtaetigkeit,
  DeputatsLehrexport,
  DeputatsVertretung,
  DeputatsErmaessigung,
  DeputatsBetreuung,
  DeputatStatistik,
  DeputatResponse,
  DeputatListResponse,
  DeputatImportResponse,
  CreateDeputatData,
  UpdateDeputatData,
  CreateLehrtaetigkeitData,
  UpdateLehrtaetigkeitData,
  CreateLehrexportData,
  UpdateLehrexportData,
  CreateVertretungData,
  UpdateVertretungData,
  CreateErmaessigungData,
  UpdateErmaessigungData,
  CreateBetreuungData,
  UpdateBetreuungData,
  UpdateEinstellungenData,
} from '../types/deputat.types';

/**
 * Deputat Service
 *
 * API-Client für Deputatsabrechnungen (Feature 4)
 */
class DeputatService {
  private baseUrl = '/deputat';

  // =========================================================================
  // EINSTELLUNGEN
  // =========================================================================

  /**
   * Holt aktuelle Einstellungen
   */
  async getEinstellungen(): Promise<DeputatsEinstellungen> {
    const response = await api.get<DeputatResponse<DeputatsEinstellungen>>(
      `${this.baseUrl}/einstellungen`
    );
    return response.data.data;
  }

  /**
   * Aktualisiert Einstellungen (nur Dekan)
   */
  async updateEinstellungen(data: UpdateEinstellungenData): Promise<DeputatsEinstellungen> {
    const response = await api.put<DeputatResponse<DeputatsEinstellungen>>(
      `${this.baseUrl}/einstellungen`,
      data
    );
    return response.data.data;
  }

  /**
   * Holt Einstellungen-Historie (nur Dekan)
   */
  async getEinstellungenHistorie(): Promise<DeputatsEinstellungen[]> {
    const response = await api.get<DeputatResponse<DeputatsEinstellungen[]>>(
      `${this.baseUrl}/einstellungen/historie`
    );
    return response.data.data;
  }

  // =========================================================================
  // DEPUTATSABRECHNUNG CRUD
  // =========================================================================

  /**
   * Holt eigene Abrechnungen
   */
  async getMeineAbrechnungen(planungsphaseId?: number): Promise<Deputatsabrechnung[]> {
    const response = await api.get<DeputatListResponse>(
      this.baseUrl,
      {
        params: { planungsphase_id: planungsphaseId }
      }
    );
    return response.data.data;
  }

  /**
   * Holt alle Abrechnungen (nur Dekan)
   */
  async getAlleAbrechnungen(
    planungsphaseId?: number,
    status?: string
  ): Promise<Deputatsabrechnung[]> {
    const response = await api.get<DeputatListResponse>(
      `${this.baseUrl}/alle`,
      {
        params: {
          planungsphase_id: planungsphaseId,
          status
        }
      }
    );
    return response.data.data;
  }

  /**
   * Holt eingereichte Abrechnungen (nur Dekan)
   */
  async getEingereichte(planungsphaseId?: number): Promise<Deputatsabrechnung[]> {
    const response = await api.get<DeputatListResponse>(
      `${this.baseUrl}/eingereicht`,
      {
        params: { planungsphase_id: planungsphaseId }
      }
    );
    return response.data.data;
  }

  /**
   * Erstellt oder holt Abrechnung
   */
  async getOrCreateAbrechnung(data: CreateDeputatData): Promise<Deputatsabrechnung> {
    const response = await api.post<DeputatResponse<Deputatsabrechnung>>(
      this.baseUrl,
      data
    );
    return response.data.data;
  }

  /**
   * Holt Abrechnung Details
   */
  async getAbrechnung(id: number): Promise<Deputatsabrechnung> {
    const response = await api.get<DeputatResponse<Deputatsabrechnung>>(
      `${this.baseUrl}/${id}`
    );
    return response.data.data;
  }

  /**
   * Aktualisiert Abrechnung
   */
  async updateAbrechnung(
    id: number,
    data: UpdateDeputatData
  ): Promise<Deputatsabrechnung> {
    const response = await api.put<DeputatResponse<Deputatsabrechnung>>(
      `${this.baseUrl}/${id}`,
      data
    );
    return response.data.data;
  }

  // =========================================================================
  // IMPORT
  // =========================================================================

  /**
   * Importiert aus Planung
   */
  async importPlanung(
    abrechnungId: number,
    ueberschreibeBestehende: boolean = false
  ): Promise<DeputatImportResponse['data']> {
    const response = await api.post<DeputatImportResponse>(
      `${this.baseUrl}/${abrechnungId}/import/planung`,
      { ueberschreibe_bestehende: ueberschreibeBestehende }
    );
    return response.data.data;
  }

  /**
   * Importiert aus Semesteraufträgen
   */
  async importSemesterauftraege(
    abrechnungId: number,
    ueberschreibeBestehende: boolean = false
  ): Promise<DeputatImportResponse['data']> {
    const response = await api.post<DeputatImportResponse>(
      `${this.baseUrl}/${abrechnungId}/import/semesterauftraege`,
      { ueberschreibe_bestehende: ueberschreibeBestehende }
    );
    return response.data.data;
  }

  // =========================================================================
  // LEHRTÄTIGKEITEN
  // =========================================================================

  /**
   * Fügt Lehrtätigkeit hinzu
   */
  async addLehrtaetigkeit(
    abrechnungId: number,
    data: CreateLehrtaetigkeitData
  ): Promise<DeputatsLehrtaetigkeit> {
    const response = await api.post<DeputatResponse<DeputatsLehrtaetigkeit>>(
      `${this.baseUrl}/${abrechnungId}/lehrtaetigkeit`,
      data
    );
    return response.data.data;
  }

  /**
   * Aktualisiert Lehrtätigkeit
   */
  async updateLehrtaetigkeit(
    lehrtaetigkeitId: number,
    data: UpdateLehrtaetigkeitData
  ): Promise<DeputatsLehrtaetigkeit> {
    const response = await api.put<DeputatResponse<DeputatsLehrtaetigkeit>>(
      `${this.baseUrl}/lehrtaetigkeit/${lehrtaetigkeitId}`,
      data
    );
    return response.data.data;
  }

  /**
   * Löscht Lehrtätigkeit
   */
  async deleteLehrtaetigkeit(lehrtaetigkeitId: number): Promise<void> {
    await api.delete(`${this.baseUrl}/lehrtaetigkeit/${lehrtaetigkeitId}`);
  }

  // =========================================================================
  // LEHREXPORT
  // =========================================================================

  /**
   * Fügt Lehrexport hinzu
   */
  async addLehrexport(
    abrechnungId: number,
    data: CreateLehrexportData
  ): Promise<DeputatsLehrexport> {
    const response = await api.post<DeputatResponse<DeputatsLehrexport>>(
      `${this.baseUrl}/${abrechnungId}/lehrexport`,
      data
    );
    return response.data.data;
  }

  /**
   * Aktualisiert Lehrexport
   */
  async updateLehrexport(
    lehrexportId: number,
    data: UpdateLehrexportData
  ): Promise<DeputatsLehrexport> {
    const response = await api.put<DeputatResponse<DeputatsLehrexport>>(
      `${this.baseUrl}/lehrexport/${lehrexportId}`,
      data
    );
    return response.data.data;
  }

  /**
   * Löscht Lehrexport
   */
  async deleteLehrexport(lehrexportId: number): Promise<void> {
    await api.delete(`${this.baseUrl}/lehrexport/${lehrexportId}`);
  }

  // =========================================================================
  // VERTRETUNGEN
  // =========================================================================

  /**
   * Fügt Vertretung hinzu
   */
  async addVertretung(
    abrechnungId: number,
    data: CreateVertretungData
  ): Promise<DeputatsVertretung> {
    const response = await api.post<DeputatResponse<DeputatsVertretung>>(
      `${this.baseUrl}/${abrechnungId}/vertretung`,
      data
    );
    return response.data.data;
  }

  /**
   * Aktualisiert Vertretung
   */
  async updateVertretung(
    vertretungId: number,
    data: UpdateVertretungData
  ): Promise<DeputatsVertretung> {
    const response = await api.put<DeputatResponse<DeputatsVertretung>>(
      `${this.baseUrl}/vertretung/${vertretungId}`,
      data
    );
    return response.data.data;
  }

  /**
   * Löscht Vertretung
   */
  async deleteVertretung(vertretungId: number): Promise<void> {
    await api.delete(`${this.baseUrl}/vertretung/${vertretungId}`);
  }

  // =========================================================================
  // ERMÄSSIGUNGEN
  // =========================================================================

  /**
   * Fügt Ermäßigung hinzu
   */
  async addErmaessigung(
    abrechnungId: number,
    data: CreateErmaessigungData
  ): Promise<DeputatsErmaessigung> {
    const response = await api.post<DeputatResponse<DeputatsErmaessigung>>(
      `${this.baseUrl}/${abrechnungId}/ermaessigung`,
      data
    );
    return response.data.data;
  }

  /**
   * Aktualisiert Ermäßigung
   */
  async updateErmaessigung(
    ermaessigungId: number,
    data: UpdateErmaessigungData
  ): Promise<DeputatsErmaessigung> {
    const response = await api.put<DeputatResponse<DeputatsErmaessigung>>(
      `${this.baseUrl}/ermaessigung/${ermaessigungId}`,
      data
    );
    return response.data.data;
  }

  /**
   * Löscht Ermäßigung
   */
  async deleteErmaessigung(ermaessigungId: number): Promise<void> {
    await api.delete(`${this.baseUrl}/ermaessigung/${ermaessigungId}`);
  }

  // =========================================================================
  // BETREUUNGEN
  // =========================================================================

  /**
   * Fügt Betreuung hinzu
   */
  async addBetreuung(
    abrechnungId: number,
    data: CreateBetreuungData
  ): Promise<DeputatsBetreuung> {
    const response = await api.post<DeputatResponse<DeputatsBetreuung>>(
      `${this.baseUrl}/${abrechnungId}/betreuung`,
      data
    );
    return response.data.data;
  }

  /**
   * Aktualisiert Betreuung
   */
  async updateBetreuung(
    betreuungId: number,
    data: UpdateBetreuungData
  ): Promise<DeputatsBetreuung> {
    const response = await api.put<DeputatResponse<DeputatsBetreuung>>(
      `${this.baseUrl}/betreuung/${betreuungId}`,
      data
    );
    return response.data.data;
  }

  /**
   * Löscht Betreuung
   */
  async deleteBetreuung(betreuungId: number): Promise<void> {
    await api.delete(`${this.baseUrl}/betreuung/${betreuungId}`);
  }

  // =========================================================================
  // WORKFLOW
  // =========================================================================

  /**
   * Reicht Abrechnung ein
   */
  async einreichen(abrechnungId: number): Promise<Deputatsabrechnung> {
    const response = await api.put<DeputatResponse<Deputatsabrechnung>>(
      `${this.baseUrl}/${abrechnungId}/einreichen`
    );
    return response.data.data;
  }

  /**
   * Genehmigt Abrechnung (nur Dekan)
   */
  async genehmigen(abrechnungId: number): Promise<Deputatsabrechnung> {
    const response = await api.put<DeputatResponse<Deputatsabrechnung>>(
      `${this.baseUrl}/${abrechnungId}/genehmigen`
    );
    return response.data.data;
  }

  /**
   * Lehnt Abrechnung ab (nur Dekan)
   */
  async ablehnen(abrechnungId: number, grund?: string): Promise<Deputatsabrechnung> {
    const response = await api.put<DeputatResponse<Deputatsabrechnung>>(
      `${this.baseUrl}/${abrechnungId}/ablehnen`,
      { grund }
    );
    return response.data.data;
  }

  /**
   * Setzt Abrechnung zurück
   */
  async zuruecksetzen(abrechnungId: number): Promise<Deputatsabrechnung> {
    const response = await api.put<DeputatResponse<Deputatsabrechnung>>(
      `${this.baseUrl}/${abrechnungId}/zuruecksetzen`
    );
    return response.data.data;
  }

  // =========================================================================
  // STATISTIK
  // =========================================================================

  /**
   * Holt Statistiken (nur Dekan)
   */
  async getStatistik(planungsphaseId?: number): Promise<DeputatStatistik> {
    const response = await api.get<DeputatResponse<DeputatStatistik>>(
      `${this.baseUrl}/statistik`,
      {
        params: { planungsphase_id: planungsphaseId }
      }
    );
    return response.data.data;
  }

  // =========================================================================
  // HELPER METHODS
  // =========================================================================

  /**
   * Prüft ob Abrechnung bearbeitet werden kann
   */
  kannBearbeitetWerden(abrechnung: Deputatsabrechnung): boolean {
    return ['entwurf', 'abgelehnt'].includes(abrechnung.status);
  }

  /**
   * Prüft ob Abrechnung eingereicht werden kann
   */
  kannEingereichtWerden(abrechnung: Deputatsabrechnung): boolean {
    return abrechnung.status === 'entwurf';
  }

  /**
   * Prüft ob Abrechnung genehmigt werden kann
   */
  kannGenehmigtWerden(abrechnung: Deputatsabrechnung): boolean {
    return abrechnung.status === 'eingereicht';
  }

  /**
   * Berechnet Gesamtzahl der Einträge
   */
  getGesamtAnzahl(abrechnung: Deputatsabrechnung): number {
    const summen = abrechnung.summen;
    if (!summen) return 0;

    return (
      summen.anzahl_lehrtaetigkeiten +
      summen.anzahl_lehrexporte +
      summen.anzahl_vertretungen +
      summen.anzahl_ermaessigungen +
      summen.anzahl_betreuungen
    );
  }

  /**
   * Gibt Farbe für Bewertung zurück
   */
  getBewertungColor(bewertung: string): 'success' | 'warning' | 'error' {
    switch (bewertung) {
      case 'erfuellt':
        return 'success';
      case 'abweichung':
        return 'warning';
      case 'starke_abweichung':
        return 'error';
      default:
        return 'warning';
    }
  }

  /**
   * Gibt Text für Bewertung zurück
   */
  getBewertungText(bewertung: string): string {
    switch (bewertung) {
      case 'erfuellt':
        return 'Erfüllt';
      case 'abweichung':
        return 'Leichte Abweichung';
      case 'starke_abweichung':
        return 'Starke Abweichung';
      default:
        return 'Unbekannt';
    }
  }

  // =========================================================================
  // PDF EXPORT
  // =========================================================================

  /**
   * Exportiert Abrechnung als PDF
   */
  async exportPdf(abrechnungId: number): Promise<Blob> {
    const response = await api.get(
      `${this.baseUrl}/${abrechnungId}/pdf`,
      { responseType: 'blob' }
    );
    return response.data;
  }

  /**
   * Lädt PDF herunter
   */
  async downloadPdf(abrechnungId: number, filename?: string): Promise<void> {
    try {
      const blob = await this.exportPdf(abrechnungId);

      // Create download link
      const url = window.URL.createObjectURL(blob);
      const link = document.createElement('a');
      link.href = url;
      link.download = filename || `Deputatsabrechnung_${abrechnungId}.pdf`;

      // Trigger download
      document.body.appendChild(link);
      link.click();

      // Cleanup
      document.body.removeChild(link);
      window.URL.revokeObjectURL(url);
    } catch (error) {
      console.error('PDF Download Error:', error);
      throw error;
    }
  }
}

// Singleton Instance
const deputatService = new DeputatService();
export default deputatService;
