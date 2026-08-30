# Kontraku — Mobile (Flutter)

Aplikasi pemilik kontrakan. Terhubung ke backend FastAPI di `../backend`.

## Struktur `lib/`

```
lib/
├── main.dart                 # setup provider + jalankan app
├── app.dart                  # MaterialApp, tema, "gerbang" login/home
├── config/app_config.dart    # alamat backend (bisa diganti saat build)
├── theme/
│   ├── app_colors.dart       # SEMUA warna, diambil dari design-reference.html
│   └── app_theme.dart        # ThemeData terang & gelap
├── models/                   # bentuk data dari API (mirror schema backend)
├── services/                 # panggilan HTTP (pakai dio)
│   ├── api_client.dart       #   dio + interceptor token + terjemah error
│   ├── auth_service.dart / kontrakan_service.dart / reminder_service.dart / dashboard_service.dart
│   └── reminder_engine.dart  # (backend) — di sini: storage_service.dart (shared_preferences)
├── providers/                # state (ChangeNotifier): auth, theme, dashboard, kontrakan, reminder
├── widgets/                  # komponen UI dipakai ulang (kartu, header, badge, bottom nav)
├── screens/
│   ├── auth/                 # login, register, lupa password
│   ├── home/                 # home_shell (bottom nav) + beranda
│   ├── kontrakan/            # list, detail, form, unit detail + sheet penyewa/pembayaran
│   ├── reminder/             # list + tambah reminder manual
│   └── profil/               # profil + toggle tema + logout
└── utils/                    # formatters (tanggal, rupiah), reminder_style
```

## Menjalankan

Pastikan backend hidup dulu (lihat `../backend/README.md`).

```bash
cd mobile
flutter pub get
```

**Chrome (paling cepat untuk cek):**
```bash
flutter run -d chrome --dart-define=API_BASE_URL=http://localhost:8000
```

**Android Emulator:** (emulator pakai 10.0.2.2 untuk menunjuk PC)
```bash
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:8000
```

**HP fisik (USB):** ganti dengan IP LAN komputer, mis.
```bash
flutter run --dart-define=API_BASE_URL=http://192.168.1.10:8000
```

Login demo (setelah `python -m app.seed` di backend): `budi@email.com` / `password123`

## Cek koneksi ke backend (butuh backend hidup di localhost:8000)

```bash
dart run tool/smoke_api.dart   # ringkas: login + dashboard + list
dart run tool/e2e.dart         # menyeluruh: 38 pemeriksaan, semua endpoint yang dipakai app
```
Dua-duanya memakai layer `services/` + `models/` yang sama dengan UI, jadi kalau
lulus berarti aplikasi tersambung benar ke backend.

## Test & analyze

```bash
flutter analyze                # harus "No issues found!"
flutter test                   # 30 test: unit + alur UI penuh (pakai backend tiruan)
```

`test/support/fake_backend.dart` = backend tiruan di memori. `test/app_flow_test.dart`
& `test/detail_flows_test.dart` menjalankan aplikasi lengkap dan mengklik lewat
setiap layar — kalau ada error render/wiring, test langsung merah.

## Notifikasi

Notifikasi **dijadwalkan lokal di HP** (`flutter_local_notifications`), bukan lewat
server. Alurnya:

1. App memuat daftar reminder aktif (`GET /reminders`) saat dibuka.
2. `NotificationProvider` menjadwalkan 1 notifikasi per reminder pada
   `tanggal_jatuh_tempo − lead_days` di jam yang dipilih (default 08:00).
3. Reminder yang ditandai selesai / dihapus otomatis dibatalkan jadwalnya.

Atur di **Profil → Notifikasi**: saklar utama, per-jenis (sewa/kontrak/maintenance/
utilitas), jam pengingat, dan tombol **"Kirim notifikasi tes"**.

Android butuh izin `POST_NOTIFICATIONS` (diminta saat pertama kali diaktifkan) dan
`USE_EXACT_ALARM` (otomatis untuk app pengingat). Sudah di `AndroidManifest.xml`
beserta 3 `<receiver>` milik plugin + `coreLibraryDesugaring` di `build.gradle.kts`.

FCM (push dari server) belum — perlu proyek Firebase; backend sudah punya slot
adapter-nya.

## Yang belum / ditunda

- **Google Maps**: "pilih lokasi di peta" sementara jadi input lat/lng manual.
  Tambah `google_maps_flutter` + API key nanti.
- **FCM**: lihat bagian Notifikasi di atas.
- **Foto**: pakai `image_picker`; di web berfungsi, di Android/iOS perlu izin
  (sudah ditangani plugin, tapi cek `AndroidManifest`/`Info.plist` kalau ada masalah).
