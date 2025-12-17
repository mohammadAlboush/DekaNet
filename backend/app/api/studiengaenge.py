"""
Studiengänge API
================
REST API für Studiengänge und Prüfungsordnungen.

Endpoints:
    GET /api/studiengaenge              - Alle Studiengänge
    GET /api/studiengaenge/<id>         - Studiengang Details
    GET /api/studiengaenge/<id>/module  - Studiengang Module
    GET /api/pruefungsordnungen         - Alle Prüfungsordnungen
    GET /api/pruefungsordnungen/<id>    - PO Details
"""

from flask import Blueprint, request
from app.api.base import (
    ApiResponse,
    login_required
)
from app.models import Studiengang, Pruefungsordnung, Modul

# Blueprint
studiengaenge_api = Blueprint('studiengaenge', __name__, url_prefix='/api/studiengaenge')
po_api = Blueprint('pruefungsordnungen', __name__, url_prefix='/api/pruefungsordnungen')


# =========================================================================
# STUDIENGÄNGE ENDPOINTS
# =========================================================================

@studiengaenge_api.route('/', methods=['GET'])
@login_required
def get_alle_studiengaenge():
    """
    GET /api/studiengaenge
    
    Holt alle Studiengänge.
    
    Query Parameters:
        ?aktiv=true
        
    Returns:
        200: Liste von Studiengängen
    """
    try:
        aktiv = request.args.get('aktiv')
        
        if aktiv is not None:
            aktiv = aktiv.lower() == 'true'
            studiengaenge = Studiengang.query.filter_by(aktiv=aktiv).all()
        else:
            studiengaenge = Studiengang.query.all()
        
        # Format
        items = [sg.to_dict() for sg in studiengaenge]
        
        return ApiResponse.success(
            data=items,
            message=f'{len(items)} Studiengang/Studiengänge gefunden'
        )
    
    except Exception as e:
        return ApiResponse.error(
            message='Fehler beim Laden der Studiengänge',
            errors=[str(e)],
            status_code=500
        )


@studiengaenge_api.route('/<int:studiengang_id>', methods=['GET'])
@login_required
def get_studiengang(studiengang_id: int):
    """
    GET /api/studiengaenge/<id>
    
    Holt Studiengang mit Details.
    
    Returns:
        200: Studiengang Details
        404: Studiengang nicht gefunden
    """
    try:
        studiengang = Studiengang.query.get(studiengang_id)
        
        if not studiengang:
            return ApiResponse.error(
                message='Studiengang nicht gefunden',
                status_code=404
            )
        
        data = studiengang.to_dict()
        data['pruefungsordnungen'] = [po.to_dict() for po in studiengang.get_pruefungsordnungen()]
        
        return ApiResponse.success(data=data)
    
    except Exception as e:
        return ApiResponse.error(
            message='Fehler beim Laden des Studiengangs',
            errors=[str(e)],
            status_code=500
        )


@studiengaenge_api.route('/<int:studiengang_id>/module', methods=['GET'])
@login_required
def get_studiengang_module(studiengang_id: int):
    """
    GET /api/studiengaenge/<id>/module
    
    Holt alle Module eines Studiengangs.
    
    Query Parameters:
        ?po_id=1  # Optional: Filter nach Prüfungsordnung
        
    Returns:
        200: Liste von Modulen
        404: Studiengang nicht gefunden
    """
    try:
        studiengang = Studiengang.query.get(studiengang_id)
        
        if not studiengang:
            return ApiResponse.error(
                message='Studiengang nicht gefunden',
                status_code=404
            )
        
        po_id = request.args.get('po_id', type=int)
        
        # Get modules for this studiengang
        module = studiengang.get_module(po_id=po_id)
        
        # Format
        items = [m.to_dict() for m in module]
        
        return ApiResponse.success(
            data=items,
            message=f'{len(items)} Modul(e) gefunden'
        )
    
    except Exception as e:
        return ApiResponse.error(
            message='Fehler beim Laden der Module',
            errors=[str(e)],
            status_code=500
        )


# =========================================================================
# PRÜFUNGSORDNUNGEN ENDPOINTS
# =========================================================================

@po_api.route('/', methods=['GET'])
@login_required
def get_alle_pos():
    """
    GET /api/pruefungsordnungen
    
    Holt alle Prüfungsordnungen.
    
    Query Parameters:
        ?aktiv=true
        
    Returns:
        200: Liste von Prüfungsordnungen
    """
    try:
        # Note: aktiv parameter was read but never used
        # If filtering by aktiv is needed in the future, implement here

        query = Pruefungsordnung.query

        # Note: Since there's no studiengang_id in pruefungsordnung table,
        # we can't filter by studiengang here

        pos = query.all()
        
        # Format
        items = [po.to_dict() for po in pos]
        
        return ApiResponse.success(
            data=items,
            message=f'{len(items)} Prüfungsordnung(en) gefunden'
        )
    
    except Exception as e:
        return ApiResponse.error(
            message='Fehler beim Laden der Prüfungsordnungen',
            errors=[str(e)],
            status_code=500
        )


@po_api.route('/<int:po_id>', methods=['GET'])
@login_required
def get_po(po_id: int):
    """
    GET /api/pruefungsordnungen/<id>
    
    Holt Prüfungsordnung mit Details.
    
    Returns:
        200: PO Details
        404: PO nicht gefunden
    """
    try:
        po = Pruefungsordnung.query.get(po_id)
        
        if not po:
            return ApiResponse.error(
                message='Prüfungsordnung nicht gefunden',
                status_code=404
            )
        
        # Details
        data = po.to_dict()
        data['anzahl_module'] = po.module.count()
        
        return ApiResponse.success(data=data)
    
    except Exception as e:
        return ApiResponse.error(
            message='Fehler beim Laden der Prüfungsordnung',
            errors=[str(e)],
            status_code=500
        )


@po_api.route('/<int:po_id>/module', methods=['GET'])
@login_required
def get_po_module(po_id: int):
    """
    GET /api/pruefungsordnungen/<id>/module
    
    Holt alle Module einer Prüfungsordnung.
    
    Query Parameters:
        ?turnus=Wintersemester
        
    Returns:
        200: Liste von Modulen
        404: PO nicht gefunden
    """
    try:
        po = Pruefungsordnung.query.get(po_id)
        
        if not po:
            return ApiResponse.error(
                message='Prüfungsordnung nicht gefunden',
                status_code=404
            )
        
        turnus = request.args.get('turnus')
        
        if turnus:
            module = Modul.query.filter_by(po_id=po_id, turnus=turnus).all()
        else:
            module = po.module.all()
        
        # Format
        items = [m.to_dict() for m in module]
        
        return ApiResponse.success(
            data=items,
            message=f'{len(items)} Modul(e) gefunden'
        )
    
    except Exception as e:
        return ApiResponse.error(
            message='Fehler beim Laden der Module',
            errors=[str(e)],
            status_code=500
        )