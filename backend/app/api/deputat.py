"""
backend/app/api/deputat.py - Deputatsabrechnung API
====================================================

Feature 4: REST API für Deputatsabrechnungen

Endpoints:
- GET /api/deputat/einstellungen - Aktuelle Einstellungen
- PUT /api/deputat/einstellungen - Einstellungen aktualisieren (Dekan)

- GET /api/deputat/ - Eigene Abrechnungen
- GET /api/deputat/alle - Alle Abrechnungen (Dekan)
- GET /api/deputat/eingereicht - Eingereichte (Dekan)
- POST /api/deputat/ - Neue Abrechnung erstellen/holen
- GET /api/deputat/<id> - Abrechnung Details
- PUT /api/deputat/<id> - Abrechnung aktualisieren

- POST /api/deputat/<id>/import/planung - Import aus Planung
- POST /api/deputat/<id>/import/semesterauftraege - Import aus Semesteraufträgen

- Lehrtätigkeiten CRUD
- Lehrexport CRUD
- Vertretungen CRUD
- Ermäßigungen CRUD
- Betreuungen CRUD

- PUT /api/deputat/<id>/einreichen - Einreichen
- PUT /api/deputat/<id>/genehmigen - Genehmigen (Dekan)
- PUT /api/deputat/<id>/ablehnen - Ablehnen (Dekan)
- PUT /api/deputat/<id>/zuruecksetzen - Zurücksetzen

- GET /api/deputat/statistik - Statistiken (Dekan)
"""

from flask import Blueprint, request, jsonify, current_app
from flask_jwt_extended import jwt_required, get_jwt_identity, current_user
from datetime import datetime
from app.services.deputat_service import deputat_service
from app.extensions import db

# Blueprint Definition
deputat_api = Blueprint('deputat', __name__, url_prefix='/api/deputat')


@deputat_api.before_request
def log_request():
    """Log every request"""
    current_app.logger.info(f"[DeputatAPI] {request.method} {request.path}")


# =============================================================================
# HELPER FUNCTIONS
# =============================================================================

def require_dekan():
    """Prüft ob User Dekan ist"""
    if current_user.rolle.name != 'dekan':
        return False
    return True


def kann_abrechnung_zugreifen(abrechnung):
    """Prüft ob User auf Abrechnung zugreifen kann"""
    if current_user.rolle.name == 'dekan':
        return True
    return abrechnung.benutzer_id == current_user.id


# =============================================================================
# EINSTELLUNGEN (nur Dekan)
# =============================================================================

@deputat_api.route('/einstellungen', methods=['GET'])
@jwt_required()
def get_einstellungen():
    """GET /api/deputat/einstellungen - Aktuelle Einstellungen"""
    try:
        einstellungen = deputat_service.get_einstellungen()

        return jsonify({
            'success': True,
            'data': einstellungen.to_dict()
        }), 200

    except Exception as e:
        current_app.logger.error(f"Error: {e}", exc_info=True)
        return jsonify({
            'success': False,
            'message': 'Fehler beim Laden der Einstellungen',
            'error': str(e)
        }), 500


@deputat_api.route('/einstellungen', methods=['PUT'])
@jwt_required()
def update_einstellungen():
    """PUT /api/deputat/einstellungen - Einstellungen aktualisieren (Dekan)"""
    try:
        if not require_dekan():
            return jsonify({
                'success': False,
                'message': 'Keine Berechtigung'
            }), 403

        data = request.get_json()
        beschreibung = data.pop('beschreibung', None)

        einstellungen = deputat_service.update_einstellungen(
            erstellt_von=current_user.id,
            beschreibung=beschreibung,
            **data
        )

        return jsonify({
            'success': True,
            'data': einstellungen.to_dict(),
            'message': 'Einstellungen aktualisiert'
        }), 200

    except Exception as e:
        current_app.logger.error(f"Error: {e}", exc_info=True)
        return jsonify({
            'success': False,
            'message': 'Fehler beim Aktualisieren',
            'error': str(e)
        }), 500


@deputat_api.route('/einstellungen/historie', methods=['GET'])
@jwt_required()
def get_einstellungen_historie():
    """GET /api/deputat/einstellungen/historie - Einstellungen Historie (Dekan)"""
    try:
        if not require_dekan():
            return jsonify({
                'success': False,
                'message': 'Keine Berechtigung'
            }), 403

        historie = deputat_service.get_einstellungen_historie()

        return jsonify({
            'success': True,
            'data': [e.to_dict() for e in historie]
        }), 200

    except Exception as e:
        current_app.logger.error(f"Error: {e}", exc_info=True)
        return jsonify({
            'success': False,
            'message': 'Fehler beim Laden',
            'error': str(e)
        }), 500


# =============================================================================
# DEPUTATSABRECHNUNG CRUD
# =============================================================================

@deputat_api.route('/', methods=['GET'])
@jwt_required()
def get_meine_abrechnungen():
    """GET /api/deputat/ - Meine Abrechnungen"""
    try:
        planungsphase_id = request.args.get('planungsphase_id', type=int)

        abrechnungen = deputat_service.get_abrechnungen_fuer_benutzer(
            benutzer_id=current_user.id,
            planungsphase_id=planungsphase_id
        )

        return jsonify({
            'success': True,
            'data': [a.to_dict(include_summen=True) for a in abrechnungen],
            'message': f'{len(abrechnungen)} Abrechnungen gefunden'
        }), 200

    except Exception as e:
        current_app.logger.error(f"Error: {e}", exc_info=True)
        return jsonify({
            'success': False,
            'message': 'Fehler beim Laden',
            'error': str(e)
        }), 500


@deputat_api.route('/alle', methods=['GET'])
@jwt_required()
def get_alle_abrechnungen():
    """GET /api/deputat/alle - Alle Abrechnungen (Dekan)"""
    try:
        if not require_dekan():
            return jsonify({
                'success': False,
                'message': 'Keine Berechtigung'
            }), 403

        planungsphase_id = request.args.get('planungsphase_id', type=int)
        status = request.args.get('status')

        if planungsphase_id:
            abrechnungen = deputat_service.get_abrechnungen_fuer_planungsphase(
                planungsphase_id=planungsphase_id,
                status=status
            )
        else:
            # Alle Abrechnungen
            from app.models import Deputatsabrechnung
            query = Deputatsabrechnung.query
            if status:
                query = query.filter_by(status=status)
            abrechnungen = query.order_by(Deputatsabrechnung.updated_at.desc()).all()

        return jsonify({
            'success': True,
            'data': [a.to_dict(include_summen=True) for a in abrechnungen],
            'message': f'{len(abrechnungen)} Abrechnungen gefunden'
        }), 200

    except Exception as e:
        current_app.logger.error(f"Error: {e}", exc_info=True)
        return jsonify({
            'success': False,
            'message': 'Fehler beim Laden',
            'error': str(e)
        }), 500


@deputat_api.route('/eingereicht', methods=['GET'])
@jwt_required()
def get_eingereichte():
    """GET /api/deputat/eingereicht - Eingereichte Abrechnungen (Dekan)"""
    try:
        if not require_dekan():
            return jsonify({
                'success': False,
                'message': 'Keine Berechtigung'
            }), 403

        planungsphase_id = request.args.get('planungsphase_id', type=int)

        abrechnungen = deputat_service.get_eingereichte_abrechnungen(
            planungsphase_id=planungsphase_id
        )

        return jsonify({
            'success': True,
            'data': [a.to_dict(include_details=True, include_summen=True) for a in abrechnungen],
            'message': f'{len(abrechnungen)} eingereichte Abrechnungen'
        }), 200

    except Exception as e:
        current_app.logger.error(f"Error: {e}", exc_info=True)
        return jsonify({
            'success': False,
            'message': 'Fehler beim Laden',
            'error': str(e)
        }), 500


@deputat_api.route('/', methods=['POST'])
@jwt_required()
def create_or_get_abrechnung():
    """POST /api/deputat/ - Erstellt oder holt Abrechnung"""
    try:
        data = request.get_json()

        if 'planungsphase_id' not in data:
            return jsonify({
                'success': False,
                'message': 'planungsphase_id ist erforderlich'
            }), 400

        abrechnung = deputat_service.get_or_create_abrechnung(
            planungsphase_id=data['planungsphase_id'],
            benutzer_id=current_user.id
        )

        return jsonify({
            'success': True,
            'data': abrechnung.to_dict(include_details=True, include_summen=True),
            'message': 'Abrechnung geladen'
        }), 200

    except ValueError as e:
        return jsonify({
            'success': False,
            'message': str(e)
        }), 400
    except Exception as e:
        current_app.logger.error(f"Error: {e}", exc_info=True)
        return jsonify({
            'success': False,
            'message': 'Fehler beim Erstellen',
            'error': str(e)
        }), 500


@deputat_api.route('/<int:abrechnung_id>', methods=['GET'])
@jwt_required()
def get_abrechnung(abrechnung_id: int):
    """GET /api/deputat/<id> - Abrechnung Details"""
    try:
        abrechnung = deputat_service.get_abrechnung(abrechnung_id)

        if not abrechnung:
            return jsonify({
                'success': False,
                'message': 'Abrechnung nicht gefunden'
            }), 404

        if not kann_abrechnung_zugreifen(abrechnung):
            return jsonify({
                'success': False,
                'message': 'Keine Berechtigung'
            }), 403

        return jsonify({
            'success': True,
            'data': abrechnung.to_dict(include_details=True, include_summen=True)
        }), 200

    except Exception as e:
        current_app.logger.error(f"Error: {e}", exc_info=True)
        return jsonify({
            'success': False,
            'message': 'Fehler beim Laden',
            'error': str(e)
        }), 500


@deputat_api.route('/<int:abrechnung_id>', methods=['PUT'])
@jwt_required()
def update_abrechnung(abrechnung_id: int):
    """PUT /api/deputat/<id> - Abrechnung aktualisieren"""
    try:
        abrechnung = deputat_service.get_abrechnung(abrechnung_id)

        if not abrechnung:
            return jsonify({
                'success': False,
                'message': 'Abrechnung nicht gefunden'
            }), 404

        if not kann_abrechnung_zugreifen(abrechnung):
            return jsonify({
                'success': False,
                'message': 'Keine Berechtigung'
            }), 403

        data = request.get_json()

        abrechnung = deputat_service.update_abrechnung(abrechnung_id, **data)

        return jsonify({
            'success': True,
            'data': abrechnung.to_dict(include_details=True, include_summen=True),
            'message': 'Abrechnung aktualisiert'
        }), 200

    except ValueError as e:
        return jsonify({
            'success': False,
            'message': str(e)
        }), 400
    except Exception as e:
        current_app.logger.error(f"Error: {e}", exc_info=True)
        return jsonify({
            'success': False,
            'message': 'Fehler beim Aktualisieren',
            'error': str(e)
        }), 500


# =============================================================================
# SYNC (NEU - Automatische Synchronisation)
# =============================================================================

@deputat_api.route('/<int:abrechnung_id>/sync', methods=['POST'])
@jwt_required()
def sync_abrechnung(abrechnung_id: int):
    """
    POST /api/deputat/<id>/sync - Synchronisiert mit Planung und Semesteraufträgen

    Wird automatisch bei Phasenauswahl aufgerufen.
    Aktualisiert importierte Daten, fügt neue hinzu, entfernt veraltete.
    Manuell hinzugefügte Einträge bleiben unberührt.
    """
    try:
        abrechnung = deputat_service.get_abrechnung(abrechnung_id)

        if not abrechnung:
            return jsonify({
                'success': False,
                'message': 'Abrechnung nicht gefunden'
            }), 404

        if not kann_abrechnung_zugreifen(abrechnung):
            return jsonify({
                'success': False,
                'message': 'Keine Berechtigung'
            }), 403

        # Synchronisation durchführen
        planung_result = deputat_service.sync_from_planung(abrechnung_id)
        auftraege_result = deputat_service.sync_from_semesterauftraege(abrechnung_id)

        # Aktualisierte Abrechnung laden
        abrechnung = deputat_service.get_abrechnung(abrechnung_id)

        return jsonify({
            'success': True,
            'data': abrechnung.to_dict(include_details=True, include_summen=True),
            'sync_result': {
                'planung': planung_result,
                'auftraege': auftraege_result
            },
            'message': f"Sync: {planung_result.get('hinzugefuegt', 0)} Module hinzugefügt, {auftraege_result.get('hinzugefuegt', 0)} Ermäßigungen"
        }), 200

    except ValueError as e:
        return jsonify({
            'success': False,
            'message': str(e)
        }), 400
    except Exception as e:
        current_app.logger.error(f"Error: {e}", exc_info=True)
        return jsonify({
            'success': False,
            'message': 'Fehler bei der Synchronisation',
            'error': str(e)
        }), 500


# =============================================================================
# IMPORT (Legacy - weiterhin verfügbar für manuellen Import)
# =============================================================================

@deputat_api.route('/<int:abrechnung_id>/import/planung', methods=['POST'])
@jwt_required()
def import_planung(abrechnung_id: int):
    """POST /api/deputat/<id>/import/planung - Import aus Planung"""
    try:
        abrechnung = deputat_service.get_abrechnung(abrechnung_id)

        if not abrechnung:
            return jsonify({
                'success': False,
                'message': 'Abrechnung nicht gefunden'
            }), 404

        if not kann_abrechnung_zugreifen(abrechnung):
            return jsonify({
                'success': False,
                'message': 'Keine Berechtigung'
            }), 403

        data = request.get_json() or {}
        ueberschreibe = data.get('ueberschreibe_bestehende', False)

        result = deputat_service.importiere_aus_planung(
            abrechnung_id=abrechnung_id,
            ueberschreibe_bestehende=ueberschreibe
        )

        # Aktualisierte Abrechnung laden
        abrechnung = deputat_service.get_abrechnung(abrechnung_id)

        return jsonify({
            'success': True,
            'data': abrechnung.to_dict(include_details=True, include_summen=True),
            'import_result': result,
            'message': f"{result['importiert']} Lehrtätigkeiten importiert"
        }), 200

    except ValueError as e:
        return jsonify({
            'success': False,
            'message': str(e)
        }), 400
    except Exception as e:
        current_app.logger.error(f"Error: {e}", exc_info=True)
        return jsonify({
            'success': False,
            'message': 'Fehler beim Import',
            'error': str(e)
        }), 500


@deputat_api.route('/<int:abrechnung_id>/import/semesterauftraege', methods=['POST'])
@jwt_required()
def import_semesterauftraege(abrechnung_id: int):
    """POST /api/deputat/<id>/import/semesterauftraege - Import aus Semesteraufträgen"""
    try:
        abrechnung = deputat_service.get_abrechnung(abrechnung_id)

        if not abrechnung:
            return jsonify({
                'success': False,
                'message': 'Abrechnung nicht gefunden'
            }), 404

        if not kann_abrechnung_zugreifen(abrechnung):
            return jsonify({
                'success': False,
                'message': 'Keine Berechtigung'
            }), 403

        data = request.get_json() or {}
        ueberschreibe = data.get('ueberschreibe_bestehende', False)

        result = deputat_service.importiere_ermaessigungen_aus_semesterauftraegen(
            abrechnung_id=abrechnung_id,
            ueberschreibe_bestehende=ueberschreibe
        )

        # Aktualisierte Abrechnung laden
        abrechnung = deputat_service.get_abrechnung(abrechnung_id)

        return jsonify({
            'success': True,
            'data': abrechnung.to_dict(include_details=True, include_summen=True),
            'import_result': result,
            'message': f"{result['importiert']} Ermäßigungen importiert"
        }), 200

    except ValueError as e:
        return jsonify({
            'success': False,
            'message': str(e)
        }), 400
    except Exception as e:
        current_app.logger.error(f"Error: {e}", exc_info=True)
        return jsonify({
            'success': False,
            'message': 'Fehler beim Import',
            'error': str(e)
        }), 500


# =============================================================================
# LEHRTÄTIGKEITEN
# =============================================================================

@deputat_api.route('/<int:abrechnung_id>/lehrtaetigkeit', methods=['POST'])
@jwt_required()
def add_lehrtaetigkeit(abrechnung_id: int):
    """POST /api/deputat/<id>/lehrtaetigkeit - Lehrtätigkeit hinzufügen"""
    try:
        abrechnung = deputat_service.get_abrechnung(abrechnung_id)

        if not abrechnung:
            return jsonify({
                'success': False,
                'message': 'Abrechnung nicht gefunden'
            }), 404

        if not kann_abrechnung_zugreifen(abrechnung):
            return jsonify({
                'success': False,
                'message': 'Keine Berechtigung'
            }), 403

        data = request.get_json()

        lt = deputat_service.add_lehrtaetigkeit(
            abrechnung_id=abrechnung_id,
            bezeichnung=data['bezeichnung'],
            sws=data['sws'],
            kategorie=data.get('kategorie', 'lehrveranstaltung'),
            wochentag=data.get('wochentag'),
            ist_block=data.get('ist_block', False)
        )

        return jsonify({
            'success': True,
            'data': lt.to_dict(),
            'message': 'Lehrtätigkeit hinzugefügt'
        }), 201

    except ValueError as e:
        return jsonify({
            'success': False,
            'message': str(e)
        }), 400
    except Exception as e:
        current_app.logger.error(f"Error: {e}", exc_info=True)
        return jsonify({
            'success': False,
            'message': 'Fehler beim Hinzufügen',
            'error': str(e)
        }), 500


@deputat_api.route('/lehrtaetigkeit/<int:lehrtaetigkeit_id>', methods=['PUT'])
@jwt_required()
def update_lehrtaetigkeit(lehrtaetigkeit_id: int):
    """PUT /api/deputat/lehrtaetigkeit/<id> - Lehrtätigkeit aktualisieren"""
    try:
        from app.models import DeputatsLehrtaetigkeit
        lt = DeputatsLehrtaetigkeit.query.get(lehrtaetigkeit_id)

        if not lt:
            return jsonify({
                'success': False,
                'message': 'Lehrtätigkeit nicht gefunden'
            }), 404

        if not kann_abrechnung_zugreifen(lt.deputatsabrechnung):
            return jsonify({
                'success': False,
                'message': 'Keine Berechtigung'
            }), 403

        data = request.get_json()

        lt = deputat_service.update_lehrtaetigkeit(lehrtaetigkeit_id, **data)

        return jsonify({
            'success': True,
            'data': lt.to_dict(),
            'message': 'Lehrtätigkeit aktualisiert'
        }), 200

    except ValueError as e:
        return jsonify({
            'success': False,
            'message': str(e)
        }), 400
    except Exception as e:
        current_app.logger.error(f"Error: {e}", exc_info=True)
        return jsonify({
            'success': False,
            'message': 'Fehler beim Aktualisieren',
            'error': str(e)
        }), 500


@deputat_api.route('/lehrtaetigkeit/<int:lehrtaetigkeit_id>', methods=['DELETE'])
@jwt_required()
def delete_lehrtaetigkeit(lehrtaetigkeit_id: int):
    """DELETE /api/deputat/lehrtaetigkeit/<id> - Lehrtätigkeit löschen"""
    try:
        from app.models import DeputatsLehrtaetigkeit
        lt = DeputatsLehrtaetigkeit.query.get(lehrtaetigkeit_id)

        if not lt:
            return jsonify({
                'success': False,
                'message': 'Lehrtätigkeit nicht gefunden'
            }), 404

        if not kann_abrechnung_zugreifen(lt.deputatsabrechnung):
            return jsonify({
                'success': False,
                'message': 'Keine Berechtigung'
            }), 403

        deputat_service.delete_lehrtaetigkeit(lehrtaetigkeit_id)

        return jsonify({
            'success': True,
            'message': 'Lehrtätigkeit gelöscht'
        }), 200

    except ValueError as e:
        return jsonify({
            'success': False,
            'message': str(e)
        }), 400
    except Exception as e:
        current_app.logger.error(f"Error: {e}", exc_info=True)
        return jsonify({
            'success': False,
            'message': 'Fehler beim Löschen',
            'error': str(e)
        }), 500


# =============================================================================
# LEHREXPORT
# =============================================================================

@deputat_api.route('/<int:abrechnung_id>/lehrexport', methods=['POST'])
@jwt_required()
def add_lehrexport(abrechnung_id: int):
    """POST /api/deputat/<id>/lehrexport - Lehrexport hinzufügen"""
    try:
        abrechnung = deputat_service.get_abrechnung(abrechnung_id)

        if not abrechnung:
            return jsonify({
                'success': False,
                'message': 'Abrechnung nicht gefunden'
            }), 404

        if not kann_abrechnung_zugreifen(abrechnung):
            return jsonify({
                'success': False,
                'message': 'Keine Berechtigung'
            }), 403

        data = request.get_json()

        le = deputat_service.add_lehrexport(
            abrechnung_id=abrechnung_id,
            fachbereich=data['fachbereich'],
            fach=data['fach'],
            sws=data['sws']
        )

        return jsonify({
            'success': True,
            'data': le.to_dict(),
            'message': 'Lehrexport hinzugefügt'
        }), 201

    except ValueError as e:
        return jsonify({
            'success': False,
            'message': str(e)
        }), 400
    except Exception as e:
        current_app.logger.error(f"Error: {e}", exc_info=True)
        return jsonify({
            'success': False,
            'message': 'Fehler beim Hinzufügen',
            'error': str(e)
        }), 500


@deputat_api.route('/lehrexport/<int:lehrexport_id>', methods=['PUT'])
@jwt_required()
def update_lehrexport(lehrexport_id: int):
    """PUT /api/deputat/lehrexport/<id> - Lehrexport aktualisieren"""
    try:
        from app.models import DeputatsLehrexport
        le = DeputatsLehrexport.query.get(lehrexport_id)

        if not le:
            return jsonify({
                'success': False,
                'message': 'Lehrexport nicht gefunden'
            }), 404

        if not kann_abrechnung_zugreifen(le.deputatsabrechnung):
            return jsonify({
                'success': False,
                'message': 'Keine Berechtigung'
            }), 403

        data = request.get_json()

        le = deputat_service.update_lehrexport(lehrexport_id, **data)

        return jsonify({
            'success': True,
            'data': le.to_dict(),
            'message': 'Lehrexport aktualisiert'
        }), 200

    except ValueError as e:
        return jsonify({
            'success': False,
            'message': str(e)
        }), 400
    except Exception as e:
        current_app.logger.error(f"Error: {e}", exc_info=True)
        return jsonify({
            'success': False,
            'message': 'Fehler beim Aktualisieren',
            'error': str(e)
        }), 500


@deputat_api.route('/lehrexport/<int:lehrexport_id>', methods=['DELETE'])
@jwt_required()
def delete_lehrexport(lehrexport_id: int):
    """DELETE /api/deputat/lehrexport/<id> - Lehrexport löschen"""
    try:
        from app.models import DeputatsLehrexport
        le = DeputatsLehrexport.query.get(lehrexport_id)

        if not le:
            return jsonify({
                'success': False,
                'message': 'Lehrexport nicht gefunden'
            }), 404

        if not kann_abrechnung_zugreifen(le.deputatsabrechnung):
            return jsonify({
                'success': False,
                'message': 'Keine Berechtigung'
            }), 403

        deputat_service.delete_lehrexport(lehrexport_id)

        return jsonify({
            'success': True,
            'message': 'Lehrexport gelöscht'
        }), 200

    except ValueError as e:
        return jsonify({
            'success': False,
            'message': str(e)
        }), 400
    except Exception as e:
        current_app.logger.error(f"Error: {e}", exc_info=True)
        return jsonify({
            'success': False,
            'message': 'Fehler beim Löschen',
            'error': str(e)
        }), 500


# =============================================================================
# VERTRETUNGEN
# =============================================================================

@deputat_api.route('/<int:abrechnung_id>/vertretung', methods=['POST'])
@jwt_required()
def add_vertretung(abrechnung_id: int):
    """POST /api/deputat/<id>/vertretung - Vertretung hinzufügen"""
    try:
        abrechnung = deputat_service.get_abrechnung(abrechnung_id)

        if not abrechnung:
            return jsonify({
                'success': False,
                'message': 'Abrechnung nicht gefunden'
            }), 404

        if not kann_abrechnung_zugreifen(abrechnung):
            return jsonify({
                'success': False,
                'message': 'Keine Berechtigung'
            }), 403

        data = request.get_json()

        v = deputat_service.add_vertretung(
            abrechnung_id=abrechnung_id,
            art=data['art'],
            vertretene_person=data['vertretene_person'],
            fach_professor=data['fach_professor'],
            sws=data['sws']
        )

        return jsonify({
            'success': True,
            'data': v.to_dict(),
            'message': 'Vertretung hinzugefügt'
        }), 201

    except ValueError as e:
        return jsonify({
            'success': False,
            'message': str(e)
        }), 400
    except Exception as e:
        current_app.logger.error(f"Error: {e}", exc_info=True)
        return jsonify({
            'success': False,
            'message': 'Fehler beim Hinzufügen',
            'error': str(e)
        }), 500


@deputat_api.route('/vertretung/<int:vertretung_id>', methods=['PUT'])
@jwt_required()
def update_vertretung(vertretung_id: int):
    """PUT /api/deputat/vertretung/<id> - Vertretung aktualisieren"""
    try:
        from app.models import DeputatsVertretung
        v = DeputatsVertretung.query.get(vertretung_id)

        if not v:
            return jsonify({
                'success': False,
                'message': 'Vertretung nicht gefunden'
            }), 404

        if not kann_abrechnung_zugreifen(v.deputatsabrechnung):
            return jsonify({
                'success': False,
                'message': 'Keine Berechtigung'
            }), 403

        data = request.get_json()

        v = deputat_service.update_vertretung(vertretung_id, **data)

        return jsonify({
            'success': True,
            'data': v.to_dict(),
            'message': 'Vertretung aktualisiert'
        }), 200

    except ValueError as e:
        return jsonify({
            'success': False,
            'message': str(e)
        }), 400
    except Exception as e:
        current_app.logger.error(f"Error: {e}", exc_info=True)
        return jsonify({
            'success': False,
            'message': 'Fehler beim Aktualisieren',
            'error': str(e)
        }), 500


@deputat_api.route('/vertretung/<int:vertretung_id>', methods=['DELETE'])
@jwt_required()
def delete_vertretung(vertretung_id: int):
    """DELETE /api/deputat/vertretung/<id> - Vertretung löschen"""
    try:
        from app.models import DeputatsVertretung
        v = DeputatsVertretung.query.get(vertretung_id)

        if not v:
            return jsonify({
                'success': False,
                'message': 'Vertretung nicht gefunden'
            }), 404

        if not kann_abrechnung_zugreifen(v.deputatsabrechnung):
            return jsonify({
                'success': False,
                'message': 'Keine Berechtigung'
            }), 403

        deputat_service.delete_vertretung(vertretung_id)

        return jsonify({
            'success': True,
            'message': 'Vertretung gelöscht'
        }), 200

    except ValueError as e:
        return jsonify({
            'success': False,
            'message': str(e)
        }), 400
    except Exception as e:
        current_app.logger.error(f"Error: {e}", exc_info=True)
        return jsonify({
            'success': False,
            'message': 'Fehler beim Löschen',
            'error': str(e)
        }), 500


# =============================================================================
# ERMÄSSIGUNGEN
# =============================================================================

@deputat_api.route('/<int:abrechnung_id>/ermaessigung', methods=['POST'])
@jwt_required()
def add_ermaessigung(abrechnung_id: int):
    """POST /api/deputat/<id>/ermaessigung - Ermäßigung hinzufügen"""
    try:
        abrechnung = deputat_service.get_abrechnung(abrechnung_id)

        if not abrechnung:
            return jsonify({
                'success': False,
                'message': 'Abrechnung nicht gefunden'
            }), 404

        if not kann_abrechnung_zugreifen(abrechnung):
            return jsonify({
                'success': False,
                'message': 'Keine Berechtigung'
            }), 403

        data = request.get_json()

        e = deputat_service.add_ermaessigung(
            abrechnung_id=abrechnung_id,
            bezeichnung=data['bezeichnung'],
            sws=data['sws']
        )

        return jsonify({
            'success': True,
            'data': e.to_dict(),
            'message': 'Ermäßigung hinzugefügt'
        }), 201

    except ValueError as e:
        return jsonify({
            'success': False,
            'message': str(e)
        }), 400
    except Exception as ex:
        current_app.logger.error(f"Error: {ex}", exc_info=True)
        return jsonify({
            'success': False,
            'message': 'Fehler beim Hinzufügen',
            'error': str(ex)
        }), 500


@deputat_api.route('/ermaessigung/<int:ermaessigung_id>', methods=['PUT'])
@jwt_required()
def update_ermaessigung(ermaessigung_id: int):
    """PUT /api/deputat/ermaessigung/<id> - Ermäßigung aktualisieren"""
    try:
        from app.models import DeputatsErmaessigung
        e = DeputatsErmaessigung.query.get(ermaessigung_id)

        if not e:
            return jsonify({
                'success': False,
                'message': 'Ermäßigung nicht gefunden'
            }), 404

        if not kann_abrechnung_zugreifen(e.deputatsabrechnung):
            return jsonify({
                'success': False,
                'message': 'Keine Berechtigung'
            }), 403

        data = request.get_json()

        e = deputat_service.update_ermaessigung(ermaessigung_id, **data)

        return jsonify({
            'success': True,
            'data': e.to_dict(),
            'message': 'Ermäßigung aktualisiert'
        }), 200

    except ValueError as e:
        return jsonify({
            'success': False,
            'message': str(e)
        }), 400
    except Exception as ex:
        current_app.logger.error(f"Error: {ex}", exc_info=True)
        return jsonify({
            'success': False,
            'message': 'Fehler beim Aktualisieren',
            'error': str(ex)
        }), 500


@deputat_api.route('/ermaessigung/<int:ermaessigung_id>', methods=['DELETE'])
@jwt_required()
def delete_ermaessigung(ermaessigung_id: int):
    """DELETE /api/deputat/ermaessigung/<id> - Ermäßigung löschen"""
    try:
        from app.models import DeputatsErmaessigung
        e = DeputatsErmaessigung.query.get(ermaessigung_id)

        if not e:
            return jsonify({
                'success': False,
                'message': 'Ermäßigung nicht gefunden'
            }), 404

        if not kann_abrechnung_zugreifen(e.deputatsabrechnung):
            return jsonify({
                'success': False,
                'message': 'Keine Berechtigung'
            }), 403

        deputat_service.delete_ermaessigung(ermaessigung_id)

        return jsonify({
            'success': True,
            'message': 'Ermäßigung gelöscht'
        }), 200

    except ValueError as e:
        return jsonify({
            'success': False,
            'message': str(e)
        }), 400
    except Exception as ex:
        current_app.logger.error(f"Error: {ex}", exc_info=True)
        return jsonify({
            'success': False,
            'message': 'Fehler beim Löschen',
            'error': str(ex)
        }), 500


# =============================================================================
# BETREUUNGEN
# =============================================================================

@deputat_api.route('/<int:abrechnung_id>/betreuung', methods=['POST'])
@jwt_required()
def add_betreuung(abrechnung_id: int):
    """POST /api/deputat/<id>/betreuung - Betreuung hinzufügen"""
    try:
        abrechnung = deputat_service.get_abrechnung(abrechnung_id)

        if not abrechnung:
            return jsonify({
                'success': False,
                'message': 'Abrechnung nicht gefunden'
            }), 404

        if not kann_abrechnung_zugreifen(abrechnung):
            return jsonify({
                'success': False,
                'message': 'Keine Berechtigung'
            }), 403

        data = request.get_json()

        # Datums-Parsing
        beginn_datum = None
        ende_datum = None
        if data.get('beginn_datum'):
            beginn_datum = datetime.strptime(data['beginn_datum'], '%Y-%m-%d').date()
        if data.get('ende_datum'):
            ende_datum = datetime.strptime(data['ende_datum'], '%Y-%m-%d').date()

        b = deputat_service.add_betreuung(
            abrechnung_id=abrechnung_id,
            student_name=data['student_name'],
            student_vorname=data['student_vorname'],
            betreuungsart=data['betreuungsart'],
            titel_arbeit=data.get('titel_arbeit'),
            status=data.get('status', 'laufend'),
            beginn_datum=beginn_datum,
            ende_datum=ende_datum
        )

        return jsonify({
            'success': True,
            'data': b.to_dict(),
            'message': 'Betreuung hinzugefügt'
        }), 201

    except ValueError as e:
        return jsonify({
            'success': False,
            'message': str(e)
        }), 400
    except Exception as e:
        current_app.logger.error(f"Error: {e}", exc_info=True)
        return jsonify({
            'success': False,
            'message': 'Fehler beim Hinzufügen',
            'error': str(e)
        }), 500


@deputat_api.route('/betreuung/<int:betreuung_id>', methods=['PUT'])
@jwt_required()
def update_betreuung(betreuung_id: int):
    """PUT /api/deputat/betreuung/<id> - Betreuung aktualisieren"""
    try:
        from app.models import DeputatsBetreuung
        b = DeputatsBetreuung.query.get(betreuung_id)

        if not b:
            return jsonify({
                'success': False,
                'message': 'Betreuung nicht gefunden'
            }), 404

        if not kann_abrechnung_zugreifen(b.deputatsabrechnung):
            return jsonify({
                'success': False,
                'message': 'Keine Berechtigung'
            }), 403

        data = request.get_json()

        # Datums-Parsing
        if 'beginn_datum' in data and data['beginn_datum']:
            data['beginn_datum'] = datetime.strptime(data['beginn_datum'], '%Y-%m-%d').date()
        if 'ende_datum' in data and data['ende_datum']:
            data['ende_datum'] = datetime.strptime(data['ende_datum'], '%Y-%m-%d').date()

        b = deputat_service.update_betreuung(betreuung_id, **data)

        return jsonify({
            'success': True,
            'data': b.to_dict(),
            'message': 'Betreuung aktualisiert'
        }), 200

    except ValueError as e:
        return jsonify({
            'success': False,
            'message': str(e)
        }), 400
    except Exception as e:
        current_app.logger.error(f"Error: {e}", exc_info=True)
        return jsonify({
            'success': False,
            'message': 'Fehler beim Aktualisieren',
            'error': str(e)
        }), 500


@deputat_api.route('/betreuung/<int:betreuung_id>', methods=['DELETE'])
@jwt_required()
def delete_betreuung(betreuung_id: int):
    """DELETE /api/deputat/betreuung/<id> - Betreuung löschen"""
    try:
        from app.models import DeputatsBetreuung
        b = DeputatsBetreuung.query.get(betreuung_id)

        if not b:
            return jsonify({
                'success': False,
                'message': 'Betreuung nicht gefunden'
            }), 404

        if not kann_abrechnung_zugreifen(b.deputatsabrechnung):
            return jsonify({
                'success': False,
                'message': 'Keine Berechtigung'
            }), 403

        deputat_service.delete_betreuung(betreuung_id)

        return jsonify({
            'success': True,
            'message': 'Betreuung gelöscht'
        }), 200

    except ValueError as e:
        return jsonify({
            'success': False,
            'message': str(e)
        }), 400
    except Exception as e:
        current_app.logger.error(f"Error: {e}", exc_info=True)
        return jsonify({
            'success': False,
            'message': 'Fehler beim Löschen',
            'error': str(e)
        }), 500


# =============================================================================
# WORKFLOW
# =============================================================================

@deputat_api.route('/<int:abrechnung_id>/einreichen', methods=['PUT'])
@jwt_required()
def einreichen(abrechnung_id: int):
    """PUT /api/deputat/<id>/einreichen - Abrechnung einreichen"""
    try:
        abrechnung = deputat_service.get_abrechnung(abrechnung_id)

        if not abrechnung:
            return jsonify({
                'success': False,
                'message': 'Abrechnung nicht gefunden'
            }), 404

        # Nur eigene Abrechnungen einreichen
        if abrechnung.benutzer_id != current_user.id:
            return jsonify({
                'success': False,
                'message': 'Keine Berechtigung'
            }), 403

        abrechnung = deputat_service.einreichen(abrechnung_id)

        return jsonify({
            'success': True,
            'data': abrechnung.to_dict(include_details=True, include_summen=True),
            'message': 'Abrechnung eingereicht'
        }), 200

    except ValueError as e:
        return jsonify({
            'success': False,
            'message': str(e)
        }), 400
    except Exception as e:
        current_app.logger.error(f"Error: {e}", exc_info=True)
        return jsonify({
            'success': False,
            'message': 'Fehler beim Einreichen',
            'error': str(e)
        }), 500


@deputat_api.route('/<int:abrechnung_id>/genehmigen', methods=['PUT'])
@jwt_required()
def genehmigen(abrechnung_id: int):
    """PUT /api/deputat/<id>/genehmigen - Abrechnung genehmigen (Dekan)"""
    try:
        if not require_dekan():
            return jsonify({
                'success': False,
                'message': 'Keine Berechtigung'
            }), 403

        abrechnung = deputat_service.genehmigen(
            abrechnung_id=abrechnung_id,
            genehmiger_id=current_user.id
        )

        return jsonify({
            'success': True,
            'data': abrechnung.to_dict(include_details=True, include_summen=True),
            'message': 'Abrechnung genehmigt'
        }), 200

    except ValueError as e:
        return jsonify({
            'success': False,
            'message': str(e)
        }), 400
    except Exception as e:
        current_app.logger.error(f"Error: {e}", exc_info=True)
        return jsonify({
            'success': False,
            'message': 'Fehler beim Genehmigen',
            'error': str(e)
        }), 500


@deputat_api.route('/<int:abrechnung_id>/ablehnen', methods=['PUT'])
@jwt_required()
def ablehnen(abrechnung_id: int):
    """PUT /api/deputat/<id>/ablehnen - Abrechnung ablehnen (Dekan)"""
    try:
        if not require_dekan():
            return jsonify({
                'success': False,
                'message': 'Keine Berechtigung'
            }), 403

        data = request.get_json() or {}
        grund = data.get('grund')

        abrechnung = deputat_service.ablehnen(
            abrechnung_id=abrechnung_id,
            grund=grund
        )

        return jsonify({
            'success': True,
            'data': abrechnung.to_dict(include_details=True, include_summen=True),
            'message': 'Abrechnung abgelehnt'
        }), 200

    except ValueError as e:
        return jsonify({
            'success': False,
            'message': str(e)
        }), 400
    except Exception as e:
        current_app.logger.error(f"Error: {e}", exc_info=True)
        return jsonify({
            'success': False,
            'message': 'Fehler beim Ablehnen',
            'error': str(e)
        }), 500


@deputat_api.route('/<int:abrechnung_id>/zuruecksetzen', methods=['PUT'])
@jwt_required()
def zuruecksetzen(abrechnung_id: int):
    """PUT /api/deputat/<id>/zuruecksetzen - Abrechnung zurücksetzen"""
    try:
        abrechnung = deputat_service.get_abrechnung(abrechnung_id)

        if not abrechnung:
            return jsonify({
                'success': False,
                'message': 'Abrechnung nicht gefunden'
            }), 404

        # Nur Dekan oder eigene (wenn abgelehnt)
        if current_user.rolle.name != 'dekan':
            if abrechnung.benutzer_id != current_user.id or abrechnung.status != 'abgelehnt':
                return jsonify({
                    'success': False,
                    'message': 'Keine Berechtigung'
                }), 403

        abrechnung = deputat_service.zuruecksetzen(abrechnung_id)

        return jsonify({
            'success': True,
            'data': abrechnung.to_dict(include_details=True, include_summen=True),
            'message': 'Abrechnung zurückgesetzt'
        }), 200

    except ValueError as e:
        return jsonify({
            'success': False,
            'message': str(e)
        }), 400
    except Exception as e:
        current_app.logger.error(f"Error: {e}", exc_info=True)
        return jsonify({
            'success': False,
            'message': 'Fehler beim Zurücksetzen',
            'error': str(e)
        }), 500


# =============================================================================
# STATISTIKEN
# =============================================================================

@deputat_api.route('/statistik', methods=['GET'])
@jwt_required()
def get_statistik():
    """GET /api/deputat/statistik - Statistiken (Dekan)"""
    try:
        if not require_dekan():
            return jsonify({
                'success': False,
                'message': 'Keine Berechtigung'
            }), 403

        planungsphase_id = request.args.get('planungsphase_id', type=int)

        stats = deputat_service.get_statistik(planungsphase_id=planungsphase_id)

        return jsonify({
            'success': True,
            'data': stats
        }), 200

    except Exception as e:
        current_app.logger.error(f"Error: {e}", exc_info=True)
        return jsonify({
            'success': False,
            'message': 'Fehler beim Laden der Statistiken',
            'error': str(e)
        }), 500


# =============================================================================
# PDF EXPORT
# =============================================================================

@deputat_api.route('/<int:abrechnung_id>/pdf', methods=['GET'])
@jwt_required()
def export_pdf(abrechnung_id):
    """GET /api/deputat/<id>/pdf - PDF Export der Abrechnung"""
    from flask import Response

    try:
        user_id = get_jwt_identity()

        # Check permission - user must own the abrechnung or be dekan
        abrechnung = deputat_service.get_by_id(abrechnung_id)
        if not abrechnung:
            return jsonify({
                'success': False,
                'message': 'Abrechnung nicht gefunden'
            }), 404

        is_dekan = require_dekan()
        is_owner = str(abrechnung.benutzer_id) == str(user_id)

        if not is_dekan and not is_owner:
            return jsonify({
                'success': False,
                'message': 'Keine Berechtigung'
            }), 403

        # Generate PDF
        pdf_bytes = deputat_service.generate_pdf(abrechnung_id)

        # Create filename
        benutzer_name = abrechnung.benutzer.username if abrechnung.benutzer else 'unbekannt'
        phase_name = abrechnung.planungsphase.name if abrechnung.planungsphase else 'unbekannt'
        # Clean filename
        safe_name = f"Deputatsabrechnung_{benutzer_name}_{phase_name}".replace(' ', '_').replace('/', '-')

        return Response(
            pdf_bytes,
            mimetype='application/pdf',
            headers={
                'Content-Disposition': f'attachment; filename="{safe_name}.pdf"',
                'Content-Type': 'application/pdf'
            }
        )

    except ValueError as e:
        return jsonify({
            'success': False,
            'message': str(e)
        }), 400
    except Exception as e:
        current_app.logger.error(f"PDF Export Error: {e}", exc_info=True)
        return jsonify({
            'success': False,
            'message': 'Fehler beim PDF-Export',
            'error': str(e)
        }), 500
