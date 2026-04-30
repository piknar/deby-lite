from __future__ import annotations

import asyncio
from typing import Any, Dict

from python.helpers.print_style import PrintStyle
from python.helpers import runtime
from python.helpers.websocket import WebSocketHandler, WebSocketResult


class DevWebsocketTestHandler(WebSocketHandler):
    """Test harness handler powering the developer WebSocket validation component.

    SECURITY: This handler is restricted to development mode only.
    All events are blocked in production to prevent abuse as a C2 attack vector.
    Only ws_event_console_subscribe/unsubscribe have a distinct non-dev error path
    for diagnostic clarity.
    """

    @classmethod
    def get_event_types(cls) -> list[str]:
        return [
            