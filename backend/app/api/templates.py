"""
Templates API
=============

REST API für Planungs-Templates.

Ermöglicht Professoren, Standard-Module-Konfigurationen für
Winter- und Sommersemester zu speichern und bei neuen Planungen
automatisch zu laden.

Endpoints:
    GET    /api/templates                     - Alle eigenen Templates
    GET    /api/templates/<id>                - Template Details
    GET    /api/templates/semester/<typ>      - Template für Semestertyp
    POST   /api/templates                     - Template erstellen
    PUT    /api/templates/<id>                - Template bearbeiten
    DELETE /api/templates/<id>                - Template löschen

    POST   /api/templates/<id>/modul          - Modul hinzufügen
    PUT    /api/templates/<id>/modul/<mid>    - Modul bearbeiten
    DELETE /api/templates/<id>/modul/<mid>    - Modul entfernen

    POST   /api/templates/<id>/aus-planung    - Template aus Planung erstellen
    POST   /api/templates/<id>/auf-planung    - Template auf Planung anwenden
"""

from flask import Blueprint, request
from app.api.base import (
    ApiResponse,
    login_required,
    get_current_user
)
from app.services import template_service
from app.extensions import db

# Blueprint
template_api = Blueprint('templates', __name__, url_prefix='/api/templates')

# Konstanten
VALID_SEMESTER_TYPEN = {'winter', 'sommer'}


# =========================================================================
# GET ENDPOINTS - Templates abrufen
# =========================================================================

@template_api.route('/', methods=['GET'])
@login_required
def get_eigene_templates():
    """
    GET /api/templates

    Holt alle eigenen Templates.

    Returns:
        200: Liste von Templates
    """
    try:
        user = get_current_user()
        templates = template_service.get_user_templates(user.id)

        items = [t.to_dict(include_module=True) for t in templates]

        return ApiResponse.success(
            data=items,
            message=f'{len(items)} Template(s) gefunden'
        )

    except Exception as e:
        return ApiResponse.error(
            message='Fehler beim Laden der Templates',
            errors=[str(e)],
            status_code=500
        )


@template_api.route('/<int:template_id>', methods=['GET'])
@login_required
def get_template_details(template_id: int):
    """
    GET /api/templates/<id>

    Holt Template-Details mit allen Modulen.

    Returns:
        200: Template mit Modulen
        404: Template nicht gefunden
    """
    try:
        user = get_current_user()
        template = template_service.get_template(template_id)

        if not template:
            return ApiResponse.error(
                message='Template nicht gefunden',
                status_code=404
            )

        # Prüfe Berechtigung
        if template.benutzer_id != user.id:
            return ApiResponse.error(
                message='Keine Berechtigung für dieses Template',
                status_code=403
            )

        return ApiResponse.success(
            data=template.to_dict(include_module=True)
        )

    except Exception as e:
        return ApiResponse.error(
            message='Fehler beim Laden des Templates',
            errors=[str(e)],
            status_code=500
        )


@template_api.route('/semester/<semester_typ>', methods=['GET'])
@login_required
def get_template_for_semester(semester_typ: str):
    """
    GET /api/templates/semester/<typ>

    Holt das aktive Template für einen Semestertyp.

    Args:
        semester_typ: 'winter' oder 'sommer'

    Returns:
        200: Template oder null wenn keins existiert
    """
    try:
        user = get_current_user()

        semester_typ = semester_typ.lower()
        if semester_typ not in VALID_SEMESTER_TYPEN:
            return ApiResponse.error(
                message=f'Ungültiger Semestertyp. Erlaubt: {", ".join(VALID_SEMESTER_TYPEN)}',
                status_code=400
            )

        template = template_service.get_template_for_semester(user.id, semester_typ)

        if template:
            return ApiResponse.success(
                data=template.to_dict(include_module=True)
            )
        else:
            return ApiResponse.success(
                data=None,
                message=f'Kein Template für {semester_typ}semester vorhanden'
            )

    except Exception as e:
        return ApiResponse.error(
            message='Fehler beim Laden des Templates',
            errors=[str(e)],
            status_code=500
        )


# =========================================================================
# CREATE/UPDATE ENDPOINTS
# =========================================================================

@template_api.route('/', methods=['POST'])
@login_required
def create_template():
    """
    POST /api/templates

    Erstellt ein neues Template.

    Body:
        {
            "semester_typ": "winter|sommer",
            "name": "Mein Template",
            "beschreibung": "Optional"
        }

    Returns:
        201: Neues Template erstellt
        400: Validierungsfehler
        409: Template existiert bereits
    """
    try:
        user = get_current_user()
        data = request.get_json()

        if not data:
            return ApiResponse.error(
                message='Keine Daten erhalten',
                status_code=400
            )

        semester_typ = data.get('semester_typ', '').lower()
        if semester_typ not in VALID_SEMESTER_TYPEN:
            return ApiResponse.error(
                message=f'Ungültiger Semestertyp. Erlaubt: {", ".join(VALID_SEMESTER_TYPEN)}',
                status_code=400
            )

        # Erstelle Template
        template, created = template_service.get_or_create_template(
            benutzer_id=user.id,
            semester_typ=semester_typ,
            name=data.get('name'),
            beschreibung=data.get('beschreibung')
        )

        if not created:
            return ApiResponse.error(
                message=f'Template für {semester_typ}semester existiert bereits',
                status_code=409
            )

        return ApiResponse.success(
            data=template.to_dict(include_module=True),
            message='Template erstellt',
            status_code=201
        )

    except Exception as e:
        db.session.rollback()
        return ApiResponse.error(
            message='Fehler beim Erstellen des Templates',
            errors=[str(e)],
            status_code=500
        )


@template_api.route('/<int:template_id>', methods=['PUT'])
@login_required
def update_template(template_id: int):
    """
    PUT /api/templates/<id>

    Aktualisiert ein Template.

    Body:
        {
            "name": "Neuer Name",
            "beschreibung": "Neue Beschreibung",
            "ist_aktiv": true,
            "wunsch_freie_tage": [...],
            "anmerkungen": "...",
            "raumbedarf": "..."
        }

    Returns:
        200: Template aktualisiert
        404: Template nicht gefunden
    """
    try:
        user = get_current_user()
        template = template_service.get_template(template_id)

        if not template:
            return ApiResponse.error(
                message='Template nicht gefunden',
                status_code=404
            )

        if template.benutzer_id != user.id:
            return ApiResponse.error(
                message='Keine Berechtigung für dieses Template',
                status_code=403
            )

        data = request.get_json()
        if not data:
            return ApiResponse.error(
                message='Keine Daten erhalten',
                status_code=400
            )

        # Update Template
        updated_template = template_service.update_template(
            template_id=template_id,
            name=data.get('name'),
            beschreibung=data.get('beschreibung'),
            ist_aktiv=data.get('ist_aktiv'),
            wunsch_freie_tage=data.get('wunsch_freie_tage'),
            anmerkungen=data.get('anmerkungen'),
            raumbedarf=data.get('raumbedarf')
        )

        return ApiResponse.success(
            data=updated_template.to_dict(include_module=True),
            message='Template aktualisiert'
        )

    except Exception as e:
        db.session.rollback()
        return ApiResponse.error(
            message='Fehler beim Aktualisieren des Templates',
            errors=[str(e)],
            status_code=500
        )


@template_api.route('/<int:template_id>', methods=['DELETE'])
@login_required
def delete_template(template_id: int):
    """
    DELETE /api/templates/<id>

    Löscht ein Template.

    Returns:
        200: Template gelöscht
        404: Template nicht gefunden
    """
    try:
        user = get_current_user()
        template = template_service.get_template(template_id)

        if not template:
            return ApiResponse.error(
                message='Template nicht gefunden',
                status_code=404
            )

        if template.benutzer_id != user.id:
            return ApiResponse.error(
                message='Keine Berechtigung für dieses Template',
                status_code=403
            )

        template_service.delete_template(template_id)

        return ApiResponse.success(
            message='Template gelöscht'
        )

    except Exception as e:
        db.session.rollback()
        return ApiResponse.error(
            message='Fehler beim Löschen des Templates',
            errors=[str(e)],
            status_code=500
        )


# =========================================================================
# MODUL ENDPOINTS
# =========================================================================

@template_api.route('/<int:template_id>/modul', methods=['POST'])
@login_required
def add_template_modul(template_id: int):
    """
    POST /api/templates/<id>/modul

    Fügt ein Modul zum Template hinzu.

    Body:
        {
            "modul_id": 123,
            "po_id": 1,
            "anzahl_vorlesungen": 1,
            "anzahl_uebungen": 2,
            "anzahl_praktika": 0,
            "anzahl_seminare": 0,
            "mitarbeiter_ids": [1, 2],
            "anmerkungen": "...",
            "raumbedarf": "...",
            "raum_vorlesung": "...",
            "raum_uebung": "...",
            "raum_praktikum": "...",
            "raum_seminar": "...",
            "kapazitaet_vorlesung": 100,
            "kapazitaet_uebung": 30,
            "kapazitaet_praktikum": 20,
            "kapazitaet_seminar": 20
        }

    Returns:
        201: Modul hinzugefügt
        400: Validierungsfehler
        409: Modul existiert bereits
    """
    try:
        user = get_current_user()
        template = template_service.get_template(template_id)

        if not template:
            return ApiResponse.error(
                message='Template nicht gefunden',
                status_code=404
            )

        if template.benutzer_id != user.id:
            return ApiResponse.error(
                message='Keine Berechtigung für dieses Template',
                status_code=403
            )

        data = request.get_json()
        if not data or not data.get('modul_id') or not data.get('po_id'):
            return ApiResponse.error(
                message='modul_id und po_id sind erforderlich',
                status_code=400
            )

        # Füge Modul hinzu
        template_modul = template_service.add_modul_to_template(
            template_id=template_id,
            modul_id=data['modul_id'],
            po_id=data['po_id'],
            anzahl_vorlesungen=data.get('anzahl_vorlesungen', 0),
            anzahl_uebungen=data.get('anzahl_uebungen', 0),
            anzahl_praktika=data.get('anzahl_praktika', 0),
            anzahl_seminare=data.get('anzahl_seminare', 0),
            mitarbeiter_ids=data.get('mitarbeiter_ids'),
            anmerkungen=data.get('anmerkungen'),
            raumbedarf=data.get('raumbedarf'),
            raum_vorlesung=data.get('raum_vorlesung'),
            raum_uebung=data.get('raum_uebung'),
            raum_praktikum=data.get('raum_praktikum'),
            raum_seminar=data.get('raum_seminar'),
            kapazitaet_vorlesung=data.get('kapazitaet_vorlesung'),
            kapazitaet_uebung=data.get('kapazitaet_uebung'),
            kapazitaet_praktikum=data.get('kapazitaet_praktikum'),
            kapazitaet_seminar=data.get('kapazitaet_seminar')
        )

        return ApiResponse.success(
            data=template_modul.to_dict(),
            message='Modul hinzugefügt',
            status_code=201
        )

    except ValueError as e:
        return ApiResponse.error(
            message=str(e),
            status_code=409
        )
    except Exception as e:
        db.session.rollback()
        return ApiResponse.error(
            message='Fehler beim Hinzufügen des Moduls',
            errors=[str(e)],
            status_code=500
        )


@template_api.route('/<int:template_id>/modul/<int:modul_id>', methods=['PUT'])
@login_required
def update_template_modul(template_id: int, modul_id: int):
    """
    PUT /api/templates/<id>/modul/<mid>

    Aktualisiert ein Modul im Template.

    Body:
        {
            "anzahl_vorlesungen": 2,
            ...
        }

    Returns:
        200: Modul aktualisiert
        404: Template oder Modul nicht gefunden
    """
    try:
        user = get_current_user()
        template = template_service.get_template(template_id)

        if not template:
            return ApiResponse.error(
                message='Template nicht gefunden',
                status_code=404
            )

        if template.benutzer_id != user.id:
            return ApiResponse.error(
                message='Keine Berechtigung für dieses Template',
                status_code=403
            )

        data = request.get_json()
        if not data:
            return ApiResponse.error(
                message='Keine Daten erhalten',
                status_code=400
            )

        # Update Modul
        template_modul = template_service.update_template_modul(
            template_id=template_id,
            modul_id=modul_id,
            **data
        )

        if not template_modul:
            return ApiResponse.error(
                message='Modul nicht im Template gefunden',
                status_code=404
            )

        return ApiResponse.success(
            data=template_modul.to_dict(),
            message='Modul aktualisiert'
        )

    except Exception as e:
        db.session.rollback()
        return ApiResponse.error(
            message='Fehler beim Aktualisieren des Moduls',
            errors=[str(e)],
            status_code=500
        )


@template_api.route('/<int:template_id>/modul/<int:modul_id>', methods=['DELETE'])
@login_required
def delete_template_modul(template_id: int, modul_id: int):
    """
    DELETE /api/templates/<id>/modul/<mid>

    Entfernt ein Modul aus dem Template.

    Returns:
        200: Modul entfernt
        404: Template oder Modul nicht gefunden
    """
    try:
        user = get_current_user()
        template = template_service.get_template(template_id)

        if not template:
            return ApiResponse.error(
                message='Template nicht gefunden',
                status_code=404
            )

        if template.benutzer_id != user.id:
            return ApiResponse.error(
                message='Keine Berechtigung für dieses Template',
                status_code=403
            )

        success = template_service.remove_modul_from_template(template_id, modul_id)

        if not success:
            return ApiResponse.error(
                message='Modul nicht im Template gefunden',
                status_code=404
            )

        return ApiResponse.success(
            message='Modul entfernt'
        )

    except Exception as e:
        db.session.rollback()
        return ApiResponse.error(
            message='Fehler beim Entfernen des Moduls',
            errors=[str(e)],
            status_code=500
        )


# =========================================================================
# SPECIAL ENDPOINTS - Template/Planung Konvertierung
# =========================================================================

@template_api.route('/<int:template_id>/aus-planung/<int:planung_id>', methods=['POST'])
@login_required
def create_from_planung(template_id: int, planung_id: int):
    """
    POST /api/templates/<id>/aus-planung/<planung_id>

    Aktualisiert Template mit Daten aus einer bestehenden Planung.
    Alle bestehenden Module werden überschrieben.

    Returns:
        200: Template aktualisiert
        404: Template oder Planung nicht gefunden
    """
    try:
        user = get_current_user()
        template = template_service.get_template(template_id)

        if not template:
            return ApiResponse.error(
                message='Template nicht gefunden',
                status_code=404
            )

        if template.benutzer_id != user.id:
            return ApiResponse.error(
                message='Keine Berechtigung für dieses Template',
                status_code=403
            )

        result = template_service.update_template_from_planung(template_id, planung_id)

        if result.get('error'):
            return ApiResponse.error(
                message=result['error'],
                status_code=404
            )

        return ApiResponse.success(
            data=result['template'].to_dict(include_module=True),
            message=f'{result["anzahl_module"]} Module aus Planung übernommen'
        )

    except Exception as e:
        db.session.rollback()
        return ApiResponse.error(
            message='Fehler beim Übernehmen der Planung',
            errors=[str(e)],
            status_code=500
        )


@template_api.route('/<int:template_id>/auf-planung/<int:planung_id>', methods=['POST'])
@login_required
def apply_to_planung(template_id: int, planung_id: int):
    """
    POST /api/templates/<id>/auf-planung/<planung_id>

    Wendet Template auf eine bestehende Planung an.
    Bestehende Module in der Planung werden NICHT gelöscht,
    nur neue Module werden hinzugefügt.

    Body (optional):
        {
            "clear_existing": false  // true um bestehende Module zu löschen
        }

    Returns:
        200: Template angewendet
        404: Template oder Planung nicht gefunden
        400: Planung kann nicht bearbeitet werden
    """
    try:
        user = get_current_user()
        template = template_service.get_template(template_id)

        if not template:
            return ApiResponse.error(
                message='Template nicht gefunden',
                status_code=404
            )

        if template.benutzer_id != user.id:
            return ApiResponse.error(
                message='Keine Berechtigung für dieses Template',
                status_code=403
            )

        data = request.get_json() or {}
        clear_existing = data.get('clear_existing', False)

        result = template_service.apply_template_to_planung(
            template_id=template_id,
            planung_id=planung_id,
            clear_existing=clear_existing
        )

        if result.get('error'):
            status_code = 404 if 'nicht gefunden' in result['error'] else 400
            return ApiResponse.error(
                message=result['error'],
                status_code=status_code
            )

        return ApiResponse.success(
            data=result['planung'].to_dict(include_module=True),
            message=f'{result["hinzugefuegt"]} Module hinzugefügt, {result["uebersprungen"]} übersprungen'
        )

    except Exception as e:
        db.session.rollback()
        return ApiResponse.error(
            message='Fehler beim Anwenden des Templates',
            errors=[str(e)],
            status_code=500
        )


@template_api.route('/aus-planung', methods=['POST'])
@login_required
def create_new_template_from_planung():
    """
    POST /api/templates/aus-planung

    Erstellt ein neues Template aus einer bestehenden Planung.

    Body:
        {
            "planung_id": 123,
            "semester_typ": "winter|sommer",
            "name": "Optional"
        }

    Returns:
        201: Template erstellt
        404: Planung nicht gefunden
        409: Template existiert bereits
    """
    try:
        user = get_current_user()
        data = request.get_json()

        if not data or not data.get('planung_id') or not data.get('semester_typ'):
            return ApiResponse.error(
                message='planung_id und semester_typ sind erforderlich',
                status_code=400
            )

        semester_typ = data['semester_typ'].lower()
        if semester_typ not in VALID_SEMESTER_TYPEN:
            return ApiResponse.error(
                message=f'Ungültiger Semestertyp. Erlaubt: {", ".join(VALID_SEMESTER_TYPEN)}',
                status_code=400
            )

        result = template_service.create_template_from_planung(
            benutzer_id=user.id,
            planung_id=data['planung_id'],
            semester_typ=semester_typ,
            name=data.get('name')
        )

        if result.get('error'):
            status_code = 404 if 'nicht gefunden' in result['error'] else 409
            return ApiResponse.error(
                message=result['error'],
                status_code=status_code
            )

        return ApiResponse.success(
            data=result['template'].to_dict(include_module=True),
            message=f'Template erstellt mit {result["anzahl_module"]} Modulen',
            status_code=201
        )

    except Exception as e:
        db.session.rollback()
        return ApiResponse.error(
            message='Fehler beim Erstellen des Templates',
            errors=[str(e)],
            status_code=500
        )
