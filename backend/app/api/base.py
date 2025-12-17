"""
Base API
========
Foundation für alle API Endpoints.

Provides:
- Response Formatting
- Error Handling
- Decorators (authentication, authorization)
- Pagination Helper
- Request Validation
"""

from functools import wraps
from flask import jsonify, request, current_app
from flask_jwt_extended import verify_jwt_in_request, get_jwt_identity
from typing import Optional, Dict, Any, Callable, List, Tuple
from app.models import Benutzer


# =========================================================================
# RESPONSE FORMATTER
# =========================================================================

class ApiResponse:
    """
    Standardisierte API Response
    
    Format:
        {
            "success": true/false,
            "data": {...},
            "message": "...",
            "errors": [...],
            "meta": {...}
        }
    """
    
    @staticmethod
    def success(
        data: Any = None,
        message: str = None,
        status_code: int = 200,
        meta: Dict[str, Any] = None
    ):
        """
        Erfolgreiche Response
        
        Args:
            data: Response Daten
            message: Optional - Success Message
            status_code: HTTP Status Code (default: 200)
            meta: Optional - Metadata (pagination, etc.)
            
        Returns:
            Flask Response mit JSON
            
        Example:
            return ApiResponse.success(
                data={'user': user.to_dict()},
                message='User created successfully',
                status_code=201
            )
        """
        response = {
            'success': True,
            'data': data
        }
        
        if message:
            response['message'] = message
        
        if meta:
            response['meta'] = meta
        
        return jsonify(response), status_code
    
    @staticmethod
    def error(
        message: str,
        errors: List[str] = None,
        status_code: int = 400,
        data: Any = None
    ):
        """
        Error Response
        
        Args:
            message: Error Message
            errors: Optional - Liste von Fehlermeldungen
            status_code: HTTP Status Code (default: 400)
            data: Optional - Zusätzliche Daten
            
        Returns:
            Flask Response mit JSON
            
        Example:
            return ApiResponse.error(
                message='Validation failed',
                errors=['Email is required', 'Password too short'],
                status_code=400
            )
        """
        response = {
            'success': False,
            'message': message
        }
        
        if errors:
            response['errors'] = errors
        
        if data:
            response['data'] = data
        
        return jsonify(response), status_code
    
    @staticmethod
    def paginated(
        items: List[Any],
        total: int,
        page: int,
        per_page: int,
        message: str = None
    ):
        """
        Paginierte Response
        
        Args:
            items: Liste von Items
            total: Gesamtanzahl
            page: Aktuelle Seite
            per_page: Items pro Seite
            message: Optional - Message
            
        Returns:
            Flask Response mit Pagination Meta
            
        Example:
            return ApiResponse.paginated(
                items=[user.to_dict() for user in users],
                total=100,
                page=1,
                per_page=20
            )
        """
        total_pages = (total + per_page - 1) // per_page
        
        return ApiResponse.success(
            data=items,
            message=message,
            meta={
                'pagination': {
                    'total': total,
                    'page': page,
                    'per_page': per_page,
                    'pages': total_pages,
                    'has_prev': page > 1,
                    'has_next': page < total_pages
                }
            }
        )


# =========================================================================
# DECORATORS
# =========================================================================

def login_required(fn: Callable) -> Callable:
    """
    Decorator: Requires valid JWT Token
    
    Usage:
        @app.route('/protected')
        @login_required
        def protected():
            return {'message': 'Protected!'}
    """
    @wraps(fn)
    def wrapper(*args, **kwargs):
        try:
            verify_jwt_in_request()
            return fn(*args, **kwargs)
        except Exception as e:
            return ApiResponse.error(
                message='Authentication required',
                errors=[str(e)],
                status_code=401
            )
    return wrapper


def role_required(*allowed_roles: str):
    """
    Decorator: Requires specific role(s)
    
    Args:
        *allowed_roles: Rolle(n) die erlaubt sind
        
    Usage:
        @app.route('/admin')
        @role_required('dekan')
        def admin_only():
            return {'message': 'Admin area!'}
    """
    def decorator(fn: Callable) -> Callable:
        @wraps(fn)
        def wrapper(*args, **kwargs):
            try:
                verify_jwt_in_request()
                user_id = get_jwt_identity()
                user = Benutzer.query.get(user_id)
                
                if not user:
                    return ApiResponse.error(
                        message='User not found',
                        status_code=401
                    )
                
                if not user.aktiv:
                    return ApiResponse.error(
                        message='Account is deactivated',
                        status_code=403
                    )
                
                if user.rolle.name not in allowed_roles:
                    return ApiResponse.error(
                        message=f'Requires role: {", ".join(allowed_roles)}',
                        status_code=403
                    )
                
                return fn(*args, **kwargs)
            except Exception as e:
                return ApiResponse.error(
                    message='Authorization failed',
                    errors=[str(e)],
                    status_code=403
                )
        return wrapper
    return decorator


def get_current_user() -> Optional[Benutzer]:
    """
    Holt aktuellen eingeloggten User
    
    Returns:
        Benutzer oder None
        
    Usage:
        user = get_current_user()
        if user:
            print(f"Logged in as: {user.username}")
    """
    try:
        verify_jwt_in_request()
        user_id = get_jwt_identity()
        return Benutzer.query.get(user_id)
    except:
        return None


def validate_request(required_fields: List[str]):
    """
    Decorator: Validiert Request JSON
    
    Args:
        required_fields: Liste von Pflichtfeldern
        
    Usage:
        @app.route('/create', methods=['POST'])
        @validate_request(['email', 'password'])
        def create():
            data = request.get_json()
            return {'email': data['email']}
    """
    def decorator(fn: Callable) -> Callable:
        @wraps(fn)
        def wrapper(*args, **kwargs):
            if not request.is_json:
                return ApiResponse.error(
                    message='Content-Type must be application/json',
                    status_code=400
                )
            
            data = request.get_json()
            missing_fields = [field for field in required_fields if field not in data]
            
            if missing_fields:
                return ApiResponse.error(
                    message='Missing required fields',
                    errors=[f'{field} is required' for field in missing_fields],
                    status_code=400
                )
            
            return fn(*args, **kwargs)
        return wrapper
    return decorator


# =========================================================================
# PAGINATION HELPER
# =========================================================================

def get_pagination_params() -> Tuple[int, int]:
    """
    Holt Pagination Parameter aus Request
    
    Returns:
        tuple: (page, per_page)
        
    Query Parameters:
        ?page=1&per_page=20
        
    Example:
        page, per_page = get_pagination_params()
        result = service.paginate(page=page, per_page=per_page)
    """
    page = request.args.get('page', 1, type=int)
    per_page = request.args.get('per_page', 20, type=int)
    
    # Limits
    page = max(1, page)
    per_page = min(100, max(1, per_page))
    
    return page, per_page


def get_filter_params(allowed_filters: List[str]) -> Dict[str, Any]:
    """
    Holt Filter Parameter aus Request
    
    Args:
        allowed_filters: Liste von erlaubten Filter-Feldern
        
    Returns:
        Dict mit Filtern
        
    Example:
        filters = get_filter_params(['status', 'semester_id'])
        # GET /api/planungen?status=eingereicht&semester_id=1
        # filters = {'status': 'eingereicht', 'semester_id': 1}
    """
    filters = {}
    for field in allowed_filters:
        value = request.args.get(field)
        if value:
            filters[field] = value
    
    return filters


def get_sort_params(allowed_fields: List[str]) -> Tuple[str, str]:
    """
    Holt Sorting Parameter aus Request
    
    Args:
        allowed_fields: Liste von erlaubten Sort-Feldern
        
    Returns:
        tuple: (sort_by, sort_order)
        
    Query Parameters:
        ?sort_by=created_at&sort_order=desc
        
    Example:
        sort_by, sort_order = get_sort_params(['created_at', 'name'])
    """
    sort_by = request.args.get('sort_by', allowed_fields[0] if allowed_fields else 'id')
    sort_order = request.args.get('sort_order', 'desc')
    
    # Validation
    if sort_by not in allowed_fields:
        sort_by = allowed_fields[0] if allowed_fields else 'id'
    
    if sort_order not in ['asc', 'desc']:
        sort_order = 'desc'
    
    return sort_by, sort_order


# =========================================================================
# ERROR HANDLERS
# =========================================================================

def register_error_handlers(app):
    """
    Registriert globale Error Handlers
    
    Args:
        app: Flask App Instance
        
    Usage:
        register_error_handlers(app)
    """
    
    @app.errorhandler(400)
    def bad_request(e):
        return ApiResponse.error(
            message='Bad Request',
            errors=[str(e)],
            status_code=400
        )
    
    @app.errorhandler(401)
    def unauthorized(e):
        return ApiResponse.error(
            message='Unauthorized',
            errors=[str(e)],
            status_code=401
        )
    
    @app.errorhandler(403)
    def forbidden(e):
        return ApiResponse.error(
            message='Forbidden',
            errors=[str(e)],
            status_code=403
        )
    
    @app.errorhandler(404)
    def not_found(e):
        return ApiResponse.error(
            message='Resource not found',
            status_code=404
        )
    
    @app.errorhandler(500)
    def internal_error(e):
        return ApiResponse.error(
            message='Internal Server Error',
            errors=[str(e)],
            status_code=500
        )


# =========================================================================
# REQUEST HELPERS
# =========================================================================

def get_json_or_400() -> Dict[str, Any]:
    """
    Holt JSON aus Request oder gibt 400 zurück
    
    Returns:
        Dict mit JSON Daten
        
    Raises:
        400 Error wenn kein JSON
    """
    if not request.is_json:
        return ApiResponse.error(
            message='Content-Type must be application/json',
            status_code=400
        )
    
    return request.get_json()


def get_search_query() -> Optional[str]:
    """
    Holt Suchbegriff aus Query Parameter
    
    Returns:
        str: Suchbegriff oder None
        
    Query Parameter:
        ?search=programmieren
    """
    return request.args.get('search', '').strip() or None