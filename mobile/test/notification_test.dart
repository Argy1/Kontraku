import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kontraku/models/models.dart';
import 'package:kontraku/models/notification_settings.dart';
import 'package:kontraku/providers/notification_provider.dart';
import 'package:kontraku/services/notification_service.dart';
import 'package:kontraku/services/storage_service.dart';
import 'package:kontraku/widgets/app_bottom_nav.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'support/harness.dart';

Reminder fakeReminder(ReminderType type) => Reminder.fromJson({
      'id': type.index + 1,
      'unit_id': 1,
      'tenant_id': null,
      'type': type.api,
      'due_date': DateTime.now()
          .add(const Duration(days: 5))
          .toIso8601String()
          .substring(0, 10),
      'lead_days': 3,
      'status': 'pending',
      'title': type.label,
      'created_at': '2026-01-01T00:00:00Z',
    });

void main() {
  setUpAll(initLocale);

  Finder navItem(String label) => find.descendant(
        of: find.byType(AppBottomNav),
        matching: find.text(label),
      );

  Future<void> openNotifScreen(WidgetTester tester) async {
    await tester.tap(navItem('Profil'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Notifikasi'));
    await tester.pumpAndSettle();
  }

  testWidgets('layar notifikasi tampil + kirim tes', (tester) async {
    await pumpApp(tester, token: 'user-1');
    await openNotifScreen(tester);

    expect(find.text('Aktifkan notifikasi'), findsOneWidget);
    expect(find.text('Sewa jatuh tempo'), findsOneWidget);
    expect(find.text('Kontrak akan habis'), findsOneWidget);
    expect(find.text('Maintenance'), findsOneWidget);
    expect(find.text('Tagihan utilitas'), findsOneWidget);

    await tester.tap(find.text('Kirim notifikasi tes'));
    await tester.pumpAndSettle();
    expect(lastNotifService!.testCount, 1);
    expect(find.text('Notifikasi tes dikirim'), findsOneWidget);
  });

  testWidgets('matikan salah satu jenis -> tersimpan & terjadwal ulang',
      (tester) async {
    await pumpApp(tester, token: 'user-1');
    await openNotifScreen(tester);

    // seed FakeBackend: ada reminder kontrak_habis + sewa_jatuh_tempo utk Budi
    final before = lastNotifService!.lastSyncCount;
    expect(before, greaterThan(0));

    // matikan "Kontrak akan habis"
    final tile = find.ancestor(
      of: find.text('Kontrak akan habis'),
      matching: find.byType(SwitchListTile),
    );
    await tester.tap(tile);
    await tester.pumpAndSettle();

    expect(lastNotifService!.lastSyncCount, lessThan(before));
  });

  testWidgets('reminder aktif langsung dijadwalkan saat app start',
      (tester) async {
    await pumpApp(tester, token: 'user-1');
    // ReminderScreen di IndexedStack load otomatis -> syncFromReminders
    expect(lastNotifService!.lastSyncCount, greaterThan(0));
  });

  group('NotificationProvider (unit)', () {
    test('toggle enabled & type mengubah settings dan reschedule', () async {
      SharedPreferences.setMockInitialValues({});
      final storage = await StorageService.create();
      final svc = NoopNotificationService();
      final p = NotificationProvider(service: svc, storage: storage);

      final reminders = [
        fakeReminder(ReminderType.sewaJatuhTempo),
        fakeReminder(ReminderType.maintenance),
      ];
      await p.syncFromReminders(reminders);
      expect(svc.lastSyncCount, 2);

      await p.toggleType(ReminderType.maintenance, false);
      expect(svc.lastSyncCount, 1);
      expect(p.settings.types.contains(ReminderType.maintenance), isFalse);

      await p.setEnabled(false);
      expect(svc.lastSyncCount, 0);

      // dimuat ulang dari storage -> setting persist
      final reloaded = storage.notificationSettings;
      expect(reloaded.enabled, isFalse);
      expect(reloaded.types.contains(ReminderType.maintenance), isFalse);
    });

    test('NotificationSettings JSON round-trip', () {
      const s = NotificationSettings(
        enabled: false,
        types: {ReminderType.utilitas},
        hour: 21,
        minute: 30,
      );
      final back = NotificationSettings.fromJson(s.toJson());
      expect(back.enabled, isFalse);
      expect(back.types, {ReminderType.utilitas});
      expect(back.hour, 21);
      expect(back.minute, 30);
    });
  });
}
