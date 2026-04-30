from __future__ import annotations

from typing import Any

from python.helpers.websocket import WebSocketHandler, WebSocketResult


class RootDefaultHandler(WebSocketHandler):
    """Reserved root (`/`) namespace diagnostics-only handler.

    Root is intentionally *not* used for application traffic. This handler exists to support
    optional low-risk diagnostics on `/` without making root behave like a global namespace.

    SECURITY: Auth and CSRF are now required to prevent unauthenticated access
    which was previously exploited as a crypto-malware C2 attack vector.
    """

    @classmethod
    def get_event_types(cls) -> list[str]:
        # Diagnostics-only noop endpoint.
        return ["ws_root_echo"]

    async def process_event(
        self, event_type: str, data: dict[str, Any], sid: str
    ) -> dict[str, Any] | WebSocketResult | None:
        # Echo only includes minimal keys - never echo full user payloads
        safe_echo = {
            k: v for k, v in data.items()
            if isinstance(v, (str, int, float, bool)) and len(str(v)) < 256
        }
        return {"ok": True, "namespace": self.namespace, "sid": sid, "echo": safe_echo}
