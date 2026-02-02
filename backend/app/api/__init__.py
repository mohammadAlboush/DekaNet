"""
backend/app/api/__init__.py - 
============================================

"""

from flask import Flask
import logging

def register_blueprints(app: Flask):
    """
    
    """
    
    logger = app.logger or logging.getLogger(__name__)
    
    logger.info("="*80)
    logger.info("[API] Registering API Blueprints...")
    logger.info("="*80)
    
    # AUTH API (JWT)
    try:
        from app.api.auth import api_auth_bp
        # KEIN url_prefix hier! Blueprint hat schon /api/auth
        app.register_blueprint(api_auth_bp)
        logger.info('   [OK] API Auth Blueprint: /api/auth')
    except ImportError as e:
        logger.error(f'   [ERROR] Failed to import auth API: {e}')
    
    # SEMESTER API
    try:
        from app.api.semester import semester_api
        # Blueprint hat schon /api/semester
        app.register_blueprint(semester_api)
        logger.info('   [OK] Semester API: /api/semester')
    except ImportError as e:
        logger.error(f'   [ERROR] Failed to import semester API: {e}')
    
    # PLANUNG API
    try:
        from app.api.planung import planung_api
        # Blueprint hat schon /api/planung
        app.register_blueprint(planung_api)
        logger.info('   [OK] Planung API: /api/planung')
    except ImportError as e:
        logger.error(f'   [ERROR] Failed to import planung API: {e}')
    
    try:
        from app.api.module import modul_api
        # Blueprint hat schon /api/module
        app.register_blueprint(modul_api)
        logger.info('   [OK] Module API: /api/module')
    except ImportError as e:
        logger.error(f'   [ERROR] Failed to import module API: {e}')
    
    try:
        from app.api.dozenten import dozenten_api
        app.register_blueprint(dozenten_api)
        logger.info('   [OK] Dozenten API: /api/dozenten')
    except ImportError as e:
        logger.error(f'   [ERROR] Failed to import dozenten API: {e}')
    
    # STUDIENGÄNGE API
    try:
        from app.api.studiengaenge import studiengaenge_api, po_api
        app.register_blueprint(studiengaenge_api)
        app.register_blueprint(po_api)
        logger.info('   [OK] Studiengänge API: /api/studiengaenge')
        logger.info('   [OK] Prüfungsordnungen API: /api/pruefungsordnungen')
    except ImportError as e:
        logger.error(f'   [ERROR] Failed to import studiengaenge API: {e}')
    
    # DASHBOARD API
    try:
        from app.api.dashboard import dashboard_api
        app.register_blueprint(dashboard_api)
        logger.info('   [OK] Dashboard API: /api/dashboard')
    except ImportError as e:
        logger.error(f'   [ERROR] Failed to import dashboard API: {e}')

    # PLANUNGSPHASE API
    try:
        from app.api.planungsphase import planungsphase_api, archiv_api
        app.register_blueprint(planungsphase_api)
        app.register_blueprint(archiv_api)
        logger.info('   [OK] Planungsphase API: /api/planungphase')
        logger.info('   [OK] Archiv API: /api/archiv')
    except ImportError as e:
        logger.error(f'   [ERROR] Failed to import planungsphase API: {e}')

    # AUFTRÄGE API
    try:
        from app.api.auftraege import auftrag_api
        app.register_blueprint(auftrag_api)
        logger.info('   [OK] Aufträge API: /api/auftraege')
    except ImportError as e:
        logger.error(f'   [ERROR] Failed to import auftraege API: {e}')

    # MODUL-VERWALTUNG API
    try:
        from app.api.modul_verwaltung import modul_verwaltung_api
        app.register_blueprint(modul_verwaltung_api)
        logger.info('   [OK] Modul-Verwaltung API: /api/modul-verwaltung')
    except ImportError as e:
        logger.error(f'   [ERROR] Failed to import modul_verwaltung API: {e}')

    # DEPUTAT API
    try:
        from app.api.deputat import deputat_api
        app.register_blueprint(deputat_api)
        logger.info('   [OK] Deputat API: /api/deputat')
    except ImportError as e:
        logger.error(f'   [ERROR] Failed to import deputat API: {e}')

    # TEMPLATES API
    try:
        from app.api.templates import template_api
        app.register_blueprint(template_api)
        logger.info('   [OK] Templates API: /api/templates')
    except ImportError as e:
        logger.error(f'   [ERROR] Failed to import templates API: {e}')

    # ADMIN API (Database Reset)
    try:
        from app.api.admin import admin_api
        app.register_blueprint(admin_api)
        logger.info('   [OK] Admin API: /api/admin')
    except ImportError as e:
        logger.error(f'   [ERROR] Failed to import admin API: {e}')

    logger.info("="*80)
    logger.info('[OK] All API Blueprints registered')
    logger.info("="*80)

# Export the registration function
__all__ = ['register_blueprints']