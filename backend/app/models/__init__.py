"""
Models Package
==============
Alle SQLAlchemy Models für das Digitale Dekanat.

Import:
    from app.models import Benutzer, Rolle, Semester, Semesterplanung, Modul

Neue Models (Semesterplanung):
- Rolle
- Benutzer  
- Semester
- Semesterplanung
- GeplantesModul
- WunschFreierTag

Bestehende Models (aus DB):
- Dozent
- Modul + alle Verknüpfungs-Tabellen
- Studiengang, Pruefungsordnung
- Lehrform, Sprache
- Modulhandbuch

Optional:
- AuditLog
- Benachrichtigung
"""

# ⚠️ WICHTIG: db von extensions importieren, NICHT von base!
from app.extensions import db

# Base Models (ohne db, da wir es schon importiert haben)
from .base import BaseModel, TimestampMixin

# Neue Models (Semesterplanung-System)
from .user import Rolle, Benutzer
from .semester import Semester
from .planung import Semesterplanung, GeplantesModul, WunschFreierTag
from .planungsphase import Planungsphase, PhaseSubmission, ArchiviertePlanung

# Bestehende Models (aus dekanat_professional_v4.db)
from .dozent import Dozent
from .modul import (
    Modul,
    ModulLehrform,
    ModulDozent,
    ModulStudiengang,
)
from .modul_details import (
    ModulLiteratur,
    ModulPruefung,
    ModulLernergebnisse,
    ModulVoraussetzungen,
    ModulAbhaengigkeit,
    ModulArbeitsaufwand,
    ModulSprache,
    ModulSeiten,
)
from .studiengang import Studiengang, Pruefungsordnung
from .lehrform import Lehrform
from .sprache import Sprache
from .modulhandbuch import Modulhandbuch

# Optional
from .audit import AuditLog
from .notification import Benachrichtigung

# ✨ NEW: Feature 2 - Semesteraufträge
from .auftrag import Auftrag, SemesterAuftrag

# ✨ NEW: Feature 3 - Modul-Verwaltung Audit Log
from .modul_audit import ModulAuditLog

# ✨ NEW: Feature 4 - Deputatsabrechnung
from .deputat_einstellungen import DeputatsEinstellungen
from .deputat import (
    Deputatsabrechnung,
    DeputatsLehrtaetigkeit,
    DeputatsLehrexport,
    DeputatsVertretung,
    DeputatsErmaessigung,
    DeputatsBetreuung,
)

# ✨ NEW: Feature 5 - Planungs-Templates
from .planungs_template import PlanungsTemplate, TemplateModul


# Alle Models für easy import
__all__ = [
    # Base
    'db',
    'BaseModel',
    'TimestampMixin',

    # Neue Models
    'Rolle',
    'Benutzer',
    'Semester',
    'Semesterplanung',
    'GeplantesModul',
    'WunschFreierTag',
    'Planungsphase',
    'PhaseSubmission',
    'ArchiviertePlanung',
    'Auftrag',
    'SemesterAuftrag',
    'ModulAuditLog',

    # Bestehende Hauptmodels
    'Dozent',
    'Modul',
    'ModulLehrform',
    'ModulDozent',
    'ModulStudiengang',
    'Studiengang',
    'Pruefungsordnung',
    'Lehrform',
    'Sprache',
    'Modulhandbuch',
    
    # Modul-Details
    'ModulLiteratur',
    'ModulPruefung',
    'ModulLernergebnisse',
    'ModulVoraussetzungen',
    'ModulAbhaengigkeit',
    'ModulArbeitsaufwand',
    'ModulSprache',
    'ModulSeiten',
    
    # Optional
    'AuditLog',
    'Benachrichtigung',

    # Deputatsabrechnung
    'DeputatsEinstellungen',
    'Deputatsabrechnung',
    'DeputatsLehrtaetigkeit',
    'DeputatsLehrexport',
    'DeputatsVertretung',
    'DeputatsErmaessigung',
    'DeputatsBetreuung',

    # Planungs-Templates
    'PlanungsTemplate',
    'TemplateModul',
]