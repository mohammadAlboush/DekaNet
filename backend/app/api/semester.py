"""Semester API - CRUD Endpoints"""
"""
Semester API
============
REST API für Semester-Verwaltung.

Endpoints:
    GET    /api/semester              - Alle Semester
    GET    /api/semester/<id>         - Semester Details
    POST   /api/semester              - Semester erstellen (Dekan)
    PUT    /api/semester/<id>         - Semester bearbeiten (Dekan)
    DELETE /api/semester/<id>         - Semester löschen (Dekan)
    POST   /api/semester/<id>/aktivieren    - Semester aktivieren (Dekan)
    POST   /api/semester/<id>/planungsphase - Planungsphase steuern (Dekan)
    GET    /api/semester/aktiv        - Aktives Semester
    GET    /api/semester/planung      - Planungssemester
    GET    /api/semester/<id>/statistik     - Semester-Statistiken
"""

from flask import Blueprint, request
from datetime import date, datetime
from app.api.base import (
    ApiResponse,
    login_required,
    role_required,
    validate_request,
    get_pagination_params,
    get_filter_params
)
from app.services import semester_service
from app.extensions import cache

# Blueprint
semester_api = Blueprint('semester', __name__, url_prefix='/api/semester')


# =========================================================================
# GET ENDPOINTS
# =========================================================================

@semester_api.route('/', methods=['GET'])
@login_required
@cache.cached(timeout=600, query_string=True)  # 10 Minuten Cache, beachtet Query-Parameter
def get_alle_semester():
    """
    GET /api/semester

    Holt alle Semester mit optionalen Filtern.

    Query Parameters:
        ?page=1&per_page=20
        ?ist_aktiv=true

    Returns:
        200: Liste von Semestern
    """
    try:
        page, per_page = get_pagination_params()

        # Filter
        filters = {}
        if request.args.get('ist_aktiv'):
            filters['ist_aktiv'] = request.args.get('ist_aktiv').lower() == 'true'
        
        # Paginate
        result = semester_service.paginate(
            page=page,
            per_page=per_page,
            **filters
        )
        
        # Format items
        items = [s.to_dict() for s in result['items']]
        
        return ApiResponse.paginated(
            items=items,
            total=result['total'],
            page=result['page'],
            per_page=result['per_page']
        )
    
    except Exception as e:
        return ApiResponse.error(
            message='Fehler beim Laden der Semester',
            errors=[str(e)],
            status_code=500
        )


@semester_api.route('/<int:semester_id>', methods=['GET'])
@login_required
def get_semester(semester_id: int):
    """
    GET /api/semester/<id>
    
    Holt ein Semester mit Details.
    
    Returns:
        200: Semester Details
        404: Semester nicht gefunden
    """
    try:
        semester = semester_service.get_by_id(semester_id)
        
        if not semester:
            return ApiResponse.error(
                message='Semester nicht gefunden',
                status_code=404
            )
        
        return ApiResponse.success(
            data=semester.to_dict()
        )
    
    except Exception as e:
        return ApiResponse.error(
            message='Fehler beim Laden des Semesters',
            errors=[str(e)],
            status_code=500
        )


@semester_api.route('/aktiv', methods=['GET'])
@login_required
def get_aktives_semester():
    """
    GET /api/semester/aktiv
    
    Holt das aktuell aktive Semester.
    
    Returns:
        200: Aktives Semester
        404: Kein aktives Semester
    """
    try:
        semester = semester_service.get_aktives_semester()
        
        if not semester:
            return ApiResponse.error(
                message='Kein aktives Semester gefunden',
                status_code=404
            )
        
        return ApiResponse.success(
            data=semester.to_dict()
        )
    
    except Exception as e:
        return ApiResponse.error(
            message='Fehler beim Laden des aktiven Semesters',
            errors=[str(e)],
            status_code=500
        )


@semester_api.route('/planung', methods=['GET'])
@login_required
def get_planungssemester():
    """
    GET /api/semester/planung

    Holt das Semester mit offener Planungsphase.

    Returns:
        200: Planungssemester oder null wenn keine Planungsphase aktiv
    """
    try:
        semester = semester_service.get_planungssemester()

        # Graceful Response: Kein Fehler wenn keine Planungsphase, sondern null
        if not semester:
            return ApiResponse.success(
                data=None,
                message='Keine offene Planungsphase'
            )

        return ApiResponse.success(
            data=semester.to_dict()
        )

    except Exception as e:
        return ApiResponse.error(
            message='Fehler beim Laden des Planungssemesters',
            errors=[str(e)],
            status_code=500
        )


# NOTE: /auto-vorschlag Endpoint wurde entfernt - automatische Semester-Erkennung
# wird nicht mehr verwendet. Der Dekan wählt Semester-Typ und Jahr manuell.


@semester_api.route('/<int:semester_id>/statistik', methods=['GET'])
@login_required
def get_semester_statistik(semester_id: int):
    """
    GET /api/semester/<id>/statistik
    
    Holt Statistiken für ein Semester.
    
    Returns:
        200: Semester-Statistiken
        404: Semester nicht gefunden
    """
    try:
        statistik = semester_service.get_statistik(semester_id)
        
        if not statistik:
            return ApiResponse.error(
                message='Semester nicht gefunden',
                status_code=404
            )
        
        return ApiResponse.success(
            data=statistik
        )
    
    except Exception as e:
        return ApiResponse.error(
            message='Fehler beim Laden der Statistiken',
            errors=[str(e)],
            status_code=500
        )


# =========================================================================
# POST ENDPOINTS (Create)
# =========================================================================

@semester_api.route('/', methods=['POST'])
@role_required('dekan')
@validate_request(['bezeichnung', 'kuerzel', 'start_datum', 'ende_datum'])
def create_semester():
    """
    POST /api/semester
    
    Erstellt ein neues Semester (nur Dekan).
    
    Request Body:
        {
            "bezeichnung": "Wintersemester 2025/2026",
            "kuerzel": "WS2025",
            "start_datum": "2025-10-01",
            "ende_datum": "2026-03-31",
            "vorlesungsbeginn": "2025-10-15",  # Optional
            "vorlesungsende": "2026-02-15",    # Optional
            "ist_aktiv": false,                # Optional
            "ist_planungsphase": false         # Optional
        }
    
    Returns:
        201: Semester erstellt
        400: Validierungsfehler
    """
    try:
        data = request.get_json()
        
        # Parse Dates
        start_datum = datetime.strptime(data['start_datum'], '%Y-%m-%d').date()
        ende_datum = datetime.strptime(data['ende_datum'], '%Y-%m-%d').date()
        
        vorlesungsbeginn = None
        if 'vorlesungsbeginn' in data:
            vorlesungsbeginn = datetime.strptime(data['vorlesungsbeginn'], '%Y-%m-%d').date()
        
        vorlesungsende = None
        if 'vorlesungsende' in data:
            vorlesungsende = datetime.strptime(data['vorlesungsende'], '%Y-%m-%d').date()
        
        # Create Semester
        semester = semester_service.create_semester(
            bezeichnung=data['bezeichnung'],
            kuerzel=data['kuerzel'],
            start_datum=start_datum,
            ende_datum=ende_datum,
            vorlesungsbeginn=vorlesungsbeginn,
            vorlesungsende=vorlesungsende,
            ist_aktiv=data.get('ist_aktiv', False),
            ist_planungsphase=data.get('ist_planungsphase', False)
        )
        
        return ApiResponse.success(
            data=semester.to_dict(),
            message='Semester erfolgreich erstellt',
            status_code=201
        )
    
    except ValueError as e:
        return ApiResponse.error(
            message='Validierungsfehler',
            errors=[str(e)],
            status_code=400
        )
    except Exception as e:
        return ApiResponse.error(
            message='Fehler beim Erstellen des Semesters',
            errors=[str(e)],
            status_code=500
        )


# =========================================================================
# PUT ENDPOINTS (Update)
# =========================================================================

@semester_api.route('/<int:semester_id>', methods=['PUT'])
@role_required('dekan')
def update_semester(semester_id: int):
    """
    PUT /api/semester/<id>
    
    Updated ein Semester (nur Dekan).
    
    Request Body:
        {
            "bezeichnung": "...",
            "start_datum": "2025-10-01",
            ...
        }
    
    Returns:
        200: Semester updated
        404: Semester nicht gefunden
        400: Validierungsfehler
    """
    try:
        data = request.get_json()
        
        # Parse Dates if present
        if 'start_datum' in data:
            data['start_datum'] = datetime.strptime(data['start_datum'], '%Y-%m-%d').date()
        
        if 'ende_datum' in data:
            data['ende_datum'] = datetime.strptime(data['ende_datum'], '%Y-%m-%d').date()
        
        if 'vorlesungsbeginn' in data:
            data['vorlesungsbeginn'] = datetime.strptime(data['vorlesungsbeginn'], '%Y-%m-%d').date()
        
        if 'vorlesungsende' in data:
            data['vorlesungsende'] = datetime.strptime(data['vorlesungsende'], '%Y-%m-%d').date()
        
        # Update
        semester = semester_service.update_semester(semester_id, **data)
        
        if not semester:
            return ApiResponse.error(
                message='Semester nicht gefunden',
                status_code=404
            )
        
        return ApiResponse.success(
            data=semester.to_dict(),
            message='Semester erfolgreich aktualisiert'
        )
    
    except ValueError as e:
        return ApiResponse.error(
            message='Validierungsfehler',
            errors=[str(e)],
            status_code=400
        )
    except Exception as e:
        return ApiResponse.error(
            message='Fehler beim Aktualisieren des Semesters',
            errors=[str(e)],
            status_code=500
        )


# =========================================================================
# POST ENDPOINTS (Actions)
# =========================================================================

@semester_api.route('/<int:semester_id>/aktivieren', methods=['POST'])
@role_required('dekan')
def aktiviere_semester(semester_id: int):
    """
    POST /api/semester/<id>/aktivieren
    
    Aktiviert ein Semester (nur Dekan).
    
    Request Body:
        {
            "planungsphase": true  # Optional
        }
    
    Returns:
        200: Semester aktiviert
        404: Semester nicht gefunden
    """
    try:
        data = request.get_json() or {}
        planungsphase = data.get('planungsphase', True)
        
        semester = semester_service.aktiviere_semester(
            semester_id,
            planungsphase=planungsphase
        )
        
        return ApiResponse.success(
            data=semester.to_dict(),
            message='Semester erfolgreich aktiviert'
        )
    
    except ValueError as e:
        return ApiResponse.error(
            message='Validierungsfehler',
            errors=[str(e)],
            status_code=400
        )
    except Exception as e:
        return ApiResponse.error(
            message='Fehler beim Aktivieren des Semesters',
            errors=[str(e)],
            status_code=500
        )


@semester_api.route('/<int:semester_id>/planungsphase', methods=['POST'])
@role_required('dekan')
@validate_request(['aktion'])
def steuere_planungsphase(semester_id: int):
    """
    POST /api/semester/<id>/planungsphase
    
    Öffnet oder schließt Planungsphase (nur Dekan).
    
    Request Body:
        {
            "aktion": "oeffnen"  # oder "schliessen"
        }
    
    Returns:
        200: Planungsphase gesteuert
        400: Ungültige Aktion
    """
    try:
        data = request.get_json()
        aktion = data['aktion']
        
        if aktion == 'oeffnen':
            semester = semester_service.oeffne_planungsphase(semester_id)
            message = 'Planungsphase erfolgreich geöffnet'
        elif aktion == 'schliessen':
            semester = semester_service.schliesse_planungsphase(semester_id)
            message = 'Planungsphase erfolgreich geschlossen'
        else:
            return ApiResponse.error(
                message='Ungültige Aktion',
                errors=['Aktion muss "oeffnen" oder "schliessen" sein'],
                status_code=400
            )
        
        return ApiResponse.success(
            data=semester.to_dict(),
            message=message
        )
    
    except ValueError as e:
        return ApiResponse.error(
            message='Validierungsfehler',
            errors=[str(e)],
            status_code=400
        )
    except Exception as e:
        return ApiResponse.error(
            message='Fehler beim Steuern der Planungsphase',
            errors=[str(e)],
            status_code=500
        )


# =========================================================================
# DELETE ENDPOINTS
# =========================================================================

@semester_api.route('/<int:semester_id>', methods=['DELETE'])
@role_required('dekan')
def delete_semester(semester_id: int):
    """
    DELETE /api/semester/<id>
    
    Löscht ein Semester (nur Dekan).
    
    Query Parameters:
        ?force=true  # Erzwingt Löschen auch mit Planungen
    
    Returns:
        200: Semester gelöscht
        400: Semester kann nicht gelöscht werden
        404: Semester nicht gefunden
    """
    try:
        force = request.args.get('force', 'false').lower() == 'true'
        
        success = semester_service.delete_semester(semester_id, force=force)
        
        if not success:
            return ApiResponse.error(
                message='Semester nicht gefunden',
                status_code=404
            )
        
        return ApiResponse.success(
            message='Semester erfolgreich gelöscht'
        )
    
    except ValueError as e:
        return ApiResponse.error(
            message='Semester kann nicht gelöscht werden',
            errors=[str(e)],
            status_code=400
        )
    except Exception as e:
        return ApiResponse.error(
            message='Fehler beim Löschen des Semesters',
            errors=[str(e)],
            status_code=500
        )