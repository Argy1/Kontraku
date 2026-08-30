import 'package:flutter/foundation.dart';

import '../models/models.dart';
import '../services/api_client.dart';
import '../services/dashboard_service.dart';

class DashboardProvider extends ChangeNotifier {
  DashboardProvider(this._service);

  final DashboardService _service;

  Dashboard? _data;
  bool _loading = false;
  String? _error;

  Dashboard? get data => _data;
  bool get loading => _loading;
  String? get error => _error;

  Future<void> load({bool showSpinner = true}) async {
    if (showSpinner) {
      _loading = true;
      _error = null;
      notifyListeners();
    }
    try {
      _data = await _service.load();
      _error = null;
    } on ApiException catch (e) {
      _error = e.message;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }
}
