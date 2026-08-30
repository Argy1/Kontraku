import 'package:dio/dio.dart';

import '../config/app_config.dart';

/// Error yang sudah "dirapikan" untuk ditampilkan ke pengguna.
class ApiException implements Exception {
  ApiException(this.message, {this.statusCode});

  final String message;
  final int? statusCode;

  bool get isUnauthorized => statusCode == 401;

  @override
  String toString() => message;
}

/// Pembungkus tipis di atas Dio.
///
/// Tugasnya:
/// - set base URL & timeout
/// - menyisipkan header `Authorization: Bearer <token>` otomatis
/// - menerjemahkan DioException jadi ApiException yang pesannya ramah
class ApiClient {
  ApiClient({String? baseUrl}) {
    _dio = Dio(
      BaseOptions(
        baseUrl: (baseUrl == null || baseUrl.isEmpty)
            ? AppConfig.apiBaseUrl
            : baseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 15),
        headers: {'Accept': 'application/json'},
      ),
    );

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          if (_token != null) {
            options.headers['Authorization'] = 'Bearer $_token';
          }
          handler.next(options);
        },
      ),
    );
  }

  late final Dio _dio;
  String? _token;

  /// Dipanggil kalau server menolak token (401) di endpoint non-auth.
  /// AuthProvider memakainya untuk otomatis logout.
  void Function()? onUnauthorized;

  /// Dipanggil AuthProvider setelah login / saat start / saat logout.
  void setToken(String? token) => _token = token;

  /// Alamat backend yang sedang dipakai.
  String get baseUrl => _dio.options.baseUrl;

  /// Ganti alamat backend saat runtime (dipakai layar "Pengaturan server").
  void setBaseUrl(String url) => _dio.options.baseUrl = url.trim();

  Future<dynamic> get(String path, {Map<String, dynamic>? query}) =>
      _run(() => _dio.get(path, queryParameters: query));

  Future<dynamic> post(String path, {Object? body}) =>
      _run(() => _dio.post(path, data: body));

  Future<dynamic> postForm(String path, Map<String, dynamic> fields) =>
      _run(() => _dio.post(path, data: FormData.fromMap(fields)));

  Future<dynamic> patch(String path, {Object? body}) =>
      _run(() => _dio.patch(path, data: body));

  Future<dynamic> delete(String path) => _run(() => _dio.delete(path));

  /// Cek apakah backend di [testUrl] (atau baseUrl saat ini) hidup.
  Future<bool> checkHealth({String? testUrl}) async {
    try {
      final res = await Dio(
        BaseOptions(
          baseUrl: testUrl ?? _dio.options.baseUrl,
          connectTimeout: const Duration(seconds: 5),
          receiveTimeout: const Duration(seconds: 5),
        ),
      ).get('/health');
      return res.statusCode == 200;
    } on DioException {
      return false;
    }
  }

  Future<dynamic> _run(Future<Response<dynamic>> Function() call) async {
    try {
      final response = await call();
      return response.data;
    } on DioException catch (e) {
      throw _toApiException(e);
    }
  }

  ApiException _toApiException(DioException e) {
    final status = e.response?.statusCode;
    final data = e.response?.data;

    final path = e.requestOptions.path;
    if (status == 401 && !path.startsWith('/auth/')) {
      onUnauthorized?.call();
    }

    // FastAPI mengembalikan {"detail": "..."} atau {"detail": [ {msg: ...} ]}
    String? detail;
    if (data is Map && data['detail'] != null) {
      final d = data['detail'];
      if (d is String) {
        detail = d;
      } else if (d is List && d.isNotEmpty && d.first is Map) {
        detail = (d.first as Map)['msg']?.toString();
      }
    }

    if (detail != null) return ApiException(detail, statusCode: status);

    final message = switch (e.type) {
      DioExceptionType.connectionTimeout ||
      DioExceptionType.receiveTimeout ||
      DioExceptionType.sendTimeout =>
        'Koneksi ke server timeout. Coba lagi.',
      DioExceptionType.connectionError =>
        'Tidak bisa terhubung ke server. Pastikan backend berjalan.',
      _ => status != null
          ? 'Terjadi kesalahan ($status).'
          : 'Terjadi kesalahan jaringan.',
    };
    return ApiException(message, statusCode: status);
  }
}
