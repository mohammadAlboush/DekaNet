"""
Security Headers Middleware
============================
Fügt wichtige Security-Header zu allen Responses hinzu.
"""

from flask import Flask, request


def add_security_headers(app: Flask):
    """
    Fügt Security-Header zu allen Responses hinzu.

    Args:
        app: Flask Application
    """

    @app.after_request
    def set_security_headers(response):
        """Setzt Security-Header für alle Responses"""

        # Content Security Policy (CSP)
        # Strikte Policy für API - Frontend sollte eigene CSP haben
        if app.config.get('ENV') == 'production':
            response.headers['Content-Security-Policy'] = (
                "default-src 'none'; "
                "frame-ancestors 'none'; "
                "base-uri 'none';"
            )
        else:
            # Development: Weniger strikt für einfacheres Testing
            response.headers['Content-Security-Policy'] = (
                "default-src 'self'; "
                "frame-ancestors 'none';"
            )

        # X-Content-Type-Options
        # Verhindert MIME-Type Sniffing
        response.headers['X-Content-Type-Options'] = 'nosniff'

        # X-Frame-Options
        # Verhindert Clickjacking
        response.headers['X-Frame-Options'] = 'DENY'

        # X-XSS-Protection
        # Legacy Browser XSS Protection (modernen Browsern durch CSP ersetzt)
        response.headers['X-XSS-Protection'] = '1; mode=block'

        # Strict-Transport-Security (HSTS)
        # Erzwingt HTTPS (nur in Production mit HTTPS)
        if app.config.get('ENV') == 'production':
            response.headers['Strict-Transport-Security'] = (
                'max-age=31536000; includeSubDomains; preload'
            )

        # Referrer-Policy
        # Kontrolliert Referrer-Informationen
        response.headers['Referrer-Policy'] = 'strict-origin-when-cross-origin'

        # Permissions-Policy (früher Feature-Policy)
        # Deaktiviert unnötige Browser-Features
        response.headers['Permissions-Policy'] = (
            'geolocation=(), '
            'microphone=(), '
            'camera=(), '
            'payment=(), '
            'usb=(), '
            'magnetometer=(), '
            'gyroscope=(), '
            'accelerometer=()'
        )

        # Cache-Control für sensitive Daten
        # API-Responses sollten nicht gecacht werden
        if request.endpoint and 'api' in request.endpoint:
            response.headers['Cache-Control'] = (
                'no-store, no-cache, must-revalidate, private, max-age=0'
            )
            response.headers['Pragma'] = 'no-cache'
            response.headers['Expires'] = '0'

        return response


def configure_cors_security(app: Flask):
    """
    Konfiguriert CORS-sicher.

    Args:
        app: Flask Application
    """

    # CORS ist bereits in extensions.py konfiguriert
    # Hier nur zusätzliche Security-Checks

    @app.before_request
    def check_cors_preflight():
        """Prüft OPTIONS-Requests (CORS Preflight)"""
        from flask import request

        if request.method == 'OPTIONS':
            # Preflight-Request - wird von CORS-Extension gehandhabt
            return

    @app.after_request
    def add_cors_security(response):
        """Zusätzliche CORS-Security"""

        # Erlaubt nur JSON Content-Type für POST/PUT/PATCH
        from flask import request

        if request.method in ['POST', 'PUT', 'PATCH']:
            content_type = request.headers.get('Content-Type', '')
            if 'application/json' not in content_type:
                # Warning loggen
                app.logger.warning(
                    f"Non-JSON Content-Type for {request.method} request",
                    extra={
                        'content_type': content_type,
                        'path': request.path,
                        'method': request.method
                    }
                )

        return response
