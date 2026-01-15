"""
Auftrag Models
==============

Feature 2: Semesteraufträge (Dekanin, Prodekan, etc.)

Tables:
- Auftrag: Master-Liste aller verfügbaren Aufträge
- SemesterAuftrag: Zuordnung Auftrag → Dozent pro Semester (mit Workflow)

Workflow:
- Professor beantragt Auftrag in Semesterplanung
- Status: beantragt → genehmigt/abgelehnt (durch Dekan)
- SWS fließt automatisch in Gesamt-SWS der Planung ein
"""

from datetime import datetime
from .base import db


class Auftrag(db.Model):
    """
    Master-Liste aller verfügbaren Aufträge

    Beispiele:
    - Dekanin (5.0 SWS)
    - Prodekan (4.5 SWS)
    - Studiengangsbeauftragter (0.5 SWS)
    - Marketing (2.0 SWS)

    Attributes:
        name: Eindeutiger Name des Auftrags
        beschreibung: Kurze Beschreibung der Aufgaben
        standard_sws: Standard-SWS für diesen Auftrag (kann pro Semester angepasst werden)
        ist_aktiv: Ob dieser Auftrag aktuell vergeben werden kann
        sortierung: Reihenfolge in Auswahl-Listen
    """
    __tablename__ = 'auftrag'

    id = db.Column(db.Integer, primary_key=True)
    name = db.Column(db.String(100), nullable=False, unique=True, index=True)
    beschreibung = db.Column(db.Text, nullable=True)
    standard_sws = db.Column(db.Float, nullable=False, default=0.0)
    ist_aktiv = db.Column(db.Boolean, nullable=False, default=True)
    sortierung = db.Column(db.Integer, nullable=True)

    # Timestamps
    created_at = db.Column(db.DateTime, default=datetime.utcnow, nullable=False)
    updated_at = db.Column(db.DateTime, default=datetime.utcnow, onupdate=datetime.utcnow, nullable=False)

    # Relationships
    semester_zuordnungen = db.relationship(
        'SemesterAuftrag',
        back_populates='auftrag',
        lazy='dynamic',
        cascade='all, delete-orphan'
    )

    def __repr__(self):
        return f'<Auftrag {self.name} ({self.standard_sws} SWS)>'

    def to_dict(self):
        """Konvertiert zu Dictionary"""
        return {
            'id': self.id,
            'name': self.name,
            'beschreibung': self.beschreibung,
            'standard_sws': self.standard_sws,
            'ist_aktiv': self.ist_aktiv,
            'sortierung': self.sortierung
        }


class SemesterAuftrag(db.Model):
    """
    Zuordnung: Auftrag → Dozent pro Semester

    Workflow:
    1. Professor beantragt Auftrag in Semesterplanung
    2. Status: 'beantragt'
    3. Dekan genehmigt/ablehnt
    4. Bei Genehmigung: Status = 'genehmigt', SWS fließt in Planung ein

    Mehrfach-Zuordnungen:
    - Ein Auftrag kann mehreren Dozenten zugeordnet werden
    - Ein Dozent kann mehrere Aufträge haben
    - Historisierung: Pro Semester können unterschiedliche Dozenten denselben Auftrag haben

    Attributes:
        semester_id: Semester
        auftrag_id: Auftrag (Master-Liste)
        dozent_id: Dozent dem zugeordnet
        sws: Tatsächliche SWS (kann vom standard_sws abweichen)
        status: 'beantragt', 'genehmigt', 'abgelehnt'
        beantragt_von: User der beantragt hat (Professor selbst)
        genehmigt_von: User der genehmigt/abgelehnt hat (Dekan)
        genehmigt_am: Zeitstempel der Genehmigung
        anmerkung: Notizen/Begründung
    """
    __tablename__ = 'semester_auftrag'

    id = db.Column(db.Integer, primary_key=True)

    # Foreign Keys
    semester_id = db.Column(
        db.Integer,
        db.ForeignKey('semester.id', ondelete='CASCADE'),
        nullable=False,
        index=True
    )
    auftrag_id = db.Column(
        db.Integer,
        db.ForeignKey('auftrag.id', ondelete='CASCADE'),
        nullable=False,
        index=True
    )
    dozent_id = db.Column(
        db.Integer,
        db.ForeignKey('dozent.id', ondelete='CASCADE'),
        nullable=False,
        index=True
    )

    # Auftrag-Details
    sws = db.Column(db.Float, nullable=False, default=0.0)
    status = db.Column(
        db.String(20),
        nullable=False,
        default='beantragt'
    )  # 'beantragt', 'genehmigt', 'abgelehnt'

    # Workflow-Tracking
    beantragt_von = db.Column(
        db.Integer,
        db.ForeignKey('benutzer.id', ondelete='SET NULL'),
        nullable=True
    )
    genehmigt_von = db.Column(
        db.Integer,
        db.ForeignKey('benutzer.id', ondelete='SET NULL'),
        nullable=True
    )
    genehmigt_am = db.Column(db.DateTime, nullable=True)
    anmerkung = db.Column(db.Text, nullable=True)

    # Timestamps
    created_at = db.Column(db.DateTime, default=datetime.utcnow, nullable=False)
    updated_at = db.Column(db.DateTime, default=datetime.utcnow, onupdate=datetime.utcnow, nullable=False)

    # Relationships
    semester = db.relationship('Semester')
    auftrag = db.relationship('Auftrag', back_populates='semester_zuordnungen')
    dozent = db.relationship('Dozent', back_populates='semester_auftraege')
    beantragt_von_user = db.relationship('Benutzer', foreign_keys=[beantragt_von])
    genehmigt_von_user = db.relationship('Benutzer', foreign_keys=[genehmigt_von])

    # Constraints
    __table_args__ = (
        db.Index('ix_semester_auftrag_semester', 'semester_id'),
        db.Index('ix_semester_auftrag_dozent', 'dozent_id'),
        db.Index('ix_semester_auftrag_status', 'status'),
        # Ein Dozent kann denselben Auftrag pro Semester nur einmal haben
        db.Index(
            'ix_semester_auftrag_unique',
            'semester_id',
            'auftrag_id',
            'dozent_id',
            unique=True
        ),
    )

    def __repr__(self):
        return f'<SemesterAuftrag {self.auftrag.name if self.auftrag else "?"} - {self.dozent.name_komplett if self.dozent else "?"} ({self.sws} SWS)>'

    def genehmigen(self, genehmigt_von_id: int):
        """Genehmigt den Auftrag"""
        self.status = 'genehmigt'
        self.genehmigt_von = genehmigt_von_id
        self.genehmigt_am = datetime.utcnow()

    def ablehnen(self, genehmigt_von_id: int, grund: str = None):
        """Lehnt den Auftrag ab"""
        self.status = 'abgelehnt'
        self.genehmigt_von = genehmigt_von_id
        self.genehmigt_am = datetime.utcnow()
        if grund:
            self.anmerkung = grund

    def to_dict(self, include_details=False):
        """Konvertiert zu Dictionary"""
        data = {
            'id': self.id,
            'semester_id': self.semester_id,
            'auftrag_id': self.auftrag_id,
            'dozent_id': self.dozent_id,
            'sws': self.sws,
            'status': self.status,
            'anmerkung': self.anmerkung,
            'created_at': self.created_at.isoformat() if self.created_at else None,
            'genehmigt_am': self.genehmigt_am.isoformat() if self.genehmigt_am else None,
        }

        if include_details:
            if self.auftrag:
                data['auftrag'] = self.auftrag.to_dict()
            if self.dozent:
                data['dozent'] = {
                    'id': self.dozent.id,
                    'name': self.dozent.name_komplett
                }
            if self.semester:
                data['semester'] = {
                    'id': self.semester.id,
                    'kuerzel': self.semester.kuerzel,
                    'bezeichnung': self.semester.bezeichnung
                }
            if self.beantragt_von_user:
                data['beantragt_von'] = {
                    'id': self.beantragt_von_user.id,
                    'name': self.beantragt_von_user.username
                }
            if self.genehmigt_von_user:
                data['genehmigt_von'] = {
                    'id': self.genehmigt_von_user.id,
                    'name': self.genehmigt_von_user.username
                }

        return data
