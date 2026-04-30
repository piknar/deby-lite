from __future__ import annotations

import threading
import time
from typing import Dict, Optional

from python.helpers.print_style import PrintStyle


class _ConnectionEntry:
    __slots__ = ('count', 'first_seen', 'blocked')

    def __init__(self, count: int = 0, first_seen: float = 0.0, blocked: bool = False) -> None:
        self.count = count
        self.first_seen = first_seen
        self.blocked = blocked


class WebSocketRateLimiter:
    """Rate limiter for WebSocket connections to prevent abuse."""

    DEFAULT_MAX_CONNECTIONS = 30
    DEFAULT_WINDOW_SECONDS = 60
    DEFAULT_BLOCK_DURATION_SECONDS = 300

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
        entry = self._entries.get(ip)
        if entry is None:
            return
        if entry.blocked and (now - entry.first_seen) > self._block_duration_seconds:
            del self._entries[ip]
        elif not entry.blocked and (now - entry.first_seen) > self._window_seconds:
            del self._entries[ip]

    def check_and_record(self, ip: str) -> bool:
        now = time.time()
        with self._lock:
            self._prune(ip, now)
            entry = self._entries.get(ip)
            if entry is None:
                self._entries[ip] = _ConnectionEntry(count=1, first_seen=now, blocked=False)
                return True
            if entry.blocked:
                return False
            entry.count += 1
            if entry.count > self._max_connections:
                entry.blocked = True
                entry.first_seen = now
                PrintStyle.warning(
                    "[SECURITY] Rate limiting WebSocket IP="
                    + ip
                    + ": "
                    + str(entry.count)
                    + " connections"
                )
                return False
            return True

    def unblock(self, ip: str) -> None:
        with self._lock:
            self._entries.pop(ip, None)

    def get_stats(self) -> dict:
        with self._lock:
            blocked = sum(1 for e in self._entries.values() if e.blocked)
            active = sum(1 for e in self._entries.values() if not e.blocked)
            return {
                "active_ips": active,
                "blocked_ips": blocked,
                "max_connections": self._max_connections,
                "window_seconds": self._window_seconds,
                "block_duration_seconds": self._block_duration_seconds,
            }


_instance: Optional[WebSocketRateLimiter] = None
_instance_lock = threading.RLock()


def get_ws_rate_limiter() -> WebSocketRateLimiter:
    global _instance
    with _instance_lock:
        if _instance is None:
            _instance = WebSocketRateLimiter()
        return _instance
