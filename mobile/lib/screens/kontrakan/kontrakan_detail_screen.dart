import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/models.dart';
import '../../services/api_client.dart';
import '../../services/kontrakan_service.dart';
import '../../theme/app_colors.dart';
import '../../utils/formatters.dart';
import '../../widgets/widgets.dart';
import 'kontrakan_form_screen.dart';
import 'unit_detail_screen.dart';
import 'unit_form_sheet.dart';

class KontrakanDetailScreen extends StatefulWidget {
  const KontrakanDetailScreen({super.key, required this.kontrakanId});

  final int kontrakanId;

  @override
  State<KontrakanDetailScreen> createState() => _KontrakanDetailScreenState();
}

class _KontrakanDetailScreenState extends State<KontrakanDetailScreen> {
  late final KontrakanService _service = context.read<KontrakanService>();

  KontrakanDetail? _detail;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = _detail == null;
      _error = null;
    });
    try {
      final detail = await _service.detail(widget.kontrakanId);
      setState(() {
        _detail = detail;
        _loading = false;
      });
    } on ApiException catch (e) {
      setState(() {
        _error = e.message;
        _loading = false;
      });
    }
  }

  String? get _photoUrl {
    final photos = _detail?.documents
        .where((d) => d.type == DocumentType.foto)
        .toList();
    return (photos == null || photos.isEmpty) ? null : photos.first.fileUrl;
  }

  Future<void> _edit() async {
    final changed = await Navigator.of(context).push<KontrakanFormResult>(
      MaterialPageRoute(
        builder: (_) => KontrakanFormScreen(existing: _detail),
      ),
    );
    if (changed == null) return;
    if (changed.deleted) {
      if (mounted) Navigator.of(context).pop();
      return;
    }
    _load();
  }

  Future<void> _addUnit() async {
    final created = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      builder: (_) => UnitFormSheet(kontrakanId: widget.kontrakanId),
    );
    if (created == true) _load();
  }

  Future<void> _openUnit(Unit unit) async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => UnitDetailScreen(unit: unit)),
    );
    _load();
  }

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final detail = _detail;

    return Scaffold(
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null && detail == null
              ? Padding(
                  padding: const EdgeInsets.only(top: 80),
                  child: ErrorRetry(message: _error!, onRetry: _load),
                )
              : RefreshIndicator(
                  onRefresh: _load,
                  child: ListView(
                    padding: EdgeInsets.zero,
                    children: [
                      _PhotoHeader(url: _photoUrl, onBack: () => Navigator.pop(context), onEdit: _edit),
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              detail!.name,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                Icon(Icons.location_on_outlined,
                                    size: 16, color: c.textSecondary),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    detail.address ?? 'Alamat belum diisi',
                                    style: TextStyle(
                                        fontSize: 13, color: c.textSecondary),
                                  ),
                                ),
                              ],
                            ),
                            if (detail.hasLocation) ...[
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Icon(Icons.my_location,
                                      size: 14, color: c.textMuted),
                                  const SizedBox(width: 6),
                                  Text(
                                    '${detail.latitude!.toStringAsFixed(5)}, ${detail.longitude!.toStringAsFixed(5)}',
                                    style: TextStyle(
                                        fontSize: 12, color: c.textMuted),
                                  ),
                                ],
                              ),
                            ],
                            const SizedBox(height: 20),
                            SectionHeader(
                              'Unit (${detail.units.length})',
                              actionLabel: 'Tambah unit',
                              onAction: _addUnit,
                            ),
                            const SizedBox(height: 12),
                            if (detail.units.isEmpty)
                              const EmptyState(
                                icon: Icons.meeting_room_outlined,
                                title: 'Belum ada unit',
                                subtitle: 'Tambah kamar/petak lewat tombol di atas.',
                              )
                            else
                              ...detail.units.map(
                                (u) => Padding(
                                  padding: const EdgeInsets.only(bottom: 10),
                                  child: _UnitCard(
                                      unit: u, onTap: () => _openUnit(u)),
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
}

class _PhotoHeader extends StatelessWidget {
  const _PhotoHeader({
    required this.url,
    required this.onBack,
    required this.onEdit,
  });

  final String? url;
  final VoidCallback onBack;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final placeholder = dark ? const Color(0xFF0F3D33) : const Color(0xFF9FE1CB);
    final topPad = MediaQuery.of(context).padding.top;

    return SizedBox(
      height: 150 + topPad,
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (url != null)
            CachedNetworkImage(
              imageUrl: url!,
              fit: BoxFit.cover,
              errorWidget: (_, _, _) => Container(color: placeholder),
              placeholder: (_, _) => Container(color: placeholder),
            )
          else
            Container(
              color: placeholder,
              child: const Center(
                child: Icon(Icons.home_rounded, size: 48, color: Colors.white70),
              ),
            ),
          Positioned(
            top: topPad + 10,
            left: 12,
            child: _RoundButton(icon: Icons.arrow_back, onTap: onBack),
          ),
          Positioned(
            top: topPad + 10,
            right: 12,
            child: _RoundButton(icon: Icons.edit_outlined, onTap: onEdit),
          ),
        ],
      ),
    );
  }
}

class _RoundButton extends StatelessWidget {
  const _RoundButton({required this.icon, required this.onTap});
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withValues(alpha: 0.9),
      shape: const CircleBorder(),
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Icon(icon, size: 20, color: const Color(0xFF04342C)),
        ),
      ),
    );
  }
}

class _UnitCard extends StatelessWidget {
  const _UnitCard({required this.unit, required this.onTap});

  final Unit unit;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(unit.name,
                        style: const TextStyle(
                            fontSize: 15, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 3),
                    Text(
                      unit.price != null
                          ? '${rupiahShort(unit.price)}/bln'
                          : 'Harga belum diatur',
                      style: TextStyle(fontSize: 13, color: c.textSecondary),
                    ),
                  ],
                ),
              ),
              StatusBadge.fromUnitStatus(context, unit.status),
            ],
          ),
        ),
      ),
    );
  }
}
