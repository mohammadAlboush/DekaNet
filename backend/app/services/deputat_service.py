"""
Deputat Service
===============

Business Logic für die Deputatsabrechnung (Feature 4)

Funktionen:
- Deputatsabrechnung erstellen, bearbeiten, verwalten
- Import aus Semesterplanung und Semesteraufträgen
- Manuelle Ergänzungen (Lehrtätigkeiten, Lehrexport, etc.)
- Workflow: Einreichen, Genehmigen, Ablehnen
- Berechnungen mit Obergrenzen und Warnungen
- Einstellungen verwalten (Dekan)
"""

from typing import Optional, List, Dict, Any
from datetime import datetime, date
from sqlalchemy.orm import joinedload, selectinload
from app.services.base_service import BaseService
from app.models import (
    Deputatsabrechnung,
    DeputatsLehrtaetigkeit,
    DeputatsLehrexport,
    DeputatsVertretung,
    DeputatsErmaessigung,
    DeputatsBetreuung,
    DeputatsEinstellungen,
    Planungsphase,
    Benutzer,
    Semesterplanung,
    GeplantesModul,
    SemesterAuftrag,
)
from app.extensions import db


class DeputatService(BaseService):
    """
    Deputat Service

    Verwaltet Deputatsabrechnungen und deren Komponenten
    """

    model = Deputatsabrechnung

    # =========================================================================
    # EINSTELLUNGEN (Dekan)
    # =========================================================================

    def get_einstellungen(self) -> DeputatsEinstellungen:
        """
        Holt die aktuellen Einstellungen

        Returns:
            Aktuelle DeputatsEinstellungen
        """
        return DeputatsEinstellungen.get_current()

    def update_einstellungen(
        self,
        erstellt_von: int,
        beschreibung: str = None,
        **kwargs
    ) -> DeputatsEinstellungen:
        """
        Aktualisiert die Einstellungen (erstellt neue Version)

        Args:
            erstellt_von: Benutzer-ID des Dekans
            beschreibung: Änderungsbeschreibung
            **kwargs: Neue Werte

        Returns:
            Neue Einstellungen
        """
        return DeputatsEinstellungen.erstelle_neue_version(
            erstellt_von=erstellt_von,
            beschreibung=beschreibung,
            **kwargs
        )

    def get_einstellungen_historie(self) -> List[DeputatsEinstellungen]:
        """
        Holt alle historischen Einstellungen

        Returns:
            Liste aller Einstellungen (neueste zuerst)
        """
        return DeputatsEinstellungen.query.order_by(
            DeputatsEinstellungen.created_at.desc()
        ).all()

    # =========================================================================
    # DEPUTATSABRECHNUNG CRUD
    # =========================================================================

    def get_or_create_abrechnung(
        self,
        planungsphase_id: int,
        benutzer_id: int,
        auto_import: bool = True
    ) -> Deputatsabrechnung:
        """
        Holt oder erstellt eine Deputatsabrechnung

        NEU: Bei Auswahl einer Phase werden Daten automatisch importiert/synchronisiert

        Args:
            planungsphase_id: Planungsphase ID
            benutzer_id: Benutzer ID
            auto_import: Automatisch aus Planung/Aufträgen importieren

        Returns:
            Deputatsabrechnung (bestehend oder neu)

        Raises:
            ValueError: Bei ungültigen IDs
        """
        # Prüfe Planungsphase
        planungsphase = Planungsphase.query.get(planungsphase_id)
        if not planungsphase:
            raise ValueError("Planungsphase nicht gefunden")

        # Prüfe Benutzer
        benutzer = Benutzer.query.get(benutzer_id)
        if not benutzer:
            raise ValueError("Benutzer nicht gefunden")

        # Suche bestehende Abrechnung
        abrechnung = Deputatsabrechnung.query.filter_by(
            planungsphase_id=planungsphase_id,
            benutzer_id=benutzer_id
        ).first()

        created = False
        if not abrechnung:
            # Erstelle neue Abrechnung
            einstellungen = self.get_einstellungen()
            abrechnung = Deputatsabrechnung(
                planungsphase_id=planungsphase_id,
                benutzer_id=benutzer_id,
                netto_lehrverpflichtung=einstellungen.default_netto_lehrverpflichtung,
                status='entwurf'
            )
            db.session.add(abrechnung)
            db.session.commit()
            created = True

        # NEU: Automatischer Import/Sync bei Auswahl einer Phase
        if auto_import and abrechnung.kann_bearbeitet_werden():
            try:
                self.sync_from_planung(abrechnung.id)
            except Exception as e:
                # Log but don't fail the request
                import logging
                logging.getLogger(__name__).warning(f"Sync from planung failed: {e}")

            try:
                self.sync_from_semesterauftraege(abrechnung.id)
            except Exception as e:
                # Log but don't fail the request
                import logging
                logging.getLogger(__name__).warning(f"Sync from semesterauftraege failed: {e}")

        return abrechnung

    def get_abrechnung(self, abrechnung_id: int) -> Optional[Deputatsabrechnung]:
        """
        Holt eine Deputatsabrechnung

        Args:
            abrechnung_id: Abrechnung ID

        Returns:
            Deputatsabrechnung oder None
        """
        return self.get_by_id(abrechnung_id)

    def get_abrechnungen_fuer_benutzer(
        self,
        benutzer_id: int,
        planungsphase_id: int = None
    ) -> List[Deputatsabrechnung]:
        """
        Holt alle Abrechnungen eines Benutzers

        Args:
            benutzer_id: Benutzer ID
            planungsphase_id: Optional - Nur für diese Planungsphase

        Returns:
            Liste von Deputatsabrechnungen
        """
        query = Deputatsabrechnung.query.options(
            joinedload(Deputatsabrechnung.planungsphase).joinedload(Planungsphase.semester),
            joinedload(Deputatsabrechnung.benutzer)
        ).filter_by(benutzer_id=benutzer_id)

        if planungsphase_id:
            query = query.filter_by(planungsphase_id=planungsphase_id)

        return query.order_by(Deputatsabrechnung.created_at.desc()).all()

    def get_abrechnungen_fuer_planungsphase(
        self,
        planungsphase_id: int,
        status: str = None
    ) -> List[Deputatsabrechnung]:
        """
        Holt alle Abrechnungen einer Planungsphase (Dekan-Ansicht)

        Args:
            planungsphase_id: Planungsphase ID
            status: Optional - Filter nach Status

        Returns:
            Liste von Deputatsabrechnungen
        """
        query = Deputatsabrechnung.query.options(
            joinedload(Deputatsabrechnung.benutzer),
            joinedload(Deputatsabrechnung.planungsphase).joinedload(Planungsphase.semester)
        ).filter_by(planungsphase_id=planungsphase_id)

        if status:
            query = query.filter_by(status=status)

        return query.all()

    def get_eingereichte_abrechnungen(
        self,
        planungsphase_id: int = None
    ) -> List[Deputatsabrechnung]:
        """
        Holt alle eingereichten Abrechnungen (zur Genehmigung durch Dekan)

        Args:
            planungsphase_id: Optional - Nur für diese Planungsphase

        Returns:
            Liste von eingereichten Deputatsabrechnungen
        """
        query = Deputatsabrechnung.query.options(
            joinedload(Deputatsabrechnung.benutzer),
            joinedload(Deputatsabrechnung.planungsphase).joinedload(Planungsphase.semester)
        ).filter_by(status='eingereicht')

        if planungsphase_id:
            query = query.filter_by(planungsphase_id=planungsphase_id)

        return query.order_by(Deputatsabrechnung.eingereicht_am.desc()).all()

    def update_abrechnung(
        self,
        abrechnung_id: int,
        **data
    ) -> Optional[Deputatsabrechnung]:
        """
        Aktualisiert eine Deputatsabrechnung

        Args:
            abrechnung_id: Abrechnung ID
            **data: Felder zum Aktualisieren

        Returns:
            Aktualisierte Abrechnung oder None

        Raises:
            ValueError: Wenn Abrechnung nicht bearbeitet werden kann
        """
        abrechnung = self.get_by_id(abrechnung_id)
        if not abrechnung:
            return None

        if not abrechnung.kann_bearbeitet_werden():
            raise ValueError(
                f"Abrechnung kann nicht bearbeitet werden (Status: {abrechnung.status})"
            )

        updateable_fields = ['netto_lehrverpflichtung', 'bemerkungen']

        for field in updateable_fields:
            if field in data:
                setattr(abrechnung, field, data[field])

        db.session.commit()
        return abrechnung

    # =========================================================================
    # SYNC / AUTO-IMPORT (NEU)
    # =========================================================================

    def sync_from_planung(self, abrechnung_id: int) -> Dict[str, int]:
        """
        Synchronisiert Lehrtätigkeiten mit der Semesterplanung.

        - Fügt neue Module hinzu (die in der Planung sind, aber noch nicht in der Abrechnung)
        - Aktualisiert bestehende importierte Module (falls SWS sich geändert hat)
        - Entfernt importierte Module, die nicht mehr in der Planung sind

        Manuell hinzugefügte Einträge bleiben unberührt!

        Args:
            abrechnung_id: Abrechnung ID

        Returns:
            Dict mit Anzahl der Änderungen
        """
        abrechnung = self.get_by_id(abrechnung_id)
        if not abrechnung:
            raise ValueError("Abrechnung nicht gefunden")

        if not abrechnung.kann_bearbeitet_werden():
            return {'hinzugefuegt': 0, 'aktualisiert': 0, 'entfernt': 0, 'message': 'Abrechnung kann nicht bearbeitet werden'}

        # Hole zugehörige Semesterplanung
        benutzer = abrechnung.benutzer
        planungsphase = abrechnung.planungsphase

        planung = Semesterplanung.query.filter_by(
            planungsphase_id=planungsphase.id,
            benutzer_id=benutzer.id
        ).first()

        if not planung:
            return {'hinzugefuegt': 0, 'aktualisiert': 0, 'entfernt': 0, 'message': 'Keine Semesterplanung gefunden'}

        # Hole alle importierten Lehrtätigkeiten (quelle='planung')
        importierte = {
            lt.geplantes_modul_id: lt
            for lt in abrechnung.lehrtaetigkeiten.filter_by(quelle='planung').all()
            if lt.geplantes_modul_id
        }

        # Hole alle geplanten Module MIT EAGER LOADING für modul
        geplante_module = {
            gm.id: gm
            for gm in GeplantesModul.query.options(
                joinedload(GeplantesModul.modul)
            ).filter_by(semesterplanung_id=planung.id).all()
        }

        hinzugefuegt = 0
        aktualisiert = 0
        entfernt = 0

        # 1. Entferne Lehrtätigkeiten deren Module nicht mehr in der Planung sind
        for gm_id, lt in list(importierte.items()):
            if gm_id not in geplante_module:
                db.session.delete(lt)
                entfernt += 1
                del importierte[gm_id]

        # 2. Füge neue Module hinzu / Aktualisiere bestehende
        for gm_id, gm in geplante_module.items():
            # Bestimme SWS
            sws_wert = 0
            if gm.sws_gesamt:
                sws_wert = gm.sws_gesamt
            elif gm.modul:
                sws_wert = gm.modul.get_sws_gesamt() if hasattr(gm.modul, 'get_sws_gesamt') else 0

            bezeichnung = gm.modul.display_name if gm.modul else f"Modul {gm.modul_id}"

            if gm_id in importierte:
                # Aktualisiere wenn sich etwas geändert hat
                lt = importierte[gm_id]
                if lt.sws != sws_wert or lt.bezeichnung != bezeichnung:
                    lt.sws = sws_wert
                    lt.bezeichnung = bezeichnung
                    aktualisiert += 1
            else:
                # Neues Modul hinzufügen
                lt = DeputatsLehrtaetigkeit(
                    deputatsabrechnung_id=abrechnung_id,
                    bezeichnung=bezeichnung,
                    kategorie='lehrveranstaltung',
                    sws=sws_wert,
                    wochentag=None,
                    ist_block=False,
                    quelle='planung',
                    geplantes_modul_id=gm.id
                )
                db.session.add(lt)
                hinzugefuegt += 1

        db.session.commit()

        return {
            'hinzugefuegt': hinzugefuegt,
            'aktualisiert': aktualisiert,
            'entfernt': entfernt
        }

    def sync_from_semesterauftraege(self, abrechnung_id: int) -> Dict[str, int]:
        """
        Synchronisiert Ermäßigungen mit den genehmigten Semesteraufträgen.

        - Fügt neue genehmigte Aufträge hinzu
        - Aktualisiert bestehende (falls SWS sich geändert hat)
        - Entfernt Aufträge, die nicht mehr genehmigt sind

        Manuell hinzugefügte Ermäßigungen bleiben unberührt!

        Args:
            abrechnung_id: Abrechnung ID

        Returns:
            Dict mit Anzahl der Änderungen
        """
        abrechnung = self.get_by_id(abrechnung_id)
        if not abrechnung:
            raise ValueError("Abrechnung nicht gefunden")

        if not abrechnung.kann_bearbeitet_werden():
            return {'hinzugefuegt': 0, 'aktualisiert': 0, 'entfernt': 0, 'message': 'Abrechnung kann nicht bearbeitet werden'}

        benutzer = abrechnung.benutzer
        planungsphase = abrechnung.planungsphase

        if not benutzer.dozent_id:
            return {'hinzugefuegt': 0, 'aktualisiert': 0, 'entfernt': 0, 'message': 'Benutzer hat keinen verknüpften Dozenten'}

        # Hole alle importierten Ermäßigungen
        importierte = {
            e.semester_auftrag_id: e
            for e in abrechnung.ermaessigungen.filter_by(quelle='semesterauftrag').all()
            if e.semester_auftrag_id
        }

        # Hole genehmigte Semesteraufträge für diese Planungsphase MIT EAGER LOADING
        semester_id = planungsphase.semester_id
        genehmigte_auftraege = {
            a.id: a for a in SemesterAuftrag.query.options(
                joinedload(SemesterAuftrag.auftrag)
            ).filter_by(
                semester_id=semester_id,
                dozent_id=benutzer.dozent_id,
                status='genehmigt'
            ).all() if a.sws > 0
        }

        hinzugefuegt = 0
        aktualisiert = 0
        entfernt = 0

        # 1. Entferne Ermäßigungen deren Aufträge nicht mehr genehmigt sind
        for auftrag_id, ermaessigung in list(importierte.items()):
            if auftrag_id not in genehmigte_auftraege:
                db.session.delete(ermaessigung)
                entfernt += 1
                del importierte[auftrag_id]

        # 2. Füge neue hinzu / Aktualisiere bestehende
        for auftrag_id, auftrag in genehmigte_auftraege.items():
            bezeichnung = auftrag.auftrag.name if auftrag.auftrag else f"Auftrag {auftrag.auftrag_id}"

            if auftrag_id in importierte:
                # Aktualisiere wenn sich etwas geändert hat
                e = importierte[auftrag_id]
                if e.sws != auftrag.sws or e.bezeichnung != bezeichnung:
                    e.sws = auftrag.sws
                    e.bezeichnung = bezeichnung
                    aktualisiert += 1
            else:
                # Neuer Auftrag hinzufügen
                e = DeputatsErmaessigung(
                    deputatsabrechnung_id=abrechnung_id,
                    bezeichnung=bezeichnung,
                    sws=auftrag.sws,
                    quelle='semesterauftrag',
                    semester_auftrag_id=auftrag.id
                )
                db.session.add(e)
                hinzugefuegt += 1

        db.session.commit()

        return {
            'hinzugefuegt': hinzugefuegt,
            'aktualisiert': aktualisiert,
            'entfernt': entfernt
        }

    # =========================================================================
    # IMPORT AUS PLANUNG (Legacy - kann weiterhin manuell aufgerufen werden)
    # =========================================================================

    def importiere_aus_planung(
        self,
        abrechnung_id: int,
        ueberschreibe_bestehende: bool = False
    ) -> Dict[str, int]:
        """
        Importiert Lehrtätigkeiten aus der Semesterplanung

        Args:
            abrechnung_id: Abrechnung ID
            ueberschreibe_bestehende: Bestehende Imports löschen?

        Returns:
            Dict mit Anzahl importierter Einträge

        Raises:
            ValueError: Bei Fehlern
        """
        abrechnung = self.get_by_id(abrechnung_id)
        if not abrechnung:
            raise ValueError("Abrechnung nicht gefunden")

        if not abrechnung.kann_bearbeitet_werden():
            raise ValueError("Abrechnung kann nicht bearbeitet werden")

        # Hole zugehörige Semesterplanung
        benutzer = abrechnung.benutzer
        planungsphase = abrechnung.planungsphase

        # Finde Semesterplanung für diesen Benutzer in dieser Planungsphase
        planung = Semesterplanung.query.filter_by(
            planungsphase_id=planungsphase.id,
            benutzer_id=benutzer.id
        ).first()

        if not planung:
            return {'importiert': 0, 'uebersprungen': 0, 'message': 'Keine Semesterplanung gefunden'}

        # Optional: Lösche bestehende Imports
        if ueberschreibe_bestehende:
            DeputatsLehrtaetigkeit.query.filter_by(
                deputatsabrechnung_id=abrechnung_id,
                quelle='planung'
            ).delete()

        # Hole bereits importierte Module
        bereits_importiert = {
            lt.geplantes_modul_id
            for lt in abrechnung.lehrtaetigkeiten.filter_by(quelle='planung').all()
            if lt.geplantes_modul_id
        }

        importiert = 0
        uebersprungen = 0

        # Importiere geplante Module MIT EAGER LOADING
        geplante_module = GeplantesModul.query.options(
            joinedload(GeplantesModul.modul)
        ).filter_by(semesterplanung_id=planung.id).all()

        for gm in geplante_module:
            if gm.id in bereits_importiert:
                uebersprungen += 1
                continue

            # Bestimme SWS
            sws_wert = 0
            if gm.sws_gesamt:
                sws_wert = gm.sws_gesamt
            elif gm.modul:
                sws_wert = gm.modul.get_sws_gesamt() if hasattr(gm.modul, 'get_sws_gesamt') else 0

            # Erstelle Lehrtätigkeit
            lt = DeputatsLehrtaetigkeit(
                deputatsabrechnung_id=abrechnung_id,
                bezeichnung=gm.modul.display_name if gm.modul else f"Modul {gm.modul_id}",
                kategorie='lehrveranstaltung',  # Standard-Kategorie
                sws=sws_wert,
                wochentag=None,  # Wird manuell eingetragen
                ist_block=False,
                quelle='planung',
                geplantes_modul_id=gm.id
            )

            db.session.add(lt)
            importiert += 1

        db.session.commit()

        return {
            'importiert': importiert,
            'uebersprungen': uebersprungen
        }

    def importiere_ermaessigungen_aus_semesterauftraegen(
        self,
        abrechnung_id: int,
        ueberschreibe_bestehende: bool = False
    ) -> Dict[str, int]:
        """
        Importiert Ermäßigungen aus Semesteraufträgen

        Args:
            abrechnung_id: Abrechnung ID
            ueberschreibe_bestehende: Bestehende Imports löschen?

        Returns:
            Dict mit Anzahl importierter Einträge
        """
        abrechnung = self.get_by_id(abrechnung_id)
        if not abrechnung:
            raise ValueError("Abrechnung nicht gefunden")

        if not abrechnung.kann_bearbeitet_werden():
            raise ValueError("Abrechnung kann nicht bearbeitet werden")

        benutzer = abrechnung.benutzer
        planungsphase = abrechnung.planungsphase

        if not benutzer.dozent_id:
            return {'importiert': 0, 'uebersprungen': 0, 'message': 'Benutzer hat keinen verknüpften Dozenten'}

        # Optional: Lösche bestehende Imports
        if ueberschreibe_bestehende:
            DeputatsErmaessigung.query.filter_by(
                deputatsabrechnung_id=abrechnung_id,
                quelle='semesterauftrag'
            ).delete()

        # Hole bereits importierte Aufträge
        bereits_importiert = {
            e.semester_auftrag_id
            for e in abrechnung.ermaessigungen.filter_by(quelle='semesterauftrag').all()
            if e.semester_auftrag_id
        }

        # Hole genehmigte Semesteraufträge für diese Planungsphase MIT EAGER LOADING
        semester_id = planungsphase.semester_id
        auftraege = SemesterAuftrag.query.options(
            joinedload(SemesterAuftrag.auftrag)
        ).filter_by(
            semester_id=semester_id,
            dozent_id=benutzer.dozent_id,
            status='genehmigt'
        ).all()

        importiert = 0
        uebersprungen = 0

        for auftrag in auftraege:
            if auftrag.id in bereits_importiert:
                uebersprungen += 1
                continue

            if auftrag.sws <= 0:
                continue

            ermaessigung = DeputatsErmaessigung(
                deputatsabrechnung_id=abrechnung_id,
                bezeichnung=auftrag.auftrag.name if auftrag.auftrag else f"Auftrag {auftrag.auftrag_id}",
                sws=auftrag.sws,
                quelle='semesterauftrag',
                semester_auftrag_id=auftrag.id
            )

            db.session.add(ermaessigung)
            importiert += 1

        db.session.commit()

        return {
            'importiert': importiert,
            'uebersprungen': uebersprungen
        }

    # =========================================================================
    # LEHRTÄTIGKEITEN
    # =========================================================================

    def add_lehrtaetigkeit(
        self,
        abrechnung_id: int,
        bezeichnung: str,
        sws: float,
        kategorie: str = 'lehrveranstaltung',
        wochentag: str = None,
        ist_block: bool = False
    ) -> DeputatsLehrtaetigkeit:
        """
        Fügt eine manuelle Lehrtätigkeit hinzu

        Args:
            abrechnung_id: Abrechnung ID
            bezeichnung: Bezeichnung
            sws: SWS
            kategorie: Kategorie
            wochentag: Wochentag
            ist_block: Blockveranstaltung?

        Returns:
            Neue Lehrtätigkeit
        """
        abrechnung = self.get_by_id(abrechnung_id)
        if not abrechnung:
            raise ValueError("Abrechnung nicht gefunden")

        if not abrechnung.kann_bearbeitet_werden():
            raise ValueError("Abrechnung kann nicht bearbeitet werden")

        if kategorie not in DeputatsLehrtaetigkeit.KATEGORIEN:
            raise ValueError(f"Ungültige Kategorie: {kategorie}")

        if wochentag and wochentag not in DeputatsLehrtaetigkeit.WOCHENTAGE:
            raise ValueError(f"Ungültiger Wochentag: {wochentag}")

        lt = DeputatsLehrtaetigkeit(
            deputatsabrechnung_id=abrechnung_id,
            bezeichnung=bezeichnung,
            kategorie=kategorie,
            sws=sws,
            wochentag=wochentag,
            ist_block=ist_block,
            quelle='manuell'
        )

        db.session.add(lt)
        db.session.commit()

        return lt

    def update_lehrtaetigkeit(
        self,
        lehrtaetigkeit_id: int,
        **data
    ) -> Optional[DeputatsLehrtaetigkeit]:
        """
        Aktualisiert eine Lehrtätigkeit

        Args:
            lehrtaetigkeit_id: Lehrtätigkeit ID
            **data: Felder zum Aktualisieren

        Returns:
            Aktualisierte Lehrtätigkeit oder None
        """
        lt = DeputatsLehrtaetigkeit.query.get(lehrtaetigkeit_id)
        if not lt:
            return None

        if not lt.deputatsabrechnung.kann_bearbeitet_werden():
            raise ValueError("Abrechnung kann nicht bearbeitet werden")

        updateable_fields = ['bezeichnung', 'kategorie', 'sws', 'wochentag', 'ist_block']

        for field in updateable_fields:
            if field in data:
                if field == 'kategorie' and data[field] not in DeputatsLehrtaetigkeit.KATEGORIEN:
                    raise ValueError(f"Ungültige Kategorie: {data[field]}")
                if field == 'wochentag' and data[field] and data[field] not in DeputatsLehrtaetigkeit.WOCHENTAGE:
                    raise ValueError(f"Ungültiger Wochentag: {data[field]}")
                setattr(lt, field, data[field])

        db.session.commit()
        return lt

    def delete_lehrtaetigkeit(self, lehrtaetigkeit_id: int) -> bool:
        """
        Löscht eine Lehrtätigkeit

        Args:
            lehrtaetigkeit_id: Lehrtätigkeit ID

        Returns:
            True wenn erfolgreich
        """
        lt = DeputatsLehrtaetigkeit.query.get(lehrtaetigkeit_id)
        if not lt:
            return False

        if not lt.deputatsabrechnung.kann_bearbeitet_werden():
            raise ValueError("Abrechnung kann nicht bearbeitet werden")

        db.session.delete(lt)
        db.session.commit()

        return True

    # =========================================================================
    # LEHREXPORT
    # =========================================================================

    def add_lehrexport(
        self,
        abrechnung_id: int,
        fachbereich: str,
        fach: str,
        sws: float
    ) -> DeputatsLehrexport:
        """
        Fügt einen Lehrexport hinzu

        Args:
            abrechnung_id: Abrechnung ID
            fachbereich: Fachbereich
            fach: Fach
            sws: SWS

        Returns:
            Neuer Lehrexport
        """
        abrechnung = self.get_by_id(abrechnung_id)
        if not abrechnung:
            raise ValueError("Abrechnung nicht gefunden")

        if not abrechnung.kann_bearbeitet_werden():
            raise ValueError("Abrechnung kann nicht bearbeitet werden")

        le = DeputatsLehrexport(
            deputatsabrechnung_id=abrechnung_id,
            fachbereich=fachbereich,
            fach=fach,
            sws=sws
        )

        db.session.add(le)
        db.session.commit()

        return le

    def update_lehrexport(
        self,
        lehrexport_id: int,
        **data
    ) -> Optional[DeputatsLehrexport]:
        """Aktualisiert einen Lehrexport"""
        le = DeputatsLehrexport.query.get(lehrexport_id)
        if not le:
            return None

        if not le.deputatsabrechnung.kann_bearbeitet_werden():
            raise ValueError("Abrechnung kann nicht bearbeitet werden")

        for field in ['fachbereich', 'fach', 'sws']:
            if field in data:
                setattr(le, field, data[field])

        db.session.commit()
        return le

    def delete_lehrexport(self, lehrexport_id: int) -> bool:
        """Löscht einen Lehrexport"""
        le = DeputatsLehrexport.query.get(lehrexport_id)
        if not le:
            return False

        if not le.deputatsabrechnung.kann_bearbeitet_werden():
            raise ValueError("Abrechnung kann nicht bearbeitet werden")

        db.session.delete(le)
        db.session.commit()

        return True

    # =========================================================================
    # VERTRETUNGEN
    # =========================================================================

    def add_vertretung(
        self,
        abrechnung_id: int,
        art: str,
        vertretene_person: str,
        fach_professor: str,
        sws: float
    ) -> DeputatsVertretung:
        """
        Fügt eine Vertretung hinzu

        Args:
            abrechnung_id: Abrechnung ID
            art: Art der Vertretung
            vertretene_person: Vertretene Person
            fach_professor: Fach des Professors
            sws: SWS

        Returns:
            Neue Vertretung
        """
        abrechnung = self.get_by_id(abrechnung_id)
        if not abrechnung:
            raise ValueError("Abrechnung nicht gefunden")

        if not abrechnung.kann_bearbeitet_werden():
            raise ValueError("Abrechnung kann nicht bearbeitet werden")

        if art not in DeputatsVertretung.ARTEN:
            raise ValueError(f"Ungültige Vertretungsart: {art}")

        v = DeputatsVertretung(
            deputatsabrechnung_id=abrechnung_id,
            art=art,
            vertretene_person=vertretene_person,
            fach_professor=fach_professor,
            sws=sws
        )

        db.session.add(v)
        db.session.commit()

        return v

    def update_vertretung(
        self,
        vertretung_id: int,
        **data
    ) -> Optional[DeputatsVertretung]:
        """Aktualisiert eine Vertretung"""
        v = DeputatsVertretung.query.get(vertretung_id)
        if not v:
            return None

        if not v.deputatsabrechnung.kann_bearbeitet_werden():
            raise ValueError("Abrechnung kann nicht bearbeitet werden")

        for field in ['art', 'vertretene_person', 'fach_professor', 'sws']:
            if field in data:
                if field == 'art' and data[field] not in DeputatsVertretung.ARTEN:
                    raise ValueError(f"Ungültige Vertretungsart: {data[field]}")
                setattr(v, field, data[field])

        db.session.commit()
        return v

    def delete_vertretung(self, vertretung_id: int) -> bool:
        """Löscht eine Vertretung"""
        v = DeputatsVertretung.query.get(vertretung_id)
        if not v:
            return False

        if not v.deputatsabrechnung.kann_bearbeitet_werden():
            raise ValueError("Abrechnung kann nicht bearbeitet werden")

        db.session.delete(v)
        db.session.commit()

        return True

    # =========================================================================
    # ERMÄSSIGUNGEN
    # =========================================================================

    def add_ermaessigung(
        self,
        abrechnung_id: int,
        bezeichnung: str,
        sws: float
    ) -> DeputatsErmaessigung:
        """
        Fügt eine manuelle Ermäßigung hinzu

        Args:
            abrechnung_id: Abrechnung ID
            bezeichnung: Bezeichnung
            sws: SWS

        Returns:
            Neue Ermäßigung
        """
        abrechnung = self.get_by_id(abrechnung_id)
        if not abrechnung:
            raise ValueError("Abrechnung nicht gefunden")

        if not abrechnung.kann_bearbeitet_werden():
            raise ValueError("Abrechnung kann nicht bearbeitet werden")

        e = DeputatsErmaessigung(
            deputatsabrechnung_id=abrechnung_id,
            bezeichnung=bezeichnung,
            sws=sws,
            quelle='manuell'
        )

        db.session.add(e)
        db.session.commit()

        return e

    def update_ermaessigung(
        self,
        ermaessigung_id: int,
        **data
    ) -> Optional[DeputatsErmaessigung]:
        """Aktualisiert eine Ermäßigung"""
        e = DeputatsErmaessigung.query.get(ermaessigung_id)
        if not e:
            return None

        if not e.deputatsabrechnung.kann_bearbeitet_werden():
            raise ValueError("Abrechnung kann nicht bearbeitet werden")

        for field in ['bezeichnung', 'sws']:
            if field in data:
                setattr(e, field, data[field])

        db.session.commit()
        return e

    def delete_ermaessigung(self, ermaessigung_id: int) -> bool:
        """Löscht eine Ermäßigung"""
        e = DeputatsErmaessigung.query.get(ermaessigung_id)
        if not e:
            return False

        if not e.deputatsabrechnung.kann_bearbeitet_werden():
            raise ValueError("Abrechnung kann nicht bearbeitet werden")

        db.session.delete(e)
        db.session.commit()

        return True

    # =========================================================================
    # BETREUUNGEN
    # =========================================================================

    def add_betreuung(
        self,
        abrechnung_id: int,
        student_name: str,
        student_vorname: str,
        betreuungsart: str,
        titel_arbeit: str = None,
        status: str = 'laufend',
        beginn_datum: date = None,
        ende_datum: date = None
    ) -> DeputatsBetreuung:
        """
        Fügt eine Betreuung hinzu

        Args:
            abrechnung_id: Abrechnung ID
            student_name: Nachname
            student_vorname: Vorname
            betreuungsart: Art der Betreuung
            titel_arbeit: Titel der Arbeit
            status: Status
            beginn_datum: Beginn
            ende_datum: Ende

        Returns:
            Neue Betreuung
        """
        abrechnung = self.get_by_id(abrechnung_id)
        if not abrechnung:
            raise ValueError("Abrechnung nicht gefunden")

        if not abrechnung.kann_bearbeitet_werden():
            raise ValueError("Abrechnung kann nicht bearbeitet werden")

        if betreuungsart not in DeputatsBetreuung.BETREUUNGSARTEN:
            raise ValueError(f"Ungültige Betreuungsart: {betreuungsart}")

        if status not in DeputatsBetreuung.STATUS_OPTIONEN:
            raise ValueError(f"Ungültiger Status: {status}")

        b = DeputatsBetreuung(
            deputatsabrechnung_id=abrechnung_id,
            student_name=student_name,
            student_vorname=student_vorname,
            titel_arbeit=titel_arbeit,
            betreuungsart=betreuungsart,
            status=status,
            beginn_datum=beginn_datum,
            ende_datum=ende_datum
        )

        # SWS automatisch berechnen
        einstellungen = self.get_einstellungen()
        b.berechne_sws(einstellungen)

        db.session.add(b)
        db.session.commit()

        return b

    def update_betreuung(
        self,
        betreuung_id: int,
        **data
    ) -> Optional[DeputatsBetreuung]:
        """Aktualisiert eine Betreuung"""
        b = DeputatsBetreuung.query.get(betreuung_id)
        if not b:
            return None

        if not b.deputatsabrechnung.kann_bearbeitet_werden():
            raise ValueError("Abrechnung kann nicht bearbeitet werden")

        updateable_fields = [
            'student_name', 'student_vorname', 'titel_arbeit',
            'betreuungsart', 'status', 'beginn_datum', 'ende_datum'
        ]

        for field in updateable_fields:
            if field in data:
                if field == 'betreuungsart' and data[field] not in DeputatsBetreuung.BETREUUNGSARTEN:
                    raise ValueError(f"Ungültige Betreuungsart: {data[field]}")
                if field == 'status' and data[field] not in DeputatsBetreuung.STATUS_OPTIONEN:
                    raise ValueError(f"Ungültiger Status: {data[field]}")
                setattr(b, field, data[field])

        # SWS neu berechnen wenn Betreuungsart geändert
        if 'betreuungsart' in data:
            einstellungen = self.get_einstellungen()
            b.berechne_sws(einstellungen)

        db.session.commit()
        return b

    def delete_betreuung(self, betreuung_id: int) -> bool:
        """Löscht eine Betreuung"""
        b = DeputatsBetreuung.query.get(betreuung_id)
        if not b:
            return False

        if not b.deputatsabrechnung.kann_bearbeitet_werden():
            raise ValueError("Abrechnung kann nicht bearbeitet werden")

        db.session.delete(b)
        db.session.commit()

        return True

    # =========================================================================
    # WORKFLOW
    # =========================================================================

    def einreichen(self, abrechnung_id: int) -> Deputatsabrechnung:
        """
        Reicht eine Abrechnung ein

        Args:
            abrechnung_id: Abrechnung ID

        Returns:
            Eingereichte Abrechnung

        Raises:
            ValueError: Wenn nicht einreichbar
        """
        abrechnung = self.get_by_id(abrechnung_id)
        if not abrechnung:
            raise ValueError("Abrechnung nicht gefunden")

        abrechnung.einreichen()
        return abrechnung

    def genehmigen(
        self,
        abrechnung_id: int,
        genehmiger_id: int
    ) -> Deputatsabrechnung:
        """
        Genehmigt eine Abrechnung (nur Dekan)

        Args:
            abrechnung_id: Abrechnung ID
            genehmiger_id: Benutzer ID des Dekans

        Returns:
            Genehmigte Abrechnung

        Raises:
            ValueError: Wenn nicht genehmigbar
        """
        abrechnung = self.get_by_id(abrechnung_id)
        if not abrechnung:
            raise ValueError("Abrechnung nicht gefunden")

        abrechnung.genehmigen(genehmiger_id)
        return abrechnung

    def ablehnen(
        self,
        abrechnung_id: int,
        grund: str = None
    ) -> Deputatsabrechnung:
        """
        Lehnt eine Abrechnung ab (nur Dekan)

        Args:
            abrechnung_id: Abrechnung ID
            grund: Ablehnungsgrund

        Returns:
            Abgelehnte Abrechnung

        Raises:
            ValueError: Wenn nicht ablehnbar
        """
        abrechnung = self.get_by_id(abrechnung_id)
        if not abrechnung:
            raise ValueError("Abrechnung nicht gefunden")

        abrechnung.ablehnen(grund)
        return abrechnung

    def zuruecksetzen(self, abrechnung_id: int) -> Deputatsabrechnung:
        """
        Setzt eine Abrechnung auf Entwurf zurück

        Args:
            abrechnung_id: Abrechnung ID

        Returns:
            Zurückgesetzte Abrechnung
        """
        abrechnung = self.get_by_id(abrechnung_id)
        if not abrechnung:
            raise ValueError("Abrechnung nicht gefunden")

        abrechnung.zurueck_zu_entwurf()
        return abrechnung

    # =========================================================================
    # BERECHNUNGEN
    # =========================================================================

    def berechne_summen(
        self,
        abrechnung_id: int
    ) -> Dict[str, Any]:
        """
        Berechnet alle Summen einer Abrechnung

        Args:
            abrechnung_id: Abrechnung ID

        Returns:
            Dict mit allen berechneten Summen und Warnungen
        """
        abrechnung = self.get_by_id(abrechnung_id)
        if not abrechnung:
            raise ValueError("Abrechnung nicht gefunden")

        einstellungen = self.get_einstellungen()
        return abrechnung.berechne_summen(einstellungen)

    # =========================================================================
    # STATISTIKEN (Dekan)
    # =========================================================================

    def get_statistik(
        self,
        planungsphase_id: int = None
    ) -> Dict[str, Any]:
        """
        Gibt Statistiken zu Deputatsabrechnungen zurück

        Args:
            planungsphase_id: Optional - Nur für diese Planungsphase

        Returns:
            Dict mit Statistiken
        """
        query = Deputatsabrechnung.query

        if planungsphase_id:
            query = query.filter_by(planungsphase_id=planungsphase_id)

        total = query.count()
        entwurf = query.filter_by(status='entwurf').count()
        eingereicht = query.filter_by(status='eingereicht').count()
        genehmigt = query.filter_by(status='genehmigt').count()
        abgelehnt = query.filter_by(status='abgelehnt').count()

        return {
            'gesamt': total,
            'entwurf': entwurf,
            'eingereicht': eingereicht,
            'genehmigt': genehmigt,
            'abgelehnt': abgelehnt,
            'quote_eingereicht': round(eingereicht / total * 100, 1) if total > 0 else 0,
            'quote_genehmigt': round(genehmigt / total * 100, 1) if total > 0 else 0,
        }

    # =========================================================================
    # PDF EXPORT
    # =========================================================================

    def generate_pdf(self, abrechnung_id: int) -> bytes:
        """
        Generiert ein professionelles PDF der Deputatsabrechnung im Excel-Stil

        Args:
            abrechnung_id: Abrechnung ID

        Returns:
            PDF als Bytes

        Raises:
            ValueError: Wenn Abrechnung nicht gefunden
        """
        from io import BytesIO
        from reportlab.lib import colors
        from reportlab.lib.pagesizes import A4
        from reportlab.lib.styles import getSampleStyleSheet, ParagraphStyle
        from reportlab.lib.units import cm, mm
        from reportlab.platypus import (
            SimpleDocTemplate, Table, TableStyle, Paragraph, Spacer, HRFlowable
        )
        from reportlab.lib.enums import TA_CENTER, TA_RIGHT, TA_LEFT
        from reportlab.graphics.shapes import Drawing, Rect
        from reportlab.graphics import renderPDF
        from datetime import datetime

        abrechnung = self.get_by_id(abrechnung_id)
        if not abrechnung:
            raise ValueError("Abrechnung nicht gefunden")

        einstellungen = self.get_einstellungen()
        summen = abrechnung.berechne_summen(einstellungen)

        # Create PDF buffer
        buffer = BytesIO()
        doc = SimpleDocTemplate(
            buffer,
            pagesize=A4,
            rightMargin=1.5*cm,
            leftMargin=1.5*cm,
            topMargin=1.5*cm,
            bottomMargin=2*cm
        )

        # Farben definieren
        PRIMARY_COLOR = colors.HexColor('#1976d2')
        PRIMARY_DARK = colors.HexColor('#1565c0')
        SUCCESS_COLOR = colors.HexColor('#4caf50')
        WARNING_COLOR = colors.HexColor('#ff9800')
        ERROR_COLOR = colors.HexColor('#f44336')
        SECTION_LEHRE = colors.HexColor('#1976d2')
        SECTION_EXPORT = colors.HexColor('#9c27b0')
        SECTION_VERTRETUNG = colors.HexColor('#ff9800')
        SECTION_ERMAESSIGUNG = colors.HexColor('#4caf50')
        SECTION_BETREUUNG = colors.HexColor('#e91e63')
        LIGHT_GRAY = colors.HexColor('#f5f5f5')
        BORDER_GRAY = colors.HexColor('#e0e0e0')

        # Styles
        styles = getSampleStyleSheet()

        # Haupttitel
        title_style = ParagraphStyle(
            'Title',
            parent=styles['Heading1'],
            fontSize=20,
            alignment=TA_CENTER,
            spaceAfter=5,
            textColor=PRIMARY_DARK,
            fontName='Helvetica-Bold'
        )

        # Untertitel (Name, Phase)
        subtitle_style = ParagraphStyle(
            'Subtitle',
            parent=styles['Normal'],
            fontSize=12,
            alignment=TA_CENTER,
            spaceAfter=3,
            textColor=colors.HexColor('#424242')
        )

        # Info-Text
        info_style = ParagraphStyle(
            'Info',
            parent=styles['Normal'],
            fontSize=10,
            alignment=TA_CENTER,
            spaceAfter=2,
            textColor=colors.HexColor('#757575')
        )

        # Abschnittstitel
        section_style = ParagraphStyle(
            'Section',
            parent=styles['Heading2'],
            fontSize=11,
            spaceBefore=12,
            spaceAfter=6,
            textColor=colors.HexColor('#424242'),
            fontName='Helvetica-Bold'
        )

        normal_style = styles['Normal']
        normal_style.fontSize = 9

        elements = []

        # =====================================================================
        # HEADER
        # =====================================================================
        benutzer_name = abrechnung.benutzer.name_komplett if abrechnung.benutzer else 'Unbekannt'
        phase_name = abrechnung.planungsphase.name if abrechnung.planungsphase else 'Unbekannt'
        semester = ''
        if abrechnung.planungsphase and abrechnung.planungsphase.semester:
            semester = abrechnung.planungsphase.semester.kuerzel or ''

        # Titel
        elements.append(Paragraph('DEPUTATSABRECHNUNG', title_style))
        elements.append(Spacer(1, 3*mm))

        # Trennlinie
        elements.append(HRFlowable(width="100%", thickness=2, color=PRIMARY_COLOR, spaceAfter=10))

        # Info-Box
        elements.append(Paragraph(f'<b>{benutzer_name}</b>', subtitle_style))
        elements.append(Paragraph(f'{phase_name}', info_style))
        if semester:
            elements.append(Paragraph(f'Semester: {semester}', info_style))
        elements.append(Spacer(1, 5*mm))

        # Status-Badge und Lehrverpflichtung in einer Tabelle
        status_text = {
            'entwurf': 'Entwurf',
            'eingereicht': 'Eingereicht',
            'genehmigt': 'Genehmigt',
            'abgelehnt': 'Abgelehnt'
        }.get(abrechnung.status, abrechnung.status)

        status_color = {
            'entwurf': colors.HexColor('#9e9e9e'),
            'eingereicht': colors.HexColor('#2196f3'),
            'genehmigt': SUCCESS_COLOR,
            'abgelehnt': ERROR_COLOR
        }.get(abrechnung.status, colors.grey)

        # Bewertung
        bewertung_text = {
            'erfuellt': 'Erfüllt',
            'abweichung': 'Abweichung',
            'starke_abweichung': 'Starke Abweichung'
        }.get(summen['bewertung'], '')

        bewertung_color = {
            'erfuellt': SUCCESS_COLOR,
            'abweichung': WARNING_COLOR,
            'starke_abweichung': ERROR_COLOR
        }.get(summen['bewertung'], colors.grey)

        # Info-Tabelle
        info_data = [
            ['Status:', status_text, 'Netto-Lehrverpflichtung:', f"{abrechnung.netto_lehrverpflichtung} SWS"],
            ['Bewertung:', bewertung_text, 'Nettobelastung:', f"{summen['nettobelastung']:.1f} SWS"],
        ]

        info_table = Table(info_data, colWidths=[3*cm, 4*cm, 4.5*cm, 4*cm])
        info_table.setStyle(TableStyle([
            ('FONTNAME', (0, 0), (0, -1), 'Helvetica-Bold'),
            ('FONTNAME', (2, 0), (2, -1), 'Helvetica-Bold'),
            ('FONTSIZE', (0, 0), (-1, -1), 9),
            ('TEXTCOLOR', (1, 0), (1, 0), status_color),
            ('TEXTCOLOR', (1, 1), (1, 1), bewertung_color),
            ('ALIGN', (0, 0), (-1, -1), 'LEFT'),
            ('VALIGN', (0, 0), (-1, -1), 'MIDDLE'),
            ('BOTTOMPADDING', (0, 0), (-1, -1), 4),
            ('TOPPADDING', (0, 0), (-1, -1), 4),
        ]))
        elements.append(info_table)
        elements.append(Spacer(1, 8*mm))

        # =====================================================================
        # HELPER: Tabellen-Style Generator
        # =====================================================================
        def create_section_table_style(header_color):
            return TableStyle([
                ('BACKGROUND', (0, 0), (-1, 0), header_color),
                ('TEXTCOLOR', (0, 0), (-1, 0), colors.white),
                ('ALIGN', (0, 0), (-1, -1), 'LEFT'),
                ('ALIGN', (-1, 0), (-1, -1), 'RIGHT'),
                ('FONTNAME', (0, 0), (-1, 0), 'Helvetica-Bold'),
                ('FONTSIZE', (0, 0), (-1, 0), 9),
                ('BOTTOMPADDING', (0, 0), (-1, 0), 6),
                ('TOPPADDING', (0, 0), (-1, 0), 6),
                ('BACKGROUND', (0, 1), (-1, -2), colors.white),
                ('FONTSIZE', (0, 1), (-1, -1), 8),
                ('BOTTOMPADDING', (0, 1), (-1, -1), 4),
                ('TOPPADDING', (0, 1), (-1, -1), 4),
                ('GRID', (0, 0), (-1, -1), 0.5, BORDER_GRAY),
                ('ROWBACKGROUNDS', (0, 1), (-1, -2), [colors.white, LIGHT_GRAY]),
                # Summenzeile hervorheben
                ('BACKGROUND', (0, -1), (-1, -1), colors.HexColor('#e3f2fd')),
                ('FONTNAME', (0, -1), (-1, -1), 'Helvetica-Bold'),
            ])

        # Wochentage-Mapping
        wochentage_map = {
            'montag': 'Mo', 'dienstag': 'Di', 'mittwoch': 'Mi',
            'donnerstag': 'Do', 'freitag': 'Fr'
        }

        # =====================================================================
        # 1. LEHRTÄTIGKEITEN
        # =====================================================================
        if abrechnung.lehrtaetigkeiten.count() > 0:
            elements.append(Paragraph('1. Lehrtätigkeiten', section_style))
            data = [['Bezeichnung', 'Kategorie', 'Wochentag(e)', 'Quelle', 'SWS']]
            kategorien_map = {
                'lehrveranstaltung': 'Lehrveranstaltung',
                'praxisseminar': 'Praxisseminar',
                'projektveranstaltung': 'Projektveranstaltung',
                'seminar_master': 'Seminar (Master)'
            }
            quelle_map = {
                'planung': 'Planung',
                'semesterauftrag': 'Auftrag',
                'manuell': 'Manuell'
            }

            for lt in abrechnung.lehrtaetigkeiten.all():
                # Mehrere Wochentage unterstützen
                wochentage_list = lt.get_wochentage_list() if hasattr(lt, 'get_wochentage_list') else []
                if wochentage_list:
                    wt = ', '.join([wochentage_map.get(w, w) for w in wochentage_list])
                elif lt.ist_block:
                    wt = 'Block'
                else:
                    wt = '-'

                data.append([
                    lt.bezeichnung[:35] + ('...' if len(lt.bezeichnung) > 35 else ''),
                    kategorien_map.get(lt.kategorie, lt.kategorie),
                    wt,
                    quelle_map.get(lt.quelle, lt.quelle),
                    f'{lt.sws:.1f}'
                ])
            data.append(['', '', '', 'Summe:', f'{summen["sws_lehrtaetigkeiten"]:.1f}'])
            table = Table(data, colWidths=[6.5*cm, 3.5*cm, 2.5*cm, 2*cm, 1.5*cm])
            table.setStyle(create_section_table_style(SECTION_LEHRE))
            elements.append(table)

        # =====================================================================
        # 2. LEHREXPORT
        # =====================================================================
        if abrechnung.lehrexporte.count() > 0:
            elements.append(Paragraph('2. Lehrexport', section_style))
            data = [['Fachbereich', 'Fach', 'SWS']]
            for le in abrechnung.lehrexporte.all():
                data.append([le.fachbereich, le.fach, f'{le.sws:.1f}'])
            data.append(['', 'Summe:', f'{summen["sws_lehrexport"]:.1f}'])
            table = Table(data, colWidths=[6*cm, 8.5*cm, 1.5*cm])
            table.setStyle(create_section_table_style(SECTION_EXPORT))
            elements.append(table)

        # =====================================================================
        # 3. VERTRETUNGEN
        # =====================================================================
        if abrechnung.vertretungen.count() > 0:
            elements.append(Paragraph('3. Vertretungen', section_style))
            data = [['Art', 'Vertretene Person', 'Fach/Professor', 'SWS']]
            art_map = {
                'praxissemester': 'Praxissemester',
                'forschungsfreisemester': 'Forschungsfreisemester'
            }
            for v in abrechnung.vertretungen.all():
                data.append([
                    art_map.get(v.art, v.art),
                    v.vertretene_person,
                    v.fach_professor,
                    f'{v.sws:.1f}'
                ])
            data.append(['', '', 'Summe:', f'{summen["sws_vertretungen"]:.1f}'])
            table = Table(data, colWidths=[4*cm, 4*cm, 6.5*cm, 1.5*cm])
            table.setStyle(create_section_table_style(SECTION_VERTRETUNG))
            elements.append(table)

        # =====================================================================
        # 4. ERMÄSSIGUNGEN
        # =====================================================================
        if abrechnung.ermaessigungen.count() > 0:
            elements.append(Paragraph('4. Ermäßigungsstunden', section_style))
            data = [['Bezeichnung', 'Quelle', 'SWS']]
            quelle_map = {
                'planung': 'Planung',
                'semesterauftrag': 'Semesterauftrag',
                'manuell': 'Manuell'
            }
            for e in abrechnung.ermaessigungen.all():
                data.append([
                    e.bezeichnung[:50] + ('...' if len(e.bezeichnung) > 50 else ''),
                    quelle_map.get(e.quelle, e.quelle),
                    f'{e.sws:.1f}'
                ])
            data.append(['', 'Summe:', f'{summen["sws_ermaessigungen"]:.1f}'])
            table = Table(data, colWidths=[10*cm, 4.5*cm, 1.5*cm])
            table.setStyle(create_section_table_style(SECTION_ERMAESSIGUNG))
            elements.append(table)

        # =====================================================================
        # 5. BETREUUNGEN
        # =====================================================================
        if abrechnung.betreuungen.count() > 0:
            elements.append(Paragraph('5. Betreuungen', section_style))
            data = [['Student/in', 'Betreuungsart', 'Titel', 'Status', 'SWS']]
            betreuungsart_map = {
                'bachelor': 'BA-Arbeit',
                'master': 'MA-Arbeit',
                'doktorarbeit': 'Doktorarbeit',
                'seminar_ba': 'Seminar (BA)',
                'seminar_ma': 'Seminar (MA)',
                'projekt_ba': 'Projekt (BA)',
                'projekt_ma': 'Projekt (MA)'
            }
            status_map = {
                'laufend': 'Laufend',
                'abgeschlossen': 'Abgeschl.'
            }
            for b in abrechnung.betreuungen.all():
                titel = (b.titel_arbeit[:25] + '...') if b.titel_arbeit and len(b.titel_arbeit) > 25 else (b.titel_arbeit or '-')
                data.append([
                    b.student_name_komplett,
                    betreuungsart_map.get(b.betreuungsart, b.betreuungsart),
                    titel,
                    status_map.get(b.status, b.status),
                    f'{b.sws:.2f}'
                ])
            # Summenzeile mit Hinweis auf Anrechnung
            data.append([
                '',
                f'Roh: {summen["sws_betreuungen_roh"]:.2f}',
                '',
                'Angerechnet:',
                f'{summen["sws_betreuungen_angerechnet"]:.2f}'
            ])
            table = Table(data, colWidths=[4*cm, 2.5*cm, 5*cm, 2.5*cm, 2*cm])
            table.setStyle(create_section_table_style(SECTION_BETREUUNG))
            elements.append(table)

        # =====================================================================
        # ZUSAMMENFASSUNG
        # =====================================================================
        elements.append(Spacer(1, 8*mm))
        elements.append(HRFlowable(width="100%", thickness=1, color=PRIMARY_COLOR, spaceAfter=5))
        elements.append(Paragraph('ZUSAMMENFASSUNG', section_style))

        # Kompakte Zusammenfassungstabelle
        summary_data = [
            ['Kategorie', 'Roh', 'Angerechnet'],
            ['Lehrtätigkeiten', f'{summen["sws_lehrtaetigkeiten"]:.1f}', f'{summen["sws_lehrtaetigkeiten"]:.1f}'],
            ['  - Praxisseminar', f'{summen["sws_praxisseminar"]:.1f}', f'{summen["sws_praxisseminar_angerechnet"]:.1f}'],
            ['  - Projektveranstaltung', f'{summen["sws_projektveranstaltung"]:.1f}', f'{summen["sws_projektveranstaltung_angerechnet"]:.1f}'],
            ['  - Seminar (Master)', f'{summen["sws_seminar_master"]:.1f}', f'{summen["sws_seminar_master_angerechnet"]:.1f}'],
            ['Lehrexport', f'{summen["sws_lehrexport"]:.1f}', f'{summen["sws_lehrexport"]:.1f}'],
            ['Vertretungen', f'{summen["sws_vertretungen"]:.1f}', f'{summen["sws_vertretungen"]:.1f}'],
            ['Betreuungen (max. 3 SWS)', f'{summen["sws_betreuungen_roh"]:.1f}', f'{summen["sws_betreuungen_angerechnet"]:.1f}'],
        ]

        summary_table = Table(summary_data, colWidths=[10*cm, 3*cm, 3*cm])
        summary_table.setStyle(TableStyle([
            ('BACKGROUND', (0, 0), (-1, 0), PRIMARY_COLOR),
            ('TEXTCOLOR', (0, 0), (-1, 0), colors.white),
            ('FONTNAME', (0, 0), (-1, 0), 'Helvetica-Bold'),
            ('ALIGN', (1, 0), (-1, -1), 'RIGHT'),
            ('FONTSIZE', (0, 0), (-1, -1), 9),
            ('BOTTOMPADDING', (0, 0), (-1, -1), 4),
            ('TOPPADDING', (0, 0), (-1, -1), 4),
            ('GRID', (0, 0), (-1, -1), 0.5, BORDER_GRAY),
            ('ROWBACKGROUNDS', (0, 1), (-1, -1), [colors.white, LIGHT_GRAY]),
        ]))
        elements.append(summary_table)
        elements.append(Spacer(1, 5*mm))

        # Ergebnistabelle (Gesamtdeputat, Ermäßigungen, Differenz)
        result_data = [
            ['Gesamtdeputat (brutto)', '', f'{summen["gesamtdeputat"]:.1f} SWS'],
            ['Ermäßigungen', '', f'- {summen["sws_ermaessigungen"]:.1f} SWS'],
            ['Nettobelastung', '', f'{summen["nettobelastung"]:.1f} SWS'],
            ['Netto-Lehrverpflichtung', '', f'{abrechnung.netto_lehrverpflichtung:.1f} SWS'],
            ['DIFFERENZ', '', f'{summen["differenz"]:+.1f} SWS'],
        ]

        # Farbe für Differenzzeile
        diff_bg_color = {
            'erfuellt': colors.HexColor('#e8f5e9'),
            'abweichung': colors.HexColor('#fff3e0'),
            'starke_abweichung': colors.HexColor('#ffebee')
        }.get(summen['bewertung'], colors.white)

        diff_text_color = {
            'erfuellt': SUCCESS_COLOR,
            'abweichung': WARNING_COLOR,
            'starke_abweichung': ERROR_COLOR
        }.get(summen['bewertung'], colors.black)

        result_table = Table(result_data, colWidths=[8*cm, 5*cm, 3*cm])
        result_table.setStyle(TableStyle([
            ('FONTNAME', (0, 0), (0, -1), 'Helvetica-Bold'),
            ('FONTSIZE', (0, 0), (-1, -1), 10),
            ('ALIGN', (-1, 0), (-1, -1), 'RIGHT'),
            ('BOTTOMPADDING', (0, 0), (-1, -1), 6),
            ('TOPPADDING', (0, 0), (-1, -1), 6),
            ('LINEABOVE', (0, 2), (-1, 2), 1, colors.grey),
            ('LINEABOVE', (0, 4), (-1, 4), 2, PRIMARY_COLOR),
            # Differenz hervorheben
            ('BACKGROUND', (0, 4), (-1, 4), diff_bg_color),
            ('TEXTCOLOR', (-1, 4), (-1, 4), diff_text_color),
            ('FONTNAME', (0, 4), (-1, 4), 'Helvetica-Bold'),
            ('FONTSIZE', (0, 4), (-1, 4), 11),
        ]))
        elements.append(result_table)

        # =====================================================================
        # HINWEISE / WARNUNGEN
        # =====================================================================
        if summen['warnungen']:
            elements.append(Spacer(1, 5*mm))
            warning_style = ParagraphStyle(
                'Warning',
                parent=styles['Normal'],
                fontSize=9,
                textColor=WARNING_COLOR,
                leftIndent=10
            )
            elements.append(Paragraph('<b>Hinweise:</b>', section_style))
            for warnung in summen['warnungen']:
                elements.append(Paragraph(f'• {warnung}', warning_style))

        # =====================================================================
        # BEMERKUNGEN
        # =====================================================================
        if abrechnung.bemerkungen:
            elements.append(Spacer(1, 5*mm))
            elements.append(Paragraph('<b>Bemerkungen:</b>', section_style))
            remark_style = ParagraphStyle(
                'Remark',
                parent=styles['Normal'],
                fontSize=9,
                leftIndent=10,
                textColor=colors.HexColor('#616161')
            )
            elements.append(Paragraph(abrechnung.bemerkungen, remark_style))

        # =====================================================================
        # FOOTER
        # =====================================================================
        elements.append(Spacer(1, 10*mm))
        elements.append(HRFlowable(width="100%", thickness=0.5, color=BORDER_GRAY, spaceAfter=5))

        footer_style = ParagraphStyle(
            'Footer',
            parent=styles['Normal'],
            fontSize=8,
            textColor=colors.HexColor('#9e9e9e')
        )

        # Zeitstempel-Tabelle
        footer_data = []
        if abrechnung.created_at:
            footer_data.append(['Erstellt:', abrechnung.created_at.strftime("%d.%m.%Y %H:%M")])
        if abrechnung.eingereicht_am:
            footer_data.append(['Eingereicht:', abrechnung.eingereicht_am.strftime("%d.%m.%Y %H:%M")])
        if abrechnung.genehmigt_am:
            genehmiger = abrechnung.genehmiger.name_komplett if abrechnung.genehmiger else 'Unbekannt'
            footer_data.append(['Genehmigt:', f'{abrechnung.genehmigt_am.strftime("%d.%m.%Y %H:%M")} von {genehmiger}'])
        if abrechnung.abgelehnt_am:
            footer_data.append(['Abgelehnt:', f'{abrechnung.abgelehnt_am.strftime("%d.%m.%Y %H:%M")}'])
            if abrechnung.ablehnungsgrund:
                footer_data.append(['Grund:', abrechnung.ablehnungsgrund])

        if footer_data:
            footer_table = Table(footer_data, colWidths=[3*cm, 13*cm])
            footer_table.setStyle(TableStyle([
                ('FONTSIZE', (0, 0), (-1, -1), 8),
                ('TEXTCOLOR', (0, 0), (-1, -1), colors.HexColor('#9e9e9e')),
                ('FONTNAME', (0, 0), (0, -1), 'Helvetica-Bold'),
                ('BOTTOMPADDING', (0, 0), (-1, -1), 2),
                ('TOPPADDING', (0, 0), (-1, -1), 2),
            ]))
            elements.append(footer_table)

        # Generierungsdatum
        elements.append(Spacer(1, 3*mm))
        elements.append(Paragraph(
            f'PDF generiert am: {datetime.now().strftime("%d.%m.%Y %H:%M")}',
            footer_style
        ))

        # Build PDF
        doc.build(elements)
        pdf_bytes = buffer.getvalue()
        buffer.close()

        return pdf_bytes


# Singleton Instance
deputat_service = DeputatService()
