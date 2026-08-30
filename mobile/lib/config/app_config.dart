/// Konfigurasi yang bisa diganti saat build tanpa mengubah kode.
///
/// Contoh menjalankan dengan alamat backend berbeda:
///   flutter run --dart-define=API_BASE_URL=http://10.0.2.2:8000
///
/// Nilai default `http://localhost:8000` cocok untuk:
///   - Flutter web (Chrome)
///   - iOS Simulator
/// Untuk Android Emulator gunakan http://10.0.2.2:8000
/// Untuk HP fisik gunakan IP LAN komputer, mis. http://192.168.1.10:8000
class AppConfig {
  const AppConfig._();

  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:8000',
  );

  /// Nilai ini cuma jadi default AWAL. Pengguna bisa menimpanya dari layar
  /// "Pengaturan server" di halaman login (disimpan lewat StorageService),
  /// jadi tidak perlu build ulang setiap IP LAN PC berubah.
}
