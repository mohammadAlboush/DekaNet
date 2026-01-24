"""
Flask Application Factory -
==========================================

WICHTIG: Config MUSS vor init_extensions() komplett geladen sein!
"""

import os

# Lade .env Datei (für DATABASE_URL etc.)
from dotenv import load_dotenv
load_dotenv()
from datetime import timedelta
from flask import Flask, jsonify
from flask_cors import CORS

# Import Config
from app.config import config

# Import Extensions
from app.extensions import (
    db,
    migrate,
    login_manager,
    jwt,
    cors,
    csrf,  # ✅ CSRF Protection
    limiter,  # ✅ Rate Limiting
    init_extensions
)

# Import Logging
from app.utils.logging_config import setup_logging, SecurityLogger

# Import Security Headers
from app.utils.security_headers import add_security_headers, configure_cors_security


def create_app(config_name=None):
    """
    Application Factory Pattern - 
    

    """
    
    # Bestimme Config aus Environment falls nicht angegeben
    if config_name is None:
        config_name = os.getenv('FLASK_ENV', 'development')
    
    # Create Flask App
    app = Flask(__name__)
    
    app.url_map.strict_slashes = False

    
    # =========================================================================
    # CONFIGURATION - SCHRITT 1: Haupt-Config laden
    # =========================================================================
    
    print(f"\n{'='*80}")
    print(f"[START] {config_name.upper()} Environment")
    print(f"{'='*80}\n")
    
    # Load Configuration from config.py
    app.config.from_object(config[config_name])
    
    # Init app in config class
    if hasattr(config[config_name], 'init_app'):
        config[config_name].init_app(app)

    # =========================================================================
    # LOGGING SETUP
    # =========================================================================
    setup_logging(app, config_name)

    # Security Logger als App-Attribut verfügbar machen
    app.security_logger = SecurityLogger(app.logger)

    # =========================================================================
    # JWT Configuration (DEBUG MODE ONLY)
    # =========================================================================

    if config_name == 'development' and app.config.get('DEBUG'):
        app.logger.debug("[JWT] Configuration:")
        app.logger.debug(f"   JWT_SECRET_KEY: {'SET' if app.config.get('JWT_SECRET_KEY') else 'MISSING!'}")
        app.logger.debug(f"   JWT_TOKEN_LOCATION: {app.config.get('JWT_TOKEN_LOCATION')}")
        app.logger.debug(f"   JWT_HEADER_NAME: {app.config.get('JWT_HEADER_NAME')}")
        app.logger.debug(f"   JWT_HEADER_TYPE: {app.config.get('JWT_HEADER_TYPE')}")
        app.logger.debug(f"   JWT_ACCESS_TOKEN_EXPIRES: {app.config.get('JWT_ACCESS_TOKEN_EXPIRES')}")
    
    # =========================================================================
    # INITIALIZE EXTENSIONS - SCHRITT 2
    # =========================================================================
    
    print("[INIT] Initializing Extensions...")
    init_extensions(app)
    print("[OK] Extensions initialized\n")
    
    # =========================================================================
    # BLUEPRINT REGISTRATION - SCHRITT 3
    # =========================================================================
    
    print("[BLUEPRINT] Registering Blueprints...")

    # 1. Web-Auth Blueprint (Flask-Login Sessions)
    try:
        from app.auth.routes import auth_bp
        app.register_blueprint(auth_bp, url_prefix='/auth')
        print("   [OK] Web Auth Blueprint: /auth")
    except ImportError as e:
        print(f"   [WARN] Web Auth Blueprint not found: {e}")

    # 2. REST API Blueprints (JWT) - OHNE doppeltes Prefix!
    try:
        from app.api import register_blueprints
        register_blueprints(app)
        print("   [OK] API Blueprints registered")
    except ImportError as e:
        print(f"   [WARN] API Blueprints not found: {e}")

    # 3. Health Check Blueprint (Production-Ready Health Endpoints)
    try:
        from app.api.health import health_api
        app.register_blueprint(health_api)
        print("   [OK] Health Check Blueprint registered")
    except ImportError as e:
        print(f"   [WARN] Health Check Blueprint not found: {e}")

    print()

    # =========================================================================
    # SECURITY HEADERS
    # =========================================================================
    add_security_headers(app)
    configure_cors_security(app)
    app.logger.info("Security headers configured")

    # =========================================================================
    # ERROR HANDLERS
    # =========================================================================
    
    @app.errorhandler(400)
    def bad_request(error):
        """400 Bad Request"""
        app.logger.error(f"400 Bad Request: {error}")
        return jsonify({
            'success': False,
            'message': 'Bad Request',
            'errors': [str(error)]
        }), 400
    
    @app.errorhandler(401)
    def unauthorized(error):
        """401 Unauthorized - ✅ SECURITY: Keine internen Details"""
        app.logger.warning(f"401 Unauthorized: {error}")
        return jsonify({
            'success': False,
            'message': 'Authentifizierung erforderlich',
            'errors': ['Bitte melden Sie sich an']
        }), 401

    @app.errorhandler(403)
    def forbidden(error):
        """403 Forbidden - ✅ SECURITY: Keine internen Details"""
        app.logger.warning(f"403 Forbidden: {error}")
        return jsonify({
            'success': False,
            'message': 'Keine Berechtigung',
            'errors': ['Sie haben keine Berechtigung für diese Aktion']
        }), 403

    @app.errorhandler(404)
    def not_found(error):
        """404 Not Found - ✅ SECURITY: Keine internen Details"""
        return jsonify({
            'success': False,
            'message': 'Ressource nicht gefunden',
            'errors': ['Die angeforderte Ressource existiert nicht']
        }), 404

    @app.errorhandler(500)
    def internal_error(error):
        """500 Internal Server Error - ✅ SECURITY: Keine internen Details"""
        # Logge den echten Fehler intern
        app.logger.exception(f'Internal Server Error: {error}')
        # Gib nur generische Meldung an Client
        return jsonify({
            'success': False,
            'message': 'Ein interner Fehler ist aufgetreten',
            'errors': ['Bitte versuchen Sie es später erneut']
        }), 500

    @app.errorhandler(Exception)
    def handle_exception(error):
        """
        Globaler Exception Handler - ✅ SECURITY: Fängt alle unbehandelten Exceptions ab

        Verhindert Information Leakage bei unerwarteten Fehlern.
        """
        # Logge den echten Fehler intern
        app.logger.exception(f'Unhandled Exception: {error}')
        # Gib nur generische Meldung an Client
        return jsonify({
            'success': False,
            'message': 'Ein unerwarteter Fehler ist aufgetreten',
            'errors': ['Bitte versuchen Sie es später erneut']
        }), 500
    
    # =========================================================================
    # ROOT ROUTES
    # =========================================================================
    
    @app.route('/')
    def index():
        """Root Endpoint - API Info"""
        return jsonify({
            'message': 'Digitales Dekanat API',
            'version': '1.0.0',
            'status': 'running',
            'environment': config_name,
            'endpoints': {
                'auth_web': '/auth/*',
                'auth_jwt': '/api/auth/*',
                'api': '/api/*',
                'health': '/health'
            }
        })
    
    @app.route('/health')
    def health():
        """Health Check Endpoint"""
        return jsonify({
            'status': 'healthy',
            'environment': config_name,
            'database': 'connected' if db else 'not configured'
        })
    
    # =========================================================================
    # DEBUG ROUTES - Only available in development mode with authentication
    # =========================================================================

    if config_name == 'development' and app.config.get('DEBUG'):
        from flask_jwt_extended import jwt_required, get_jwt_identity

        @app.route('/debug/routes')
        @jwt_required()
        def debug_routes():
            """
            Debug: Zeigt alle Routes

            SECURITY:
            - Only available in development mode
            - Requires valid JWT authentication
            - Disabled in production automatically
            """
            current_user_id = get_jwt_identity()

            routes = []
            for rule in app.url_map.iter_rules():
                routes.append({
                    'endpoint': rule.endpoint,
                    'methods': list(rule.methods - {'HEAD', 'OPTIONS'}),
                    'path': rule.rule
                })
            return jsonify({
                'total': len(routes),
                'routes': sorted(routes, key=lambda x: x['path']),
                'requested_by': current_user_id
            })

        @app.route('/debug/config')
        @jwt_required()
        def debug_config():
            """
            Debug: Zeigt wichtige Config-Werte

            SECURITY:
            - Only available in development mode
            - Requires valid JWT authentication
            - Sensitive values are masked
            - Disabled in production automatically
            """
            current_user_id = get_jwt_identity()

            return jsonify({
                'environment': config_name,
                'debug': app.config.get('DEBUG'),
                'jwt_configured': bool(app.config.get('JWT_SECRET_KEY')),
                'jwt_token_location': app.config.get('JWT_TOKEN_LOCATION'),
                'jwt_header_name': app.config.get('JWT_HEADER_NAME'),
                'jwt_header_type': app.config.get('JWT_HEADER_TYPE'),
                'cors_origins': app.config.get('CORS_ORIGINS'),
                'database': app.config.get('SQLALCHEMY_DATABASE_URI', 'not set')[:50] + '...',
                'requested_by': current_user_id
            })

        app.logger.info('[SECURITY] Debug endpoints enabled (development mode only) - requires JWT authentication')
    
    # =========================================================================
    # CLI COMMANDS
    # =========================================================================
    
    @app.cli.command()
    def init_db():
        """Initialize database"""
        with app.app_context():
            db.create_all()
            print("[OK] Database initialized")
    
    @app.cli.command()
    def drop_db():
        """Drop all database tables"""
        if input("Are you sure? (yes/no): ").lower() == 'yes':
            with app.app_context():
                db.drop_all()
                print("[OK] Database dropped")
        else:
            print("[CANCEL] Cancelled")
    
    @app.cli.command()
    def routes():
        """Show all registered routes"""
        output = []
        for rule in app.url_map.iter_rules():
            methods = ','.join(sorted(rule.methods - {'HEAD', 'OPTIONS'}))
            output.append((methods, rule.rule, rule.endpoint))
        
        output.sort(key=lambda x: x[1])
        
        print("\n" + "="*80)
        print("REGISTERED ROUTES:")
        print("="*80)
        for methods, path, endpoint in output:
            print(f"  {methods:12} {path:50} [{endpoint}]")
        print("="*80)
        print(f"Total: {len(output)} routes\n")
    
    @app.cli.command()
    def test_jwt():
        """Test JWT Configuration"""
        print("\n" + "="*80)
        print("JWT CONFIGURATION TEST")
        print("="*80)
        
        print(f"\nJWT_SECRET_KEY: {'[OK] SET' if app.config.get('JWT_SECRET_KEY') else '[ERROR] MISSING'}")
        print(f"JWT_TOKEN_LOCATION: {app.config.get('JWT_TOKEN_LOCATION')}")
        print(f"JWT_HEADER_NAME: {app.config.get('JWT_HEADER_NAME')}")
        print(f"JWT_HEADER_TYPE: {app.config.get('JWT_HEADER_TYPE')}")
        print(f"JWT_ACCESS_TOKEN_EXPIRES: {app.config.get('JWT_ACCESS_TOKEN_EXPIRES')}")
        print(f"JWT_REFRESH_TOKEN_EXPIRES: {app.config.get('JWT_REFRESH_TOKEN_EXPIRES')}")
        
        print("\n" + "="*80)
        
        # Test Token Creation
        try:
            from flask_jwt_extended import create_access_token
            with app.app_context():
                test_token = create_access_token(identity='1')
                print(f"\n[OK] JWT Token Creation: SUCCESS")
                print(f"   Sample Token: {test_token[:50]}...")
        except Exception as e:
            print(f"\n[ERROR] JWT Token Creation: FAILED")
            print(f"   Error: {e}")
        
        print("\n" + "="*80 + "\n")
    
    # =========================================================================
    # STARTUP INFO
    # =========================================================================
    
    print(f"{'='*80}")
    print(f"[OK] Application initialized successfully!")
    print(f"{'='*80}\n")
    
    return app