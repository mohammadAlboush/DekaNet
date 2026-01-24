"""Semesterplanung API - Endpoints für Workflow"""
"""
Planning API - **KERN!**
========================
REST API für Semesterplanung-Workflow.

**WICHTIGSTER TEIL DES SYSTEMS!**

Der komplette 8-Schritte Workflow:
1. Semester auswählen
2. Module auswählen  
3. Module hinzufügen
4. Mitarbeiter zuordnen
5. Multiplikatoren setzen
6. Zusätzliche Infos
7. Wunsch-freie Tage
8. Einreichen

Endpoints:
    GET    /api/planung                    - Eigene Planungen
    GET    /api/planung/meine              - Eigene aktuelle Planung
    GET    /api/planung/<id>               - Planung Details
    POST   /api/planung                    - Planung erstellen
    DELETE /api/planung/<id>               - Planung löschen
    
    POST   /api/planung/<id>/modul         - Modul hinzufügen
    PUT    /api/planung/<id>/modul/<mid>   - Modul bearbeiten
    DELETE /api/planung/<id>/modul/<mid>   - Modul entfernen
    
    POST   /api/planung/<id>/wunsch-tag    - Wunsch-Tag hinzufügen
    DELETE /api/planung/<id>/wunsch-tag/<wid> - Wunsch-Tag entfernen
    
    POST   /api/planung/<id>/einreichen    - Planung einreichen
    POST   /api/planung/<id>/freigeben     - Planung freigeben (Dekan)
    POST   /api/planung/<id>/ablehnen      - Planung ablehnen (Dekan)
    
    GET    /api/planung/dekan              - Alle Planungen (Dekan)
    GET    /api/planung/eingereicht        - Eingereichte Planungen (Dekan)
"""

from flask import Blueprint, request, current_app
from sqlalchemy.orm import joinedload
from app.api.base import (
    ApiResponse,
    login_required,
    role_required,
    validate_request,
    get_pagination_params,
    get_current_user
)
from app.services import planung_service, semester_service, notification_service
from app.models.planungsphase import Planungsphase
from app.extensions import db
from app.utils.sanitization import sanitize_planung_data, sanitize_modul_data, sanitize_wunsch_tag_data

# Blueprint
planung_api = Blueprint('planung', __name__, url_prefix='/api/planung')

# Valid status values for input validation
VALID_STATUS_VALUES = {'entwurf', 'eingereicht', 'freigegeben', 'abgelehnt'}


# =========================================================================
# GET ENDPOINTS - Eigene Planungen
# =========================================================================

@planung_api.route('/', methods=['GET'])
@login_required
def get_eigene_planungen():
    """
    GET /api/planung
    
    Holt eigene Semesterplanungen.
    
    Query Parameters:
        ?semester_id=1
        ?status=entwurf
        
    Returns:
        200: Liste von eigenen Planungen
    """
    try:
        user = get_current_user()

        # Filter mit Validierung
        semester_id = request.args.get('semester_id', type=int)
        status = request.args.get('status')

        # Input validation for status parameter
        if status and status not in VALID_STATUS_VALUES:
            return ApiResponse.error(
                message=f'Ungültiger Status. Erlaubt: {", ".join(VALID_STATUS_VALUES)}',
                status_code=400
            )

        if semester_id:
            planungen = planung_service.get_by_semester(semester_id, status=status)
            # Filter nur eigene
            planungen = [p for p in planungen if p.benutzer_id == user.id]
        else:
            planungen = planung_service.get_by_user(user.id)
            if status:
                planungen = [p for p in planungen if p.status == status]
        
        # Format
        items = [p.to_dict() for p in planungen]
        
        return ApiResponse.success(
            data=items,
            message=f'{len(items)} Planung(en) gefunden'
        )
    
    except Exception as e:
        return ApiResponse.error(
            message='Fehler beim Laden der Planungen',
            errors=[str(e)],
            status_code=500
        )


@planung_api.route('/meine', methods=['GET'])
@login_required
def get_meine_aktuelle_planung():
    """
    GET /api/planung/meine
    
    Holt die aktuelle Planung des Benutzers für das aktive Planungssemester.
    
    Returns:
        200: Aktuelle Planung mit Details
        404: Keine aktuelle Planung gefunden
    """
    try:
        user = get_current_user()
        
        # Hole aktuelles Planungssemester
        planungs_semester = semester_service.get_planungssemester()

        if not planungs_semester:
            return ApiResponse.success(
                data=None,
                message='Keine aktive Planungsphase'
            )

        # Hole aktive Planungsphase
        active_phase = Planungsphase.get_active_phase()

        # ✅ WICHTIG: Hole oder erstelle Planung für aktuelle Phase
        planung, created = planung_service.get_or_create_planung(
            semester_id=planungs_semester.id,
            benutzer_id=user.id,
            planungsphase_id=active_phase.id if active_phase else None
        )
        
        # Lade Details
        data = planung.to_dict()
        data['geplante_module'] = [gm.to_dict() for gm in planung.geplante_module]
        data['wunsch_freie_tage'] = [w.to_dict() for w in planung.wunsch_freie_tage]
        data['semester'] = planungs_semester.to_dict()
        
        return ApiResponse.success(
            data=data,
            message='Aktuelle Planung geladen' if not created else 'Neue Planung erstellt'
        )
    
    except Exception as e:
        return ApiResponse.error(
            message='Fehler beim Laden der aktuellen Planung',
            errors=[str(e)],
            status_code=500
        )


@planung_api.route('/professor/phasen-historie', methods=['GET'])
@login_required
def get_professor_phasen_historie():
    """
    GET /api/planung/professor/phasen-historie

    Holt die Planungshistorie des Professors - gruppiert nach Planungsphasen.

    ✅ Zeigt für jede Phase:
       - Phase-Info (Name, Datum, Status)
       - Planung des Professors (falls vorhanden)
       - Einreichungsstatus
       - Module-Anzahl

    Query Parameters:
        ?semester_id=1  - Filtere nach Semester (optional, default: aktuelles Planungssemester)

    Returns:
        200: Liste von Phasen mit zugehörigen Planungen
    """
    try:
        user = get_current_user()
        semester_id = request.args.get('semester_id', type=int)

        # Hole Semester
        if semester_id:
            semester = semester_service.get_by_id(semester_id)
        else:
            # Standard: Aktuelles Planungssemester
            semester = semester_service.get_planungssemester()

        if not semester:
            return ApiResponse.success(
                data=[],
                message='Kein Semester gefunden'
            )

        # Hole alle Phasen dieses Semesters
        phasen = Planungsphase.query.filter_by(semester_id=semester.id).order_by(Planungsphase.created_at.asc()).all()

        # Hole alle Planungen des Professors für dieses Semester
        planungen = planung_service.get_by_user(user.id)
        planungen = [p for p in planungen if p.semester_id == semester.id]

        # Erstelle Mapping: phase_id -> planung
        planungen_by_phase = {p.planungsphase_id: p for p in planungen if p.planungsphase_id}

        # Baue Historie
        historie = []
        for phase in phasen:
            planung = planungen_by_phase.get(phase.id)

            phase_data = {
                'phase': {
                    'id': phase.id,
                    'name': phase.name,
                    'startdatum': phase.startdatum.isoformat() if phase.startdatum else None,
                    'enddatum': phase.enddatum.isoformat() if phase.enddatum else None,
                    'ist_aktiv': phase.ist_aktiv,
                    'geschlossen_am': phase.geschlossen_am.isoformat() if phase.geschlossen_am else None,
                },
                'planung': None,
                'hat_planung': False,
                'status': None,
                'eingereicht_am': None,
                'module_anzahl': 0
            }

            if planung:
                phase_data['hat_planung'] = True
                phase_data['planung'] = {
                    'id': planung.id,
                    'status': planung.status,
                    'gesamt_sws': planung.gesamt_sws,
                    'eingereicht_am': planung.eingereicht_am.isoformat() if planung.eingereicht_am else None,
                    'freigegeben_am': planung.freigegeben_am.isoformat() if planung.freigegeben_am else None,
                    'abgelehnt_am': planung.abgelehnt_am.isoformat() if planung.abgelehnt_am else None,
                    'ablehnungsgrund': planung.ablehnungsgrund,
                }
                phase_data['status'] = planung.status
                phase_data['eingereicht_am'] = planung.eingereicht_am.isoformat() if planung.eingereicht_am else None
                phase_data['module_anzahl'] = planung.anzahl_module

            historie.append(phase_data)

        return ApiResponse.success(
            data={
                'semester': semester.to_dict(),
                'phasen': historie,
                'gesamt_phasen': len(historie),
                'phasen_mit_planung': sum(1 for h in historie if h['hat_planung'])
            },
            message=f'{len(historie)} Phasen gefunden'
        )

    except Exception as e:
        return ApiResponse.error(
            message='Fehler beim Laden der Phasenhistorie',
            errors=[str(e)],
            status_code=500
        )


@planung_api.route('/<int:planung_id>', methods=['GET'])
@login_required
def get_planung(planung_id: int):
    """
    GET /api/planung/<id>
    
    Holt Details einer Planung.
    
    Returns:
        200: Planung Details mit Modulen
        403: Keine Berechtigung
        404: Planung nicht gefunden
    """
    try:
        user = get_current_user()
        planung = planung_service.get_by_id(planung_id)
        
        if not planung:
            return ApiResponse.error(
                message='Planung nicht gefunden',
                status_code=404
            )
        
        # Berechtigung prüfen
        if planung.benutzer_id != user.id and (not user.rolle or user.rolle.name != 'dekan'):
            return ApiResponse.error(
                message='Keine Berechtigung für diese Planung',
                status_code=403
            )
        
        # Details
        data = planung.to_dict()
        data['geplante_module'] = [gm.to_dict() for gm in planung.geplante_module]
        data['wunsch_freie_tage'] = [w.to_dict() for w in planung.wunsch_freie_tage]
        
        return ApiResponse.success(data=data)
    
    except Exception as e:
        return ApiResponse.error(
            message='Fehler beim Laden der Planung',
            errors=[str(e)],
            status_code=500
        )


# =========================================================================
# POST ENDPOINTS - Planung erstellen
# =========================================================================

@planung_api.route('/', methods=['POST'])
@login_required
@validate_request(['semester_id'])
def create_planung():
    """
    POST /api/planung
    
    Erstellt neue Semesterplanung oder holt bestehende.
    
    Request Body:
        {
            "semester_id": 1
        }
    
    Returns:
        200/201: Planung (created=true/false)
        400: Validierungsfehler
    """
    try:
        user = get_current_user()
        data = request.get_json()
        
        semester_id = data['semester_id']
        
        # Prüfe ob Semester existiert
        semester = semester_service.get_by_id(semester_id)
        if not semester:
            return ApiResponse.error(
                message='Semester nicht gefunden',
                status_code=404
            )
        
        # Prüfe ob Planungsphase offen
        if not semester.ist_planungsphase:
            return ApiResponse.error(
                message='Planungsphase ist nicht geöffnet',
                status_code=400
            )

        # Hole aktive Planungsphase
        active_phase = Planungsphase.get_active_phase()

        # ✅ WICHTIG: Übergib planungsphase_id an Service
        # Dadurch wird für jede Phase eine NEUE Planung erstellt
        planung, created = planung_service.get_or_create_planung(
            semester_id=semester_id,
            benutzer_id=user.id,
            planungsphase_id=active_phase.id if active_phase else None
        )
        
        return ApiResponse.success(
            data={
                **planung.to_dict(),
                'created': created
            },
            message='Planung erfolgreich erstellt' if created else 'Planung bereits vorhanden',
            status_code=201 if created else 200
        )
    
    except Exception as e:
        return ApiResponse.error(
            message='Fehler beim Erstellen der Planung',
            errors=[str(e)],
            status_code=500
        )


@planung_api.route('/<int:planung_id>', methods=['PUT'])
@login_required
def update_planung(planung_id: int):
    """
    PUT /api/planung/<id>
    
    Aktualisiert eine bestehende Planung (Entwurf).
    
    Request Body:
        {
            "notizen": "...",           # Optional
            "po_id": 1                  # Optional
        }
    
    Returns:
        200: Planung aktualisiert
        400: Validierungsfehler / Planung kann nicht bearbeitet werden
        403: Keine Berechtigung
        404: Planung nicht gefunden
    """
    try:
        user = get_current_user()
        planung = planung_service.get_by_id(planung_id)
        
        if not planung:
            return ApiResponse.error(
                message='Planung nicht gefunden',
                status_code=404
            )
        
        # Berechtigung prüfen
        if planung.benutzer_id != user.id:
            return ApiResponse.error(
                message='Keine Berechtigung für diese Planung',
                status_code=403
            )
        
        # Prüfen ob Planung bearbeitet werden kann
        if not planung.kann_bearbeitet_werden():
            return ApiResponse.error(
                message=f'Planung mit Status "{planung.status}" kann nicht bearbeitet werden',
                status_code=400
            )
        
        # Update mit Sanitization
        data = request.get_json()
        data = sanitize_planung_data(data)
        updated_planung = planung_service.update(planung_id, **data)
        
        if not updated_planung:
            return ApiResponse.error(
                message='Planung konnte nicht aktualisiert werden',
                status_code=500
            )
        
        return ApiResponse.success(
            data=updated_planung.to_dict(),
            message='Planung aktualisiert'
        )
    
    except Exception as e:
        return ApiResponse.error(
            message='Fehler beim Aktualisieren der Planung',
            errors=[str(e)],
            status_code=500
        )


# =========================================================================
# MODULE MANAGEMENT
# =========================================================================

@planung_api.route('/<int:planung_id>/modul', methods=['POST'])
@login_required
@validate_request(['modul_id', 'po_id'])
def add_modul(planung_id: int):
    """
    POST /api/planung/<id>/modul
    
    Fügt ein Modul zur Planung hinzu.
    
    Request Body:
        {
            "modul_id": 1,
            "po_id": 1,
            "anzahl_vorlesungen": 2,  # Optional
            "anzahl_uebungen": 1,     # Optional
            "anzahl_praktika": 0,     # Optional
            "anzahl_seminare": 0,     # Optional
            "mitarbeiter_ids": [1,2], # Optional
            "anmerkungen": "...",     # Optional
            "raumbedarf": "...",      # Optional
            "raum_vorlesung": "HS 101",   # Optional - Feature 4
            "raum_uebung": "SR 201",      # Optional - Feature 4
            "raum_praktikum": "Lab 301",  # Optional - Feature 4
            "raum_seminar": "SR 102",     # Optional - Feature 4
            "kapazitaet_vorlesung": 120,  # Optional - Feature 4
            "kapazitaet_uebung": 30,      # Optional - Feature 4
            "kapazitaet_praktikum": 20,   # Optional - Feature 4
            "kapazitaet_seminar": 25      # Optional - Feature 4
        }
    
    Returns:
        201: Modul hinzugefügt
        400: Validierungsfehler
        403: Keine Berechtigung
    """
    try:
        user = get_current_user()
        planung = planung_service.get_by_id(planung_id)
        
        if not planung:
            return ApiResponse.error(
                message='Planung nicht gefunden',
                status_code=404
            )
        
        # Berechtigung prüfen
        if planung.benutzer_id != user.id:
            return ApiResponse.error(
                message='Keine Berechtigung für diese Planung',
                status_code=403
            )
        
        # Prüfen ob Planung bearbeitet werden kann
        if not planung.kann_bearbeitet_werden():
            return ApiResponse.error(
                message=f'Planung mit Status "{planung.status}" kann nicht bearbeitet werden',
                status_code=400
            )
        
        # Modul hinzufügen mit Sanitization
        data = request.get_json()
        data = sanitize_modul_data(data)
        geplantes_modul = planung_service.add_modul(
            planung_id=planung_id,
            modul_id=data['modul_id'],
            po_id=data['po_id'],
            anzahl_vorlesungen=data.get('anzahl_vorlesungen', 0),
            anzahl_uebungen=data.get('anzahl_uebungen', 0),
            anzahl_praktika=data.get('anzahl_praktika', 0),
            anzahl_seminare=data.get('anzahl_seminare', 0),
            mitarbeiter_ids=data.get('mitarbeiter_ids'),
            anmerkungen=data.get('anmerkungen'),
            raumbedarf=data.get('raumbedarf'),
            # ✨ NEW: Feature 4 - Raumplanung pro Lehrform
            raum_vorlesung=data.get('raum_vorlesung'),
            raum_uebung=data.get('raum_uebung'),
            raum_praktikum=data.get('raum_praktikum'),
            raum_seminar=data.get('raum_seminar'),
            # ✨ NEW: Feature 4 - Kapazitäts-Anforderungen pro Lehrform
            kapazitaet_vorlesung=data.get('kapazitaet_vorlesung'),
            kapazitaet_uebung=data.get('kapazitaet_uebung'),
            kapazitaet_praktikum=data.get('kapazitaet_praktikum'),
            kapazitaet_seminar=data.get('kapazitaet_seminar')
        )
        
        return ApiResponse.success(
            data=geplantes_modul.to_dict(),
            message='Modul erfolgreich hinzugefügt',
            status_code=201
        )
    
    except ValueError as e:
        return ApiResponse.error(
            message='Fehler beim Hinzufügen des Moduls',
            errors=[str(e)],
            status_code=400
        )
    except Exception as e:
        return ApiResponse.error(
            message='Fehler beim Hinzufügen des Moduls',
            errors=[str(e)],
            status_code=500
        )


@planung_api.route('/<int:planung_id>/modul/<int:modul_id>', methods=['PUT'])
@login_required
def update_modul(planung_id: int, modul_id: int):
    """
    PUT /api/planung/<id>/modul/<mid>
    
    Bearbeitet ein geplantes Modul.
    
    Request Body:
        {
            "anzahl_vorlesungen": 2,  # Optional
            "anzahl_uebungen": 1,     # Optional
            "anzahl_praktika": 0,     # Optional
            "anzahl_seminare": 0,     # Optional
            "mitarbeiter_ids": [1,2], # Optional
            "anmerkungen": "...",     # Optional
            "raumbedarf": "..."       # Optional
        }
    
    Returns:
        200: Modul aktualisiert
        400: Validierungsfehler
        403: Keine Berechtigung
        404: Modul nicht gefunden
    """
    try:
        user = get_current_user()
        planung = planung_service.get_by_id(planung_id)
        
        if not planung:
            return ApiResponse.error(
                message='Planung nicht gefunden',
                status_code=404
            )
        
        # Berechtigung prüfen
        if planung.benutzer_id != user.id:
            return ApiResponse.error(
                message='Keine Berechtigung für diese Planung',
                status_code=403
            )
        
        # Prüfen ob Planung bearbeitet werden kann
        if not planung.kann_bearbeitet_werden():
            return ApiResponse.error(
                message=f'Planung mit Status "{planung.status}" kann nicht bearbeitet werden',
                status_code=400
            )
        
        # Modul aktualisieren mit Sanitization
        data = request.get_json()
        data = sanitize_modul_data(data)

        # FIX: modul_id ist die ID des GeplantesModul, nicht des Moduls!
        # Die Route verwendet die GeplantesModul.id
        geplantes_modul = planung_service.update_modul(
            geplantes_modul_id=modul_id,  # FIXED: Richtige Parameter-Name
            **data
        )

        if not geplantes_modul:
            return ApiResponse.error(
                message='Modul nicht gefunden',
                status_code=404
            )
        
        return ApiResponse.success(
            data=geplantes_modul.to_dict(),
            message='Modul erfolgreich aktualisiert'
        )
    
    except ValueError as e:
        return ApiResponse.error(
            message='Fehler beim Aktualisieren des Moduls',
            errors=[str(e)],
            status_code=400
        )
    except Exception as e:
        return ApiResponse.error(
            message='Fehler beim Aktualisieren des Moduls',
            errors=[str(e)],
            status_code=500
        )


@planung_api.route('/<int:planung_id>/modul/<int:modul_id>', methods=['DELETE'])
@login_required
def delete_modul(planung_id: int, modul_id: int):
    """
    DELETE /api/planung/<id>/modul/<mid>
    
    Entfernt ein Modul aus der Planung.
    
    Returns:
        200: Modul entfernt
        403: Keine Berechtigung
        404: Planung/Modul nicht gefunden
    """
    try:
        user = get_current_user()
        planung = planung_service.get_by_id(planung_id)
        
        if not planung:
            return ApiResponse.error(
                message='Planung nicht gefunden',
                status_code=404
            )
        
        # Berechtigung prüfen
        if planung.benutzer_id != user.id:
            return ApiResponse.error(
                message='Keine Berechtigung für diese Planung',
                status_code=403
            )
        
        # Prüfen ob Planung bearbeitet werden kann
        if not planung.kann_bearbeitet_werden():
            return ApiResponse.error(
                message=f'Planung mit Status "{planung.status}" kann nicht bearbeitet werden',
                status_code=400
            )
        
        # Modul entfernen
        success = planung_service.remove_modul(planung_id, modul_id)
        
        if not success:
            return ApiResponse.error(
                message='Modul nicht gefunden',
                status_code=404
            )
        
        return ApiResponse.success(
            message='Modul erfolgreich entfernt'
        )
    
    except Exception as e:
        return ApiResponse.error(
            message='Fehler beim Entfernen des Moduls',
            errors=[str(e)],
            status_code=500
        )


# =========================================================================
# WUNSCH-FREIE TAGE
# =========================================================================

@planung_api.route('/<int:planung_id>/wunsch-tag', methods=['POST'])
@login_required
@validate_request(['datum'])
def add_wunsch_tag(planung_id: int):
    """
    POST /api/planung/<id>/wunsch-tag
    
    Fügt einen Wunsch-freien Tag hinzu.
    
    Request Body:
        {
            "datum": "2024-12-24",
            "grund": "Weihnachten",  # Optional
            "ganztags": true          # Optional
        }
    
    Returns:
        201: Wunsch-Tag hinzugefügt
        400: Validierungsfehler
        403: Keine Berechtigung
    """
    try:
        user = get_current_user()
        planung = planung_service.get_by_id(planung_id)
        
        if not planung:
            return ApiResponse.error(
                message='Planung nicht gefunden',
                status_code=404
            )
        
        # Berechtigung prüfen
        if planung.benutzer_id != user.id:
            return ApiResponse.error(
                message='Keine Berechtigung für diese Planung',
                status_code=403
            )
        
        # Prüfen ob Planung bearbeitet werden kann
        if not planung.kann_bearbeitet_werden():
            return ApiResponse.error(
                message=f'Planung mit Status "{planung.status}" kann nicht bearbeitet werden',
                status_code=400
            )
        
        # Wunsch-Tag hinzufügen mit Sanitization
        data = request.get_json()
        data = sanitize_wunsch_tag_data(data)
        wunsch_tag = planung_service.add_wunsch_tag(
            planung_id=planung_id,
            datum=data['datum'],
            grund=data.get('grund'),
            ganztags=data.get('ganztags', True)
        )
        
        return ApiResponse.success(
            data=wunsch_tag.to_dict(),
            message='Wunsch-Tag erfolgreich hinzugefügt',
            status_code=201
        )
    
    except ValueError as e:
        return ApiResponse.error(
            message='Fehler beim Hinzufügen des Wunsch-Tags',
            errors=[str(e)],
            status_code=400
        )
    except Exception as e:
        return ApiResponse.error(
            message='Fehler beim Hinzufügen des Wunsch-Tags',
            errors=[str(e)],
            status_code=500
        )


@planung_api.route('/<int:planung_id>/wunsch-tag/<int:wunsch_id>', methods=['DELETE'])
@login_required
def delete_wunsch_tag(planung_id: int, wunsch_id: int):
    """
    DELETE /api/planung/<id>/wunsch-tag/<wid>
    
    Entfernt einen Wunsch-freien Tag.
    
    Returns:
        200: Wunsch-Tag entfernt
        403: Keine Berechtigung
        404: Planung/Wunsch-Tag nicht gefunden
    """
    try:
        user = get_current_user()
        planung = planung_service.get_by_id(planung_id)
        
        if not planung:
            return ApiResponse.error(
                message='Planung nicht gefunden',
                status_code=404
            )
        
        # Berechtigung prüfen
        if planung.benutzer_id != user.id:
            return ApiResponse.error(
                message='Keine Berechtigung für diese Planung',
                status_code=403
            )
        
        # Prüfen ob Planung bearbeitet werden kann
        if not planung.kann_bearbeitet_werden():
            return ApiResponse.error(
                message=f'Planung mit Status "{planung.status}" kann nicht bearbeitet werden',
                status_code=400
            )
        
        # Wunsch-Tag entfernen
        success = planung_service.remove_wunsch_tag(planung_id, wunsch_id)
        
        if not success:
            return ApiResponse.error(
                message='Wunsch-Tag nicht gefunden',
                status_code=404
            )
        
        return ApiResponse.success(
            message='Wunsch-Tag erfolgreich entfernt'
        )
    
    except Exception as e:
        return ApiResponse.error(
            message='Fehler beim Entfernen des Wunsch-Tags',
            errors=[str(e)],
            status_code=500
        )


@planung_api.route('/<int:planung_id>/zusatzinfos', methods=['PUT'])
@login_required
def update_zusatzinfos(planung_id: int):
    """
    PUT /api/planung/<id>/zusatzinfos

    Aktualisiert alle Zusatzinformationen einer Planung in einem Aufruf.
    Ersetzt alle bestehenden Wunsch-freie-Tage.

    Request Body:
        {
            "anmerkungen": "...",           # Optional
            "raumbedarf": "...",            # Optional
            "room_requirements": [...],     # Optional - Array of room requirements
            "special_requests": {...},      # Optional - Object with special requests
            "wunsch_freie_tage": [          # Optional - Replaces all existing
                {
                    "wochentag": "montag",
                    "zeitraum": "ganztags",
                    "prioritaet": "hoch",
                    "grund": "..."
                }
            ]
        }

    Returns:
        200: Zusatzinfos aktualisiert
        400: Validierungsfehler
        403: Keine Berechtigung
    """
    try:
        user = get_current_user()
        planung = planung_service.get_by_id(planung_id)

        if not planung:
            return ApiResponse.error(
                message='Planung nicht gefunden',
                status_code=404
            )

        # Berechtigung prüfen
        if planung.benutzer_id != user.id:
            return ApiResponse.error(
                message='Keine Berechtigung für diese Planung',
                status_code=403
            )

        # Prüfen ob Planung bearbeitet werden kann
        if not planung.kann_bearbeitet_werden():
            return ApiResponse.error(
                message=f'Planung mit Status "{planung.status}" kann nicht bearbeitet werden',
                status_code=400
            )

        data = request.get_json()

        # Update Planung fields
        if 'anmerkungen' in data:
            planung.anmerkungen = data['anmerkungen']
        if 'raumbedarf' in data:
            planung.raumbedarf = data['raumbedarf']
        if 'room_requirements' in data:
            planung.room_requirements = data['room_requirements']
        if 'special_requests' in data:
            planung.special_requests = data['special_requests']

        # Update Wunsch-freie-Tage (replace all)
        if 'wunsch_freie_tage' in data:
            # Delete existing
            from app.models import WunschFreierTag
            WunschFreierTag.query.filter_by(semesterplanung_id=planung_id).delete()

            # Add new
            for tag_data in data['wunsch_freie_tage']:
                wunsch_tag = WunschFreierTag(
                    semesterplanung_id=planung_id,
                    wochentag=tag_data.get('wochentag', 'montag'),
                    zeitraum=tag_data.get('zeitraum', 'ganztags'),
                    prioritaet=tag_data.get('prioritaet', 'mittel'),
                    grund=tag_data.get('grund', ''),
                )
                db.session.add(wunsch_tag)

        db.session.commit()

        # Return updated planung with all data
        return ApiResponse.success(
            data=planung.to_dict(include_module=True),
            message='Zusatzinfos erfolgreich aktualisiert'
        )

    except Exception as e:
        db.session.rollback()
        return ApiResponse.error(
            message='Fehler beim Aktualisieren der Zusatzinfos',
            errors=[str(e)],
            status_code=500
        )


# =========================================================================
# WORKFLOW - Einreichen, Freigeben, Ablehnen
# =========================================================================

@planung_api.route('/<int:planung_id>/einreichen', methods=['POST'])
@login_required
def einreichen(planung_id: int):
    """
    POST /api/planung/<id>/einreichen
    
    Reicht Planung ein (Status: entwurf → eingereicht).
    
    Returns:
        200: Planung eingereicht
        400: Planung kann nicht eingereicht werden
        403: Keine Berechtigung
    """
    try:
        user = get_current_user()
        planung = planung_service.get_by_id(planung_id)
        
        if not planung:
            return ApiResponse.error(
                message='Planung nicht gefunden',
                status_code=404
            )
        
        # Berechtigung prüfen
        if planung.benutzer_id != user.id:
            return ApiResponse.error(
                message='Keine Berechtigung für diese Planung',
                status_code=403
            )
        
        # Session-Refresh um sicherzustellen, dass alle Module geladen sind
        db.session.refresh(planung)
        
        # Prüfe Status explizit
        if planung.status != 'entwurf':
            return ApiResponse.error(
                message=f'Planung mit Status "{planung.status}" kann nicht eingereicht werden',
                errors=[f'Aktueller Status: {planung.status}'],
                status_code=400
            )
        
        # Prüfe ob Module vorhanden sind - explizit mit count()
        anzahl_module = planung.anzahl_module
        if anzahl_module == 0:
            return ApiResponse.error(
                message='Planung kann nicht eingereicht werden',
                errors=['Mindestens ein Modul muss zur Planung hinzugefügt werden'],
                status_code=400
            )
        
        # Einreichen über Service
        try:
            planung = planung_service.einreichen(planung_id)
        except ValueError as ve:
            return ApiResponse.error(
                message='Planung kann nicht eingereicht werden',
                errors=[str(ve)],
                status_code=400
            )
        
        # Notification an Benutzer
        try:
            notification_service.notify_planung_eingereicht(
                benutzer_id=user.id,
                semester_kuerzel=planung.semester.kuerzel
            )
        except Exception as notif_error:
            # Notification-Fehler nicht kritisch
            current_app.logger.warning(f"Notification error: {notif_error}")
        
        # Notification an Dekane
        try:
            notification_service.notify_dekan_neue_planung(
                dozent_name=user.name_komplett,
                semester_kuerzel=planung.semester.kuerzel
            )
        except Exception as notif_error:
            # Notification-Fehler nicht kritisch
            current_app.logger.warning(f"Notification error: {notif_error}")
        
        return ApiResponse.success(
            data=planung.to_dict(),
            message='Planung erfolgreich eingereicht'
        )
    
    except ValueError as e:
        return ApiResponse.error(
            message='Planung kann nicht eingereicht werden',
            errors=[str(e)],
            status_code=400
        )
    except Exception as e:
        return ApiResponse.error(
            message='Fehler beim Einreichen der Planung',
            errors=[str(e)],
            status_code=500
        )


@planung_api.route('/<int:planung_id>/freigeben', methods=['POST'])
@role_required('dekan')
def freigeben(planung_id: int):
    """
    POST /api/planung/<id>/freigeben
    
    Gibt Planung frei (nur Dekan) (Status: eingereicht → freigegeben).
    
    Returns:
        200: Planung freigegeben
        400: Planung kann nicht freigegeben werden
    """
    try:
        user = get_current_user()
        planung = planung_service.get_by_id(planung_id)
        
        if not planung:
            return ApiResponse.error(
                message='Planung nicht gefunden',
                status_code=404
            )
        
        # Freigeben
        planung = planung_service.freigeben(planung_id, user.id)
        
        # Notification an Dozent
        try:
            notification_service.notify_planung_freigegeben(
                benutzer_id=planung.benutzer_id,
                semester_kuerzel=planung.semester.kuerzel
            )
        except Exception as notif_error:
            current_app.logger.warning(f"Notification error: {notif_error}")
        
        return ApiResponse.success(
            data=planung.to_dict(),
            message='Planung erfolgreich freigegeben'
        )
    
    except ValueError as e:
        return ApiResponse.error(
            message='Planung kann nicht freigegeben werden',
            errors=[str(e)],
            status_code=400
        )
    except Exception as e:
        return ApiResponse.error(
            message='Fehler beim Freigeben der Planung',
            errors=[str(e)],
            status_code=500
        )


@planung_api.route('/<int:planung_id>/ablehnen', methods=['POST'])
@role_required('dekan')
def ablehnen(planung_id: int):
    """
    POST /api/planung/<id>/ablehnen
    
    Lehnt Planung ab (nur Dekan) (Status: eingereicht → abgelehnt).
    
    Request Body:
        {
            "grund": "..."  # Optional
        }
    
    Returns:
        200: Planung abgelehnt
        400: Planung kann nicht abgelehnt werden
    """
    try:
        data = request.get_json() or {}
        grund = data.get('grund')
        
        planung = planung_service.get_by_id(planung_id)
        
        if not planung:
            return ApiResponse.error(
                message='Planung nicht gefunden',
                status_code=404
            )
        
        # Ablehnen
        planung = planung_service.ablehnen(planung_id, grund=grund)
        
        # Notification an Dozent
        try:
            notification_service.notify_planung_abgelehnt(
                benutzer_id=planung.benutzer_id,
                semester_kuerzel=planung.semester.kuerzel,
                grund=grund
            )
        except Exception as notif_error:
            current_app.logger.warning(f"Notification error: {notif_error}")
        
        return ApiResponse.success(
            data=planung.to_dict(),
            message='Planung erfolgreich abgelehnt'
        )
    
    except ValueError as e:
        return ApiResponse.error(
            message='Planung kann nicht abgelehnt werden',
            errors=[str(e)],
            status_code=400
        )
    except Exception as e:
        return ApiResponse.error(
            message='Fehler beim Ablehnen der Planung',
            errors=[str(e)],
            status_code=500
        )


# =========================================================================
# DEKAN VIEWS
# =========================================================================

@planung_api.route('/dekan', methods=['GET'])
@role_required('dekan')
def get_alle_planungen_dekan():
    """
    GET /api/planung/dekan

    Holt Planungen der aktiven Planungsphase (nur Dekan).

    ✅ WICHTIG: Standardmäßig werden nur Planungen der AKTIVEN Phase gezeigt.
               Wenn keine Phase aktiv ist → leere Liste (Dashboard leer).
               Geschlossene Phasen gehören ins Archiv, nicht ins Dashboard!

    Query Parameters:
        ?planungsphase_id=5  - Zeige spezifische Phase (für Archiv/Historie)
        ?status=eingereicht  - Filtere nach Status
        ?page=1&per_page=20

    Returns:
        200: Liste aller Planungen der aktiven Phase
    """
    try:
        status = request.args.get('status')
        planungsphase_id = request.args.get('planungsphase_id', type=int)
        page, per_page = get_pagination_params()

        # Input validation for status parameter
        if status and status not in VALID_STATUS_VALUES:
            return ApiResponse.error(
                message=f'Ungültiger Status. Erlaubt: {", ".join(VALID_STATUS_VALUES)}',
                status_code=400
            )

        # ✅ NEUE LOGIK: Standard = nur aktive Phase
        if planungsphase_id:
            # Spezifische Phase angefordert (z.B. für Archiv-Ansicht)
            planungen = planung_service.get_all(status=status)
            planungen = [p for p in planungen if p.planungsphase_id == planungsphase_id]
        else:
            # ✅ STANDARD: Nur aktive Phase zeigen
            active_phase = Planungsphase.get_active_phase()

            if not active_phase:
                # 🔴 Keine aktive Phase = Dashboard leer (korrekt!)
                planungen = []
            else:
                # ✅ Zeige nur Planungen der aktiven Phase
                planungen = planung_service.get_all(status=status)
                planungen = [p for p in planungen if p.planungsphase_id == active_phase.id]

        # Format - ✅ WICHTIG: include_module=True für Dekan-Ansicht mit vollständigen Daten
        items = [p.to_dict(include_module=True) for p in planungen]

        return ApiResponse.success(
            data=items,
            message=f'{len(items)} Planung(en) gefunden'
        )
    
    except Exception as e:
        return ApiResponse.error(
            message='Fehler beim Laden der Planungen',
            errors=[str(e)],
            status_code=500
        )


@planung_api.route('/eingereicht', methods=['GET'])
@role_required('dekan')
def get_eingereichte_planungen():
    """
    GET /api/planung/eingereicht

    Holt eingereichte Planungen der aktiven Phase (nur Dekan).

    ✅ WICHTIG: Zeigt nur Planungen der AKTIVEN Planungsphase.
               Wenn keine Phase aktiv ist → leere Liste (nichts zu prüfen!).
               Geschlossene Phasen gehören ins Archiv, nicht in "Planungen prüfen"!

    Query Parameters:
        ?planungsphase_id=5  - Zeige spezifische Phase (für Archiv)

    Returns:
        200: Liste eingereichte Planungen der aktiven Phase
    """
    try:
        planungsphase_id = request.args.get('planungsphase_id', type=int)

        # ✅ NEUE LOGIK: Standard = nur aktive Phase
        if planungsphase_id:
            # Spezifische Phase angefordert (z.B. für Archiv-Ansicht)
            planungen = planung_service.get_eingereichte(semester_id=None)
            planungen = [p for p in planungen if p.planungsphase_id == planungsphase_id]
        else:
            # ✅ STANDARD: Nur aktive Phase zeigen
            active_phase = Planungsphase.get_active_phase()

            if not active_phase:
                # 🔴 Keine aktive Phase = nichts zu prüfen (korrekt!)
                planungen = []
            else:
                # ✅ Zeige nur eingereichte Planungen der aktiven Phase
                planungen = planung_service.get_eingereichte(semester_id=None)
                planungen = [p for p in planungen if p.planungsphase_id == active_phase.id]

        # Format mit Details - ✅ WICHTIG: include_module=True für vollständige Daten
        items = []
        for p in planungen:
            data = p.to_dict(include_module=True)  # ✅ Module einschließen!
            data['anzahl_module'] = p.anzahl_module
            items.append(data)

        return ApiResponse.success(
            data=items,
            message=f'{len(items)} eingereichte Planung(en) gefunden'
        )
    
    except Exception as e:
        return ApiResponse.error(
            message='Fehler beim Laden der eingereichten Planungen',
            errors=[str(e)],
            status_code=500
        )


# =========================================================================
# DELETE PLANUNG
# =========================================================================

@planung_api.route('/<int:planung_id>', methods=['DELETE'])
@login_required
def delete_planung(planung_id: int):
    """
    DELETE /api/planung/<id>
    
    Löscht eine Planung.
    
    Query Parameters:
        ?force=true  # Erzwingt Löschen (Dekan)
    
    Returns:
        200: Planung gelöscht
        403: Keine Berechtigung
        404: Planung nicht gefunden
    """
    try:
        user = get_current_user()
        planung = planung_service.get_by_id(planung_id)
        
        if not planung:
            return ApiResponse.error(
                message='Planung nicht gefunden',
                status_code=404
            )
        
        # Berechtigung prüfen
        force = request.args.get('force', 'false').lower() == 'true'
        if planung.benutzer_id != user.id:
            if user.rolle.name != 'dekan' or not force:
                return ApiResponse.error(
                    message='Keine Berechtigung zum Löschen',
                    status_code=403
                )
        
        # Delete
        success = planung_service.delete_planung(planung_id, force=force)
        
        if not success:
            return ApiResponse.error(
                message='Planung konnte nicht gelöscht werden',
                status_code=400
            )
        
        return ApiResponse.success(
            message='Planung erfolgreich gelöscht'
        )
    
    except ValueError as e:
        return ApiResponse.error(
            message='Planung kann nicht gelöscht werden',
            errors=[str(e)],
            status_code=400
        )
    except Exception as e:
        return ApiResponse.error(
            message='Fehler beim Löschen der Planung',
            errors=[str(e)],
            status_code=500
        )