"""
Validation Schemas
==================
Input validation using Marshmallow.
"""

from .auth_schemas import LoginSchema, ChangePasswordSchema
from .user_schemas import BenutzerCreateSchema, BenutzerUpdateSchema
from .planung_schemas import SemesterplanungCreateSchema, SemesterplanungUpdateSchema

__all__ = [
    'LoginSchema',
    'ChangePasswordSchema',
    'BenutzerCreateSchema',
    'BenutzerUpdateSchema',
    'SemesterplanungCreateSchema',
    'SemesterplanungUpdateSchema',
]
