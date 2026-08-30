import 'package:flutter/foundation.dart';

import '../models/models.dart';
import '../services/api_client.dart';
import '../services/reminder_service.dart';

class ReminderProvider extends ChangeNotifier {
  ReminderProvider(this._service);

  final ReminderService _service;

  /// Dipanggil tiap kali daftar reminder aktif berubah (untuk menjadwalkan
  /// ulang notifikasi lokal). Diset di main.dart.
  void Function(List<Reminder> reminders)? onRemindersChanged;

  List<Reminder> _all = [];
  bool _loading = false;
  String? _error;
  ReminderType? _filter; // null = semua

  /// Daftar sesuai filter yang dipilih di layar.
  List<Reminder> get items => _filter == null
      ? _all
      : _all.where((r) => r.type == _filter).toList();

  bool get loading => _loading;
  String? get error => _error;
  ReminderType? get filter => _filter;

  void setFilter(ReminderType? type) {
    _filter = type;
    notifyListeners();
  }

  Future<void> load({bool showSpinner = true}) async {
    if (showSpinner) {
      _loading = true;
      _error = null;
      notifyListeners();
    }
    try {
      _all = await _service.list(); // selalu ambil semua yang aktif
      _error = null;
      onRemindersChanged?.call(_all);
    } on ApiException catch (e) {
      _error = e.message;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<String> refreshFromTenants() async {
    final message = await _service.refresh();
    await load(showSpinner: false);
    return message;
  }

  Future<void> markDone(int id) async {
    await _service.updateStatus(id, ReminderStatus.done);
    _all = _all.where((r) => r.id != id).toList();
    onRemindersChanged?.call(_all);
    notifyListeners();
  }

  Future<void> delete(int id) async {
    await _service.delete(id);
    _all = _all.where((r) => r.id != id).toList();
    onRemindersChanged?.call(_all);
    notifyListeners();
  }

  // --- pengelompokan untuk tampilan "hari ini / minggu ini / nanti" ---

  List<Reminder> get today => items.where((r) => r.daysLeft <= 0).toList();

  List<Reminder> get thisWeek =>
      items.where((r) => r.daysLeft > 0 && r.daysLeft <= 7).toList();

  List<Reminder> get later => items.where((r) => r.daysLeft > 7).toList();
}
