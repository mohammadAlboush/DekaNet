"""
Flask Extensions - 
========================================
Zentraler Ort für alle Flask Extensions mit umfangreichem Logging.

WICHTIG: JWT Config muss VOR init_extensions() in app.config sein!
"""

from flask_sqlalchemy import SQLAlchemy
from flask_migrate import Migrate
from flask_login import LoginManager
from flask_jwt_extended import JWTManager
from flask_cors import CORS
from flask_limiter import Limiter
from flask_limiter.util import get_remote_address
from flask_caching import Cache
from flask_wtf.csrf import CSRFProtect  # ✅ CSRF Protection


# =========================================================================
# DATABASE (SQLAlchemy)
# =========================================================================
db = SQLAlchemy()

# =========================================================================
# DATABASE MIGRATIONS (Flask-Migrate)
# =========================================================================
migrate = Migrate()

# =========================================================================
# AUTHENTICATION (Flask-Login) - Für Web-Sessions
# =========================================================================
login_manager = LoginManager()
login_manager.login_view = 'auth.login'
login_manager.login_message = 'Bitte melden Sie sich an, um auf diese Seite zuzugreifen.'
login_manager.login_message_category = 'info'
login_manager.session_protection = 'strong'

# =========================================================================
# JWT AUTHENTICATION (Flask-JWT-Extended) - Für REST API
# =========================================================================
jwt = JWTManager()

# =========================================================================
# CORS (Cross-Origin Resource Sharing)
# =========================================================================
cors = CORS()

# =========================================================================
# RATE LIMITER (Flask-Limiter) - Protection against brute-force attacks
# =========================================================================
limiter = Limiter(
    key_func=get_remote_address,
    default_limits=["200 per hour"],
    storage_uri="memory://",
)

# =========================================================================
# CACHE (Flask-Caching) - API Response Caching
# =========================================================================
cache = Cache()

# =========================================================================
# CSRF PROTECTION (Flask-WTF) - Protection against CSRF attacks
# =========================================================================
csrf = CSRFProtect()


# =========================================================================
# INITIALIZATION FUNCTION
# =========================================================================
def init_extensions(app):
    """
    Initialisiert alle Extensions mit der Flask App
    
    Args:
        app: Flask Application Instance
    """
    
    # =====================================================================
    # VALIDATION: JWT Config MUSS existieren!
    # =====================================================================
    
    required_jwt_config = [
        'JWT_SECRET_KEY',
        'JWT_TOKEN_LOCATION',
        'JWT_HEADER_NAME',
        'JWT_HEADER_TYPE'
    ]
    
    missing = [key for key in required_jwt_config if key not in app.config]
    
    if missing:
        raise ValueError(
            f"[ERROR] JWT Configuration incomplete! Missing: {', '.join(missing)}\n"
            f"   These must be set in config.py BEFORE init_extensions()!"
        )

    app.logger.info("[JWT] Configuration validated:")
    for key in required_jwt_config:
        value = app.config.get(key)
        if key == 'JWT_SECRET_KEY':
            # Don't log the actual secret
            app.logger.info(f"   {key}: {'*' * 20} (SET)")
        else:
            app.logger.info(f"   {key}: {value}")
    
    # =====================================================================
    # Database
    # =====================================================================
    db.init_app(app)
    app.logger.info('[OK] Database initialized')

    # =====================================================================
    # Migrations
    # =====================================================================
    migrate.init_app(app, db)
    app.logger.info('[OK] Migrations initialized')
    
    # =====================================================================
    # Login Manager (Flask-Login)
    # =====================================================================
    login_manager.init_app(app)
    app.logger.info('[OK] Login Manager initialized')

    # =====================================================================
    # JWT Manager (Flask-JWT-Extended)
    # =====================================================================
    jwt.init_app(app)
    app.logger.info('[OK] JWT Manager initialized')
    
    # =====================================================================
    # USER LOADERS
    # =====================================================================
    
    @login_manager.user_loader
    def load_user(user_id):
        """Flask-Login User Loader"""
        from app.models.user import Benutzer
        return Benutzer.query.get(int(user_id))
    
    @jwt.user_identity_loader
    def user_identity_lookup(user):
        """
        JWT User Identity Loader
        WICHTIG: Muss einen STRING zurückgeben für JWT Subject!
        
        Args:
            user: Benutzer-Objekt ODER User-ID (int)
            
        Returns:
            User ID als STRING (Flask-JWT-Extended requirement)
        """
        # Falls bereits eine ID übergeben wurde
        if isinstance(user, (int, str)):
            user_id = str(user)
            if app.config.get('DEBUG'):
                app.logger.debug(f"[JWT] Identity Loader: {user_id} (from int/str)")
            return user_id

        # Falls User-Objekt übergeben wurde
        if hasattr(user, 'id'):
            user_id = str(user.id)
            if app.config.get('DEBUG'):
                app.logger.debug(f"[JWT] Identity Loader: {user_id} (from User object)")
            return user_id
        
        # Fallback
        try:
            user_id = str(user)
            app.logger.warning(f"[JWT] Identity Loader: {user_id} (fallback)")
            return user_id
        except (TypeError, ValueError) as e:
            app.logger.error(f"[JWT] Invalid user identity: {type(user)} - {user}: {e}")
            return None
    
    @jwt.user_lookup_loader
    def user_lookup_callback(_jwt_header, jwt_data):
        """
        JWT User Lookup Loader
        Lädt User-Objekt aus JWT Token

        Args:
            _jwt_header: JWT Header (unused)
            jwt_data: JWT Payload mit 'sub' (Identity als String)

        Returns:
            Benutzer-Objekt oder None
        """
        from app.models.user import Benutzer
        identity = jwt_data["sub"]  # Kommt als STRING vom JWT

        if app.config.get('DEBUG'):
            app.logger.debug(f"[JWT] User Lookup: identity={identity}")

        try:
            # Konvertiere String zu Integer für DB Query
            user_id = int(identity)
            user = Benutzer.query.filter_by(id=user_id).first()

            if not user:
                app.logger.warning(f"[JWT] User not found for ID: {user_id}")
                return None

            if not user.aktiv:
                app.logger.warning(f"[JWT] User {user_id} is inactive")
                return None

            if app.config.get('DEBUG'):
                app.logger.debug(f"[JWT] User loaded: {user.username} (ID: {user_id})")
            return user

        except (ValueError, TypeError) as e:
            app.logger.error(f"[JWT] Invalid identity in token: {identity} - {e}")
            return None
    
    # =====================================================================
    # JWT ERROR HANDLERS
    # =====================================================================
    
    @jwt.expired_token_loader
    def expired_token_callback(jwt_header, jwt_payload):
        """Token ist abgelaufen"""
        app.logger.warning(f"[JWT] [EXPIRED] Token expired for user: {jwt_payload.get('sub')}")
        return {
            'success': False,
            'message': 'Token ist abgelaufen',
            'errors': ['Token expired']
        }, 401

    @jwt.invalid_token_loader
    def invalid_token_callback(error):
        """Token ist ungültig"""
        app.logger.warning(f"[JWT] [ERROR] Invalid token: {error}")
        return {
            'success': False,
            'message': 'Token ist ungültig',
            'errors': [str(error)]
        }, 401

    @jwt.unauthorized_loader
    def missing_token_callback(error):
        """Kein Token vorhanden"""
        app.logger.warning(f"[JWT] [ERROR] Missing token: {error}")
        return {
            'success': False,
            'message': 'Kein Authorization Token',
            'errors': ['Authorization header is missing or malformed']
        }, 401
    
    @jwt.revoked_token_loader
    def revoked_token_callback(jwt_header, jwt_payload):
        """Token wurde widerrufen"""
        app.logger.warning(f"[JWT] [REVOKED] Token revoked for user: {jwt_payload.get('sub')}")
        return {
            'success': False,
            'message': 'Token wurde widerrufen',
            'errors': ['Token revoked']
        }, 401
    
    # =====================================================================
    # JWT REQUEST LOGGING (DEBUG MODE ONLY)
    # =====================================================================

    # This is automatically handled by Flask-JWT-Extended, but we can add logging
    @app.before_request
    def log_request_info():
        """Log Request Info (only in DEBUG mode)"""
        if app.config.get('DEBUG'):
            from flask import request
            
            # Nur API Requests loggen
            if request.path.startswith('/api/'):
                auth_header = request.headers.get('Authorization', 'MISSING')
                
                # Verkürze Token für Log
                if auth_header.startswith('Bearer '):
                    token_preview = auth_header[:20] + '...' + auth_header[-10:]
                else:
                    token_preview = auth_header
                
                app.logger.debug(f"[Request] {request.method} {request.path}")
                app.logger.debug(f"[Request] Authorization: {token_preview}")
    
    # =====================================================================
    # CORS Configuration
    # =====================================================================
    
    cors.init_app(
        app,
        resources={
            r"/api/*": {
                "origins": app.config.get('CORS_ORIGINS', [
                    'http://localhost:3000',
                    'http://localhost:5173',
                    'http://localhost:5174',
                    'http://127.0.0.1:3000',
                    'http://127.0.0.1:5173',
                    'http://127.0.0.1:5174'
                ]),
                "methods": ["GET", "POST", "PUT", "DELETE", "PATCH", "OPTIONS"],
                "allow_headers": app.config.get('CORS_ALLOW_HEADERS', [
                    "Content-Type",
                    "Authorization",
                    "X-Requested-With",
                    "Accept"
                ]),
                "expose_headers": app.config.get('CORS_EXPOSE_HEADERS', [
                    "Content-Type",
                    "Authorization"
                ]),
                "supports_credentials": app.config.get('CORS_SUPPORTS_CREDENTIALS', True),
                "max_age": app.config.get('CORS_MAX_AGE', 3600)
            }
        }
    )
    app.logger.info('[OK] CORS initialized')
    app.logger.info(f"   Origins: {app.config.get('CORS_ORIGINS')}")

    # =====================================================================
    # Rate Limiter - Protection against brute-force attacks
    # =====================================================================
    limiter.init_app(app)
    app.logger.info('[OK] Rate Limiter initialized')
    app.logger.info(f"   Storage: {limiter._storage_uri}")

    # =====================================================================
    # Cache - API Response Caching
    # =====================================================================
    cache.init_app(app, config={
        'CACHE_TYPE': 'SimpleCache',  # In-Memory Cache
        'CACHE_DEFAULT_TIMEOUT': 300,  # 5 Minuten Default
    })
    app.logger.info('[OK] Cache initialized')
    app.logger.info(f"   Type: SimpleCache (in-memory)")
    app.logger.info(f"   Default Timeout: 300 seconds")

    # =====================================================================
    # CSRF Protection - Protection against CSRF attacks
    # =====================================================================
    csrf.init_app(app)
    app.logger.info('[OK] CSRF Protection initialized')
    app.logger.info(f"   Enabled: True")
    app.logger.info(f"   Token in Headers: X-CSRF-TOKEN")

    # =====================================================================
    # SHELL CONTEXT
    # =====================================================================
    
    @app.shell_context_processor
    def make_shell_context():
        """Macht Models und db im Flask Shell verfügbar"""
        from app.models.user import Benutzer
        from app.models.semester import Semester
        from app.models.planung import Semesterplanung, GeplantesModul, WunschFreierTag
        from app.models.dozent import Dozent
        from app.models.modul import Modul
        from app.models.studiengang import Studiengang, Pruefungsordnung
        
        try:
            from app.models.lehrform import Lehrform
        except ImportError:
            Lehrform = None
            
        try:
            from app.models.sprache import Sprache
        except ImportError:
            Sprache = None
        
        try:
            from app.models.user import Rolle
        except ImportError:
            Rolle = None
        
        context = {
            'db': db,
            'Benutzer': Benutzer,
            'Semester': Semester,
            'Semesterplanung': Semesterplanung,
            'GeplantesModul': GeplantesModul,
            'WunschFreierTag': WunschFreierTag,
            'Dozent': Dozent,
            'Modul': Modul,
            'Studiengang': Studiengang,
            'Pruefungsordnung': Pruefungsordnung,
        }
        
        if Rolle:
            context['Rolle'] = Rolle
        if Lehrform:
            context['Lehrform'] = Lehrform
        if Sprache:
            context['Sprache'] = Sprache
        
        return context
    
    app.logger.info('[OK] All extensions initialized successfully')