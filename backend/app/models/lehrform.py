"""
Lehrform Model
==============
Lehrformen (Vorlesung, Übung, Praktikum, etc.)
"""

from .base import db


class Lehrform(db.Model):
    """Lehrformen (V, Ü, P, S, etc.)"""
    __tablename__ = 'lehrform'
    
    id = db.Column(db.Integer, primary_key=True)
    bezeichnung = db.Column(db.String(50), nullable=False, unique=True)
    kuerzel = db.Column(db.String(10), unique=True)
    
    # Relationships
    modul_lehrformen = db.relationship('ModulLehrform', back_populates='lehrform', lazy='dynamic')
    
    def __repr__(self):
        return f'<Lehrform {self.bezeichnung} ({self.kuerzel})>'
    
    def __str__(self):
        return self.bezeichnung
    
    def to_dict(self):
        return {
            'id': self.id,
            'bezeichnung': self.bezeichnung,
            'kuerzel': self.kuerzel
        }