"""
PlanungsTemplate Model
======================

Feature: Template-System für Semesterplanung

Ermöglicht Professoren, Standard-Module-Konfigurationen für
Winter- und Sommersemester zu speichern und beim Start einer
neuen Planungsphase automatisch zu laden.

Models:
- PlanungsTemplate: Haupttabelle (ein Template pro Benutzer + Semestertyp)
- TemplateModul: Module innerhalb eines Templates
"""

from datetime import datetime
import json
from typing import Dict, Any, List, Optional
from app.extensions import db


class PlanungsTemplate(db.Model):
    """
    PlanungsTemplate - Speichert Modul-Konfigurationen als Vorlage

    Ein Professor kann je ein Template pro Semestertyp (Winter/Sommer) haben.
    Templates enthalten Module mit Multiplikatoren, die beim Start einer
    neuen Planung automatisch geladen werden können.

    Attributes:
        benutzer_id: Foreign Key zu Benutzer (Professor)
        semester_typ: 'winter' oder 'sommer'
        name: Optionaler Name des Templates
        beschreibung: Optionale Beschreibung
        ist_aktiv: Ob das Template als Standard verwendet wird
    """
    __tablename__ = 'planungs_templates'

    id = db.Column(db.Integer, primary_key=True)

    # Verknüpfung zum Benutzer
    benutzer_id = db.Column(
        db.Integer,
        db.ForeignKey('benutzer.id', ondelete='CASCADE'),
        nullable=False,
        index=True
    )

    # Semestertyp: 'winter' oder 'sommer'
    semester_typ = db.Column(
        db.String(20),
        nullable=False,
        index=True
    )

    # Template-Metadaten
    name = db.Column(db.String(100), nullable=True)
    beschreibung = db.Column(db.Text, nullable=True)

    # Aktivstatus - wenn True, wird dieses Template automatisch vorgeschlagen
    ist_aktiv = db.Column(db.Boolean, default=True, nullable=False)

    # Wunsch-freie Tage als JSON (wird auch im Template gespeichert)
    _wunsch_freie_tage = db.Column('wunsch_freie_tage', db.Text, nullable=True)

    # Anmerkungen und Raumbedarf
    anmerkungen = db.Column(db.Text, nullable=True)
    raumbedarf = db.Column(db.Text, nullable=True)

    # Audit
    created_at = db.Column(db.DateTime, default=datetime.utcnow, nullable=False)
    updated_at = db.Column(
        db.DateTime,
        default=datetime.utcnow,
        onupdate=datetime.utcnow,
        nullable=False
    )

    # Relationships
    benutzer = db.relationship(
        'Benutzer',
        foreign_keys=[benutzer_id],
        backref=db.backref('planungs_templates', lazy='dynamic')
    )

    # Template-Module - lazy='selectin' für optimierte Batch-Queries
    template_module = db.relationship(
        'TemplateModul',
        back_populates='template',
        cascade='all, delete-orphan',
        lazy='selectin'
    )

    # UNIQUE Constraint: Ein Benutzer kann nur EIN Template pro Semestertyp haben
    __table_args__ = (
        db.UniqueConstraint(
            'benutzer_id',
            'semester_typ',
            name='uq_template_benutzer_semestertyp'
        ),
        db.Index('ix_template_benutzer_aktiv', 'benutzer_id', 'ist_aktiv'),
    )

    # Konstanten
    SEMESTER_TYPEN = ['winter', 'sommer']

    def __repr__(self):
        return f'<PlanungsTemplate {self.id} - {self.benutzer.username if self.benutzer else "?"} - {self.semester_typ}>'

    # =========================================================================
    # WUNSCH-FREIE TAGE JSON HANDLING
    # =========================================================================

    @property
    def wunsch_freie_tage(self) -> List[Dict[str, Any]]:
        """Gibt Liste von Wunsch-freien Tagen zurück"""
        if self._wunsch_freie_tage:
            try:
                return json.loads(self._wunsch_freie_tage)
            except (json.JSONDecodeError, TypeError):
                return []
        return []

    @wunsch_freie_tage.setter
    def wunsch_freie_tage(self, value: List[Dict[str, Any]]):
        """Setzt Wunsch-freie Tage als JSON"""
        if value:
            self._wunsch_freie_tage = json.dumps(value, ensure_ascii=False)
        else:
            self._wunsch_freie_tage = None

    # =========================================================================
    # CLASS METHODS
    # =========================================================================

    @classmethod
    def get_for_user(cls, benutzer_id: int, semester_typ: str = None) -> Optional['PlanungsTemplate']:
        """
        Holt das aktive Template für einen Benutzer.

        Args:
            benutzer_id: ID des Benutzers
            semester_typ: Optional 'winter' oder 'sommer'

        Returns:
            PlanungsTemplate oder None
        """
        query = cls.query.filter_by(benutzer_id=benutzer_id, ist_aktiv=True)

        if semester_typ:
            query = query.filter_by(semester_typ=semester_typ.lower())

        return query.first()

    @classmethod
    def get_all_for_user(cls, benutzer_id: int) -> List['PlanungsTemplate']:
        """
        Holt alle Templates für einen Benutzer.

        Args:
            benutzer_id: ID des Benutzers

        Returns:
            Liste von PlanungsTemplates
        """
        # Wegen lazy='dynamic' auf template_module können wir kein eager loading nutzen
        # Die Module werden bei to_dict() geladen
        return cls.query.filter_by(benutzer_id=benutzer_id).order_by(cls.semester_typ).all()

    @classmethod
    def get_or_create(cls, benutzer_id: int, semester_typ: str) -> tuple:
        """
        Holt existierendes Template oder erstellt neues.

        Args:
            benutzer_id: ID des Benutzers
            semester_typ: 'winter' oder 'sommer'

        Returns:
            tuple: (PlanungsTemplate, created: bool)
        """
        semester_typ = semester_typ.lower()
        if semester_typ not in cls.SEMESTER_TYPEN:
            raise ValueError(f"Ungültiger Semestertyp: {semester_typ}")

        template = cls.query.filter_by(
            benutzer_id=benutzer_id,
            semester_typ=semester_typ
        ).first()

        if template:
            return template, False

        template = cls(
            benutzer_id=benutzer_id,
            semester_typ=semester_typ,
            name=f"{'Winter' if semester_typ == 'winter' else 'Sommer'}semester Template",
            ist_aktiv=True
        )
        db.session.add(template)
        db.session.commit()

        return template, True

    # =========================================================================
    # TEMPLATE OPERATIONS
    # =========================================================================

    def add_modul(
        self,
        modul_id: int,
        po_id: int,
        anzahl_vorlesungen: int = 0,
        anzahl_uebungen: int = 0,
        anzahl_praktika: int = 0,
        anzahl_seminare: int = 0,
        **kwargs
    ) -> 'TemplateModul':
        """
        Fügt ein Modul zum Template hinzu.

        Args:
            modul_id: ID des Moduls
            po_id: ID der Prüfungsordnung
            anzahl_vorlesungen: Anzahl Vorlesungen
            anzahl_uebungen: Anzahl Übungen
            anzahl_praktika: Anzahl Praktika
            anzahl_seminare: Anzahl Seminare
            **kwargs: Weitere Felder

        Returns:
            TemplateModul
        """
        # Prüfe ob Modul bereits existiert
        existing = TemplateModul.query.filter_by(template_id=self.id, modul_id=modul_id).first()
        if existing:
            raise ValueError(f"Modul {modul_id} ist bereits im Template")

        template_modul = TemplateModul(
            template_id=self.id,
            modul_id=modul_id,
            po_id=po_id,
            anzahl_vorlesungen=anzahl_vorlesungen,
            anzahl_uebungen=anzahl_uebungen,
            anzahl_praktika=anzahl_praktika,
            anzahl_seminare=anzahl_seminare,
            **kwargs
        )

        db.session.add(template_modul)
        db.session.commit()

        return template_modul

    def remove_modul(self, modul_id: int) -> bool:
        """
        Entfernt ein Modul aus dem Template.

        Args:
            modul_id: ID des Moduls

        Returns:
            bool: True wenn erfolgreich
        """
        template_modul = TemplateModul.query.filter_by(template_id=self.id, modul_id=modul_id).first()
        if template_modul:
            db.session.delete(template_modul)
            db.session.commit()
            return True
        return False

    def clear_module(self):
        """Entfernt alle Module aus dem Template."""
        TemplateModul.query.filter_by(template_id=self.id).delete()
        db.session.commit()

    def update_from_planung(self, semesterplanung: 'Semesterplanung') -> int:
        """
        Aktualisiert Template mit Daten aus einer bestehenden Semesterplanung.
        Überschreibt alle bestehenden Module.

        Args:
            semesterplanung: Die Semesterplanung als Vorlage

        Returns:
            int: Anzahl der übernommenen Module
        """
        # Alle bestehenden Module löschen
        self.clear_module()

        # Wunsch-freie Tage übernehmen
        wunsch_tage = []
        for tag in semesterplanung.wunsch_freie_tage:
            wunsch_tage.append({
                'wochentag': tag.wochentag,
                'zeitraum': tag.zeitraum,
                'prioritaet': tag.prioritaet,
                'grund': tag.grund_text
            })
        self.wunsch_freie_tage = wunsch_tage

        # Anmerkungen und Raumbedarf übernehmen
        self.anmerkungen = semesterplanung.anmerkungen
        self.raumbedarf = semesterplanung.raumbedarf

        # Module übernehmen
        count = 0
        for geplantes_modul in semesterplanung.geplante_module:
            template_modul = TemplateModul(
                template_id=self.id,
                modul_id=geplantes_modul.modul_id,
                po_id=geplantes_modul.po_id,
                anzahl_vorlesungen=geplantes_modul.anzahl_vorlesungen,
                anzahl_uebungen=geplantes_modul.anzahl_uebungen,
                anzahl_praktika=geplantes_modul.anzahl_praktika,
                anzahl_seminare=geplantes_modul.anzahl_seminare,
                mitarbeiter_ids=geplantes_modul.mitarbeiter_ids,
                anmerkungen=geplantes_modul.anmerkungen,
                raumbedarf=geplantes_modul.raumbedarf,
                raum_vorlesung=geplantes_modul.raum_vorlesung,
                raum_uebung=geplantes_modul.raum_uebung,
                raum_praktikum=geplantes_modul.raum_praktikum,
                raum_seminar=geplantes_modul.raum_seminar,
                kapazitaet_vorlesung=geplantes_modul.kapazitaet_vorlesung,
                kapazitaet_uebung=geplantes_modul.kapazitaet_uebung,
                kapazitaet_praktikum=geplantes_modul.kapazitaet_praktikum,
                kapazitaet_seminar=geplantes_modul.kapazitaet_seminar,
            )
            db.session.add(template_modul)
            count += 1

        db.session.commit()
        return count

    # =========================================================================
    # SERIALISIERUNG
    # =========================================================================

    def to_dict(self, include_module: bool = False) -> Dict[str, Any]:
        """
        Konvertiert zu Dictionary (für API).

        Args:
            include_module: Sollen alle Module inkludiert werden?
        """
        # Mit lazy='selectin' ist template_module eine Liste
        module_list = self.template_module if self.template_module else []
        anzahl_module = len(module_list)

        data = {
            'id': self.id,
            'benutzer_id': self.benutzer_id,
            'semester_typ': self.semester_typ,
            'name': self.name,
            'beschreibung': self.beschreibung,
            'ist_aktiv': self.ist_aktiv,
            'wunsch_freie_tage': self.wunsch_freie_tage,
            'anmerkungen': self.anmerkungen,
            'raumbedarf': self.raumbedarf,
            'anzahl_module': anzahl_module,
            'created_at': self.created_at.isoformat() if self.created_at else None,
            'updated_at': self.updated_at.isoformat() if self.updated_at else None,
        }

        # Benutzer-Info
        if self.benutzer:
            data['benutzer'] = {
                'id': self.benutzer.id,
                'username': self.benutzer.username,
                'name_komplett': self.benutzer.name_komplett
            }

        if include_module:
            data['template_module'] = [m.to_dict() for m in module_list]

        return data


class TemplateModul(db.Model):
    """
    TemplateModul - Ein Modul innerhalb eines Templates

    Speichert die Modul-Konfiguration (Multiplikatoren, Räume, etc.)
    die beim Laden des Templates auf die Semesterplanung übertragen wird.

    Attributes:
        template_id: Foreign Key zu PlanungsTemplate
        modul_id: Foreign Key zu Modul
        po_id: Foreign Key zu Pruefungsordnung
        anzahl_*: Multiplikatoren für Lehrformen
        raum_*: Raum-Präferenzen pro Lehrform
        kapazitaet_*: Kapazitäts-Anforderungen pro Lehrform
    """
    __tablename__ = 'template_module'

    id = db.Column(db.Integer, primary_key=True)

    # Verknüpfungen
    template_id = db.Column(
        db.Integer,
        db.ForeignKey('planungs_templates.id', ondelete='CASCADE'),
        nullable=False,
        index=True
    )
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
        index=True  # Performance: Index für Filterung nach PO
    )

    # MULTIPLIKATOREN
    anzahl_vorlesungen = db.Column(db.Integer, default=0, nullable=False)
    anzahl_uebungen = db.Column(db.Integer, default=0, nullable=False)
    anzahl_praktika = db.Column(db.Integer, default=0, nullable=False)
    anzahl_seminare = db.Column(db.Integer, default=0, nullable=False)

    # MITARBEITER (JSON Array von dozent_ids)
    _mitarbeiter_ids = db.Column('mitarbeiter_ids', db.Text, nullable=True)

    # ZUSÄTZLICHE INFOS
    anmerkungen = db.Column(db.Text, nullable=True)
    raumbedarf = db.Column(db.Text, nullable=True)

    # RAUMPLANUNG PRO LEHRFORM
    raum_vorlesung = db.Column(db.String(100), nullable=True)
    raum_uebung = db.Column(db.String(100), nullable=True)
    raum_praktikum = db.Column(db.String(100), nullable=True)
    raum_seminar = db.Column(db.String(100), nullable=True)

    # KAPAZITÄTS-ANFORDERUNGEN PRO LEHRFORM
    kapazitaet_vorlesung = db.Column(db.Integer, nullable=True)
    kapazitaet_uebung = db.Column(db.Integer, nullable=True)
    kapazitaet_praktikum = db.Column(db.Integer, nullable=True)
    kapazitaet_seminar = db.Column(db.Integer, nullable=True)

    created_at = db.Column(db.DateTime, default=datetime.utcnow, nullable=False)

    # Relationships - mit eager loading für Performance
    template = db.relationship('PlanungsTemplate', back_populates='template_module')
    modul = db.relationship('Modul', lazy='joined')  # Verhindert N+1 Queries
    pruefungsordnung = db.relationship('Pruefungsordnung', lazy='joined')

    # UNIQUE Constraint: Ein Modul kann nur EINMAL pro Template sein
    __table_args__ = (
        db.UniqueConstraint('template_id', 'modul_id', name='uq_template_modul'),
        db.Index('ix_template_modul_template', 'template_id'),
    )

    def __repr__(self):
        return f'<TemplateModul {self.modul.kuerzel if self.modul else "?"}>'

    # =========================================================================
    # MITARBEITER JSON HANDLING
    # =========================================================================

    @property
    def mitarbeiter_ids(self) -> List[int]:
        """Gibt Liste von Mitarbeiter-IDs zurück"""
        if self._mitarbeiter_ids:
            try:
                return json.loads(self._mitarbeiter_ids)
            except (json.JSONDecodeError, TypeError):
                return []
        return []

    @mitarbeiter_ids.setter
    def mitarbeiter_ids(self, value: List[int]):
        """Setzt Mitarbeiter-IDs als JSON"""
        if value:
            self._mitarbeiter_ids = json.dumps(value)
        else:
            self._mitarbeiter_ids = None

    # =========================================================================
    # SERIALISIERUNG
    # =========================================================================

    def to_dict(self) -> Dict[str, Any]:
        """Konvertiert zu Dictionary (für API)"""
        # Modul-Daten mit Lehrformen für SWS-Berechnung im Frontend
        modul_data = None
        if self.modul:
            # Berechne sws_gesamt aus Lehrformen
            sws_gesamt = 0.0
            lehrformen_list = []
            try:
                # Lehrformen laden für SWS-Berechnung
                for lf in self.modul.lehrformen:
                    if lf.lehrform:
                        lf_sws = float(lf.sws) if lf.sws else 0.0
                        sws_gesamt += lf_sws
                        lehrformen_list.append({
                            'id': lf.id,
                            'lehrform_id': lf.lehrform_id,
                            'bezeichnung': lf.lehrform.bezeichnung,
                            'kuerzel': lf.lehrform.kuerzel,
                            'sws': lf_sws
                        })
            except Exception:
                pass  # Falls Lehrformen nicht ladbar

            modul_data = {
                'id': self.modul.id,
                'kuerzel': self.modul.kuerzel,
                'bezeichnung_de': self.modul.bezeichnung_de,
                'leistungspunkte': self.modul.leistungspunkte,
                'sws_gesamt': sws_gesamt,
                'lehrformen': lehrformen_list
            }

        return {
            'id': self.id,
            'template_id': self.template_id,
            'modul_id': self.modul_id,
            'po_id': self.po_id,

            # Modul-Daten mit Lehrformen
            'modul': modul_data,

            # Multiplikatoren
            'anzahl_vorlesungen': self.anzahl_vorlesungen,
            'anzahl_uebungen': self.anzahl_uebungen,
            'anzahl_praktika': self.anzahl_praktika,
            'anzahl_seminare': self.anzahl_seminare,

            # Mitarbeiter
            'mitarbeiter_ids': self.mitarbeiter_ids,

            # Zusätzlich
            'anmerkungen': self.anmerkungen,
            'raumbedarf': self.raumbedarf,

            # Raumplanung pro Lehrform
            'raum_vorlesung': self.raum_vorlesung,
            'raum_uebung': self.raum_uebung,
            'raum_praktikum': self.raum_praktikum,
            'raum_seminar': self.raum_seminar,

            # Kapazitäts-Anforderungen pro Lehrform
            'kapazitaet_vorlesung': self.kapazitaet_vorlesung,
            'kapazitaet_uebung': self.kapazitaet_uebung,
            'kapazitaet_praktikum': self.kapazitaet_praktikum,
            'kapazitaet_seminar': self.kapazitaet_seminar,
        }
