import 'package:flutter/material.dart';

import '../../widgets/app_bottom_nav.dart';
import '../kontrakan/kontrakan_list_screen.dart';
import '../profil/profil_screen.dart';
import '../reminder/reminder_screen.dart';
import 'beranda_screen.dart';

/// Kerangka utama setelah login: 4 tab + bottom nav.
///
/// Memakai IndexedStack supaya state tiap tab (posisi scroll, data yang sudah
/// dimuat) tidak hilang saat pindah tab.
class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _index = 0;

  void _goToTab(int i) => setState(() => _index = i);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _index,
        sizing: StackFit.expand,
        children: [
          BerandaScreen(onSeeAllKontrakan: () => _goToTab(1)),
          const KontrakanListScreen(),
          const ReminderScreen(),
          const ProfilScreen(),
        ],
      ),
      bottomNavigationBar: AppBottomNav(
        currentIndex: _index,
        onTap: _goToTab,
      ),
    );
  }
}
