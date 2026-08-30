import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:kontraku/app.dart';
import 'package:kontraku/providers/auth_provider.dart';
import 'package:kontraku/providers/dashboard_provider.dart';
import 'package:kontraku/providers/kontrakan_provider.dart';
import 'package:kontraku/providers/notification_provider.dart';
import 'package:kontraku/providers/reminder_provider.dart';
import 'package:kontraku/providers/theme_provider.dart';
import 'package:kontraku/services/api_client.dart';
import 'package:kontraku/services/auth_service.dart';
import 'package:kontraku/services/dashboard_service.dart';
import 'package:kontraku/services/kontrakan_service.dart';
import 'package:kontraku/services/notification_service.dart';
import 'package:kontraku/services/reminder_service.dart';
import 'package:kontraku/services/storage_service.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'fake_backend.dart';

Future<void> initLocale() => initializeDateFormatting('id_ID', null);

/// Bangun & pump aplikasi lengkap dengan backend tiruan.
///
/// [token] null = mulai dari layar login; "user-1" = langsung masuk sebagai Budi
/// (data seed ada di FakeApiClient).
///
/// Kalau ada exception saat build layar mana pun, `testWidgets` otomatis
/// menandai test gagal — jadi test-test ini sekaligus penjaga "tidak ada error".
NoopNotificationService? lastNotifService;

Future<FakeApiClient> pumpApp(WidgetTester tester, {String? token}) async {
  // ukuran layar seukuran HP supaya layout tidak "overflow" di test
  tester.view.physicalSize = const Size(390, 844);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  SharedPreferences.setMockInitialValues(
    token == null ? {} : {'auth_token': token},
  );
  final storage = await StorageService.create();
  final api = FakeApiClient();
  final kontrakanService = KontrakanService(api);

  final notifService = NoopNotificationService();
  lastNotifService = notifService;
  final notifications = NotificationProvider(
    service: notifService,
    storage: storage,
  );
  final reminderProvider = ReminderProvider(ReminderService(api))
    ..onRemindersChanged = notifications.syncFromReminders;

  await tester.pumpWidget(
    MultiProvider(
      providers: [
        Provider<StorageService>.value(value: storage),
        Provider<ApiClient>.value(value: api),
        Provider<KontrakanService>.value(value: kontrakanService),
        Provider<ReminderService>(create: (_) => ReminderService(api)),
        ChangeNotifierProvider(create: (_) => ThemeProvider(storage)),
        ChangeNotifierProvider(
          create: (_) => AuthProvider(
            api: api,
            authService: AuthService(api),
            storage: storage,
          )..bootstrap(),
        ),
        ChangeNotifierProvider(
          create: (_) => DashboardProvider(DashboardService(api)),
        ),
        ChangeNotifierProvider(
          create: (_) => KontrakanListProvider(kontrakanService),
        ),
        ChangeNotifierProvider.value(value: reminderProvider),
        ChangeNotifierProvider.value(value: notifications),
      ],
      child: const KontrakuApp(),
    ),
  );
  await tester.pumpAndSettle();
  return api;
}
