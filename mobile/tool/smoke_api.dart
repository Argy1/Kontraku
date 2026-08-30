// ignore_for_file: avoid_print
//
// Cek cepat layer service + parsing model lawan backend yang jalan di localhost:8000.
// Jalankan:  dart run tool/smoke_api.dart
// (butuh backend hidup + sudah di-seed: budi@email.com / password123)

import 'package:kontraku/services/api_client.dart';
import 'package:kontraku/services/auth_service.dart';
import 'package:kontraku/services/dashboard_service.dart';
import 'package:kontraku/services/kontrakan_service.dart';
import 'package:kontraku/services/reminder_service.dart';

Future<void> main() async {
  final api = ApiClient();
  final auth = AuthService(api);

  final token = await auth.login(email: 'budi@email.com', password: 'password123');
  api.setToken(token);
  final me = await auth.me();
  print('login OK -> ${me.name} <${me.email}>');

  final dash = await DashboardService(api).load();
  print('\ndashboard: ${dash.kontrakanCount} kontrakan, '
      '${dash.activeReminderCount} reminder aktif, '
      '${dash.attention.length} perlu perhatian');
  for (final a in dash.attention) {
    print('  - [${a.type.label}] ${a.title} — ${a.daysLeft} hari @ ${a.kontrakanName}');
  }

  final list = await KontrakanService(api).list();
  final ringkas = list
      .map((k) => '${k.name} (${k.unitCount} unit / ${k.occupiedCount} terisi)')
      .join(', ');
  print('\nkontrakan: $ringkas');

  final detail = await KontrakanService(api).detail(list.first.id);
  print('detail "${detail.name}": '
      '${detail.units.map((u) => "${u.name}=${u.status.name}").join(", ")}');

  final reminders = await ReminderService(api).list();
  print('\nreminder aktif: ${reminders.length} '
      '(${reminders.map((r) => r.type.name).toSet().join(", ")})');

  print('\nSEMUA OK ✅');
}
