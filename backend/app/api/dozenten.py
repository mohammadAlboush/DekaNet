"""
backend/app/api/dozenten.py - VOLLSTÄNDIGE VERSION MIT ALLEN DATEN
===================================================================
Zeigt ALLE Dozenten-Daten aus der Datenbank an und ermöglicht Bearbeitung
"""

from flask import Blueprint, request, jsonify, current_app
from flask_jwt_extended import jwt_required, get_jwt_identity, current_user
from app.models import Dozent, Benutzer, ModulDozent, Modul
from app.extensions import db

# Blueprint Definition
dozenten_api = Blueprint('dozenten', __name__, url_prefix='/api/dozenten')


@dozenten_api.before_request
def log_request():
    """Log every request"""
    current_app.logger.info(f"[DozentenAPI] {request.method} {request.path}")


# =========================================================================
# GET ENDPOINTS
# =========================================================================

@dozenten_api.route('/', methods=['GET'])
@jwt_required()
def get_alle_dozenten():
    """GET /api/dozenten - Holt alle Dozenten"""
    try:
        user_id = get_jwt_identity()
        current_app.logger.info(f"[DozentenAPI] Request from user: {user_id}")
        
        if not current_user:
            return jsonify({
                'success': False,
                'message': 'Authentication error'
            }), 401
        
        # Query parameters
        fachbereich = request.args.get('fachbereich')
        aktiv = request.args.get('aktiv')
        mit_benutzer = request.args.get('mit_benutzer')
        search = request.args.get('search')
        
        # Direkte Datenbankabfrage
        if not search and not fachbereich and mit_benutzer is None:
            if aktiv is not None:
                aktiv_bool = aktiv.lower() == 'true'
            else:
                aktiv_bool = True
            
            dozenten = Dozent.query.filter_by(aktiv=aktiv_bool).all()
            
            if len(dozenten) == 0:
                dozenten = Dozent.query.all()
        else:
            # Mit Filtern
            from app.services import dozent_service
            
            if aktiv is not None:
                aktiv_bool = aktiv.lower() == 'true'
            else:
                aktiv_bool = True
                
            if mit_benutzer is not None:
                mit_benutzer_bool = mit_benutzer.lower() == 'true'
            else:
                mit_benutzer_bool = None
            
            dozenten = dozent_service.filter_dozenten(
                fachbereich=fachbereich,
                aktiv=aktiv_bool,
                mit_benutzer=mit_benutzer_bool,
                suchbegriff=search
            )
        
        # Format response
        items = []
        for dozent in dozenten:
            try:
                dozent_dict = {
                    'id': dozent.id,
                    'titel': dozent.titel,
                    'vorname': dozent.vorname,
                    'nachname': dozent.nachname,
                    'name_komplett': dozent.name_komplett,
                    'email': dozent.email,
                    'fachbereich': dozent.fachbereich,
                    'aktiv': dozent.aktiv,
                    'name_mit_titel': f"{dozent.titel or ''} {dozent.name_komplett}".strip(),
                    'hat_benutzer_account': False,
                    'anzahl_module': 0
                }
                
                try:
                    if hasattr(dozent, 'hat_benutzer_account'):
                        dozent_dict['hat_benutzer_account'] = dozent.hat_benutzer_account
                    if hasattr(dozent, 'anzahl_module'):
                        dozent_dict['anzahl_module'] = dozent.anzahl_module
                except:
                    pass
                
                items.append(dozent_dict)
            except Exception as e:
                current_app.logger.error(f"Error processing dozent {dozent.id}: {e}")
                continue
        
        return jsonify({
            'success': True,
            'data': items,
            'message': f'{len(items)} Dozent(en) gefunden'
        }), 200
        
    except Exception as e:
        current_app.logger.error(f"Error: {e}", exc_info=True)
        return jsonify({
            'success': False,
            'message': 'Fehler beim Laden der Dozenten',
            'error': str(e)
        }), 500


@dozenten_api.route('/search', methods=['GET'])
@jwt_required()
def search_dozenten():
    """GET /api/dozenten/search - Sucht Dozenten"""
    try:
        query = request.args.get('q', '').strip()
        
        if not query:
            return jsonify({
                'success': False,
                'message': 'Suchbegriff erforderlich'
            }), 400
        
        search_term = f"%{query}%"
        dozenten = Dozent.query.filter(
            db.or_(
                Dozent.vorname.ilike(search_term),
                Dozent.nachname.ilike(search_term),
                Dozent.name_komplett.ilike(search_term),
                Dozent.email.ilike(search_term)
            )
        ).all()
        
        items = []
        for dozent in dozenten:
            items.append({
                'id': dozent.id,
                'titel': dozent.titel,
                'vorname': dozent.vorname,
                'nachname': dozent.nachname,
                'name_komplett': dozent.name_komplett,
                'email': dozent.email,
                'fachbereich': dozent.fachbereich,
                'aktiv': dozent.aktiv
            })
        
        return jsonify({
            'success': True,
            'data': items,
            'message': f'{len(items)} Dozent(en) gefunden'
        }), 200
        
    except Exception as e:
        current_app.logger.error(f"Search error: {e}", exc_info=True)
        return jsonify({
            'success': False,
            'message': 'Fehler bei der Suche',
            'error': str(e)
        }), 500


@dozenten_api.route('/<int:dozent_id>', methods=['GET'])
@jwt_required()
def get_dozent(dozent_id: int):
    """
    GET /api/dozenten/<id> - VOLLSTÄNDIGE DETAILS
    Zeigt ALLE Daten aus der Datenbank
    """
    try:
        user_id = get_jwt_identity()
        current_app.logger.info(f"[DozentenAPI] Get complete details for dozent {dozent_id}")
        
        # Lade Dozent
        dozent = Dozent.query.get(dozent_id)
        
        if not dozent:
            return jsonify({
                'success': False,
                'message': 'Dozent nicht gefunden'
            }), 404
        
        # VOLLSTÄNDIGE DATEN
        details = {
            # Basis-Daten
            'id': dozent.id,
            'titel': dozent.titel,
            'vorname': dozent.vorname,
            'nachname': dozent.nachname,
            'name_komplett': dozent.name_komplett,
            'email': dozent.email,
            'fachbereich': dozent.fachbereich,
            'aktiv': dozent.aktiv,
            
            # Zusätzliche Infos
            'name_mit_titel': f"{dozent.titel or ''} {dozent.name_komplett}".strip(),
            
            # Benutzer-Account
            'hat_benutzer_account': False,
            'benutzer': None,
            
            # Module
            'anzahl_module': 0,
            'module': [],
            
            # Timestamps
            'created_at': dozent.created_at.isoformat() if hasattr(dozent, 'created_at') and dozent.created_at else None,
            'updated_at': dozent.updated_at.isoformat() if hasattr(dozent, 'updated_at') and dozent.updated_at else None,
        }
        
        # Benutzer-Account
        try:
            benutzer = Benutzer.query.filter_by(dozent_id=dozent_id).first()
            if benutzer:
                details['hat_benutzer_account'] = True
                details['benutzer'] = {
                    'id': benutzer.id,
                    'username': benutzer.username,
                    'email': benutzer.email,
                    'rolle': benutzer.rolle.name if benutzer.rolle else None,
                    'aktiv': benutzer.aktiv,
                    'letzter_login': benutzer.letzter_login.isoformat() if benutzer.letzter_login else None
                }
        except Exception as e:
            current_app.logger.error(f"Error loading benutzer: {e}")
        
        # Module
        try:
            modul_zuordnungen = ModulDozent.query.filter_by(dozent_id=dozent_id).all()
            
            # Zähle nur eindeutige Module (ein Dozent kann mehrere Rollen im selben Modul haben)
            unique_module_ids = set(zuordnung.modul_id for zuordnung in modul_zuordnungen)
            details['anzahl_module'] = len(unique_module_ids)
            
            current_app.logger.info(f"[DozentenAPI] Found {len(modul_zuordnungen)} module zuordnungen, {len(unique_module_ids)} unique modules")
            
            
            for zuordnung in modul_zuordnungen:
                try:
                    # Lade Modul direkt über modul_id
                    modul = Modul.query.get(zuordnung.modul_id)
                    if modul:
                        details['module'].append({
                            'zuordnung_id': zuordnung.id,
                            'modul_id': modul.id,
                            'kuerzel': modul.kuerzel,
                            'bezeichnung_de': modul.bezeichnung_de,
                            'rolle': zuordnung.rolle,
                            'po_id': modul.po_id if hasattr(modul, 'po_id') else None
                        })
                        current_app.logger.debug(f"  Added module: {modul.kuerzel}")
                except Exception as inner_e:
                    current_app.logger.error(f"Error loading modul {zuordnung.modul_id}: {inner_e}")
                    
            current_app.logger.info(f"[DozentenAPI] ✓ Loaded {len(details['module'])} modules")
        except Exception as e:
            current_app.logger.error(f"Error loading module: {e}", exc_info=True)
        
        current_app.logger.info(f"[DozentenAPI] ✓ Complete details loaded for dozent {dozent_id}")
        
        return jsonify({
            'success': True,
            'data': details
        }), 200
    
    except Exception as e:
        current_app.logger.error(f"[DozentenAPI] Error: {e}", exc_info=True)
        return jsonify({
            'success': False,
            'message': 'Fehler beim Laden des Dozenten',
            'error': str(e)
        }), 500


@dozenten_api.route('/<int:dozent_id>/module', methods=['GET'])
@jwt_required()
def get_dozent_module(dozent_id: int):
    """GET /api/dozenten/<id>/module - Holt Module eines Dozenten"""
    try:
        dozent = Dozent.query.get(dozent_id)
        if not dozent:
            return jsonify({
                'success': False,
                'message': 'Dozent nicht gefunden'
            }), 404
        
        rolle = request.args.get('rolle')
        po_id = request.args.get('po_id', type=int)
        
        query = ModulDozent.query.filter_by(dozent_id=dozent_id)
        
        if rolle:
            query = query.filter_by(rolle=rolle)
        
        zuordnungen = query.all()
        
        items = []
        for zuordnung in zuordnungen:
            modul = Modul.query.get(zuordnung.modul_id)
            if modul:
                if po_id and modul.po_id != po_id:
                    continue
                    
                items.append({
                    'zuordnung_id': zuordnung.id,
                    'modul_id': modul.id,
                    'kuerzel': modul.kuerzel,
                    'bezeichnung_de': modul.bezeichnung_de,
                    'rolle': zuordnung.rolle,
                    'po_id': modul.po_id if hasattr(modul, 'po_id') else None
                })
        
        return jsonify({
            'success': True,
            'data': items,
            'message': f'{len(items)} Modul(e) gefunden'
        }), 200
        
    except Exception as e:
        current_app.logger.error(f"Error: {e}", exc_info=True)
        return jsonify({
            'success': False,
            'message': 'Fehler beim Laden der Module',
            'error': str(e)
        }), 500


# =========================================================================
# POST/PUT/DELETE ENDPOINTS
# =========================================================================

@dozenten_api.route('/', methods=['POST'])
@jwt_required()
def create_dozent():
    """POST /api/dozenten/ - Erstellt einen neuen Dozenten"""
    try:
        if current_user.rolle.name != 'dekan':
            return jsonify({
                'success': False,
                'message': 'Keine Berechtigung'
            }), 403
        
        data = request.get_json()
        
        if 'nachname' not in data:
            return jsonify({
                'success': False,
                'message': 'Pflichtfeld fehlt: nachname'
            }), 400
        
        # Erstelle name_komplett
        name_parts = []
        if data.get('titel'):
            name_parts.append(data['titel'])
        if data.get('vorname'):
            name_parts.append(data['vorname'])
        name_parts.append(data['nachname'])
        name_komplett = ' '.join(name_parts)
        
        # Prüfe ob Dozent bereits existiert
        existing = Dozent.query.filter_by(name_komplett=name_komplett).first()
        if existing:
            return jsonify({
                'success': False,
                'message': 'Dozent mit diesem Namen existiert bereits'
            }), 400
        
        # Erstelle Dozent
        dozent = Dozent(
            titel=data.get('titel'),
            vorname=data.get('vorname'),
            nachname=data['nachname'],
            name_komplett=name_komplett,
            email=data.get('email'),
            fachbereich=data.get('fachbereich'),
            aktiv=data.get('aktiv', True)
        )
        
        db.session.add(dozent)
        db.session.commit()
        
        return jsonify({
            'success': True,
            'message': 'Dozent erfolgreich erstellt',
            'data': {
                'id': dozent.id,
                'name_komplett': dozent.name_komplett,
                'email': dozent.email
            }
        }), 201
        
    except Exception as e:
        db.session.rollback()
        current_app.logger.error(f"Error: {e}")
        return jsonify({
            'success': False,
            'message': 'Fehler beim Erstellen',
            'error': str(e)
        }), 500


@dozenten_api.route('/<int:dozent_id>', methods=['PUT'])
@jwt_required()
def update_dozent(dozent_id: int):
    """PUT /api/dozenten/<id> - BEARBEITET ALLE FELDER"""
    try:
        if current_user.rolle.name != 'dekan':
            return jsonify({
                'success': False,
                'message': 'Keine Berechtigung'
            }), 403
        
        dozent = Dozent.query.get(dozent_id)
        if not dozent:
            return jsonify({
                'success': False,
                'message': 'Dozent nicht gefunden'
            }), 404
        
        data = request.get_json()
        
        # ALLE editierbaren Felder
        updateable_fields = ['titel', 'vorname', 'nachname', 'email', 'fachbereich', 'aktiv']
        
        name_changed = False
        for field in updateable_fields:
            if field in data:
                if field in ['titel', 'vorname', 'nachname']:
                    name_changed = True
                setattr(dozent, field, data[field])
        
        # Wenn Name geändert wurde, aktualisiere name_komplett
        if name_changed:
            name_parts = []
            if dozent.titel:
                name_parts.append(dozent.titel)
            if dozent.vorname:
                name_parts.append(dozent.vorname)
            name_parts.append(dozent.nachname)
            dozent.name_komplett = ' '.join(name_parts)
        
        db.session.commit()
        
        return jsonify({
            'success': True,
            'message': 'Dozent erfolgreich aktualisiert',
            'data': {
                'id': dozent.id,
                'name_komplett': dozent.name_komplett,
                'email': dozent.email
            }
        }), 200
        
    except Exception as e:
        db.session.rollback()
        current_app.logger.error(f"Error: {e}")
        return jsonify({
            'success': False,
            'message': 'Fehler beim Aktualisieren',
            'error': str(e)
        }), 500


@dozenten_api.route('/<int:dozent_id>', methods=['DELETE'])
@jwt_required()
def delete_dozent(dozent_id: int):
    """DELETE /api/dozenten/<id> - Löscht einen Dozenten"""
    try:
        if current_user.rolle.name != 'dekan':
            return jsonify({
                'success': False,
                'message': 'Keine Berechtigung'
            }), 403
        
        dozent = Dozent.query.get(dozent_id)
        if not dozent:
            return jsonify({
                'success': False,
                'message': 'Dozent nicht gefunden'
            }), 404
        
        force = request.args.get('force', 'false').lower() == 'true'
        
        # Prüfe Modulzuordnungen
        zuordnungen = ModulDozent.query.filter_by(dozent_id=dozent_id).count()
        
        if zuordnungen > 0 and not force:
            return jsonify({
                'success': False,
                'message': f'Dozent ist {zuordnungen} Modulen zugeordnet',
                'hint': 'Verwenden Sie ?force=true'
            }), 409
        
        # Prüfe Benutzer-Account
        benutzer = Benutzer.query.filter_by(dozent_id=dozent_id).first()
        if benutzer and not force:
            return jsonify({
                'success': False,
                'message': 'Dozent hat einen Benutzer-Account',
                'hint': 'Verwenden Sie ?force=true'
            }), 409
        
        db.session.delete(dozent)
        db.session.commit()
        
        return jsonify({
            'success': True,
            'message': 'Dozent erfolgreich gelöscht'
        }), 200
        
    except Exception as e:
        db.session.rollback()
        current_app.logger.error(f"Error: {e}")
        return jsonify({
            'success': False,
            'message': 'Fehler beim Löschen',
            'error': str(e)
        }), 500