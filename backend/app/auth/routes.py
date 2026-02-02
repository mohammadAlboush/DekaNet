"""
Authentication Routes
====================
Blueprint für Login, Logout und User-Management.

Routes:
    - POST /auth/login: Login
    - POST /auth/logout: Logout
    - GET  /auth/me: Aktueller User Info
    - POST /auth/change-password: Passwort ändern
"""

from flask import Blueprint, request, jsonify, session, redirect, url_for, render_template, flash
from flask_login import login_user, logout_user, current_user, login_required
from marshmallow import ValidationError
from app.extensions import db, limiter
from app.models import Benutzer
from app.auth.utils import verify_password, validate_password_with_config, hash_password
from app.auth.decorators import active_user_required
from app.validators.auth_schemas import LoginSchema, ChangePasswordSchema


# Blueprint erstellen
auth_bp = Blueprint('auth', __name__)


# =========================================================================
# WEB ROUTES (Templates)
# =========================================================================

@auth_bp.route('/login', methods=['GET', 'POST'])
@limiter.limit("5 per minute")
@limiter.limit("20 per hour")
def login():
    """
    Login-Seite (Web)

    GET: Zeigt Login-Formular
    POST: Verarbeitet Login

    Security: Rate Limited to prevent brute-force attacks
    """
    # Bereits eingeloggt? Redirect zu Dashboard
    if current_user.is_authenticated:
        return redirect(url_for('dashboard.index'))
    
    if request.method == 'POST':
        # Form-Daten holen
        username = request.form.get('username', '').strip()
        password = request.form.get('password', '')
        remember = request.form.get('remember', False) == 'on'
        
        # Validierung
        if not username or not password:
            flash('Bitte geben Sie Benutzername und Passwort ein.', 'danger')
            return render_template('auth/login.html')
        
        # User suchen
        user = Benutzer.get_by_username(username)
        if not user:
            user = Benutzer.get_by_email(username)  # Auch Email erlauben
        
        # User nicht gefunden oder Passwort falsch
        if not user or not user.check_password(password):
            flash('Ungültiger Benutzername oder Passwort.', 'danger')
            return render_template('auth/login.html')
        
        # User inaktiv?
        if not user.aktiv:
            flash('Ihr Account ist deaktiviert. Bitte wenden Sie sich an den Administrator.', 'danger')
            return render_template('auth/login.html')
        
        # Login erfolgreich!
        login_user(user, remember=remember)
        user.aktualisiere_letzten_login()
        
        flash(f'Willkommen zurück, {user.name_komplett}!', 'success')
        
        # Redirect zu "next" Parameter oder Dashboard
        next_page = request.args.get('next')
        if next_page:
            return redirect(next_page)
        
        # Dashboard basierend auf Rolle
        if user.ist_dekan():
            return redirect(url_for('dashboard.dekan'))
        elif user.ist_professor():
            return redirect(url_for('dashboard.professor'))
        elif user.ist_lehrbeauftragter():
            return redirect(url_for('dashboard.lehrbeauftragter'))
        
        return redirect(url_for('dashboard.index'))
    
    # GET: Zeige Login-Formular
    return render_template('auth/login.html')


@auth_bp.route('/logout')
@login_required
def logout():
    """
    Logout (Web)
    """
    logout_user()
    flash('Sie wurden erfolgreich abgemeldet.', 'info')
    return redirect(url_for('auth.login'))


# =========================================================================
# API ROUTES (JSON)
# =========================================================================

@auth_bp.route('/api/login', methods=['POST'])
@limiter.limit("5 per minute")
@limiter.limit("20 per hour")
def api_login():
    """
    API Login

    POST /auth/api/login

    Request Body:
        {
            "username": "max.mueller",
            "password": "password123",
            "remember": false
        }

    Response:
        {
            "success": true,
            "user": {
                "id": 1,
                "username": "max.mueller",
                "email": "max@example.com",
                "rolle": "professor"
            }
        }

    Security:
        - Rate Limited (5 per minute, 20 per hour)
        - Input validation with Marshmallow
    """
    data = request.get_json()

    if not data:
        return jsonify({
            'error': 'Bad Request',
            'message': 'JSON-Daten fehlen'
        }), 400

    # Input Validation
    schema = LoginSchema()
    try:
        validated_data = schema.load(data)
    except ValidationError as err:
        return jsonify({
            'error': 'Validation Error',
            'message': 'Eingabedaten sind ungültig',
            'errors': err.messages
        }), 400

    # Daten extrahieren (bereits validiert!)
    username = validated_data['username'].strip()
    password = validated_data['password']
    remember = validated_data.get('remember', False)
    
    # User suchen
    user = Benutzer.get_by_username(username)
    if not user:
        user = Benutzer.get_by_email(username)  # Auch Email erlauben
    
    # User nicht gefunden oder Passwort falsch
    if not user or not user.check_password(password):
        return jsonify({
            'error': 'Unauthorized',
            'message': 'Ungültiger Benutzername oder Passwort'
        }), 401
    
    # User inaktiv?
    if not user.aktiv:
        return jsonify({
            'error': 'Forbidden',
            'message': 'Account ist deaktiviert'
        }), 403
    
    # Login erfolgreich!
    login_user(user, remember=remember)
    user.aktualisiere_letzten_login()
    
    return jsonify({
        'success': True,
        'message': 'Login erfolgreich',
        'user': user.to_dict()
    }), 200


@auth_bp.route('/api/logout', methods=['POST'])
@login_required
def api_logout():
    """
    API Logout
    
    POST /auth/api/logout
    
    Response:
        {
            "success": true,
            "message": "Logout erfolgreich"
        }
    """
    logout_user()
    return jsonify({
        'success': True,
        'message': 'Logout erfolgreich'
    }), 200


@auth_bp.route('/api/me', methods=['GET'])
@login_required
def api_me():
    """
    Aktueller User Info (API)
    
    GET /auth/api/me
    
    Response:
        {
            "user": {
                "id": 1,
                "username": "max.mueller",
                "email": "max@example.com",
                "rolle": "professor",
                ...
            }
        }
    """
    return jsonify({
        'user': current_user.to_dict()
    }), 200


@auth_bp.route('/api/change-password', methods=['POST'])
@login_required
@active_user_required
def api_change_password():
    """
    Passwort ändern (API)

    POST /auth/api/change-password

    Request Body:
        {
            "old_password": "old123",
            "new_password": "new123",
            "confirm_password": "new123"
        }

    Response:
        {
            "success": true,
            "message": "Passwort erfolgreich geändert"
        }

    Security:
        - Requires authentication
        - Input validation with Marshmallow
    """
    data = request.get_json()

    if not data:
        return jsonify({
            'error': 'Bad Request',
            'message': 'JSON-Daten fehlen'
        }), 400

    # Input Validation
    schema = ChangePasswordSchema()
    try:
        validated_data = schema.load(data)
    except ValidationError as err:
        return jsonify({
            'error': 'Validation Error',
            'message': 'Eingabedaten sind ungültig',
            'errors': err.messages
        }), 400

    # Daten extrahieren (bereits validiert!)
    old_password = validated_data['old_password']
    new_password = validated_data['new_password']
    confirm_password = validated_data['confirm_password']
    
    # Altes Passwort prüfen
    if not current_user.check_password(old_password):
        return jsonify({
            'error': 'Bad Request',
            'message': 'Altes Passwort ist falsch'
        }), 400
    
    # Neue Passwörter stimmen überein?
    if new_password != confirm_password:
        return jsonify({
            'error': 'Bad Request',
            'message': 'Neue Passwörter stimmen nicht überein'
        }), 400
    
    # Passwort-Stärke prüfen
    from flask import current_app
    is_valid, errors = validate_password_with_config(new_password, current_app.config)
    if not is_valid:
        return jsonify({
            'error': 'Bad Request',
            'message': 'Passwort erfüllt nicht die Anforderungen',
            'errors': errors
        }), 400
    
    # Passwort ändern
    current_user.set_password(new_password)
    db.session.commit()
    
    return jsonify({
        'success': True,
        'message': 'Passwort erfolgreich geändert'
    }), 200


@auth_bp.route('/api/check-session', methods=['GET'])
def api_check_session():
    """
    Prüft ob User eingeloggt ist (API)
    
    GET /auth/api/check-session
    
    Response:
        {
            "authenticated": true,
            "user": {...}
        }
    """
    if current_user.is_authenticated:
        return jsonify({
            'authenticated': True,
            'user': current_user.to_dict()
        }), 200
    
    return jsonify({
        'authenticated': False,
        'user': None
    }), 200


# =========================================================================
# HELPER ROUTES
# =========================================================================

@auth_bp.route('/unauthorized')
def unauthorized():
    """
    Unauthorized Handler (401)
    """
    return render_template('errors/401.html'), 401


@auth_bp.route('/forbidden')
def forbidden():
    """
    Forbidden Handler (403)
    """
    return render_template('errors/403.html'), 403