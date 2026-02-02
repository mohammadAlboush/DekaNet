"""
Sprache Model
=============
Sprachen für Module (Deutsch, Englisch, etc.)
"""

from .base import db


class Sprache(db.Model):
    """Sprachen (3 Einträge: Deutsch, Englisch, etc.)"""
    __tablename__ = 'sprache'
    
    id = db.Column(db.Integer, primary_key=True)
    bezeichnung = db.Column(db.String(50), nullable=False, unique=True)
    iso_code = db.Column(db.String(5), unique=True)  # 'de', 'en'
    
    # Relationships
    modul_sprachen = db.relationship('ModulSprache', back_populates='sprache', lazy='dynamic')
    
    def __repr__(self):
        return f'<Sprache {self.bezeichnung}>'
    
    def __str__(self):
        return self.bezeichnung
    
    def to_dict(self):
        return {
            'id': self.id,
            'bezeichnung': self.bezeichnung,
            'iso_code': self.iso_code
        }