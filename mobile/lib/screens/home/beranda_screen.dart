import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/models.dart';
import '../../providers/auth_provider.dart';
import '../../providers/dashboard_provider.dart';
import '../../theme/app_colors.dart';
import '../../utils/formatters.dart';
import '../../widgets/widgets.dart';
import '../kontrakan/kontrakan_detail_screen.dart';

class BerandaScreen extends StatefulWidget {
  const BerandaScreen({super.key, required this.onSeeAllKontrakan});

  final VoidCallback onSeeAllKontrakan;

  @override
  State<BerandaScreen> createState() => _BerandaScreenState();
}

class _BerandaScreenState extends State<BerandaScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => context.read<DashboardProvider>().load(),
    );
  }

  Future<void> _openKontrakan(int id) async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => KontrakanDetailScreen(kontrakanId: id)),
    );
    if (mounted) context.read<DashboardProvider>().load(showSpinner: false);
  }

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final provider = context.watch<DashboardProvider>();
    final data = provider.data;
    final user = context.watch<AuthProvider>().user;

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () => context.read<DashboardProvider>().load(showSpinner: false),
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            _Header(
              name: data?.greetingName ?? user?.name ?? '',
              initials: user?.initials ?? '?',
              kontrakanCount: data?.kontrakanCount ?? 0,
              reminderCount: data?.activeReminderCount ?? 0,
            ),
            if (provider.loading && data == null)
              const Padding(
                padding: EdgeInsets.only(top: 60),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (provider.error != null && data == null)
              Padding(
                padding: const EdgeInsets.only(top: 40),
                child: ErrorRetry(
                  message: provider.error!,
                  onRetry: () => context.read<DashboardProvider>().load(),
                ),
              )
            else if (data != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 18, 16, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SectionHeader('Perlu perhatian'),
                    const SizedBox(height: 10),
                    if (data.attention.isEmpty)
                      _MiniEmpty(
                        icon: Icons.check_circle_outline,
                        text: 'Tidak ada yang mendesak. Aman 👍',
                        color: c.textSecondary,
                      )
                    else
                      ...data.attention.map(
                        (item) => Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: AttentionCard(
                            item: item,
                            onTap: () => _openKontrakan(
                              _kontrakanIdForAttention(data, item),
                            ),
                          ),
                        ),
                      ),
                    const SizedBox(height: 14),
                    SectionHeader(
                      'Kontrakan saya',
                      actionLabel: data.kontrakan.length > 2 ? 'Lihat semua' : null,
                      onAction: widget.onSeeAllKontrakan,
                    ),
                    const SizedBox(height: 10),
                    if (data.kontrakan.isEmpty)
                      _MiniEmpty(
                        icon: Icons.home_outlined,
                        text: 'Belum ada kontrakan. Tambah dari tab Kontrakan.',
                        color: c.textSecondary,
                      )
                    else
                      ...data.kontrakan.take(5).toList().asMap().entries.map(
                            (e) => Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: KontrakanCard(
                                kontrakan: e.value,
                                index: e.key,
                                onTap: () => _openKontrakan(e.value.id),
                              ),
                            ),
                          ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  /// Attention item hanya membawa nama kontrakan, bukan id. Cocokkan lewat nama.
  int _kontrakanIdForAttention(Dashboard data, AttentionItem item) {
    final match = data.kontrakan.where((k) => k.name == item.kontrakanName);
    return match.isEmpty ? data.kontrakan.first.id : match.first.id;
  }
}

class _Header extends StatelessWidget {
  const _Header({
    required this.name,
    required this.initials,
    required this.kontrakanCount,
    required this.reminderCount,
  });

  final String name;
  final String initials;
  final int kontrakanCount;
  final int reminderCount;

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    return DecorativeHeader(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      greeting(),
                      style: TextStyle(fontSize: 13, color: c.headerAccentText),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      name.isEmpty ? '...' : name,
                      style: const TextStyle(
                        fontSize: 23,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: 42,
                height: 42,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: c.avatarBg,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  initials,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: c.avatarText,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: HeaderStatCard(
                  icon: Icons.apartment_rounded,
                  value: '$kontrakanCount',
                  label: 'Kontrakan',
                  iconColor: c.avatarBg,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: HeaderStatCard(
                  icon: Icons.notifications_active_rounded,
                  value: '$reminderCount',
                  label: 'Reminder',
                  iconColor: c.contractBar,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MiniEmpty extends StatelessWidget {
  const _MiniEmpty({
    required this.icon,
    required this.text,
    required this.color,
  });

  final IconData icon;
  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.of(context).surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.of(context).cardBorder, width: 0.5),
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: color),
          const SizedBox(width: 10),
          Expanded(child: Text(text, style: TextStyle(fontSize: 14, color: color))),
        ],
      ),
    );
  }
}
