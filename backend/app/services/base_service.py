"""
Base Service
============
Foundation für alle Services mit CRUD Operations.

Alle Services erben von dieser Klasse und bekommen automatisch:
- get_by_id()
- get_all()
- create()
- update()
- delete()
- paginate()
"""

from typing import Optional, List, Dict, Any, Type
from sqlalchemy.orm import Query
from app.extensions import db
from app.models import BaseModel
from flask import current_app


class BaseService:
    """
    Base Service Class
    
    Provides common CRUD operations for all services.
    Services should inherit from this class.
    
    Attributes:
        model: SQLAlchemy Model Class
    
    Example:
        class UserService(BaseService):
            model = Benutzer
            
        user_service = UserService()
        user = user_service.get_by_id(1)
    """
    
    model: Type[BaseModel] = None
    
    def __init__(self):
        """Initialisiert Service"""
        if self.model is None:
            raise ValueError(f"{self.__class__.__name__} muss 'model' Attribut haben")
    
    # =========================================================================
    # READ OPERATIONS
    # =========================================================================
    
    def get_by_id(self, id: int) -> Optional[BaseModel]:
        """
        Holt Objekt anhand ID
        
        Args:
            id: Primärschlüssel
            
        Returns:
            Model-Objekt oder None
            
        Example:
            user = user_service.get_by_id(1)
        """
        return self.model.query.get(id)
    
    def get_all(self, **filters) -> List[BaseModel]:
        """
        Holt alle Objekte mit optionalen Filtern
        
        Args:
            **filters: SQLAlchemy Filter (z.B. aktiv=True)
            
        Returns:
            Liste von Model-Objekten
            
        Example:
            active_users = user_service.get_all(aktiv=True)
        """
        query = self.model.query
        
        # Apply filters - mehr Flexibilität
        for key, value in filters.items():
            if value is not None:
                # Prüfe ob das Attribut existiert
                if hasattr(self.model, key):
                    query = query.filter_by(**{key: value})
                else:
                    current_app.logger.warning(f"Unknown filter attribute: {key}")
        
        return query.all()
    
    def get_first(self, **filters) -> Optional[BaseModel]:
        """
        Holt erstes Objekt mit Filtern
        
        Args:
            **filters: SQLAlchemy Filter
            
        Returns:
            Model-Objekt oder None
            
        Example:
            user = user_service.get_first(email='test@example.com')
        """
        return self.model.query.filter_by(**filters).first()
    
    def exists(self, **filters) -> bool:
        """
        Prüft ob Objekt existiert
        
        Args:
            **filters: SQLAlchemy Filter
            
        Returns:
            bool: True wenn existiert
            
        Example:
            exists = user_service.exists(email='test@example.com')
        """
        return self.model.query.filter_by(**filters).first() is not None
    
    def count(self, **filters) -> int:
        """
        Zählt Objekte
        
        Args:
            **filters: SQLAlchemy Filter
            
        Returns:
            int: Anzahl
            
        Example:
            total = user_service.count()
            active = user_service.count(aktiv=True)
        """
        query = self.model.query
        
        for key, value in filters.items():
            if value is not None and hasattr(self.model, key):
                query = query.filter_by(**{key: value})
        
        return query.count()
    
    # =========================================================================
    # CREATE OPERATIONS
    # =========================================================================
    
    def create(self, **data) -> BaseModel:
        """
        Erstellt neues Objekt
        
        Args:
            **data: Felder für das Objekt
            
        Returns:
            Erstelltes Model-Objekt
            
        Raises:
            ValueError: Bei ungültigen Daten
            
        Example:
            user = user_service.create(
                username='test',
                email='test@example.com'
            )
        """
        try:
            obj = self.model(**data)
            db.session.add(obj)
            db.session.commit()
            return obj
        except Exception as e:
            db.session.rollback()
            raise ValueError(f"Fehler beim Erstellen: {str(e)}")
    
    def create_many(self, objects: List[Dict[str, Any]]) -> List[BaseModel]:
        """
        Erstellt mehrere Objekte auf einmal
        
        Args:
            objects: Liste von Dictionaries mit Objektdaten
            
        Returns:
            Liste von erstellten Objekten
            
        Example:
            users = user_service.create_many([
                {'username': 'user1', 'email': 'user1@example.com'},
                {'username': 'user2', 'email': 'user2@example.com'}
            ])
        """
        try:
            objs = [self.model(**data) for data in objects]
            db.session.add_all(objs)
            db.session.commit()
            return objs
        except Exception as e:
            db.session.rollback()
            raise ValueError(f"Fehler beim Erstellen mehrerer Objekte: {str(e)}")
    
    # =========================================================================
    # UPDATE OPERATIONS
    # =========================================================================
    
    def update(self, id: int, **data) -> Optional[BaseModel]:
        """
        Updated Objekt
        
        Args:
            id: Primärschlüssel
            **data: Felder die geupdated werden sollen
            
        Returns:
            Geupdatetes Objekt oder None
            
        Example:
            user = user_service.update(1, vorname='Max')
        """
        obj = self.get_by_id(id)
        if not obj:
            return None
        
        try:
            for key, value in data.items():
                if hasattr(obj, key):
                    setattr(obj, key, value)
            db.session.commit()
            return obj
        except Exception as e:
            db.session.rollback()
            raise ValueError(f"Fehler beim Updaten: {str(e)}")
    
    def update_many(self, objects: List[Dict[str, Any]]) -> List[BaseModel]:
        """
        Updated mehrere Objekte
        
        Args:
            objects: Liste von Dicts mit 'id' und Update-Feldern
            
        Returns:
            Liste von geupdateten Objekten
            
        Example:
            users = user_service.update_many([
                {'id': 1, 'aktiv': False},
                {'id': 2, 'aktiv': False}
            ])
        """
        updated = []
        try:
            for data in objects:
                obj_id = data.pop('id')
                obj = self.update(obj_id, **data)
                if obj:
                    updated.append(obj)
            return updated
        except Exception as e:
            db.session.rollback()
            raise ValueError(f"Fehler beim Updaten mehrerer Objekte: {str(e)}")
    
    # =========================================================================
    # DELETE OPERATIONS
    # =========================================================================
    
    def delete(self, id: int) -> bool:
        """
        Löscht Objekt
        
        Args:
            id: Primärschlüssel
            
        Returns:
            bool: True wenn erfolgreich gelöscht
            
        Example:
            success = user_service.delete(1)
        """
        obj = self.get_by_id(id)
        if not obj:
            return False
        
        try:
            db.session.delete(obj)
            db.session.commit()
            return True
        except Exception as e:
            db.session.rollback()
            raise ValueError(f"Fehler beim Löschen: {str(e)}")
    
    def delete_many(self, ids: List[int]) -> int:
        """
        Löscht mehrere Objekte
        
        Args:
            ids: Liste von IDs
            
        Returns:
            int: Anzahl gelöschter Objekte
            
        Example:
            deleted = user_service.delete_many([1, 2, 3])
        """
        count = 0
        try:
            for obj_id in ids:
                if self.delete(obj_id):
                    count += 1
            return count
        except Exception as e:
            db.session.rollback()
            raise ValueError(f"Fehler beim Löschen mehrerer Objekte: {str(e)}")
    
    # =========================================================================
    # QUERY HELPERS
    # =========================================================================
    
    def filter(self, **filters) -> Query:
        """
        Erstellt Query mit Filtern
        
        Args:
            **filters: SQLAlchemy Filter
            
        Returns:
            Query-Objekt
            
        Example:
            query = user_service.filter(aktiv=True)
            users = query.all()
        """
        return self.model.query.filter_by(**filters)
    
    def paginate(self, page: int = 1, per_page: int = 20, **filters) -> Dict[str, Any]:
        """
        Paginiert Ergebnisse - VERBESSERTE VERSION mit Fallback
        
        Args:
            page: Seitennummer (1-basiert)
            per_page: Objekte pro Seite
            **filters: SQLAlchemy Filter
            
        Returns:
            Dict mit pagination Info:
                - items: Liste von Objekten
                - total: Gesamtanzahl
                - page: Aktuelle Seite
                - per_page: Items pro Seite
                - pages: Gesamtanzahl Seiten
                - has_prev: Hat vorherige Seite?
                - has_next: Hat nächste Seite?
                
        Example:
            result = user_service.paginate(page=1, per_page=10, aktiv=True)
            users = result['items']
        """
        # Build query with filters
        query = self.model.query
        
        for key, value in filters.items():
            if value is not None and hasattr(self.model, key):
                query = query.filter_by(**{key: value})
        
        # Versuche Flask-SQLAlchemy pagination
        try:
            pagination = query.paginate(
                page=page,
                per_page=per_page,
                error_out=False
            )
            
            return {
                'items': pagination.items,
                'total': pagination.total,
                'page': pagination.page,
                'per_page': pagination.per_page,
                'pages': pagination.pages,
                'has_prev': pagination.has_prev,
                'has_next': pagination.has_next,
                'prev_num': pagination.prev_num,
                'next_num': pagination.next_num
            }
        except Exception as e:
            # FALLBACK: Manuelle Pagination wenn Flask-SQLAlchemy fehlschlägt
            current_app.logger.warning(f"Flask-SQLAlchemy pagination failed, using manual: {e}")
            
            # Get total count
            total = query.count()
            
            # Calculate pagination values
            pages = (total + per_page - 1) // per_page if per_page > 0 else 1
            page = max(1, min(page, pages))  # Ensure page is within valid range
            
            # Get items for current page
            offset = (page - 1) * per_page
            items = query.offset(offset).limit(per_page).all()
            
            return {
                'items': items,
                'total': total,
                'page': page,
                'per_page': per_page,
                'pages': pages,
                'has_prev': page > 1,
                'has_next': page < pages,
                'prev_num': page - 1 if page > 1 else None,
                'next_num': page + 1 if page < pages else None
            }
    
    def paginate_simple(self, page: int = 1, per_page: int = 20, **filters) -> Dict[str, Any]:
        """
        Einfache manuelle Pagination (Alternative zu paginate)
        
        Args:
            page: Seitennummer (1-basiert)
            per_page: Objekte pro Seite
            **filters: Filter
            
        Returns:
            Dict mit items, total, page, per_page
        """
        # Get all items with filters
        all_items = self.get_all(**filters)
        total = len(all_items)
        
        # Calculate pagination
        pages = (total + per_page - 1) // per_page if per_page > 0 else 1
        page = max(1, min(page, pages))
        
        # Slice items for current page
        start = (page - 1) * per_page
        end = start + per_page
        items = all_items[start:end]
        
        return {
            'items': items,
            'total': total,
            'page': page,
            'per_page': per_page,
            'pages': pages,
            'has_prev': page > 1,
            'has_next': page < pages
        }
    
    # =========================================================================
    # UTILITY METHODS
    # =========================================================================
    
    def to_dict(self, obj: BaseModel, exclude: List[str] = None) -> Dict[str, Any]:
        """
        Konvertiert Model zu Dictionary
        
        Args:
            obj: Model-Objekt
            exclude: Liste von Feldern die ausgeschlossen werden sollen
            
        Returns:
            Dictionary mit Model-Daten
            
        Example:
            user_dict = user_service.to_dict(user, exclude=['password_hash'])
        """
        if hasattr(obj, 'to_dict'):
            # Nutze Model's eigene to_dict Methode wenn vorhanden
            if exclude and hasattr(obj.to_dict, '__call__'):
                # Prüfe ob to_dict exclude parameter akzeptiert
                import inspect
                sig = inspect.signature(obj.to_dict)
                if 'exclude' in sig.parameters:
                    return obj.to_dict(exclude=exclude)
            return obj.to_dict()
        
        # Fallback: Manuell konvertieren
        data = {}
        for column in obj.__table__.columns:
            if exclude and column.name in exclude:
                continue
            data[column.name] = getattr(obj, column.name)
        return data
    
    def to_dict_list(self, objects: List[BaseModel], exclude: List[str] = None) -> List[Dict[str, Any]]:
        """
        Konvertiert Liste von Models zu Liste von Dicts
        
        Args:
            objects: Liste von Model-Objekten
            exclude: Liste von Feldern die ausgeschlossen werden sollen
            
        Returns:
            Liste von Dictionaries
            
        Example:
            users_data = user_service.to_dict_list(users, exclude=['password_hash'])
        """
        return [self.to_dict(obj, exclude) for obj in objects]
    
    def refresh(self, obj: BaseModel) -> BaseModel:
        """
        Lädt Objekt neu aus DB
        
        Args:
            obj: Model-Objekt
            
        Returns:
            Neu geladenes Objekt
        """
        db.session.refresh(obj)
        return obj
    
    def commit(self):
        """Committed aktuelle Session"""
        try:
            db.session.commit()
        except Exception as e:
            db.session.rollback()
            raise ValueError(f"Fehler beim Commit: {str(e)}")
    
    def rollback(self):
        """Rollt aktuelle Session zurück"""
        db.session.rollback()