"""
backend/app/api/auftraege.py - Semesteraufträge API
===================================================

Feature 2: REST API für Semesteraufträge

Endpoints:
- GET /api/auftraege/ - Liste aller Aufträge (Master-Liste)
- POST /api/auftraege/ - Neuen Auftrag erstellen (nur Dekan)
- PUT /api/auftraege/<id> - Auftrag bearbeiten (nur Dekan)
- DELETE /api/auftraege/<id> - Auftrag löschen (nur Dekan)

- GET /api/auftraege/semester/<semester_id> - Aufträge für Semester
- POST /api/auftraege/semester/<semester_id>/beantragen - Auftrag beantragen (Professor)
- PUT /api/auftraege/semester-auftrag/<id>/genehmigen - Genehmigen (Dekan)
- PUT /api/auftraege/semester-auftrag/<id>/ablehnen - Ablehnen (Dekan)
- DELETE /api/auftraege/semester-auftrag/<id> - Löschen

- GET /api/auftraege/meine - Meine Aufträge (aktueller User)
- GET /api/auftraege/beantragt - Alle beantragten (Dekan-View)
- GET /api/auftraege/statistik - Statistiken
"""

from flask import Blueprint, request, jsonify, current_app
from flask_jwt_extended import jwt_required, get_jwt_identity, current_user
from app.services.auftrag_service import auftrag_service
from app.extensions import db
from app.api.base import ApiResponse

# Blueprint Definition
auftrag_api = Blueprint('auftraege', __name__, url_prefix='/api/auftraege')


@auftrag_api.before_request
def log_request():
    """Log every request"""
    current_app.logger.info(f"[AuftragAPI] {request.method} {request.path}")


# =========================================================================
# AUFTRAG MASTER-LISTE (Dekan-Verwaltung)
# =========================================================================

@auftrag_api.route('/', methods=['GET'])
@jwt_required()
def get_alle_auftraege():
    """GET /api/auftraege/ - Holt alle Aufträge aus Master-Liste"""
    try:
        nur_aktive = request.args.get('nur_aktive', 'true').lower() == 'true'

        auftraege = auftrag_service.get_all_auftraege(nur_aktive=nur_aktive)

        return jsonify({
            'success': True,
            'data': [a.to_dict() for a in auftraege],
            'message': f'{len(auftraege)} Aufträge gefunden'
        }), 200

    except Exception as e:
        return ApiResponse.internal_error(
            message='Fehler beim Laden der Auftraege',
            exception=e,
            log_context='AuftragAPI.get_alle'
        )


@auftrag_api.route('/', methods=['POST'])
@jwt_required()
def create_auftrag():
    """POST /api/auftraege/ - Erstellt neuen Auftrag (nur Dekan)"""
    try:
        if current_user.rolle.name != 'dekan':
            return jsonify({
                'success': False,
                'message': 'Keine Berechtigung'
            }), 403

        data = request.get_json()

        if 'name' not in data:
            return jsonify({
                'success': False,
                'message': 'Name ist erforderlich'
            }), 400

        auftrag = auftrag_service.create_auftrag(
            name=data['name'],
            standard_sws=data.get('standard_sws', 0.0),
            beschreibung=data.get('beschreibung'),
            sortierung=data.get('sortierung')
        )

        return jsonify({
            'success': True,
            'data': auftrag.to_dict(),
            'message': 'Auftrag erstellt'
        }), 201

    except ValueError as e:
        return jsonify({
            'success': False,
            'message': str(e)
        }), 400
    except Exception as e:
        return ApiResponse.internal_error(
            message='Fehler beim Erstellen',
            exception=e,
            log_context='AuftragAPI.create'
        )


@auftrag_api.route('/<int:auftrag_id>', methods=['PUT'])
@jwt_required()
def update_auftrag(auftrag_id: int):
    """PUT /api/auftraege/<id> - Aktualisiert Auftrag (nur Dekan)"""
    try:
        if current_user.rolle.name != 'dekan':
            return jsonify({
                'success': False,
                'message': 'Keine Berechtigung'
            }), 403

        data = request.get_json()

        auftrag = auftrag_service.update_auftrag(auftrag_id, **data)

        if not auftrag:
            return jsonify({
                'success': False,
                'message': 'Auftrag nicht gefunden'
            }), 404

        return jsonify({
            'success': True,
            'data': auftrag.to_dict(),
            'message': 'Auftrag aktualisiert'
        }), 200

    except Exception as e:
        return ApiResponse.internal_error(
            message='Fehler beim Aktualisieren',
            exception=e,
            log_context='AuftragAPI.update'
        )


@auftrag_api.route('/<int:auftrag_id>', methods=['DELETE'])
@jwt_required()
def delete_auftrag(auftrag_id: int):
    """DELETE /api/auftraege/<id> - Löscht Auftrag (nur Dekan)"""
    try:
        if current_user.rolle.name != 'dekan':
            return jsonify({
                'success': False,
                'message': 'Keine Berechtigung'
            }), 403

        success = auftrag_service.delete_auftrag(auftrag_id)

        if not success:
            return jsonify({
                'success': False,
                'message': 'Auftrag nicht gefunden'
            }), 404

        return jsonify({
            'success': True,
            'message': 'Auftrag gelöscht'
        }), 200

    except ValueError as e:
        return jsonify({
            'success': False,
            'message': str(e)
        }), 409
    except Exception as e:
        return ApiResponse.internal_error(
            message='Fehler beim Loeschen',
            exception=e,
            log_context='AuftragAPI.delete'
        )


# =========================================================================
# SEMESTER-AUFTRÄGE (Professor & Dekan)
# =========================================================================

@auftrag_api.route('/semester/<int:semester_id>', methods=['GET'])
@jwt_required()
def get_auftraege_fuer_semester(semester_id: int):
    """GET /api/auftraege/semester/<id> - Aufträge für Semester"""
    try:
        dozent_id = request.args.get('dozent_id', type=int)
        status = request.args.get('status')

        # Wenn kein dozent_id angegeben, nutze aktuellen User
        if not dozent_id and current_user.dozent:
            dozent_id = current_user.dozent.id

        auftraege = auftrag_service.get_auftraege_fuer_semester(
            semester_id=semester_id,
            dozent_id=dozent_id,
            status=status
        )

        return jsonify({
            'success': True,
            'data': [a.to_dict(include_details=True) for a in auftraege],
            'message': f'{len(auftraege)} Aufträge gefunden'
        }), 200

    except Exception as e:
        return ApiResponse.internal_error(
            message='Fehler beim Laden',
            exception=e,
            log_context='AuftragAPI'
        )


@auftrag_api.route('/semester/<int:semester_id>/beantragen', methods=['POST'])
@jwt_required()
def beantrage_auftrag(semester_id: int):
    """POST /api/auftraege/semester/<id>/beantragen - Auftrag beantragen"""
    try:
        data = request.get_json()

        if 'auftrag_id' not in data:
            return jsonify({
                'success': False,
                'message': 'auftrag_id ist erforderlich'
            }), 400

        # Dozent muss existieren
        if not current_user.dozent:
            return jsonify({
                'success': False,
                'message': 'Kein Dozent-Account vorhanden'
            }), 403

        semester_auftrag = auftrag_service.beantrage_auftrag(
            semester_id=semester_id,
            auftrag_id=data['auftrag_id'],
            dozent_id=current_user.dozent.id,
            beantragt_von_id=current_user.id,
            sws=data.get('sws'),
            anmerkung=data.get('anmerkung')
        )

        return jsonify({
            'success': True,
            'data': semester_auftrag.to_dict(include_details=True),
            'message': 'Auftrag beantragt'
        }), 201

    except ValueError as e:
        return jsonify({
            'success': False,
            'message': str(e)
        }), 400
    except Exception as e:
        return ApiResponse.internal_error(
            message='Fehler beim Beantragen',
            exception=e,
            log_context='AuftragAPI.beantragen'
        )


@auftrag_api.route('/semester-auftrag/<int:semester_auftrag_id>/genehmigen', methods=['PUT'])
@jwt_required()
def genehmige_auftrag(semester_auftrag_id: int):
    """PUT /api/auftraege/semester-auftrag/<id>/genehmigen - Genehmigen (Dekan)"""
    try:
        if current_user.rolle.name != 'dekan':
            return jsonify({
                'success': False,
                'message': 'Keine Berechtigung'
            }), 403

        semester_auftrag = auftrag_service.genehmige_auftrag(
            semester_auftrag_id=semester_auftrag_id,
            genehmigt_von_id=current_user.id
        )

        return jsonify({
            'success': True,
            'data': semester_auftrag.to_dict(include_details=True),
            'message': 'Auftrag genehmigt'
        }), 200

    except ValueError as e:
        return jsonify({
            'success': False,
            'message': str(e)
        }), 400
    except Exception as e:
        return ApiResponse.internal_error(
            message='Fehler beim Genehmigen',
            exception=e,
            log_context='AuftragAPI.genehmigen'
        )


@auftrag_api.route('/semester-auftrag/<int:semester_auftrag_id>/ablehnen', methods=['PUT'])
@jwt_required()
def lehne_auftrag_ab(semester_auftrag_id: int):
    """PUT /api/auftraege/semester-auftrag/<id>/ablehnen - Ablehnen (Dekan)"""
    try:
        if current_user.rolle.name != 'dekan':
            return jsonify({
                'success': False,
                'message': 'Keine Berechtigung'
            }), 403

        data = request.get_json()
        grund = data.get('grund') if data else None

        semester_auftrag = auftrag_service.lehne_auftrag_ab(
            semester_auftrag_id=semester_auftrag_id,
            genehmigt_von_id=current_user.id,
            grund=grund
        )

        return jsonify({
            'success': True,
            'data': semester_auftrag.to_dict(include_details=True),
            'message': 'Auftrag abgelehnt'
        }), 200

    except ValueError as e:
        return jsonify({
            'success': False,
            'message': str(e)
        }), 400
    except Exception as e:
        return ApiResponse.internal_error(
            message='Fehler beim Ablehnen',
            exception=e,
            log_context='AuftragAPI.ablehnen'
        )


@auftrag_api.route('/semester-auftrag/<int:semester_auftrag_id>', methods=['PUT'])
@jwt_required()
def update_semester_auftrag(semester_auftrag_id: int):
    """PUT /api/auftraege/semester-auftrag/<id> - Aktualisiert SWS/Anmerkung"""
    try:
        # Nur Dekan oder eigener Antrag
        from app.models import SemesterAuftrag
        semester_auftrag = SemesterAuftrag.query.get(semester_auftrag_id)

        if not semester_auftrag:
            return jsonify({
                'success': False,
                'message': 'Semester-Auftrag nicht gefunden'
            }), 404

        # Berechtigung prüfen
        ist_dekan = current_user.rolle.name == 'dekan'
        ist_eigener = semester_auftrag.beantragt_von == current_user.id

        if not (ist_dekan or ist_eigener):
            return jsonify({
                'success': False,
                'message': 'Keine Berechtigung'
            }), 403

        data = request.get_json()

        updated = auftrag_service.update_semester_auftrag(
            semester_auftrag_id,
            **data
        )

        return jsonify({
            'success': True,
            'data': updated.to_dict(include_details=True),
            'message': 'Semester-Auftrag aktualisiert'
        }), 200

    except Exception as e:
        return ApiResponse.internal_error(
            message='Fehler beim Aktualisieren',
            exception=e,
            log_context='AuftragAPI.update'
        )


@auftrag_api.route('/semester-auftrag/<int:semester_auftrag_id>', methods=['DELETE'])
@jwt_required()
def delete_semester_auftrag(semester_auftrag_id: int):
    """DELETE /api/auftraege/semester-auftrag/<id> - Löscht Semester-Auftrag"""
    try:
        # Nur Dekan oder eigener Antrag (und Status = beantragt)
        from app.models import SemesterAuftrag
        semester_auftrag = SemesterAuftrag.query.get(semester_auftrag_id)

        if not semester_auftrag:
            return jsonify({
                'success': False,
                'message': 'Semester-Auftrag nicht gefunden'
            }), 404

        # Berechtigung prüfen
        ist_dekan = current_user.rolle.name == 'dekan'
        ist_eigener_und_beantragt = (
            semester_auftrag.beantragt_von == current_user.id and
            semester_auftrag.status == 'beantragt'
        )

        if not (ist_dekan or ist_eigener_und_beantragt):
            return jsonify({
                'success': False,
                'message': 'Keine Berechtigung'
            }), 403

        success = auftrag_service.delete_semester_auftrag(semester_auftrag_id)

        return jsonify({
            'success': True,
            'message': 'Semester-Auftrag gelöscht'
        }), 200

    except Exception as e:
        return ApiResponse.internal_error(
            message='Fehler beim Loeschen',
            exception=e,
            log_context='AuftragAPI.delete'
        )


# =========================================================================
# HELPER ENDPOINTS
# =========================================================================

@auftrag_api.route('/meine', methods=['GET'])
@jwt_required()
def get_meine_auftraege():
    """GET /api/auftraege/meine - Meine Aufträge (aktueller User)"""
    try:
        if not current_user.dozent:
            return jsonify({
                'success': False,
                'message': 'Kein Dozent-Account vorhanden'
            }), 403

        semester_id = request.args.get('semester_id', type=int)

        auftraege = auftrag_service.get_auftraege_fuer_dozent(
            dozent_id=current_user.dozent.id,
            semester_id=semester_id
        )

        return jsonify({
            'success': True,
            'data': [a.to_dict(include_details=True) for a in auftraege],
            'message': f'{len(auftraege)} Aufträge gefunden'
        }), 200

    except Exception as e:
        return ApiResponse.internal_error(
            message='Fehler beim Laden',
            exception=e,
            log_context='AuftragAPI'
        )


@auftrag_api.route('/beantragt', methods=['GET'])
@jwt_required()
def get_beantragte_auftraege():
    """GET /api/auftraege/beantragt - Alle beantragten (Dekan-View)"""
    try:
        if current_user.rolle.name != 'dekan':
            return jsonify({
                'success': False,
                'message': 'Keine Berechtigung'
            }), 403

        semester_id = request.args.get('semester_id', type=int)

        auftraege = auftrag_service.get_beantragte_auftraege(semester_id=semester_id)

        return jsonify({
            'success': True,
            'data': [a.to_dict(include_details=True) for a in auftraege],
            'message': f'{len(auftraege)} beantragte Aufträge'
        }), 200

    except Exception as e:
        return ApiResponse.internal_error(
            message='Fehler beim Laden',
            exception=e,
            log_context='AuftragAPI'
        )


@auftrag_api.route('/statistik', methods=['GET'])
@jwt_required()
def get_statistik():
    """GET /api/auftraege/statistik - Statistiken"""
    try:
        semester_id = request.args.get('semester_id', type=int)

        stats = auftrag_service.get_statistik(semester_id=semester_id)

        return jsonify({
            'success': True,
            'data': stats
        }), 200

    except Exception as e:
        return ApiResponse.internal_error(
            message='Fehler beim Laden der Statistiken',
            exception=e,
            log_context='AuftragAPI.statistik'
        )
