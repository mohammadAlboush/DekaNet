"""
Authentication Utilities
========================
Helper-Funktionen für Authentication und Passwort-Management.

Functions:
    - hash_password: Hasht ein Passwort
    - check_password: Prüft Passwort gegen Hash
    - validate_password: Validiert Passwort-Stärke
    - generate_random_password: Generiert zufälliges Passwort
"""

import re
import secrets
import string
from werkzeug.security import generate_password_hash, check_password_hash


def hash_password(password, method='pbkdf2:sha256', salt_length=16):
    """
    Hasht ein Passwort mit Werkzeug
    
    Args:
        password: Klartext-Passwort
        method: Hash-Methode (default: pbkdf2:sha256)
        salt_length: Länge des Salts
    
    Returns:
        str: Gehashtes Passwort
        
    Example:
        >>> pw_hash = hash_password('MeinPasswort123!')
        >>> 'pbkdf2:sha256' in pw_hash
        True
    """
    return generate_password_hash(
        password,
        method=method,
        salt_length=salt_length
    )


def verify_password(password, password_hash):
    """
    Prüft ob Passwort mit Hash übereinstimmt
    
    Args:
        password: Klartext-Passwort
        password_hash: Gespeicherter Hash
    
    Returns:
        bool: True wenn Passwort korrekt
        
    Example:
        >>> pw_hash = hash_password('test123')
        >>> verify_password('test123', pw_hash)
        True
        >>> verify_password('wrong', pw_hash)
        False
    """
    return check_password_hash(password_hash, password)


def validate_password(password, min_length=8, require_uppercase=True, 
                     require_lowercase=True, require_digit=True, 
                     require_special=False):
    """
    Validiert Passwort-Stärke gegen Anforderungen
    
    Args:
        password: Zu prüfendes Passwort
        min_length: Minimale Länge
        require_uppercase: Großbuchstabe erforderlich?
        require_lowercase: Kleinbuchstabe erforderlich?
        require_digit: Ziffer erforderlich?
        require_special: Sonderzeichen erforderlich?
    
    Returns:
        tuple: (bool: valide?, list: Fehlermeldungen)
        
    Example:
        >>> validate_password('abc')
        (False, ['Passwort muss mindestens 8 Zeichen lang sein', ...])
        >>> validate_password('Test1234')
        (True, [])
    """
    errors = []
    
    # Länge prüfen
    if len(password) < min_length:
        errors.append(f'Passwort muss mindestens {min_length} Zeichen lang sein')
    
    # Großbuchstabe
    if require_uppercase and not re.search(r'[A-Z]', password):
        errors.append('Passwort muss mindestens einen Großbuchstaben enthalten')
    
    # Kleinbuchstabe
    if require_lowercase and not re.search(r'[a-z]', password):
        errors.append('Passwort muss mindestens einen Kleinbuchstaben enthalten')
    
    # Ziffer
    if require_digit and not re.search(r'\d', password):
        errors.append('Passwort muss mindestens eine Ziffer enthalten')
    
    # Sonderzeichen
    if require_special and not re.search(r'[!@#$%^&*(),.?":{}|<>]', password):
        errors.append('Passwort muss mindestens ein Sonderzeichen enthalten')
    
    is_valid = len(errors) == 0
    return is_valid, errors


def validate_password_with_config(password, config):
    """
    Validiert Passwort mit Flask Config
    
    Args:
        password: Zu prüfendes Passwort
        config: Flask app.config
    
    Returns:
        tuple: (bool: valide?, list: Fehlermeldungen)
    """
    return validate_password(
        password,
        min_length=config.get('MIN_PASSWORD_LENGTH', 8),
        require_uppercase=config.get('REQUIRE_PASSWORD_UPPERCASE', True),
        require_lowercase=config.get('REQUIRE_PASSWORD_LOWERCASE', True),
        require_digit=config.get('REQUIRE_PASSWORD_DIGIT', True),
        require_special=config.get('REQUIRE_PASSWORD_SPECIAL', False)
    )


def generate_random_password(length=12, use_uppercase=True, use_lowercase=True,
                            use_digits=True, use_special=True):
    """
    Generiert ein zufälliges, sicheres Passwort
    
    Args:
        length: Länge des Passworts
        use_uppercase: Großbuchstaben verwenden?
        use_lowercase: Kleinbuchstaben verwenden?
        use_digits: Ziffern verwenden?
        use_special: Sonderzeichen verwenden?
    
    Returns:
        str: Zufälliges Passwort
        
    Example:
        >>> pw = generate_random_password()
        >>> len(pw)
        12
        >>> pw = generate_random_password(length=20)
        >>> len(pw)
        20
    """
    # Zeichenpool aufbauen
    characters = ''
    if use_lowercase:
        characters += string.ascii_lowercase
    if use_uppercase:
        characters += string.ascii_uppercase
    if use_digits:
        characters += string.digits
    if use_special:
        characters += '!@#$%^&*()_+-=[]{}|;:,.<>?'
    
    if not characters:
        raise ValueError("Mindestens eine Zeichengruppe muss aktiviert sein")
    
    # Passwort generieren
    password = ''.join(secrets.choice(characters) for _ in range(length))
    
    return password


def sanitize_username(username):
    """
    Bereinigt Username (lowercase, keine Sonderzeichen)
    
    Args:
        username: Zu bereinigender Username
    
    Returns:
        str: Bereinigter Username
        
    Example:
        >>> sanitize_username('Max.Müller')
        'max.muller'
    """
    # Lowercase
    username = username.lower()
    
    # Umlaute ersetzen
    replacements = {
        'ä': 'ae',
        'ö': 'oe',
        'ü': 'ue',
        'ß': 'ss'
    }
    for old, new in replacements.items():
        username = username.replace(old, new)
    
    # Nur alphanumerisch + Punkt + Unterstrich + Bindestrich
    username = re.sub(r'[^a-z0-9._-]', '', username)
    
    return username


def validate_email(email):
    """
    Validiert Email-Adresse (einfache Prüfung)
    
    Args:
        email: Zu prüfende Email
    
    Returns:
        bool: True wenn gültig
        
    Example:
        >>> validate_email('test@example.com')
        True
        >>> validate_email('invalid')
        False
    """
    # Einfaches Email-Pattern (nicht 100% RFC-konform, aber praktisch)
    pattern = r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$'
    return bool(re.match(pattern, email))


def get_password_strength(password):
    """
    Berechnet Passwort-Stärke (Score 0-5)
    
    Args:
        password: Zu bewertendes Passwort
    
    Returns:
        int: Stärke-Score (0=sehr schwach, 5=sehr stark)
        
    Example:
        >>> get_password_strength('abc')
        0
        >>> get_password_strength('Test1234!')
        4
    """
    score = 0
    
    # Länge
    if len(password) >= 8:
        score += 1
    if len(password) >= 12:
        score += 1
    
    # Zeichenarten
    if re.search(r'[a-z]', password):
        score += 1
    if re.search(r'[A-Z]', password):
        score += 1
    if re.search(r'\d', password):
        score += 1
    if re.search(r'[!@#$%^&*(),.?":{}|<>]', password):
        score += 1
    
    # Maximum 5
    return min(score, 5)


def get_password_strength_text(password):
    """
    Gibt textuelle Beschreibung der Passwort-Stärke
    
    Args:
        password: Zu bewertendes Passwort
    
    Returns:
        str: Beschreibung (z.B. "Sehr stark")
        
    Example:
        >>> get_password_strength_text('abc')
        'Sehr schwach'
        >>> get_password_strength_text('Test1234!')
        'Stark'
    """
    score = get_password_strength(password)
    
    strengths = {
        0: 'Sehr schwach',
        1: 'Sehr schwach',
        2: 'Schwach',
        3: 'Mittel',
        4: 'Stark',
        5: 'Sehr stark'
    }
    
    return strengths.get(score, 'Unbekannt')