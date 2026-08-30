// ignore_for_file: avoid_print
//
// Uji menyeluruh: setiap operasi yang dipakai aplikasi Flutter dijalankan
// lewat layer service + model yang SAMA dengan yang dipakai UI, menembak
// backend sungguhan di localhost:8000.
//
// Jalankan:  dart run tool/e2e.dart
// Syarat  :  backend hidup (docker compose up -d + alembic upgrade head + uvicorn)

import 'dart:typed_data';

import 'package:kontraku/models/models.dart';
import 'package:kontraku/services/api_client.dart';
import 'package:kontraku/services/auth_service.dart';
import 'package:kontraku/services/dashboard_service.dart';
import 'package:kontraku/services/kontrakan_service.dart';
import 'package:kontraku/services/reminder_service.dart';

const _email = 'e2e-tester@example.com';
const _otherEmail = 'e2e-other@example.com';
const _password = 'e2etest123';

int _passed = 0;
int _failed = 0;

void check(String name, bool ok, [String extra = '']) {
  if (ok) {
    _passed++;
    print('  ✅ $name${extra.isEmpty ? '' : '  ($extra)'}');
  } else {
    _failed++;
    print('  ❌ $name${extra.isEmpty ? '' : '  ($extra)'}');
  }
}

/// PNG 1x1 transparan — untuk uji upload dokumen.
final _tinyPng = Uint8List.fromList([
  0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A, 0x00, 0x00, 0x00, 0x0D,
  0x49, 0x48, 0x44, 0x52, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x01,
  0x08, 0x06, 0x00, 0x00, 0x00, 0x1F, 0x15, 0xC4, 0x89, 0x00, 0x00, 0x00,
  0x0D, 0x49, 0x44, 0x41, 0x54, 0x78, 0x9C, 0x62, 0x00, 0x01, 0x00, 0x00,
  0x05, 0x00, 0x01, 0x0D, 0x0A, 0x2D, 0xB4, 0x00, 0x00, 0x00, 0x00, 0x49,
  0x45, 0x4E, 0x44, 0xAE, 0x42, 0x60, 0x82,
]);

Future<void> main() async {
  final api = ApiClient();
  final auth = AuthService(api);
  final kontrakanSvc = KontrakanService(api);
  final reminderSvc = ReminderService(api);
  final dashboardSvc = DashboardService(api);

  print('== AUTH ==');
  String token;
  try {
    token = await auth.register(
        name: 'E2E Tester', email: _email, password: _password);
    print('  (user e2e baru dibuat)');
  } on ApiException {
    token = await auth.login(email: _email, password: _password);
    print('  (login user e2e yang sudah ada)');
  }
  api.setToken(token);
  check('register/login menghasilkan token', token.length > 20);

  final me = await auth.me();
  check('GET /auth/me', me.email == _email, me.name);

  // bersih-bersih sisa run sebelumnya
  for (final k in await kontrakanSvc.list()) {
    await kontrakanSvc.delete(k.id);
  }
  check('hapus data sisa run lama', (await kontrakanSvc.list()).isEmpty);

  // token salah -> 401 -> pesan ramah
  try {
    final bad = ApiClient()..setToken('token-ngawur');
    await KontrakanService(bad).list();
    check('token invalid ditolak', false);
  } on ApiException catch (e) {
    check('token invalid ditolak', e.isUnauthorized, e.message);
  }

  print('\n== KONTRAKAN ==');
  final melati = await kontrakanSvc.create(
    name: 'Kontrakan E2E Melati',
    address: 'Jl. Uji No. 1',
    latitude: -6.6,
    longitude: 106.8,
  );
  check('POST /kontrakan', melati.name.contains('Melati'));
  check('lat/lng tersimpan', melati.latitude != null && melati.longitude != null,
      '${melati.latitude}, ${melati.longitude}');

  final anggrek =
      await kontrakanSvc.create(name: 'Kontrakan E2E Anggrek', address: null);
  check('POST /kontrakan tanpa alamat', anggrek.address == null);

  var list = await kontrakanSvc.list();
  check('GET /kontrakan (list)', list.length == 2);

  final renamed =
      await kontrakanSvc.update(melati.id, name: 'Kontrakan E2E Melati 2');
  check('PATCH /kontrakan', renamed.name.endsWith('Melati 2'));

  print('\n== UNIT ==');
  final k1 = await kontrakanSvc.createUnit(melati.id,
      name: 'Kamar 1', status: UnitStatus.kosong, price: 800000);
  final k2 = await kontrakanSvc.createUnit(melati.id,
      name: 'Kamar 2', status: UnitStatus.kosong, price: 850000);
  await kontrakanSvc.createUnit(anggrek.id,
      name: 'Kamar A', status: UnitStatus.renovasi, price: 900000);
  check('POST unit', k1.name == 'Kamar 1' && k1.price == 800000);

  final k1terisi =
      await kontrakanSvc.updateUnit(k1.id, status: UnitStatus.terisi);
  check('PATCH unit (status)', k1terisi.status == UnitStatus.terisi);

  final detail = await kontrakanSvc.detail(melati.id);
  check('GET /kontrakan/{id} (detail + units)', detail.units.length == 2);
  check('ringkasan unit_count/occupied_count',
      detail.unitCount == 2 && detail.occupiedCount == 1,
      '${detail.unitCount}u / ${detail.occupiedCount} terisi');

  print('\n== DOKUMEN / FOTO ==');
  final doc = await kontrakanSvc.uploadDocument(
    melati.id,
    bytes: _tinyPng,
    filename: 'foto.png',
    type: DocumentType.foto,
    label: 'Tampak depan',
  );
  check('POST dokumen (upload multipart)', doc.fileUrl.isNotEmpty, doc.fileUrl);
  final withDoc = await kontrakanSvc.detail(melati.id);
  check('dokumen muncul di detail', withDoc.documents.length == 1);
  await kontrakanSvc.deleteDocument(melati.id, doc.id);
  check('DELETE dokumen',
      (await kontrakanSvc.detail(melati.id)).documents.isEmpty);

  print('\n== PENYEWA ==');
  final now = DateTime.now();
  final joko = await kontrakanSvc.createTenant(
    k1.id,
    name: 'Pak Joko E2E',
    phone: '0812-0000-1111',
    contractStart: now.subtract(const Duration(days: 60)),
    contractEnd: now.add(const Duration(days: 20)),
    rentAmount: 800000,
    dueDay: 15,
  );
  check('POST penyewa', joko.name.contains('Joko') && joko.dueDay == 15);

  var tenants = await kontrakanSvc.tenants(k1.id);
  check('GET penyewa aktif', tenants.length == 1);

  print('\n== PEMBAYARAN ==');
  final pay = await kontrakanSvc.createPayment(
    joko.id,
    amount: 800000,
    paidDate: now,
    periodStart: DateTime(now.year, now.month, 1),
    note: 'Lunas bulan ini',
  );
  check('POST pembayaran', pay.amount == 800000);
  final pays = await kontrakanSvc.payments(joko.id);
  check('GET riwayat pembayaran', pays.length == 1);

  print('\n== REMINDER ==');
  final msg = await reminderSvc.refresh();
  check('POST /reminders/refresh', msg.contains('reminder'), msg);

  var reminders = await reminderSvc.list();
  final hasRent =
      reminders.any((r) => r.type == ReminderType.sewaJatuhTempo);
  final hasContract =
      reminders.any((r) => r.type == ReminderType.kontrakHabis);
  check('reminder sewa & kontrak dibuat otomatis', hasRent && hasContract,
      '${reminders.length} reminder');

  final manual = await reminderSvc.create(
    unitId: k2.id,
    type: ReminderType.maintenance,
    dueDate: now.add(const Duration(days: 4)),
    title: 'Servis AC E2E',
  );
  check('POST reminder manual', manual.title == 'Servis AC E2E');

  await reminderSvc.updateStatus(manual.id, ReminderStatus.done);
  final afterDone = await reminderSvc.list();
  check('PATCH reminder -> done (hilang dari list aktif)',
      afterDone.every((r) => r.id != manual.id));

  reminders = await reminderSvc.list(type: ReminderType.sewaJatuhTempo);
  check('GET /reminders?type= filter',
      reminders.every((r) => r.type == ReminderType.sewaJatuhTempo));

  print('\n== DASHBOARD ==');
  final dash = await dashboardSvc.load();
  check('GET /dashboard', dash.kontrakanCount == 2, dash.greetingName);
  check('dashboard menghitung reminder aktif', dash.activeReminderCount > 0,
      '${dash.activeReminderCount} aktif');
  check('dashboard "perlu perhatian" terisi', dash.attention.isNotEmpty,
      '${dash.attention.length} item');

  print('\n== ARSIP PENYEWA ==');
  await kontrakanSvc.archiveTenant(joko.id);
  check('POST /tenants/{id}/archive',
      (await kontrakanSvc.tenants(k1.id)).isEmpty);
  tenants = await kontrakanSvc.tenants(k1.id, includeInactive: true);
  check('penyewa lama masih ada di riwayat', tenants.length == 1);
  check('riwayat pembayaran ikut terjaga',
      (await kontrakanSvc.payments(joko.id)).length == 1);

  print('\n== ISOLASI ANTAR AKUN ==');
  final otherApi = ApiClient();
  final otherAuth = AuthService(otherApi);
  String otherToken;
  try {
    otherToken = await otherAuth.register(
        name: 'Orang Lain', email: _otherEmail, password: _password);
  } on ApiException {
    otherToken = await otherAuth.login(
        email: _otherEmail, password: _password);
  }
  otherApi.setToken(otherToken);
  final otherSvc = KontrakanService(otherApi);
  check('akun lain tidak melihat kontrakan kita',
      (await otherSvc.list()).where((k) => k.id == melati.id).isEmpty);
  try {
    await otherSvc.detail(melati.id);
    check('akun lain -> 404 di detail milik orang', false);
  } on ApiException catch (e) {
    check('akun lain -> 404 di detail milik orang', e.statusCode == 404);
  }

  print('\n== LUPA / RESET PASSWORD ==');
  final resetToken = await AuthService(ApiClient()).forgotPassword(_email);
  check('POST /auth/forgot-password (token dev)', resetToken != null);
  if (resetToken != null) {
    await AuthService(ApiClient())
        .resetPassword(token: resetToken, newPassword: _password);
    final relog = await AuthService(ApiClient())
        .login(email: _email, password: _password);
    check('login lagi setelah reset', relog.length > 20);
  }

  print('\n== HAPUS (CASCADE) ==');
  await kontrakanSvc.deleteUnit(k2.id);
  check('DELETE unit', (await kontrakanSvc.detail(melati.id)).units.length == 1);
  await kontrakanSvc.delete(melati.id);
  await kontrakanSvc.delete(anggrek.id);
  check('DELETE kontrakan', (await kontrakanSvc.list()).isEmpty);
  check('reminder ikut terhapus (cascade)',
      (await reminderSvc.list(includeDone: true)).isEmpty);

  print('\n=====================================');
  print('  LULUS: $_passed   GAGAL: $_failed');
  print('=====================================');
  if (_failed > 0) {
    throw StateError('$_failed pemeriksaan gagal');
  }
}
