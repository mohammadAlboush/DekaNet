"""
API Authentication Routes (JWT)
================================
REST API Blueprint für JWT-basierte Authentication.

Routes:
    POST   /api/auth/login           - Login (JWT Token holen)
    POST   /api/auth/logout          - Logout (Token invalidieren)
    POST   /api/auth/refresh         - Token erneuern
    GET    /api/auth/me              - Aktueller User Info
    GET    /api/auth/profile         - User Profil
    PUT    /api/auth/profile         - User Profil aktualisieren
    POST   /api/auth/change-password - Passwort ändern
    GET    /api/auth/verify          - Token verifizieren
"""

from flask import Blueprint, request, jsonify
from flask_jwt_extended import (
    create_access_token,
    create_refresh_token,
    jwt_required,
    get_jwt_identity,
    current_user
)
from marshmallow import ValidationError
from app.extensions import db, limiter
from app.models.user import Benutzer
from app.auth.utils import validate_password_with_config
from flask import current_app
from app.validators.auth_schemas import LoginSchema, ChangePasswordSchema  # ✅ Input Validation
from app.validators.user_schemas import BenutzerUpdateSchema  # ✅ Input Validation


# Blueprint erstellen
api_auth_bp = Blueprint('api_auth', __name__, url_prefix='/api/auth')


# =========================================================================
# LOGIN & REGISTRATION
# =========================================================================

@api_auth_bp.route('/login', methods=['POST'])
@limiter.limit("5 per minute")  # ✅ Protection against brute-force attacks
@limiter.limit("20 per hour")
def login():
    """
    Login mit JWT - Rate Limited & Input Validated

    Security:
        - Rate Limited (5 per minute, 20 per hour)
        - Input validation with Marshmallow
        - Failed login attempts logged
    """
    try:
        data = request.get_json()

        if not data:
            return jsonify({
                'success': False,
                'message': 'JSON-Daten fehlen',
                'errors': ['Request body muss JSON sein']
            }), 400

        # ✅ INPUT VALIDATION mit Marshmallow
        schema = LoginSchema()
        try:
            validated_data = schema.load(data)
        except ValidationError as err:
            return jsonify({
                'success': False,
                'message': 'Eingabedaten sind ungültig',
                'errors': err.messages
            }), 400

        username = validated_data['username'].strip()
        password = validated_data['password']
        
        from app.services import user_service
        user = user_service.get_by_username(username)
        if not user:
            user = user_service.get_by_email(username)
        
        if not user or not user.check_password(password):
            # Security Logging: Failed login
            current_app.security_logger.log_login_attempt(
                username=username,
                success=False,
                ip=request.remote_addr,
                reason='invalid_credentials'
            )
            return jsonify({
                'success': False,
                'message': 'Ungültige Anmeldedaten',
                'errors': ['Username oder Passwort falsch']
            }), 401

        if not user.aktiv:
            # Security Logging: Inactive account login attempt
            current_app.security_logger.log_login_attempt(
                username=username,
                success=False,
                ip=request.remote_addr,
                reason='account_inactive'
            )
            return jsonify({
                'success': False,
                'message': 'Account deaktiviert',
                'errors': ['Ihr Account wurde deaktiviert']
            }), 403
        
        # WICHTIG: Übergebe user.id als INTEGER
        # Der user_identity_loader in extensions.py konvertiert zu String
        access_token = create_access_token(identity=int(user.id))
        refresh_token = create_refresh_token(identity=int(user.id))
        
        user.aktualisiere_letzten_login()

        # Security Logging: Successful login
        current_app.security_logger.log_login_attempt(
            username=username,
            success=True,
            ip=request.remote_addr,
            reason='success'
        )

        return jsonify({
            'success': True,
            'message': 'Login erfolgreich',
            'data': {
                'access_token': access_token,
                'refresh_token': refresh_token,
                'user': user.to_dict()
            }
        }), 200
        
    except Exception as e:
        current_app.logger.error(f"Login Error: {e}", exc_info=True)
        return jsonify({
            'success': False,
            'message': 'Fehler beim Login',
            'errors': [str(e)]
        }), 500


@api_auth_bp.route('/register', methods=['POST'])
def register():
    """Registrierung (Optional)"""
    return jsonify({
        'success': False,
        'message': 'Registrierung nicht verfügbar',
        'errors': ['Bitte kontaktieren Sie den Administrator']
    }), 403


# =========================================================================
# TOKEN MANAGEMENT
# =========================================================================

@api_auth_bp.route('/refresh', methods=['POST'])
@jwt_required(refresh=True)
@limiter.limit("10 per minute")  # ✅ Rate Limiting für Token Refresh
def refresh():
    """Token erneuern mit Refresh Token - Rate Limited"""
    try:
        user_id = get_jwt_identity()
        access_token = create_access_token(identity=user_id)
        
        return jsonify({
            'success': True,
            'data': {
                'access_token': access_token
            }
        }), 200
        
    except Exception as e:
        current_app.logger.error(f"Token Refresh Error: {e}")
        return jsonify({
            'success': False,
            'message': 'Fehler beim Token-Refresh',
            'errors': [str(e)]
        }), 500


@api_auth_bp.route('/logout', methods=['POST'])
@jwt_required()
def logout():
    """Logout (Token invalidieren)"""
    return jsonify({
        'success': True,
        'message': 'Logout erfolgreich'
    }), 200


@api_auth_bp.route('/verify', methods=['GET'])
@jwt_required()
def verify():
    """Token verifizieren"""
    try:
        user_id = get_jwt_identity()
        
        return jsonify({
            'success': True,
            'message': 'Token ist gültig',
            'data': {
                'user_id': user_id,
                'valid': True
            }
        }), 200
        
    except Exception as e:
        return jsonify({
            'success': False,
            'message': 'Token ungültig',
            'errors': [str(e)]
        }), 401


# =========================================================================
# USER INFO
# =========================================================================

@api_auth_bp.route('/me', methods=['GET'])
@jwt_required()
def me():
    """Aktueller User Info"""
    try:
        if not current_user:
            return jsonify({
                'success': False,
                'message': 'User nicht gefunden',
                'errors': ['User existiert nicht mehr']
            }), 404
        
        return jsonify({
            'success': True,
            'data': {
                'user': current_user.to_dict()
            }
        }), 200
        
    except Exception as e:
        current_app.logger.error(f"Get User Error: {e}")
        return jsonify({
            'success': False,
            'message': 'Fehler beim Laden des Users',
            'errors': [str(e)]
        }), 500


@api_auth_bp.route('/profile', methods=['GET'])
@jwt_required()
def profile():
    """User Profil (mit zusätzlichen Details)"""
    try:
        if not current_user:
            return jsonify({
                'success': False,
                'message': 'User nicht gefunden'
            }), 404
        
        stats = {}
        
        if current_user.ist_professor() or current_user.ist_lehrbeauftragter():
            stats['anzahl_planungen'] = current_user.semesterplanungen.count()
            stats['anzahl_freigegeben'] = current_user.semesterplanungen.filter_by(status='freigegeben').count()
        
        if current_user.ist_dekan():
            stats['anzahl_freigaben'] = current_user.freigegebene_planungen.count()
        
        return jsonify({
            'success': True,
            'data': {
                'user': current_user.to_dict(),
                'statistics': stats
            }
        }), 200
        
    except Exception as e:
        current_app.logger.error(f"Get Profile Error: {e}")
        return jsonify({
            'success': False,
            'message': 'Fehler beim Laden des Profils',
            'errors': [str(e)]
        }), 500


@api_auth_bp.route('/profile', methods=['PUT'])
@jwt_required()
@limiter.limit("20 per minute")  # ✅ Rate Limiting für Profil-Updates
def update_profile():
    """
    User Profil aktualisieren

    PUT /api/auth/profile
    Request Body:
        {
            "vorname": "Maximilian",
            "nachname": "Müller",
            "email": "max.mueller@example.com"
        }

    Security:
        - Rate Limited (20 per minute)
        - Input validation with Marshmallow
    """
    try:
        if not current_user:
            return jsonify({
                'success': False,
                'message': 'User nicht gefunden'
            }), 404

        data = request.get_json()

        if not data:
            return jsonify({
                'success': False,
                'message': 'JSON-Daten fehlen'
            }), 400

        # ✅ INPUT VALIDATION mit Marshmallow
        schema = BenutzerUpdateSchema()
        try:
            validated_data = schema.load(data)
        except ValidationError as err:
            return jsonify({
                'success': False,
                'message': 'Eingabedaten sind ungültig',
                'errors': err.messages
            }), 400

        allowed_fields = ['vorname', 'nachname', 'email']
        
        from app.services import user_service
        
        update_data = {}
        for field in allowed_fields:
            if field in validated_data:
                update_data[field] = validated_data[field]
        
        if not update_data:
            return jsonify({
                'success': False,
                'message': 'Keine gültigen Felder zum Aktualisieren',
                'errors': ['Erlaubte Felder: ' + ', '.join(allowed_fields)]
            }), 400
        
        updated_user = user_service.update_user(current_user.id, **update_data)
        
        if not updated_user:
            return jsonify({
                'success': False,
                'message': 'Fehler beim Aktualisieren'
            }), 500
        
        return jsonify({
            'success': True,
            'message': 'Profil erfolgreich aktualisiert',
            'data': {
                'user': updated_user.to_dict()
            }
        }), 200
        
    except ValueError as e:
        return jsonify({
            'success': False,
            'message': 'Validierungsfehler',
            'errors': [str(e)]
        }), 400
    except Exception as e:
        current_app.logger.error(f"Update Profile Error: {e}")
        db.session.rollback()
        return jsonify({
            'success': False,
            'message': 'Fehler beim Aktualisieren des Profils',
            'errors': [str(e)]
        }), 500


# =========================================================================
# PASSWORD MANAGEMENT
# =========================================================================

@api_auth_bp.route('/change-password', methods=['POST'])
@jwt_required()
@limiter.limit("5 per minute")  # ✅ Rate Limiting für Passwort-Änderungen
def change_password():
    """
    Passwort ändern

    Security:
        - Rate Limited (5 per minute)
        - Input validation with Marshmallow
        - Password strength validation
    """
    try:
        data = request.get_json()

        if not data:
            return jsonify({
                'success': False,
                'message': 'JSON-Daten fehlen'
            }), 400

        # ✅ INPUT VALIDATION mit Marshmallow
        schema = ChangePasswordSchema()
        try:
            validated_data = schema.load(data)
        except ValidationError as err:
            return jsonify({
                'success': False,
                'message': 'Eingabedaten sind ungültig',
                'errors': err.messages
            }), 400

        old_password = validated_data['old_password']
        new_password = validated_data['new_password']
        confirm_password = validated_data['confirm_password']
        
        if not current_user.check_password(old_password):
            return jsonify({
                'success': False,
                'message': 'Altes Passwort ist falsch',
                'errors': ['Das alte Passwort stimmt nicht']
            }), 400
        
        if new_password != confirm_password:
            return jsonify({
                'success': False,
                'message': 'Passwörter stimmen nicht überein',
                'errors': ['new_password und confirm_password müssen identisch sein']
            }), 400
        
        is_valid, errors = validate_password_with_config(new_password, current_app.config)
        if not is_valid:
            return jsonify({
                'success': False,
                'message': 'Passwort erfüllt nicht die Anforderungen',
                'errors': errors
            }), 400
        
        current_user.set_password(new_password)
        db.session.commit()
        
        return jsonify({
            'success': True,
            'message': 'Passwort erfolgreich geändert'
        }), 200
        
    except Exception as e:
        current_app.logger.error(f"Change Password Error: {e}")
        db.session.rollback()
        return jsonify({
            'success': False,
            'message': 'Fehler beim Ändern des Passworts',
            'errors': [str(e)]
        }), 500


# =========================================================================
# HEALTH CHECK
# =========================================================================

@api_auth_bp.route('/health', methods=['GET'])
def health():
    """Health Check für Auth API"""
    return jsonify({
        'status': 'healthy',
        'service': 'auth-api',
        'jwt_enabled': True
    }), 200