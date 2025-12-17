"""
Application Entry Point
=======================
Startet die Flask Application.

Usage:
    python run.py
    
    # oder mit flask command
    flask run
    
    # mit debug mode
    flask run --debug
    
    # mit custom port
    flask run --port 5001
"""

import os
from app import create_app


# App erstellen
app = create_app(os.environ.get('FLASK_ENV', 'development'))


if __name__ == '__main__':
    """
    Startet Development Server
    NICHT für Production verwenden! (Verwende gunicorn/uwsgi)
    """
    
    # Port aus Environment oder Default 5000
    port = int(os.environ.get('PORT', 5000))
    
    # Debug aus Environment oder Config
    debug = app.config.get('DEBUG', False)
    
    # Host (0.0.0.0 = von außen erreichbar)
    host = os.environ.get('HOST', '127.0.0.1')
    
    print(f"""
    ================================================================

            DIGITALES DEKANAT - Backend Server

    ================================================================

     Server running on: http://{host}:{port}
     Environment: {os.environ.get('FLASK_ENV', 'development')}
     Debug Mode: {debug}
     Database: {app.config['SQLALCHEMY_DATABASE_URI'].split('///')[-1] if 'sqlite' in app.config['SQLALCHEMY_DATABASE_URI'] else 'PostgreSQL'}

     Ready to accept requests!

    Press CTRL+C to stop the server
    """)
    
    app.run(
        host=host,
        port=port,
        debug=debug,
        use_reloader=debug,
        threaded=True
    )