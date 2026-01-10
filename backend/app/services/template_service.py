"""
Template Service
================

Business Logic für Planungs-Templates.

Ermöglicht Professoren, Standard-Module-Konfigurationen für
Winter- und Sommersemester zu speichern und bei neuen Planungen
automatisch zu laden.
"""

from typing import List, Dict, Any, Optional
from app.extensions import db
from app.models import PlanungsTemplate, TemplateModul, Semesterplanung, GeplantesModul, WunschFreierTag
from app.services.base_service import BaseService


class TemplateService(BaseService):
    """
    Service für Planungs-Template Operationen.

    Methoden:
        - get_user_templates(benutzer_id): Alle Templates eines Benutzers
        - get_template(template_id): Template Details
        - get_template_for_semester(benutzer_id, semester_typ): Template für Semestertyp
        - get_or_create_template(...): Holt oder erstellt Template
        - update_template(...): Aktualisiert Template
        - delete_template(template_id): Löscht Template
        - add_modul_to_template(...): Fügt Modul hinzu
        - update_template_modul(...): Aktualisiert Modul
        - remove_modul_from_template(...): Entfernt Modul
        - update_template_from_planung(...): Template aus Planung
        - apply_template_to_planung(...): Template auf Planung anwenden
        - create_template_from_planung(...): Neues Template aus Planung
    """

    # BaseService erfordert model Attribut
    model = PlanungsTemplate

    # =========================================================================
    # GET METHODS
    # =========================================================================

    def get_user_templates(self, benutzer_id: int) -> List[PlanungsTemplate]:
        """
        Holt alle Templates eines Benutzers.

        Args:
            benutzer_id: ID des Benutzers

        Returns:
            Liste von PlanungsTemplates
        """
        return PlanungsTemplate.get_all_for_user(benutzer_id)

    def get_template(self, template_id: int) -> Optional[PlanungsTemplate]:
        """
        Holt ein Template nach ID.

        Args:
            template_id: ID des Templates

        Returns:
            PlanungsTemplate oder None
        """
        return PlanungsTemplate.query.get(template_id)

    def get_template_for_semester(
        self,
        benutzer_id: int,
        semester_typ: str
    ) -> Optional[PlanungsTemplate]:
        """
        Holt das aktive Template für einen Semestertyp.

        Args:
            benutzer_id: ID des Benutzers
            semester_typ: 'winter' oder 'sommer'

        Returns:
            PlanungsTemplate oder None
        """
        return PlanungsTemplate.get_for_user(benutzer_id, semester_typ)

    # =========================================================================
    # CREATE/UPDATE METHODS
    # =========================================================================

    def get_or_create_template(
        self,
        benutzer_id: int,
        semester_typ: str,
        name: str = None,
        beschreibung: str = None
    ) -> tuple:
        """
        Holt existierendes Template oder erstellt neues.

        Args:
            benutzer_id: ID des Benutzers
            semester_typ: 'winter' oder 'sommer'
            name: Optionaler Name
            beschreibung: Optionale Beschreibung

        Returns:
            tuple: (PlanungsTemplate, created: bool)
        """
        template, created = PlanungsTemplate.get_or_create(benutzer_id, semester_typ)

        if created and (name or beschreibung):
            if name:
                template.name = name
            if beschreibung:
                template.beschreibung = beschreibung
            db.session.commit()

        return template, created

    def update_template(
        self,
        template_id: int,
        name: str = None,
        beschreibung: str = None,
        ist_aktiv: bool = None,
        wunsch_freie_tage: List[Dict] = None,
        anmerkungen: str = None,
        raumbedarf: str = None
    ) -> Optional[PlanungsTemplate]:
        """
        Aktualisiert ein Template.

        Args:
            template_id: ID des Templates
            name: Neuer Name
            beschreibung: Neue Beschreibung
            ist_aktiv: Aktivstatus
            wunsch_freie_tage: Liste von Wunsch-freien Tagen
            anmerkungen: Anmerkungen
            raumbedarf: Raumbedarf

        Returns:
            Aktualisiertes PlanungsTemplate oder None
        """
        template = self.get_template(template_id)
        if not template:
            return None

        if name is not None:
            template.name = name
        if beschreibung is not None:
            template.beschreibung = beschreibung
        if ist_aktiv is not None:
            template.ist_aktiv = ist_aktiv
        if wunsch_freie_tage is not None:
            template.wunsch_freie_tage = wunsch_freie_tage
        if anmerkungen is not None:
            template.anmerkungen = anmerkungen
        if raumbedarf is not None:
            template.raumbedarf = raumbedarf

        db.session.commit()
        return template

    def delete_template(self, template_id: int) -> bool:
        """
        Löscht ein Template.

        Args:
            template_id: ID des Templates

        Returns:
            True wenn erfolgreich
        """
        template = self.get_template(template_id)
        if not template:
            return False

        db.session.delete(template)
        db.session.commit()
        return True

    # =========================================================================
    # MODUL METHODS
    # =========================================================================

    def add_modul_to_template(
        self,
        template_id: int,
        modul_id: int,
        po_id: int,
        anzahl_vorlesungen: int = 0,
        anzahl_uebungen: int = 0,
        anzahl_praktika: int = 0,
        anzahl_seminare: int = 0,
        mitarbeiter_ids: List[int] = None,
        anmerkungen: str = None,
        raumbedarf: str = None,
        raum_vorlesung: str = None,
        raum_uebung: str = None,
        raum_praktikum: str = None,
        raum_seminar: str = None,
        kapazitaet_vorlesung: int = None,
        kapazitaet_uebung: int = None,
        kapazitaet_praktikum: int = None,
        kapazitaet_seminar: int = None
    ) -> TemplateModul:
        """
        Fügt ein Modul zum Template hinzu.

        Args:
            template_id: ID des Templates
            modul_id: ID des Moduls
            po_id: ID der Prüfungsordnung
            ...: Weitere Felder

        Returns:
            TemplateModul

        Raises:
            ValueError: Wenn Modul bereits existiert
        """
        template = self.get_template(template_id)
        if not template:
            raise ValueError(f"Template {template_id} nicht gefunden")

        # Prüfe ob Modul bereits existiert
        existing = TemplateModul.query.filter_by(
            template_id=template_id,
            modul_id=modul_id
        ).first()

        if existing:
            raise ValueError(f"Modul {modul_id} ist bereits im Template")

        template_modul = TemplateModul(
            template_id=template_id,
            modul_id=modul_id,
            po_id=po_id,
            anzahl_vorlesungen=anzahl_vorlesungen,
            anzahl_uebungen=anzahl_uebungen,
            anzahl_praktika=anzahl_praktika,
            anzahl_seminare=anzahl_seminare,
            anmerkungen=anmerkungen,
            raumbedarf=raumbedarf,
            raum_vorlesung=raum_vorlesung,
            raum_uebung=raum_uebung,
            raum_praktikum=raum_praktikum,
            raum_seminar=raum_seminar,
            kapazitaet_vorlesung=kapazitaet_vorlesung,
            kapazitaet_uebung=kapazitaet_uebung,
            kapazitaet_praktikum=kapazitaet_praktikum,
            kapazitaet_seminar=kapazitaet_seminar
        )

        if mitarbeiter_ids:
            template_modul.mitarbeiter_ids = mitarbeiter_ids

        db.session.add(template_modul)
        db.session.commit()

        return template_modul

    def update_template_modul(
        self,
        template_id: int,
        modul_id: int,
        **kwargs
    ) -> Optional[TemplateModul]:
        """
        Aktualisiert ein Modul im Template.

        Args:
            template_id: ID des Templates
            modul_id: ID des Moduls
            **kwargs: Zu aktualisierende Felder

        Returns:
            Aktualisiertes TemplateModul oder None
        """
        template_modul = TemplateModul.query.filter_by(
            template_id=template_id,
            modul_id=modul_id
        ).first()

        if not template_modul:
            return None

        # Erlaubte Felder
        allowed_fields = [
            'anzahl_vorlesungen', 'anzahl_uebungen', 'anzahl_praktika', 'anzahl_seminare',
            'mitarbeiter_ids', 'anmerkungen', 'raumbedarf',
            'raum_vorlesung', 'raum_uebung', 'raum_praktikum', 'raum_seminar',
            'kapazitaet_vorlesung', 'kapazitaet_uebung', 'kapazitaet_praktikum', 'kapazitaet_seminar'
        ]

        for field in allowed_fields:
            if field in kwargs and kwargs[field] is not None:
                setattr(template_modul, field, kwargs[field])

        db.session.commit()
        return template_modul

    def remove_modul_from_template(self, template_id: int, modul_id: int) -> bool:
        """
        Entfernt ein Modul aus dem Template.

        Args:
            template_id: ID des Templates
            modul_id: ID des Moduls

        Returns:
            True wenn erfolgreich
        """
        template_modul = TemplateModul.query.filter_by(
            template_id=template_id,
            modul_id=modul_id
        ).first()

        if not template_modul:
            return False

        db.session.delete(template_modul)
        db.session.commit()
        return True

    # =========================================================================
    # TEMPLATE <-> PLANUNG KONVERTIERUNG
    # =========================================================================

    def update_template_from_planung(
        self,
        template_id: int,
        planung_id: int
    ) -> Dict[str, Any]:
        """
        Aktualisiert Template mit Daten aus einer bestehenden Planung.
        Alle bestehenden Module werden überschrieben.

        Args:
            template_id: ID des Templates
            planung_id: ID der Planung

        Returns:
            Dict mit 'template', 'anzahl_module' oder 'error'
        """
        template = self.get_template(template_id)
        if not template:
            return {'error': 'Template nicht gefunden'}

        planung = Semesterplanung.query.get(planung_id)
        if not planung:
            return {'error': 'Planung nicht gefunden'}

        # Update Template
        anzahl = template.update_from_planung(planung)

        return {
            'template': template,
            'anzahl_module': anzahl
        }

    def apply_template_to_planung(
        self,
        template_id: int,
        planung_id: int,
        clear_existing: bool = False
    ) -> Dict[str, Any]:
        """
        Wendet Template auf eine bestehende Planung an.

        Args:
            template_id: ID des Templates
            planung_id: ID der Planung
            clear_existing: True um bestehende Module zu löschen

        Returns:
            Dict mit 'planung', 'hinzugefuegt', 'uebersprungen' oder 'error'
        """
        template = self.get_template(template_id)
        if not template:
            return {'error': 'Template nicht gefunden'}

        planung = Semesterplanung.query.get(planung_id)
        if not planung:
            return {'error': 'Planung nicht gefunden'}

        # Prüfe ob Planung bearbeitet werden kann
        if not planung.kann_bearbeitet_werden():
            return {'error': 'Planung kann nicht bearbeitet werden (Status: ' + planung.status + ')'}

        hinzugefuegt = 0
        uebersprungen = 0

        # Optional: Bestehende Module löschen
        if clear_existing:
            for gm in planung.geplante_module.all():
                db.session.delete(gm)
            for wt in planung.wunsch_freie_tage.all():
                db.session.delete(wt)
            db.session.flush()

        # Wunsch-freie Tage übernehmen (nur wenn clear_existing oder keine vorhanden)
        if clear_existing or planung.wunsch_freie_tage.count() == 0:
            for tag_data in template.wunsch_freie_tage:
                wunsch_tag = WunschFreierTag(
                    semesterplanung_id=planung.id,
                    wochentag=tag_data.get('wochentag'),
                    zeitraum=tag_data.get('zeitraum', 'ganztags'),
                    prioritaet=tag_data.get('prioritaet', 'mittel'),
                    grund=tag_data.get('grund')
                )
                db.session.add(wunsch_tag)

        # Anmerkungen und Raumbedarf übernehmen (nur wenn leer)
        if template.anmerkungen and not planung.anmerkungen:
            planung.anmerkungen = template.anmerkungen
        if template.raumbedarf and not planung.raumbedarf:
            planung.raumbedarf = template.raumbedarf

        # Module übernehmen
        existing_modul_ids = [gm.modul_id for gm in planung.geplante_module.all()]

        for tm in template.template_module.all():
            if tm.modul_id in existing_modul_ids:
                uebersprungen += 1
                continue

            geplantes_modul = GeplantesModul(
                semesterplanung_id=planung.id,
                modul_id=tm.modul_id,
                po_id=tm.po_id,
                anzahl_vorlesungen=tm.anzahl_vorlesungen,
                anzahl_uebungen=tm.anzahl_uebungen,
                anzahl_praktika=tm.anzahl_praktika,
                anzahl_seminare=tm.anzahl_seminare,
                anmerkungen=tm.anmerkungen,
                raumbedarf=tm.raumbedarf,
                raum_vorlesung=tm.raum_vorlesung,
                raum_uebung=tm.raum_uebung,
                raum_praktikum=tm.raum_praktikum,
                raum_seminar=tm.raum_seminar,
                kapazitaet_vorlesung=tm.kapazitaet_vorlesung,
                kapazitaet_uebung=tm.kapazitaet_uebung,
                kapazitaet_praktikum=tm.kapazitaet_praktikum,
                kapazitaet_seminar=tm.kapazitaet_seminar
            )

            if tm.mitarbeiter_ids:
                geplantes_modul.mitarbeiter_ids = tm.mitarbeiter_ids

            # SWS berechnen
            geplantes_modul.berechne_sws()

            db.session.add(geplantes_modul)
            hinzugefuegt += 1

        # Gesamt-SWS neu berechnen
        planung.berechne_gesamt_sws()
        db.session.commit()

        return {
            'planung': planung,
            'hinzugefuegt': hinzugefuegt,
            'uebersprungen': uebersprungen
        }

    def create_template_from_planung(
        self,
        benutzer_id: int,
        planung_id: int,
        semester_typ: str,
        name: str = None
    ) -> Dict[str, Any]:
        """
        Erstellt ein neues Template aus einer bestehenden Planung.

        Args:
            benutzer_id: ID des Benutzers
            planung_id: ID der Planung
            semester_typ: 'winter' oder 'sommer'
            name: Optionaler Name

        Returns:
            Dict mit 'template', 'anzahl_module' oder 'error'
        """
        planung = Semesterplanung.query.get(planung_id)
        if not planung:
            return {'error': 'Planung nicht gefunden'}

        # Prüfe ob Template bereits existiert
        existing = PlanungsTemplate.query.filter_by(
            benutzer_id=benutzer_id,
            semester_typ=semester_typ.lower()
        ).first()

        if existing:
            return {'error': f'Template für {semester_typ}semester existiert bereits'}

        # Erstelle neues Template
        template = PlanungsTemplate(
            benutzer_id=benutzer_id,
            semester_typ=semester_typ.lower(),
            name=name or f"{'Winter' if semester_typ.lower() == 'winter' else 'Sommer'}semester Template",
            ist_aktiv=True
        )
        db.session.add(template)
        db.session.flush()  # Um ID zu bekommen

        # Module und Einstellungen übernehmen
        anzahl = template.update_from_planung(planung)

        return {
            'template': template,
            'anzahl_module': anzahl
        }
