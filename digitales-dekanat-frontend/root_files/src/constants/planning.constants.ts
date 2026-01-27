/**
 * Planning Constants
 * ==================
 *
 * Zentrale Konstanten für das Planungs- und Template-System.
 * Verhindert hardcodierte Werte in Komponenten.
 */

/**
 * Standard-Kapazitäten pro Lehrform
 * Diese Werte werden verwendet, wenn keine spezifischen Kapazitäten definiert sind.
 */
export const DEFAULT_CAPACITIES = {
  vorlesung: 30,
  uebung: 20,
  praktikum: 15,
  seminar: 20,
} as const;

/**
 * Multiplikator-Limits für Lehrformen
 * Definiert Warn- und Maximalgrenzen für Multiplikatoren.
 */
export const MULTIPLIKATOR_LIMITS = {
  /** Maximale Eingabe für Multiplikatoren */
  maxInput: 10,
  /** Ab dieser Gesamtzahl wird eine Warnung angezeigt */
  warningThreshold: 10,
  /** Ab dieser Anzahl Vorlesungen wird eine Warnung angezeigt */
  vorlesungWarning: 5,
  /** Ab dieser Anzahl Übungen wird eine Warnung angezeigt */
  uebungWarning: 5,
} as const;

/**
 * Performance-Limits
 * Definiert Grenzen für Performance-Optimierungen.
 */
export const PERFORMANCE_LIMITS = {
  /** Maximale Anzahl Module in Dropdown-Vorschlägen */
  maxModuleSuggestions: 20,
  /** Maximale Anzahl Dozenten in einer Liste */
  maxDozentDisplay: 50,
} as const;

/**
 * Lehrform-Kürzel
 * Standard-Kürzel für die verschiedenen Lehrformen.
 */
export const LEHRFORM_KUERZEL = {
  vorlesung: 'V',
  uebung: 'Ü',
  praktikum: 'P',
  seminar: 'S',
} as const;

/**
 * UI-Konstanten für Formulare
 */
export const FORM_CONSTANTS = {
  /** Höhe eines Menü-Items in Pixeln */
  ITEM_HEIGHT: 48,
  /** Padding oben für Menü-Items */
  ITEM_PADDING_TOP: 8,
} as const;

/**
 * Status-Werte für Planung
 */
export const PLANUNG_STATUS = {
  ENTWURF: 'entwurf',
  EINGEREICHT: 'eingereicht',
  FREIGEGEBEN: 'freigegeben',
  ABGELEHNT: 'abgelehnt',
} as const;

/**
 * Semester-Typen
 */
export const SEMESTER_TYPEN = {
  WINTER: 'winter',
  SOMMER: 'sommer',
} as const;

export type SemesterTyp = typeof SEMESTER_TYPEN[keyof typeof SEMESTER_TYPEN];
export type PlanungStatus = typeof PLANUNG_STATUS[keyof typeof PLANUNG_STATUS];
