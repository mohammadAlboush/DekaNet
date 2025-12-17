// types/modul_types.ts - FINALE KORRIGIERTE VERSION
// ✅ Kompatibel mit Wizard UND Module.tsx

export interface Modul {
  id: number;
  kuerzel: string;
  po_id: number;
  bezeichnung_de: string;
  bezeichnung_en?: string;
  untertitel?: string;
  leistungspunkte?: number;
  turnus?: string;
  sws_gesamt?: number;
  gruppengroesse?: string;
  teilnehmerzahl?: string;
  anmeldemodalitaeten?: string;
  
  // ✅ Für Wizard: Filter und SWS-Berechnung
  lehrformen?: ModulLehrform[];
  dozenten?: ModulDozent[];
  
  // Optional: Weitere Details
  literatur?: ModulLiteratur[];
  studiengaenge?: ModulStudiengang[];
  sprachen?: ModulSprache[];
  abhaengigkeiten?: ModulAbhaengigkeit[];
  pruefung?: ModulPruefung | null;
  lernergebnisse?: ModulLernergebnisse | null;
  voraussetzungen?: ModulVoraussetzungen | null;
  arbeitsaufwand?: ModulArbeitsaufwand[];  // ✅ KORRIGIERT: Array statt single object
  seiten?: any[];
}

export interface ModulLehrform {
  id: number;
  lehrform_id: number;
  bezeichnung: string;
  kuerzel: string;
  sws: number;
}

export interface ModulDozent {
  id: number;
  dozent_id: number;
  name_komplett?: string;
  name_kurz?: string;
  vorname?: string;
  nachname?: string;
  rolle: 'verantwortlicher' | 'lehrperson';
}

export interface ModulLiteratur {
  id: number;
  titel: string;
  autoren?: string;
  verlag?: string;
  jahr?: number;
  isbn?: string;
  typ?: string;
  pflichtliteratur?: boolean;
  sortierung?: number;
}

export interface ModulPruefung {
  pruefungsform?: string;
  pruefungsdauer_minuten?: number;
  pruefungsleistungen?: string;
  benotung?: string;
}

export interface ModulLernergebnisse {
  lernziele?: string;
  kompetenzen?: string;
  inhalt?: string;
}

export interface ModulVoraussetzungen {
  formal?: string;
  empfohlen?: string;
  inhaltlich?: string;
}

export interface ModulArbeitsaufwand {
  kontaktzeit_stunden?: number;
  selbststudium_stunden?: number;
  pruefungsvorbereitung_stunden?: number;
  gesamt_stunden?: number;
}

export interface ModulStudiengang {
  id: number;
  studiengang_id: number;
  bezeichnung: string;
  kuerzel?: string;
  semester?: number;
  pflicht?: boolean;
  wahlpflicht?: boolean;
}

export interface ModulSprache {
  id: number;
  bezeichnung: string;
}

export interface ModulAbhaengigkeit {
  id: number;
  voraussetzung_modul_id: number;
  voraussetzung_kuerzel: string;
  voraussetzung_name: string;
  typ: string;
}

export interface ModulDetails extends Modul {
  lehrformen: ModulLehrform[];
  dozenten: ModulDozent[];
  literatur: ModulLiteratur[];
  studiengaenge: ModulStudiengang[];
  sprachen: ModulSprache[];
  abhaengigkeiten: ModulAbhaengigkeit[];
  pruefung?: ModulPruefung | null;
  lernergebnisse?: ModulLernergebnisse | null;
  voraussetzungen?: ModulVoraussetzungen | null;
  arbeitsaufwand: ModulArbeitsaufwand[];  // ✅ KORRIGIERT: Array
  seiten?: any[];
}

// Legacy exports for backwards compatibility
export type Lehrform = ModulLehrform;
export type Dozent = ModulDozent;