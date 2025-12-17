"""
backend/app/api/module.py - ERWEITERT MIT VOLLSTÄNDIGER BEARBEITUNG
====================================================================
Ermöglicht Bearbeitung ALLER Modul-Daten
"""

from flask import Blueprint, request, jsonify, current_app
from flask_jwt_extended import jwt_required, get_jwt_identity, current_user
from app.models import (
    Modul, ModulDozent, ModulLehrform, ModulLiteratur, ModulPruefung,
    ModulLernergebnisse, ModulVoraussetzungen, ModulArbeitsaufwand,
    ModulStudiengang, ModulSprache, ModulAbhaengigkeit,
    Dozent, Lehrform, Studiengang, Sprache
)
from app.extensions import db, cache
from app.utils.cache_utils import invalidate_module_caches
from sqlalchemy.orm import joinedload

# Blueprint Definition
modul_api = Blueprint('module', __name__, url_prefix='/api/module')


@modul_api.before_request
def log_request():
    """Log every request"""
    current_app.logger.info(f"[ModuleAPI] {request.method} {request.path}")


# =========================================================================
# HELPER FUNCTIONS
# =========================================================================

def calculate_sws_robust(modul):
    """Berechnet SWS für ein Modul"""
    try:
        if hasattr(modul, 'get_sws_gesamt'):
            try:
                sws = modul.get_sws_gesamt()
                if sws is not None and sws > 0:
                    return float(sws)
            except:
                pass
        
        if hasattr(modul, 'lehrformen'):
            try:
                lehrformen = modul.lehrformen.all() if hasattr(modul.lehrformen, 'all') else modul.lehrformen
                if lehrformen:
                    sws = sum(lf.sws for lf in lehrformen if hasattr(lf, 'sws'))
                    if sws > 0:
                        return float(sws)
            except:
                pass
        
        return 0.0
    except:
        return 0.0


def modul_to_dict_robust(modul):
    """Konvertiert Modul zu Dict - MIT DOZENTEN UND LEHRFORMEN"""
    try:
        # Lade Dozenten für das Modul
        dozenten_list = []
        try:
            dozenten = ModulDozent.query.filter_by(modul_id=modul.id).all()
            current_app.logger.debug(f"[modul_to_dict] Modul {modul.kuerzel} (ID: {modul.id}) - Found {len(dozenten)} dozent assignments")

            for d in dozenten:
                if d.dozent:
                    name_komplett = d.dozent.name_komplett if hasattr(d.dozent, 'name_komplett') else f"{d.dozent.vorname} {d.dozent.nachname}"
                    name_kurz = d.dozent.name_kurz if hasattr(d.dozent, 'name_kurz') else f"{d.dozent.vorname[0]}. {d.dozent.nachname}"
                    dozent_data = {
                        'id': d.id,
                        'dozent_id': d.dozent_id,
                        'name': name_komplett,  # ✅ Für Anzeige in Tabelle
                        'name_komplett': name_komplett,  # ✅ Konsistent mit TypeScript
                        'name_kurz': name_kurz,  # ✅ Für kompakte Anzeige
                        'vorname': d.dozent.vorname,
                        'nachname': d.dozent.nachname,
                        'rolle': d.rolle
                    }
                    dozenten_list.append(dozent_data)
                    current_app.logger.debug(f"[modul_to_dict]   - Added dozent: {dozent_data}")
                else:
                    current_app.logger.warning(f"[modul_to_dict]   - ModulDozent {d.id} has no dozent reference!")

            if len(dozenten_list) > 0:
                current_app.logger.info(f"[modul_to_dict] ✓ Modul {modul.kuerzel} has {len(dozenten_list)} dozenten assigned")
        except Exception as e:
            current_app.logger.error(f"[modul_to_dict] ✗ Error loading dozenten for modul {modul.id}: {e}")

        # ✅ Lade Lehrformen für das Modul (WICHTIG für SWS-Berechnung!)
        lehrformen_list = []
        try:
            lehrformen = ModulLehrform.query.filter_by(modul_id=modul.id).all()
            for lf in lehrformen:
                if lf.lehrform:
                    lehrformen_list.append({
                        'id': lf.id,
                        'lehrform_id': lf.lehrform_id,
                        'bezeichnung': lf.lehrform.bezeichnung,
                        'kuerzel': lf.lehrform.kuerzel,
                        'sws': float(lf.sws) if lf.sws else 0.0
                    })
        except Exception as e:
            current_app.logger.error(f"[modul_to_dict] Error loading lehrformen for modul {modul.id}: {e}")

        # ✅ Füge po_id hinzu (wichtig für Frontend!)
        po_id = modul.po_id if hasattr(modul, 'po_id') and modul.po_id else 1

        result = {
            'id': modul.id,
            'kuerzel': modul.kuerzel,
            'po_id': po_id,  # ✅ PO-ID hinzugefügt
            'bezeichnung_de': modul.bezeichnung_de,
            'bezeichnung_en': modul.bezeichnung_en,
            'leistungspunkte': modul.leistungspunkte if modul.leistungspunkte else 0,
            'turnus': modul.turnus if modul.turnus else 'Nicht festgelegt',
            'sws_gesamt': calculate_sws_robust(modul),
            'dozenten': dozenten_list,  # ✅ Dozenten hinzugefügt
            'lehrformen': lehrformen_list  # ✅ Lehrformen hinzugefügt (für SWS-Berechnung!)
        }

        return result
    except Exception as e:
        current_app.logger.error(f"[modul_to_dict] ✗ Error converting modul: {e}")
        return None


# =========================================================================
# GET ENDPOINTS (wie vorher)
# =========================================================================

@modul_api.route('/', methods=['GET'])
@jwt_required()
def get_alle_module():
    """GET /api/module/ - Holt alle Module"""
    try:
        user_id = get_jwt_identity()
        current_app.logger.info(f"[ModuleAPI] ========== GET ALL MODULES START ==========")
        current_app.logger.info(f"[ModuleAPI] Request from user: {user_id}")

        if not current_user:
            return jsonify({
                'success': False,
                'message': 'Authentication error'
            }), 401

        # Query Parameters
        page = request.args.get('page', 1, type=int)
        per_page = request.args.get('per_page', 100, type=int)
        po_id = request.args.get('po_id', type=int)
        turnus = request.args.get('turnus')
        search = request.args.get('search', '').strip()

        current_app.logger.info(f"[ModuleAPI] Query params: page={page}, per_page={per_page}, po_id={po_id}, turnus={turnus}, search='{search}'")

        # Query bauen
        try:
            query = Modul.query.options(joinedload(Modul.lehrformen))

            if po_id:
                query = query.filter(Modul.po_id == po_id)
            if turnus:
                query = query.filter(Modul.turnus == turnus)
            if search:
                search_term = f"%{search}%"
                query = query.filter(
                    db.or_(
                        Modul.kuerzel.ilike(search_term),
                        Modul.bezeichnung_de.ilike(search_term),
                        Modul.bezeichnung_en.ilike(search_term)
                    )
                )

            module = query.all()
            current_app.logger.info(f"[ModuleAPI] ✓ Query successful: {len(module)} modules found")
        except Exception as e:
            current_app.logger.error(f"[ModuleAPI] ✗ Query failed: {e}")
            query = Modul.query
            if po_id:
                query = query.filter(Modul.po_id == po_id)
            module = query.all()
            current_app.logger.info(f"[ModuleAPI] ✓ Fallback query: {len(module)} modules found")

        # Konvertiere zu Dict
        items = []
        for m in module:
            modul_dict = modul_to_dict_robust(m)
            if modul_dict:
                items.append(modul_dict)

        # DEBUG: Log first 3 modules with dozenten details
        current_app.logger.info(f"[ModuleAPI] 📊 First 3 modules with dozenten:")
        for i, item in enumerate(items[:3]):
            current_app.logger.info(f"[ModuleAPI] Module {i+1}: {item['kuerzel']}")
            current_app.logger.info(f"[ModuleAPI]   - Dozenten count: {len(item.get('dozenten', []))}")
            current_app.logger.info(f"[ModuleAPI]   - Dozenten: {item.get('dozenten', [])}")

        current_app.logger.info(f"[ModuleAPI] ✅ Returning {len(items)} modules to client")
        current_app.logger.info(f"[ModuleAPI] ========== GET ALL MODULES END ==========")

        return jsonify({
            'success': True,
            'data': items,
            'message': f'{len(items)} Module gefunden'
        }), 200

    except Exception as e:
        current_app.logger.error(f"[ModuleAPI] ❌❌❌ Error: {e}", exc_info=True)
        return jsonify({
            'success': False,
            'message': 'Fehler beim Laden',
            'error': str(e)
        }), 500


@modul_api.route('/search', methods=['GET'])
@jwt_required()
def search_module():
    """GET /api/module/search - Sucht Module"""
    try:
        query_text = request.args.get('q', '').strip()
        po_id = request.args.get('po_id', type=int)
        
        if not query_text:
            return jsonify({
                'success': False,
                'message': 'Suchbegriff erforderlich'
            }), 400
        
        search_term = f"%{query_text}%"
        module_query = Modul.query.filter(
            db.or_(
                Modul.kuerzel.ilike(search_term),
                Modul.bezeichnung_de.ilike(search_term),
                Modul.bezeichnung_en.ilike(search_term)
            )
        )
        
        if po_id:
            module_query = module_query.filter(Modul.po_id == po_id)
        
        module = module_query.all()
        
        items = []
        for m in module:
            modul_dict = modul_to_dict_robust(m)
            if modul_dict:
                items.append(modul_dict)
        
        return jsonify({
            'success': True,
            'data': items,
            'message': f'{len(items)} Modul(e) gefunden'
        }), 200
    
    except Exception as e:
        current_app.logger.error(f"Search error: {e}", exc_info=True)
        return jsonify({
            'success': False,
            'message': 'Fehler bei der Suche',
            'error': str(e)
        }), 500


@modul_api.route('/<int:modul_id>', methods=['GET'])
@jwt_required()
def get_modul(modul_id: int):
    """GET /api/module/<id> - VOLLSTÄNDIGE DETAILS"""
    try:
        user_id = get_jwt_identity()
        current_app.logger.info(f"[ModuleAPI] Get complete details for module {modul_id}")
        
        modul = Modul.query.get(modul_id)
        
        if not modul:
            return jsonify({
                'success': False,
                'message': 'Modul nicht gefunden'
            }), 404
        
        # VOLLSTÄNDIGE DATEN
        details = {
            # Basis-Daten
            'id': modul.id,
            'kuerzel': modul.kuerzel,
            'po_id': modul.po_id,
            'bezeichnung_de': modul.bezeichnung_de,
            'bezeichnung_en': modul.bezeichnung_en,
            'untertitel': modul.untertitel,
            'leistungspunkte': modul.leistungspunkte,
            'turnus': modul.turnus,
            'gruppengroesse': modul.gruppengroesse if hasattr(modul, 'gruppengroesse') else None,
            'teilnehmerzahl': modul.teilnehmerzahl if hasattr(modul, 'teilnehmerzahl') else None,
            'anmeldemodalitaeten': modul.anmeldemodalitaeten if hasattr(modul, 'anmeldemodalitaeten') else None,
            'sws_gesamt': calculate_sws_robust(modul),
            
            # Listen für Detail-Daten
            'lehrformen': [],
            'dozenten': [],
            'studiengaenge': [],
            'literatur': [],
            'sprachen': [],
            'abhaengigkeiten': [],
            'seiten': [],
            'pruefung': None,
            'lernergebnisse': None,
            'voraussetzungen': None,
            'arbeitsaufwand': []
        }
        
        # Lehrformen
        try:
            lehrformen = ModulLehrform.query.filter_by(modul_id=modul_id).all()
            for lf in lehrformen:
                if lf.lehrform:
                    details['lehrformen'].append({
                        'id': lf.id,
                        'lehrform_id': lf.lehrform_id,
                        'bezeichnung': lf.lehrform.bezeichnung,
                        'kuerzel': lf.lehrform.kuerzel,
                        'sws': float(lf.sws) if lf.sws else 0.0
                    })
        except Exception as e:
            current_app.logger.error(f"Error loading lehrformen: {e}")
        
        # Dozenten
        try:
            dozenten = ModulDozent.query.filter_by(modul_id=modul_id).all()
            for d in dozenten:
                if d.dozent:
                    details['dozenten'].append({
                        'id': d.id,
                        'dozent_id': d.dozent_id,
                        'name': d.dozent.name_komplett if hasattr(d.dozent, 'name_komplett') else f"{d.dozent.vorname} {d.dozent.nachname}",
                        'vorname': d.dozent.vorname,
                        'nachname': d.dozent.nachname,
                        'rolle': d.rolle
                    })
        except Exception as e:
            current_app.logger.error(f"Error loading dozenten: {e}")
        
        # Studiengänge
        try:
            studiengaenge = ModulStudiengang.query.filter_by(modul_id=modul_id).all()
            for sg in studiengaenge:
                if sg.studiengang:
                    details['studiengaenge'].append({
                        'id': sg.id,
                        'studiengang_id': sg.studiengang_id,
                        'bezeichnung': sg.studiengang.bezeichnung,
                        'kuerzel': sg.studiengang.kuerzel if hasattr(sg.studiengang, 'kuerzel') else None,
                        'semester': sg.semester,
                        'pflicht': sg.pflicht,
                        'wahlpflicht': sg.wahlpflicht
                    })
        except Exception as e:
            current_app.logger.error(f"Error loading studiengaenge: {e}")
        
        # Literatur
        try:
            literatur = ModulLiteratur.query.filter_by(modul_id=modul_id).order_by(ModulLiteratur.sortierung).all()
            for lit in literatur:
                details['literatur'].append({
                    'id': lit.id,
                    'titel': lit.titel,
                    'autoren': lit.autoren,
                    'verlag': lit.verlag,
                    'jahr': lit.jahr,
                    'isbn': lit.isbn,
                    'typ': lit.typ,
                    'pflichtliteratur': lit.pflichtliteratur,
                    'sortierung': lit.sortierung
                })
        except Exception as e:
            current_app.logger.error(f"Error loading literatur: {e}")
        
        # Sprachen
        try:
            sprachen = ModulSprache.query.filter_by(modul_id=modul_id).all()
            for spr in sprachen:
                if spr.sprache:
                    details['sprachen'].append({
                        'id': spr.sprache_id,
                        'bezeichnung': spr.sprache.bezeichnung if hasattr(spr.sprache, 'bezeichnung') else None
                    })
        except Exception as e:
            current_app.logger.error(f"Error loading sprachen: {e}")
        
        # Prüfung
        try:
            pruefung = ModulPruefung.query.filter_by(modul_id=modul_id).first()
            if pruefung:
                details['pruefung'] = {
                    'pruefungsform': pruefung.pruefungsform,
                    'pruefungsdauer_minuten': pruefung.pruefungsdauer_minuten,
                    'pruefungsleistungen': pruefung.pruefungsleistungen,
                    'benotung': pruefung.benotung
                }
        except Exception as e:
            current_app.logger.error(f"Error loading pruefung: {e}")
        
        # Lernergebnisse
        try:
            lernergebnisse = ModulLernergebnisse.query.filter_by(modul_id=modul_id).first()
            if lernergebnisse:
                details['lernergebnisse'] = {
                    'lernziele': lernergebnisse.lernziele,
                    'kompetenzen': lernergebnisse.kompetenzen,
                    'inhalt': lernergebnisse.inhalt
                }
        except Exception as e:
            current_app.logger.error(f"Error loading lernergebnisse: {e}")
        
        # Voraussetzungen
        try:
            voraussetzungen = ModulVoraussetzungen.query.filter_by(modul_id=modul_id).first()
            if voraussetzungen:
                details['voraussetzungen'] = {
                    'formal': voraussetzungen.formal,
                    'empfohlen': voraussetzungen.empfohlen,
                    'inhaltlich': voraussetzungen.inhaltlich
                }
        except Exception as e:
            current_app.logger.error(f"Error loading voraussetzungen: {e}")
        
        # Arbeitsaufwand
        try:
            arbeitsaufwand = ModulArbeitsaufwand.query.filter_by(modul_id=modul_id).first()
            if arbeitsaufwand:
                details['arbeitsaufwand'] = [{
                    'kontaktzeit_stunden': arbeitsaufwand.kontaktzeit_stunden,
                    'selbststudium_stunden': arbeitsaufwand.selbststudium_stunden,
                    'pruefungsvorbereitung_stunden': arbeitsaufwand.pruefungsvorbereitung_stunden,
                    'gesamt_stunden': arbeitsaufwand.gesamt_stunden
                }]
        except Exception as e:
            current_app.logger.error(f"Error loading arbeitsaufwand: {e}")
        
        # Abhängigkeiten
        try:
            abhaengigkeiten = ModulAbhaengigkeit.query.filter_by(modul_id=modul_id).all()
            for abh in abhaengigkeiten:
                if abh.voraussetzung_modul:
                    details['abhaengigkeiten'].append({
                        'id': abh.id,
                        'voraussetzung_modul_id': abh.voraussetzung_modul_id,
                        'voraussetzung_kuerzel': abh.voraussetzung_modul.kuerzel,
                        'voraussetzung_name': abh.voraussetzung_modul.bezeichnung_de,
                        'typ': abh.typ
                    })
        except Exception as e:
            current_app.logger.error(f"Error loading abhaengigkeiten: {e}")
        
        current_app.logger.info(f"[ModuleAPI] ✓ Complete details loaded for module {modul_id}")
        
        return jsonify({
            'success': True,
            'data': details
        }), 200
    
    except Exception as e:
        current_app.logger.error(f"[ModuleAPI] Error: {e}", exc_info=True)
        return jsonify({
            'success': False,
            'message': 'Fehler beim Laden des Moduls',
            'error': str(e)
        }), 500


# =========================================================================
# CREATE/UPDATE/DELETE HAUPTMODUL
# =========================================================================

@modul_api.route('/', methods=['POST'])
@jwt_required()
def create_modul():
    """POST /api/module/ - Erstellt ein neues Modul"""
    try:
        if current_user.rolle.name != 'dekan':
            return jsonify({
                'success': False,
                'message': 'Keine Berechtigung'
            }), 403
        
        data = request.get_json()
        required_fields = ['kuerzel', 'po_id', 'bezeichnung_de']
        for field in required_fields:
            if field not in data:
                return jsonify({
                    'success': False,
                    'message': f'Pflichtfeld fehlt: {field}'
                }), 400
        
        existing = Modul.query.filter_by(
            kuerzel=data['kuerzel'],
            po_id=data['po_id']
        ).first()
        
        if existing:
            return jsonify({
                'success': False,
                'message': 'Modul existiert bereits'
            }), 400
        
        modul = Modul(
            kuerzel=data['kuerzel'],
            po_id=data['po_id'],
            bezeichnung_de=data['bezeichnung_de'],
            bezeichnung_en=data.get('bezeichnung_en'),
            untertitel=data.get('untertitel'),
            leistungspunkte=data.get('leistungspunkte'),
            turnus=data.get('turnus'),
            gruppengroesse=data.get('gruppengroesse'),
            teilnehmerzahl=data.get('teilnehmerzahl'),
            anmeldemodalitaeten=data.get('anmeldemodalitaeten')
        )
        
        db.session.add(modul)
        db.session.commit()

        # Cache invalidieren nach Modul-Erstellung
        invalidate_module_caches()

        return jsonify({
            'success': True,
            'message': 'Modul erstellt',
            'data': {
                'id': modul.id,
                'kuerzel': modul.kuerzel,
                'bezeichnung_de': modul.bezeichnung_de
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


@modul_api.route('/<int:modul_id>', methods=['PUT'])
@jwt_required()
def update_modul(modul_id: int):
    """PUT /api/module/<id> - BEARBEITET BASIS-FELDER"""
    try:
        if current_user.rolle.name != 'dekan':
            return jsonify({
                'success': False,
                'message': 'Keine Berechtigung'
            }), 403
        
        modul = Modul.query.get(modul_id)
        if not modul:
            return jsonify({
                'success': False,
                'message': 'Modul nicht gefunden'
            }), 404
        
        data = request.get_json()
        
        # Basis-Felder
        updateable_fields = [
            'bezeichnung_de', 'bezeichnung_en', 'untertitel',
            'leistungspunkte', 'turnus', 'gruppengroesse',
            'teilnehmerzahl', 'anmeldemodalitaeten'
        ]
        
        for field in updateable_fields:
            if field in data:
                setattr(modul, field, data[field])
        
        db.session.commit()
        
        return jsonify({
            'success': True,
            'message': 'Modul aktualisiert',
            'data': {
                'id': modul.id,
                'kuerzel': modul.kuerzel,
                'bezeichnung_de': modul.bezeichnung_de
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


@modul_api.route('/<int:modul_id>', methods=['DELETE'])
@jwt_required()
def delete_modul(modul_id: int):
    """DELETE /api/module/<id> - Löscht ein Modul"""
    try:
        if current_user.rolle.name != 'dekan':
            return jsonify({
                'success': False,
                'message': 'Keine Berechtigung'
            }), 403
        
        modul = Modul.query.get(modul_id)
        if not modul:
            return jsonify({
                'success': False,
                'message': 'Modul nicht gefunden'
            }), 404
        
        force = request.args.get('force', 'false').lower() == 'true'
        
        from app.models import GeplanteModule
        verwendungen = GeplanteModule.query.filter_by(modul_id=modul_id).count()
        
        if verwendungen > 0 and not force:
            return jsonify({
                'success': False,
                'message': f'Modul wird in {verwendungen} Planungen verwendet',
                'hint': 'Verwenden Sie ?force=true'
            }), 409
        
        db.session.delete(modul)
        db.session.commit()
        
        return jsonify({
            'success': True,
            'message': 'Modul gelöscht'
        }), 200
        
    except Exception as e:
        db.session.rollback()
        current_app.logger.error(f"Error: {e}")
        return jsonify({
            'success': False,
            'message': 'Fehler beim Löschen',
            'error': str(e)
        }), 500


# =========================================================================
# LEHRFORMEN BEARBEITEN
# =========================================================================

@modul_api.route('/<int:modul_id>/lehrformen', methods=['POST'])
@jwt_required()
def add_lehrform(modul_id: int):
    """POST /api/module/<id>/lehrformen - Fügt Lehrform hinzu"""
    try:
        if current_user.rolle.name != 'dekan':
            return jsonify({'success': False, 'message': 'Keine Berechtigung'}), 403
        
        modul = Modul.query.get(modul_id)
        if not modul:
            return jsonify({'success': False, 'message': 'Modul nicht gefunden'}), 404
        
        data = request.get_json()
        lehrform_id = data.get('lehrform_id')
        sws = data.get('sws', 0)
        
        if not lehrform_id:
            return jsonify({'success': False, 'message': 'lehrform_id erforderlich'}), 400
        
        # Prüfe ob Lehrform existiert
        lehrform = Lehrform.query.get(lehrform_id)
        if not lehrform:
            return jsonify({'success': False, 'message': 'Lehrform nicht gefunden'}), 404
        
        # Prüfe ob bereits vorhanden
        existing = ModulLehrform.query.filter_by(
            modul_id=modul_id,
            lehrform_id=lehrform_id
        ).first()
        
        if existing:
            return jsonify({'success': False, 'message': 'Lehrform bereits zugeordnet'}), 400
        
        modul_lehrform = ModulLehrform(
            modul_id=modul_id,
            po_id=modul.po_id,
            lehrform_id=lehrform_id,
            sws=sws
        )
        
        db.session.add(modul_lehrform)
        db.session.commit()
        
        return jsonify({
            'success': True,
            'message': 'Lehrform hinzugefügt',
            'data': {
                'id': modul_lehrform.id,
                'bezeichnung': lehrform.bezeichnung,
                'sws': sws
            }
        }), 201
        
    except Exception as e:
        db.session.rollback()
        current_app.logger.error(f"Error: {e}")
        return jsonify({'success': False, 'message': str(e)}), 500


@modul_api.route('/<int:modul_id>/lehrformen/<int:lehrform_zuordnung_id>', methods=['PUT'])
@jwt_required()
def update_lehrform(modul_id: int, lehrform_zuordnung_id: int):
    """PUT /api/module/<id>/lehrformen/<id> - Aktualisiert SWS"""
    try:
        if current_user.rolle.name != 'dekan':
            return jsonify({'success': False, 'message': 'Keine Berechtigung'}), 403
        
        lehrform_zuordnung = ModulLehrform.query.get(lehrform_zuordnung_id)
        if not lehrform_zuordnung or lehrform_zuordnung.modul_id != modul_id:
            return jsonify({'success': False, 'message': 'Zuordnung nicht gefunden'}), 404
        
        data = request.get_json()
        if 'sws' in data:
            lehrform_zuordnung.sws = data['sws']
        
        db.session.commit()
        
        return jsonify({
            'success': True,
            'message': 'SWS aktualisiert'
        }), 200
        
    except Exception as e:
        db.session.rollback()
        return jsonify({'success': False, 'message': str(e)}), 500


@modul_api.route('/<int:modul_id>/lehrformen/<int:lehrform_zuordnung_id>', methods=['DELETE'])
@jwt_required()
def delete_lehrform(modul_id: int, lehrform_zuordnung_id: int):
    """DELETE /api/module/<id>/lehrformen/<id> - Entfernt Lehrform"""
    try:
        if current_user.rolle.name != 'dekan':
            return jsonify({'success': False, 'message': 'Keine Berechtigung'}), 403
        
        lehrform_zuordnung = ModulLehrform.query.get(lehrform_zuordnung_id)
        if not lehrform_zuordnung or lehrform_zuordnung.modul_id != modul_id:
            return jsonify({'success': False, 'message': 'Zuordnung nicht gefunden'}), 404
        
        db.session.delete(lehrform_zuordnung)
        db.session.commit()
        
        return jsonify({'success': True, 'message': 'Lehrform entfernt'}), 200
        
    except Exception as e:
        db.session.rollback()
        return jsonify({'success': False, 'message': str(e)}), 500


# =========================================================================
# DOZENTEN BEARBEITEN
# =========================================================================

@modul_api.route('/<int:modul_id>/dozenten', methods=['POST'])
@jwt_required()
def add_dozent(modul_id: int):
    """POST /api/module/<id>/dozenten - Fügt Dozent hinzu"""
    try:
        if current_user.rolle.name != 'dekan':
            return jsonify({'success': False, 'message': 'Keine Berechtigung'}), 403
        
        modul = Modul.query.get(modul_id)
        if not modul:
            return jsonify({'success': False, 'message': 'Modul nicht gefunden'}), 404
        
        data = request.get_json()
        dozent_id = data.get('dozent_id')
        rolle = data.get('rolle', 'lehrperson')
        
        if not dozent_id:
            return jsonify({'success': False, 'message': 'dozent_id erforderlich'}), 400
        
        dozent = Dozent.query.get(dozent_id)
        if not dozent:
            return jsonify({'success': False, 'message': 'Dozent nicht gefunden'}), 404
        
        existing = ModulDozent.query.filter_by(
            modul_id=modul_id,
            dozent_id=dozent_id
        ).first()
        
        if existing:
            return jsonify({'success': False, 'message': 'Dozent bereits zugeordnet'}), 400
        
        modul_dozent = ModulDozent(
            modul_id=modul_id,
            po_id=modul.po_id,
            dozent_id=dozent_id,
            rolle=rolle
        )
        
        db.session.add(modul_dozent)
        db.session.commit()
        
        return jsonify({
            'success': True,
            'message': 'Dozent hinzugefügt',
            'data': {
                'id': modul_dozent.id,
                'name': dozent.name_komplett if hasattr(dozent, 'name_komplett') else f"{dozent.vorname} {dozent.nachname}",
                'rolle': rolle
            }
        }), 201
        
    except Exception as e:
        db.session.rollback()
        return jsonify({'success': False, 'message': str(e)}), 500


@modul_api.route('/<int:modul_id>/dozenten/<int:dozent_zuordnung_id>', methods=['PUT'])
@jwt_required()
def update_dozent(modul_id: int, dozent_zuordnung_id: int):
    """PUT /api/module/<id>/dozenten/<id> - Aktualisiert Rolle"""
    try:
        if current_user.rolle.name != 'dekan':
            return jsonify({'success': False, 'message': 'Keine Berechtigung'}), 403
        
        dozent_zuordnung = ModulDozent.query.get(dozent_zuordnung_id)
        if not dozent_zuordnung or dozent_zuordnung.modul_id != modul_id:
            return jsonify({'success': False, 'message': 'Zuordnung nicht gefunden'}), 404
        
        data = request.get_json()
        if 'rolle' in data:
            dozent_zuordnung.rolle = data['rolle']
        
        db.session.commit()
        
        return jsonify({'success': True, 'message': 'Rolle aktualisiert'}), 200
        
    except Exception as e:
        db.session.rollback()
        return jsonify({'success': False, 'message': str(e)}), 500


@modul_api.route('/<int:modul_id>/dozenten/<int:dozent_zuordnung_id>', methods=['DELETE'])
@jwt_required()
def delete_dozent(modul_id: int, dozent_zuordnung_id: int):
    """DELETE /api/module/<id>/dozenten/<id> - Entfernt Dozent"""
    try:
        if current_user.rolle.name != 'dekan':
            return jsonify({'success': False, 'message': 'Keine Berechtigung'}), 403

        dozent_zuordnung = ModulDozent.query.get(dozent_zuordnung_id)
        if not dozent_zuordnung or dozent_zuordnung.modul_id != modul_id:
            return jsonify({'success': False, 'message': 'Zuordnung nicht gefunden'}), 404

        db.session.delete(dozent_zuordnung)
        db.session.commit()

        return jsonify({'success': True, 'message': 'Dozent entfernt'}), 200

    except Exception as e:
        db.session.rollback()
        return jsonify({'success': False, 'message': str(e)}), 500


@modul_api.route('/<int:modul_id>/dozenten/<int:dozent_zuordnung_id>/replace', methods=['PUT'])
@jwt_required()
def replace_dozent(modul_id: int, dozent_zuordnung_id: int):
    """PUT /api/module/<id>/dozenten/<id>/replace - Ersetzt Dozent (behält Rolle)"""
    try:
        if current_user.rolle.name != 'dekan':
            return jsonify({'success': False, 'message': 'Keine Berechtigung'}), 403

        dozent_zuordnung = ModulDozent.query.get(dozent_zuordnung_id)
        if not dozent_zuordnung or dozent_zuordnung.modul_id != modul_id:
            return jsonify({'success': False, 'message': 'Zuordnung nicht gefunden'}), 404

        data = request.get_json()
        neuer_dozent_id = data.get('neuer_dozent_id')

        if not neuer_dozent_id:
            return jsonify({'success': False, 'message': 'Neuer Dozent-ID erforderlich'}), 400

        # Prüfe ob neuer Dozent existiert
        from app.models.dozent import Dozent
        neuer_dozent = Dozent.query.get(neuer_dozent_id)
        if not neuer_dozent:
            return jsonify({'success': False, 'message': 'Neuer Dozent nicht gefunden'}), 404

        # Behalte die aktuelle Rolle
        alte_rolle = dozent_zuordnung.rolle

        # Aktualisiere den Dozenten
        dozent_zuordnung.dozent_id = neuer_dozent_id

        db.session.commit()

        return jsonify({
            'success': True,
            'message': f'Dozent ersetzt. Rolle "{alte_rolle}" wurde beibehalten.'
        }), 200

    except Exception as e:
        db.session.rollback()
        return jsonify({'success': False, 'message': str(e)}), 500


# =========================================================================
# LITERATUR BEARBEITEN
# =========================================================================

@modul_api.route('/<int:modul_id>/literatur', methods=['POST'])
@jwt_required()
def add_literatur(modul_id: int):
    """POST /api/module/<id>/literatur - Fügt Literatur hinzu"""
    try:
        if current_user.rolle.name != 'dekan':
            return jsonify({'success': False, 'message': 'Keine Berechtigung'}), 403
        
        modul = Modul.query.get(modul_id)
        if not modul:
            return jsonify({'success': False, 'message': 'Modul nicht gefunden'}), 404
        
        data = request.get_json()
        titel = data.get('titel')
        
        if not titel:
            return jsonify({'success': False, 'message': 'Titel erforderlich'}), 400
        
        literatur = ModulLiteratur(
            modul_id=modul_id,
            po_id=modul.po_id,
            titel=titel,
            autoren=data.get('autoren'),
            verlag=data.get('verlag'),
            jahr=data.get('jahr'),
            isbn=data.get('isbn'),
            typ=data.get('typ'),
            pflichtliteratur=data.get('pflichtliteratur', False),
            sortierung=data.get('sortierung')
        )
        
        db.session.add(literatur)
        db.session.commit()
        
        return jsonify({
            'success': True,
            'message': 'Literatur hinzugefügt',
            'data': {'id': literatur.id}
        }), 201
        
    except Exception as e:
        db.session.rollback()
        return jsonify({'success': False, 'message': str(e)}), 500


@modul_api.route('/<int:modul_id>/literatur/<int:literatur_id>', methods=['PUT'])
@jwt_required()
def update_literatur(modul_id: int, literatur_id: int):
    """PUT /api/module/<id>/literatur/<id> - Aktualisiert Literatur"""
    try:
        if current_user.rolle.name != 'dekan':
            return jsonify({'success': False, 'message': 'Keine Berechtigung'}), 403
        
        literatur = ModulLiteratur.query.get(literatur_id)
        if not literatur or literatur.modul_id != modul_id:
            return jsonify({'success': False, 'message': 'Literatur nicht gefunden'}), 404
        
        data = request.get_json()
        updateable_fields = ['titel', 'autoren', 'verlag', 'jahr', 'isbn', 'typ', 'pflichtliteratur', 'sortierung']
        
        for field in updateable_fields:
            if field in data:
                setattr(literatur, field, data[field])
        
        db.session.commit()
        
        return jsonify({'success': True, 'message': 'Literatur aktualisiert'}), 200
        
    except Exception as e:
        db.session.rollback()
        return jsonify({'success': False, 'message': str(e)}), 500


@modul_api.route('/<int:modul_id>/literatur/<int:literatur_id>', methods=['DELETE'])
@jwt_required()
def delete_literatur(modul_id: int, literatur_id: int):
    """DELETE /api/module/<id>/literatur/<id> - Entfernt Literatur"""
    try:
        if current_user.rolle.name != 'dekan':
            return jsonify({'success': False, 'message': 'Keine Berechtigung'}), 403
        
        literatur = ModulLiteratur.query.get(literatur_id)
        if not literatur or literatur.modul_id != modul_id:
            return jsonify({'success': False, 'message': 'Literatur nicht gefunden'}), 404
        
        db.session.delete(literatur)
        db.session.commit()
        
        return jsonify({'success': True, 'message': 'Literatur entfernt'}), 200
        
    except Exception as e:
        db.session.rollback()
        return jsonify({'success': False, 'message': str(e)}), 500


# =========================================================================
# PRÜFUNG BEARBEITEN
# =========================================================================

@modul_api.route('/<int:modul_id>/pruefung', methods=['PUT'])
@jwt_required()
def update_pruefung(modul_id: int):
    """PUT /api/module/<id>/pruefung - Aktualisiert Prüfungsdaten"""
    try:
        if current_user.rolle.name != 'dekan':
            return jsonify({'success': False, 'message': 'Keine Berechtigung'}), 403
        
        modul = Modul.query.get(modul_id)
        if not modul:
            return jsonify({'success': False, 'message': 'Modul nicht gefunden'}), 404
        
        data = request.get_json()
        
        pruefung = ModulPruefung.query.filter_by(modul_id=modul_id).first()
        
        if not pruefung:
            pruefung = ModulPruefung(
                modul_id=modul_id,
                po_id=modul.po_id
            )
            db.session.add(pruefung)
        
        updateable_fields = ['pruefungsform', 'pruefungsdauer_minuten', 'pruefungsleistungen', 'benotung']
        
        for field in updateable_fields:
            if field in data:
                setattr(pruefung, field, data[field])
        
        db.session.commit()
        
        return jsonify({'success': True, 'message': 'Prüfung aktualisiert'}), 200
        
    except Exception as e:
        db.session.rollback()
        return jsonify({'success': False, 'message': str(e)}), 500


# =========================================================================
# LERNERGEBNISSE BEARBEITEN
# =========================================================================

@modul_api.route('/<int:modul_id>/lernergebnisse', methods=['PUT'])
@jwt_required()
def update_lernergebnisse(modul_id: int):
    """PUT /api/module/<id>/lernergebnisse - Aktualisiert Lernergebnisse"""
    try:
        if current_user.rolle.name != 'dekan':
            return jsonify({'success': False, 'message': 'Keine Berechtigung'}), 403
        
        modul = Modul.query.get(modul_id)
        if not modul:
            return jsonify({'success': False, 'message': 'Modul nicht gefunden'}), 404
        
        data = request.get_json()
        
        lernergebnisse = ModulLernergebnisse.query.filter_by(modul_id=modul_id).first()
        
        if not lernergebnisse:
            lernergebnisse = ModulLernergebnisse(
                modul_id=modul_id,
                po_id=modul.po_id
            )
            db.session.add(lernergebnisse)
        
        updateable_fields = ['lernziele', 'kompetenzen', 'inhalt']
        
        for field in updateable_fields:
            if field in data:
                setattr(lernergebnisse, field, data[field])
        
        db.session.commit()
        
        return jsonify({'success': True, 'message': 'Lernergebnisse aktualisiert'}), 200
        
    except Exception as e:
        db.session.rollback()
        return jsonify({'success': False, 'message': str(e)}), 500


# =========================================================================
# VORAUSSETZUNGEN BEARBEITEN
# =========================================================================

@modul_api.route('/<int:modul_id>/voraussetzungen', methods=['PUT'])
@jwt_required()
def update_voraussetzungen(modul_id: int):
    """PUT /api/module/<id>/voraussetzungen - Aktualisiert Voraussetzungen"""
    try:
        if current_user.rolle.name != 'dekan':
            return jsonify({'success': False, 'message': 'Keine Berechtigung'}), 403
        
        modul = Modul.query.get(modul_id)
        if not modul:
            return jsonify({'success': False, 'message': 'Modul nicht gefunden'}), 404
        
        data = request.get_json()
        
        voraussetzungen = ModulVoraussetzungen.query.filter_by(modul_id=modul_id).first()
        
        if not voraussetzungen:
            voraussetzungen = ModulVoraussetzungen(
                modul_id=modul_id,
                po_id=modul.po_id
            )
            db.session.add(voraussetzungen)
        
        updateable_fields = ['formal', 'empfohlen', 'inhaltlich']
        
        for field in updateable_fields:
            if field in data:
                setattr(voraussetzungen, field, data[field])
        
        db.session.commit()
        
        return jsonify({'success': True, 'message': 'Voraussetzungen aktualisiert'}), 200
        
    except Exception as e:
        db.session.rollback()
        return jsonify({'success': False, 'message': str(e)}), 500


# =========================================================================
# ARBEITSAUFWAND BEARBEITEN
# =========================================================================

@modul_api.route('/<int:modul_id>/arbeitsaufwand', methods=['PUT'])
@jwt_required()
def update_arbeitsaufwand(modul_id: int):
    """PUT /api/module/<id>/arbeitsaufwand - Aktualisiert Arbeitsaufwand"""
    try:
        if current_user.rolle.name != 'dekan':
            return jsonify({'success': False, 'message': 'Keine Berechtigung'}), 403
        
        modul = Modul.query.get(modul_id)
        if not modul:
            return jsonify({'success': False, 'message': 'Modul nicht gefunden'}), 404
        
        data = request.get_json()
        
        arbeitsaufwand = ModulArbeitsaufwand.query.filter_by(modul_id=modul_id).first()
        
        if not arbeitsaufwand:
            arbeitsaufwand = ModulArbeitsaufwand(
                modul_id=modul_id,
                po_id=modul.po_id
            )
            db.session.add(arbeitsaufwand)
        
        updateable_fields = ['kontaktzeit_stunden', 'selbststudium_stunden', 'pruefungsvorbereitung_stunden', 'gesamt_stunden']
        
        for field in updateable_fields:
            if field in data:
                setattr(arbeitsaufwand, field, data[field])
        
        db.session.commit()
        
        return jsonify({'success': True, 'message': 'Arbeitsaufwand aktualisiert'}), 200
        
    except Exception as e:
        db.session.rollback()
        return jsonify({'success': False, 'message': str(e)}), 500


# =========================================================================
# FEATURE 1: VERTRETER & ZWEITPRÜFER
# =========================================================================

@modul_api.route('/<int:modul_id>/dozenten/<int:dozent_zuordnung_id>/vertreter', methods=['PUT'])
@jwt_required()
def set_vertreter(modul_id: int, dozent_zuordnung_id: int):
    """PUT /api/module/<id>/dozenten/<id>/vertreter - Setzt Vertreter"""
    try:
        # Nur Modulverantwortlicher kann Vertreter festlegen
        dozent_zuordnung = ModulDozent.query.get(dozent_zuordnung_id)
        if not dozent_zuordnung or dozent_zuordnung.modul_id != modul_id:
            return jsonify({'success': False, 'message': 'Zuordnung nicht gefunden'}), 404

        # Prüfe ob aktueller User Modulverantwortlicher ist
        if dozent_zuordnung.rolle != 'verantwortlicher':
            return jsonify({'success': False, 'message': 'Nur Modulverantwortlicher kann Vertreter festlegen'}), 403

        # Prüfe ob aktueller User = Modulverantwortlicher
        if not current_user.dozent or current_user.dozent.id != dozent_zuordnung.dozent_id:
            if current_user.rolle.name != 'dekan':
                return jsonify({'success': False, 'message': 'Keine Berechtigung'}), 403

        data = request.get_json()
        vertreter_id = data.get('vertreter_id')

        if vertreter_id:
            # Validierung: Vertreter darf nicht = Verantwortlicher sein
            if vertreter_id == dozent_zuordnung.dozent_id:
                return jsonify({'success': False, 'message': 'Vertreter kann nicht der Verantwortliche selbst sein'}), 400

            # Validierung: Vertreter darf nicht = Zweitprüfer sein
            if vertreter_id == dozent_zuordnung.zweitpruefer_id:
                return jsonify({'success': False, 'message': 'Vertreter kann nicht der Zweitprüfer sein'}), 400

            # Prüfe ob Vertreter existiert
            vertreter = Dozent.query.get(vertreter_id)
            if not vertreter:
                return jsonify({'success': False, 'message': 'Vertreter nicht gefunden'}), 404

        dozent_zuordnung.vertreter_id = vertreter_id
        db.session.commit()

        return jsonify({
            'success': True,
            'message': 'Vertreter festgelegt',
            'data': dozent_zuordnung.to_dict()
        }), 200

    except Exception as e:
        db.session.rollback()
        current_app.logger.error(f"Error: {e}", exc_info=True)
        return jsonify({'success': False, 'message': str(e)}), 500


@modul_api.route('/<int:modul_id>/dozenten/<int:dozent_zuordnung_id>/zweitpruefer', methods=['PUT'])
@jwt_required()
def set_zweitpruefer(modul_id: int, dozent_zuordnung_id: int):
    """PUT /api/module/<id>/dozenten/<id>/zweitpruefer - Setzt Zweitprüfer"""
    try:
        # Nur Modulverantwortlicher kann Zweitprüfer festlegen
        dozent_zuordnung = ModulDozent.query.get(dozent_zuordnung_id)
        if not dozent_zuordnung or dozent_zuordnung.modul_id != modul_id:
            return jsonify({'success': False, 'message': 'Zuordnung nicht gefunden'}), 404

        # Prüfe ob aktueller User Modulverantwortlicher ist
        if dozent_zuordnung.rolle != 'verantwortlicher':
            return jsonify({'success': False, 'message': 'Nur Modulverantwortlicher kann Zweitprüfer festlegen'}), 403

        # Prüfe ob aktueller User = Modulverantwortlicher
        if not current_user.dozent or current_user.dozent.id != dozent_zuordnung.dozent_id:
            if current_user.rolle.name != 'dekan':
                return jsonify({'success': False, 'message': 'Keine Berechtigung'}), 403

        data = request.get_json()
        zweitpruefer_id = data.get('zweitpruefer_id')

        if zweitpruefer_id:
            # Validierung: Zweitprüfer darf nicht = Verantwortlicher sein
            if zweitpruefer_id == dozent_zuordnung.dozent_id:
                return jsonify({'success': False, 'message': 'Zweitprüfer kann nicht der Verantwortliche selbst sein'}), 400

            # Validierung: Zweitprüfer darf nicht = Vertreter sein
            if zweitpruefer_id == dozent_zuordnung.vertreter_id:
                return jsonify({'success': False, 'message': 'Zweitprüfer kann nicht der Vertreter sein'}), 400

            # Prüfe ob Zweitprüfer existiert
            zweitpruefer = Dozent.query.get(zweitpruefer_id)
            if not zweitpruefer:
                return jsonify({'success': False, 'message': 'Zweitprüfer nicht gefunden'}), 404

        dozent_zuordnung.zweitpruefer_id = zweitpruefer_id
        db.session.commit()

        return jsonify({
            'success': True,
            'message': 'Zweitprüfer festgelegt',
            'data': dozent_zuordnung.to_dict()
        }), 200

    except Exception as e:
        db.session.rollback()
        current_app.logger.error(f"Error: {e}", exc_info=True)
        return jsonify({'success': False, 'message': str(e)}), 500


# =========================================================================
# HILFSFUNKTIONEN - LISTE ALLER LEHRFORMEN/DOZENTEN/ETC
# =========================================================================

@modul_api.route('/options/lehrformen', methods=['GET'])
@jwt_required()
@cache.cached(timeout=3600)  # 1 Stunde Cache - Lehrformen ändern sich selten
def get_lehrformen_options():
    """GET /api/module/options/lehrformen - Liste aller Lehrformen"""
    try:
        lehrformen = Lehrform.query.order_by(Lehrform.bezeichnung).all()
        return jsonify({
            'success': True,
            'data': [{'id': lf.id, 'bezeichnung': lf.bezeichnung, 'kuerzel': lf.kuerzel} for lf in lehrformen]
        }), 200
    except Exception as e:
        return jsonify({'success': False, 'message': str(e)}), 500


@modul_api.route('/options/dozenten', methods=['GET'])
@jwt_required()
@cache.cached(timeout=1800)  # 30 Minuten Cache - Dozenten ändern sich gelegentlich
def get_dozenten_options():
    """GET /api/module/options/dozenten - Liste aller Dozenten"""
    try:
        dozenten = Dozent.query.order_by(Dozent.nachname, Dozent.vorname).all()
        return jsonify({
            'success': True,
            'data': [{
                'id': d.id,
                'name': d.name_komplett if hasattr(d, 'name_komplett') else f"{d.vorname} {d.nachname}",
                'vorname': d.vorname,
                'nachname': d.nachname
            } for d in dozenten]
        }), 200
    except Exception as e:
        return jsonify({'success': False, 'message': str(e)}), 500


@modul_api.route('/options/studiengaenge', methods=['GET'])
@jwt_required()
@cache.cached(timeout=3600)  # 1 Stunde Cache - Studiengänge ändern sich selten
def get_studiengaenge_options():
    """GET /api/module/options/studiengaenge - Liste aller Studiengänge"""
    try:
        studiengaenge = Studiengang.query.order_by(Studiengang.bezeichnung).all()
        return jsonify({
            'success': True,
            'data': [{
                'id': sg.id,
                'bezeichnung': sg.bezeichnung,
                'kuerzel': sg.kuerzel if hasattr(sg, 'kuerzel') else None
            } for sg in studiengaenge]
        }), 200
    except Exception as e:
        return jsonify({'success': False, 'message': str(e)}), 500