from __future__ import annotations

from python.helpers.print_style import PrintStyle
from python.helpers.websocket import WebSocketHandler


class HelloHandler(WebSocketHandler):
    """Sample handler used for foundational testing.

    SECURITY: Now requires authentication to prevent unauthenticated WebSocket access.
    """

    @classmethod
    def get_event_types(cls) -> list[str]:
        return ["hello_request"]

    async def process_event(self, event_type: str, data: dict, sid: str):
        name = data.get("name") or "stranger"
        # Limit echoed name length to prevent data exfiltration
        safe_name = str(name)[:64]
        PrintStyle.info(f"hello_request from {sid} ({safe_name})")
        return {"message": f"Hello, {safe_name}!", "handler": self.identifier}
