"""
Admin API Endpoints
===================

Administrative Funktionen für Dekan:
- Datenbank Reset (löscht Planungen und Deputatsabrechnungen)
"""

from flask import Blueprint, jsonify, request
from flask_jwt_extended import jwt_required, get_jwt_identity
from app.extensions import db
from app.models.user import Benutzer
from app.models.planung import Semesterplanung, GeplantesModul, WunschFreierTag
from app.models.planungsphase import Planungsphase, ArchiviertePlanung
from app.models.semester import Semester
from app.models.deputat import (
    Deputatsabrechnung,
    DeputatsLehrtaetigkeit,
    DeputatsLehrexport,
    DeputatsVertretung,
    DeputatsErmaessigung,
    DeputatsBetreuung
)
from app.models.auftrag import SemesterAuftrag
import logging

logger = logging.getLogger(__name__)

admin_api = Blueprint('admin_api', __name__, url_prefix='/api/admin')


def check_dekan_role():
    """Prüft ob der aktuelle Benutzer Dekan ist"""
    user_id = get_jwt_identity()
    user = Benutzer.query.get(user_id)
    if not user:
        return False, jsonify({'success': False, 'error': 'Benutzer nicht gefunden'}), 404
    if not user.rolle or user.rolle.name != 'dekan':
        return False, jsonify({'success': False, 'error': 'Nur Dekan hat Zugriff auf Admin-Funktionen'}), 403
    return True, user, None


@admin_api.route('/reset-database', methods=['POST'])
@jwt_required()
def reset_database():
    """
    Setzt die Datenbank zurück (löscht Planungen, Phasen und Deputatsabrechnungen)

    ACHTUNG: Diese Aktion ist nicht umkehrbar!

    Löscht:
    - Alle Semesterplanungen (inkl. GeplantesModul, WunschFreierTag)
    - Alle archivierten Planungen
    - Alle Planungsphasen
    - Alle Deputatsabrechnungen (inkl. alle Child-Tabellen)
    - Alle SemesterAufträge

    Behält:
    - Module
    - Dozenten
    - Semester
    - Prüfungsordnungen
    - Studiengänge
    - Benutzer
    - Aufträge (Master-Liste)
    """
    is_dekan, result, error = check_dekan_role()
    if not is_dekan:
        return result, error

    # Sicherheitscheck: Bestätigungscode muss übereinstimmen
    data = request.get_json() or {}
    confirmation_code = data.get('confirmation_code')

    if confirmation_code != 'RESET_BESTAETIGEN':
        return jsonify({
            'success': False,
            'error': 'Ungültiger Bestätigungscode'
        }), 400

    try:
        # Zähle vor dem Löschen
        stats_before = {
            'semesterplanungen': Semesterplanung.query.count(),
            'geplante_module': GeplantesModul.query.count(),
            'wunsch_freie_tage': WunschFreierTag.query.count(),
            'archivierte_planungen': ArchiviertePlanung.query.count(),
            'planungsphasen': Planungsphase.query.count(),
            'deputatsabrechnungen': Deputatsabrechnung.query.count(),
            'deputats_lehrtaetigkeiten': DeputatsLehrtaetigkeit.query.count(),
            'deputats_lehrexporte': DeputatsLehrexport.query.count(),
            'deputats_vertretungen': DeputatsVertretung.query.count(),
            'deputats_ermaessigungen': DeputatsErmaessigung.query.count(),
            'deputats_betreuungen': DeputatsBetreuung.query.count(),
            'semester_auftraege': SemesterAuftrag.query.count(),
        }

        logger.warning(f"[ADMIN] DATABASE RESET initiated by user {result.id} ({result.username})")
        logger.warning(f"[ADMIN] Stats before reset: {stats_before}")

        # Lösche in richtiger Reihenfolge (Child → Parent)

        # 1. Deputatsabrechnung Child-Tabellen (CASCADE sollte funktionieren, aber explizit sicherer)
        DeputatsLehrtaetigkeit.query.delete()
        DeputatsLehrexport.query.delete()
        DeputatsVertretung.query.delete()
        DeputatsErmaessigung.query.delete()
        DeputatsBetreuung.query.delete()

        # 2. Deputatsabrechnungen
        Deputatsabrechnung.query.delete()

        # 3. Semesterplanung Child-Tabellen
        WunschFreierTag.query.delete()
        GeplantesModul.query.delete()

        # 4. Semesterplanungen
        Semesterplanung.query.delete()

        # 5. Archivierte Planungen (vor Planungsphasen wegen FK)
        ArchiviertePlanung.query.delete()

        # 6. Planungsphasen (nach archivierten Planungen wegen FK)
        Planungsphase.query.delete()

        # 7. Setze ist_planungsphase Flag auf allen Semestern zurück
        Semester.query.update({'ist_planungsphase': False})

        # 8. SemesterAufträge (Zuordnungen, nicht die Master-Liste!)
        SemesterAuftrag.query.delete()

        db.session.commit()

        logger.warning(f"[ADMIN] DATABASE RESET completed successfully")

        return jsonify({
            'success': True,
            'message': 'Datenbank wurde erfolgreich zurückgesetzt',
            'deleted': stats_before
        })

    except Exception as e:
        db.session.rollback()
        logger.error(f"[ADMIN] DATABASE RESET failed: {e}")
        return jsonify({
            'success': False,
            'error': f'Fehler beim Zurücksetzen: {str(e)}'
        }), 500


@admin_api.route('/reset-database/preview', methods=['GET'])
@jwt_required()
def preview_reset():
    """
    Zeigt eine Vorschau dessen, was beim Reset gelöscht würde
    """
    is_dekan, result, error = check_dekan_role()
    if not is_dekan:
        return result, error

    try:
        stats = {
            'semesterplanungen': Semesterplanung.query.count(),
            'geplante_module': GeplantesModul.query.count(),
            'wunsch_freie_tage': WunschFreierTag.query.count(),
            'archivierte_planungen': ArchiviertePlanung.query.count(),
            'planungsphasen': Planungsphase.query.count(),
            'deputatsabrechnungen': Deputatsabrechnung.query.count(),
            'deputats_lehrtaetigkeiten': DeputatsLehrtaetigkeit.query.count(),
            'deputats_lehrexporte': DeputatsLehrexport.query.count(),
            'deputats_vertretungen': DeputatsVertretung.query.count(),
            'deputats_ermaessigungen': DeputatsErmaessigung.query.count(),
            'deputats_betreuungen': DeputatsBetreuung.query.count(),
            'semester_auftraege': SemesterAuftrag.query.count(),
        }

        # Berechne Summen
        stats['total_items'] = sum(stats.values())

        return jsonify({
            'success': True,
            'preview': stats
        })

    except Exception as e:
        logger.error(f"[ADMIN] Preview failed: {e}")
        return jsonify({
            'success': False,
            'error': f'Fehler beim Laden der Vorschau: {str(e)}'
        }), 500
