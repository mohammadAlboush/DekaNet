"""
Modul-Verwaltung Service
========================
Business Logic für Dekan-Modul-Verwaltung

Feature 3: Modul-Verwaltung
- Dozenten zu Modulen zuweisen/entfernen
- Änderungen protokollieren
- Ab nächstem Semester wirksam
"""

from typing import List, Dict, Optional, Any
from app.models import (
    db,
    Modul,
    ModulDozent,
    Dozent,
    Pruefungsordnung,
    ModulAuditLog,
    Semester
)
from app.services.base_service import BaseService
from datetime import datetime


class ModulVerwaltungService(BaseService):
    """Service für Modul-Verwaltung (Dekan)"""

    model = Modul

    # =========================================================================
    # MODULE MIT DOZENTEN ABRUFEN
    # =========================================================================

    def get_module_mit_dozenten(
        self,
        po_id: Optional[int] = None,
        nur_aktive: bool = True
    ) -> List[Dict[str, Any]]:
        """
        Holt alle Module mit ihren zugeordneten Dozenten

        Args:
            po_id: Optional - Filter nach Prüfungsordnung
            nur_aktive: Nur aktive Module (wird auf Dozenten angewendet)

        Returns:
            Liste von Modulen mit Dozenten-Zuordnungen
        """
        query = Modul.query

        # Note: Modul table has no 'aktiv' field, so we get all modules
        # and filter by active Dozenten instead if nur_aktive is True

        module = query.order_by(Modul.kuerzel).all()

        result = []
        for modul in module:
            # Hole Dozenten-Zuordnungen
            dozenten_query = ModulDozent.query.filter_by(modul_id=modul.id)

            if po_id:
                dozenten_query = dozenten_query.filter_by(po_id=po_id)

            dozenten_zuordnungen = dozenten_query.all()

            modul_dict = {
                'id': modul.id,
                'kuerzel': modul.kuerzel,
                'bezeichnung_de': modul.bezeichnung_de,
                'bezeichnung_en': modul.bezeichnung_en,
                'leistungspunkte': modul.leistungspunkte,
                'dozenten': []
            }

            for zuordnung in dozenten_zuordnungen:
                if zuordnung.dozent:
                    # Filter by active Dozenten if nur_aktive is True
                    if nur_aktive and not zuordnung.dozent.aktiv:
                        continue

                    modul_dict['dozenten'].append({
                        'id': zuordnung.dozent.id,
                        'name': zuordnung.dozent.name_komplett,
                        'name_kurz': zuordnung.dozent.name_kurz,
                        'rolle': zuordnung.rolle,
                        'zuordnung_id': zuordnung.id,
                        'po_id': zuordnung.po_id,
                        'vertreter_id': zuordnung.vertreter_id,
                        'zweitpruefer_id': zuordnung.zweitpruefer_id,
                    })

            result.append(modul_dict)

        return result

    # =========================================================================
    # DOZENT HINZUFÜGEN
    # =========================================================================

    def add_dozent_to_modul(
        self,
        modul_id: int,
        po_id: int,
        dozent_id: int,
        rolle: str,
        geaendert_von_id: int,
        bemerkung: Optional[str] = None
    ) -> ModulDozent:
        """
        Fügt einen Dozenten zu einem Modul hinzu

        Args:
            modul_id: ID des Moduls
            po_id: ID der Prüfungsordnung
            dozent_id: ID des Dozenten
            rolle: Rolle ('verantwortlich', 'mitwirkend', etc.)
            geaendert_von_id: ID des Benutzers (Dekan)
            bemerkung: Optionale Bemerkung

        Returns:
            ModulDozent: Neue Zuordnung

        Raises:
            ValueError: Bei fehlenden/ungültigen Daten
        """
        # Validierung
        modul = Modul.query.get(modul_id)
        if not modul:
            raise ValueError(f"Modul {modul_id} nicht gefunden")

        dozent = Dozent.query.get(dozent_id)
        if not dozent:
            raise ValueError(f"Dozent {dozent_id} nicht gefunden")

        po = Pruefungsordnung.query.get(po_id)
        if not po:
            raise ValueError(f"Prüfungsordnung {po_id} nicht gefunden")

        # Prüfe ob Zuordnung bereits existiert
        existing = ModulDozent.query.filter_by(
            modul_id=modul_id,
            po_id=po_id,
            dozent_id=dozent_id,
            rolle=rolle
        ).first()

        if existing:
            raise ValueError(
                f"Dozent {dozent.name_komplett} ist bereits als '{rolle}' "
                f"für Modul {modul.kuerzel} zugeordnet"
            )

        # Erstelle neue Zuordnung
        zuordnung = ModulDozent(
            modul_id=modul_id,
            po_id=po_id,
            dozent_id=dozent_id,
            rolle=rolle
        )

        db.session.add(zuordnung)

        # Audit Log
        ModulAuditLog.log_dozent_hinzugefuegt(
            modul_id=modul_id,
            po_id=po_id,
            dozent_id=dozent_id,
            rolle=rolle,
            geaendert_von_id=geaendert_von_id,
            bemerkung=bemerkung
        )

        db.session.commit()

        return zuordnung

    # =========================================================================
    # DOZENT ENTFERNEN
    # =========================================================================

    def remove_dozent_from_modul(
        self,
        zuordnung_id: int,
        geaendert_von_id: int,
        bemerkung: Optional[str] = None
    ) -> bool:
        """
        Entfernt einen Dozenten von einem Modul

        Args:
            zuordnung_id: ID der ModulDozent-Zuordnung
            geaendert_von_id: ID des Benutzers (Dekan)
            bemerkung: Optionale Bemerkung

        Returns:
            bool: True wenn erfolgreich

        Raises:
            ValueError: Wenn Zuordnung nicht gefunden
        """
        zuordnung = ModulDozent.query.get(zuordnung_id)
        if not zuordnung:
            raise ValueError(f"Zuordnung {zuordnung_id} nicht gefunden")

        # Audit Log BEVOR wir löschen
        ModulAuditLog.log_dozent_entfernt(
            modul_id=zuordnung.modul_id,
            po_id=zuordnung.po_id,
            dozent_id=zuordnung.dozent_id,
            rolle=zuordnung.rolle,
            geaendert_von_id=geaendert_von_id,
            bemerkung=bemerkung
        )

        db.session.delete(zuordnung)
        db.session.commit()

        return True

    # =========================================================================
    # DOZENT ERSETZEN
    # =========================================================================

    def replace_dozent(
        self,
        zuordnung_id: int,
        neuer_dozent_id: int,
        geaendert_von_id: int,
        bemerkung: Optional[str] = None
    ) -> ModulDozent:
        """
        Ersetzt einen Dozenten durch einen anderen

        Args:
            zuordnung_id: ID der bestehenden Zuordnung
            neuer_dozent_id: ID des neuen Dozenten
            geaendert_von_id: ID des Benutzers (Dekan)
            bemerkung: Optionale Bemerkung

        Returns:
            ModulDozent: Aktualisierte Zuordnung

        Raises:
            ValueError: Bei Fehler
        """
        zuordnung = ModulDozent.query.get(zuordnung_id)
        if not zuordnung:
            raise ValueError(f"Zuordnung {zuordnung_id} nicht gefunden")

        neuer_dozent = Dozent.query.get(neuer_dozent_id)
        if not neuer_dozent:
            raise ValueError(f"Dozent {neuer_dozent_id} nicht gefunden")

        # Prüfe ob neuer Dozent bereits zugeordnet ist
        existing = ModulDozent.query.filter_by(
            modul_id=zuordnung.modul_id,
            po_id=zuordnung.po_id,
            dozent_id=neuer_dozent_id,
            rolle=zuordnung.rolle
        ).first()

        if existing:
            raise ValueError(
                f"Dozent {neuer_dozent.name_komplett} ist bereits "
                f"als '{zuordnung.rolle}' zugeordnet"
            )

        # Speichere alten Dozenten für Audit Log
        alter_dozent_id = zuordnung.dozent_id

        # Ersetze Dozenten
        zuordnung.dozent_id = neuer_dozent_id

        # Audit Log
        ModulAuditLog.log_dozent_ersetzt(
            modul_id=zuordnung.modul_id,
            po_id=zuordnung.po_id,
            alt_dozent_id=alter_dozent_id,
            neu_dozent_id=neuer_dozent_id,
            rolle=zuordnung.rolle,
            geaendert_von_id=geaendert_von_id,
            bemerkung=bemerkung
        )

        db.session.commit()

        return zuordnung

    # =========================================================================
    # AUDIT LOG ABRUFEN
    # =========================================================================

    def get_audit_log(
        self,
        modul_id: Optional[int] = None,
        dozent_id: Optional[int] = None,
        limit: int = 100
    ) -> List[Dict[str, Any]]:
        """
        Holt Audit Log Einträge

        Args:
            modul_id: Optional - Filter nach Modul
            dozent_id: Optional - Filter nach Dozent
            limit: Maximale Anzahl Einträge

        Returns:
            Liste von Audit Log Einträgen
        """
        query = ModulAuditLog.query

        if modul_id:
            query = query.filter_by(modul_id=modul_id)

        if dozent_id:
            query = query.filter(
                (ModulAuditLog.alt_dozent_id == dozent_id) |
                (ModulAuditLog.neu_dozent_id == dozent_id)
            )

        logs = query.order_by(ModulAuditLog.created_at.desc()).limit(limit).all()

        return [log.to_dict() for log in logs]

    # =========================================================================
    # BULK OPERATIONS
    # =========================================================================

    def bulk_transfer_module(
        self,
        modul_ids: List[int],
        von_dozent_id: int,
        zu_dozent_id: int,
        po_id: int,
        geaendert_von_id: int,
        rolle: str = 'verantwortlich',
        bemerkung: Optional[str] = None
    ) -> Dict[str, Any]:
        """
        Überträgt mehrere Module von einem Dozenten zu einem anderen

        Args:
            modul_ids: Liste von Modul-IDs
            von_dozent_id: Alter Dozent
            zu_dozent_id: Neuer Dozent
            po_id: Prüfungsordnung
            geaendert_von_id: Dekan
            rolle: Rolle (default: 'verantwortlich')
            bemerkung: Optionale Bemerkung

        Returns:
            Dict mit Statistik (erfolgreich, fehlgeschlagen)
        """
        erfolgreich = []
        fehlgeschlagen = []

        for modul_id in modul_ids:
            try:
                # Finde bestehende Zuordnung
                zuordnung = ModulDozent.query.filter_by(
                    modul_id=modul_id,
                    po_id=po_id,
                    dozent_id=von_dozent_id,
                    rolle=rolle
                ).first()

                if not zuordnung:
                    fehlgeschlagen.append({
                        'modul_id': modul_id,
                        'fehler': f"Dozent {von_dozent_id} ist nicht als '{rolle}' zugeordnet"
                    })
                    continue

                # Ersetze Dozenten
                self.replace_dozent(
                    zuordnung_id=zuordnung.id,
                    neuer_dozent_id=zu_dozent_id,
                    geaendert_von_id=geaendert_von_id,
                    bemerkung=bemerkung
                )

                erfolgreich.append(modul_id)

            except Exception as e:
                fehlgeschlagen.append({
                    'modul_id': modul_id,
                    'fehler': str(e)
                })

        return {
            'erfolgreich': erfolgreich,
            'fehlgeschlagen': fehlgeschlagen,
            'gesamt': len(modul_ids),
            'erfolgreich_count': len(erfolgreich),
            'fehlgeschlagen_count': len(fehlgeschlagen)
        }


# Singleton Instance
modul_verwaltung_service = ModulVerwaltungService()
