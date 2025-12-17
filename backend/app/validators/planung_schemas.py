"""
Planung Validation Schemas
==========================
Validates planning-related inputs.
"""

from marshmallow import Schema, fields, validates, ValidationError, validate


class SemesterplanungCreateSchema(Schema):
    """Semesterplanung Creation Validation"""

    user_id = fields.Int(
        required=True,
        validate=[
            validate.Range(min=1, error="User ID muss größer als 0 sein")
        ],
        error_messages={
            'required': 'User ID ist erforderlich',
            'invalid': 'User ID muss eine Zahl sein'
        }
    )

    semester_id = fields.Int(
        required=True,
        validate=[
            validate.Range(min=1, error="Semester ID muss größer als 0 sein")
        ],
        error_messages={
            'required': 'Semester ID ist erforderlich',
            'invalid': 'Semester ID muss eine Zahl sein'
        }
    )

    planungsphase_id = fields.Int(
        allow_none=True,
        validate=[
            validate.Range(min=1, error="Planungsphase ID muss größer als 0 sein")
        ],
        error_messages={
            'invalid': 'Planungsphase ID muss eine Zahl sein'
        }
    )

    status = fields.Str(
        missing='in_bearbeitung',
        validate=[
            validate.OneOf(
                ['in_bearbeitung', 'eingereicht', 'freigegeben', 'abgelehnt'],
                error="Ungültiger Status"
            )
        ]
    )

    anmerkungen = fields.Str(
        allow_none=True,
        validate=[
            validate.Length(max=5000, error="Anmerkungen dürfen maximal 5000 Zeichen lang sein")
        ]
    )

    raumbedarf = fields.Str(
        allow_none=True,
        validate=[
            validate.Length(max=2000, error="Raumbedarf darf maximal 2000 Zeichen lang sein")
        ]
    )


class SemesterplanungUpdateSchema(Schema):
    """Semesterplanung Update Validation"""

    status = fields.Str(
        validate=[
            validate.OneOf(
                ['in_bearbeitung', 'eingereicht', 'freigegeben', 'abgelehnt'],
                error="Ungültiger Status"
            )
        ]
    )

    anmerkungen = fields.Str(
        allow_none=True,
        validate=[
            validate.Length(max=5000, error="Anmerkungen dürfen maximal 5000 Zeichen lang sein")
        ]
    )

    raumbedarf = fields.Str(
        allow_none=True,
        validate=[
            validate.Length(max=2000, error="Raumbedarf darf maximal 2000 Zeichen lang sein")
        ]
    )

    planungsphase_id = fields.Int(
        allow_none=True,
        validate=[
            validate.Range(min=1, error="Planungsphase ID muss größer als 0 sein")
        ],
        error_messages={
            'invalid': 'Planungsphase ID muss eine Zahl sein'
        }
    )


class GeplantesModulCreateSchema(Schema):
    """Geplantes Modul Creation Validation"""

    planung_id = fields.Int(
        required=True,
        validate=[
            validate.Range(min=1, error="Planung ID muss größer als 0 sein")
        ],
        error_messages={
            'required': 'Planung ID ist erforderlich',
            'invalid': 'Planung ID muss eine Zahl sein'
        }
    )

    modul_id = fields.Int(
        required=True,
        validate=[
            validate.Range(min=1, error="Modul ID muss größer als 0 sein")
        ],
        error_messages={
            'required': 'Modul ID ist erforderlich',
            'invalid': 'Modul ID muss eine Zahl sein'
        }
    )

    sws = fields.Float(
        allow_none=True,
        validate=[
            validate.Range(min=0, max=20, error="SWS muss zwischen 0 und 20 liegen")
        ],
        error_messages={
            'invalid': 'SWS muss eine Zahl sein'
        }
    )

    semester = fields.Int(
        allow_none=True,
        validate=[
            validate.Range(min=1, max=12, error="Semester muss zwischen 1 und 12 liegen")
        ],
        error_messages={
            'invalid': 'Semester muss eine Zahl sein'
        }
    )

    anmerkungen = fields.Str(
        allow_none=True,
        validate=[
            validate.Length(max=2000, error="Anmerkungen dürfen maximal 2000 Zeichen lang sein")
        ]
    )


class GeplantesModulUpdateSchema(Schema):
    """Geplantes Modul Update Validation"""

    sws = fields.Float(
        allow_none=True,
        validate=[
            validate.Range(min=0, max=20, error="SWS muss zwischen 0 und 20 liegen")
        ],
        error_messages={
            'invalid': 'SWS muss eine Zahl sein'
        }
    )

    semester = fields.Int(
        allow_none=True,
        validate=[
            validate.Range(min=1, max=12, error="Semester muss zwischen 1 und 12 liegen")
        ],
        error_messages={
            'invalid': 'Semester muss eine Zahl sein'
        }
    )

    anmerkungen = fields.Str(
        allow_none=True,
        validate=[
            validate.Length(max=2000, error="Anmerkungen dürfen maximal 2000 Zeichen lang sein")
        ]
    )

    mitarbeiter_ids = fields.List(
        fields.Int(validate=validate.Range(min=1)),
        allow_none=True,
        error_messages={
            'invalid': 'Mitarbeiter IDs muss eine Liste von Zahlen sein'
        }
    )
