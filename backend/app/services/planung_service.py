"""
Planung Service
===============
**KERN-FEATURE!** Business Logic für Semesterplanung-Workflow.

Der komplette 8-Schritte Workflow:
1. Semester auswählen
2. Module auswählen
3. Module hinzufügen
4. Mitarbeiter zuordnen
5. Multiplikatoren setzen
6. Zusätzliche Infos
7. Wunsch-freie Tage
8. Einreichen

Funktionen:
- Planung erstellen/bearbeiten
- Module hinzufügen/entfernen
- Workflow (einreichen, freigeben, ablehnen)
- SWS-Berechnung
"""

from typing import Optional, List, Dict, Any
from datetime import datetime
from app.services.base_service import BaseService
from app.services.sws_calculator import sws_calculator
from app.models import (
    Semesterplanung, GeplantesModul, WunschFreierTag,
    Semester, Benutzer, Modul
)
from app.extensions import db


class PlanungService(BaseService):
    """
    Planung Service
    
    **KERN-SERVICE** für Semesterplanung-Workflow.
    """
    
    model = Semesterplanung
    
    # =========================================================================
    # PLANUNG MANAGEMENT
    # =========================================================================
    
    def get_or_create_planung(
        self,
        semester_id: int,
        benutzer_id: int,
        planungsphase_id: int = None
    ) -> tuple[Semesterplanung, bool]:
        """
        Holt bestehende Planung oder erstellt neue

        Args:
            semester_id: Semester ID
            benutzer_id: Benutzer ID
            planungsphase_id: Planungsphase ID (optional, aber empfohlen!)

        Returns:
            tuple: (Semesterplanung, created: bool)

        Raises:
            ValueError: Wenn Planungsphase nicht aktiv ist

        Example:
            >>> planung, created = planung_service.get_or_create_planung(1, 1, planungsphase_id=2)

        WICHTIG: Mit planungsphase_id kann ein Professor mehrere Planungen pro Semester haben
                 (eine pro Phase). Ohne planungsphase_id wird nur nach (semester, benutzer) gesucht.
        """
        # Prüfe ob Semester Planungsphase aktiv hat
        semester = Semester.query.get(semester_id)
        if not semester:
            raise ValueError(f"Semester mit ID {semester_id} nicht gefunden")

        if not semester.ist_planungsphase:
            raise ValueError(
                f"Planungsphase für Semester '{semester.bezeichnung}' ist nicht aktiv. "
                "Neue Planungen können nur während einer offenen Planungsphase erstellt werden."
            )

        # Prüfe ob Planung existiert
        query_filter = {
            'semester_id': semester_id,
            'benutzer_id': benutzer_id
        }

        # Wenn planungsphase_id gegeben, auch danach filtern
        # Dies ermöglicht mehrere Planungen pro Semester (eine pro Phase)
        if planungsphase_id is not None:
            query_filter['planungsphase_id'] = planungsphase_id

        planung = Semesterplanung.query.filter_by(**query_filter).first()

        if planung:
            return planung, False

        # Erstelle neue Planung
        planung = Semesterplanung(
            semester_id=semester_id,
            benutzer_id=benutzer_id,
            planungsphase_id=planungsphase_id,
            status='entwurf',
            gesamt_sws=0.0
        )
        db.session.add(planung)
        db.session.commit()

        return planung, True
    
    def delete_planung(
        self,
        planung_id: int,
        force: bool = False
    ) -> bool:
        """
        Löscht eine Planung
        
        Args:
            planung_id: Planung ID
            force: Bei True auch freigegebene Planungen löschen
            
        Returns:
            bool: True wenn erfolgreich
            
        Raises:
            ValueError: Wenn Planung nicht gelöscht werden kann
        """
        planung = self.get_by_id(planung_id)
        if not planung:
            return False
        
        # Prüfe Status
        if not force and planung.status == 'freigegeben':
            raise ValueError("Freigegebene Planungen können nicht gelöscht werden")
        
        return self.delete(planung_id)
    
    # =========================================================================
    # MODUL MANAGEMENT (Schritt 3)
    # =========================================================================
    
    def add_modul(
        self,
        planung_id: int,
        modul_id: int,
        po_id: int,
        anzahl_vorlesungen: int = 0,
        anzahl_uebungen: int = 0,
        anzahl_praktika: int = 0,
        anzahl_seminare: int = 0,
        mitarbeiter_ids: List[int] = None,
        anmerkungen: str = None,
        raumbedarf: str = None,
        # Raumplanung pro Lehrform
        raum_vorlesung: str = None,
        raum_uebung: str = None,
        raum_praktikum: str = None,
        raum_seminar: str = None,
        # Kapazitäts-Anforderungen pro Lehrform
        kapazitaet_vorlesung: int = None,
        kapazitaet_uebung: int = None,
        kapazitaet_praktikum: int = None,
        kapazitaet_seminar: int = None
    ) -> GeplantesModul:
        """
        Fügt ein Modul zur Planung hinzu

        Args:
            planung_id: Semesterplanung ID
            modul_id: Modul ID
            po_id: Prüfungsordnung ID
            anzahl_vorlesungen: Multiplikator Vorlesungen
            anzahl_uebungen: Multiplikator Übungen
            anzahl_praktika: Multiplikator Praktika
            anzahl_seminare: Multiplikator Seminare
            mitarbeiter_ids: Optional - Liste von Dozenten-IDs
            anmerkungen: Optional - Anmerkungen
            raumbedarf: Optional - Raumbedarf
            raum_vorlesung: Optional - Raum für Vorlesung (Feature 4)
            raum_uebung: Optional - Raum für Übung (Feature 4)
            raum_praktikum: Optional - Raum für Praktikum (Feature 4)
            raum_seminar: Optional - Raum für Seminar (Feature 4)
            kapazitaet_vorlesung: Optional - Kapazität für Vorlesung (Feature 4)
            kapazitaet_uebung: Optional - Kapazität für Übung (Feature 4)
            kapazitaet_praktikum: Optional - Kapazität für Praktikum (Feature 4)
            kapazitaet_seminar: Optional - Kapazität für Seminar (Feature 4)

        Returns:
            GeplantesModul: Neu erstelltes geplantes Modul
            
        Raises:
            ValueError: Bei Validierungsfehlern
            
        Example:
            >>> geplantes = planung_service.add_modul(
                    planung_id=1,
                    modul_id=5,
                    po_id=1,
                    anzahl_vorlesungen=2,
                    anzahl_uebungen=1
                )
        """
        planung = self.get_by_id(planung_id)
        if not planung:
            raise ValueError("Planung nicht gefunden")
        
        # Prüfe ob Planung bearbeitet werden kann
        if not planung.kann_bearbeitet_werden():
            raise ValueError(f"Planung im Status '{planung.status}' kann nicht bearbeitet werden")
        
        # Prüfe ob Modul bereits existiert
        existing = GeplantesModul.query.filter_by(
            semesterplanung_id=planung_id,
            modul_id=modul_id
        ).first()
        if existing:
            raise ValueError("Modul ist bereits in der Planung")
        
        # Validiere Multiplikatoren
        is_valid, error_msg = sws_calculator.validate_multiplikatoren(
            modul_id, po_id,
            anzahl_vorlesungen, anzahl_uebungen,
            anzahl_praktika, anzahl_seminare
        )
        if not is_valid:
            raise ValueError(f"Ungültige Multiplikatoren: {error_msg}")
        
        # Erstelle geplantes Modul
        geplantes_modul = GeplantesModul(
            semesterplanung_id=planung_id,
            modul_id=modul_id,
            po_id=po_id,
            anzahl_vorlesungen=anzahl_vorlesungen,
            anzahl_uebungen=anzahl_uebungen,
            anzahl_praktika=anzahl_praktika,
            anzahl_seminare=anzahl_seminare,
            anmerkungen=anmerkungen,
            raumbedarf=raumbedarf,
            # Raumplanung pro Lehrform
            raum_vorlesung=raum_vorlesung,
            raum_uebung=raum_uebung,
            raum_praktikum=raum_praktikum,
            raum_seminar=raum_seminar,
            # Kapazitäts-Anforderungen pro Lehrform
            kapazitaet_vorlesung=kapazitaet_vorlesung,
            kapazitaet_uebung=kapazitaet_uebung,
            kapazitaet_praktikum=kapazitaet_praktikum,
            kapazitaet_seminar=kapazitaet_seminar
        )
        
        # Mitarbeiter setzen
        if mitarbeiter_ids:
            geplantes_modul.mitarbeiter_ids = mitarbeiter_ids
        
        db.session.add(geplantes_modul)
        db.session.flush()  # Damit ID verfügbar ist
        
        # SWS berechnen
        sws_calculator.update_geplantes_modul_sws(geplantes_modul)
        
        # Planung Gesamt-SWS updaten
        sws_calculator.update_planung_gesamt_sws(planung_id)
        
        db.session.commit()
        
        return geplantes_modul
    
    def update_modul(
        self,
        geplantes_modul_id: int,
        **data
    ) -> Optional[GeplantesModul]:
        """
        Updated ein geplantes Modul
        
        Args:
            geplantes_modul_id: GeplantesModul ID
            **data: Felder die geupdated werden sollen
            
        Returns:
            Geupdatetes GeplantesModul oder None
            
        Example:
            >>> geplantes = planung_service.update_modul(
                    1,
                    anzahl_vorlesungen=3,
                    anmerkungen="Mehr Gruppen nötig"
                )
        """
        geplantes_modul = GeplantesModul.query.get(geplantes_modul_id)
        if not geplantes_modul:
            return None
        
        # Prüfe ob Planung bearbeitet werden kann
        if not geplantes_modul.semesterplanung.kann_bearbeitet_werden():
            raise ValueError("Planung kann nicht mehr bearbeitet werden")
        
        # Update Felder
        for key, value in data.items():
            if hasattr(geplantes_modul, key):
                setattr(geplantes_modul, key, value)
        
        # SWS neu berechnen wenn Multiplikatoren geändert
        if any(k in data for k in ['anzahl_vorlesungen', 'anzahl_uebungen', 
                                    'anzahl_praktika', 'anzahl_seminare']):
            sws_calculator.update_geplantes_modul_sws(geplantes_modul)
            sws_calculator.update_planung_gesamt_sws(geplantes_modul.semesterplanung_id)
        
        db.session.commit()
        
        return geplantes_modul
    
    def remove_modul(
        self,
        planung_id: int,
        modul_id: int
    ) -> bool:
        """
        Entfernt ein Modul aus der Planung
        
        Args:
            planung_id: Semesterplanung ID
            modul_id: Modul ID
            
        Returns:
            bool: True wenn erfolgreich
        """
        planung = self.get_by_id(planung_id)
        if not planung:
            return False
        
        # Prüfe ob Planung bearbeitet werden kann
        if not planung.kann_bearbeitet_werden():
            raise ValueError("Planung kann nicht mehr bearbeitet werden")
        
        # Finde geplantes Modul
        geplantes_modul = GeplantesModul.query.filter_by(
            semesterplanung_id=planung_id,
            modul_id=modul_id
        ).first()
        
        if not geplantes_modul:
            return False
        
        # Löschen
        db.session.delete(geplantes_modul)
        
        # Gesamt-SWS updaten
        sws_calculator.update_planung_gesamt_sws(planung_id)
        
        db.session.commit()
        
        return True
    
    # =========================================================================
    # WUNSCH-FREIE TAGE (Schritt 7)
    # =========================================================================
    
    def add_wunsch_freier_tag(
        self,
        planung_id: int,
        wochentag: str,
        prioritaet: int = 1,
        bemerkung: str = None
    ) -> WunschFreierTag:
        """
        Fügt einen Wunsch-freien Tag hinzu
        
        Args:
            planung_id: Semesterplanung ID
            wochentag: Wochentag ('montag', 'dienstag', etc.)
            prioritaet: Priorität (1=hoch, 2=mittel, 3=niedrig)
            bemerkung: Optional - Begründung
            
        Returns:
            WunschFreierTag: Neu erstellter Wunsch
            
        Raises:
            ValueError: Bei ungültigen Daten
        """
        planung = self.get_by_id(planung_id)
        if not planung:
            raise ValueError("Planung nicht gefunden")
        
        # Validiere Wochentag
        if not WunschFreierTag.is_valid_wochentag(wochentag):
            raise ValueError(f"Ungültiger Wochentag: {wochentag}")
        
        # Erstelle Wunsch
        wunsch = WunschFreierTag(
            semesterplanung_id=planung_id,
            wochentag=wochentag.lower(),
            prioritaet=prioritaet,
            bemerkung=bemerkung
        )
        
        db.session.add(wunsch)
        db.session.commit()
        
        return wunsch
    
    def remove_wunsch_freier_tag(
        self,
        wunsch_id: int
    ) -> bool:
        """
        Entfernt einen Wunsch-freien Tag
        
        Args:
            wunsch_id: WunschFreierTag ID
            
        Returns:
            bool: True wenn erfolgreich
        """
        wunsch = WunschFreierTag.query.get(wunsch_id)
        if not wunsch:
            return False
        
        db.session.delete(wunsch)
        db.session.commit()
        
        return True
    
    # =========================================================================
    # WORKFLOW (Schritt 8)
    # =========================================================================
    
    def einreichen(
        self,
        planung_id: int
    ) -> Semesterplanung:
        """
        Reicht Planung ein (Status: entwurf → eingereicht)

        Args:
            planung_id: Semesterplanung ID

        Returns:
            Semesterplanung mit neuem Status

        Raises:
            ValueError: Wenn Planung nicht eingereicht werden kann
        """
        planung = self.get_by_id(planung_id)
        if not planung:
            raise ValueError("Planung nicht gefunden")

        # Prüfe ob einreichbar
        if not planung.kann_eingereicht_werden():
            raise ValueError("Planung kann nicht eingereicht werden")

        # Finale SWS-Berechnung
        sws_calculator.update_alle_geplanten_module(planung_id)

        # Einreichen
        planung.einreichen()

        # Track submission in active planning phase
        from app.models.planungsphase import Planungsphase, PhaseSubmission
        active_phase = Planungsphase.get_active_phase()
        if active_phase:
            # Check if submission already exists
            existing = PhaseSubmission.query.filter_by(
                planungphase_id=active_phase.id,
                professor_id=planung.benutzer_id
            ).first()

            if not existing:
                # Create new submission record
                submission = PhaseSubmission(
                    planungphase_id=active_phase.id,
                    professor_id=planung.benutzer_id,
                    planung_id=planung_id,
                    status='eingereicht'
                )
                db.session.add(submission)

                # Update phase submission counter
                active_phase.anzahl_einreichungen = (active_phase.anzahl_einreichungen or 0) + 1

            else:
                # Update existing submission
                existing.planung_id = planung_id
                existing.status = 'eingereicht'
                existing.eingereicht_am = datetime.utcnow()

            db.session.commit()

        return planung
    
    def freigeben(
        self,
        planung_id: int,
        freigeber_id: int
    ) -> Semesterplanung:
        """
        Gibt Planung frei (nur Dekan!) (Status: eingereicht → freigegeben)

        Args:
            planung_id: Semesterplanung ID
            freigeber_id: Benutzer ID des Freigebers

        Returns:
            Freigegebene Semesterplanung

        Raises:
            ValueError: Wenn Planung nicht freigegeben werden kann
        """
        planung = self.get_by_id(planung_id)
        if not planung:
            raise ValueError("Planung nicht gefunden")

        # Prüfe ob freigegeben werden kann
        if not planung.kann_freigegeben_werden():
            raise ValueError(f"Planung im Status '{planung.status}' kann nicht freigegeben werden")

        # Freigeben
        planung.freigeben(freigeber_id)

        # Update PhaseSubmission status
        from app.models.planungsphase import Planungsphase, PhaseSubmission
        active_phase = Planungsphase.get_active_phase()
        if active_phase:
            submission = PhaseSubmission.query.filter_by(
                planungphase_id=active_phase.id,
                professor_id=planung.benutzer_id
            ).first()

            if submission:
                # Update existing submission
                submission.status = 'freigegeben'
                submission.freigegeben_am = datetime.utcnow()
                submission.freigegeben_von = freigeber_id

                # Update phase approval counter
                active_phase.anzahl_genehmigt = (active_phase.anzahl_genehmigt or 0) + 1
            else:
                # Create submission if it doesn't exist (for legacy data)
                submission = PhaseSubmission(
                    planungphase_id=active_phase.id,
                    professor_id=planung.benutzer_id,
                    planung_id=planung_id,
                    status='freigegeben',
                    eingereicht_am=planung.eingereicht_am or datetime.utcnow(),
                    freigegeben_am=datetime.utcnow(),
                    freigegeben_von=freigeber_id
                )
                db.session.add(submission)

                # Update phase counters
                active_phase.anzahl_einreichungen = (active_phase.anzahl_einreichungen or 0) + 1
                active_phase.anzahl_genehmigt = (active_phase.anzahl_genehmigt or 0) + 1

            db.session.commit()

        return planung
    
    def ablehnen(
        self,
        planung_id: int,
        grund: str = None
    ) -> Semesterplanung:
        """
        Lehnt Planung ab (nur Dekan!) (Status: eingereicht → abgelehnt)
        
        Args:
            planung_id: Semesterplanung ID
            grund: Optional - Ablehnungsgrund
            
        Returns:
            Abgelehnte Semesterplanung
            
        Raises:
            ValueError: Wenn Planung nicht abgelehnt werden kann
        """
        planung = self.get_by_id(planung_id)
        if not planung:
            raise ValueError("Planung nicht gefunden")
        
        # Prüfe ob abgelehnt werden kann
        if planung.status != 'eingereicht':
            raise ValueError("Nur eingereichte Planungen können abgelehnt werden")
        
        # Ablehnen
        planung.ablehnen(grund)
        
        return planung
    
    def zurueck_zu_entwurf(
        self,
        planung_id: int
    ) -> Semesterplanung:
        """
        Setzt Planung zurück auf Entwurf
        
        Args:
            planung_id: Semesterplanung ID
            
        Returns:
            Semesterplanung im Entwurf-Status
        """
        planung = self.get_by_id(planung_id)
        if not planung:
            raise ValueError("Planung nicht gefunden")
        
        planung.zurueck_zu_entwurf()
        
        return planung
    
    # =========================================================================
    # QUERIES
    # =========================================================================
    
    def get_by_semester_and_user(
        self,
        semester_id: int,
        benutzer_id: int
    ) -> Optional[Semesterplanung]:
        """
        Holt Planung für Semester und Benutzer
        
        Args:
            semester_id: Semester ID
            benutzer_id: Benutzer ID
            
        Returns:
            Semesterplanung oder None
        """
        return self.get_first(
            semester_id=semester_id,
            benutzer_id=benutzer_id
        )
    
    def get_by_semester(
        self,
        semester_id: int,
        status: str = None
    ) -> List[Semesterplanung]:
        """
        Holt alle Planungen für ein Semester
        
        Args:
            semester_id: Semester ID
            status: Optional - Filter nach Status
            
        Returns:
            Liste von Semesterplanungen
        """
        if status:
            return self.get_all(semester_id=semester_id, status=status)
        return self.get_all(semester_id=semester_id)
    
    def get_by_user(
        self,
        benutzer_id: int
    ) -> List[Semesterplanung]:
        """
        Holt alle Planungen eines Benutzers
        
        Args:
            benutzer_id: Benutzer ID
            
        Returns:
            Liste von Semesterplanungen
        """
        return self.get_all(benutzer_id=benutzer_id)
    
    def get_eingereichte(
        self,
        semester_id: Optional[int] = None
    ) -> List[Semesterplanung]:
        """
        Holt alle eingereichten Planungen
        
        Args:
            semester_id: Optional - Nur für dieses Semester
            
        Returns:
            Liste von eingereichten Semesterplanungen
        """
        if semester_id:
            return self.get_all(semester_id=semester_id, status='eingereicht')
        return self.get_all(status='eingereicht')
    
    def get_freigegebene(
        self,
        semester_id: Optional[int] = None
    ) -> List[Semesterplanung]:
        """
        Holt alle freigegebenen Planungen
        
        Args:
            semester_id: Optional - Nur für dieses Semester
            
        Returns:
            Liste von freigegebenen Semesterplanungen
        """
        if semester_id:
            return self.get_all(semester_id=semester_id, status='freigegeben')
        return self.get_all(status='freigegeben')
    
    # =========================================================================
    # STATISTICS
    # =========================================================================

    def get_statistik(
        self,
        semester_id: Optional[int] = None
    ) -> Dict[str, Any]:
        """
        Gibt Planungs-Statistiken zurück

        Args:
            semester_id: Optional - Nur für dieses Semester

        Returns:
            Dict mit Statistiken
        """
        filters = {'semester_id': semester_id} if semester_id else {}

        return {
            'gesamt': self.count(**filters),
            'entwurf': self.count(status='entwurf', **filters),
            'eingereicht': self.count(status='eingereicht', **filters),
            'freigegeben': self.count(status='freigegeben', **filters),
            'abgelehnt': self.count(status='abgelehnt', **filters),
        }

    # =========================================================================
    # FEATURE 2: SEMESTERAUFTRÄGE INTEGRATION
    # =========================================================================

    def get_planung_mit_auftraegen(
        self,
        planung_id: int
    ) -> Optional[Dict[str, Any]]:
        """
        Holt Planung mit integrierten Semesteraufträgen

        Args:
            planung_id: Semesterplanung ID

        Returns:
            Dict mit Planung-Daten + Aufträge + Gesamt-SWS (Module + Aufträge)
        """
        planung = self.get_by_id(planung_id)
        if not planung:
            return None

        # Hole genehmigte Aufträge für diesen Dozenten & Semester
        from app.services.auftrag_service import auftrag_service

        # Finde Dozent des Benutzers
        dozent_id = planung.benutzer.dozent_id if planung.benutzer and planung.benutzer.dozent else None

        auftraege = []
        auftraege_sws = 0.0

        if dozent_id:
            auftraege_list = auftrag_service.get_genehmigte_auftraege(
                semester_id=planung.semester_id,
                dozent_id=dozent_id
            )
            auftraege = [a.to_dict(include_details=True) for a in auftraege_list]
            auftraege_sws = sum(a.sws for a in auftraege_list)

        return {
            'planung': planung,
            'module_sws': planung.gesamt_sws,
            'auftraege': auftraege,
            'auftraege_sws': auftraege_sws,
            'gesamt_sws': planung.gesamt_sws + auftraege_sws
        }


# Singleton Instance
planung_service = PlanungService()