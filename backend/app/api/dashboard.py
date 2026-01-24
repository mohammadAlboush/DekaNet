"""
Dashboard API
=============
REST API für Dashboard und Übersichten.

Endpoints:
    GET /api/dashboard              - Dashboard Übersicht
    GET /api/dashboard/dozent       - Dozenten-Dashboard
    GET /api/dashboard/dekan        - Dekan-Dashboard
    GET /api/dashboard/statistik    - Gesamt-Statistiken
    GET /api/dashboard/notifications - Benachrichtigungen
"""

from flask import Blueprint, request, current_app
from datetime import datetime
from sqlalchemy.orm import joinedload
from sqlalchemy import func
from app.extensions import db, cache
from app.api.base import (
    ApiResponse,
    login_required,
    role_required,
    get_current_user,
    get_pagination_params
)
from app.services import (
    semester_service,
    planung_service,
    user_service,
    modul_service,
    dozent_service,
    notification_service
)
from app.models.modul import Modul, ModulDozent

# Blueprint
dashboard_api = Blueprint('dashboard', __name__, url_prefix='/api/dashboard')


# =========================================================================
# GENERAL DASHBOARD
# =========================================================================

@dashboard_api.route('/', methods=['GET'])
@login_required
def get_dashboard():
    """
    GET /api/dashboard
    
    Holt Dashboard-Daten basierend auf Benutzerrolle.
    
    Returns:
        200: Dashboard Daten
    """
    try:
        user = get_current_user()
        
        # Basis-Daten für alle
        data = {
            'user': {
                'id': user.id,
                'username': user.username,
                'rolle': user.rolle.name if user.rolle else 'unknown',
                'name_komplett': user.name_komplett
            },
            'semester': {
                'aktiv': None,
                'planungsphase': None
            }
        }
        
        # Aktives Semester
        aktives_semester = semester_service.get_aktives_semester()
        if aktives_semester:
            data['semester']['aktiv'] = aktives_semester.to_dict()
        
        # Planungssemester
        planungs_semester = semester_service.get_planungssemester()
        if planungs_semester:
            data['semester']['planungsphase'] = planungs_semester.to_dict()
        
        # Benachrichtigungen
        ungelesene = notification_service.count_ungelesene(user.id)
        data['benachrichtigungen'] = {
            'ungelesen': ungelesene
        }
        
        # Rollen-spezifische Daten
        if user.rolle and user.rolle.name == 'dekan':
            # Dekan Dashboard
            data['dekan'] = _get_dekan_dashboard_data()
        else:
            # Dozenten Dashboard
            data['dozent'] = _get_dozent_dashboard_data(user)
        
        return ApiResponse.success(data=data)
    
    except Exception as e:
        return ApiResponse.error(
            message='Fehler beim Laden des Dashboards',
            errors=[str(e)],
            status_code=500
        )


# =========================================================================
# DOZENTEN DASHBOARD
# =========================================================================

@dashboard_api.route('/dozent', methods=['GET'])
@login_required
def get_dozent_dashboard():
    """
    GET /api/dashboard/dozent
    
    Holt Dozenten-spezifische Dashboard-Daten.
    
    Returns:
        200: Dozenten Dashboard
    """
    try:
        user = get_current_user()
        data = _get_dozent_dashboard_data(user)
        
        return ApiResponse.success(data=data)
    
    except Exception as e:
        return ApiResponse.error(
            message='Fehler beim Laden des Dozenten-Dashboards',
            errors=[str(e)],
            status_code=500
        )


def _get_dozent_dashboard_data(user):
    """Helper: Holt Dozenten Dashboard Daten"""
    data = {}
    
    # Eigene Planungen
    planungen = planung_service.get_by_user(user.id)
    data['planungen'] = {
        'gesamt': len(planungen),
        'entwurf': len([p for p in planungen if p.status == 'entwurf']),
        'eingereicht': len([p for p in planungen if p.status == 'eingereicht']),
        'freigegeben': len([p for p in planungen if p.status == 'freigegeben']),
        'liste': [p.to_dict() for p in planungen[:5]]  # Letzte 5
    }
    
    # Aktuelle Planung
    planungs_semester = semester_service.get_planungssemester()
    if planungs_semester:
        aktuelle_planung = planung_service.get_by_semester_and_user(
            planungs_semester.id,
            user.id
        )
        if aktuelle_planung:
            data['aktuelle_planung'] = {
                **aktuelle_planung.to_dict(),
                'anzahl_module': aktuelle_planung.anzahl_module
            }
        else:
            data['aktuelle_planung'] = None
    
    # Module (wenn Dozent verknüpft)
    if user.dozent:
        module = dozent_service.get_module(user.dozent_id)
        data['module'] = {
            'gesamt': len(module),
            'liste': module[:10]  # Top 10
        }
    
    return data


# =========================================================================
# DEKAN DASHBOARD
# =========================================================================

@dashboard_api.route('/dekan', methods=['GET'])
@role_required('dekan')
def get_dekan_dashboard():
    """
    GET /api/dashboard/dekan
    
    Holt Dekan-spezifische Dashboard-Daten.
    
    Returns:
        200: Dekan Dashboard
    """
    try:
        data = _get_dekan_dashboard_data()
        
        return ApiResponse.success(data=data)
    
    except Exception as e:
        return ApiResponse.error(
            message='Fehler beim Laden des Dekan-Dashboards',
            errors=[str(e)],
            status_code=500
        )


def _get_dekan_dashboard_data():
    """Helper: Holt Dekan Dashboard Daten"""
    data = {}
    
    # Planungssemester Statistiken
    planungs_semester = semester_service.get_planungssemester()
    if planungs_semester:
        statistik = semester_service.get_statistik(planungs_semester.id)
        data['planungssemester'] = statistik
        
        # Eingereichte Planungen
        eingereichte = planung_service.get_eingereichte(planungs_semester.id)
        data['eingereichte_planungen'] = {
            'anzahl': len(eingereichte),
            'liste': [p.to_dict() for p in eingereichte]
        }
    else:
        data['planungssemester'] = None
        data['eingereichte_planungen'] = {
            'anzahl': 0,
            'liste': []
        }
    
    # Gesamt-Statistiken
    data['statistiken'] = {
        'benutzer': user_service.get_statistik(),
        'dozenten': dozent_service.get_statistik(),
        'module': modul_service.get_statistik()
    }
    
    # Alle Semester
    alle_semester = semester_service.get_all()
    data['alle_semester'] = [s.to_dict() for s in alle_semester]
    
    return data


# =========================================================================
# STATISTIKEN
# =========================================================================

@dashboard_api.route('/statistik', methods=['GET'])
@login_required
@cache.cached(timeout=60, query_string=True)  # ✅ PERFORMANCE: 60s Cache für Statistiken
def get_statistik():
    """
    GET /api/dashboard/statistik

    Holt Gesamt-Statistiken.

    Returns:
        200: Gesamt-Statistiken
    """
    try:
        data = {
            'benutzer': user_service.get_statistik(),
            'dozenten': dozent_service.get_statistik(),
            'module': modul_service.get_statistik(),
            'semester': {
                'gesamt': semester_service.count(),
                'aktiv': semester_service.count(ist_aktiv=True)
            }
        }

        # Planungs-Statistiken (wenn Planungsphase)
        planungs_semester = semester_service.get_planungssemester()
        if planungs_semester:
            data['planungen'] = planung_service.get_statistik(planungs_semester.id)

        return ApiResponse.success(data=data)

    except Exception as e:
        return ApiResponse.error(
            message='Fehler beim Laden der Statistiken',
            errors=[str(e)],
            status_code=500
        )


@dashboard_api.route('/statistik/phasen', methods=['GET'])
@login_required
@cache.cached(timeout=60, query_string=True)  # ✅ PERFORMANCE: 60s Cache
def get_phasen_statistik():
    """
    GET /api/dashboard/statistik/phasen

    Holt Statistiken pro Planungsphase.

    Query Parameters:
        ?semester_id=<id>  - Optional: Filter nach Semester
        ?limit=<n>         - Optional: Anzahl der Phasen (default: alle)

    Returns:
        200: Statistiken pro Planungsphase mit Gesamtübersicht
    """
    try:
        from app.models.planungsphase import Planungsphase
        from app.models.planung import Semesterplanung
        from sqlalchemy import func

        semester_id = request.args.get('semester_id', type=int)
        limit = request.args.get('limit', type=int)

        # Query für Planungsphasen
        query = Planungsphase.query

        if semester_id:
            query = query.filter_by(semester_id=semester_id)

        # Sortiere nach Erstellungsdatum (neueste zuerst)
        query = query.order_by(Planungsphase.created_at.desc())

        if limit:
            query = query.limit(limit)

        phasen = query.all()

        # Statistiken pro Phase sammeln
        phasen_statistiken = []

        # Gesamtstatistiken initialisieren
        gesamt_statistik = {
            'anzahl_phasen': len(phasen),
            'anzahl_planungen_gesamt': 0,
            'anzahl_einreichungen_gesamt': 0,
            'anzahl_genehmigt_gesamt': 0,
            'anzahl_abgelehnt_gesamt': 0,
            'anzahl_entwuerfe_gesamt': 0,
            'durchschnittliche_genehmigungsrate': 0.0,
            'aktive_phasen': 0
        }

        for phase in phasen:
            # ✅ KORRIGIERT: Zähle nur Planungen die DIESER Phase zugeordnet sind
            planungen_query = Semesterplanung.query.filter_by(
                planungsphase_id=phase.id  # ✅ Nutze phase.id statt semester_id
            )

            # Planungen nach Status zählen
            entwuerfe = planungen_query.filter_by(status='entwurf').count()
            eingereicht = planungen_query.filter_by(status='eingereicht').count()
            freigegeben = planungen_query.filter_by(status='freigegeben').count()
            abgelehnt = planungen_query.filter_by(status='abgelehnt').count()

            gesamt_planungen = entwuerfe + eingereicht + freigegeben + abgelehnt

            # Berechne SWS-Statistiken
            total_sws = 0
            avg_sws = 0
            if gesamt_planungen > 0:
                # ✅ KORRIGIERT: Nutze planungsphase_id für SWS-Berechnung
                sws_result = db.session.query(
                    func.sum(Semesterplanung.gesamt_sws).label('total'),
                    func.avg(Semesterplanung.gesamt_sws).label('average')
                ).filter(
                    Semesterplanung.planungsphase_id == phase.id  # ✅ KORRIGIERT
                ).first()

                total_sws = float(sws_result.total or 0)
                avg_sws = float(sws_result.average or 0)

            # Genehmigungsrate berechnen
            genehmigungsrate = 0.0
            if eingereicht + freigegeben + abgelehnt > 0:
                genehmigungsrate = (freigegeben / (eingereicht + freigegeben + abgelehnt)) * 100

            # Phase Dauer berechnen
            if phase.geschlossen_am and phase.startdatum:
                dauer_tage = (phase.geschlossen_am - phase.startdatum).days
            elif phase.ist_aktiv and phase.startdatum:
                dauer_tage = (datetime.utcnow() - phase.startdatum).days
            else:
                dauer_tage = 0

            phase_stat = {
                'phase_id': phase.id,
                'phase_name': phase.name,
                'semester_id': phase.semester_id,
                'semester_name': phase.semester.kuerzel if phase.semester else None,
                'startdatum': phase.startdatum.isoformat() if phase.startdatum else None,
                'enddatum': phase.enddatum.isoformat() if phase.enddatum else None,
                'ist_aktiv': phase.ist_aktiv,
                'geschlossen_am': phase.geschlossen_am.isoformat() if phase.geschlossen_am else None,
                'dauer_tage': dauer_tage,
                'statistiken': {
                    'gesamt_planungen': gesamt_planungen,
                    'entwuerfe': entwuerfe,
                    'eingereicht': eingereicht,
                    'freigegeben': freigegeben,
                    'abgelehnt': abgelehnt,
                    'genehmigungsrate': round(genehmigungsrate, 2),
                    'sws': {
                        'gesamt': round(total_sws, 2),
                        'durchschnitt': round(avg_sws, 2)
                    }
                }
            }

            phasen_statistiken.append(phase_stat)

            # Aktualisiere Gesamtstatistiken
            gesamt_statistik['anzahl_planungen_gesamt'] += gesamt_planungen
            gesamt_statistik['anzahl_einreichungen_gesamt'] += eingereicht
            gesamt_statistik['anzahl_genehmigt_gesamt'] += freigegeben
            gesamt_statistik['anzahl_abgelehnt_gesamt'] += abgelehnt
            gesamt_statistik['anzahl_entwuerfe_gesamt'] += entwuerfe

            if phase.ist_aktiv:
                gesamt_statistik['aktive_phasen'] += 1

        # Berechne durchschnittliche Genehmigungsrate
        if gesamt_statistik['anzahl_einreichungen_gesamt'] + gesamt_statistik['anzahl_genehmigt_gesamt'] + gesamt_statistik['anzahl_abgelehnt_gesamt'] > 0:
            gesamt_statistik['durchschnittliche_genehmigungsrate'] = round(
                (gesamt_statistik['anzahl_genehmigt_gesamt'] /
                 (gesamt_statistik['anzahl_einreichungen_gesamt'] +
                  gesamt_statistik['anzahl_genehmigt_gesamt'] +
                  gesamt_statistik['anzahl_abgelehnt_gesamt'])) * 100,
                2
            )

        return ApiResponse.success(data={
            'gesamt': gesamt_statistik,
            'phasen': phasen_statistiken
        })

    except Exception as e:
        return ApiResponse.error(
            message='Fehler beim Laden der Phasen-Statistiken',
            errors=[str(e)],
            status_code=500
        )


# =========================================================================
# BENACHRICHTIGUNGEN
# =========================================================================

@dashboard_api.route('/notifications', methods=['GET'])
@login_required
def get_notifications():
    """
    GET /api/dashboard/notifications
    
    Holt Benachrichtigungen des Benutzers.
    
    Query Parameters:
        ?ungelesen=true
        ?limit=20
        
    Returns:
        200: Liste von Benachrichtigungen
    """
    try:
        user = get_current_user()
        
        ungelesen_only = request.args.get('ungelesen', 'false').lower() == 'true'
        limit = request.args.get('limit', 20, type=int)
        
        if ungelesen_only:
            notifications = notification_service.get_ungelesene(user.id)
        else:
            notifications = notification_service.get_by_user(user.id, limit=limit)
        
        # Format
        items = [n.to_dict() for n in notifications]
        
        # Statistik
        statistik = notification_service.get_statistik(user.id)
        
        return ApiResponse.success(
            data={
                'notifications': items,
                'statistik': statistik
            }
        )
    
    except Exception as e:
        return ApiResponse.error(
            message='Fehler beim Laden der Benachrichtigungen',
            errors=[str(e)],
            status_code=500
        )


@dashboard_api.route('/notifications/<int:notification_id>/gelesen', methods=['POST'])
@login_required
def markiere_gelesen(notification_id: int):
    """
    POST /api/dashboard/notifications/<id>/gelesen
    
    Markiert Benachrichtigung als gelesen.
    
    Returns:
        200: Benachrichtigung als gelesen markiert
        404: Benachrichtigung nicht gefunden
    """
    try:
        success = notification_service.markiere_gelesen(notification_id)
        
        if not success:
            return ApiResponse.error(
                message='Benachrichtigung nicht gefunden',
                status_code=404
            )
        
        return ApiResponse.success(
            message='Benachrichtigung als gelesen markiert'
        )
    
    except Exception as e:
        return ApiResponse.error(
            message='Fehler beim Markieren der Benachrichtigung',
            errors=[str(e)],
            status_code=500
        )


@dashboard_api.route('/notifications/alle-gelesen', methods=['POST'])
@login_required
def markiere_alle_gelesen():
    """
    POST /api/dashboard/notifications/alle-gelesen

    Markiert alle Benachrichtigungen als gelesen.

    Returns:
        200: Alle Benachrichtigungen als gelesen markiert
    """
    try:
        user = get_current_user()
        count = notification_service.markiere_alle_gelesen(user.id)

        return ApiResponse.success(
            message=f'{count} Benachrichtigung(en) als gelesen markiert',
            data={'count': count}
        )

    except Exception as e:
        return ApiResponse.error(
            message='Fehler beim Markieren der Benachrichtigungen',
            errors=[str(e)],
            status_code=500
        )


# =========================================================================
# NICHT ZUGEORDNETE MODULE
# =========================================================================

@dashboard_api.route('/nicht-zugeordnete-module', methods=['GET'])
@login_required
def get_nicht_zugeordnete_module():
    """
    GET /api/dashboard/nicht-zugeordnete-module

    Holt Module die noch nicht zugeordnet sind.

    Logik:
    - Wenn aktives Semester = Wintersemester
      → Zeige Module mit turnus="Wintersemester" oder "Jedes Semester"
    - Wenn aktives Semester = Sommersemester
      → Zeige Module mit turnus="Sommersemester" oder "Jedes Semester"
    - Nur Module die NICHT in einer aktiven Semesterplanung sind
    - Nur wenn eine Planungsphase aktiv ist

    Query Parameters:
        ?semester_id=<id>  - Optional: Spezifisches Semester (default: aktives Semester)
        ?po_id=<id>        - Optional: Filter nach Prüfungsordnung

    Returns:
        200: Liste nicht zugeordneter Module mit Statistiken
        400: Keine aktive Planungsphase
    """
    try:
        from app.models.semester import Semester
        from app.models.planungsphase import Planungsphase
        from app.models.modul import Modul
        from app.models.planung import GeplantesModul
        from sqlalchemy import and_, or_

        # Semester bestimmen
        semester_id = request.args.get('semester_id', type=int)
        po_id = request.args.get('po_id', type=int)

        semester = None
        relevante_turnus = None

        if semester_id:
            semester = Semester.query.get(semester_id)
            if not semester:
                return ApiResponse.error(
                    message='Semester nicht gefunden',
                    status_code=404
                )

            # Bestimme relevante Turnus-Werte basierend auf Semester
            # Inkl. "jährlich" Varianten, da diese auch in diesem Semester stattfinden
            if semester.ist_wintersemester:
                relevante_turnus = ['Wintersemester', 'Wintersemester, jährlich', 'Jedes Semester']
            elif semester.ist_sommersemester:
                relevante_turnus = ['Sommersemester', 'Sommersemester, jährlich', 'Jedes Semester']
        else:
            # Kein Semester angegeben -> "Alle" Filter
            # Hole aktives Semester nur für Info-Anzeige
            semester = Semester.get_aktives_semester()
            # relevante_turnus = None bedeutet "alle Turnus"
            relevante_turnus = None

        # Wenn kein Semester gefunden wurde (auch nicht aktives)
        if not semester:
            return ApiResponse.error(
                message='Kein Semester gefunden',
                status_code=400
            )

        # Prüfe ob Planungsphase aktiv (nur wenn spezifisches Semester)
        if semester_id and not semester.ist_planungsphase:
            return ApiResponse.success(
                message='Keine aktive Planungsphase',
                data={
                    'semester': semester.to_dict(),
                    'planungsphase_aktiv': False,
                    'nicht_zugeordnete_module': [],
                    'statistik': {
                        'gesamt': 0,
                        'nach_turnus': {}
                    }
                }
            )

        # Hole aktive Planungsphase (falls semester_id angegeben)
        aktive_phase = None
        planungsphase_aktiv = False

        if semester_id:
            aktive_phase = Planungsphase.query.filter_by(
                semester_id=semester.id,
                ist_aktiv=True
            ).first()
            planungsphase_aktiv = aktive_phase is not None

        # Query: Alle Module des relevanten Turnus mit Eager Loading
        modul_query = Modul.query.options(
            joinedload(Modul.dozent_zuordnungen).joinedload(ModulDozent.dozent)
        )

        if po_id:
            modul_query = modul_query.filter_by(po_id=po_id)

        if relevante_turnus:
            modul_query = modul_query.filter(Modul.turnus.in_(relevante_turnus))

        alle_module = modul_query.all()

        # Hole alle bereits geplanten Modul-IDs
        geplante_modul_ids = []

        if semester_id and aktive_phase:
            # Spezifisches Semester mit aktiver Phase
            from app.models.planung import Semesterplanung
            geplante_modul_ids = db.session.query(GeplantesModul.modul_id).join(
                Semesterplanung,
                GeplantesModul.semesterplanung_id == Semesterplanung.id
            ).filter(
                Semesterplanung.planungsphase_id == aktive_phase.id
            ).distinct().all()

            geplante_modul_ids = [m[0] for m in geplante_modul_ids]
        elif not semester_id:
            # "Alle" Filter: Hole alle jemals geplanten Module
            geplante_modul_ids = db.session.query(GeplantesModul.modul_id).distinct().all()
            geplante_modul_ids = [m[0] for m in geplante_modul_ids]

        # Filter: Nicht zugeordnete Module
        nicht_zugeordnete = []
        statistik_nach_turnus = {}

        # ✅ PERFORMANCE FIX: Prefetch alle Planungen mit Benutzer-Daten VOR dem Loop
        modul_planungen_map = {}  # modul_id -> [planungen_data]
        if semester_id and aktive_phase:
            from app.models.planung import Semesterplanung
            from app.models.user import Benutzer

            # Hole alle Planungen für alle Module in einem Query (mit Benutzer-Join)
            alle_planungen = db.session.query(
                GeplantesModul.modul_id,
                Semesterplanung.id.label('planung_id'),
                Semesterplanung.status,
                Semesterplanung.eingereicht_am,
                Semesterplanung.benutzer_id,
                Benutzer.titel,
                Benutzer.vorname,
                Benutzer.nachname
            ).join(
                Semesterplanung,
                GeplantesModul.semesterplanung_id == Semesterplanung.id
            ).join(
                Benutzer,
                Semesterplanung.benutzer_id == Benutzer.id
            ).filter(
                Semesterplanung.planungsphase_id == aktive_phase.id
            ).all()

            # Gruppiere nach modul_id
            for p in alle_planungen:
                if p.modul_id not in modul_planungen_map:
                    modul_planungen_map[p.modul_id] = []

                # Name zusammenbauen
                name_teile = []
                if p.titel:
                    name_teile.append(p.titel)
                if p.vorname:
                    name_teile.append(p.vorname)
                if p.nachname:
                    name_teile.append(p.nachname)
                dozent_name = ' '.join(name_teile) if name_teile else 'Unbekannt'

                modul_planungen_map[p.modul_id].append({
                    'hat_planung': True,
                    'planung_id': p.planung_id,
                    'dozent_id': p.benutzer_id,
                    'dozent_name': dozent_name,
                    'status': p.status,
                    'eingereicht_am': p.eingereicht_am.isoformat() if p.eingereicht_am else None
                })

        for modul in alle_module:
            if modul.id not in geplante_modul_ids:
                # Hole Verantwortlichen Dozenten (nutzt eager-loaded dozent_zuordnungen)
                verantwortliche = modul.get_verantwortliche()
                verantwortlicher_data = None
                if verantwortliche:
                    v = verantwortliche[0]  # Erster Verantwortlicher
                    verantwortlicher_data = {
                        'dozent_id': v.id,
                        'name': v.name_komplett,
                        'email': v.email
                    }

                # Hole alle Lehrpersonen (nutzt eager-loaded dozent_zuordnungen)
                lehrpersonen = modul.get_lehrpersonen()
                lehrpersonen_data = [{
                    'dozent_id': lp.id,
                    'name': lp.name_komplett,
                    'email': lp.email
                } for lp in lehrpersonen]

                # ✅ PERFORMANCE FIX: Nutze prefetched Planungen statt Query im Loop
                planungen_data = modul_planungen_map.get(modul.id, [])

                nicht_zugeordnete.append({
                    'id': modul.id,
                    'kuerzel': modul.kuerzel,
                    'bezeichnung_de': modul.bezeichnung_de,
                    'bezeichnung_en': modul.bezeichnung_en,
                    'leistungspunkte': modul.leistungspunkte,
                    'turnus': modul.turnus,
                    'sws_gesamt': modul.get_sws_gesamt(),
                    'po_id': modul.po_id,
                    'verantwortlicher': verantwortlicher_data,
                    'lehrpersonen': lehrpersonen_data,
                    'planungen': planungen_data
                })

                # Statistik nach Turnus
                turnus = modul.turnus or 'Unbekannt'
                statistik_nach_turnus[turnus] = statistik_nach_turnus.get(turnus, 0) + 1

        # Sortiere nach Kürzel
        nicht_zugeordnete.sort(key=lambda x: x['kuerzel'])

        return ApiResponse.success(data={
            'semester': semester.to_dict() if semester else None,
            'planungsphase': {
                'id': aktive_phase.id,
                'name': aktive_phase.name,
                'ist_aktiv': aktive_phase.ist_aktiv
            } if aktive_phase else None,
            'planungsphase_aktiv': planungsphase_aktiv,
            'relevante_turnus': relevante_turnus,
            'nicht_zugeordnete_module': nicht_zugeordnete,
            'statistik': {
                'gesamt': len(nicht_zugeordnete),
                'nach_turnus': statistik_nach_turnus,
                'alle_module': len(alle_module),
                'geplante_module': len(geplante_modul_ids),
                'zuordnungsquote': round((len(geplante_modul_ids) / len(alle_module) * 100), 2) if len(alle_module) > 0 else 0
            }
        })

    except Exception as e:
        return ApiResponse.error(
            message='Fehler beim Laden der nicht zugeordneten Module',
            errors=[str(e)],
            status_code=500
        )


# =========================================================================
# DOZENTEN PLANUNGS-FORTSCHRITT
# =========================================================================

@dashboard_api.route('/dozenten-planungsfortschritt', methods=['GET'])
@role_required('dekan')
def get_dozenten_planungsfortschritt():
    """
    GET /api/dashboard/dozenten-planungsfortschritt

    Zeigt für jeden Dozenten:
    - Wie viele Module er planen muss (basierend auf Modulverantwortung)
    - Wie viele er bereits geplant hat
    - Prozentsatz

    Query Parameters:
        ?semester_id=<id>  - Optional: Spezifisches Semester (default: Planungssemester)

    Returns:
        200: Liste mit Dozenten und ihrem Planungsfortschritt
    """
    try:
        from app.models.semester import Semester
        from app.models.planungsphase import Planungsphase
        from app.models.planung import Semesterplanung, GeplantesModul
        from app.models.dozent import Dozent

        semester_id = request.args.get('semester_id', type=int)

        # Semester bestimmen
        if semester_id:
            semester = Semester.query.get(semester_id)
        else:
            semester = semester_service.get_planungssemester()

        if not semester:
            return ApiResponse.error(
                message='Kein Semester gefunden',
                status_code=400
            )

        # Relevante Turnus-Werte für dieses Semester
        if semester.ist_wintersemester:
            relevante_turnus = ['Wintersemester', 'Wintersemester, jährlich', 'Jedes Semester']
        elif semester.ist_sommersemester:
            relevante_turnus = ['Sommersemester', 'Sommersemester, jährlich', 'Jedes Semester']
        else:
            relevante_turnus = None

        # Aktive Planungsphase finden
        aktive_phase = Planungsphase.query.filter_by(
            semester_id=semester.id,
            ist_aktiv=True
        ).first()

        # Hole alle Dozenten die Module verantworten
        # Prüfe zuerst, welche Rollen existieren und passe Filter an
        verantwortlicher_rolle = 'verantwortlicher'

        # Fallback: Falls keine 'verantwortlicher' Einträge existieren,
        # suche nach alternativen Bezeichnungen
        if not db.session.query(ModulDozent.id).filter_by(rolle='verantwortlicher').first():
            # Suche nach Alternativen (Modulverantwortlicher, etc.)
            for alt_rolle in ['Modulverantwortlicher', 'modulverantwortlicher', 'Verantwortlicher', 'verantwortlich']:
                if db.session.query(ModulDozent.id).filter_by(rolle=alt_rolle).first():
                    verantwortlicher_rolle = alt_rolle
                    current_app.logger.debug(f"Using alternative rolle: {verantwortlicher_rolle}")
                    break

        current_app.logger.debug(f"Searching for rolle: {verantwortlicher_rolle}")

        dozenten_query = db.session.query(
            Dozent.id,
            Dozent.titel,
            Dozent.vorname,
            Dozent.nachname,
            Dozent.email
        ).join(
            ModulDozent, ModulDozent.dozent_id == Dozent.id
        ).filter(
            ModulDozent.rolle == verantwortlicher_rolle,
            Dozent.aktiv == True
        ).distinct()

        dozenten = dozenten_query.all()
        current_app.logger.debug(f"Found {len(dozenten)} dozenten with rolle '{verantwortlicher_rolle}'")

        # ✅ PERFORMANCE FIX: Prefetch alle Modul-Dozent-Zuordnungen VOR dem Loop
        dozent_ids = [d.id for d in dozenten]

        # Query: Alle Module aller Dozenten mit relevantem Turnus (1 Query statt N)
        module_query = db.session.query(
            ModulDozent.dozent_id,
            Modul.id.label('modul_id'),
            Modul.kuerzel,
            Modul.bezeichnung_de
        ).join(
            Modul, ModulDozent.modul_id == Modul.id
        ).filter(
            ModulDozent.dozent_id.in_(dozent_ids),
            ModulDozent.rolle == verantwortlicher_rolle
        )

        if relevante_turnus:
            module_query = module_query.filter(Modul.turnus.in_(relevante_turnus))

        alle_module_zuordnungen = module_query.all()

        # Gruppiere nach dozent_id: {dozent_id: [(modul_id, kuerzel, bezeichnung), ...]}
        dozent_module_map = {}
        for z in alle_module_zuordnungen:
            if z.dozent_id not in dozent_module_map:
                dozent_module_map[z.dozent_id] = []
            dozent_module_map[z.dozent_id].append({
                'id': z.modul_id,
                'kuerzel': z.kuerzel,
                'bezeichnung': z.bezeichnung_de
            })

        # ✅ PERFORMANCE FIX: Prefetch alle geplanten Module (1 Query statt N)
        alle_geplanten_modul_ids = set()
        if aktive_phase:
            geplante_query = db.session.query(GeplantesModul.modul_id).join(
                Semesterplanung,
                GeplantesModul.semesterplanung_id == Semesterplanung.id
            ).filter(
                Semesterplanung.planungsphase_id == aktive_phase.id
            ).distinct().all()

            alle_geplanten_modul_ids = set(m[0] for m in geplante_query)

        result = []

        for dozent in dozenten:
            # ✅ PERFORMANCE FIX: Nutze prefetched Daten statt Query
            verantwortliche_module = dozent_module_map.get(dozent.id, [])
            anzahl_zu_planen = len(verantwortliche_module)

            if anzahl_zu_planen == 0:
                continue  # Skip Dozenten ohne Module in diesem Semester

            # ✅ PERFORMANCE FIX: Filter aus prefetched Set
            geplante_modul_ids = set(
                m['id'] for m in verantwortliche_module
                if m['id'] in alle_geplanten_modul_ids
            )

            # Berechne nicht geplante Module
            nicht_geplante_module = [
                m for m in verantwortliche_module
                if m['id'] not in geplante_modul_ids
            ]

            anzahl_geplant = len(geplante_modul_ids)
            prozent = round((anzahl_geplant / anzahl_zu_planen) * 100, 1) if anzahl_zu_planen > 0 else 0

            # Name zusammenbauen
            name_teile = []
            if dozent.titel:
                name_teile.append(dozent.titel)
            if dozent.vorname:
                name_teile.append(dozent.vorname)
            name_teile.append(dozent.nachname)
            name_komplett = ' '.join(name_teile)

            result.append({
                'dozent_id': dozent.id,
                'name': name_komplett,
                'email': dozent.email,
                'anzahl_zu_planen': anzahl_zu_planen,
                'anzahl_geplant': anzahl_geplant,
                'anzahl_offen': anzahl_zu_planen - anzahl_geplant,
                'prozent_geplant': prozent,
                'status': 'vollständig' if prozent == 100 else 'teilweise' if prozent > 0 else 'offen',
                'nicht_geplante_module': nicht_geplante_module
            })

        # Sortiere: Erst nach Prozent (aufsteigend), dann nach Name
        result.sort(key=lambda x: (x['prozent_geplant'], x['name']))

        # Statistik
        vollstaendig = len([d for d in result if d['status'] == 'vollständig'])
        teilweise = len([d for d in result if d['status'] == 'teilweise'])
        offen = len([d for d in result if d['status'] == 'offen'])

        return ApiResponse.success(data={
            'semester': semester.to_dict(),
            'planungsphase_aktiv': aktive_phase is not None,
            'dozenten': result,
            'statistik': {
                'gesamt_dozenten': len(result),
                'vollstaendig': vollstaendig,
                'teilweise': teilweise,
                'offen': offen,
                'durchschnitt_prozent': round(sum(d['prozent_geplant'] for d in result) / len(result), 1) if result else 0
            }
        })

    except Exception as e:
        current_app.logger.exception("Error in get_dozenten_planungsfortschritt")
        return ApiResponse.error(
            message='Fehler beim Laden des Planungsfortschritts',
            errors=[str(e)],
            status_code=500
        )