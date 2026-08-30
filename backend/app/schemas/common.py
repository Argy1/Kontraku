from pydantic import BaseModel


class Message(BaseModel):
    """Balasan sederhana untuk aksi yang tidak mengembalikan data."""

    message: str
