"""
Authentication Validation Schemas
=================================
Validates authentication-related inputs.
"""

from marshmallow import Schema, fields, validates, ValidationError, validate


class LoginSchema(Schema):
    """Login Request Validation"""

    username = fields.Str(
        required=True,
        validate=[
            validate.Length(min=1, max=255, error="Benutzername muss zwischen 1 und 255 Zeichen lang sein")
        ],
        error_messages={
            'required': 'Benutzername ist erforderlich',
            'null': 'Benutzername darf nicht null sein',
            'invalid': 'Ungültiger Benutzername'
        }
    )

    password = fields.Str(
        required=True,
        validate=[
            validate.Length(min=1, max=255, error="Passwort muss zwischen 1 und 255 Zeichen lang sein")
        ],
        error_messages={
            'required': 'Passwort ist erforderlich',
            'null': 'Passwort darf nicht null sein',
            'invalid': 'Ungültiges Passwort'
        }
    )

    remember = fields.Bool(
        missing=False,
        error_messages={
            'invalid': 'Remember-Feld muss ein Boolean sein'
        }
    )

    @validates('username')
    def validate_username(self, value):
        """Validate username format"""
        # Entferne Whitespace
        value = value.strip()

        if not value:
            raise ValidationError("Benutzername darf nicht leer sein")

        # Prüfe auf gefährliche Zeichen
        dangerous_chars = ['<', '>', '&', '"', "'", '/', '\\', '|', ';']
        for char in dangerous_chars:
            if char in value:
                raise ValidationError(f"Benutzername darf das Zeichen '{char}' nicht enthalten")


class ChangePasswordSchema(Schema):
    """Change Password Request Validation"""

    old_password = fields.Str(
        required=True,
        validate=[
            validate.Length(min=1, max=255, error="Altes Passwort muss angegeben werden")
        ],
        error_messages={
            'required': 'Altes Passwort ist erforderlich',
            'null': 'Altes Passwort darf nicht null sein'
        }
    )

    new_password = fields.Str(
        required=True,
        validate=[
            validate.Length(min=8, max=255, error="Neues Passwort muss mindestens 8 Zeichen lang sein")
        ],
        error_messages={
            'required': 'Neues Passwort ist erforderlich',
            'null': 'Neues Passwort darf nicht null sein'
        }
    )

    confirm_password = fields.Str(
        required=True,
        validate=[
            validate.Length(min=8, max=255, error="Passwortbestätigung muss mindestens 8 Zeichen lang sein")
        ],
        error_messages={
            'required': 'Passwortbestätigung ist erforderlich',
            'null': 'Passwortbestätigung darf nicht null sein'
        }
    )

    @validates('new_password')
    def validate_new_password(self, value):
        """Validate new password strength"""
        if len(value) < 8:
            raise ValidationError("Passwort muss mindestens 8 Zeichen lang sein")

        # Diese Validierung wird zusätzlich in validate_password_with_config durchgeführt
        # Hier nur grundlegende Checks
