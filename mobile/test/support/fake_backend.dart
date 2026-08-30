import 'package:collection/collection.dart';
import 'package:dio/dio.dart';
import 'package:kontraku/services/api_client.dart';

/// Backend tiruan di memori untuk widget test — meniru perilaku FastAPI
/// (bentuk JSON, status code, isolasi per-akun) tanpa jaringan.
///
/// Dipakai dengan menaruh instance ini sebagai `ApiClient` di Provider.
class FakeApiClient extends ApiClient {
  FakeApiClient({this.seed = true}) {
    if (seed) _seed();
  }

  final bool seed;

  final _users = <Map<String, dynamic>>[];
  final _kontrakan = <Map<String, dynamic>>[];
  final _units = <Map<String, dynamic>>[];
  final _tenants = <Map<String, dynamic>>[];
  final _payments = <Map<String, dynamic>>[];
  final _documents = <Map<String, dynamic>>[];
  final _reminders = <Map<String, dynamic>>[];
  int _seq = 0;

  int get _id => ++_seq;
  String _nowIso() => DateTime.now().toUtc().toIso8601String();
  String _date(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  // Token = "user-<id>". _currentUserId dibaca ulang tiap request dari header
  // yang di-set lewat setToken().
  String? _token;
  @override
  void setToken(String? token) => _token = token;

  int? get _uid {
    if (_token == null) return null;
    final m = RegExp(r'^user-(\d+)$').firstMatch(_token!);
    return m == null ? null : int.parse(m.group(1)!);
  }

  ApiException _err(int code, String msg) => ApiException(msg, statusCode: code);

  void _seed() {
    final uid = _id;
    _users.add({'id': uid, 'name': 'Pak Budi', 'email': 'budi@email.com', 'password': 'password123', 'created_at': _nowIso()});
    final k1 = _mkKontrakan(uid, 'Kontrakan melati', 'Jl. mawar no. 5');
    final k2 = _mkKontrakan(uid, 'Kontrakan anggrek', 'Jl. kenanga no. 12');
    final u1 = _mkUnit(k1, 'Kamar 1', 'terisi', 800000);
    _mkUnit(k1, 'Kamar 2', 'kosong', 850000);
    _mkUnit(k2, 'Kamar 1', 'terisi', 900000);
    final t = _mkTenant(u1, 'Pak Joko', dueDay: 15, rent: 800000, contractEndInDays: 10);
    _payments.add({'id': _id, 'tenant_id': t, 'amount': 800000, 'paid_date': _date(DateTime.now()), 'period_start': null, 'note': null, 'created_at': _nowIso()});
    _refreshReminders(uid);
  }

  int _mkKontrakan(int owner, String name, String? address) {
    final id = _id;
    _kontrakan.add({'id': id, 'owner_id': owner, 'name': name, 'address': address, 'latitude': null, 'longitude': null, 'created_at': _nowIso()});
    return id;
  }

  int _mkUnit(int kontrakanId, String name, String status, num? price) {
    final id = _id;
    _units.add({'id': id, 'kontrakan_id': kontrakanId, 'name': name, 'status': status, 'price': price, 'created_at': _nowIso()});
    return id;
  }

  int _mkTenant(int unitId, String name,
      {int? dueDay, num? rent, int? contractEndInDays}) {
    final id = _id;
    _tenants.add({
      'id': id,
      'unit_id': unitId,
      'name': name,
      'phone': null,
      'contract_start': null,
      'contract_end': contractEndInDays == null
          ? null
          : _date(DateTime.now().add(Duration(days: contractEndInDays))),
      'rent_amount': rent,
      'due_day': dueDay,
      'is_active': true,
      'created_at': _nowIso(),
    });
    return id;
  }

  // --- helpers kepemilikan ---
  Map<String, dynamic>? _ownedKontrakan(int id) {
    final k = _kontrakan.firstWhereOrNull((e) => e['id'] == id);
    return (k != null && k['owner_id'] == _uid) ? k : null;
  }

  Map<String, dynamic>? _ownedUnit(int id) {
    final u = _units.firstWhereOrNull((e) => e['id'] == id);
    if (u == null) return null;
    return _ownedKontrakan(u['kontrakan_id'] as int) == null ? null : u;
  }

  Map<String, dynamic>? _ownedTenant(int id) {
    final t = _tenants.firstWhereOrNull((e) => e['id'] == id);
    if (t == null) return null;
    return _ownedUnit(t['unit_id'] as int) == null ? null : t;
  }

  Map<String, dynamic> _kontrakanOut(Map<String, dynamic> k) {
    final units = _units.where((u) => u['kontrakan_id'] == k['id']);
    return {
      ...k,
      'unit_count': units.length,
      'occupied_count': units.where((u) => u['status'] == 'terisi').length,
    };
  }

  /// Mirror backend: buang reminder sewa/kontrak yang tidak lagi cocok dengan
  /// data penyewa (diarsipkan, due_day/contract_end berubah).
  void _dismissAutoRemindersForTenant(int tenantId) {
    final t = _tenants.firstWhereOrNull((x) => x['id'] == tenantId);
    for (final r in _reminders) {
      if (r['tenant_id'] != tenantId) continue;
      if (r['type'] != 'sewa_jatuh_tempo' && r['type'] != 'kontrak_habis') {
        continue;
      }
      if (r['status'] != 'pending' && r['status'] != 'sent') continue;

      var valid = t != null && t['is_active'] == true;
      if (valid && r['type'] == 'sewa_jatuh_tempo') {
        final dd = t['due_day'];
        valid = dd != null &&
            (r['due_date'] as String)
                .endsWith('-${dd.toString().padLeft(2, '0')}');
      } else if (valid && r['type'] == 'kontrak_habis') {
        valid = t['contract_end'] == r['due_date'];
      }
      if (!valid) r['status'] = 'dismissed';
    }
  }

  void _refreshReminders(int owner) {
    final today = DateTime.now();
    for (final t in _tenants.where((t) => t['is_active'] == true)) {
      final unit = _units.firstWhere((u) => u['id'] == t['unit_id']);
      if (_kontrakan.firstWhere((k) => k['id'] == unit['kontrakan_id'])['owner_id'] != owner) {
        continue;
      }
      void ensure(String type, String due, String title) {
        final exists = _reminders.any((r) =>
            r['unit_id'] == unit['id'] &&
            r['tenant_id'] == t['id'] &&
            r['type'] == type &&
            r['due_date'] == due);
        if (!exists) {
          _reminders.add({
            'id': _id,
            'unit_id': unit['id'],
            'tenant_id': t['id'],
            'type': type,
            'due_date': due,
            'lead_days': 3,
            'status': 'pending',
            'title': title,
            'created_at': _nowIso(),
          });
        }
      }

      if (t['contract_end'] != null) {
        final end = DateTime.parse(t['contract_end'] as String);
        if (end.difference(today).inDays <= 60 && !end.isBefore(today)) {
          ensure('kontrak_habis', t['contract_end'] as String,
              'Kontrak akan habis - ${unit['name']}');
        }
      }
      if (t['due_day'] != null) {
        final day = t['due_day'] as int;
        var due = DateTime(today.year, today.month, day);
        if (due.isBefore(DateTime(today.year, today.month, today.day))) {
          due = DateTime(today.year, today.month + 1, day);
        }
        ensure('sewa_jatuh_tempo', _date(due),
            'Sewa jatuh tempo - ${unit['name']}');
      }
    }
  }

  // ================= override ApiClient =================

  @override
  Future<dynamic> get(String path, {Map<String, dynamic>? query}) async =>
      _route('GET', path, query: query);

  @override
  Future<dynamic> post(String path, {Object? body}) async =>
      _route('POST', path, body: body);

  @override
  Future<dynamic> postForm(String path, Map<String, dynamic> fields) async =>
      _route('POST', path, body: fields);

  @override
  Future<dynamic> patch(String path, {Object? body}) async =>
      _route('PATCH', path, body: body);

  @override
  Future<dynamic> delete(String path) async => _route('DELETE', path);

  dynamic _route(String method, String path,
      {Object? body, Map<String, dynamic>? query}) {
    final b = _asMap(body);
    final seg = path.split('/').where((s) => s.isNotEmpty).toList();

    // ---- auth ----
    if (path == '/auth/register' && method == 'POST') {
      if (_users.any((u) => u['email'] == b['email'])) {
        throw _err(409, 'Email sudah terdaftar');
      }
      final id = _id;
      _users.add({'id': id, 'name': b['name'], 'email': b['email'], 'password': b['password'], 'created_at': _nowIso()});
      return {'access_token': 'user-$id', 'token_type': 'bearer'};
    }
    if (path == '/auth/login' && method == 'POST') {
      final u = _users.where((u) => u['email'] == b['username'] && u['password'] == b['password']).firstOrNull;
      if (u == null) throw _err(401, 'Email atau password salah');
      return {'access_token': 'user-${u['id']}', 'token_type': 'bearer'};
    }
    if (path == '/auth/me' && method == 'GET') {
      final u = _users.where((u) => u['id'] == _uid).firstOrNull;
      if (u == null) throw _err(401, 'Token tidak valid');
      return {'id': u['id'], 'name': u['name'], 'email': u['email'], 'created_at': u['created_at']};
    }
    if (path == '/auth/forgot-password' && method == 'POST') {
      return {'message': 'ok', 'reset_token': 'reset-token'};
    }
    if (path == '/auth/reset-password' && method == 'POST') {
      return {'message': 'Password berhasil diubah.'};
    }

    if (_uid == null) throw _err(401, 'Token tidak valid atau kadaluarsa');

    // ---- dashboard ----
    if (path == '/dashboard' && method == 'GET') {
      final mine = _kontrakan.where((k) => k['owner_id'] == _uid).toList();
      final active = _reminders.where((r) {
        final unit = _units.firstWhere((u) => u['id'] == r['unit_id']);
        final k = _kontrakan.firstWhere((k) => k['id'] == unit['kontrakan_id']);
        return k['owner_id'] == _uid && (r['status'] == 'pending' || r['status'] == 'sent');
      }).toList();
      final today = DateTime.now();
      return {
        'greeting_name': _users.firstWhere((u) => u['id'] == _uid)['name'],
        'kontrakan_count': mine.length,
        'active_reminder_count': active.length,
        'attention': active.take(5).map((r) {
          final unit = _units.firstWhere((u) => u['id'] == r['unit_id']);
          final k = _kontrakan.firstWhere((k) => k['id'] == unit['kontrakan_id']);
          return {
            'reminder_id': r['id'],
            'type': r['type'],
            'title': r['title'],
            'due_date': r['due_date'],
            'days_left': DateTime.parse(r['due_date'] as String)
                .difference(DateTime(today.year, today.month, today.day))
                .inDays,
            'unit_name': unit['name'],
            'kontrakan_name': k['name'],
          };
        }).toList(),
        'kontrakan': mine.map(_kontrakanOut).toList(),
      };
    }

    // ---- kontrakan ----
    if (path == '/kontrakan') {
      if (method == 'GET') {
        return _kontrakan.where((k) => k['owner_id'] == _uid).map(_kontrakanOut).toList();
      }
      if (method == 'POST') {
        final id = _id;
        final row = {'id': id, 'owner_id': _uid, 'name': b['name'], 'address': b['address'], 'latitude': b['latitude'], 'longitude': b['longitude'], 'created_at': _nowIso()};
        _kontrakan.add(row);
        return _kontrakanOut(row);
      }
    }
    if (seg.length >= 2 && seg[0] == 'kontrakan') {
      final kid = int.tryParse(seg[1]);
      final k = kid == null ? null : _ownedKontrakan(kid);
      if (k == null) throw _err(404, 'Kontrakan tidak ditemukan');

      if (seg.length == 2) {
        if (method == 'GET') {
          return {
            ..._kontrakanOut(k),
            'units': _units.where((u) => u['kontrakan_id'] == kid).toList(),
            'documents': _documents.where((d) => d['kontrakan_id'] == kid).toList(),
          };
        }
        if (method == 'PATCH') {
          for (final e in b.entries) {
            k[e.key] = e.value;
          }
          return _kontrakanOut(k);
        }
        if (method == 'DELETE') {
          _cascadeDeleteKontrakan(kid!);
          return null;
        }
      }
      if (seg.length == 3 && seg[2] == 'units') {
        if (method == 'GET') {
          return _units.where((u) => u['kontrakan_id'] == kid).toList();
        }
        if (method == 'POST') {
          final id = _id;
          final row = {'id': id, 'kontrakan_id': kid, 'name': b['name'], 'status': b['status'] ?? 'kosong', 'price': b['price'], 'created_at': _nowIso()};
          _units.add(row);
          return row;
        }
      }
      if (seg.length == 3 && seg[2] == 'documents') {
        if (method == 'GET') {
          return _documents.where((d) => d['kontrakan_id'] == kid).toList();
        }
        if (method == 'POST') {
          final id = _id;
          final row = {'id': id, 'kontrakan_id': kid, 'file_url': 'http://fake/uploads/$id.png', 'type': b['type'] ?? 'foto', 'label': b['label'], 'created_at': _nowIso()};
          _documents.add(row);
          return row;
        }
      }
      if (seg.length == 4 && seg[2] == 'documents' && method == 'DELETE') {
        _documents.removeWhere((d) => d['id'] == int.parse(seg[3]));
        return null;
      }
    }

    // ---- units ----
    if (seg.length >= 2 && seg[0] == 'units') {
      final uid = int.tryParse(seg[1]);
      final u = uid == null ? null : _ownedUnit(uid);
      if (u == null) throw _err(404, 'Unit tidak ditemukan');
      if (seg.length == 2) {
        if (method == 'GET') return u;
        if (method == 'PATCH') {
          for (final e in b.entries) {
            u[e.key] = e.value;
          }
          return u;
        }
        if (method == 'DELETE') {
          _units.removeWhere((x) => x['id'] == uid);
          _tenants.removeWhere((t) => t['unit_id'] == uid);
          _reminders.removeWhere((r) => r['unit_id'] == uid);
          return null;
        }
      }
      if (seg.length == 3 && seg[2] == 'tenants') {
        if (method == 'GET') {
          final inc = query?['include_inactive'] == true;
          return _tenants.where((t) => t['unit_id'] == uid && (inc || t['is_active'] == true)).toList();
        }
        if (method == 'POST') {
          final id = _id;
          final row = {
            'id': id,
            'unit_id': uid,
            'name': b['name'],
            'phone': b['phone'],
            'contract_start': b['contract_start'],
            'contract_end': b['contract_end'],
            'rent_amount': b['rent_amount'],
            'due_day': b['due_day'],
            'is_active': true,
            'created_at': _nowIso(),
          };
          _tenants.add(row);
          _refreshReminders(_uid!);
          return row;
        }
      }
    }

    // ---- tenants ----
    if (seg.length >= 2 && seg[0] == 'tenants') {
      final tid = int.tryParse(seg[1]);
      final t = tid == null ? null : _ownedTenant(tid);
      if (t == null) throw _err(404, 'Penyewa tidak ditemukan');
      if (seg.length == 3 && seg[2] == 'archive' && method == 'POST') {
        t['is_active'] = false;
        _dismissAutoRemindersForTenant(tid!);
        return t;
      }
      if (seg.length == 3 && seg[2] == 'payments') {
        if (method == 'GET') {
          return _payments.where((p) => p['tenant_id'] == tid).toList();
        }
        if (method == 'POST') {
          final id = _id;
          final row = {'id': id, 'tenant_id': tid, 'amount': b['amount'], 'paid_date': b['paid_date'], 'period_start': b['period_start'], 'note': b['note'], 'created_at': _nowIso()};
          _payments.add(row);
          return row;
        }
      }
      if (seg.length == 2 && method == 'PATCH') {
        for (final e in b.entries) {
          t[e.key] = e.value;
        }
        // mirror backend: due_day/contract_end berubah -> reminder lama dibuang,
        // yang baru dibuat
        _dismissAutoRemindersForTenant(tid!);
        _refreshReminders(_uid!);
        return t;
      }
    }

    // ---- reminders ----
    if (path == '/reminders/refresh' && method == 'POST') {
      _refreshReminders(_uid!);
      return {'message': '1 reminder baru dibuat.'};
    }
    if (path == '/reminders') {
      final mine = _reminders.where((r) {
        final unit = _units.where((u) => u['id'] == r['unit_id']).firstOrNull;
        if (unit == null) return false;
        final k = _kontrakan.firstWhere((k) => k['id'] == unit['kontrakan_id']);
        return k['owner_id'] == _uid;
      }).toList();
      if (method == 'GET') {
        final type = query?['type'];
        final incDone = query?['include_done'] == true;
        return mine.where((r) {
          if (type != null && r['type'] != type) return false;
          if (!incDone && !(r['status'] == 'pending' || r['status'] == 'sent')) {
            return false;
          }
          return true;
        }).toList();
      }
      if (method == 'POST') {
        final id = _id;
        final row = {'id': id, 'unit_id': b['unit_id'], 'tenant_id': b['tenant_id'], 'type': b['type'], 'due_date': b['due_date'], 'lead_days': b['lead_days'] ?? 3, 'status': 'pending', 'title': b['title'], 'created_at': _nowIso()};
        _reminders.add(row);
        return row;
      }
    }
    if (seg.length == 2 && seg[0] == 'reminders') {
      final rid = int.parse(seg[1]);
      final r = _reminders.where((r) => r['id'] == rid).firstOrNull;
      if (r == null) throw _err(404, 'Reminder tidak ditemukan');
      if (method == 'PATCH') {
        for (final e in b.entries) {
          r[e.key] = e.value;
        }
        return r;
      }
      if (method == 'DELETE') {
        _reminders.removeWhere((x) => x['id'] == rid);
        return {'message': 'Reminder dihapus.'};
      }
    }

    throw _err(500, 'Rute tiruan tidak dikenal: $method $path');
  }

  void _cascadeDeleteKontrakan(int kid) {
    final unitIds = _units.where((u) => u['kontrakan_id'] == kid).map((u) => u['id']).toSet();
    final tenantIds = _tenants.where((t) => unitIds.contains(t['unit_id'])).map((t) => t['id']).toSet();
    _payments.removeWhere((p) => tenantIds.contains(p['tenant_id']));
    _reminders.removeWhere((r) => unitIds.contains(r['unit_id']));
    _tenants.removeWhere((t) => unitIds.contains(t['unit_id']));
    _units.removeWhere((u) => u['kontrakan_id'] == kid);
    _documents.removeWhere((d) => d['kontrakan_id'] == kid);
    _kontrakan.removeWhere((k) => k['id'] == kid);
  }

  Map<String, dynamic> _asMap(Object? body) {
    if (body == null) return {};
    if (body is Map<String, dynamic>) return body;
    if (body is Map) return body.map((k, v) => MapEntry('$k', v));
    if (body is FormData) {
      final m = <String, dynamic>{};
      for (final f in body.fields) {
        m[f.key] = f.value;
      }
      for (final f in body.files) {
        m[f.key] = f.value.filename;
      }
      return m;
    }
    return {};
  }
}
