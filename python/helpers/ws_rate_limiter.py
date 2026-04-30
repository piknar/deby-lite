from __future__ import annotations

import threading
import time
from collections import defaultdict
from dataclasses import dataclass, field
from typing import Dict, Optional

from python.helpers.print_style import PrintStyle


@dataclass
class _ConnectionEntry:
    count: int = 0
    first_seen: float = 0.0
    blocked: bool = False


class WebSocketRateLimiter:
    """Rate limiter for WebSocket connections to prevent abuse.

    Tracks connection attempts per IP within a sliding window and blocks
    IPs that exceed the configured threshold. This mitigates crypto-malware
    C2 rapid-reconnect and resource exhaustion attacks.
    """

    DEFAULT_MAX_CONNECTIONS = 30
    DEFAULT_WINDOW_SECONDS = 60
    DEFAULT_BLOCK_DURATION_SECONDS = 300  # 5 minutes

    def __init__(
        self,
        max_connections: int = DEFAULT_MAX_CONNECTIONS,
        window_seconds: float = DEFAULT_WINDOW_SECONDS,
        block_duration_seconds: float = DEFAULT_BLOCK_DURATION_SECONDS,
    ) -> None:
        self._max_connections = max_connections
        self._window_seconds = window_seconds
        self._block_duration_seconds = block_duration_seconds
        self._lock = threading.RLock()
        self._entries: Dict[str, _ConnectionEntry] = {}

    def _prune(self, ip: str, now: float) -> None:
        """Remove expired entries for an IP."""
        entry = self._entries.get(ip)
        if entry is None:
            return
        if entry.blocked and (now - entry.first_seen) > self._block_duration_seconds:
            del self._entries[ip]
        elif not entry.blocked and (now - entry.first_seen) > self._window_seconds:
            del self._entries[ip]

    def check_and_record(self, ip: str) -> bool:
        """Check if an IP is allowed to connect and record the attempt.

        Returns True if the connection is allowed, False if rate-limited.
        """
        now = time.time()
        with self._lock:
            self._prune(ip, now)
            entry = self._entries.get(ip)

            if entry is None:
                self._entries[ip] = _ConnectionEntry(
                    count=1, first_seen=now, blocked=False
                )
                return True

            if entry.blocked:
                # Still within block window
                return False

            entry.count += 1
            if entry.count > self._max_connections:
                entry.blocked = True
                entry.first_seen = now  # Start block timer from now
                PrintStyle.warning(
                    f