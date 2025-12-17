"""
Structured Logging Configuration
=================================
Konfiguration für strukturiertes JSON-Logging mit Kontext-Informationen.
"""

import logging
import json
from datetime import datetime
from typing import Optional, Dict, Any
from flask import request, has_request_context, g
from functools import wraps


class StructuredFormatter(logging.Formatter):
    """
    JSON-basierter Log-Formatter mit zusätzlichen Kontext-Informationen.
    """

    def format(self, record: logging.LogRecord) -> str:
        """Formatiert Log-Record als JSON"""

        # Basis-Log-Daten
        log_data = {
            'timestamp': datetime.utcnow().isoformat() + 'Z',
            'level': record.levelname,
            'logger': record.name,
            'message': record.getMessage(),
            'module': record.module,
            'function': record.funcName,
            'line': record.lineno,
        }

        # Request-Kontext hinzufügen falls verfügbar
        if has_request_context():
            try:
                log_data['request'] = {
                    'method': request.method,
                    'path': request.path,
                    'remote_addr': request.remote_addr,
                    'user_agent': request.user_agent.string if request.user_agent else None,
                }

                # User-ID falls verfügbar
                if hasattr(g, 'current_user_id'):
                    log_data['user_id'] = g.current_user_id

                # Request-ID falls verfügbar
                if hasattr(g, 'request_id'):
                    log_data['request_id'] = g.request_id

            except Exception:
                # Falls Request-Kontext-Zugriff fehlschlägt
                pass

        # Exception-Informationen
        if record.exc_info:
            log_data['exception'] = {
                'type': record.exc_info[0].__name__ if record.exc_info[0] else None,
                'message': str(record.exc_info[1]) if record.exc_info[1] else None,
                'traceback': self.formatException(record.exc_info)
            }

        # Extra-Felder vom LogRecord
        for key, value in record.__dict__.items():
            if key not in ['name', 'msg', 'args', 'created', 'filename', 'funcName',
                          'levelname', 'levelno', 'lineno', 'module', 'msecs',
                          'message', 'pathname', 'process', 'processName',
                          'relativeCreated', 'thread', 'threadName', 'exc_info',
                          'exc_text', 'stack_info']:
                log_data[key] = value

        return json.dumps(log_data, default=str)


class HumanReadableFormatter(logging.Formatter):
    """
    Menschen-lesbarer Log-Formatter für Development.
    """

    def format(self, record: logging.LogRecord) -> str:
        """Formatiert Log-Record menschen-lesbar"""

        # Farben für verschiedene Log-Levels (nur in Terminals mit ANSI-Support)
        colors = {
            'DEBUG': '\033[36m',     # Cyan
            'INFO': '\033[32m',      # Green
            'WARNING': '\033[33m',   # Yellow
            'ERROR': '\033[31m',     # Red
            'CRITICAL': '\033[35m',  # Magenta
            'RESET': '\033[0m'       # Reset
        }

        # Timestamp
        timestamp = datetime.fromtimestamp(record.created).strftime('%Y-%m-%d %H:%M:%S')

        # Level mit Farbe (optional)
        level = f"{colors.get(record.levelname, '')}{record.levelname:8}{colors['RESET']}"

        # Basis-Message
        message = f"[{timestamp}] {level} {record.name}: {record.getMessage()}"

        # Request-Info hinzufügen
        if has_request_context():
            try:
                request_info = f" [{request.method} {request.path}]"
                if hasattr(g, 'current_user_id'):
                    request_info += f" [User: {g.current_user_id}]"
                message += request_info
            except Exception:
                pass

        # Exception-Info
        if record.exc_info:
            message += "\n" + self.formatException(record.exc_info)

        return message


def setup_logging(app, config_name: str = 'development'):
    """
    Konfiguriert Logging für die Flask-App.

    Args:
        app: Flask Application
        config_name: Konfigurations-Umgebung ('development', 'production', 'testing')
    """

    # Root-Logger konfigurieren
    root_logger = logging.getLogger()
    root_logger.setLevel(logging.INFO)

    # Entferne existierende Handler
    for handler in root_logger.handlers[:]:
        root_logger.removeHandler(handler)

    # Console-Handler
    console_handler = logging.StreamHandler()

    if config_name == 'production':
        # Production: Strukturiertes JSON-Logging
        console_handler.setFormatter(StructuredFormatter())
        console_handler.setLevel(logging.INFO)
    else:
        # Development/Testing: Menschen-lesbares Format
        console_handler.setFormatter(HumanReadableFormatter())
        console_handler.setLevel(logging.DEBUG)

    root_logger.addHandler(console_handler)

    # File-Handler für Production
    if config_name == 'production':
        try:
            file_handler = logging.FileHandler('app.log')
            file_handler.setFormatter(StructuredFormatter())
            file_handler.setLevel(logging.INFO)
            root_logger.addHandler(file_handler)

            # Error-Log separat
            error_handler = logging.FileHandler('error.log')
            error_handler.setFormatter(StructuredFormatter())
            error_handler.setLevel(logging.ERROR)
            root_logger.addHandler(error_handler)
        except Exception as e:
            app.logger.error(f"Could not create log files: {e}")

    # SQLAlchemy-Logging reduzieren
    logging.getLogger('sqlalchemy.engine').setLevel(logging.WARNING)

    app.logger.info(f"Logging configured for {config_name} environment")


def log_with_context(logger: logging.Logger, level: str, message: str, **kwargs):
    """
    Logged eine Message mit zusätzlichem Kontext.

    Args:
        logger: Logger-Instanz
        level: Log-Level ('debug', 'info', 'warning', 'error', 'critical')
        message: Log-Message
        **kwargs: Zusätzliche Kontext-Daten

    Examples:
        >>> log_with_context(app.logger, 'info', 'User logged in', user_id=123, ip='192.168.1.1')
    """
    log_func = getattr(logger, level.lower())
    log_func(message, extra=kwargs)


def log_decorator(message: Optional[str] = None, level: str = 'info'):
    """
    Decorator zum automatischen Logging von Funktions-Aufrufen.

    Args:
        message: Optionale custom Message
        level: Log-Level

    Examples:
        >>> @log_decorator('Processing planung', level='info')
        >>> def process_planung(planung_id):
        >>>     ...
    """
    def decorator(func):
        @wraps(func)
        def wrapper(*args, **kwargs):
            logger = logging.getLogger(func.__module__)

            func_name = func.__name__
            log_message = message or f"Calling {func_name}"

            # Vor Ausführung loggen
            log_with_context(
                logger, level, log_message,
                function=func_name,
                args_count=len(args),
                kwargs_count=len(kwargs)
            )

            try:
                result = func(*args, **kwargs)

                # Erfolg loggen
                log_with_context(
                    logger, level, f"{func_name} completed successfully",
                    function=func_name,
                    success=True
                )

                return result

            except Exception as e:
                # Fehler loggen
                log_with_context(
                    logger, 'error', f"{func_name} failed",
                    function=func_name,
                    error=str(e),
                    error_type=type(e).__name__,
                    success=False
                )
                raise

        return wrapper
    return decorator


# Security Event Logging
class SecurityLogger:
    """Logger für Security-Events"""

    def __init__(self, app_logger):
        self.logger = app_logger

    def log_login_attempt(self, username: str, success: bool, ip: str, reason: Optional[str] = None):
        """Logged Login-Versuche"""
        self.logger.warning(
            f"Login attempt: {username}",
            extra={
                'event_type': 'login_attempt',
                'username': username,
                'success': success,
                'ip_address': ip,
                'reason': reason
            }
        )

    def log_authorization_failure(self, user_id: int, resource: str, action: str):
        """Logged Autorisierungs-Fehler"""
        self.logger.warning(
            f"Authorization failed: User {user_id} tried {action} on {resource}",
            extra={
                'event_type': 'authorization_failure',
                'user_id': user_id,
                'resource': resource,
                'action': action
            }
        )

    def log_suspicious_activity(self, description: str, **kwargs):
        """Logged verdächtige Aktivitäten"""
        self.logger.warning(
            f"Suspicious activity: {description}",
            extra={
                'event_type': 'suspicious_activity',
                'description': description,
                **kwargs
            }
        )

    def log_data_access(self, user_id: int, resource_type: str, resource_id: int, action: str):
        """Logged Datenzugriffe"""
        self.logger.info(
            f"Data access: User {user_id} {action} {resource_type} {resource_id}",
            extra={
                'event_type': 'data_access',
                'user_id': user_id,
                'resource_type': resource_type,
                'resource_id': resource_id,
                'action': action
            }
        )

    def log_password_change(self, user_id: int, success: bool, ip: str):
        """Logged Passwort-Änderungen"""
        level = 'info' if success else 'warning'
        log_func = getattr(self.logger, level)
        log_func(
            f"Password change: User {user_id}",
            extra={
                'event_type': 'password_change',
                'user_id': user_id,
                'success': success,
                'ip_address': ip
            }
        )

    def log_rate_limit_exceeded(self, ip: str, endpoint: str, limit: str):
        """Logged Rate Limit Überschreitungen"""
        self.logger.warning(
            f"Rate limit exceeded: {ip} on {endpoint}",
            extra={
                'event_type': 'rate_limit_exceeded',
                'ip_address': ip,
                'endpoint': endpoint,
                'limit': limit
            }
        )

    def log_validation_error(self, endpoint: str, errors: dict, ip: str):
        """Logged Input Validation Errors"""
        self.logger.info(
            f"Validation error on {endpoint}",
            extra={
                'event_type': 'validation_error',
                'endpoint': endpoint,
                'errors': errors,
                'ip_address': ip
            }
        )

    def log_file_upload(self, user_id: int, filename: str, size: int, success: bool, reason: Optional[str] = None):
        """Logged File Upload Versuche"""
        level = 'info' if success else 'warning'
        log_func = getattr(self.logger, level)
        log_func(
            f"File upload: User {user_id}, File {filename}",
            extra={
                'event_type': 'file_upload',
                'user_id': user_id,
                'filename': filename,
                'size_bytes': size,
                'success': success,
                'reason': reason
            }
        )

    def log_csrf_failure(self, endpoint: str, ip: str):
        """Logged CSRF Token Failures"""
        self.logger.warning(
            f"CSRF validation failed: {endpoint}",
            extra={
                'event_type': 'csrf_failure',
                'endpoint': endpoint,
                'ip_address': ip
            }
        )

    def log_jwt_error(self, error_type: str, user_id: Optional[str], ip: str, reason: str):
        """Logged JWT Fehler"""
        self.logger.warning(
            f"JWT Error: {error_type}",
            extra={
                'event_type': 'jwt_error',
                'error_type': error_type,
                'user_id': user_id,
                'ip_address': ip,
                'reason': reason
            }
        )

    def log_account_lockout(self, username: str, ip: str, reason: str):
        """Logged Account Lockouts (z.B. nach zu vielen fehlgeschlagenen Login-Versuchen)"""
        self.logger.error(
            f"Account lockout: {username}",
            extra={
                'event_type': 'account_lockout',
                'username': username,
                'ip_address': ip,
                'reason': reason
            }
        )

    def log_privilege_escalation_attempt(self, user_id: int, requested_role: str, ip: str):
        """Logged Privilege Escalation Versuche"""
        self.logger.critical(
            f"Privilege escalation attempt: User {user_id} tried to access {requested_role}",
            extra={
                'event_type': 'privilege_escalation',
                'user_id': user_id,
                'requested_role': requested_role,
                'ip_address': ip
            }
        )
