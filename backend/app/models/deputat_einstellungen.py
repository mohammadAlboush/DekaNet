"""
DeputatsEinstellungen Model
===========================

Globale Konfiguration für die Deputatsabrechnung.

Enthält:
- SWS-Werte für Betreuungen
- Obergrenzen für verschiedene Lehrkategorien
- Warnschwellen
"""

from datetime import datetime
from typing import Dict, Any
from app.extensions import db


class DeputatsEinstellungen(db.Model):
    """
    Globale Einstellungen für die Deputatsabrechnung

    Singleton-Pattern: Es gibt immer nur einen aktiven Einstellungssatz.
    """
    __tablename__ = 'deputats_einstellungen'

    id = db.Column(db.Integer, primary_key=True)

    # =========================================================================
    # SWS-WERTE FÜR BETREUUNGEN
    # =========================================================================

    # Abschlussarbeiten
    sws_bachelor_arbeit = db.Column(db.Float, default=0.3, nullable=False)
    sws_master_arbeit = db.Column(db.Float, default=0.5, nullable=False)
    sws_doktorarbeit = db.Column(db.Float, default=1.0, nullable=False)

    # Seminare & Projekte
    sws_seminar_ba = db.Column(db.Float, default=0.2, nullable=False)
    sws_seminar_ma = db.Column(db.Float, default=0.3, nullable=False)
    sws_projekt_ba = db.Column(db.Float, default=0.2, nullable=False)
    sws_projekt_ma = db.Column(db.Float, default=0.3, nullable=False)

    # =========================================================================
    # OBERGRENZEN
    # =========================================================================

    # Maximal anrechenbare SWS pro Kategorie
    max_sws_praxisseminar = db.Column(db.Float, default=5.0, nullable=False)
    max_sws_projektveranstaltung = db.Column(db.Float, default=6.0, nullable=False)
    max_sws_seminar_master = db.Column(db.Float, default=4.0, nullable=False)
    max_sws_betreuung = db.Column(db.Float, default=3.0, nullable=False)

    # =========================================================================
    # WARNSCHWELLEN
    # =========================================================================

    # Warnung wenn Ermäßigungen diesen Wert überschreiten
    warn_ermaessigung_ueber = db.Column(db.Float, default=5.0, nullable=False)

    # =========================================================================
    # STANDARD-LEHRVERPFLICHTUNG
    # =========================================================================

    default_netto_lehrverpflichtung = db.Column(db.Float, default=18.0, nullable=False)

    # =========================================================================
    # META
    # =========================================================================

    # Aktivstatus (nur ein Eintrag kann aktiv sein)
    ist_aktiv = db.Column(db.Boolean, default=True, nullable=False)

    # Beschreibung für Versionierung
    beschreibung = db.Column(db.String(500), nullable=True)

    # Audit
    created_at = db.Column(db.DateTime, default=datetime.utcnow, nullable=False)
    updated_at = db.Column(
        db.DateTime,
        default=datetime.utcnow,
        onupdate=datetime.utcnow,
        nullable=False
    )
    erstellt_von = db.Column(
        db.Integer,
        db.ForeignKey('benutzer.id', ondelete='SET NULL'),
        nullable=True
    )

    # Relationships
    ersteller = db.relationship('Benutzer', foreign_keys=[erstellt_von])

    def __repr__(self):
        return f'<DeputatsEinstellungen {self.id} - {"aktiv" if self.ist_aktiv else "inaktiv"}>'

    # =========================================================================
    # CLASS METHODS
    # =========================================================================

    @classmethod
    def get_current(cls) -> 'DeputatsEinstellungen':
        """
        Holt die aktuellen aktiven Einstellungen.
        Falls keine existieren, werden Default-Einstellungen erstellt.

        Returns:
            DeputatsEinstellungen: Aktive Einstellungen
        """
        einstellungen = cls.query.filter_by(ist_aktiv=True).first()

        if einstellungen is None:
            # Erstelle Default-Einstellungen
            einstellungen = cls(
                ist_aktiv=True,
                beschreibung='Standard-Einstellungen (automatisch erstellt)'
            )
            db.session.add(einstellungen)
            db.session.commit()

        return einstellungen

    @classmethod
    def erstelle_neue_version(
        cls,
        erstellt_von: int = None,
        beschreibung: str = None,
        **kwargs
    ) -> 'DeputatsEinstellungen':
        """
        Erstellt eine neue Version der Einstellungen.
        Die alte aktive Version wird deaktiviert.

        Args:
            erstellt_von: Benutzer-ID des Erstellers
            beschreibung: Beschreibung der Änderung
            **kwargs: Zu ändernde Werte

        Returns:
            DeputatsEinstellungen: Neue aktive Einstellungen
        """
        # Aktuelle Einstellungen holen
        current = cls.get_current()

        # Alle bisherigen deaktivieren
        cls.query.filter_by(ist_aktiv=True).update({'ist_aktiv': False})

        # Neue Einstellungen mit Werten der alten erstellen
        neue_einstellungen = cls(
            sws_bachelor_arbeit=kwargs.get('sws_bachelor_arbeit', current.sws_bachelor_arbeit),
            sws_master_arbeit=kwargs.get('sws_master_arbeit', current.sws_master_arbeit),
            sws_doktorarbeit=kwargs.get('sws_doktorarbeit', current.sws_doktorarbeit),
            sws_seminar_ba=kwargs.get('sws_seminar_ba', current.sws_seminar_ba),
            sws_seminar_ma=kwargs.get('sws_seminar_ma', current.sws_seminar_ma),
            sws_projekt_ba=kwargs.get('sws_projekt_ba', current.sws_projekt_ba),
            sws_projekt_ma=kwargs.get('sws_projekt_ma', current.sws_projekt_ma),
            max_sws_praxisseminar=kwargs.get('max_sws_praxisseminar', current.max_sws_praxisseminar),
            max_sws_projektveranstaltung=kwargs.get('max_sws_projektveranstaltung', current.max_sws_projektveranstaltung),
            max_sws_seminar_master=kwargs.get('max_sws_seminar_master', current.max_sws_seminar_master),
            max_sws_betreuung=kwargs.get('max_sws_betreuung', current.max_sws_betreuung),
            warn_ermaessigung_ueber=kwargs.get('warn_ermaessigung_ueber', current.warn_ermaessigung_ueber),
            default_netto_lehrverpflichtung=kwargs.get('default_netto_lehrverpflichtung', current.default_netto_lehrverpflichtung),
            ist_aktiv=True,
            beschreibung=beschreibung,
            erstellt_von=erstellt_von
        )

        db.session.add(neue_einstellungen)
        db.session.commit()

        return neue_einstellungen

    # =========================================================================
    # SERIALISIERUNG
    # =========================================================================

    def to_dict(self) -> Dict[str, Any]:
        """Konvertiert zu Dictionary (für API)"""
        return {
            'id': self.id,

            # SWS-Werte für Betreuungen
            'sws_bachelor_arbeit': self.sws_bachelor_arbeit,
            'sws_master_arbeit': self.sws_master_arbeit,
            'sws_doktorarbeit': self.sws_doktorarbeit,
            'sws_seminar_ba': self.sws_seminar_ba,
            'sws_seminar_ma': self.sws_seminar_ma,
            'sws_projekt_ba': self.sws_projekt_ba,
            'sws_projekt_ma': self.sws_projekt_ma,

            # Obergrenzen
            'max_sws_praxisseminar': self.max_sws_praxisseminar,
            'max_sws_projektveranstaltung': self.max_sws_projektveranstaltung,
            'max_sws_seminar_master': self.max_sws_seminar_master,
            'max_sws_betreuung': self.max_sws_betreuung,

            # Warnschwellen
            'warn_ermaessigung_ueber': self.warn_ermaessigung_ueber,

            # Standard-Lehrverpflichtung
            'default_netto_lehrverpflichtung': self.default_netto_lehrverpflichtung,

            # Meta
            'ist_aktiv': self.ist_aktiv,
            'beschreibung': self.beschreibung,
            'created_at': self.created_at.isoformat() if self.created_at else None,
            'updated_at': self.updated_at.isoformat() if self.updated_at else None,
            'erstellt_von': self.erstellt_von,
            'ersteller_name': self.ersteller.name_komplett if self.ersteller else None
        }

    def get_betreuungs_sws(self) -> Dict[str, float]:
        """Gibt alle Betreuungs-SWS-Werte als Dict zurück"""
        return {
            'bachelor': self.sws_bachelor_arbeit,
            'master': self.sws_master_arbeit,
            'doktorarbeit': self.sws_doktorarbeit,
            'seminar_ba': self.sws_seminar_ba,
            'seminar_ma': self.sws_seminar_ma,
            'projekt_ba': self.sws_projekt_ba,
            'projekt_ma': self.sws_projekt_ma,
        }

    def get_obergrenzen(self) -> Dict[str, float]:
        """Gibt alle Obergrenzen als Dict zurück"""
        return {
            'praxisseminar': self.max_sws_praxisseminar,
            'projektveranstaltung': self.max_sws_projektveranstaltung,
            'seminar_master': self.max_sws_seminar_master,
            'betreuung': self.max_sws_betreuung,
        }
