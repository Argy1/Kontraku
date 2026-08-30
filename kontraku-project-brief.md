# Kontraku — project brief

Aplikasi reminder & manajemen kontrakan untuk pemilik properti sewa. Dipakai lewat mobile app (Android/iOS), penyewa tidak punya akses.

## Tech stack
- **Mobile**: Flutter (Dart)
- **Backend**: FastAPI (Python)
- **Database**: PostgreSQL
- **Hosting**: Railway (backend + database)
- **Auth**: JWT
- **Notifikasi**: Firebase Cloud Messaging (FCM)
- **Storage foto/dokumen**: Cloudinary
- **Map/lokasi**: Google Maps Flutter plugin + Geocoding API

## Fitur inti (MVP)
1. **Auth** — register, login, reset password. Setiap akun = 1 tenant data terisolasi.
2. **Kontrakan** — CRUD, nama, alamat, lokasi (lat/long), multi-foto, jumlah unit.
3. **Unit** — per kontrakan, punya status (kosong/terisi/renovasi), harga sewa.
4. **Penyewa (tenant)** — data per unit: nama, kontak, tanggal mulai/akhir kontrak, jumlah sewa, tanggal jatuh tempo. Riwayat penyewa lama diarsipkan (`is_active = false`), bukan dihapus.
5. **Payment log** — riwayat pembayaran per tenant per periode.
6. **Reminder** — 4 tipe: sewa jatuh tempo, kontrak akan habis, maintenance, tagihan utilitas. Trigger H- sekian hari, kirim via FCM.
7. **Dashboard/beranda** — ringkasan reminder mendekati due date + status unit.
8. **Pendukung**: search & filter, upload dokumen (KTP/surat kontrak), catatan bebas per unit, export laporan (nice-to-have, boleh disusul).

## ERD (ringkasan)
```
USERS (id, name, email, password_hash)
  └─< KONTRAKAN (id, owner_id FK, name, address, lat, lng)
        ├─< UNIT (id, kontrakan_id FK, name, status, price)
        │     └─< TENANT (id, unit_id FK, name, phone, contract_end, is_active)
        │           ├─< PAYMENT (id, tenant_id FK, amount, paid_date)
        │           └─< REMINDER (id, tenant_id FK, unit_id FK, type, due_date)
        └─< DOCUMENT (id, kontrakan_id FK, file_url, type)
```

## Desain — "Hangat & Jelas"
Target pengguna termasuk orang tua, jadi prioritas: font lebih besar dari standar, kontras tinggi, kartu besar dengan jarak lega, label teks di tiap ikon navigasi (bukan ikon doang).

**Palet warna** (dari Claude color ramps):
- Header/aksen utama: teal (`#085041` light header, `#04342C` dark header)
- Reminder sewa: amber (`#EF9F27` / `#FAEEDA`)
- Reminder kontrak: coral (`#D85A30` / `#FAECE7`)
- Kartu kontrakan: purple (`#3C3489`/`#CECBF6`) & pink (`#72243E`/`#F4C0D1`) bergantian
- Status "terisi": green (`#27500A`/`#EAF3DE`); "kosong": gray

**Tipografi**: judul kartu 16-17px, angka ringkasan 22-26px, body 13-15px (lebih besar dari UI standar).

**Tema**: ikut sistem (light/dark) secara default, dengan toggle manual di halaman Profil (`ThemeMode.system` / `.light` / `.dark`, disimpan via `shared_preferences`).

**Layar yang sudah didesain** (rujukan visual, screenshot ada di riwayat chat Claude):
1. Beranda — header teal dekoratif, ringkasan (jumlah kontrakan & reminder), kartu "perlu perhatian", daftar kontrakan
2. Detail kontrakan — foto header, alamat, daftar unit dengan badge status
3. Tambah kontrakan — form: foto, nama, alamat, pilih lokasi di peta
4. Reminder — dikelompokkan per waktu (hari ini/minggu ini/bulan ini), filter kategori
5. Profil — avatar, toggle tema (otomatis/terang/gelap), pengaturan, logout

## Struktur folder yang disarankan
```
Kontraku/
├── backend/          # FastAPI
│   ├── app/
│   │   ├── models/
│   │   ├── routers/
│   │   ├── schemas/
│   │   └── main.py
│   └── requirements.txt
└── mobile/           # Flutter
    ├── lib/
    │   ├── screens/
    │   ├── widgets/
    │   ├── models/
    │   ├── services/
    │   └── theme/
    └── pubspec.yaml
```
