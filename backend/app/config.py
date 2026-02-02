"""
Flask Configuration -
=======================================
Konfiguration für verschiedene Environments mit KOMPLETTER JWT-Config.

WICHTIG: JWT_TOKEN_LOCATION muss VOR init_extensions() gesetzt sein!
"""

import os
import secrets
from datetime import timedelta
from pathlib import Path


# Base Directory
BASE_DIR = Path(__file__).parent.parent


def _generate_dev_secret():
    """Generiert einen zufälligen Secret Key für Development."""
    return secrets.token_hex(32)


class Config:
    """
    Base Configuration
    Gemeinsame Einstellungen für alle Environments
    """
    
    # =========================================================================
    # SECRET KEY (WICHTIG: In Production aus Environment Variable!)
    # =========================================================================
    SECRET_KEY = os.environ.get('SECRET_KEY') or _generate_dev_secret()

    # =========================================================================
    # JWT CONFIGURATION - KRITISCH: MUSS VOR EXTENSION INIT GESETZT SEIN!
    # =========================================================================
    JWT_SECRET_KEY = os.environ.get('JWT_SECRET_KEY') or _generate_dev_secret()
    JWT_ACCESS_TOKEN_EXPIRES = timedelta(hours=1)
    JWT_REFRESH_TOKEN_EXPIRES = timedelta(days=30)

    # JWT Token Location - Cookies für XSS-Schutz
    JWT_TOKEN_LOCATION = ['cookies']
    JWT_HEADER_NAME = 'Authorization'
    JWT_HEADER_TYPE = 'Bearer'

    # JWT Cookie Security
    JWT_COOKIE_SECURE = False  # In Production: True (nur HTTPS)
    JWT_COOKIE_CSRF_PROTECT = True  # CSRF Protection für JWT Cookies
    JWT_COOKIE_SAMESITE = 'Lax'  # CSRF Protection
    JWT_ACCESS_COOKIE_NAME = 'access_token_cookie'
    JWT_REFRESH_COOKIE_NAME = 'refresh_token_cookie'
    JWT_ACCESS_COOKIE_PATH = '/api/'
    JWT_REFRESH_COOKIE_PATH = '/api/auth/refresh'
    JWT_COOKIE_DOMAIN = None  # Automatisch aus Request
    JWT_SESSION_COOKIE = False  # Persistente Cookies (nicht nur Session)

    # JWT Error Messages
    JWT_ERROR_MESSAGE_KEY = 'message'
    
    # =========================================================================
    # DATABASE - PostgreSQL Required (no SQLite fallback)
    # =========================================================================
    SQLALCHEMY_DATABASE_URI = os.environ.get('DATABASE_URL')

    SQLALCHEMY_TRACK_MODIFICATIONS = False
    SQLALCHEMY_ECHO = False
    SQLALCHEMY_RECORD_QUERIES = True
    SQLALCHEMY_ENGINE_OPTIONS = {
        'pool_pre_ping': True,
        'pool_recycle': 3600,
        'pool_size': 20,
        'max_overflow': 40,
        'pool_timeout': 30,
    }
    
    # =========================================================================
    # FLASK-LOGIN & SESSION SECURITY
    # =========================================================================
    PERMANENT_SESSION_LIFETIME = timedelta(hours=2)
    SESSION_COOKIE_SECURE = False  # In Production: True (nur HTTPS)
    SESSION_COOKIE_HTTPONLY = True  # XSS Protection
    SESSION_COOKIE_SAMESITE = 'Lax'  # CSRF Protection

    REMEMBER_COOKIE_DURATION = timedelta(days=7)
    REMEMBER_COOKIE_SECURE = False  # In Production: True (nur HTTPS)
    REMEMBER_COOKIE_HTTPONLY = True  # XSS Protection
    REMEMBER_COOKIE_SAMESITE = 'Lax'  # CSRF Protection
    
    # =========================================================================
    # PAGINATION
    # =========================================================================
    ITEMS_PER_PAGE = 50
    MAX_ITEMS_PER_PAGE = 100
    
    # =========================================================================
    # FILE UPLOADS
    # =========================================================================
    UPLOAD_FOLDER = BASE_DIR / 'uploads'
    MAX_CONTENT_LENGTH = 16 * 1024 * 1024
    ALLOWED_EXTENSIONS = {'pdf', 'docx', 'xlsx'}
    
    # =========================================================================
    # LOGGING
    # =========================================================================
    LOG_LEVEL = os.environ.get('LOG_LEVEL', 'INFO')
    LOG_FILE = BASE_DIR / 'logs' / 'app.log'
    
    # =========================================================================
    # SECURITY
    # =========================================================================
    WTF_CSRF_ENABLED = True
    WTF_CSRF_TIME_LIMIT = None
    
    MIN_PASSWORD_LENGTH = 8
    REQUIRE_PASSWORD_UPPERCASE = True
    REQUIRE_PASSWORD_LOWERCASE = True
    REQUIRE_PASSWORD_DIGIT = True
    REQUIRE_PASSWORD_SPECIAL = False
    
    RATELIMIT_ENABLED = True
    RATELIMIT_STORAGE_URL = "memory://"
    
    # =========================================================================
    # CORS (für API)
    # =========================================================================
    CORS_ORIGINS = [
        'http://localhost:3000',
        'http://localhost:5173',
        'http://localhost:5174',
        'http://127.0.0.1:3000',
        'http://127.0.0.1:5173',
        'http://127.0.0.1:5174'
    ]
    
    # CORS Headers - WICHTIG für JWT!
    CORS_ALLOW_HEADERS = [
        'Content-Type',
        'Authorization',
        'X-Requested-With',
        'Accept'
    ]
    
    CORS_EXPOSE_HEADERS = ['Content-Type', 'Authorization']
    CORS_SUPPORTS_CREDENTIALS = True
    CORS_MAX_AGE = 3600
    
    # =========================================================================
    # APPLICATION
    # =========================================================================
    APP_NAME = 'Digitales Dekanat'
    APP_VERSION = '1.0.0'
    
    @staticmethod
    def init_app(app):
        """
        Initialisierung die nach App-Erstellung ausgeführt wird
        """
        os.makedirs(Config.UPLOAD_FOLDER, exist_ok=True)
        os.makedirs(Config.LOG_FILE.parent, exist_ok=True)


class DevelopmentConfig(Config):
    """Development Configuration"""
    DEBUG = True
    TESTING = False

    SQLALCHEMY_ECHO = True
    LOG_LEVEL = 'DEBUG'

    SESSION_COOKIE_SECURE = False
    REMEMBER_COOKIE_SECURE = False

    # Rate Limiting für Development lockerer
    RATELIMIT_STORAGE_URL = "memory://"
    RATELIMIT_DEFAULT = "1000 per hour"  # Sehr großzügig für Development
    RATELIMIT_HEADERS_ENABLED = True
    
    # CSRF in Development deaktivieren für API Testing
    WTF_CSRF_ENABLED = False


class TestingConfig(Config):
    """Testing Configuration"""
    DEBUG = False
    TESTING = True
    
    SQLALCHEMY_DATABASE_URI = 'sqlite:///:memory:'
    WTF_CSRF_ENABLED = False
    BCRYPT_LOG_ROUNDS = 4
    
    SESSION_COOKIE_SECURE = False
    REMEMBER_COOKIE_SECURE = False


class ProductionConfig(Config):
    """Production Configuration"""
    DEBUG = False
    TESTING = False

    SQLALCHEMY_ECHO = False

    # WICHTIG: Secret Keys aus Environment
    SECRET_KEY = os.environ.get('SECRET_KEY')
    JWT_SECRET_KEY = os.environ.get('JWT_SECRET_KEY')

    LOG_LEVEL = 'WARNING'

    # CSRF deaktivieren fuer JWT-basierte API
    # JWT im Authorization-Header ist bereits CSRF-sicher
    WTF_CSRF_ENABLED = False

    # Security - HTTPS (Aus Environment Variable, Default: False fuer HTTP-Server)
    # Setze SESSION_COOKIE_SECURE=true in .env wenn HTTPS verfuegbar
    SESSION_COOKIE_SECURE = os.environ.get('SESSION_COOKIE_SECURE', 'false').lower() == 'true'
    REMEMBER_COOKIE_SECURE = os.environ.get('SESSION_COOKIE_SECURE', 'false').lower() == 'true'
    JWT_COOKIE_SECURE = os.environ.get('JWT_COOKIE_SECURE', 'false').lower() == 'true'
    PREFERRED_URL_SCHEME = os.environ.get('PREFERRED_URL_SCHEME', 'http')
    
    # CORS stricter
    CORS_ORIGINS = os.environ.get('CORS_ORIGINS', '').split(',')
    if not CORS_ORIGINS or CORS_ORIGINS == ['']:
        CORS_ORIGINS = []
    
    @classmethod
    def init_app(cls, app):
        """Production-spezifische Initialisierung"""
        Config.init_app(app)

        # Validiere SECRET_KEYs - muessen aus Environment kommen
        if not cls.SECRET_KEY:
            raise ValueError(
                "SECRET_KEY muss in Production explizit gesetzt sein!\n"
                "Setze die Environment Variable: export SECRET_KEY='your-secret-key'\n"
                "Generiere einen Key: python -c \"import secrets; print(secrets.token_hex(32))\""
            )

        if not cls.JWT_SECRET_KEY:
            raise ValueError(
                "JWT_SECRET_KEY muss in Production explizit gesetzt sein!\n"
                "Setze die Environment Variable: export JWT_SECRET_KEY='your-jwt-secret-key'\n"
                "Generiere einen Key: python -c \"import secrets; print(secrets.token_hex(32))\""
            )

        # Validiere Cookie-Sicherheit für HTTPS
        if not cls.SESSION_COOKIE_SECURE:
            app.logger.warning(
                "WARNUNG: SESSION_COOKIE_SECURE ist False! "
                "Setze SESSION_COOKIE_SECURE=true für HTTPS-Produktion."
            )

        # Validiere CORS-Origins
        if not cls.CORS_ORIGINS or cls.CORS_ORIGINS == [''] or 'your-domain.com' in str(cls.CORS_ORIGINS):
            app.logger.warning(
                "WARNUNG: CORS_ORIGINS nicht konfiguriert! "
                "Setze CORS_ORIGINS auf deine Produktions-Domain."
            )


# Config Dictionary
config = {
    'development': DevelopmentConfig,
    'testing': TestingConfig,
    'production': ProductionConfig,
    'default': DevelopmentConfig
}


def get_config(config_name=None):
    """Holt die richtige Konfiguration"""
    if config_name is None:
        config_name = os.environ.get('FLASK_ENV', 'development')
    
    return config.get(config_name, DevelopmentConfig)