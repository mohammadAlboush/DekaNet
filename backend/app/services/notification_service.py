"""
Notification Service
====================
Business Logic für Benachrichtigungen.

Funktionen:
- Benachrichtigungen erstellen
- Benachrichtigungen als gelesen markieren
- Ungelesene Benachrichtigungen holen
"""

from typing import Optional, List, Dict, Any
from datetime import datetime, timedelta
from app.services.base_service import BaseService
from app.models import Benachrichtigung, Benutzer
from app.extensions import db


class NotificationService(BaseService):
    """
    Notification Service
    
    Verwaltet Benachrichtigungen für Benutzer.
    """
    
    model = Benachrichtigung
    
    # Notification Types
    TYPES = {
        'planung_eingereicht': 'Semesterplanung eingereicht',
        'planung_freigegeben': 'Semesterplanung freigegeben',
        'planung_abgelehnt': 'Semesterplanung abgelehnt',
        'planungsphase_geoeffnet': 'Planungsphase geöffnet',
        'planungsphase_geschlossen': 'Planungsphase geschlossen',
        'erinnerung': 'Erinnerung',
        'system': 'System-Benachrichtigung',
    }
    
    # =========================================================================
    # NOTIFICATION CREATION
    # =========================================================================
    
    def create_notification(
        self,
        empfaenger_id: int,
        typ: str,
        titel: str,
        nachricht: str = None
    ) -> Benachrichtigung:
        """
        Erstellt eine neue Benachrichtigung
        
        Args:
            empfaenger_id: Benutzer ID des Empfängers
            typ: Typ der Benachrichtigung
            titel: Titel
            nachricht: Optional - Nachricht
            
        Returns:
            Benachrichtigung: Neue Benachrichtigung
            
        Example:
            >>> notification = notification_service.create_notification(
                    empfaenger_id=1,
                    typ='planung_freigegeben',
                    titel='Ihre Planung wurde freigegeben',
                    nachricht='Die Semesterplanung für WS2025 wurde freigegeben.'
                )
        """
        # Validiere Typ
        if typ not in self.TYPES:
            raise ValueError(f"Ungültiger Notification-Typ: {typ}")
        
        # Erstelle Benachrichtigung
        notification = self.create(
            empfaenger_id=empfaenger_id,
            typ=typ,
            titel=titel,
            nachricht=nachricht,
            gelesen=False
        )
        
        return notification
    
    def create_bulk(
        self,
        empfaenger_ids: List[int],
        typ: str,
        titel: str,
        nachricht: str = None
    ) -> List[Benachrichtigung]:
        """
        Erstellt Benachrichtigungen für mehrere Empfänger
        
        Args:
            empfaenger_ids: Liste von Benutzer IDs
            typ: Typ der Benachrichtigung
            titel: Titel
            nachricht: Optional - Nachricht
            
        Returns:
            Liste von Benachrichtigungen
            
        Example:
            >>> notifications = notification_service.create_bulk(
                    empfaenger_ids=[1, 2, 3],
                    typ='planungsphase_geoeffnet',
                    titel='Planungsphase ist geöffnet',
                    nachricht='Sie können jetzt Ihre Semesterplanung erstellen.'
                )
        """
        notifications = []
        for empfaenger_id in empfaenger_ids:
            notification = self.create_notification(
                empfaenger_id=empfaenger_id,
                typ=typ,
                titel=titel,
                nachricht=nachricht
            )
            notifications.append(notification)
        
        return notifications
    
    # =========================================================================
    # SPECIFIC NOTIFICATIONS
    # =========================================================================
    
    def notify_planung_eingereicht(
        self,
        benutzer_id: int,
        semester_kuerzel: str
    ) -> Benachrichtigung:
        """
        Benachrichtigt über eingereichte Planung
        
        Args:
            benutzer_id: Benutzer ID
            semester_kuerzel: Semester-Kürzel
            
        Returns:
            Benachrichtigung
        """
        return self.create_notification(
            empfaenger_id=benutzer_id,
            typ='planung_eingereicht',
            titel=f'Planung für {semester_kuerzel} eingereicht',
            nachricht=f'Ihre Semesterplanung für {semester_kuerzel} wurde eingereicht und wartet auf Freigabe.'
        )
    
    def notify_planung_freigegeben(
        self,
        benutzer_id: int,
        semester_kuerzel: str
    ) -> Benachrichtigung:
        """
        Benachrichtigt über freigegebene Planung
        
        Args:
            benutzer_id: Benutzer ID
            semester_kuerzel: Semester-Kürzel
            
        Returns:
            Benachrichtigung
        """
        return self.create_notification(
            empfaenger_id=benutzer_id,
            typ='planung_freigegeben',
            titel=f'Planung für {semester_kuerzel} freigegeben',
            nachricht=f'Ihre Semesterplanung für {semester_kuerzel} wurde freigegeben.'
        )
    
    def notify_planung_abgelehnt(
        self,
        benutzer_id: int,
        semester_kuerzel: str,
        grund: str = None
    ) -> Benachrichtigung:
        """
        Benachrichtigt über abgelehnte Planung
        
        Args:
            benutzer_id: Benutzer ID
            semester_kuerzel: Semester-Kürzel
            grund: Optional - Ablehnungsgrund
            
        Returns:
            Benachrichtigung
        """
        nachricht = f'Ihre Semesterplanung für {semester_kuerzel} wurde abgelehnt.'
        if grund:
            nachricht += f'\n\nGrund: {grund}'
        
        return self.create_notification(
            empfaenger_id=benutzer_id,
            typ='planung_abgelehnt',
            titel=f'Planung für {semester_kuerzel} abgelehnt',
            nachricht=nachricht
        )
    
    def notify_planungsphase_geoeffnet(
        self,
        semester_kuerzel: str,
        alle_dozenten: bool = True
    ) -> List[Benachrichtigung]:
        """
        Benachrichtigt über geöffnete Planungsphase
        
        Args:
            semester_kuerzel: Semester-Kürzel
            alle_dozenten: Alle Dozenten benachrichtigen?
            
        Returns:
            Liste von Benachrichtigungen
        """
        if alle_dozenten:
            # Hole alle Dozenten (Professoren + Lehrbeauftragte)
            from app.services.user_service import user_service
            dozenten = user_service.get_dozenten()
            empfaenger_ids = [d.id for d in dozenten]
        else:
            empfaenger_ids = []
        
        return self.create_bulk(
            empfaenger_ids=empfaenger_ids,
            typ='planungsphase_geoeffnet',
            titel=f'Planungsphase für {semester_kuerzel} geöffnet',
            nachricht=f'Die Planungsphase für {semester_kuerzel} ist jetzt geöffnet. Sie können Ihre Semesterplanung erstellen.'
        )
    
    def notify_dekan_neue_planung(
        self,
        dozent_name: str,
        semester_kuerzel: str
    ) -> List[Benachrichtigung]:
        """
        Benachrichtigt Dekane über neue eingereichte Planung
        
        Args:
            dozent_name: Name des Dozenten
            semester_kuerzel: Semester-Kürzel
            
        Returns:
            Liste von Benachrichtigungen
        """
        from app.services.user_service import user_service
        dekane = user_service.get_dekane()
        empfaenger_ids = [d.id for d in dekane]
        
        return self.create_bulk(
            empfaenger_ids=empfaenger_ids,
            typ='planung_eingereicht',
            titel=f'Neue Planung von {dozent_name}',
            nachricht=f'{dozent_name} hat eine Semesterplanung für {semester_kuerzel} eingereicht.'
        )
    
    # =========================================================================
    # NOTIFICATION STATUS
    # =========================================================================
    
    def markiere_gelesen(
        self,
        notification_id: int
    ) -> bool:
        """
        Markiert Benachrichtigung als gelesen
        
        Args:
            notification_id: Benachrichtigung ID
            
        Returns:
            bool: True wenn erfolgreich
        """
        notification = self.get_by_id(notification_id)
        if not notification:
            return False
        
        notification.markiere_gelesen()
        return True
    
    def markiere_alle_gelesen(
        self,
        benutzer_id: int
    ) -> int:
        """
        Markiert alle Benachrichtigungen eines Benutzers als gelesen
        
        Args:
            benutzer_id: Benutzer ID
            
        Returns:
            int: Anzahl markierter Benachrichtigungen
        """
        ungelesen = self.get_ungelesene(benutzer_id)
        
        for notification in ungelesen:
            notification.markiere_gelesen()
        
        return len(ungelesen)
    
    def delete_notification(
        self,
        notification_id: int
    ) -> bool:
        """
        Löscht eine Benachrichtigung
        
        Args:
            notification_id: Benachrichtigung ID
            
        Returns:
            bool: True wenn erfolgreich
        """
        return self.delete(notification_id)
    
    # =========================================================================
    # QUERIES
    # =========================================================================
    
    def get_by_user(
        self,
        benutzer_id: int,
        limit: Optional[int] = None
    ) -> List[Benachrichtigung]:
        """
        Holt alle Benachrichtigungen eines Benutzers
        
        Args:
            benutzer_id: Benutzer ID
            limit: Optional - Maximum Anzahl
            
        Returns:
            Liste von Benachrichtigungen
        """
        query = Benachrichtigung.query.filter_by(
            empfaenger_id=benutzer_id
        ).order_by(Benachrichtigung.erstellt_am.desc())
        
        if limit:
            query = query.limit(limit)
        
        return query.all()
    
    def get_ungelesene(
        self,
        benutzer_id: int
    ) -> List[Benachrichtigung]:
        """
        Holt alle ungelesenen Benachrichtigungen
        
        Args:
            benutzer_id: Benutzer ID
            
        Returns:
            Liste von ungelesenen Benachrichtigungen
        """
        return Benachrichtigung.query.filter_by(
            empfaenger_id=benutzer_id,
            gelesen=False
        ).order_by(Benachrichtigung.erstellt_am.desc()).all()
    
    def get_gelesene(
        self,
        benutzer_id: int,
        limit: Optional[int] = 10
    ) -> List[Benachrichtigung]:
        """
        Holt gelesene Benachrichtigungen
        
        Args:
            benutzer_id: Benutzer ID
            limit: Optional - Maximum Anzahl
            
        Returns:
            Liste von gelesenen Benachrichtigungen
        """
        query = Benachrichtigung.query.filter_by(
            empfaenger_id=benutzer_id,
            gelesen=True
        ).order_by(Benachrichtigung.gelesen_am.desc())
        
        if limit:
            query = query.limit(limit)
        
        return query.all()
    
    def get_by_typ(
        self,
        benutzer_id: int,
        typ: str
    ) -> List[Benachrichtigung]:
        """
        Holt Benachrichtigungen nach Typ
        
        Args:
            benutzer_id: Benutzer ID
            typ: Notification-Typ
            
        Returns:
            Liste von Benachrichtigungen
        """
        return Benachrichtigung.query.filter_by(
            empfaenger_id=benutzer_id,
            typ=typ
        ).order_by(Benachrichtigung.erstellt_am.desc()).all()
    
    # =========================================================================
    # STATISTICS
    # =========================================================================
    
    def count_ungelesene(
        self,
        benutzer_id: int
    ) -> int:
        """
        Zählt ungelesene Benachrichtigungen
        
        Args:
            benutzer_id: Benutzer ID
            
        Returns:
            int: Anzahl ungelesener Benachrichtigungen
        """
        return Benachrichtigung.query.filter_by(
            empfaenger_id=benutzer_id,
            gelesen=False
        ).count()
    
    def get_statistik(
        self,
        benutzer_id: int
    ) -> Dict[str, Any]:
        """
        Gibt Benachrichtigungs-Statistiken zurück
        
        Args:
            benutzer_id: Benutzer ID
            
        Returns:
            Dict mit Statistiken
        """
        return {
            'gesamt': Benachrichtigung.query.filter_by(
                empfaenger_id=benutzer_id
            ).count(),
            'ungelesen': self.count_ungelesene(benutzer_id),
            'gelesen': Benachrichtigung.query.filter_by(
                empfaenger_id=benutzer_id,
                gelesen=True
            ).count(),
        }
    
    # =========================================================================
    # CLEANUP
    # =========================================================================
    
    def delete_alte_benachrichtigungen(
        self,
        tage: int = 30
    ) -> int:
        """
        Löscht alte gelesene Benachrichtigungen
        
        Args:
            tage: Löscht Benachrichtigungen älter als X Tage
            
        Returns:
            int: Anzahl gelöschter Benachrichtigungen
        """
        grenze = datetime.utcnow() - timedelta(days=tage)
        
        alte = Benachrichtigung.query.filter(
            Benachrichtigung.gelesen == True,
            Benachrichtigung.gelesen_am < grenze
        ).all()
        
        count = len(alte)
        for notification in alte:
            db.session.delete(notification)
        
        db.session.commit()
        
        return count


# Singleton Instance
notification_service = NotificationService()