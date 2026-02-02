"""
Health Check API
================
Health & Readiness Endpoints für Load Balancer und Monitoring

Endpoints:
- GET /health     - Health Check (DB Connection)
- GET /ready      - Readiness Check
- GET /metrics    - System Metrics (Optional)
"""

from flask import Blueprint, jsonify
from datetime import datetime
from app.extensions import db
from sqlalchemy import text
from app.api.base import ApiResponse
import psutil
import os

health_api = Blueprint('health', __name__)


@health_api.route('/health', methods=['GET'])
def health_check():
    """
    Health Check Endpoint
    =====================
    Prüft ob die Application gesund ist:
    - Database Connection
    - Application läuft

    Returns:
        200: Application ist healthy
        503: Application ist unhealthy

    Example:
        GET /health

        Response (200):
        {
            "status": "healthy",
            "database": "connected",
            "timestamp": "2025-12-04T10:30:00.000Z",
            "version": "1.0.0"
        }

        Response (503):
        {
            "status": "unhealthy",
            "database": "disconnected",
            "error": "Connection refused",
            "timestamp": "2025-12-04T10:30:00.000Z"
        }
    """
    checks = {
        'status': 'healthy',
        'timestamp': datetime.utcnow().isoformat() + 'Z',
        'version': os.getenv('APP_VERSION', '1.0.0')
    }

    # Check Database Connection
    try:
        db.session.execute(text('SELECT 1'))
        checks['database'] = 'connected'
    except Exception as e:
        checks['status'] = 'unhealthy'
        checks['database'] = 'disconnected'
        checks['error'] = str(e)
        return jsonify(checks), 503

    return jsonify(checks), 200


@health_api.route('/ready', methods=['GET'])
def readiness_check():
    """
    Readiness Check Endpoint
    ========================
    Prüft ob die Application bereit ist, Traffic zu empfangen.

    Unterschied zu /health:
    - /health: Ist die App grundsätzlich gesund?
    - /ready: Ist die App bereit für Requests?

    Use Case:
    - Kubernetes Readiness Probe
    - Load Balancer Health Check
    - Deployment-Prozess (warten bis ready)

    Returns:
        200: Application ist ready
        503: Application ist not ready

    Example:
        GET /ready

        Response (200):
        {
            "status": "ready",
            "timestamp": "2025-12-04T10:30:00.000Z"
        }
    """
    # Hier können zusätzliche Checks hinzugefügt werden:
    # - Ist Cache verfügbar?
    # - Sind externe Services erreichbar?
    # - Sind Migrations durchgeführt?

    return jsonify({
        'status': 'ready',
        'timestamp': datetime.utcnow().isoformat() + 'Z'
    }), 200


@health_api.route('/metrics', methods=['GET'])
def metrics():
    """
    System Metrics Endpoint
    =======================
    Liefert System-Metriken für Monitoring.

    OPTIONAL: Nur aktivieren wenn gewünscht!
    Kann für Prometheus, Grafana, etc. genutzt werden.

    Returns:
        200: Metrics
        500: Error

    Example:
        GET /metrics

        Response (200):
        {
            "system": {
                "cpu_percent": 45.2,
                "memory_percent": 62.8,
                "memory_used_mb": 1024,
                "memory_total_mb": 4096,
                "disk_percent": 55.3
            },
            "database": {
                "pool_size": 10,
                "connections_checkedin": 8,
                "connections_checkedout": 2,
                "overflow": 0
            },
            "application": {
                "uptime_seconds": 3600,
                "version": "1.0.0",
                "environment": "production"
            },
            "timestamp": "2025-12-04T10:30:00.000Z"
        }
    """
    try:
        metrics_data = {
            'timestamp': datetime.utcnow().isoformat() + 'Z',
            'application': {
                'version': os.getenv('APP_VERSION', '1.0.0'),
                'environment': os.getenv('FLASK_ENV', 'development')
            }
        }

        # System Metrics
        try:
            memory = psutil.virtual_memory()
            disk = psutil.disk_usage('/')

            metrics_data['system'] = {
                'cpu_percent': psutil.cpu_percent(interval=0.1),
                'memory_percent': memory.percent,
                'memory_used_mb': round(memory.used / 1024 / 1024, 2),
                'memory_total_mb': round(memory.total / 1024 / 1024, 2),
                'disk_percent': disk.percent
            }
        except Exception as e:
            metrics_data['system'] = {'error': str(e)}

        # Database Metrics
        try:
            pool = db.engine.pool
            metrics_data['database'] = {
                'pool_size': pool.size(),
                'connections_checkedin': pool.checkedin(),
                'connections_checkedout': pool.checkedout(),
                'overflow': pool.overflow()
            }
        except Exception as e:
            metrics_data['database'] = {'error': str(e)}

        return jsonify(metrics_data), 200

    except Exception as e:
        return ApiResponse.internal_error(
            message='Metrics collection failed',
            exception=e,
            log_context='HealthAPI'
        )


@health_api.route('/ping', methods=['GET'])
def ping():
    """
    Simple Ping Endpoint
    ====================
    Einfachster Check: Ist die App erreichbar?

    Kein DB-Check, kein overhead.
    Gut für schnelle Load Balancer Checks.

    Returns:
        200: pong

    Example:
        GET /ping

        Response (200):
        {
            "message": "pong",
            "timestamp": "2025-12-04T10:30:00.000Z"
        }
    """
    return jsonify({
        'message': 'pong',
        'timestamp': datetime.utcnow().isoformat() + 'Z'
    }), 200


# ============================================================================
# VERWENDUNG
# ============================================================================
# 1. Load Balancer Health Check:
#    - Primary: GET /health (mit DB Check)
#    - Fallback: GET /ping (ohne DB Check)
#
# 2. Kubernetes Probes:
#    - livenessProbe: GET /ping
#    - readinessProbe: GET /ready
#
# 3. Monitoring (Prometheus):
#    - GET /metrics
#
# 4. Deployment Check:
#    - GET /ready (warten bis 200)
# ============================================================================
