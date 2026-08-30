import 'package:flutter/foundation.dart';

import '../models/models.dart';
import '../services/api_client.dart';
import '../services/kontrakan_service.dart';

/// Daftar kontrakan untuk tab "Kontrakan".
class KontrakanListProvider extends ChangeNotifier {
  KontrakanListProvider(this._service);

  final KontrakanService _service;

  List<Kontrakan> _items = [];
  bool _loading = false;
  String? _error;

  List<Kontrakan> get items => _items;
  bool get loading => _loading;
  String? get error => _error;

  Future<void> load({bool showSpinner = true}) async {
    if (showSpinner) {
      _loading = true;
      _error = null;
      notifyListeners();
    }
    try {
      _items = await _service.list();
      _error = null;
    } on ApiException catch (e) {
      _error = e.message;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  /// Dipanggil setelah tambah/ubah/hapus dari layar lain.
  Future<void> reload() => load(showSpinner: false);
}
