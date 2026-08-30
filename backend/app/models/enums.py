"""Kumpulan pilihan tetap (enum) yang dipakai kolom-kolom model.

Pakai `str, enum.Enum` supaya nilainya gampang dikirim/diterima sebagai JSON
di API nanti (langsung jadi string biasa).
"""

import enum


class UnitStatus(str, enum.Enum):
    kosong = "kosong"
    terisi = "terisi"
    renovasi = "renovasi"


class ReminderType(str, enum.Enum):
    # 4 tipe reminder sesuai brief
    sewa_jatuh_tempo = "sewa_jatuh_tempo"
    kontrak_habis = "kontrak_habis"
    maintenance = "maintenance"
    utilitas = "utilitas"


class ReminderStatus(str, enum.Enum):
    pending = "pending"      # belum waktunya / belum dikirim
    sent = "sent"            # notifikasi FCM sudah dikirim
    done = "done"            # sudah ditindaklanjuti pemilik
    dismissed = "dismissed"  # diabaikan pemilik


class DocumentType(str, enum.Enum):
    ktp = "ktp"
    surat_kontrak = "surat_kontrak"
    foto = "foto"
    lainnya = "lainnya"
