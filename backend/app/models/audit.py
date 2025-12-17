"""
Audit Log Model
===============
Protokollierung wichtiger Aktionen
"""

from datetime import datetime
from .base import db


class AuditLog(db.Model):
    """Audit-Log fÃ¼r wichtige Aktionen"""
    __tablename__ = 'audit_log'
    
    id = db.Column(db.Integer, primary_key=True)
    benutzer_id = db.Column(db.Integer, db.ForeignKey('benutzer.id', ondelete='SET NULL'), index=True)
    aktion = db.Column(db.String(100), nullable=False, index=True)
    tabelle = db.Column(db.String(50))
    datensatz_id = db.Column(db.Integer)
    alte_werte = db.Column(db.Text)  # JSON
    neue_werte = db.Column(db.Text)  # JSON
    ip_adresse = db.Column(db.String(50))
    timestamp = db.Column(db.DateTime, default=datetime.utcnow, nullable=False, index=True)
    
    # Relationships
    benutzer = db.relationship('Benutzer', back_populates='audit_logs')
    
    def __repr__(self):
        return f'<AuditLog {self.aktion} by {self.benutzer_id}>'
    
    def to_dict(self):
        return {
            'id': self.id,
            'benutzer': self.benutzer.username if self.benutzer else 'System',
            'aktion': self.aktion,
            'timestamp': self.timestamp.isoformat()
        }
    
    @classmethod
    def log(cls, benutzer_id, aktion, **kwargs):
        """Helper-Methode zum Erstellen eines Log-Eintrags"""
        log = cls(
            benutzer_id=benutzer_id,
            aktion=aktion,
            **kwargs
        )
        db.session.add(log)
        db.session.commit()
        return log