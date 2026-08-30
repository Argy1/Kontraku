import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/models.dart';
import '../../providers/dashboard_provider.dart';
import '../../providers/reminder_provider.dart';
import '../../widgets/widgets.dart';
import 'add_reminder_screen.dart';

class ReminderScreen extends StatefulWidget {
  const ReminderScreen({super.key});

  @override
  State<ReminderScreen> createState() => _ReminderScreenState();
}

class _ReminderScreenState extends State<ReminderScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => context.read<ReminderProvider>().load(),
    );
  }

  Future<void> _refreshFromTenants() async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      final msg = await context.read<ReminderProvider>().refreshFromTenants();
      messenger.showSnackBar(SnackBar(content: Text(msg)));
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text('$e')));
    }
  }

  Future<void> _complete(int id) async {
    try {
      await context.read<ReminderProvider>().markDone(id);
      if (mounted) {
        context.read<DashboardProvider>().load(showSpinner: false);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('$e')));
      }
    }
  }

  Future<void> _delete(int id) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Hapus reminder?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Batal')),
          FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Hapus')),
        ],
      ),
    );
    if (ok != true || !mounted) return;
    await context.read<ReminderProvider>().delete(id);
    if (mounted) context.read<DashboardProvider>().load(showSpinner: false);
  }

  Future<void> _add() async {
    final created = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => const AddReminderScreen()),
    );
    if (created == true && mounted) {
      context.read<ReminderProvider>().load(showSpinner: false);
      context.read<DashboardProvider>().load(showSpinner: false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ReminderProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Reminder'),
        actions: [
          IconButton(
            tooltip: 'Buat ulang dari data penyewa',
            onPressed: _refreshFromTenants,
            icon: const Icon(Icons.sync),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _add,
        icon: const Icon(Icons.add),
        label: const Text('Reminder'),
      ),
      body: Column(
        children: [
          _FilterBar(
            selected: provider.filter,
            onSelect: (t) => context.read<ReminderProvider>().setFilter(t),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () =>
                  context.read<ReminderProvider>().load(showSpinner: false),
              child: AsyncView(
                loading: provider.loading && provider.items.isEmpty,
                error: provider.items.isEmpty ? provider.error : null,
                onRetry: () => context.read<ReminderProvider>().load(),
                child: provider.items.isEmpty
                    ? ListView(
                        children: const [
                          SizedBox(height: 80),
                          EmptyState(
                            icon: Icons.notifications_none,
                            title: 'Tidak ada reminder',
                            subtitle:
                                'Tekan ikon sync untuk membuat dari data penyewa, '
                                'atau tombol + untuk reminder manual.',
                          ),
                        ],
                      )
                    : ListView(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
                        children: [
                          _group('Hari ini', provider.today),
                          _group('Minggu ini', provider.thisWeek),
                          _group('Nanti', provider.later),
                        ],
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _group(String label, List<Reminder> items) {
    if (items.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        GroupLabel(label),
        const SizedBox(height: 10),
        ...items.map(
          (r) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: ReminderTile(
              reminder: r,
              onComplete: () => _complete(r.id),
              onLongPress: () => _delete(r.id),
            ),
          ),
        ),
      ],
    );
  }
}

class _FilterBar extends StatelessWidget {
  const _FilterBar({required this.selected, required this.onSelect});

  final ReminderType? selected;
  final ValueChanged<ReminderType?> onSelect;

  @override
  Widget build(BuildContext context) {
    final chips = <(String, ReminderType?)>[
      ('Semua', null),
      ('Sewa', ReminderType.sewaJatuhTempo),
      ('Kontrak', ReminderType.kontrakHabis),
      ('Maintenance', ReminderType.maintenance),
      ('Utilitas', ReminderType.utilitas),
    ];
    return SizedBox(
      height: 52,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        itemCount: chips.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (_, i) {
          final (label, type) = chips[i];
          return ChoiceChip(
            label: Text(label),
            selected: selected == type,
            onSelected: (_) => onSelect(type),
          );
        },
      ),
    );
  }
}
