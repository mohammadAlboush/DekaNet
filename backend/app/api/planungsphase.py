"""
Planungsphase API
=================
REST API für Planungsphasen-Verwaltung
"""

from flask import Blueprint, request, jsonify, current_app
from flask_jwt_extended import jwt_required, get_jwt_identity
from datetime import datetime
from sqlalchemy import desc

from functools import wraps
from app.extensions import db
from app.models.planungsphase import Planungsphase, PhaseSubmission, ArchiviertePlanung
from app.models.user import Benutzer as User
from app.models.planung import Semesterplanung
from app.models.semester import Semester

# Role required decorator
def role_required(role):
    """Decorator to require a specific role"""
    def decorator(f):
        @wraps(f)
        @jwt_required()
        def decorated_function(*args, **kwargs):
            user_id = get_jwt_identity()
            user = User.query.get(user_id)

            if not user or not user.rolle or user.rolle.name != role:
                return jsonify({'success': False, 'message': 'Nicht autorisiert'}), 403

            return f(*args, **kwargs)
        return decorated_function
    return decorator

# Blueprint erstellen
planungsphase_api = Blueprint('planungsphase_api', __name__, url_prefix='/api/planungphase')
archiv_api = Blueprint('archiv_api', __name__, url_prefix='/api/archiv')

# Valid status values for input validation
VALID_STATUS_VALUES = {'entwurf', 'eingereicht', 'freigegeben', 'abgelehnt'}


# ============================================
# PLANUNGSPHASE API ENDPOINTS
# ============================================

@planungsphase_api.route('/start', methods=['POST'])
@jwt_required()
@role_required('dekan')
def start_phase():
    """Startet eine neue Planungsphase"""
    try:
        data = request.get_json()
        user_id = get_jwt_identity()

        # Validierung
        if not data.get('semester_id'):
            return jsonify({'success': False, 'message': 'Semester ID erforderlich'}), 400

        if not data.get('name'):
            return jsonify({'success': False, 'message': 'Phasenname erforderlich'}), 400

        # Parse Enddatum wenn vorhanden
        enddatum = None
        if data.get('enddatum'):
            try:
                enddatum = datetime.fromisoformat(data['enddatum'].replace('Z', '+00:00'))
            except:
                return jsonify({'success': False, 'message': 'Ungültiges Enddatum'}), 400

        # Starte neue Phase
        phase = Planungsphase.start_phase(
            semester_id=data['semester_id'],
            name=data['name'],
            enddatum=enddatum,
            user_id=user_id
        )

        return jsonify({
            'success': True,
            'phase': phase.to_dict()
        }), 201

    except Exception as e:
        current_app.logger.error(f"Error starting phase: {e}")
        return jsonify({
            'success': False,
            'message': 'Fehler beim Starten der Planungsphase',
            'error': str(e)
        }), 500


@planungsphase_api.route('/<int:phase_id>/close', methods=['POST'])
@jwt_required()
@role_required('dekan')
def close_phase(phase_id):
    """Schließt eine Planungsphase"""
    try:
        data = request.get_json()
        user_id = get_jwt_identity()

        phase = Planungsphase.query.get_or_404(phase_id)

        # Schließe Phase mit Archivierung
        result = phase.close_phase(
            user_id=user_id,
            archiviere_entwuerfe=data.get('archiviere_entwuerfe', False),
            grund=data.get('grund')
        )

        return jsonify({
            'success': True,
            'phase': phase.to_dict(),
            'archivierte_planungen': result['archivierte_planungen'],
            'geloeschte_entwuerfe': result['geloeschte_entwuerfe']
        })

    except Exception as e:
        current_app.logger.error(f"Error closing phase: {e}")
        return jsonify({
            'success': False,
            'message': 'Fehler beim Schließen der Planungsphase',
            'error': str(e)
        }), 500


@planungsphase_api.route('', methods=['GET'])
@jwt_required()
def get_all_phases():
    """Holt alle Planungsphasen"""
    try:
        semester_id = request.args.get('semester_id', type=int)

        query = Planungsphase.query
        if semester_id:
            query = query.filter_by(semester_id=semester_id)

        phases = query.order_by(desc(Planungsphase.created_at)).all()

        # Finde aktive Phase
        active_phase = next((p for p in phases if p.ist_aktiv), None)

        return jsonify({
            'success': True,
            'phasen': [p.to_dict() for p in phases],
            'total': len(phases),
            'aktive_phase': active_phase.to_dict() if active_phase else None
        })

    except Exception as e:
        current_app.logger.error(f"Error getting phases: {e}")
        return jsonify({
            'success': False,
            'message': 'Fehler beim Abrufen der Planungsphasen',
            'error': str(e)
        }), 500


@planungsphase_api.route('/active', methods=['GET'])
@jwt_required()
def get_active_phase():
    """Holt die aktive Planungsphase"""
    try:
        phase = Planungsphase.get_active_phase()
        return jsonify({
            'success': True,
            'phase': phase.to_dict() if phase else None
        })

    except Exception as e:
        current_app.logger.error(f"Error getting active phase: {e}")
        return jsonify({
            'success': False,
            'message': 'Fehler beim Abrufen der aktiven Phase',
            'error': str(e)
        }), 500


@planungsphase_api.route('/<int:phase_id>', methods=['PUT'])
@jwt_required()
@role_required('dekan')
def update_phase(phase_id):
    """Aktualisiert eine Planungsphase"""
    try:
        data = request.get_json()
        phase = Planungsphase.query.get_or_404(phase_id)

        # Update fields
        if 'name' in data:
            phase.name = data['name']

        if 'enddatum' in data:
            if data['enddatum']:
                phase.enddatum = datetime.fromisoformat(data['enddatum'].replace('Z', '+00:00'))
            else:
                phase.enddatum = None

        db.session.commit()

        return jsonify({
            'success': True,
            'phase': phase.to_dict()
        })

    except Exception as e:
        current_app.logger.error(f"Error updating phase: {e}")
        return jsonify({
            'success': False,
            'message': 'Fehler beim Aktualisieren der Planungsphase',
            'error': str(e)
        }), 500


@planungsphase_api.route('/submission-status', methods=['GET'])
@jwt_required()
def check_submission_status():
    """Prüft den Einreichungsstatus"""
    try:
        user_id = get_jwt_identity()
        user = User.query.get(user_id)

        professor_id = request.args.get('professor_id', type=int)

        # 🔍 DEBUGGING: Log all values
        current_app.logger.info(f"[SubmissionStatus] user_id from JWT: {user_id}")
        current_app.logger.info(f"[SubmissionStatus] professor_id from query: {professor_id}")
        current_app.logger.info(f"[SubmissionStatus] user.dozent_id: {user.dozent_id if user else 'NO USER'}")
        current_app.logger.info(f"[SubmissionStatus] user.rolle: {user.rolle.name if user and user.rolle else 'NO ROLE'}")

        # ✅ FIX: professor_id kann entweder user.id ODER user.dozent_id sein
        # Prüfe ob professor_id zum aktuellen User gehört
        is_own_request = (
            professor_id == user_id or
            (user.dozent_id and professor_id == user.dozent_id)
        )

        current_app.logger.info(f"[SubmissionStatus] is_own_request: {is_own_request}")
        current_app.logger.info(f"[SubmissionStatus] Check 1 (professor_id == user_id): {professor_id} == {user_id} = {professor_id == user_id}")
        current_app.logger.info(f"[SubmissionStatus] Check 2 (dozent match): {professor_id} == {user.dozent_id} = {user.dozent_id and professor_id == user.dozent_id}")

        # Nur Dekan kann andere Professoren prüfen
        if professor_id and not is_own_request:
            current_app.logger.warning(f"[SubmissionStatus] Permission denied: professor_id={professor_id}, is_own_request={is_own_request}, user.rolle={user.rolle.name if user and user.rolle else 'NO ROLE'}")
            # Nur Dekan darf andere Professoren prüfen
            if not user.rolle or user.rolle.name != 'dekan':
                return jsonify({'success': False, 'message': 'Nicht autorisiert'}), 403

        # Wenn keine professor_id angegeben wurde, nutze dozent_id des Users (oder user_id als Fallback)
        if not professor_id:
            professor_id = user.dozent_id if user.dozent_id else user_id

        # Hole aktive Phase
        active_phase = Planungsphase.get_active_phase()

        if not active_phase:
            return jsonify({
                'success': True,
                'kann_einreichen': False,
                'grund': 'keine_aktive_phase'
            })

        # Check deadline
        if active_phase.enddatum and datetime.utcnow() > active_phase.enddatum:
            return jsonify({
                'success': True,
                'kann_einreichen': False,
                'grund': 'phase_abgelaufen',
                'aktive_phase': active_phase.to_dict()
            })

        # Check for approved submission
        approved = PhaseSubmission.query.filter_by(
            planungphase_id=active_phase.id,
            professor_id=professor_id,
            status='freigegeben'
        ).first()

        if approved:
            return jsonify({
                'success': True,
                'kann_einreichen': False,
                'grund': 'bereits_genehmigt',
                'aktive_phase': active_phase.to_dict(),
                'letzte_einreichung': approved.to_dict()
            })

        # Calculate remaining time
        verbleibende_zeit = None
        if active_phase.enddatum:
            diff = active_phase.enddatum - datetime.utcnow()
            verbleibende_zeit = int(diff.total_seconds() / 60)  # In minutes

        return jsonify({
            'success': True,
            'kann_einreichen': True,
            'aktive_phase': active_phase.to_dict(),
            'verbleibende_zeit': verbleibende_zeit
        })

    except Exception as e:
        current_app.logger.error(f"Error checking submission status: {e}")
        return jsonify({
            'success': False,
            'message': 'Fehler beim Prüfen des Einreichungsstatus',
            'error': str(e)
        }), 500


@planungsphase_api.route('/record-submission', methods=['POST'])
@jwt_required()
def record_submission():
    """Zeichnet eine Einreichung auf"""
    try:
        data = request.get_json()
        professor_id = get_jwt_identity()

        if not data.get('planung_id'):
            return jsonify({'success': False, 'message': 'Planung ID erforderlich'}), 400

        # Hole aktive Phase
        active_phase = Planungsphase.get_active_phase()
        if not active_phase:
            return jsonify({'success': False, 'message': 'Keine aktive Planungsphase'}), 400

        # Record submission
        submission = PhaseSubmission.record_submission(
            planungphase_id=active_phase.id,
            professor_id=professor_id,
            planung_id=data['planung_id']
        )

        return jsonify({
            'success': True,
            'submission': submission.to_dict()
        }), 201

    except Exception as e:
        current_app.logger.error(f"Error recording submission: {e}")
        return jsonify({
            'success': False,
            'message': 'Fehler beim Aufzeichnen der Einreichung',
            'error': str(e)
        }), 500


@planungsphase_api.route('/<int:phase_id>/submissions', methods=['GET'])
@jwt_required()
@role_required('dekan')
def get_phase_submissions(phase_id):
    """Holt alle Einreichungen einer Phase"""
    try:
        phase = Planungsphase.query.get_or_404(phase_id)

        # Hole existierende Submissions
        submissions = PhaseSubmission.query.filter_by(
            planungphase_id=phase_id
        ).order_by(desc(PhaseSubmission.eingereicht_am)).all()

        # Konvertiere zu Dict mit Fehlerbehandlung
        submission_list = []
        for submission in submissions:
            try:
                submission_list.append(submission.to_dict())
            except Exception as e:
                current_app.logger.warning(f"Could not convert submission to dict: {e}")
                # Füge minimale Info hinzu
                submission_list.append({
                    'id': submission.id,
                    'professor_id': submission.professor_id,
                    'planung_id': submission.planung_id,
                    'status': submission.status,
                    'eingereicht_am': submission.eingereicht_am.isoformat() if submission.eingereicht_am else None
                })

        return jsonify(submission_list)

    except Exception as e:
        current_app.logger.error(f"Error getting submissions: {e}")
        return jsonify({
            'success': False,
            'message': 'Fehler beim Abrufen der Einreichungen',
            'error': str(e)
        }), 500


@planungsphase_api.route('/<int:phase_id>/statistics', methods=['GET'])
@jwt_required()
def get_phase_statistics(phase_id):
    """Holt Statistiken einer Phase"""
    try:
        phase = Planungsphase.query.get_or_404(phase_id)

        # Get actual professor count from database
        from app.models.user import Rolle
        professor_roles = Rolle.query.filter(
            Rolle.name.in_(['professor', 'lehrbeauftragter'])
        ).all()
        professor_role_ids = [r.id for r in professor_roles]

        professoren_gesamt = User.query.filter(
            User.rolle_id.in_(professor_role_ids)
        ).count() if professor_role_ids else 0

        # Einfache Statistiken für neue Phase
        statistics = {
            'professoren_gesamt': professoren_gesamt,
            'professoren_eingereicht': 0,
            'einreichungsquote': 0.0,
            'genehmigungsquote': 0.0,
            'durchschnittliche_bearbeitungszeit': 0.0,
            'top_module': []
        }

        # Versuche erweiterte Statistiken zu holen, falls verfügbar
        try:
            extended_stats = phase.get_statistics()
            if extended_stats:
                statistics.update(extended_stats)
        except Exception as stats_error:
            current_app.logger.warning(f"Could not get extended statistics: {stats_error}")

        return jsonify(statistics)

    except Exception as e:
        current_app.logger.error(f"Error getting statistics: {e}")
        return jsonify({
            'success': False,
            'message': 'Fehler beim Abrufen der Statistiken',
            'error': str(e)
        }), 500


@planungsphase_api.route('/history', methods=['GET'])
@jwt_required()
def get_phase_history():
    """Holt die Phasen-Historie"""
    try:
        user_id = get_jwt_identity()
        user = User.query.get(user_id)

        professor_id = request.args.get('professor_id', type=int)

        # Nur Dekan kann andere Professoren sehen
        if professor_id and professor_id != user_id and (not user.rolle or user.rolle.name != 'dekan'):
            return jsonify({'success': False, 'message': 'Nicht autorisiert'}), 403

        # Wenn Professor, nur eigene Historie
        if (not user.rolle or user.rolle.name != 'dekan') and not professor_id:
            professor_id = user_id

        # Hole alle Phasen
        phases = Planungsphase.query.order_by(desc(Planungsphase.created_at)).all()

        history = []
        for phase in phases:
            entry = {
                'phase': phase.to_dict(),
                'statistik': phase.get_statistics()
            }

            # Füge eigene Einreichung hinzu wenn Professor
            if professor_id:
                submission = PhaseSubmission.query.filter_by(
                    planungphase_id=phase.id,
                    professor_id=professor_id
                ).first()
                if submission:
                    entry['eigene_einreichung'] = submission.to_dict()

            history.append(entry)

        return jsonify({
            'success': True,
            'history': history
        })

    except Exception as e:
        current_app.logger.error(f"Error getting history: {e}")
        return jsonify({
            'success': False,
            'message': 'Fehler beim Abrufen der Historie',
            'error': str(e)
        }), 500


@planungsphase_api.route('/dashboard', methods=['GET'])
@jwt_required()
@role_required('dekan')
def get_phase_dashboard():
    """Holt Dashboard-Daten"""
    try:
        active_phase = Planungsphase.get_active_phase()

        if not active_phase:
            return jsonify({
                'success': True,
                'phase': None,
                'einreichungen_heute': 0,
                'offene_reviews': 0,
                'durchschnittliche_bearbeitungszeit': 0,
                'deadline_warnung': False,
                'professoren_ohne_einreichung': []
            })

        # Hole Submissions
        submissions = PhaseSubmission.query.filter_by(planungphase_id=active_phase.id).all()

        # Berechne heutige Einreichungen
        heute = datetime.utcnow().date()
        einreichungen_heute = len([s for s in submissions if s.eingereicht_am.date() == heute])

        # Offene Reviews
        offene_reviews = len([s for s in submissions if s.status == 'eingereicht'])

        # Deadline-Warnung (innerhalb 3 Tage)
        deadline_warnung = False
        if active_phase.enddatum:
            diff = (active_phase.enddatum - datetime.utcnow()).days
            deadline_warnung = 0 < diff <= 3

        # Professoren ohne Einreichung
        from app.models.user import Rolle
        professor_roles = Rolle.query.filter(
            Rolle.name.in_(['professor', 'lehrbeauftragter'])
        ).all()
        professor_role_ids = [r.id for r in professor_roles]

        all_professors = User.query.filter(
            User.rolle_id.in_(professor_role_ids)
        ).all() if professor_role_ids else []
        submitted_ids = {s.professor_id for s in submissions}
        professoren_ohne_einreichung = [
            {
                'id': p.id,
                'name': f"{p.vorname} {p.nachname}",
                'email': p.email
            }
            for p in all_professors if p.id not in submitted_ids
        ]

        return jsonify({
            'success': True,
            'phase': active_phase.to_dict(),
            'einreichungen_heute': einreichungen_heute,
            'offene_reviews': offene_reviews,
            'durchschnittliche_bearbeitungszeit': active_phase.get_statistics().get('durchschnittliche_bearbeitungszeit', 0),
            'deadline_warnung': deadline_warnung,
            'professoren_ohne_einreichung': professoren_ohne_einreichung
        })

    except Exception as e:
        current_app.logger.error(f"Error getting dashboard: {e}")
        return jsonify({
            'success': False,
            'message': 'Fehler beim Abrufen der Dashboard-Daten',
            'error': str(e)
        }), 500


# ============================================
# ARCHIV API ENDPOINTS
# ============================================

@archiv_api.route('/planungen', methods=['GET'])
@jwt_required()
def get_archived_planungen():
    """Holt archivierte Planungen"""
    try:
        user_id = get_jwt_identity()
        user = User.query.get(user_id)

        # Filter von Query-Parametern
        status = request.args.get('status')

        # Input validation for status parameter
        if status and status not in VALID_STATUS_VALUES:
            return jsonify({
                'success': False,
                'message': f'Ungültiger Status. Erlaubt: {", ".join(VALID_STATUS_VALUES)}'
            }), 400

        filter_dict = {
            'planungphase_id': request.args.get('planungphase_id', type=int),
            'semester_id': request.args.get('semester_id', type=int),
            'status': status,
            'von_datum': request.args.get('von_datum'),
            'bis_datum': request.args.get('bis_datum'),
            'limit': request.args.get('limit', 50, type=int),
            'offset': request.args.get('offset', 0, type=int)
        }

        # Professoren sehen nur ihre eigenen
        if user.rolle in ['Professor', 'Lehrbeauftragter']:
            filter_dict['professor_id'] = user_id

        # Remove None values
        filter_dict = {k: v for k, v in filter_dict.items() if v is not None}

        result = ArchiviertePlanung.get_filtered(filter_dict)

        return jsonify({
            'success': True,
            **result
        })

    except Exception as e:
        current_app.logger.error(f"Error getting archived planungen: {e}")
        return jsonify({
            'success': False,
            'message': 'Fehler beim Abrufen der archivierten Planungen',
            'error': str(e)
        }), 500


@archiv_api.route('/planungen/<int:archiv_id>', methods=['GET'])
@jwt_required()
def get_archived_planung_detail(archiv_id):
    """Holt Details einer archivierten Planung"""
    try:
        user_id = get_jwt_identity()
        user = User.query.get(user_id)

        archived = ArchiviertePlanung.query.get_or_404(archiv_id)

        # Prüfe Berechtigung
        if (not user.rolle or user.rolle.name != 'dekan') and archived.professor_id != user_id:
            return jsonify({'success': False, 'message': 'Nicht autorisiert'}), 403

        return jsonify({
            'success': True,
            'data': archived.to_dict()
        })

    except Exception as e:
        current_app.logger.error(f"Error getting archived detail: {e}")
        return jsonify({
            'success': False,
            'message': 'Fehler beim Abrufen der Archivdetails',
            'error': str(e)
        }), 500


@archiv_api.route('/planungen/<int:archiv_id>/restore', methods=['POST'])
@jwt_required()
@role_required('Dekan')
def restore_archived_planung(archiv_id):
    """Stellt eine archivierte Planung wieder her"""
    try:
        user_id = get_jwt_identity()
        archived = ArchiviertePlanung.query.get_or_404(archiv_id)

        # Wiederherstellen
        new_planung = archived.restore(restored_by=user_id)

        return jsonify({
            'success': True,
            'message': 'Planung erfolgreich wiederhergestellt',
            'planung_id': new_planung.id
        })

    except Exception as e:
        current_app.logger.error(f"Error restoring planung: {e}")
        return jsonify({
            'success': False,
            'message': 'Fehler beim Wiederherstellen der Planung',
            'error': str(e)
        }), 500


@archiv_api.route('/statistics', methods=['GET'])
@jwt_required()
def get_archive_statistics():
    """Holt Archiv-Statistiken"""
    try:
        # Basis-Statistiken
        total = ArchiviertePlanung.query.count()
        by_status = db.session.query(
            ArchiviertePlanung.status_bei_archivierung,
            db.func.count(ArchiviertePlanung.id)
        ).group_by(ArchiviertePlanung.status_bei_archivierung).all()

        by_grund = db.session.query(
            ArchiviertePlanung.archiviert_grund,
            db.func.count(ArchiviertePlanung.id)
        ).group_by(ArchiviertePlanung.archiviert_grund).all()

        oldest = db.session.query(db.func.min(ArchiviertePlanung.archiviert_am)).scalar()
        newest = db.session.query(db.func.max(ArchiviertePlanung.archiviert_am)).scalar()

        return jsonify({
            'success': True,
            'data': {
                'total_archived': total,
                'by_status': dict(by_status),
                'by_grund': dict(by_grund),
                'oldest_archive': oldest.isoformat() if oldest else None,
                'newest_archive': newest.isoformat() if newest else None
            }
        })

    except Exception as e:
        current_app.logger.error(f"Error getting archive statistics: {e}")
        return jsonify({
            'success': False,
            'message': 'Fehler beim Abrufen der Archivstatistiken',
            'error': str(e)
        }), 500