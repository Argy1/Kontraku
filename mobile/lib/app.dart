import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/auth_provider.dart';
import 'providers/theme_provider.dart';
import 'screens/auth/login_screen.dart';
import 'screens/home/home_shell.dart';
import 'screens/splash_screen.dart';
import 'theme/app_theme.dart';

class KontrakuApp extends StatelessWidget {
  const KontrakuApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeMode = context.watch<ThemeProvider>().mode;

    return MaterialApp(
      title: 'Kontraku',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: themeMode, // ThemeMode.system / .light / .dark
      home: const _RootGate(),
    );
  }
}

/// Menentukan layar pertama berdasarkan status login.
class _RootGate extends StatelessWidget {
  const _RootGate();

  @override
  Widget build(BuildContext context) {
    final status = context.watch<AuthProvider>().status;
    return switch (status) {
      AuthStatus.unknown => const SplashScreen(),
      AuthStatus.unauthenticated => const LoginScreen(),
      AuthStatus.authenticated => const HomeShell(),
    };
  }
}
