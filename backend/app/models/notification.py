"""
Notification Model
==================
Benachrichtigungen für Benutzer
"""

from datetime import datetime
from .base import db


class Benachrichtigung(db.Model):
    """Benachrichtigungen für Benutzer"""
    __tablename__ = 'benachrichtigung'
    
    id = db.Column(db.Integer, primary_key=True)
    empfaenger_id = db.Column(db.Integer, db.ForeignKey('benutzer.id', ondelete='CASCADE'), nullable=False, index=True)
    typ = db.Column(db.String(50), nullable=False)  # 'planung_freigegeben', 'erinnerung', etc.
    titel = db.Column(db.String(255), nullable=False)
    nachricht = db.Column(db.Text)
    gelesen = db.Column(db.Boolean, default=False, nullable=False, index=True)
    erstellt_am = db.Column(db.DateTime, default=datetime.utcnow, nullable=False)
    gelesen_am = db.Column(db.DateTime)
    
    # Relationships
    empfaenger = db.relationship('Benutzer', back_populates='benachrichtigungen')
    
    def __repr__(self):
        return f'<Benachrichtigung {self.titel}>'
    
    def markiere_gelesen(self):
        """Markiert Benachrichtigung als gelesen"""
        self.gelesen = True
        self.gelesen_am = datetime.utcnow()
        db.session.commit()
    
    def to_dict(self):
        return {
            'id': self.id,
            'typ': self.typ,
            'titel': self.titel,
            'nachricht': self.nachricht,
            'gelesen': self.gelesen,
            'erstellt_am': self.erstellt_am.isoformat()
        }