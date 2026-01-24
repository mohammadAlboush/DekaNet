"""
Token Blocklist - Sichere Token-Invalidierung
==============================================

✅ SECURITY: Ermöglicht das Invalidieren von JWTs bei Logout.

In-Memory Implementation für Development.
Für Production: Redis oder Datenbank verwenden.

Usage:
    from app.utils.token_blocklist import token_blocklist

    # Token blocken (bei Logout)
    token_blocklist.add(jti, exp_timestamp)

    # Prüfen ob Token geblockt ist
    is_blocked = token_blocklist.is_blocked(jti)
"""

import time
from threading import Lock
from typing import Dict, Optional
from datetime import datetime


class TokenBlocklist:
    """
    Thread-safe In-Memory Token Blocklist.

    ✅ SECURITY FEATURES:
    - Automatische Bereinigung abgelaufener Tokens
    - Thread-safe durch Lock
    - TTL-basierte Speicherung (Tokens werden nach Ablauf entfernt)

    ⚠️ HINWEIS: Für Production sollte Redis verwendet werden!
    Diese Implementation verliert Daten bei Server-Neustart.
    """

    def __init__(self):
        self._blocklist: Dict[str, float] = {}  # jti -> expiry_timestamp
        self._lock = Lock()
        self._last_cleanup = time.time()
        self._cleanup_interval = 300  # 5 Minuten

    def add(self, jti: str, exp_timestamp: Optional[float] = None) -> None:
        """
        Fügt Token zur Blocklist hinzu.

        Args:
            jti: JWT ID (unique identifier)
            exp_timestamp: Token-Ablaufzeit (Unix timestamp)
                          Falls nicht angegeben, wird Token für 24h geblockt
        """
        if exp_timestamp is None:
            # Default: 24 Stunden
            exp_timestamp = time.time() + 86400

        with self._lock:
            self._blocklist[jti] = exp_timestamp
            self._maybe_cleanup()

    def is_blocked(self, jti: str) -> bool:
        """
        Prüft ob Token in Blocklist ist.

        Args:
            jti: JWT ID

        Returns:
            True wenn geblockt, False sonst
        """
        with self._lock:
            if jti not in self._blocklist:
                return False

            # Prüfe ob Token abgelaufen ist
            exp_timestamp = self._blocklist[jti]
            if time.time() > exp_timestamp:
                # Token ist abgelaufen - aus Blocklist entfernen
                del self._blocklist[jti]
                return False

            return True

    def remove(self, jti: str) -> bool:
        """
        Entfernt Token aus Blocklist.

        Args:
            jti: JWT ID

        Returns:
            True wenn entfernt, False wenn nicht gefunden
        """
        with self._lock:
            if jti in self._blocklist:
                del self._blocklist[jti]
                return True
            return False

    def clear(self) -> None:
        """Leert die gesamte Blocklist."""
        with self._lock:
            self._blocklist.clear()

    def _maybe_cleanup(self) -> None:
        """
        Bereinigt abgelaufene Tokens (wird automatisch aufgerufen).
        Nicht thread-safe - muss innerhalb des Locks aufgerufen werden.
        """
        now = time.time()
        if now - self._last_cleanup < self._cleanup_interval:
            return

        # Entferne abgelaufene Tokens
        expired_jtis = [
            jti for jti, exp in self._blocklist.items()
            if now > exp
        ]
        for jti in expired_jtis:
            del self._blocklist[jti]

        self._last_cleanup = now

    @property
    def size(self) -> int:
        """Anzahl der geblockten Tokens."""
        with self._lock:
            return len(self._blocklist)

    def get_stats(self) -> dict:
        """Statistiken für Debugging."""
        with self._lock:
            return {
                'blocked_tokens': len(self._blocklist),
                'last_cleanup': datetime.fromtimestamp(self._last_cleanup).isoformat(),
            }


# Singleton-Instanz
token_blocklist = TokenBlocklist()
