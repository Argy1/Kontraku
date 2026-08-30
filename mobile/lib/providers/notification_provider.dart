import 'package:flutter/foundation.dart';

import '../models/models.dart';
import '../models/notification_settings.dart';
import '../services/notification_service.dart';
import '../services/storage_service.dart';

class NotificationProvider extends ChangeNotifier {
  NotificationProvider({
    required NotificationService service,
    required StorageService storage,
  })  : _service = service,
        _storage = storage,
        _settings = storage.notificationSettings;

  final NotificationService _service;
  final StorageService _storage;

  NotificationSettings _settings;
  bool _permissionGranted = false;
  List<Reminder> _lastReminders = const [];

  NotificationSettings get settings => _settings;
  bool get permissionGranted => _permissionGranted;

  /// Dipanggil sekali saat app start.
  Future<void> init() async {
    await _service.init();
    _permissionGranted = await _service.hasPermission();
    notifyListeners();
  }

  /// Minta izin ke sistem (Android 13+ / iOS).
  Future<bool> requestPermission() async {
    _permissionGranted = await _service.requestPermission();
    notifyListeners();
    if (_permissionGranted) await _reschedule();
    return _permissionGranted;
  }

  Future<void> refreshPermission() async {
    _permissionGranted = await _service.hasPermission();
    notifyListeners();
  }

  Future<void> setEnabled(bool value) async {
    _settings = _settings.copyWith(enabled: value);
    await _persistAndReschedule();
  }

  Future<void> toggleType(ReminderType type, bool value) async {
    final next = {..._settings.types};
    value ? next.add(type) : next.remove(type);
    _settings = _settings.copyWith(types: next);
    await _persistAndReschedule();
  }

  Future<void> setTime(int hour, int minute) async {
    _settings = _settings.copyWith(hour: hour, minute: minute);
    await _persistAndReschedule();
  }

  Future<void> sendTest() => _service.showTest();

  /// Dipanggil tiap kali daftar reminder di-load / berubah.
  Future<void> syncFromReminders(List<Reminder> reminders) async {
    _lastReminders = reminders;
    await _reschedule();
  }

  Future<void> _persistAndReschedule() async {
    notifyListeners();
    await _storage.saveNotificationSettings(_settings);
    await _reschedule();
  }

  Future<void> _reschedule() async {
    try {
      await _service.syncReminders(_lastReminders, _settings);
    } catch (e) {
      debugPrint('gagal menjadwalkan notifikasi: $e');
    }
  }
}
