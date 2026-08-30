import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/models.dart';
import '../../services/api_client.dart';
import '../../services/kontrakan_service.dart';
import '../../theme/app_colors.dart';
import '../../utils/formatters.dart';
import '../../widgets/widgets.dart';
import 'payment_form_sheet.dart';
import 'tenant_form_sheet.dart';
import 'unit_form_sheet.dart';

class UnitDetailScreen extends StatefulWidget {
  const UnitDetailScreen({super.key, required this.unit});

  final Unit unit;

  @override
  State<UnitDetailScreen> createState() => _UnitDetailScreenState();
}

class _UnitDetailScreenState extends State<UnitDetailScreen> {
  KontrakanService get _service => context.read<KontrakanService>();

  late Unit _unit = widget.unit;
  List<Tenant> _tenants = [];
  bool _loading = true;
  String? _error;
  bool _showArchived = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = _tenants.isEmpty;
      _error = null;
    });
    try {
      final tenants =
          await _service.tenants(_unit.id, includeInactive: _showArchived);
      setState(() {
        _tenants = tenants;
        _loading = false;
      });
    } on ApiException catch (e) {
      setState(() {
        _error = e.message;
        _loading = false;
      });
    }
  }

  Tenant? get _activeTenant {
    for (final t in _tenants) {
      if (t.isActive) return t;
    }
    return null;
  }

  Future<void> _editUnit() async {
    final changed = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      builder: (_) =>
          UnitFormSheet(kontrakanId: _unit.kontrakanId, existing: _unit),
    );
    if (changed != true) return;
    final fresh = await _service.detail(_unit.kontrakanId);
    for (final u in fresh.units) {
      if (u.id == _unit.id && mounted) {
        setState(() => _unit = u);
        break;
      }
    }
  }

  Future<void> _changeStatus(UnitStatus status) async {
    try {
      final updated = await _service.updateUnit(_unit.id, status: status);
      setState(() => _unit = updated);
    } on ApiException catch (e) {
      _snack(e.message);
    }
  }

  Future<void> _addTenant() async {
    final created = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      builder: (_) => TenantFormSheet(unitId: _unit.id),
    );
    if (created == true) {
      await _changeStatus(UnitStatus.terisi);
      _load();
    }
  }

  Future<void> _editTenant(Tenant tenant) async {
    final saved = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      builder: (_) => TenantFormSheet(unitId: _unit.id, existing: tenant),
    );
    if (saved == true) {
      _snack('Data penyewa diperbarui. Reminder ikut disesuaikan.');
      _load();
    }
  }

  Future<void> _archive(Tenant tenant) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Arsipkan penyewa?'),
        content: Text(
            '${tenant.name} akan dipindah ke riwayat. Data pembayaran tetap tersimpan.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Batal')),
          FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Arsipkan')),
        ],
      ),
    );
    if (ok != true) return;
    try {
      await _service.archiveTenant(tenant.id);
      await _changeStatus(UnitStatus.kosong);
      _load();
    } on ApiException catch (e) {
      _snack(e.message);
    }
  }

  Future<void> _addPayment(Tenant tenant) async {
    final saved = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      builder: (_) => PaymentFormSheet(
        tenantId: tenant.id,
        suggestedAmount: tenant.rentAmount,
      ),
    );
    if (saved == true) _snack('Pembayaran dicatat.');
  }

  Future<void> _openPayments(Tenant tenant) async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => _PaymentHistoryScreen(tenant: tenant)),
    );
  }

  void _snack(String m) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(m)));

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(_unit.name),
        actions: [
          IconButton(
            onPressed: _editUnit,
            icon: const Icon(Icons.edit_outlined),
            tooltip: 'Ubah unit',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _load,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Harga sewa',
                              style: TextStyle(
                                  fontSize: 13, color: c.textSecondary)),
                          const SizedBox(height: 2),
                          Text(
                            _unit.price != null
                                ? '${rupiah(_unit.price)} / bln'
                                : 'Belum diatur',
                            style: const TextStyle(
                                fontSize: 17, fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ),
                    StatusBadge.fromUnitStatus(context, _unit.status),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text('Ubah status', style: Theme.of(context).textTheme.labelSmall),
            const SizedBox(height: 6),
            Wrap(
              spacing: 8,
              children: UnitStatus.values.map((s) {
                final selected = s == _unit.status;
                return ChoiceChip(
                  label: Text(s.label),
                  selected: selected,
                  onSelected: (_) => _changeStatus(s),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
            SectionHeader(
              _showArchived ? 'Penyewa & riwayat' : 'Penyewa',
              actionLabel: _activeTenant == null ? 'Tambah' : null,
              onAction: _addTenant,
            ),
            const SizedBox(height: 8),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Tampilkan penyewa lama'),
              value: _showArchived,
              onChanged: (v) {
                setState(() => _showArchived = v);
                _load();
              },
            ),
            if (_loading)
              const Padding(
                padding: EdgeInsets.all(24),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (_error != null)
              ErrorRetry(message: _error!, onRetry: _load)
            else if (_tenants.isEmpty)
              const EmptyState(
                icon: Icons.people_outline,
                title: 'Belum ada penyewa',
                subtitle: 'Tekan "Tambah" untuk mencatat penyewa unit ini.',
              )
            else
              ..._tenants.map(
                (t) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _TenantCard(
                    tenant: t,
                    onEdit: t.isActive ? () => _editTenant(t) : null,
                    onArchive: t.isActive ? () => _archive(t) : null,
                    onAddPayment: () => _addPayment(t),
                    onOpenPayments: () => _openPayments(t),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _TenantCard extends StatelessWidget {
  const _TenantCard({
    required this.tenant,
    required this.onEdit,
    required this.onArchive,
    required this.onAddPayment,
    required this.onOpenPayments,
  });

  final Tenant tenant;
  final VoidCallback? onEdit;
  final VoidCallback? onArchive;
  final VoidCallback onAddPayment;
  final VoidCallback onOpenPayments;

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(tenant.name,
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w600)),
                ),
                if (!tenant.isActive)
                  StatusBadge.due(context, 'Arsip')
                else if (tenant.dueDay != null)
                  Text('Jatuh tempo tgl ${tenant.dueDay}',
                      style: TextStyle(fontSize: 12, color: c.textSecondary)),
              ],
            ),
            const SizedBox(height: 6),
            _row(c, Icons.phone_outlined, tenant.phone ?? '-'),
            _row(
              c,
              Icons.event_outlined,
              '${formatDate(tenant.contractStart)} — ${formatDate(tenant.contractEnd)}',
            ),
            _row(c, Icons.payments_outlined,
                tenant.rentAmount != null ? rupiah(tenant.rentAmount) : '-'),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                OutlinedButton.icon(
                  onPressed: onAddPayment,
                  icon: const Icon(Icons.add, size: 16),
                  label: const Text('Pembayaran'),
                ),
                TextButton(
                    onPressed: onOpenPayments,
                    child: const Text('Riwayat bayar')),
                if (onEdit != null)
                  TextButton.icon(
                    onPressed: onEdit,
                    icon: const Icon(Icons.edit_outlined, size: 15),
                    label: const Text('Ubah'),
                  ),
                if (onArchive != null)
                  TextButton(
                    onPressed: onArchive,
                    child: Text('Arsipkan',
                        style: TextStyle(color: c.contractText)),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _row(AppColors c, IconData icon, String text) => Padding(
        padding: const EdgeInsets.only(top: 3),
        child: Row(
          children: [
            Icon(icon, size: 15, color: c.textMuted),
            const SizedBox(width: 8),
            Expanded(
                child: Text(text,
                    style: TextStyle(fontSize: 13, color: c.textSecondary))),
          ],
        ),
      );
}

class _PaymentHistoryScreen extends StatefulWidget {
  const _PaymentHistoryScreen({required this.tenant});
  final Tenant tenant;

  @override
  State<_PaymentHistoryScreen> createState() => _PaymentHistoryScreenState();
}

class _PaymentHistoryScreenState extends State<_PaymentHistoryScreen> {
  List<Payment> _items = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final items =
          await context.read<KontrakanService>().payments(widget.tenant.id);
      setState(() {
        _items = items;
        _loading = false;
      });
    } on ApiException catch (e) {
      setState(() {
        _error = e.message;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    return Scaffold(
      appBar: AppBar(title: Text('Pembayaran · ${widget.tenant.name}')),
      body: AsyncView(
        loading: _loading,
        error: _error,
        onRetry: _load,
        child: _items.isEmpty
            ? const EmptyState(
                icon: Icons.receipt_long_outlined,
                title: 'Belum ada pembayaran')
            : ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: _items.length,
                separatorBuilder: (_, _) => const SizedBox(height: 8),
                itemBuilder: (_, i) {
                  final p = _items[i];
                  return Card(
                    child: ListTile(
                      title: Text(rupiah(p.amount),
                          style:
                              const TextStyle(fontWeight: FontWeight.w600)),
                      subtitle: Text(
                        'Dibayar ${formatDate(p.paidDate)}'
                        '${p.note != null && p.note!.isNotEmpty ? ' · ${p.note}' : ''}',
                        style: TextStyle(color: c.textSecondary),
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}
