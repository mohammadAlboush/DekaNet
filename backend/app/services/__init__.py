"""
Service Layer - Business Logic und Use Cases
=============================================

Alle Services sind hier als Singleton-Instanzen verfügbar.

Usage:
    from app.services import user_service, planung_service
    
    user = user_service.get_by_id(1)
    planung = planung_service.get_or_create_planung(semester_id, benutzer_id)
"""

# Import Base Service
from app.services.base_service import BaseService

# Import Service Classes
from app.services.user_service import UserService
from app.services.semester_service import SemesterService
from app.services.modul_service import ModulService
from app.services.dozent_service import DozentService
from app.services.planung_service import PlanungService
from app.services.notification_service import NotificationService

# Import Calculator
from app.services.sws_calculator import SWSCalculator

# Import Auftrag Service
from app.services.auftrag_service import AuftragService

# Import Deputat Service (Feature 4)
from app.services.deputat_service import DeputatService

# =========================================================================
# SINGLETON INSTANCES
# =========================================================================
# Diese Instanzen sollten überall verwendet werden

user_service = UserService()
semester_service = SemesterService()
modul_service = ModulService()
dozent_service = DozentService()
planung_service = PlanungService()
notification_service = NotificationService()
sws_calculator = SWSCalculator()
auftrag_service = AuftragService()
deputat_service = DeputatService()


# =========================================================================
# EXPORTS
# =========================================================================

__all__ = [
    # Base
    'BaseService',

    # Service Classes
    'UserService',
    'SemesterService',
    'ModulService',
    'DozentService',
    'PlanungService',
    'NotificationService',
    'SWSCalculator',
    'AuftragService',
    'DeputatService',

    # Singleton Instances (HAUPTSÄCHLICH DIESE VERWENDEN!)
    'user_service',
    'semester_service',
    'modul_service',
    'dozent_service',
    'planung_service',
    'notification_service',
    'sws_calculator',
    'auftrag_service',
    'deputat_service',
]