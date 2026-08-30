import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

import '../models/models.dart';
import '../models/notification_settings.dart';
import '../utils/formatters.dart';

/// Notifikasi dijadwalkan LANGSUNG DI HP (flutter_local_notifications),
/// tidak lewat server / Firebase. Cocok untuk reminder karena app sudah
/// tahu semua tanggal jatuh tempo.
///
/// FCM (push dari server) bisa ditambahkan nanti — butuh proyek Firebase.
abstract class NotificationService {
  Future<void> init();
  Future<bool> requestPermission();
  Future<bool> hasPermission();
  Future<void> showTest();

  /// Batalkan semua jadwal lalu jadwalkan ulang dari daftar reminder aktif.
  Future<void> syncReminders(
    List<Reminder> reminders,
    NotificationSettings settings,
  );

  Future<void> cancelAll();
}

class LocalNotificationService implements NotificationService {
  final _plugin = FlutterLocalNotificationsPlugin();
  bool _ready = false;

  static const _channelId = 'kontraku_reminders';
  static const _channelName = 'Pengingat';
  static const _channelDesc =
      'Sewa jatuh tempo, kontrak habis, maintenance, tagihan utilitas';

  AndroidFlutterLocalNotificationsPlugin? get _android => _plugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();

  @override
  Future<void> init() async {
    if (_ready) return;

    tzdata.initializeTimeZones();
    try {
      tz.setLocalLocation(tz.getLocation(await FlutterTimezone.getLocalTimezone()));
    } catch (_) {
      tz.setLocalLocation(tz.getLocation('Asia/Jakarta'));
    }

    await _plugin.initialize(
      const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        iOS: DarwinInitializationSettings(
          requestAlertPermission: false,
          requestBadgePermission: false,
          requestSoundPermission: false,
        ),
      ),
    );

    await _android?.createNotificationChannel(
      const AndroidNotificationChannel(
        _channelId,
        _channelName,
        description: _channelDesc,
        importance: Importance.high,
      ),
    );

    _ready = true;
  }

  @override
  Future<bool> requestPermission() async {
    await init();
    final android = _android;
    if (android != null) {
      final granted = await android.requestNotificationsPermission() ?? false;
      // izin alarm presisi (Android 12+). Dengan USE_EXACT_ALARM di manifest
      // biasanya sudah otomatis; ini cuma jaga-jaga.
      await android.requestExactAlarmsPermission();
      return granted;
    }
    final ios = _plugin.resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin>();
    if (ios != null) {
      return await ios.requestPermissions(alert: true, badge: true, sound: true) ??
          false;
    }
    return true;
  }

  @override
  Future<bool> hasPermission() async {
    await init();
    final android = _android;
    if (android != null) {
      return await android.areNotificationsEnabled() ?? false;
    }
    return true;
  }

  NotificationDetails get _details => const NotificationDetails(
        android: AndroidNotificationDetails(
          _channelId,
          _channelName,
          channelDescription: _channelDesc,
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      );

  @override
  Future<void> showTest() async {
    await init();
    await _plugin.show(
      999000,
      'Notifikasi tes',
      'Kalau kamu lihat ini, notifikasi Kontraku aktif. 🎉',
      _details,
    );
  }

  @override
  Future<void> cancelAll() async {
    await init();
    await _plugin.cancelAll();
  }

  @override
  Future<void> syncReminders(
    List<Reminder> reminders,
    NotificationSettings settings,
  ) async {
    await init();
    await _plugin.cancelAll();
    if (!settings.enabled) return;

    final now = tz.TZDateTime.now(tz.local);

    for (final r in reminders) {
      if (!settings.wants(r.type)) continue;
      if (r.status != ReminderStatus.pending &&
          r.status != ReminderStatus.sent) {
        continue;
      }

      // Ideal: H-leadDays pada jam yang dipilih.
      var fireAt = tz.TZDateTime(
        tz.local,
        r.dueDate.year,
        r.dueDate.month,
        r.dueDate.day,
        settings.hour,
        settings.minute,
      ).subtract(Duration(days: r.leadDays));

      final dueDay = tz.TZDateTime(
          tz.local, r.dueDate.year, r.dueDate.month, r.dueDate.day, 23, 59);

      if (fireAt.isBefore(now)) {
        // Jadwal idealnya sudah lewat. Kalau reminder-nya masih relevan
        // (belum lewat tanggal jatuh tempo), ingatkan sebentar lagi.
        if (dueDay.isAfter(now)) {
          fireAt = now.add(const Duration(seconds: 10));
        } else {
          continue; // sudah basi
        }
      }

      try {
        await _plugin.zonedSchedule(
          r.id,
          r.displayTitle,
          _bodyFor(r),
          fireAt,
          _details,
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        );
      } catch (e) {
        // mis. izin exact alarm belum ada -> coba mode tidak presisi
        debugPrint('zonedSchedule gagal ($e), fallback inexact');
        await _plugin.zonedSchedule(
          r.id,
          r.displayTitle,
          _bodyFor(r),
          fireAt,
          _details,
          androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        );
      }
    }
  }

  String _bodyFor(Reminder r) {
    final left = relativeDays(r.daysLeft);
    return 'Jatuh tempo ${formatDate(r.dueDate)} · $left';
  }
}

/// Dipakai di test / platform tanpa notifikasi.
class NoopNotificationService implements NotificationService {
  int testCount = 0;
  int lastSyncCount = 0;

  @override
  Future<void> init() async {}
  @override
  Future<bool> requestPermission() async => true;
  @override
  Future<bool> hasPermission() async => true;
  @override
  Future<void> showTest() async => testCount++;
  @override
  Future<void> cancelAll() async {}
  @override
  Future<void> syncReminders(List<Reminder> r, NotificationSettings s) async {
    lastSyncCount = s.enabled ? r.where((x) => s.wants(x.type)).length : 0;
  }
}
