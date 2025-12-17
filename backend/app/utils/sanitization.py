"""
Input Sanitization Utilities
=============================
Utilities für sichere Input-Verarbeitung und XSS-Prävention.
"""

import bleach
from typing import Optional


# Erlaubte HTML-Tags für Rich-Text-Felder (falls später benötigt)
ALLOWED_TAGS = []  # Keine HTML-Tags erlaubt
ALLOWED_ATTRIBUTES = {}

# Strikte Einstellungen: Alle HTML-Tags entfernen
BLEACH_SETTINGS = {
    'tags': ALLOWED_TAGS,
    'attributes': ALLOWED_ATTRIBUTES,
    'strip': True,  # Tags entfernen statt escapen
}


def sanitize_text(text: Optional[str], max_length: Optional[int] = None) -> str:
    """
    Bereinigt Text-Input von potenziell gefährlichem HTML/JavaScript.

    Args:
        text: Der zu bereinigende Text
        max_length: Optionale maximale Länge

    Returns:
        Bereinigter Text ohne HTML-Tags

    Examples:
        >>> sanitize_text("<script>alert('XSS')</script>Hello")
        "alert('XSS')Hello"

        >>> sanitize_text("Normal text with <b>bold</b>")
        "Normal text with bold"

        >>> sanitize_text("  Whitespace test  ")
        "Whitespace test"
    """
    if not text:
        return ""

    # HTML-Tags entfernen
    cleaned = bleach.clean(text, **BLEACH_SETTINGS)

    # Whitespace normalisieren
    cleaned = " ".join(cleaned.split())

    # Länge begrenzen falls angegeben
    if max_length and len(cleaned) > max_length:
        cleaned = cleaned[:max_length]

    return cleaned


def sanitize_html(html: Optional[str], allow_basic_formatting: bool = False) -> str:
    """
    Bereinigt HTML-Input mit optionaler Basis-Formatierung.

    Args:
        html: Der zu bereinigende HTML-Text
        allow_basic_formatting: Erlaube grundlegende Formatierung (b, i, u, p)

    Returns:
        Bereinigter HTML-Text

    Examples:
        >>> sanitize_html("<script>alert('XSS')</script><p>Text</p>")
        "&lt;script&gt;alert('XSS')&lt;/script&gt;&lt;p&gt;Text&lt;/p&gt;"

        >>> sanitize_html("<b>Bold</b> text", allow_basic_formatting=True)
        "<b>Bold</b> text"
    """
    if not html:
        return ""

    if allow_basic_formatting:
        # Basis-Formatierung erlauben
        allowed_tags = ['b', 'i', 'u', 'p', 'br', 'strong', 'em']
        allowed_attrs = {}
    else:
        # Alles escapen
        allowed_tags = []
        allowed_attrs = {}

    cleaned = bleach.clean(
        html,
        tags=allowed_tags,
        attributes=allowed_attrs,
        strip=False  # Escapen statt entfernen
    )

    return cleaned


def sanitize_dict_texts(data: dict, text_fields: list) -> dict:
    """
    Bereinigt Text-Felder in einem Dictionary.

    Args:
        data: Dictionary mit zu bereinigenden Daten
        text_fields: Liste der Feldnamen, die bereinigt werden sollen

    Returns:
        Dictionary mit bereinigten Text-Feldern

    Examples:
        >>> data = {'name': 'Test', 'notes': '<script>XSS</script>'}
        >>> sanitize_dict_texts(data, ['notes'])
        {'name': 'Test', 'notes': 'XSS'}
    """
    cleaned_data = data.copy()

    for field in text_fields:
        if field in cleaned_data and isinstance(cleaned_data[field], str):
            cleaned_data[field] = sanitize_text(cleaned_data[field])

    return cleaned_data


# Maximale Längen für verschiedene Felder
MAX_LENGTHS = {
    'anmerkungen': 5000,
    'bemerkung': 1000,
    'notizen': 5000,
    'raumbedarf': 500,
    'grund': 1000,
    'ablehnungsgrund': 2000,
}


def sanitize_planung_data(data: dict) -> dict:
    """
    Bereinigt Daten für Semesterplanung.

    Args:
        data: Dictionary mit Planungsdaten

    Returns:
        Dictionary mit bereinigten Daten
    """
    text_fields = ['anmerkungen', 'notizen', 'raumbedarf']
    cleaned = sanitize_dict_texts(data, text_fields)

    # Längen-Limits anwenden
    for field, max_len in MAX_LENGTHS.items():
        if field in cleaned and cleaned[field]:
            cleaned[field] = cleaned[field][:max_len]

    # JSON-Felder durchlassen (werden nicht sanitized, da sie strukturierte Daten sind)
    if 'room_requirements' in data:
        cleaned['room_requirements'] = data['room_requirements']
    if 'special_requests' in data:
        cleaned['special_requests'] = data['special_requests']

    return cleaned


def sanitize_modul_data(data: dict) -> dict:
    """
    Bereinigt Daten für geplante Module.

    Args:
        data: Dictionary mit Modul-Daten

    Returns:
        Dictionary mit bereinigten Daten
    """
    text_fields = ['anmerkungen', 'bemerkung', 'raumbedarf']
    cleaned = sanitize_dict_texts(data, text_fields)

    # Längen-Limits anwenden
    for field, max_len in MAX_LENGTHS.items():
        if field in cleaned and cleaned[field]:
            cleaned[field] = cleaned[field][:max_len]

    return cleaned


def sanitize_wunsch_tag_data(data: dict) -> dict:
    """
    Bereinigt Daten für Wunsch-freie Tage.

    Args:
        data: Dictionary mit Wunsch-Tag-Daten

    Returns:
        Dictionary mit bereinigten Daten
    """
    text_fields = ['bemerkung', 'grund']
    cleaned = sanitize_dict_texts(data, text_fields)

    # Längen-Limits anwenden
    for field, max_len in MAX_LENGTHS.items():
        if field in cleaned and cleaned[field]:
            cleaned[field] = cleaned[field][:max_len]

    # Enum-Felder durchlassen (wochentag, zeitraum, prioritaet)
    for field in ['wochentag', 'zeitraum', 'prioritaet']:
        if field in data:
            cleaned[field] = data[field]

    return cleaned
