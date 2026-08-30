import '../models/models.dart';
import 'api_client.dart';

class AuthService {
  AuthService(this._api);

  final ApiClient _api;

  /// Register -> backend langsung mengembalikan token.
  Future<String> register({
    required String name,
    required String email,
    required String password,
  }) async {
    final data = await _api.post('/auth/register', body: {
      'name': name,
      'email': email,
      'password': password,
    });
    return data['access_token'] as String;
  }

  /// Login pakai form-data OAuth2 (username = email).
  Future<String> login({
    required String email,
    required String password,
  }) async {
    final data = await _api.postForm('/auth/login', {
      'username': email,
      'password': password,
    });
    return data['access_token'] as String;
  }

  Future<User> me() async {
    final data = await _api.get('/auth/me');
    return User.fromJson(data as Map<String, dynamic>);
  }

  /// Mengembalikan reset_token (hanya ada saat backend mode development).
  Future<String?> forgotPassword(String email) async {
    final data = await _api.post('/auth/forgot-password', body: {'email': email});
    return data['reset_token'] as String?;
  }

  Future<void> resetPassword({
    required String token,
    required String newPassword,
  }) {
    return _api.post('/auth/reset-password', body: {
      'token': token,
      'new_password': newPassword,
    });
  }
}
