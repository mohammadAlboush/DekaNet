"""
Planungsphase Model
===================
Model für Planungsphasen-Verwaltung mit Archivierung
"""

from datetime import datetime
from sqlalchemy import func, and_, or_, text
from sqlalchemy.dialects.postgresql import JSONB
from app.extensions import db
from app.models.base import BaseModel


class Planungsphase(BaseModel):
    """
    Model für Planungsphasen
    Eine Phase ist ein Zeitraum, in dem Professoren ihre Planungen einreichen können
    """
    __tablename__ = 'planungsphasen'

    semester_id = db.Column(db.Integer, db.ForeignKey('semester.id', ondelete='CASCADE'), nullable=False)
    name = db.Column(db.String(255), nullable=False)
    startdatum = db.Column(db.DateTime, nullable=False, default=datetime.utcnow)
    enddatum = db.Column(db.DateTime, nullable=True)  # Optional deadline
    ist_aktiv = db.Column(db.Boolean, nullable=False, default=True)
    geschlossen_am = db.Column(db.DateTime, nullable=True)
    geschlossen_von = db.Column(db.Integer, db.ForeignKey('benutzer.id'), nullable=True)
    geschlossen_grund = db.Column(db.Text, nullable=True)

    # NEU: Strukturierte Semester-Info (zur Redundanz, falls Semester gelöscht wird)
    semester_typ = db.Column(db.String(20), nullable=True)  # 'wintersemester' | 'sommersemester'
    semester_jahr = db.Column(db.Integer, nullable=True)     # z.B. 2025

    # Statistik-Felder (werden automatisch aktualisiert)
    anzahl_einreichungen = db.Column(db.Integer, nullable=False, default=0)
    anzahl_genehmigt = db.Column(db.Integer, nullable=False, default=0)
    anzahl_abgelehnt = db.Column(db.Integer, nullable=False, default=0)

    # Relationships
    semester = db.relationship('Semester', backref='planungsphasen')
    geschlossen_von_user = db.relationship('Benutzer', foreign_keys=[geschlossen_von])
    submissions = db.relationship('PhaseSubmission', back_populates='phase', cascade='all, delete-orphan')
    archivierte_planungen = db.relationship('ArchiviertePlanung', back_populates='phase', cascade='all, delete-orphan')

    # Constraints
    __table_args__ = (
        db.CheckConstraint('enddatum IS NULL OR enddatum > startdatum', name='chk_dates'),
        # Partial unique index to ensure only one active phase per semester
        # This is created via migration, not through SQLAlchemy constraint
        # CREATE UNIQUE INDEX idx_unique_active_phase_per_semester ON planungsphasen (semester_id) WHERE ist_aktiv = 1
    )

    @classmethod
    def get_active_phase(cls):
        """Holt die aktive Planungsphase"""
        return cls.query.filter_by(ist_aktiv=True).first()

    @classmethod
    def start_phase(cls, semester_id, name, enddatum=None, user_id=None):
        """Startet eine neue Planungsphase"""
        # Schließe alle anderen aktiven Phasen für dieses Semester
        db.session.execute(
            text("""
                UPDATE planungsphasen
                SET ist_aktiv = false,
                    geschlossen_am = CURRENT_TIMESTAMP,
                    geschlossen_von = :user_id,
                    geschlossen_grund = 'Neue Phase gestartet'
                WHERE semester_id = :semester_id AND ist_aktiv = true
            """),
            {'user_id': user_id, 'semester_id': semester_id}
        )

        # Erstelle neue Phase
        new_phase = cls(
            semester_id=semester_id,
            name=name,
            startdatum=datetime.utcnow(),
            enddatum=enddatum,
            ist_aktiv=True
        )
        db.session.add(new_phase)
        db.session.commit()
        return new_phase

    def close_phase(self, user_id, archiviere_entwuerfe=False, grund=None):
        """Schließt diese Planungsphase mit Archivierung"""
        from app.models.planung import Semesterplanung

        # Archiviere alle eingereichten/genehmigten/abgelehnten Planungen
        planungen_to_archive = Semesterplanung.query.filter(
            Semesterplanung.semester_id == self.semester_id,
            Semesterplanung.status.in_(['eingereicht', 'freigegeben', 'abgelehnt'])
        ).all()

        archiviert_count = 0
        for planung in planungen_to_archive:
            ArchiviertePlanung.archive_planung(
                planung=planung,
                phase=self,
                archiviert_von=user_id,
                grund='phase_geschlossen'
            )
            archiviert_count += 1

        # Handle Entwürfe
        entwuerfe = Semesterplanung.query.filter(
            Semesterplanung.semester_id == self.semester_id,
            Semesterplanung.status == 'entwurf'
        ).all()

        geloescht_count = 0
        if archiviere_entwuerfe:
            # Archiviere Entwürfe
            for entwurf in entwuerfe:
                ArchiviertePlanung.archive_planung(
                    planung=entwurf,
                    phase=self,
                    archiviert_von=user_id,
                    grund='phase_geschlossen'
                )
                geloescht_count += 1
        else:
            # Lösche Entwürfe
            for entwurf in entwuerfe:
                db.session.delete(entwurf)
                geloescht_count += 1

        # Schließe die Phase
        self.ist_aktiv = False
        self.geschlossen_am = datetime.utcnow()
        self.geschlossen_von = user_id
        self.geschlossen_grund = grund or 'Manuell geschlossen'

        db.session.commit()

        return {
            'archivierte_planungen': archiviert_count,
            'geloeschte_entwuerfe': geloescht_count
        }

    def get_statistics(self):
        """Berechnet Statistiken für diese Phase"""
        from app.models.user import Benutzer
        from app.models.user import Rolle

        # Anzahl aller Professoren
        professor_roles = Rolle.query.filter(
            Rolle.name.in_(['professor', 'lehrbeauftragter'])
        ).all()
        professor_role_ids = [r.id for r in professor_roles]

        professoren_gesamt = Benutzer.query.filter(
            Benutzer.rolle_id.in_(professor_role_ids)
        ).count() if professor_role_ids else 0

        # Anzahl eingereichter Professoren
        professoren_eingereicht = db.session.query(func.count(func.distinct(PhaseSubmission.professor_id))).filter(
            PhaseSubmission.planungphase_id == self.id
        ).scalar() or 0

        # Berechne Quoten
        einreichungsquote = (professoren_eingereicht / professoren_gesamt * 100) if professoren_gesamt > 0 else 0
        genehmigungsquote = (self.anzahl_genehmigt / self.anzahl_einreichungen * 100) if self.anzahl_einreichungen > 0 else 0

        # Durchschnittliche Bearbeitungszeit
        avg_time = db.session.query(
            func.avg(func.extract('hour', PhaseSubmission.freigegeben_am - PhaseSubmission.eingereicht_am))
        ).filter(
            PhaseSubmission.planungphase_id == self.id,
            PhaseSubmission.freigegeben_am.isnot(None)
        ).scalar() or 0

        # Calculate duration in days
        dauer_tage = 0
        if self.startdatum:
            end_date = self.geschlossen_am or datetime.utcnow()
            dauer_tage = (end_date - self.startdatum).days

        return {
            'phase_id': self.id,
            'phase_name': self.name,
            'startdatum': self.startdatum,
            'enddatum': self.enddatum,
            'dauer_tage': dauer_tage,
            'professoren_gesamt': professoren_gesamt,
            'professoren_eingereicht': professoren_eingereicht,
            'einreichungsquote': round(einreichungsquote, 1),
            'genehmigungsquote': round(genehmigungsquote, 1),
            'durchschnittliche_bearbeitungszeit': round(avg_time, 1),
            'anzahl_einreichungen': self.anzahl_einreichungen,
            'anzahl_genehmigt': self.anzahl_genehmigt,
            'anzahl_abgelehnt': self.anzahl_abgelehnt
        }

    def to_dict(self):
        """Konvertiert zu Dictionary"""
        return {
            'id': self.id,
            'semester_id': self.semester_id,
            'name': self.name,
            'startdatum': self.startdatum.isoformat() if self.startdatum else None,
            'enddatum': self.enddatum.isoformat() if self.enddatum else None,
            'ist_aktiv': self.ist_aktiv,
            'geschlossen_am': self.geschlossen_am.isoformat() if self.geschlossen_am else None,
            'geschlossen_von': self.geschlossen_von,
            'geschlossen_grund': self.geschlossen_grund,
            'semester_typ': self.semester_typ,
            'semester_jahr': self.semester_jahr,
            'anzahl_einreichungen': self.anzahl_einreichungen,
            'anzahl_genehmigt': self.anzahl_genehmigt,
            'anzahl_abgelehnt': self.anzahl_abgelehnt,
            'created_at': self.created_at.isoformat(),
            'updated_at': self.updated_at.isoformat()
        }


class PhaseSubmission(BaseModel):
    """
    Model für Einreichungen in einer Planungsphase
    Trackt welcher Professor wann welche Planung eingereicht hat
    """
    __tablename__ = 'phase_submissions'

    planungphase_id = db.Column(db.Integer, db.ForeignKey('planungsphasen.id', ondelete='CASCADE'), nullable=False)
    professor_id = db.Column(db.Integer, db.ForeignKey('benutzer.id'), nullable=False)
    planung_id = db.Column(db.Integer, db.ForeignKey('semesterplanung.id', ondelete='CASCADE'), nullable=False)

    eingereicht_am = db.Column(db.DateTime, nullable=False, default=datetime.utcnow)
    status = db.Column(db.String(50), nullable=False, default='eingereicht')  # eingereicht, freigegeben, abgelehnt

    freigegeben_am = db.Column(db.DateTime, nullable=True)
    freigegeben_von = db.Column(db.Integer, db.ForeignKey('benutzer.id'), nullable=True)

    abgelehnt_am = db.Column(db.DateTime, nullable=True)
    abgelehnt_von = db.Column(db.Integer, db.ForeignKey('benutzer.id'), nullable=True)
    abgelehnt_grund = db.Column(db.Text, nullable=True)

    # Relationships
    phase = db.relationship('Planungsphase', back_populates='submissions')
    professor = db.relationship('Benutzer', foreign_keys=[professor_id], backref='phase_submissions')
    planung = db.relationship('Semesterplanung', backref='phase_submission')
    freigebender = db.relationship('Benutzer', foreign_keys=[freigegeben_von])
    ablehnender = db.relationship('Benutzer', foreign_keys=[abgelehnt_von])

    # Constraint: Ein Professor kann pro Phase nur eine genehmigte Planung haben
    __table_args__ = (
        db.UniqueConstraint('planungphase_id', 'professor_id', 'status', name='unique_professor_phase_approved'),
    )

    @classmethod
    def record_submission(cls, planungphase_id, professor_id, planung_id):
        """Zeichnet eine Einreichung auf"""
        # Prüfe ob bereits eine Einreichung existiert
        existing = cls.query.filter_by(
            planungphase_id=planungphase_id,
            professor_id=professor_id,
            status='eingereicht'
        ).first()

        if existing:
            # Update existing submission
            existing.planung_id = planung_id
            existing.eingereicht_am = datetime.utcnow()
        else:
            # Create new submission
            submission = cls(
                planungphase_id=planungphase_id,
                professor_id=professor_id,
                planung_id=planung_id,
                status='eingereicht'
            )
            db.session.add(submission)

        # Update phase counter
        phase = Planungsphase.query.get(planungphase_id)
        if phase:
            # Update submission counter
            phase.anzahl_einreichungen = db.session.query(func.count(cls.id)).filter(
                cls.planungphase_id == planungphase_id
            ).scalar() or 0

        db.session.commit()
        return existing or submission

    def approve(self, user_id):
        """Genehmigt diese Einreichung"""
        self.status = 'freigegeben'
        self.freigegeben_am = datetime.utcnow()
        self.freigegeben_von = user_id

        # Update phase statistics
        self.phase.anzahl_genehmigt += 1

        db.session.commit()

    def reject(self, user_id, grund=None):
        """Lehnt diese Einreichung ab"""
        self.status = 'abgelehnt'
        self.abgelehnt_am = datetime.utcnow()
        self.abgelehnt_von = user_id
        self.abgelehnt_grund = grund

        # Update phase statistics
        self.phase.anzahl_abgelehnt += 1

        db.session.commit()

    def to_dict(self):
        """Konvertiert zu Dictionary"""
        return {
            'id': self.id,
            'planungphase_id': self.planungphase_id,
            'professor_id': self.professor_id,
            'professor_name': f"{self.professor.vorname} {self.professor.nachname}" if self.professor else None,
            'planung_id': self.planung_id,
            'eingereicht_am': self.eingereicht_am.isoformat(),
            'status': self.status,
            'freigegeben_am': self.freigegeben_am.isoformat() if self.freigegeben_am else None,
            'freigegeben_von': self.freigegeben_von,
            'abgelehnt_am': self.abgelehnt_am.isoformat() if self.abgelehnt_am else None,
            'abgelehnt_von': self.abgelehnt_von,
            'abgelehnt_grund': self.abgelehnt_grund
        }


class ArchiviertePlanung(BaseModel):
    """
    Model für archivierte Planungen
    Speichert komplette Planungsdaten als JSONB für historische Zwecke
    """
    __tablename__ = 'archivierte_planungen'

    original_planung_id = db.Column(db.Integer, nullable=False)
    planungphase_id = db.Column(db.Integer, db.ForeignKey('planungsphasen.id'), nullable=False)
    professor_id = db.Column(db.Integer, db.ForeignKey('benutzer.id'), nullable=False)
    professor_name = db.Column(db.String(255), nullable=False)
    semester_id = db.Column(db.Integer, db.ForeignKey('semester.id'), nullable=False)
    semester_name = db.Column(db.String(255), nullable=False)
    phase_name = db.Column(db.String(255), nullable=False)

    status_bei_archivierung = db.Column(db.String(50), nullable=False)
    archiviert_am = db.Column(db.DateTime, nullable=False, default=datetime.utcnow)
    archiviert_grund = db.Column(db.String(50), nullable=False)  # phase_geschlossen, manuell, system
    archiviert_von = db.Column(db.Integer, db.ForeignKey('benutzer.id'), nullable=True)

    # Komplette Planungsdaten als JSON
    planung_daten = db.Column(JSONB, nullable=False)

    # Relationships
    phase = db.relationship('Planungsphase', back_populates='archivierte_planungen')
    professor = db.relationship('Benutzer', foreign_keys=[professor_id])
    archivierer = db.relationship('Benutzer', foreign_keys=[archiviert_von])
    semester = db.relationship('Semester')

    @classmethod
    def archive_planung(cls, planung, phase, archiviert_von, grund='manuell'):
        """Archiviert eine Planung"""
        from app.models.user import Benutzer
        from app.models.semester import Semester

        professor = Benutzer.query.get(planung.benutzer_id)
        semester = Semester.query.get(planung.semester_id)

        # Sammle alle Planungsdaten
        planung_data = {
            'id': planung.id,
            'dozent_id': planung.benutzer_id,
            'semester_id': planung.semester_id,
            'status': planung.status,
            'gesamt_sws': planung.gesamt_sws,
            'anmerkungen': planung.anmerkungen,
            'created_at': planung.created_at.isoformat(),
            'updated_at': planung.updated_at.isoformat(),
            'geplante_module': []
        }

        # Füge geplante Module hinzu
        for modul in planung.geplante_module:
            planung_data['geplante_module'].append({
                'modul_id': modul.modul_id,
                'modul_name': modul.modul.bezeichnung_de if modul.modul else None,
                'multiplikator_vorlesung': modul.anzahl_vorlesungen,
                'multiplikator_seminar': modul.anzahl_seminare,
                'multiplikator_uebung': modul.anzahl_uebungen,
                'multiplikator_praktikum': modul.anzahl_praktika,
                'berechnete_sws': modul.sws_gesamt
            })

        # Erstelle Archiveintrag
        archived = cls(
            original_planung_id=planung.id,
            planungphase_id=phase.id,
            professor_id=planung.benutzer_id,
            professor_name=f"{professor.vorname} {professor.nachname}" if professor else "Unbekannt",
            semester_id=planung.semester_id,
            semester_name=semester.bezeichnung if semester else "Unbekannt",
            phase_name=phase.name,
            status_bei_archivierung=planung.status,
            archiviert_grund=grund,
            archiviert_von=archiviert_von,
            planung_daten=planung_data
        )

        db.session.add(archived)
        db.session.commit()

        return archived

    def restore(self, restored_by):
        """Stellt eine archivierte Planung wieder her"""
        from app.models.planung import Semesterplanung, GeplantesModul

        # Erstelle neue Planung aus archivierten Daten
        data = self.planung_daten

        new_planung = Semesterplanung(
            dozent_id=self.professor_id,
            semester_id=self.semester_id,
            status='entwurf',  # Immer als Entwurf wiederherstellen
            gesamt_sws=data.get('gesamt_sws', 0),
            notizen=data.get('notizen', '')
        )
        db.session.add(new_planung)
        db.session.flush()  # Get ID for foreign keys

        # Stelle Module wieder her
        for modul_data in data.get('geplante_module', []):
            geplantes_modul = GeplantesModul(
                planung_id=new_planung.id,
                modul_id=modul_data['modul_id'],
                multiplikator_vorlesung=modul_data.get('multiplikator_vorlesung', 1),
                multiplikator_seminar=modul_data.get('multiplikator_seminar', 1),
                multiplikator_uebung=modul_data.get('multiplikator_uebung', 1),
                multiplikator_praktikum=modul_data.get('multiplikator_praktikum', 1),
                berechnete_sws=modul_data.get('berechnete_sws', 0)
            )
            db.session.add(geplantes_modul)

        # Lösche Archiveintrag
        db.session.delete(self)
        db.session.commit()

        return new_planung

    @classmethod
    def get_filtered(cls, filter_dict):
        """Holt gefilterte archivierte Planungen"""
        query = cls.query

        if filter_dict.get('planungphase_id'):
            query = query.filter_by(planungphase_id=filter_dict['planungphase_id'])

        if filter_dict.get('professor_id'):
            query = query.filter_by(professor_id=filter_dict['professor_id'])

        if filter_dict.get('semester_id'):
            query = query.filter_by(semester_id=filter_dict['semester_id'])

        if filter_dict.get('status'):
            query = query.filter_by(status_bei_archivierung=filter_dict['status'])

        if filter_dict.get('von_datum'):
            query = query.filter(cls.archiviert_am >= filter_dict['von_datum'])

        if filter_dict.get('bis_datum'):
            query = query.filter(cls.archiviert_am <= filter_dict['bis_datum'])

        # Pagination
        limit = filter_dict.get('limit', 50)
        offset = filter_dict.get('offset', 0)

        total = query.count()
        planungen = query.order_by(cls.archiviert_am.desc()).limit(limit).offset(offset).all()

        return {
            'planungen': [p.to_dict() for p in planungen],
            'total': total,
            'pages': (total + limit - 1) // limit  # Ceiling division
        }

    def to_dict(self):
        """Konvertiert zu Dictionary"""
        return {
            'id': self.id,
            'original_planung_id': self.original_planung_id,
            'planungphase_id': self.planungphase_id,
            'professor_id': self.professor_id,
            'professor_name': self.professor_name,
            'semester_id': self.semester_id,
            'semester_name': self.semester_name,
            'phase_name': self.phase_name,
            'status_bei_archivierung': self.status_bei_archivierung,
            'archiviert_am': self.archiviert_am.isoformat(),
            'archiviert_grund': self.archiviert_grund,
            'archiviert_von': self.archiviert_von,
            'planung_daten': self.planung_daten,
            'created_at': self.created_at.isoformat()
        }


# Update Planungsphase statistics
def update_phase_statistics(phase_id):
    """Helper function to update phase statistics"""
    phase = Planungsphase.query.get(phase_id)
    if not phase:
        return

    # Count submissions by status
    submissions = PhaseSubmission.query.filter_by(planungphase_id=phase_id).all()

    phase.anzahl_einreichungen = len(submissions)
    phase.anzahl_genehmigt = len([s for s in submissions if s.status == 'freigegeben'])
    phase.anzahl_abgelehnt = len([s for s in submissions if s.status == 'abgelehnt'])

    db.session.commit()