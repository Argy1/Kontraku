import 'package:flutter/material.dart';

import '../services/storage_service.dart';

/// Mengelola pilihan tema (otomatis / terang / gelap) dan menyimpannya
/// lewat shared_preferences, sesuai brief.
class ThemeProvider extends ChangeNotifier {
  ThemeProvider(this._storage) : _mode = _storage.themeMode;

  final StorageService _storage;
  ThemeMode _mode;

  ThemeMode get mode => _mode;

  Future<void> setMode(ThemeMode mode) async {
    if (mode == _mode) return;
    _mode = mode;
    notifyListeners();
    await _storage.saveThemeMode(mode);
  }
}
