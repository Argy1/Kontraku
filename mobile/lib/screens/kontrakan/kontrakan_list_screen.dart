import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/dashboard_provider.dart';
import '../../providers/kontrakan_provider.dart';
import '../../widgets/widgets.dart';
import 'kontrakan_detail_screen.dart';
import 'kontrakan_form_screen.dart';

class KontrakanListScreen extends StatefulWidget {
  const KontrakanListScreen({super.key});

  @override
  State<KontrakanListScreen> createState() => _KontrakanListScreenState();
}

class _KontrakanListScreenState extends State<KontrakanListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => context.read<KontrakanListProvider>().load(),
    );
  }

  Future<void> _refreshAll() async {
    await context.read<KontrakanListProvider>().reload();
    if (mounted) {
      context.read<DashboardProvider>().load(showSpinner: false);
    }
  }

  Future<void> _add() async {
    final result = await Navigator.of(context).push<KontrakanFormResult>(
      MaterialPageRoute(builder: (_) => const KontrakanFormScreen()),
    );
    if (result != null) _refreshAll(); // ada kontrakan baru tersimpan
  }

  Future<void> _open(int id) async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => KontrakanDetailScreen(kontrakanId: id)),
    );
    _refreshAll();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<KontrakanListProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Kontrakan'),
        actions: [
          TextButton.icon(
            onPressed: _add,
            icon: const Icon(Icons.add),
            label: const Text('Tambah'),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refreshAll,
        child: AsyncView(
          loading: provider.loading && provider.items.isEmpty,
          error: provider.items.isEmpty ? provider.error : null,
          onRetry: () => context.read<KontrakanListProvider>().load(),
          child: provider.items.isEmpty
              ? ListView(
                  children: const [
                    SizedBox(height: 80),
                    EmptyState(
                      icon: Icons.home_outlined,
                      title: 'Belum ada kontrakan',
                      subtitle: 'Tekan "Tambah" untuk mendaftarkan yang pertama.',
                    ),
                  ],
                )
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: provider.items.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 10),
                  itemBuilder: (context, i) {
                    final k = provider.items[i];
                    return KontrakanCard(
                      kontrakan: k,
                      index: i,
                      onTap: () => _open(k.id),
                    );
                  },
                ),
        ),
      ),
    );
  }
}
