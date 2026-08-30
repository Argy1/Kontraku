import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';

import 'app.dart';
import 'providers/auth_provider.dart';
import 'providers/dashboard_provider.dart';
import 'providers/kontrakan_provider.dart';
import 'providers/notification_provider.dart';
import 'providers/reminder_provider.dart';
import 'providers/theme_provider.dart';
import 'services/api_client.dart';
import 'services/auth_service.dart';
import 'services/dashboard_service.dart';
import 'services/kontrakan_service.dart';
import 'services/notification_service.dart';
import 'services/reminder_service.dart';
import 'services/storage_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('id_ID', null); // data locale untuk intl

  final storage = await StorageService.create();
  // alamat backend: pakai yang disimpan pengguna kalau ada, kalau tidak pakai
  // default dari --dart-define / AppConfig.
  final api = ApiClient(baseUrl: storage.apiBaseUrl);
  final kontrakanService = KontrakanService(api);

  // Notifikasi lokal (dijadwalkan di HP). Wiring: tiap kali daftar reminder
  // berubah, ReminderProvider memberi tahu NotificationProvider untuk
  // menjadwalkan ulang.
  final notifications = NotificationProvider(
    service: LocalNotificationService(),
    storage: storage,
  )..init();
  final reminderProvider = ReminderProvider(ReminderService(api))
    ..onRemindersChanged = notifications.syncFromReminders;

  runApp(
    MultiProvider(
      providers: [
        // --- layer service (tidak notify, cukup Provider biasa) ---
        Provider<StorageService>.value(value: storage),
        Provider<ApiClient>.value(value: api),
        Provider<KontrakanService>.value(value: kontrakanService),
        Provider<ReminderService>(create: (_) => ReminderService(api)),

        // --- layer state (ChangeNotifier) ---
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
}
