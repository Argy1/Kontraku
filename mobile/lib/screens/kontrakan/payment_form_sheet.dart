import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../services/api_client.dart';
import '../../services/kontrakan_service.dart';
import '../../utils/formatters.dart';

class PaymentFormSheet extends StatefulWidget {
  const PaymentFormSheet({super.key, required this.tenantId, this.suggestedAmount});

  final int tenantId;
  final double? suggestedAmount;

  @override
  State<PaymentFormSheet> createState() => _PaymentFormSheetState();
}

class _PaymentFormSheetState extends State<PaymentFormSheet> {
  final _formKey = GlobalKey<FormState>();
  late final _amount = TextEditingController(
      text: widget.suggestedAmount?.toStringAsFixed(0) ?? '');
  final _note = TextEditingController();
  DateTime _paidDate = DateTime.now();
  bool _busy = false;

  @override
  void dispose() {
    _amount.dispose();
    _note.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _busy = true);
    try {
      await context.read<KontrakanService>().createPayment(
            widget.tenantId,
            amount: double.parse(_amount.text.trim()),
            paidDate: _paidDate,
            periodStart: DateTime(_paidDate.year, _paidDate.month, 1),
            note: _note.text.trim(),
          );
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
            Text('Catat pembayaran',
                style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            TextFormField(
              controller: _amount,
              keyboardType: TextInputType.number,
              decoration:
                  const InputDecoration(labelText: 'Jumlah', prefixText: 'Rp '),
              validator: (v) {
                final n = double.tryParse((v ?? '').trim());
                return (n == null || n <= 0) ? 'Jumlah tidak valid' : null;
              },
            ),
            const SizedBox(height: 14),
            InkWell(
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: _paidDate,
                  firstDate: DateTime(_paidDate.year - 3),
                  lastDate: DateTime.now().add(const Duration(days: 1)),
                );
                if (picked != null) setState(() => _paidDate = picked);
              },
              child: InputDecorator(
                decoration: const InputDecoration(labelText: 'Tanggal bayar'),
                child: Text(formatDate(_paidDate)),
              ),
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _note,
              decoration: const InputDecoration(labelText: 'Catatan (opsional)'),
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
