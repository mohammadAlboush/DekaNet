"""
backend/app/api/modul_verwaltung.py - Modul-Verwaltung API
==========================================================

Feature 3: REST API für Modul-Verwaltung durch Dekan

Endpoints:
- GET /api/modul-verwaltung/ - Liste aller Module mit Dozenten
- POST /api/modul-verwaltung/<modul_id>/dozenten - Dozent zu Modul hinzufügen
- DELETE /api/modul-verwaltung/dozenten/<zuordnung_id> - Dozent von Modul entfernen
- PUT /api/modul-verwaltung/dozenten/<zuordnung_id> - Dozent ersetzen
- POST /api/modul-verwaltung/bulk-transfer - Mehrere Module übertragen
- GET /api/modul-verwaltung/audit-log - Audit Log abrufen

Alle Endpoints erfordern Dekan-Rolle!
"""

from flask import Blueprint, request, jsonify, current_app
from flask_jwt_extended import jwt_required, current_user
from app.services.modul_verwaltung_service import modul_verwaltung_service
from app.extensions import db

# Blueprint Definition
modul_verwaltung_api = Blueprint('modul_verwaltung', __name__, url_prefix='/api/modul-verwaltung')


@modul_verwaltung_api.before_request
@jwt_required()
def check_dekan_role():
    """Alle Endpoints nur für Dekan"""
    if current_user.rolle.name != 'dekan':
        return jsonify({
            'success': False,
            'message': 'Keine Berechtigung. Nur Dekan kann Module verwalten.'
        }), 403


@modul_verwaltung_api.before_request
def log_request():
    """Log every request"""
    current_app.logger.info(f"[ModulVerwaltungAPI] {request.method} {request.path}")


# =========================================================================
# MODULE MIT DOZENTEN ABRUFEN
# =========================================================================

@modul_verwaltung_api.route('/', methods=['GET'])
def get_module_mit_dozenten():
    """GET /api/modul-verwaltung/ - Liste aller Module mit Dozenten"""
    try:
        po_id = request.args.get('po_id', type=int)
        nur_aktive = request.args.get('nur_aktive', 'true').lower() == 'true'

        module = modul_verwaltung_service.get_module_mit_dozenten(
            po_id=po_id,
            nur_aktive=nur_aktive
        )

        return jsonify({
            'success': True,
            'data': module,
            'message': f'{len(module)} Module gefunden'
        }), 200

    except Exception as e:
        current_app.logger.error(f"Error: {e}", exc_info=True)
        return jsonify({
            'success': False,
            'message': 'Fehler beim Laden der Module',
            'error': str(e)
        }), 500


# =========================================================================
# DOZENT HINZUFÜGEN
# =========================================================================

@modul_verwaltung_api.route('/<int:modul_id>/dozenten', methods=['POST'])
def add_dozent_to_modul(modul_id: int):
    """POST /api/modul-verwaltung/<modul_id>/dozenten - Dozent hinzufügen"""
    try:
        data = request.get_json()

        # Validierung
        required_fields = ['po_id', 'dozent_id', 'rolle']
        for field in required_fields:
            if field not in data:
                return jsonify({
                    'success': False,
                    'message': f'{field} ist erforderlich'
                }), 400

        zuordnung = modul_verwaltung_service.add_dozent_to_modul(
            modul_id=modul_id,
            po_id=data['po_id'],
            dozent_id=data['dozent_id'],
            rolle=data['rolle'],
            geaendert_von_id=current_user.id,
            bemerkung=data.get('bemerkung')
        )

        return jsonify({
            'success': True,
            'data': {
                'id': zuordnung.id,
                'modul_id': zuordnung.modul_id,
                'dozent_id': zuordnung.dozent_id,
                'rolle': zuordnung.rolle
            },
            'message': 'Dozent erfolgreich hinzugefügt'
        }), 201

    except ValueError as e:
        return jsonify({
            'success': False,
            'message': str(e)
        }), 400
    except Exception as e:
        current_app.logger.error(f"Error: {e}", exc_info=True)
        db.session.rollback()
        return jsonify({
            'success': False,
            'message': 'Fehler beim Hinzufügen des Dozenten',
            'error': str(e)
        }), 500


# =========================================================================
# DOZENT ENTFERNEN
# =========================================================================

@modul_verwaltung_api.route('/dozenten/<int:zuordnung_id>', methods=['DELETE'])
def remove_dozent_from_modul(zuordnung_id: int):
    """DELETE /api/modul-verwaltung/dozenten/<zuordnung_id> - Dozent entfernen"""
    try:
        data = request.get_json() if request.get_json() else {}

        success = modul_verwaltung_service.remove_dozent_from_modul(
            zuordnung_id=zuordnung_id,
            geaendert_von_id=current_user.id,
            bemerkung=data.get('bemerkung')
        )

        return jsonify({
            'success': True,
            'message': 'Dozent erfolgreich entfernt'
        }), 200

    except ValueError as e:
        return jsonify({
            'success': False,
            'message': str(e)
        }), 404
    except Exception as e:
        current_app.logger.error(f"Error: {e}", exc_info=True)
        db.session.rollback()
        return jsonify({
            'success': False,
            'message': 'Fehler beim Entfernen des Dozenten',
            'error': str(e)
        }), 500


# =========================================================================
# DOZENT ERSETZEN
# =========================================================================

@modul_verwaltung_api.route('/dozenten/<int:zuordnung_id>', methods=['PUT'])
def replace_dozent(zuordnung_id: int):
    """PUT /api/modul-verwaltung/dozenten/<zuordnung_id> - Dozent ersetzen"""
    try:
        data = request.get_json()

        if 'neuer_dozent_id' not in data:
            return jsonify({
                'success': False,
                'message': 'neuer_dozent_id ist erforderlich'
            }), 400

        zuordnung = modul_verwaltung_service.replace_dozent(
            zuordnung_id=zuordnung_id,
            neuer_dozent_id=data['neuer_dozent_id'],
            geaendert_von_id=current_user.id,
            bemerkung=data.get('bemerkung')
        )

        return jsonify({
            'success': True,
            'data': {
                'id': zuordnung.id,
                'modul_id': zuordnung.modul_id,
                'dozent_id': zuordnung.dozent_id,
                'rolle': zuordnung.rolle
            },
            'message': 'Dozent erfolgreich ersetzt'
        }), 200

    except ValueError as e:
        return jsonify({
            'success': False,
            'message': str(e)
        }), 400
    except Exception as e:
        current_app.logger.error(f"Error: {e}", exc_info=True)
        db.session.rollback()
        return jsonify({
            'success': False,
            'message': 'Fehler beim Ersetzen des Dozenten',
            'error': str(e)
        }), 500


# =========================================================================
# BULK OPERATIONS
# =========================================================================

@modul_verwaltung_api.route('/bulk-transfer', methods=['POST'])
def bulk_transfer_module():
    """POST /api/modul-verwaltung/bulk-transfer - Mehrere Module übertragen"""
    try:
        data = request.get_json()

        # Validierung
        required_fields = ['modul_ids', 'von_dozent_id', 'zu_dozent_id', 'po_id']
        for field in required_fields:
            if field not in data:
                return jsonify({
                    'success': False,
                    'message': f'{field} ist erforderlich'
                }), 400

        if not isinstance(data['modul_ids'], list) or len(data['modul_ids']) == 0:
            return jsonify({
                'success': False,
                'message': 'modul_ids muss eine nicht-leere Liste sein'
            }), 400

        result = modul_verwaltung_service.bulk_transfer_module(
            modul_ids=data['modul_ids'],
            von_dozent_id=data['von_dozent_id'],
            zu_dozent_id=data['zu_dozent_id'],
            po_id=data['po_id'],
            geaendert_von_id=current_user.id,
            rolle=data.get('rolle', 'verantwortlich'),
            bemerkung=data.get('bemerkung')
        )

        return jsonify({
            'success': True,
            'data': result,
            'message': f'{result["erfolgreich_count"]} von {result["gesamt"]} Modulen übertragen'
        }), 200

    except ValueError as e:
        return jsonify({
            'success': False,
            'message': str(e)
        }), 400
    except Exception as e:
        current_app.logger.error(f"Error: {e}", exc_info=True)
        db.session.rollback()
        return jsonify({
            'success': False,
            'message': 'Fehler beim Übertragen der Module',
            'error': str(e)
        }), 500


# =========================================================================
# AUDIT LOG
# =========================================================================

@modul_verwaltung_api.route('/audit-log', methods=['GET'])
def get_audit_log():
    """GET /api/modul-verwaltung/audit-log - Audit Log abrufen"""
    try:
        modul_id = request.args.get('modul_id', type=int)
        dozent_id = request.args.get('dozent_id', type=int)
        limit = request.args.get('limit', default=100, type=int)

        # Limit begrenzen
        limit = min(limit, 1000)

        logs = modul_verwaltung_service.get_audit_log(
            modul_id=modul_id,
            dozent_id=dozent_id,
            limit=limit
        )

        return jsonify({
            'success': True,
            'data': logs,
            'message': f'{len(logs)} Einträge gefunden'
        }), 200

    except Exception as e:
        current_app.logger.error(f"Error: {e}", exc_info=True)
        return jsonify({
            'success': False,
            'message': 'Fehler beim Laden des Audit Logs',
            'error': str(e)
        }), 500
