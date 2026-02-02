"""
Base Model
==========
Gemeinsame Felder und Methoden für alle Models.
Implementiert DRY (Don't Repeat Yourself) Prinzip.
"""

from datetime import datetime
# db von extensions importieren, NICHT neu erstellen!
from app.extensions import db


class BaseModel(db.Model):
    """
    Abstract Base Model
    Alle Models erben von dieser Klasse und bekommen automatisch:
    - id (Primary Key)
    - created_at (Timestamp bei Erstellung)
    - updated_at (Timestamp bei jeder Änderung)
    """
    __abstract__ = True
    
    id = db.Column(db.Integer, primary_key=True)
    created_at = db.Column(
        db.DateTime,
        nullable=False,
        default=datetime.utcnow,
        server_default=db.func.current_timestamp()
    )
    updated_at = db.Column(
        db.DateTime,
        nullable=False,
        default=datetime.utcnow,
        onupdate=datetime.utcnow,
        server_default=db.func.current_timestamp()
    )
    
    def save(self):
        """Speichert das Model in der Datenbank"""
        db.session.add(self)
        db.session.commit()
        return self
    
    def delete(self):
        """Löscht das Model aus der Datenbank"""
        db.session.delete(self)
        db.session.commit()
    
    def update(self, **kwargs):
        """
        Updated das Model mit den übergebenen Attributen
        
        Usage:
            user.update(vorname='Max', nachname='Müller')
        """
        for key, value in kwargs.items():
            if hasattr(self, key):
                setattr(self, key, value)
        self.updated_at = datetime.utcnow()
        db.session.commit()
        return self
    
    def to_dict(self, exclude=None):
        """
        Konvertiert das Model zu einem Dictionary
        
        Args:
            exclude: Liste von Feldern die ausgeschlossen werden sollen
        
        Returns:
            dict: Model-Daten als Dictionary
        """
        exclude = exclude or []
        data = {}
        
        for column in self.__table__.columns:
            if column.name not in exclude:
                value = getattr(self, column.name)
                # DateTime zu ISO String konvertieren
                if isinstance(value, datetime):
                    data[column.name] = value.isoformat()
                else:
                    data[column.name] = value
        
        return data
    
    def __repr__(self):
        """String-Repräsentation für Debugging"""
        return f"<{self.__class__.__name__} {self.id}>"


class TimestampMixin:
    """
    Mixin für Timestamp-Felder
    Kann optional statt BaseModel verwendet werden
    """
    created_at = db.Column(
        db.DateTime,
        nullable=False,
        default=datetime.utcnow,
        server_default=db.func.current_timestamp()
    )
    updated_at = db.Column(
        db.DateTime,
        nullable=False,
        default=datetime.utcnow,
        onupdate=datetime.utcnow,
        server_default=db.func.current_timestamp()
    )