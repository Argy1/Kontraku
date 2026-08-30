"""Kirim push notification (Firebase Cloud Messaging).

- LogPush : cuma cetak ke terminal — dipakai saat lokal.
- FcmPush : placeholder untuk nanti (butuh service account Firebase).
"""

from __future__ import annotations

import logging
from abc import ABC, abstractmethod

from app.core.config import settings

logger = logging.getLogger("kontraku.push")


class PushSender(ABC):
    @abstractmethod
    def send(self, *, token: str, title: str, body: str, data: dict | None = None) -> None:
        ...


class LogPush(PushSender):
    def send(self, *, token: str, title: str, body: str, data: dict | None = None) -> None:
        logger.info("[PUSH -> %s] %s | %s | data=%s", token[:12], title, body, data or {})


class FcmPush(PushSender):
    def __init__(self) -> None:
        raise NotImplementedError(
            "FcmPush belum diimplementasi. Set PUSH_BACKEND=log untuk sekarang."
        )

    def send(self, *, token: str, title: str, body: str, data: dict | None = None) -> None:  # pragma: no cover
        raise NotImplementedError


def get_push_sender() -> PushSender:
    if settings.PUSH_BACKEND == "fcm":
        return FcmPush()
    return LogPush()
