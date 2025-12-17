"""
Cache Utilities
===============
Helper-Funktionen für Cache-Invalidierung bei Datenänderungen.
"""

from app.extensions import cache
from flask import current_app


def invalidate_module_caches():
    """
    Invalidiert alle Modul-bezogenen Caches.

    Rufe diese Funktion auf, wenn:
    - Ein Modul erstellt/aktualisiert/gelöscht wird
    - Dozenten-Zuordnungen geändert werden
    - Lehrformen hinzugefügt/geändert werden
    """
    try:
        # Lösche alle gecachten /api/module/options/* Endpoints
        cache.delete_memoized('get_lehrformen_options')
        cache.delete_memoized('get_dozenten_options')
        cache.delete_memoized('get_studiengaenge_options')
        current_app.logger.info('[Cache] Module-related caches invalidated')
    except Exception as e:
        current_app.logger.error(f'[Cache] Error invalidating module caches: {e}')


def invalidate_semester_caches():
    """
    Invalidiert alle Semester-bezogenen Caches.

    Rufe diese Funktion auf, wenn:
    - Ein Semester erstellt/aktualisiert/gelöscht wird
    - Semester aktiviert/deaktiviert wird
    - Planungsphase geändert wird
    """
    try:
        # Lösche alle gecachten Semester-Listen
        cache.delete('view//api/semester/')  # Flask-Caching Key Format
        current_app.logger.info('[Cache] Semester caches invalidated')
    except Exception as e:
        current_app.logger.error(f'[Cache] Error invalidating semester caches: {e}')


def invalidate_dozent_caches():
    """
    Invalidiert Dozenten-bezogene Caches.

    Rufe diese Funktion auf, wenn:
    - Ein Dozent erstellt/aktualisiert/gelöscht wird
    """
    try:
        cache.delete_memoized('get_dozenten_options')
        current_app.logger.info('[Cache] Dozent caches invalidated')
    except Exception as e:
        current_app.logger.error(f'[Cache] Error invalidating dozent caches: {e}')


def invalidate_studiengang_caches():
    """
    Invalidiert Studiengang-bezogene Caches.

    Rufe diese Funktion auf, wenn:
    - Ein Studiengang erstellt/aktualisiert/gelöscht wird
    """
    try:
        cache.delete_memoized('get_studiengaenge_options')
        current_app.logger.info('[Cache] Studiengang caches invalidated')
    except Exception as e:
        current_app.logger.error(f'[Cache] Error invalidating studiengang caches: {e}')


def clear_all_caches():
    """
    Löscht alle Caches komplett.

    Nur in besonderen Fällen verwenden (z.B. nach Datenimport).
    """
    try:
        cache.clear()
        current_app.logger.warning('[Cache] All caches cleared')
    except Exception as e:
        current_app.logger.error(f'[Cache] Error clearing all caches: {e}')
