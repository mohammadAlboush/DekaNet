"""
Auftrag Service
===============

Business Logic für Semesteraufträge (Feature 2)

Funktionen:
- Auftrag-Verwaltung (CRUD für Dekan)
- Semester-Auftrag-Verwaltung (Beantragen, Genehmigen, Ablehnen)
- SWS-Berechnung in Semesterplanung integrieren
- Historisierung & Statistiken
"""

from typing import Optional, List, Dict, Any
from datetime import datetime
from app.services.base_service import BaseService
from app.models import Auftrag, SemesterAuftrag, Semester, Dozent, Benutzer
from app.extensions import db


class AuftragService(BaseService):
    """
    Auftrag Service

    Verwaltet Aufträge und deren Zuordnungen zu Dozenten pro Semester
    """

    model = Auftrag

    # =========================================================================
    # AUFTRAG MASTER-LISTE (Dekan-Verwaltung)
    # =========================================================================

    def get_all_auftraege(self, nur_aktive: bool = True) -> List[Auftrag]:
        """
        Holt alle Aufträge aus Master-Liste

        Args:
            nur_aktive: Nur aktive Aufträge (default: True)

        Returns:
            Liste von Aufträgen
        """
        query = Auftrag.query
        if nur_aktive:
            query = query.filter_by(ist_aktiv=True)
        return query.order_by(Auftrag.sortierung, Auftrag.name).all()

    def create_auftrag(
        self,
        name: str,
        standard_sws: float = 0.0,
        beschreibung: str = None,
        sortierung: int = None
    ) -> Auftrag:
        """
        Erstellt einen neuen Auftrag (nur Dekan)

        Args:
            name: Eindeutiger Name
            standard_sws: Standard-SWS
            beschreibung: Beschreibung
            sortierung: Sortier-Reihenfolge

        Returns:
            Neu erstellter Auftrag

        Raises:
            ValueError: Wenn Auftrag bereits existiert
        """
        # Prüfe ob Name bereits existiert
        existing = Auftrag.query.filter_by(name=name).first()
        if existing:
            raise ValueError(f"Auftrag '{name}' existiert bereits")

        auftrag = Auftrag(
            name=name,
            standard_sws=standard_sws,
            beschreibung=beschreibung,
            sortierung=sortierung,
            ist_aktiv=True
        )

        db.session.add(auftrag)
        db.session.commit()

        return auftrag

    def update_auftrag(
        self,
        auftrag_id: int,
        **data
    ) -> Optional[Auftrag]:
        """
        Aktualisiert einen Auftrag

        Args:
            auftrag_id: Auftrag ID
            **data: Felder zum Aktualisieren

        Returns:
            Aktualisierter Auftrag oder None
        """
        auftrag = self.get_by_id(auftrag_id)
        if not auftrag:
            return None

        updateable_fields = ['name', 'beschreibung', 'standard_sws', 'ist_aktiv', 'sortierung']

        for field in updateable_fields:
            if field in data:
                setattr(auftrag, field, data[field])

        db.session.commit()
        return auftrag

    def delete_auftrag(self, auftrag_id: int) -> bool:
        """
        Löscht einen Auftrag (nur wenn keine Zuordnungen existieren)

        Args:
            auftrag_id: Auftrag ID

        Returns:
            True wenn erfolgreich

        Raises:
            ValueError: Wenn Zuordnungen existieren
        """
        auftrag = self.get_by_id(auftrag_id)
        if not auftrag:
            return False

        # Prüfe ob Zuordnungen existieren
        zuordnungen_count = SemesterAuftrag.query.filter_by(auftrag_id=auftrag_id).count()
        if zuordnungen_count > 0:
            raise ValueError(
                f"Auftrag kann nicht gelöscht werden: {zuordnungen_count} Zuordnungen existieren"
            )

        return self.delete(auftrag_id)

    # =========================================================================
    # SEMESTER-AUFTRAG VERWALTUNG
    # =========================================================================

    def beantrage_auftrag(
        self,
        semester_id: int,
        auftrag_id: int,
        dozent_id: int,
        beantragt_von_id: int,
        sws: float = None,
        anmerkung: str = None
    ) -> SemesterAuftrag:
        """
        Professor beantragt einen Auftrag für sich selbst

        Args:
            semester_id: Semester ID
            auftrag_id: Auftrag ID
            dozent_id: Dozent ID (sollte = beantragt_von.dozent_id sein)
            beantragt_von_id: Benutzer ID des Antragstellers
            sws: Gewünschte SWS (optional, sonst standard_sws)
            anmerkung: Begründung

        Returns:
            Neu erstellter SemesterAuftrag

        Raises:
            ValueError: Bei Validierungsfehlern
        """
        # Validiere Semester
        semester = Semester.query.get(semester_id)
        if not semester:
            raise ValueError("Semester nicht gefunden")

        # Validiere Auftrag
        auftrag = self.get_by_id(auftrag_id)
        if not auftrag:
            raise ValueError("Auftrag nicht gefunden")

        if not auftrag.ist_aktiv:
            raise ValueError("Auftrag ist nicht aktiv")

        # Validiere Dozent
        dozent = Dozent.query.get(dozent_id)
        if not dozent:
            raise ValueError("Dozent nicht gefunden")

        # Prüfe ob bereits existiert
        existing = SemesterAuftrag.query.filter_by(
            semester_id=semester_id,
            auftrag_id=auftrag_id,
            dozent_id=dozent_id
        ).first()

        if existing:
            raise ValueError(
                f"Auftrag '{auftrag.name}' wurde bereits für dieses Semester beantragt"
            )

        # Verwende standard_sws wenn nicht angegeben
        if sws is None:
            sws = auftrag.standard_sws

        # Erstelle SemesterAuftrag
        semester_auftrag = SemesterAuftrag(
            semester_id=semester_id,
            auftrag_id=auftrag_id,
            dozent_id=dozent_id,
            sws=sws,
            status='beantragt',
            beantragt_von=beantragt_von_id,
            anmerkung=anmerkung
        )

        db.session.add(semester_auftrag)
        db.session.commit()

        return semester_auftrag

    def genehmige_auftrag(
        self,
        semester_auftrag_id: int,
        genehmigt_von_id: int
    ) -> SemesterAuftrag:
        """
        Dekan genehmigt einen beantragten Auftrag

        Args:
            semester_auftrag_id: SemesterAuftrag ID
            genehmigt_von_id: Benutzer ID des Dekans

        Returns:
            Genehmigter SemesterAuftrag

        Raises:
            ValueError: Wenn nicht genehmigungsfähig
        """
        semester_auftrag = SemesterAuftrag.query.get(semester_auftrag_id)
        if not semester_auftrag:
            raise ValueError("Semester-Auftrag nicht gefunden")

        if semester_auftrag.status != 'beantragt':
            raise ValueError(
                f"Auftrag kann nicht genehmigt werden. Status: {semester_auftrag.status}"
            )

        semester_auftrag.genehmigen(genehmigt_von_id)
        db.session.commit()

        return semester_auftrag

    def lehne_auftrag_ab(
        self,
        semester_auftrag_id: int,
        genehmigt_von_id: int,
        grund: str = None
    ) -> SemesterAuftrag:
        """
        Dekan lehnt einen beantragten Auftrag ab

        Args:
            semester_auftrag_id: SemesterAuftrag ID
            genehmigt_von_id: Benutzer ID des Dekans
            grund: Ablehnungsgrund

        Returns:
            Abgelehnter SemesterAuftrag

        Raises:
            ValueError: Wenn nicht ablehnbar
        """
        semester_auftrag = SemesterAuftrag.query.get(semester_auftrag_id)
        if not semester_auftrag:
            raise ValueError("Semester-Auftrag nicht gefunden")

        if semester_auftrag.status != 'beantragt':
            raise ValueError(
                f"Auftrag kann nicht abgelehnt werden. Status: {semester_auftrag.status}"
            )

        semester_auftrag.ablehnen(genehmigt_von_id, grund)
        db.session.commit()

        return semester_auftrag

    def update_semester_auftrag(
        self,
        semester_auftrag_id: int,
        **data
    ) -> Optional[SemesterAuftrag]:
        """
        Aktualisiert einen Semester-Auftrag (z.B. SWS anpassen)

        Args:
            semester_auftrag_id: SemesterAuftrag ID
            **data: Felder zum Aktualisieren

        Returns:
            Aktualisierter SemesterAuftrag oder None
        """
        semester_auftrag = SemesterAuftrag.query.get(semester_auftrag_id)
        if not semester_auftrag:
            return None

        updateable_fields = ['sws', 'anmerkung']

        for field in updateable_fields:
            if field in data:
                setattr(semester_auftrag, field, data[field])

        db.session.commit()
        return semester_auftrag

    def delete_semester_auftrag(self, semester_auftrag_id: int) -> bool:
        """
        Löscht einen Semester-Auftrag

        Args:
            semester_auftrag_id: SemesterAuftrag ID

        Returns:
            True wenn erfolgreich
        """
        semester_auftrag = SemesterAuftrag.query.get(semester_auftrag_id)
        if not semester_auftrag:
            return False

        db.session.delete(semester_auftrag)
        db.session.commit()

        return True

    # =========================================================================
    # QUERIES
    # =========================================================================

    def get_auftraege_fuer_semester(
        self,
        semester_id: int,
        dozent_id: int = None,
        status: str = None
    ) -> List[SemesterAuftrag]:
        """
        Holt alle Aufträge für ein Semester

        Args:
            semester_id: Semester ID
            dozent_id: Optional - Nur für diesen Dozenten
            status: Optional - Filter nach Status

        Returns:
            Liste von SemesterAuftrag
        """
        query = SemesterAuftrag.query.filter_by(semester_id=semester_id)

        if dozent_id:
            query = query.filter_by(dozent_id=dozent_id)

        if status:
            query = query.filter_by(status=status)

        return query.all()

    def get_auftraege_fuer_dozent(
        self,
        dozent_id: int,
        semester_id: int = None
    ) -> List[SemesterAuftrag]:
        """
        Holt alle Aufträge eines Dozenten

        Args:
            dozent_id: Dozent ID
            semester_id: Optional - Nur für dieses Semester

        Returns:
            Liste von SemesterAuftrag
        """
        query = SemesterAuftrag.query.filter_by(dozent_id=dozent_id)

        if semester_id:
            query = query.filter_by(semester_id=semester_id)

        return query.order_by(SemesterAuftrag.created_at.desc()).all()

    def get_beantragte_auftraege(self, semester_id: int = None) -> List[SemesterAuftrag]:
        """
        Holt alle beantragten (noch nicht genehmigten) Aufträge

        Args:
            semester_id: Optional - Nur für dieses Semester

        Returns:
            Liste von beantragten SemesterAuftrag
        """
        query = SemesterAuftrag.query.filter_by(status='beantragt')

        if semester_id:
            query = query.filter_by(semester_id=semester_id)

        return query.order_by(SemesterAuftrag.created_at.desc()).all()

    def get_genehmigte_auftraege(
        self,
        semester_id: int = None,
        dozent_id: int = None
    ) -> List[SemesterAuftrag]:
        """
        Holt alle genehmigten Aufträge

        Args:
            semester_id: Optional - Nur für dieses Semester
            dozent_id: Optional - Nur für diesen Dozenten

        Returns:
            Liste von genehmigten SemesterAuftrag
        """
        query = SemesterAuftrag.query.filter_by(status='genehmigt')

        if semester_id:
            query = query.filter_by(semester_id=semester_id)

        if dozent_id:
            query = query.filter_by(dozent_id=dozent_id)

        return query.all()

    # =========================================================================
    # SWS-BERECHNUNG
    # =========================================================================

    def berechne_gesamt_sws_fuer_dozent(
        self,
        dozent_id: int,
        semester_id: int
    ) -> float:
        """
        Berechnet Gesamt-SWS aus genehmigten Aufträgen für einen Dozenten

        Args:
            dozent_id: Dozent ID
            semester_id: Semester ID

        Returns:
            Gesamt-SWS aus Aufträgen
        """
        genehmigte = self.get_genehmigte_auftraege(
            semester_id=semester_id,
            dozent_id=dozent_id
        )

        return sum(auftrag.sws for auftrag in genehmigte)

    # =========================================================================
    # STATISTIKEN
    # =========================================================================

    def get_statistik(self, semester_id: int = None) -> Dict[str, Any]:
        """
        Gibt Statistiken zu Aufträgen zurück

        Args:
            semester_id: Optional - Nur für dieses Semester

        Returns:
            Dict mit Statistiken
        """
        filters = {'semester_id': semester_id} if semester_id else {}

        query = SemesterAuftrag.query
        if semester_id:
            query = query.filter_by(semester_id=semester_id)

        return {
            'gesamt': query.count(),
            'beantragt': query.filter_by(status='beantragt').count(),
            'genehmigt': query.filter_by(status='genehmigt').count(),
            'abgelehnt': query.filter_by(status='abgelehnt').count(),
            'gesamt_sws_genehmigt': db.session.query(
                db.func.sum(SemesterAuftrag.sws)
            ).filter_by(status='genehmigt', **filters).scalar() or 0.0
        }


# Singleton Instance
auftrag_service = AuftragService()
