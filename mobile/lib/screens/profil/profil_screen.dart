import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../providers/theme_provider.dart';
import '../../services/api_client.dart';
import '../../theme/app_colors.dart';
import '../auth/server_settings_sheet.dart';
import '../notifikasi/notification_settings_screen.dart';

class ProfilScreen extends StatelessWidget {
  const ProfilScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final user = context.watch<AuthProvider>().user;
    final themeProvider = context.watch<ThemeProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Profil')),
      body: ListView(
        children: [
          const SizedBox(height: 12),
          Center(
            child: Column(
              children: [
                Container(
                  width: 72,
                  height: 72,
                  alignment: Alignment.center,
                  decoration:
                      BoxDecoration(color: c.avatarBg, shape: BoxShape.circle),
                  child: Text(
                    user?.initials ?? '?',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                      color: c.avatarText,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Text(user?.name ?? '-',
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.w600)),
                const SizedBox(height: 3),
                Text(user?.email ?? '-',
                    style: TextStyle(fontSize: 13, color: c.textSecondary)),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _Label('Tampilan'),
                const SizedBox(height: 8),
                _Panel(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.brightness_6_outlined,
                                size: 19, color: c.textSecondary),
                            const SizedBox(width: 12),
                            const Text('Tema', style: TextStyle(fontSize: 15)),
                          ],
                        ),
                        const SizedBox(height: 10),
                        _ThemeToggle(
                          mode: themeProvider.mode,
                          onChanged: themeProvider.setMode,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                _Label('Lainnya'),
                const SizedBox(height: 8),
                _Panel(
                  child: Column(
                    children: [
                      _Row(
                        icon: Icons.dns_outlined,
                        label: 'Pengaturan server',
                        onTap: () => ServerSettingsSheet.show(context),
                      ),
                      Divider(height: 1, color: c.cardBorder),
                      _Row(
                        icon: Icons.notifications_outlined,
                        label: 'Notifikasi',
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const NotificationSettingsScreen(),
                          ),
                        ),
                      ),
                      Divider(height: 1, color: c.cardBorder),
                      _Row(
                        icon: Icons.help_outline,
                        label: 'Bantuan',
                        onTap: () => _soon(context),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                _Panel(
                  border: c.contractCardBorder,
                  child: _Row(
                    icon: Icons.logout,
                    label: 'Keluar',
                    color: c.contractText,
                    onTap: () => _confirmLogout(context),
                  ),
                ),
                const SizedBox(height: 24),
                Center(
                  child: Text(
                    'Kontraku v1.0.0\nserver: ${context.read<ApiClient>().baseUrl}',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 11, color: c.textMuted),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _soon(BuildContext context) => ScaffoldMessenger.of(context)
      .showSnackBar(const SnackBar(content: Text('Segera hadir')));

  Future<void> _confirmLogout(BuildContext context) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Keluar dari akun?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Batal')),
          FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Keluar')),
        ],
      ),
    );
    if (ok == true && context.mounted) {
      await context.read<AuthProvider>().logout();
    }
  }
}

class _Label extends StatelessWidget {
  const _Label(this.text);
  final String text;
  @override
  Widget build(BuildContext context) => Text(
        text.toUpperCase(),
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.4,
          color: AppColors.of(context).textMuted,
        ),
      );
}

class _Panel extends StatelessWidget {
  const _Panel({required this.child, this.border});
  final Widget child;
  final Color? border;

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    return Container(
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: border ?? c.cardBorder, width: 0.5),
      ),
      clipBehavior: Clip.antiAlias,
      child: child,
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({
    required this.icon,
    required this.label,
    required this.onTap,
    this.color,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final fg = color ?? c.textPrimary;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Icon(icon, size: 19, color: color ?? c.textSecondary),
            const SizedBox(width: 12),
            Text(label, style: TextStyle(fontSize: 15, color: fg)),
            const Spacer(),
            if (color == null)
              Icon(Icons.chevron_right, size: 18, color: c.textMuted),
          ],
        ),
      ),
    );
  }
}

class _ThemeToggle extends StatelessWidget {
  const _ThemeToggle({required this.mode, required this.onChanged});

  final ThemeMode mode;
  final ValueChanged<ThemeMode> onChanged;

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    const options = [
      (ThemeMode.system, 'Otomatis'),
      (ThemeMode.light, 'Terang'),
      (ThemeMode.dark, 'Gelap'),
    ];
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: c.background,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          for (final (m, label) in options)
            Expanded(
              child: GestureDetector(
                onTap: () => onChanged(m),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  padding: const EdgeInsets.symmetric(vertical: 7),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: m == mode ? c.primary : Colors.transparent,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: m == mode ? c.onPrimary : c.textSecondary,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
