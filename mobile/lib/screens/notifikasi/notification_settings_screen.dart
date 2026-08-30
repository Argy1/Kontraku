import 'package:app_settings/app_settings.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/enums.dart';
import '../../providers/notification_provider.dart';
import '../../theme/app_colors.dart';

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  State<NotificationSettingsScreen> createState() =>
      _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState
    extends State<NotificationSettingsScreen> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    context.read<NotificationProvider>().refreshPermission();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // balik dari halaman pengaturan sistem -> cek ulang izin
    if (state == AppLifecycleState.resumed) {
      context.read<NotificationProvider>().refreshPermission();
    }
  }

  Future<void> _enable(bool value) async {
    final notif = context.read<NotificationProvider>();
    if (value && !notif.permissionGranted) {
      final ok = await notif.requestPermission();
      if (!ok) {
        if (mounted) _showPermissionSheet();
        return;
      }
    }
    await notif.setEnabled(value);
  }

  void _showPermissionSheet() {
    showModalBottomSheet(
      context: context,
      builder: (_) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Izin notifikasi ditolak',
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            const Text(
              'Aktifkan izin notifikasi untuk Kontraku lewat Pengaturan sistem, '
              'lalu kembali ke sini.',
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: () {
                Navigator.pop(context);
                AppSettings.openAppSettings(
                    type: AppSettingsType.notification);
              },
              icon: const Icon(Icons.open_in_new),
              label: const Text('Buka pengaturan'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickTime() async {
    final notif = context.read<NotificationProvider>();
    final s = notif.settings;
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: s.hour, minute: s.minute),
    );
    if (picked != null) {
      await notif.setTime(picked.hour, picked.minute);
    }
  }

  Future<void> _test() async {
    final notif = context.read<NotificationProvider>();
    if (!notif.permissionGranted) {
      final ok = await notif.requestPermission();
      if (!ok) {
        if (mounted) _showPermissionSheet();
        return;
      }
    }
    await notif.sendTest();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Notifikasi tes dikirim')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final notif = context.watch<NotificationProvider>();
    final s = notif.settings;
    final on = s.enabled;

    return Scaffold(
      appBar: AppBar(title: const Text('Notifikasi')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (!notif.permissionGranted)
            Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: c.rentBg,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, size: 18, color: c.rentText),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Izin notifikasi belum diberikan.',
                      style: TextStyle(fontSize: 13, color: c.rentText),
                    ),
                  ),
                  TextButton(
                    onPressed: () => AppSettings.openAppSettings(
                        type: AppSettingsType.notification),
                    child: const Text('Atur'),
                  ),
                ],
              ),
            ),
          Card(
            child: SwitchListTile(
              title: const Text('Aktifkan notifikasi',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
              subtitle: Text(
                'Pengingat dijadwalkan di HP ini berdasarkan tanggal jatuh '
                'tempo tiap reminder (H- sesuai pengaturan reminder).',
                style: TextStyle(fontSize: 12, color: c.textSecondary),
              ),
              value: on,
              onChanged: _enable,
            ),
          ),
          const SizedBox(height: 16),
          Opacity(
            opacity: on ? 1 : 0.5,
            child: IgnorePointer(
              ignoring: !on,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('JENIS PENGINGAT',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.4,
                        color: c.textMuted,
                      )),
                  const SizedBox(height: 8),
                  Card(
                    child: Column(
                      children: [
                        for (final t in ReminderType.values) ...[
                          SwitchListTile(
                            dense: true,
                            title: Text(t.label,
                                style: const TextStyle(fontSize: 14)),
                            value: s.types.contains(t),
                            onChanged: (v) =>
                                context.read<NotificationProvider>()
                                    .toggleType(t, v),
                          ),
                          if (t != ReminderType.values.last)
                            Divider(height: 1, color: c.cardBorder),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Card(
                    child: ListTile(
                      leading: Icon(Icons.schedule, color: c.textSecondary),
                      title: const Text('Jam pengingat',
                          style: TextStyle(fontSize: 14)),
                      subtitle: Text(
                        'Notifikasi dikirim jam '
                        '${s.hour.toString().padLeft(2, '0')}:'
                        '${s.minute.toString().padLeft(2, '0')}',
                        style: TextStyle(fontSize: 12, color: c.textSecondary),
                      ),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: _pickTime,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          OutlinedButton.icon(
            onPressed: _test,
            icon: const Icon(Icons.notifications_active_outlined),
            label: const Text('Kirim notifikasi tes'),
          ),
          const SizedBox(height: 12),
          Text(
            'Catatan: notifikasi ini dijadwalkan lokal, jadi tetap muncul walau '
            'HP offline. Reminder yang dibuat/diubah di HP lain baru ikut '
            'terjadwal setelah kamu membuka app ini.',
            style: TextStyle(fontSize: 12, color: c.textMuted),
          ),
        ],
      ),
    );
  }
}
