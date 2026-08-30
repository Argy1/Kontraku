"""Kirim email (untuk sekarang cuma dipakai reset password).

- ConsoleEmail : cetak isi email ke terminal — dipakai saat lokal.
- SmtpEmail    : placeholder untuk nanti.
"""

from __future__ import annotations

import logging
from abc import ABC, abstractmethod

from app.core.config import settings

logger = logging.getLogger("kontraku.email")


class EmailSender(ABC):
    @abstractmethod
    def send(self, *, to: str, subject: str, body: str) -> None:
        ...


class ConsoleEmail(EmailSender):
    def send(self, *, to: str, subject: str, body: str) -> None:
        logger.info("\n--- EMAIL ---\nTo: %s\nSubject: %s\n\n%s\n-------------", to, subject, body)


class SmtpEmail(EmailSender):
    def __init__(self) -> None:
        raise NotImplementedError(
            "SmtpEmail belum diimplementasi. Set EMAIL_BACKEND=console untuk sekarang."
        )

    def send(self, *, to: str, subject: str, body: str) -> None:  # pragma: no cover
        raise NotImplementedError


def get_email_sender() -> EmailSender:
    if settings.EMAIL_BACKEND == "smtp":
        return SmtpEmail()
    return ConsoleEmail()
