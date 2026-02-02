"""
Modul Audit Log Model
=====================
Protokolliert Änderungen an Modul-Dozenten-Zuordnungen durch den Dekan.

Feature 3: Modul-Verwaltung
"""

from datetime import datetime
from .base import db


class ModulAuditLog(db.Model):
    """
    Audit Log für Modul-Zuordnungsänderungen

    Protokolliert wann, wer, welche Änderung an Modul-Dozent-Zuordnungen gemacht hat.
    """
    __tablename__ = 'modul_audit_log'

    id = db.Column(db.Integer, primary_key=True)

    # Was wurde geändert?
    modul_id = db.Column(
        db.Integer,
        db.ForeignKey('modul.id', ondelete='CASCADE'),
        nullable=False,
        index=True
    )
    po_id = db.Column(
        db.Integer,
        db.ForeignKey('pruefungsordnung.id', ondelete='CASCADE'),
        nullable=False,
        index=True
    )

    # Wer hat geändert?
    geaendert_von = db.Column(
        db.Integer,
        db.ForeignKey('benutzer.id', ondelete='SET NULL'),
        nullable=True
    )

    # Änderungstyp
    aktion = db.Column(
        db.String(50),
        nullable=False
    )  # 'dozent_hinzugefuegt', 'dozent_entfernt', 'rolle_geaendert', etc.

    # Vorher / Nachher
    alt_dozent_id = db.Column(
        db.Integer,
        db.ForeignKey('dozent.id', ondelete='SET NULL'),
        nullable=True
    )
    neu_dozent_id = db.Column(
        db.Integer,
        db.ForeignKey('dozent.id', ondelete='SET NULL'),
        nullable=True
    )

    alte_rolle = db.Column(db.String(50), nullable=True)
    neue_rolle = db.Column(db.String(50), nullable=True)

    # Zusätzliche Infos
    bemerkung = db.Column(db.Text, nullable=True)

    # Wann?
    created_at = db.Column(
        db.DateTime,
        default=datetime.utcnow,
        nullable=False,
        index=True
    )

    # Relationships
    modul = db.relationship('Modul', backref='audit_logs')
    pruefungsordnung = db.relationship('Pruefungsordnung')
    geaendert_von_benutzer = db.relationship(
        'Benutzer',
        foreign_keys=[geaendert_von],
        backref='modul_aenderungen'
    )
    alter_dozent = db.relationship(
        'Dozent',
        foreign_keys=[alt_dozent_id],
        backref='modul_aenderungen_alt'
    )
    neuer_dozent = db.relationship(
        'Dozent',
        foreign_keys=[neu_dozent_id],
        backref='modul_aenderungen_neu'
    )

    __table_args__ = (
        db.Index('ix_modul_audit_modul_datum', 'modul_id', 'created_at'),
    )

    def __repr__(self):
        return f'<ModulAuditLog {self.id} - {self.aktion} @ {self.created_at}>'

    def to_dict(self):
        """Konvertiert zu Dictionary für API"""
        return {
            'id': self.id,
            'modul': {
                'id': self.modul.id,
                'kuerzel': self.modul.kuerzel,
                'bezeichnung_de': self.modul.bezeichnung_de
            } if self.modul else None,
            'aktion': self.aktion,
            'alter_dozent': {
                'id': self.alter_dozent.id,
                'name': self.alter_dozent.name_komplett
            } if self.alter_dozent else None,
            'neuer_dozent': {
                'id': self.neuer_dozent.id,
                'name': self.neuer_dozent.name_komplett
            } if self.neuer_dozent else None,
            'alte_rolle': self.alte_rolle,
            'neue_rolle': self.neue_rolle,
            'geaendert_von': {
                'id': self.geaendert_von_benutzer.id,
                'name': self.geaendert_von_benutzer.name_komplett
            } if self.geaendert_von_benutzer else None,
            'bemerkung': self.bemerkung,
            'created_at': self.created_at.isoformat()
        }

    @classmethod
    def log_dozent_hinzugefuegt(cls, modul_id, po_id, dozent_id, rolle, geaendert_von_id, bemerkung=None):
        """Protokolliert: Dozent zu Modul hinzugefügt"""
        log = cls(
            modul_id=modul_id,
            po_id=po_id,
            aktion='dozent_hinzugefuegt',
            neu_dozent_id=dozent_id,
            neue_rolle=rolle,
            geaendert_von=geaendert_von_id,
            bemerkung=bemerkung
        )
        db.session.add(log)
        return log

    @classmethod
    def log_dozent_entfernt(cls, modul_id, po_id, dozent_id, rolle, geaendert_von_id, bemerkung=None):
        """Protokolliert: Dozent von Modul entfernt"""
        log = cls(
            modul_id=modul_id,
            po_id=po_id,
            aktion='dozent_entfernt',
            alt_dozent_id=dozent_id,
            alte_rolle=rolle,
            geaendert_von=geaendert_von_id,
            bemerkung=bemerkung
        )
        db.session.add(log)
        return log

    @classmethod
    def log_dozent_ersetzt(cls, modul_id, po_id, alt_dozent_id, neu_dozent_id, rolle, geaendert_von_id, bemerkung=None):
        """Protokolliert: Dozent wurde durch anderen ersetzt"""
        log = cls(
            modul_id=modul_id,
            po_id=po_id,
            aktion='dozent_ersetzt',
            alt_dozent_id=alt_dozent_id,
            neu_dozent_id=neu_dozent_id,
            alte_rolle=rolle,
            neue_rolle=rolle,
            geaendert_von=geaendert_von_id,
            bemerkung=bemerkung
        )
        db.session.add(log)
        return log
