import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/models.dart';
import '../../services/api_client.dart';
import '../../services/kontrakan_service.dart';

/// Bottom sheet untuk tambah / ubah unit. Kembalikan `true` kalau ada perubahan.
class UnitFormSheet extends StatefulWidget {
  const UnitFormSheet({super.key, required this.kontrakanId, this.existing});

  final int kontrakanId;
  final Unit? existing;

  @override
  State<UnitFormSheet> createState() => _UnitFormSheetState();
}

class _UnitFormSheetState extends State<UnitFormSheet> {
  final _formKey = GlobalKey<FormState>();
  late final _name = TextEditingController(text: widget.existing?.name ?? '');
  late final _price = TextEditingController(
      text: widget.existing?.price?.toStringAsFixed(0) ?? '');
  late UnitStatus _status = widget.existing?.status ?? UnitStatus.kosong;
  bool _busy = false;

  bool get _isEdit => widget.existing != null;

  @override
  void dispose() {
    _name.dispose();
    _price.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _busy = true);
    final service = context.read<KontrakanService>();
    final price =
        _price.text.trim().isEmpty ? null : double.tryParse(_price.text.trim());
    try {
      if (_isEdit) {
        await service.updateUnit(widget.existing!.id,
            name: _name.text.trim(), status: _status, price: price);
      } else {
        await service.createUnit(widget.kontrakanId,
            name: _name.text.trim(), status: _status, price: price);
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
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(_isEdit ? 'Ubah unit' : 'Tambah unit',
                style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            TextFormField(
              controller: _name,
              decoration: const InputDecoration(
                  labelText: 'Nama unit', hintText: 'mis. Kamar 3'),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Wajib diisi' : null,
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _price,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                  labelText: 'Harga sewa / bulan', prefixText: 'Rp '),
            ),
            const SizedBox(height: 14),
            DropdownButtonFormField<UnitStatus>(
              initialValue: _status,
              decoration: const InputDecoration(labelText: 'Status'),
              items: UnitStatus.values
                  .map((s) =>
                      DropdownMenuItem(value: s, child: Text(s.label)))
                  .toList(),
              onChanged: (v) => setState(() => _status = v ?? _status),
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
                  : const Text('Simpan'),
            ),
          ],
        ),
      ),
    );
  }
}
