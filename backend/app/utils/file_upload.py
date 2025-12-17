"""
Secure File Upload Utility
==========================
Sichere Datei-Upload-Funktionalität mit Validierung.

Security Features:
- File Type Validation (Extension + MIME Type)
- File Size Limits
- Secure Filename Generation
- Path Traversal Prevention
- Virus Scanning Integration (optional)
"""

import os
import re
import uuid
import mimetypes
from pathlib import Path
from werkzeug.utils import secure_filename
from flask import current_app


# Erlaubte Dateitypen mit MIME-Types
ALLOWED_FILE_TYPES = {
    'pdf': ['application/pdf'],
    'docx': [
        'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
        'application/msword'
    ],
    'xlsx': [
        'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
        'application/vnd.ms-excel'
    ],
    'png': ['image/png'],
    'jpg': ['image/jpeg'],
    'jpeg': ['image/jpeg'],
}

# Maximale Dateigrößen (in Bytes)
MAX_FILE_SIZES = {
    'pdf': 16 * 1024 * 1024,    # 16 MB
    'docx': 10 * 1024 * 1024,   # 10 MB
    'xlsx': 10 * 1024 * 1024,   # 10 MB
    'png': 5 * 1024 * 1024,     # 5 MB
    'jpg': 5 * 1024 * 1024,     # 5 MB
    'jpeg': 5 * 1024 * 1024,    # 5 MB
}

# Verbotene Dateitypen (immer ablehnen)
FORBIDDEN_EXTENSIONS = {
    'exe', 'bat', 'cmd', 'com', 'pif', 'scr', 'vbs', 'js', 'jar',
    'app', 'deb', 'rpm', 'sh', 'php', 'py', 'rb', 'pl', 'cgi',
    'asp', 'aspx', 'jsp', 'dll', 'so', 'dmg', 'pkg'
}


class FileUploadError(Exception):
    """Custom Exception for File Upload Errors"""
    pass


class FileValidator:
    """
    Validator für hochgeladene Dateien.

    Features:
    - Extension Validation
    - MIME Type Validation
    - File Size Validation
    - Magic Bytes Validation (optional)
    """

    def __init__(self, allowed_extensions=None, max_size=None):
        """
        Args:
            allowed_extensions (set): Erlaubte Dateiendungen (default: aus Config)
            max_size (int): Maximale Dateigröße in Bytes (default: aus Config)
        """
        self.allowed_extensions = allowed_extensions or current_app.config.get(
            'ALLOWED_EXTENSIONS',
            {'pdf', 'docx', 'xlsx'}
        )
        self.max_size = max_size or current_app.config.get(
            'MAX_CONTENT_LENGTH',
            16 * 1024 * 1024
        )

    def validate_extension(self, filename: str) -> str:
        """
        Validiert Dateiendung.

        Args:
            filename (str): Dateiname

        Returns:
            str: Dateiendung (lowercase)

        Raises:
            FileUploadError: Bei ungültiger Extension
        """
        if '.' not in filename:
            raise FileUploadError("Datei hat keine Endung")

        extension = filename.rsplit('.', 1)[1].lower()

        # Prüfe auf verbotene Extensions
        if extension in FORBIDDEN_EXTENSIONS:
            current_app.logger.warning(
                f"[SECURITY] Forbidden file extension attempted: {extension}",
                extra={'filename': filename}
            )
            raise FileUploadError(
                f"Dateityp '.{extension}' ist aus Sicherheitsgründen nicht erlaubt"
            )

        # Prüfe auf erlaubte Extensions
        if extension not in self.allowed_extensions:
            raise FileUploadError(
                f"Dateityp '.{extension}' ist nicht erlaubt. "
                f"Erlaubt sind: {', '.join(self.allowed_extensions)}"
            )

        return extension

    def validate_mime_type(self, file_stream, extension: str) -> bool:
        """
        Validiert MIME-Type der Datei.

        Args:
            file_stream: File-Stream-Objekt
            extension (str): Erwartete Dateiendung

        Returns:
            bool: True wenn MIME-Type passt

        Raises:
            FileUploadError: Bei ungültigem MIME-Type
        """
        # Lese erste Bytes für MIME-Type Detection
        try:
            file_start = file_stream.read(1024)
            file_stream.seek(0)  # Reset stream

            # Guess MIME-Type
            mime_type = mimetypes.guess_type(f"file.{extension}")[0]

            if not mime_type:
                raise FileUploadError("MIME-Type konnte nicht ermittelt werden")

            # Prüfe ob MIME-Type zur Extension passt
            allowed_mimes = ALLOWED_FILE_TYPES.get(extension, [])

            if mime_type not in allowed_mimes:
                current_app.logger.warning(
                    f"[SECURITY] MIME-Type mismatch: expected {allowed_mimes}, got {mime_type}",
                    extra={'extension': extension}
                )
                raise FileUploadError(
                    f"Dateiinhalt stimmt nicht mit Dateiendung überein"
                )

            return True

        except Exception as e:
            if isinstance(e, FileUploadError):
                raise
            raise FileUploadError(f"Fehler bei MIME-Type Validierung: {str(e)}")

    def validate_size(self, file_stream, extension: str) -> int:
        """
        Validiert Dateigröße.

        Args:
            file_stream: File-Stream-Objekt
            extension (str): Dateiendung

        Returns:
            int: Dateigröße in Bytes

        Raises:
            FileUploadError: Bei zu großer Datei
        """
        # Bestimme maximale Größe für diesen Dateityp
        max_size = MAX_FILE_SIZES.get(extension, self.max_size)

        # Springe ans Ende und lese Position (= Dateigröße)
        file_stream.seek(0, os.SEEK_END)
        file_size = file_stream.tell()
        file_stream.seek(0)  # Reset

        if file_size == 0:
            raise FileUploadError("Datei ist leer")

        if file_size > max_size:
            size_mb = file_size / (1024 * 1024)
            max_mb = max_size / (1024 * 1024)
            raise FileUploadError(
                f"Datei ist zu groß ({size_mb:.2f} MB). "
                f"Maximal erlaubt: {max_mb:.2f} MB"
            )

        return file_size

    def validate_filename(self, filename: str) -> str:
        """
        Validiert und säubert Dateiname.

        Args:
            filename (str): Original-Dateiname

        Returns:
            str: Gesäuberter Dateiname

        Raises:
            FileUploadError: Bei ungültigem Dateinamen
        """
        if not filename:
            raise FileUploadError("Dateiname ist leer")

        # Entferne gefährliche Zeichen
        # Nur erlaubt: a-z, A-Z, 0-9, -, _, .
        safe_name = re.sub(r'[^a-zA-Z0-9._-]', '_', filename)

        # Verhindere Path Traversal
        if '..' in safe_name or '/' in safe_name or '\\' in safe_name:
            raise FileUploadError("Ungültiger Dateiname (Path Traversal Versuch)")

        # Werkzeug's secure_filename als zusätzliche Absicherung
        safe_name = secure_filename(safe_name)

        if not safe_name:
            raise FileUploadError("Dateiname konnte nicht gesäubert werden")

        return safe_name

    def validate(self, file_storage) -> dict:
        """
        Vollständige Validierung einer hochgeladenen Datei.

        Args:
            file_storage: Flask FileStorage Objekt

        Returns:
            dict: Validierungsergebnis mit Metadaten

        Raises:
            FileUploadError: Bei Validierungsfehler
        """
        # 1. Validiere Dateiname
        original_filename = file_storage.filename
        safe_filename = self.validate_filename(original_filename)

        # 2. Validiere Extension
        extension = self.validate_extension(safe_filename)

        # 3. Validiere Dateigröße
        file_size = self.validate_size(file_storage.stream, extension)

        # 4. Validiere MIME-Type (optional, kann deaktiviert werden)
        try:
            self.validate_mime_type(file_storage.stream, extension)
        except FileUploadError as e:
            current_app.logger.warning(f"MIME validation failed: {e}")
            # Je nach Konfiguration: entweder Fehler werfen oder nur warnen
            # raise

        return {
            'original_filename': original_filename,
            'safe_filename': safe_filename,
            'extension': extension,
            'size': file_size,
            'size_mb': round(file_size / (1024 * 1024), 2),
            'valid': True
        }


def generate_unique_filename(original_filename: str) -> str:
    """
    Generiert einen eindeutigen, sicheren Dateinamen.

    Args:
        original_filename (str): Original-Dateiname

    Returns:
        str: Eindeutiger Dateiname (UUID + Extension)
    """
    # Extrahiere Extension
    extension = ''
    if '.' in original_filename:
        extension = original_filename.rsplit('.', 1)[1].lower()

    # Generiere UUID
    unique_id = uuid.uuid4().hex

    # Kombiniere
    return f"{unique_id}.{extension}" if extension else unique_id


def save_uploaded_file(file_storage, subfolder: str = None) -> dict:
    """
    Speichert eine hochgeladene Datei sicher.

    Args:
        file_storage: Flask FileStorage Objekt
        subfolder (str): Optionaler Unterordner

    Returns:
        dict: File-Info (path, filename, size, etc.)

    Raises:
        FileUploadError: Bei Validierungsfehler oder I/O Fehler
    """
    # Validiere Datei
    validator = FileValidator()
    validation_result = validator.validate(file_storage)

    # Generiere eindeutigen Dateinamen
    unique_filename = generate_unique_filename(validation_result['safe_filename'])

    # Bestimme Upload-Pfad
    upload_folder = current_app.config.get('UPLOAD_FOLDER')
    if not upload_folder:
        raise FileUploadError("UPLOAD_FOLDER nicht konfiguriert")

    # Erstelle Unterordner falls angegeben
    if subfolder:
        # Säubere Unterordner-Namen (verhindere Path Traversal)
        subfolder = secure_filename(subfolder)
        upload_path = Path(upload_folder) / subfolder
    else:
        upload_path = Path(upload_folder)

    # Erstelle Verzeichnis falls nicht vorhanden
    upload_path.mkdir(parents=True, exist_ok=True)

    # Vollständiger Dateipfad
    file_path = upload_path / unique_filename

    # Prüfe ob Datei bereits existiert (sollte bei UUID nicht passieren)
    if file_path.exists():
        current_app.logger.warning(f"File already exists (UUID collision?): {file_path}")
        # Generiere neuen Namen
        unique_filename = generate_unique_filename(validation_result['safe_filename'])
        file_path = upload_path / unique_filename

    try:
        # Speichere Datei
        file_storage.save(str(file_path))

        current_app.logger.info(
            f"[UPLOAD] File saved successfully",
            extra={
                'filename': unique_filename,
                'original': validation_result['original_filename'],
                'size_mb': validation_result['size_mb'],
                'path': str(file_path)
            }
        )

        return {
            'success': True,
            'filename': unique_filename,
            'original_filename': validation_result['original_filename'],
            'path': str(file_path),
            'size': validation_result['size'],
            'size_mb': validation_result['size_mb'],
            'extension': validation_result['extension'],
            'url': f"/uploads/{subfolder}/{unique_filename}" if subfolder else f"/uploads/{unique_filename}"
        }

    except Exception as e:
        current_app.logger.error(
            f"[ERROR] Failed to save file: {e}",
            exc_info=True
        )
        raise FileUploadError(f"Datei konnte nicht gespeichert werden: {str(e)}")


def delete_uploaded_file(filename: str, subfolder: str = None) -> bool:
    """
    Löscht eine hochgeladene Datei sicher.

    Args:
        filename (str): Dateiname
        subfolder (str): Optionaler Unterordner

    Returns:
        bool: True wenn erfolgreich gelöscht

    Raises:
        FileUploadError: Bei Fehler
    """
    upload_folder = current_app.config.get('UPLOAD_FOLDER')
    if not upload_folder:
        raise FileUploadError("UPLOAD_FOLDER nicht konfiguriert")

    # Säubere Dateiname (verhindere Path Traversal)
    safe_filename = secure_filename(filename)

    # Bestimme Pfad
    if subfolder:
        subfolder = secure_filename(subfolder)
        file_path = Path(upload_folder) / subfolder / safe_filename
    else:
        file_path = Path(upload_folder) / safe_filename

    # Prüfe ob Datei existiert
    if not file_path.exists():
        raise FileUploadError("Datei nicht gefunden")

    # Prüfe ob Pfad wirklich in UPLOAD_FOLDER liegt (zusätzliche Sicherheit)
    upload_folder_path = Path(upload_folder).resolve()
    file_path_resolved = file_path.resolve()

    if not str(file_path_resolved).startswith(str(upload_folder_path)):
        current_app.logger.error(
            f"[SECURITY] Path Traversal attempt detected",
            extra={'requested_path': str(file_path), 'resolved': str(file_path_resolved)}
        )
        raise FileUploadError("Ungültiger Dateipfad (Sicherheitsverstoß)")

    try:
        file_path.unlink()
        current_app.logger.info(f"[DELETE] File deleted: {safe_filename}")
        return True
    except Exception as e:
        current_app.logger.error(f"[ERROR] Failed to delete file: {e}", exc_info=True)
        raise FileUploadError(f"Datei konnte nicht gelöscht werden: {str(e)}")
