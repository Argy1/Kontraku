import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/notification_settings.dart';

/// Penyimpanan lokal sederhana: token login + pilihan tema.
///
/// Catatan: untuk produksi, token sebaiknya di `flutter_secure_storage`.
/// Di sini pakai shared_preferences supaya setup tetap ringkas.
class StorageService {
  StorageService(this._prefs);

  final SharedPreferences _prefs;

  static const _kToken = 'auth_token';
  static const _kThemeMode = 'theme_mode';
  static const _kApiBaseUrl = 'api_base_url';
  static const _kNotif = 'notification_settings';

  static Future<StorageService> create() async =>
      StorageService(await SharedPreferences.getInstance());

  // --- token ---
  String? get token => _prefs.getString(_kToken);

  Future<void> saveToken(String token) => _prefs.setString(_kToken, token);

  Future<void> clearToken() => _prefs.remove(_kToken);

  // --- tema ---
  ThemeMode get themeMode {
    switch (_prefs.getString(_kThemeMode)) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }

  Future<void> saveThemeMode(ThemeMode mode) =>
      _prefs.setString(_kThemeMode, mode.name);

  // --- alamat backend (bisa diubah dari dalam app, berguna saat IP LAN berubah) ---
  String? get apiBaseUrl => _prefs.getString(_kApiBaseUrl);

  Future<void> saveApiBaseUrl(String url) =>
      _prefs.setString(_kApiBaseUrl, url.trim());

  Future<void> clearApiBaseUrl() => _prefs.remove(_kApiBaseUrl);

  // --- pengaturan notifikasi ---
  NotificationSettings get notificationSettings {
    final raw = _prefs.getString(_kNotif);
    if (raw == null) return const NotificationSettings();
    try {
      return NotificationSettings.fromJson(
        jsonDecode(raw) as Map<String, dynamic>,
      );
    } catch (_) {
      return const NotificationSettings();
    }
  }

  Future<void> saveNotificationSettings(NotificationSettings s) =>
      _prefs.setString(_kNotif, jsonEncode(s.toJson()));
}
