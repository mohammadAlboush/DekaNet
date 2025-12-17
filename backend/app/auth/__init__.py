"""
Flask Application Factory
=========================
App Factory Pattern fÃ¼r Flask Application.

Usage:
    from app import create_app
    
    app = create_app()  # Development
    app = create_app('production')  # Production
"""

import os
import logging
from flask import Flask, render_template
from app.config import get_config
from app.extensions import init_extensions


def create_app(config_name=None):
    """
    Application Factory
    Erstellt und konfiguriert die Flask Application
    
    Args:
        config_name: Name der Config ('development', 'testing', 'production')
                     Wenn None, wird FLASK_ENV Environment Variable verwendet
    
    Returns:
        Flask: Konfigurierte Flask Application
    """
    # Flask App erstellen
    app = Flask(__name__)
    
    # =========================================================================
    # CONFIGURATION
    # =========================================================================
    config_class = get_config(config_name)
    app.config.from_object(config_class)
    config_class.init_app(app)
    
    # =========================================================================
    # LOGGING
    # =========================================================================
    setup_logging(app)
    
    # =========================================================================
    # EXTENSIONS
    # =========================================================================
    init_extensions(app)
    
    # =========================================================================
    # BLUEPRINTS
    # =========================================================================
    register_blueprints(app)
    
    # =========================================================================
    # ERROR HANDLERS
    # =========================================================================
    register_error_handlers(app)
    
    # =========================================================================
    # TEMPLATE FILTERS
    # =========================================================================
    register_template_filters(app)
    
    # =========================================================================
    # CONTEXT PROCESSORS
    # =========================================================================
    register_context_processors(app)
    
    # Logging
    app.logger.info(f'{app.config["APP_NAME"]} v{app.config["APP_VERSION"]} started')
    app.logger.info(f'Environment: {config_name or os.environ.get("FLASK_ENV", "development")}')
    
    return app


def setup_logging(app):
    """
    Konfiguriert Logging
    
    Args:
        app: Flask Application
    """
    # Log Level aus Config
    log_level = getattr(logging, app.config['LOG_LEVEL'].upper(), logging.INFO)
    
    # File Handler
    if not app.debug and not app.testing:
        file_handler = logging.FileHandler(app.config['LOG_FILE'])
        file_handler.setLevel(log_level)
        file_handler.setFormatter(logging.Formatter(
            '[%(asctime)s] %(levelname)s in %(module)s: %(message)s'
        ))
        app.logger.addHandler(file_handler)
    
    app.logger.setLevel(log_level)


def register_blueprints(app):
    """
    Registriert alle Blueprints
    
    Args:
        app: Flask Application
    """
    # Auth Blueprint
    from app.auth.routes import auth_bp
    app.register_blueprint(auth_bp, url_prefix='/auth')
    
    from app.api.auth import auth_api_bp
    app.register_blueprint(auth_api_bp, url_prefix='/api/auth')
    
    from app.api.semester import semester_api_bp
    app.register_blueprint(semester_api_bp, url_prefix='/api/semester')
    
    from app.api.planung import planung_api_bp
    app.register_blueprint(planung_api_bp, url_prefix='/api/planung')
    
    from app.api.module import modul_api
    app.register_blueprint(modul_api, url_prefix='/api/module')
    
    from app.api.dozenten import dozenten_api_bp
    app.register_blueprint(dozenten_api_bp, url_prefix='/api/dozenten')
    
    from app.api.studiengaenge import studiengaenge_api_bp
    app.register_blueprint(studiengaenge_api_bp, url_prefix='/api/studiengaenge')
    
    from app.api.dashboard import dashboard_api_bp
    app.register_blueprint(dashboard_api_bp, url_prefix='/api/dashboard')
    
    


def register_error_handlers(app):
    """
    Registriert Error Handlers
    
    Args:
        app: Flask Application
    """
    
    @app.errorhandler(404)
    def not_found_error(error):
        """404 Not Found"""
        if app.config['DEBUG']:
            return {'error': 'Not Found', 'message': str(error)}, 404
        return render_template('errors/404.html'), 404
    
    @app.errorhandler(500)
    def internal_error(error):
        """500 Internal Server Error"""
        from app.extensions import db
        db.session.rollback()  # Rollback bei DB-Fehler
        
        app.logger.error(f'Internal Server Error: {error}')
        
        if app.config['DEBUG']:
            return {'error': 'Internal Server Error', 'message': str(error)}, 500
        return render_template('errors/500.html'), 500
    
    @app.errorhandler(403)
    def forbidden_error(error):
        """403 Forbidden"""
        return {'error': 'Forbidden', 'message': 'Sie haben keine Berechtigung fÃ¼r diese Aktion'}, 403
    
    @app.errorhandler(401)
    def unauthorized_error(error):
        """401 Unauthorized"""
        return {'error': 'Unauthorized', 'message': 'Authentifizierung erforderlich'}, 401


def register_template_filters(app):
    """
    Registriert Custom Jinja2 Template Filters
    
    Args:
        app: Flask Application
    """
    from datetime import datetime
    
    @app.template_filter('datetime_format')
    def datetime_format(value, format='%d.%m.%Y %H:%M'):
        """Formatiert datetime fÃ¼r Templates"""
        if value is None:
            return ''
        if isinstance(value, str):
            value = datetime.fromisoformat(value)
        return value.strftime(format)
    
    @app.template_filter('date_format')
    def date_format(value, format='%d.%m.%Y'):
        """Formatiert date fÃ¼r Templates"""
        if value is None:
            return ''
        if isinstance(value, str):
            from datetime import datetime
            value = datetime.fromisoformat(value).date()
        return value.strftime(format)
    
    @app.template_filter('status_badge')
    def status_badge(status):
        """Gibt Bootstrap Badge Klasse fÃ¼r Status zurÃ¼ck"""
        badges = {
            'entwurf': 'secondary',
            'eingereicht': 'info',
            'freigegeben': 'success',
            'abgelehnt': 'danger',
            'aktiv': 'success',
            'inaktiv': 'secondary',
        }
        return badges.get(status.lower(), 'secondary')


def register_context_processors(app):
    """
    Registriert Context Processors fÃ¼r Templates
    
    Args:
        app: Flask Application
    """
    
    @app.context_processor
    def inject_app_info():
        """Macht App-Infos in allen Templates verfÃ¼gbar"""
        return {
            'app_name': app.config['APP_NAME'],
            'app_version': app.config['APP_VERSION'],
        }
    
    @app.context_processor
    def inject_current_year():
        """Macht aktuelles Jahr in Templates verfÃ¼gbar"""
        from datetime import datetime
        return {'current_year': datetime.now().year}