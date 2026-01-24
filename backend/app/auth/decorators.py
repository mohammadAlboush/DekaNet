"""
Authentication Decorators
=========================
Decorators für Role-Based Access Control (RBAC).

Decorators:
    - @login_required: User muss eingeloggt sein
    - @role_required: User muss bestimmte Rolle haben
    - @dekan_required: Nur für Dekane
    - @professor_required: Nur für Professoren
    - @dozent_required: Für Professoren und Lehrbeauftragte
"""

from functools import wraps
from flask import abort, flash, redirect, url_for, request, jsonify
from flask_login import current_user


def login_required(f):
    """
    Decorator: User muss eingeloggt sein
    
    Usage:
        @app.route('/protected')
        @login_required
        def protected_route():
            return 'Only for logged in users'
    """
    @wraps(f)
    def decorated_function(*args, **kwargs):
        if not current_user.is_authenticated:
            # API Request?
            if request.path.startswith('/api/'):
                return jsonify({
                    'error': 'Unauthorized',
                    'message': 'Authentifizierung erforderlich'
                }), 401
            
            # Web Request
            flash('Bitte melden Sie sich an, um auf diese Seite zuzugreifen.', 'warning')
            return redirect(url_for('auth.login', next=request.url))
        
        return f(*args, **kwargs)
    
    return decorated_function


def role_required(*roles):
    """
    Decorator: User muss eine der angegebenen Rollen haben
    
    Args:
        *roles: Erlaubte Rollen (z.B. 'dekan', 'professor')
    
    Usage:
        @app.route('/dekan-only')
        @role_required('dekan')
        def dekan_route():
            return 'Only for dekans'
        
        @app.route('/teaching-staff')
        @role_required('professor', 'lehrbeauftragter')
        def teaching_route():
            return 'For professors and lecturers'
    """
    def decorator(f):
        @wraps(f)
        def decorated_function(*args, **kwargs):
            # User muss eingeloggt sein
            if not current_user.is_authenticated:
                # API Request?
                if request.path.startswith('/api/'):
                    return jsonify({
                        'error': 'Unauthorized',
                        'message': 'Authentifizierung erforderlich'
                    }), 401
                
                flash('Bitte melden Sie sich an.', 'warning')
                return redirect(url_for('auth.login', next=request.url))
            
            # Rolle prüfen
            if not current_user.rolle:
                # API Request?
                if request.path.startswith('/api/'):
                    return jsonify({
                        'error': 'Forbidden',
                        'message': 'Keine Rolle zugewiesen'
                    }), 403
                
                flash('Ihrem Account ist keine Rolle zugewiesen.', 'danger')
                abort(403)
            
            # ✅ SECURITY: Sichere Methode verwenden
            user_role = current_user.get_rolle_name() if hasattr(current_user, 'get_rolle_name') else current_user.rolle.name

            if user_role not in roles:
                # API Request?
                if request.path.startswith('/api/'):
                    return jsonify({
                        'error': 'Forbidden',
                        'message': f'Zugriff nur für: {", ".join(roles)}'
                    }), 403
                
                flash(f'Zugriff verweigert. Erforderliche Rolle: {", ".join(roles)}', 'danger')
                abort(403)
            
            return f(*args, **kwargs)
        
        return decorated_function
    
    return decorator


def dekan_required(f):
    """
    Decorator: Nur für Dekane
    
    Usage:
        @app.route('/approve-planning')
        @dekan_required
        def approve_planning():
            return 'Only dekans can approve'
    """
    @wraps(f)
    @role_required('dekan')
    def decorated_function(*args, **kwargs):
        return f(*args, **kwargs)
    
    return decorated_function


def professor_required(f):
    """
    Decorator: Nur für Professoren
    
    Usage:
        @app.route('/professor-dashboard')
        @professor_required
        def professor_dashboard():
            return 'Professor dashboard'
    """
    @wraps(f)
    @role_required('professor')
    def decorated_function(*args, **kwargs):
        return f(*args, **kwargs)
    
    return decorated_function


def lehrbeauftragter_required(f):
    """
    Decorator: Nur für Lehrbeauftragte
    
    Usage:
        @app.route('/lecturer-dashboard')
        @lehrbeauftragter_required
        def lecturer_dashboard():
            return 'Lecturer dashboard'
    """
    @wraps(f)
    @role_required('lehrbeauftragter')
    def decorated_function(*args, **kwargs):
        return f(*args, **kwargs)
    
    return decorated_function


def dozent_required(f):
    """
    Decorator: Für Professoren UND Lehrbeauftragte (alle Dozenten)
    
    Usage:
        @app.route('/my-planning')
        @dozent_required
        def my_planning():
            return 'Available for all teaching staff'
    """
    @wraps(f)
    @role_required('professor', 'lehrbeauftragter')
    def decorated_function(*args, **kwargs):
        return f(*args, **kwargs)
    
    return decorated_function


def active_user_required(f):
    """
    Decorator: User muss aktiv sein
    
    Usage:
        @app.route('/some-route')
        @active_user_required
        def some_route():
            return 'Only for active users'
    """
    @wraps(f)
    def decorated_function(*args, **kwargs):
        if not current_user.is_authenticated:
            # API Request?
            if request.path.startswith('/api/'):
                return jsonify({
                    'error': 'Unauthorized',
                    'message': 'Authentifizierung erforderlich'
                }), 401
            
            flash('Bitte melden Sie sich an.', 'warning')
            return redirect(url_for('auth.login', next=request.url))
        
        if not current_user.aktiv:
            # API Request?
            if request.path.startswith('/api/'):
                return jsonify({
                    'error': 'Forbidden',
                    'message': 'Account ist deaktiviert'
                }), 403
            
            flash('Ihr Account ist deaktiviert. Bitte wenden Sie sich an den Administrator.', 'danger')
            abort(403)
        
        return f(*args, **kwargs)
    
    return decorated_function


def owns_resource_or_admin(resource_user_id_func):
    """
    Decorator: User muss Owner der Ressource sein ODER Admin
    
    Args:
        resource_user_id_func: Funktion die User-ID der Ressource zurückgibt
    
    Usage:
        @app.route('/planning/<int:planning_id>')
        @owns_resource_or_admin(lambda planning_id: Semesterplanung.query.get(planning_id).benutzer_id)
        def edit_planning(planning_id):
            return 'Edit planning'
    """
    def decorator(f):
        @wraps(f)
        def decorated_function(*args, **kwargs):
            if not current_user.is_authenticated:
                abort(401)
            
            # Admin/Dekan darf alles
            if current_user.ist_dekan():
                return f(*args, **kwargs)
            
            # User-ID der Ressource holen
            resource_user_id = resource_user_id_func(*args, **kwargs)
            
            # Prüfen ob Owner
            if current_user.id != resource_user_id:
                # API Request?
                if request.path.startswith('/api/'):
                    return jsonify({
                        'error': 'Forbidden',
                        'message': 'Sie sind nicht berechtigt auf diese Ressource zuzugreifen'
                    }), 403
                
                flash('Sie sind nicht berechtigt auf diese Ressource zuzugreifen.', 'danger')
                abort(403)
            
            return f(*args, **kwargs)
        
        return decorated_function
    
    return decorator


# Alias für Flask-Login compatibility
from flask_login import login_required as flask_login_required

__all__ = [
    'login_required',
    'role_required',
    'dekan_required',
    'professor_required',
    'lehrbeauftragter_required',
    'dozent_required',
    'active_user_required',
    'owns_resource_or_admin',
]