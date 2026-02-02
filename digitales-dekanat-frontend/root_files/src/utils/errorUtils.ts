/**
 * Error Utilities
 * ================
 * Typsichere Fehlerbehandlung fuer TypeScript
 */

/**
 * Extrahiert eine lesbare Fehlermeldung aus einem unbekannten Error
 * @param error - Unbekannter Fehler (unknown type)
 * @param fallback - Fallback-Nachricht falls keine Meldung extrahiert werden kann
 * @returns Lesbare Fehlermeldung
 */
export function getErrorMessage(error: unknown, fallback = 'Ein Fehler ist aufgetreten'): string {
  if (error instanceof Error) {
    return error.message;
  }
  if (typeof error === 'string') {
    return error;
  }
  if (error && typeof error === 'object' && 'message' in error) {
    return String((error as { message: unknown }).message);
  }
  return fallback;
}

/**
 * Prueft ob ein Wert ein Error-Objekt ist
 * @param value - Zu pruefender Wert
 * @returns true wenn Error
 */
export function isError(value: unknown): value is Error {
  return value instanceof Error;
}

/**
 * Wrapper fuer async Funktionen mit Fehlerbehandlung
 * @param fn - Async Funktion
 * @param onError - Error Handler
 */
export async function tryCatch<T>(
  fn: () => Promise<T>,
  onError: (error: unknown) => void
): Promise<T | undefined> {
  try {
    return await fn();
  } catch (error) {
    onError(error);
    return undefined;
  }
}
