import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/models.dart';
import '../../services/api_client.dart';
import '../../services/kontrakan_service.dart';
import '../../utils/formatters.dart';

/// Bottom sheet tambah / ubah penyewa sebuah unit.
class TenantFormSheet extends StatefulWidget {
  const TenantFormSheet({super.key, required this.unitId, this.existing});

  final int unitId;

  /// null = tambah baru, tidak null = ubah.
  final Tenant? existing;

  bool get isEdit => existing != null;

  @override
  State<TenantFormSheet> createState() => _TenantFormSheetState();
}

class _TenantFormSheetState extends State<TenantFormSheet> {
  final _formKey = GlobalKey<FormState>();
  late final _name = TextEditingController(text: widget.existing?.name ?? '');
  late final _phone = TextEditingController(text: widget.existing?.phone ?? '');
  late final _rent = TextEditingController(
      text: widget.existing?.rentAmount?.toStringAsFixed(0) ?? '');
  late final _dueDay = TextEditingController(
      text: widget.existing?.dueDay?.toString() ?? '');
  late DateTime? _start = widget.existing?.contractStart;
  late DateTime? _end = widget.existing?.contractEnd;
  bool _busy = false;

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    _rent.dispose();
    _dueDay.dispose();
    super.dispose();
  }

  Future<void> _pickDate({required bool isStart}) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: (isStart ? _start : _end) ?? now,
      firstDate: DateTime(now.year - 5),
      lastDate: DateTime(now.year + 10),
    );
    if (picked != null) {
      setState(() => isStart ? _start = picked : _end = picked);
    }
  }

  int? get _dueDayValue =>
      _dueDay.text.trim().isEmpty ? null : int.tryParse(_dueDay.text.trim());
  double? get _rentValue =>
      _rent.text.trim().isEmpty ? null : double.tryParse(_rent.text.trim());

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _busy = true);
    final service = context.read<KontrakanService>();
    try {
      if (widget.isEdit) {
        await service.updateTenant(
          widget.existing!.id,
          name: _name.text.trim(),
          phone: _phone.text.trim(),
          contractStart: _start,
          contractEnd: _end,
          clearContractEnd: _end == null,
          rentAmount: _rentValue,
          dueDay: _dueDayValue,
          clearDueDay: _dueDayValue == null,
        );
      } else {
        await service.createTenant(
          widget.unitId,
          name: _name.text.trim(),
          phone: _phone.text.trim(),
          contractStart: _start,
          contractEnd: _end,
          rentAmount: _rentValue,
          dueDay: _dueDayValue,
        );
      }
      if (mounted) Navigator.pop(context, true);
    } on ApiException catch (e) {
      setState(() => _busy = false);
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(e.message)));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(widget.isEdit ? 'Ubah penyewa' : 'Tambah penyewa',
                  style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 16),
              TextFormField(
                controller: _name,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(labelText: 'Nama penyewa'),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Wajib diisi' : null,
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _phone,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(labelText: 'No. HP'),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: _DateField(
                      label: 'Mulai kontrak',
                      value: _start,
                      onTap: () => _pickDate(isStart: true),
                      onClear: () => setState(() => _start = null),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _DateField(
                      label: 'Akhir kontrak',
                      value: _end,
                      onTap: () => _pickDate(isStart: false),
                      onClear: () => setState(() => _end = null),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _rent,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                          labelText: 'Sewa / bln', prefixText: 'Rp '),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _dueDay,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Jatuh tempo',
                        hintText: 'tgl 1-31',
                      ),
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) return null;
                        final n = int.tryParse(v.trim());
                        if (n == null || n < 1 || n > 31) return '1-31';
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              FilledButton(
                onPressed: _busy ? null : _save,
                child: _busy
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white))
                    : Text(widget.isEdit
                        ? 'Simpan perubahan'
                        : 'Simpan penyewa'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DateField extends StatelessWidget {
  const _DateField({
    required this.label,
    required this.value,
    required this.onTap,
    required this.onClear,
  });

  final String label;
  final DateTime? value;
  final VoidCallback onTap;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          suffixIcon: value == null
              ? null
              : IconButton(
                  icon: const Icon(Icons.clear, size: 16),
                  onPressed: onClear,
                  visualDensity: VisualDensity.compact,
                ),
        ),
        child: Text(value == null ? 'Pilih' : formatDate(value)),
      ),
    );
  }
}
