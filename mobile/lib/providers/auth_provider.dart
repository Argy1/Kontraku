import 'package:flutter/foundation.dart';

import '../models/models.dart';
import '../services/api_client.dart';
import '../services/auth_service.dart';
import '../services/storage_service.dart';

enum AuthStatus { unknown, authenticated, unauthenticated }

/// Sumber kebenaran status login. Widget mendengarkan ini untuk memutuskan
/// menampilkan halaman login atau halaman utama.
class AuthProvider extends ChangeNotifier {
  AuthProvider({
    required ApiClient api,
    required AuthService authService,
    required StorageService storage,
  })  : _api = api,
        _auth = authService,
        _storage = storage {
    _api.onUnauthorized = _handleUnauthorized;
  }

  final ApiClient _api;
  final AuthService _auth;
  final StorageService _storage;

  AuthStatus _status = AuthStatus.unknown;
  User? _user;
  String? _error;
  bool _busy = false;

  AuthStatus get status => _status;
  User? get user => _user;
  String? get error => _error;
  bool get busy => _busy;

  /// Dipanggil sekali saat app start: cek apakah ada token tersimpan & masih valid.
  Future<void> bootstrap() async {
    final token = _storage.token;
    if (token == null) {
      _status = AuthStatus.unauthenticated;
      notifyListeners();
      return;
    }
    _api.setToken(token);
    try {
      _user = await _auth.me();
      _status = AuthStatus.authenticated;
    } on ApiException {
      await _storage.clearToken();
      _api.setToken(null);
      _status = AuthStatus.unauthenticated;
    }
    notifyListeners();
  }

  Future<bool> login({required String email, required String password}) {
    return _authenticate(() => _auth.login(email: email, password: password));
  }

  Future<bool> register({
    required String name,
    required String email,
    required String password,
  }) {
    return _authenticate(
      () => _auth.register(name: name, email: email, password: password),
    );
  }

  Future<void> logout() async {
    await _storage.clearToken();
    _api.setToken(null);
    _user = null;
    _status = AuthStatus.unauthenticated;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  /// Mengembalikan reset_token (hanya terisi saat backend mode development).
  Future<String?> forgotPassword(String email) => _auth.forgotPassword(email);

  Future<void> resetPassword({
    required String token,
    required String newPassword,
  }) =>
      _auth.resetPassword(token: token, newPassword: newPassword);

  Future<bool> _authenticate(Future<String> Function() getToken) async {
    _busy = true;
    _error = null;
    notifyListeners();
    try {
      final token = await getToken();
      await _storage.saveToken(token);
      _api.setToken(token);
      _user = await _auth.me();
      _status = AuthStatus.authenticated;
      return true;
    } on ApiException catch (e) {
      _error = e.message;
      return false;
    } finally {
      _busy = false;
      notifyListeners();
    }
  }

  void _handleUnauthorized() {
    // token kadaluarsa di tengah pemakaian -> paksa kembali ke login
    _storage.clearToken();
    _api.setToken(null);
    _user = null;
    _status = AuthStatus.unauthenticated;
    notifyListeners();
  }
}
