"""
User Validation Schemas
=======================
Validates user-related inputs.
"""

from marshmallow import Schema, fields, validates, ValidationError, validate
import re


class BenutzerCreateSchema(Schema):
    """User Creation Validation"""

    username = fields.Str(
        required=True,
        validate=[
            validate.Length(min=3, max=80, error="Benutzername muss zwischen 3 und 80 Zeichen lang sein")
        ],
        error_messages={
            'required': 'Benutzername ist erforderlich'
        }
    )

    email = fields.Email(
        required=True,
        validate=[
            validate.Length(max=120, error="Email darf maximal 120 Zeichen lang sein")
        ],
        error_messages={
            'required': 'Email ist erforderlich',
            'invalid': 'Ungültige Email-Adresse'
        }
    )

    password = fields.Str(
        required=True,
        validate=[
            validate.Length(min=8, max=255, error="Passwort muss mindestens 8 Zeichen lang sein")
        ],
        error_messages={
            'required': 'Passwort ist erforderlich'
        }
    )

    vorname = fields.Str(
        required=True,
        validate=[
            validate.Length(min=1, max=100, error="Vorname muss zwischen 1 und 100 Zeichen lang sein")
        ],
        error_messages={
            'required': 'Vorname ist erforderlich'
        }
    )

    nachname = fields.Str(
        required=True,
        validate=[
            validate.Length(min=1, max=100, error="Nachname muss zwischen 1 und 100 Zeichen lang sein")
        ],
        error_messages={
            'required': 'Nachname ist erforderlich'
        }
    )

    rolle = fields.Str(
        required=True,
        validate=[
            validate.OneOf(
                ['admin', 'dekan', 'professor', 'lehrbeauftragter'],
                error="Ungültige Rolle"
            )
        ],
        error_messages={
            'required': 'Rolle ist erforderlich'
        }
    )

    aktiv = fields.Bool(
        missing=True,
        error_messages={
            'invalid': 'Aktiv-Feld muss ein Boolean sein'
        }
    )

    @validates('username')
    def validate_username(self, value):
        """Validate username format"""
        # Nur alphanumerische Zeichen, Punkte und Unterstriche erlaubt
        if not re.match(r'^[a-zA-Z0-9._-]+$', value):
            raise ValidationError(
                "Benutzername darf nur Buchstaben, Zahlen, Punkte, Bindestriche und Unterstriche enthalten"
            )

    @validates('email')
    def validate_email(self, value):
        """Validate email format"""
        # Zusätzliche Email-Validierung
        if not re.match(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$', value):
            raise ValidationError("Ungültige Email-Adresse")


class BenutzerUpdateSchema(Schema):
    """User Update Validation"""

    email = fields.Email(
        validate=[
            validate.Length(max=120, error="Email darf maximal 120 Zeichen lang sein")
        ],
        error_messages={
            'invalid': 'Ungültige Email-Adresse'
        }
    )

    vorname = fields.Str(
        validate=[
            validate.Length(min=1, max=100, error="Vorname muss zwischen 1 und 100 Zeichen lang sein")
        ]
    )

    nachname = fields.Str(
        validate=[
            validate.Length(min=1, max=100, error="Nachname muss zwischen 1 und 100 Zeichen lang sein")
        ]
    )

    rolle = fields.Str(
        validate=[
            validate.OneOf(
                ['admin', 'dekan', 'professor', 'lehrbeauftragter'],
                error="Ungültige Rolle"
            )
        ]
    )

    aktiv = fields.Bool(
        error_messages={
            'invalid': 'Aktiv-Feld muss ein Boolean sein'
        }
    )

    @validates('email')
    def validate_email(self, value):
        """Validate email format"""
        if value and not re.match(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$', value):
            raise ValidationError("Ungültige Email-Adresse")
