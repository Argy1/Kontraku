import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/models.dart';
import '../../services/api_client.dart';
import '../../services/kontrakan_service.dart';
import '../../services/reminder_service.dart';
import '../../utils/formatters.dart';

/// Reminder manual: hanya tipe maintenance & utilitas
/// (sewa & kontrak dibuat otomatis oleh sistem).
class AddReminderScreen extends StatefulWidget {
  const AddReminderScreen({super.key});

  @override
  State<AddReminderScreen> createState() => _AddReminderScreenState();
}

class _AddReminderScreenState extends State<AddReminderScreen> {
  final _formKey = GlobalKey<FormState>();
  final _title = TextEditingController();

  List<Kontrakan> _kontrakan = [];
  List<Unit> _units = [];
  Kontrakan? _selectedKontrakan;
  Unit? _selectedUnit;
  ReminderType _type = ReminderType.maintenance;
  DateTime _dueDate = DateTime.now().add(const Duration(days: 7));

  bool _loadingKontrakan = true;
  bool _loadingUnits = false;
  bool _busy = false;
  String? _error;

  KontrakanService get _kService => context.read<KontrakanService>();

  @override
  void initState() {
    super.initState();
    _loadKontrakan();
  }

  @override
  void dispose() {
    _title.dispose();
    super.dispose();
  }

  Future<void> _loadKontrakan() async {
    try {
      final list = await _kService.list();
      setState(() {
        _kontrakan = list;
        _loadingKontrakan = false;
      });
    } on ApiException catch (e) {
      setState(() {
        _error = e.message;
        _loadingKontrakan = false;
      });
    }
  }

  Future<void> _selectKontrakan(Kontrakan? k) async {
    setState(() {
      _selectedKontrakan = k;
      _selectedUnit = null;
      _units = [];
      _loadingUnits = k != null;
    });
    if (k == null) return;
    try {
      final detail = await _kService.detail(k.id);
      setState(() {
        _units = detail.units;
        _loadingUnits = false;
      });
    } on ApiException catch (e) {
      setState(() {
        _loadingUnits = false;
        _error = e.message;
      });
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedUnit == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pilih unit dulu')),
      );
      return;
    }
    setState(() => _busy = true);
    try {
      await context.read<ReminderService>().create(
            unitId: _selectedUnit!.id,
            type: _type,
            dueDate: _dueDate,
            title: _title.text.trim().isEmpty ? null : _title.text.trim(),
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
    return Scaffold(
      appBar: AppBar(title: const Text('Reminder baru')),
      body: _loadingKontrakan
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text(_error!))
              : Form(
                  key: _formKey,
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      SegmentedButton<ReminderType>(
                        segments: const [
                          ButtonSegment(
                            value: ReminderType.maintenance,
                            label: Text('Maintenance'),
                            icon: Icon(Icons.build_outlined),
                          ),
                          ButtonSegment(
                            value: ReminderType.utilitas,
                            label: Text('Utilitas'),
                            icon: Icon(Icons.bolt_outlined),
                          ),
                        ],
                        selected: {_type},
                        onSelectionChanged: (s) =>
                            setState(() => _type = s.first),
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<Kontrakan>(
                        initialValue: _selectedKontrakan,
                        decoration:
                            const InputDecoration(labelText: 'Kontrakan'),
                        items: _kontrakan
                            .map((k) => DropdownMenuItem(
                                value: k, child: Text(k.name)))
                            .toList(),
                        onChanged: _selectKontrakan,
                        validator: (v) => v == null ? 'Pilih kontrakan' : null,
                      ),
                      const SizedBox(height: 14),
                      DropdownButtonFormField<Unit>(
                        initialValue: _selectedUnit,
                        decoration: InputDecoration(
                          labelText: 'Unit',
                          suffixIcon: _loadingUnits
                              ? const Padding(
                                  padding: EdgeInsets.all(12),
                                  child: SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                        strokeWidth: 2),
                                  ),
                                )
                              : null,
                        ),
                        items: _units
                            .map((u) => DropdownMenuItem(
                                value: u, child: Text(u.name)))
                            .toList(),
                        onChanged: (u) => setState(() => _selectedUnit = u),
                        validator: (v) => v == null ? 'Pilih unit' : null,
                      ),
                      const SizedBox(height: 14),
                      TextFormField(
                        controller: _title,
                        decoration: const InputDecoration(
                          labelText: 'Judul',
                          hintText: 'mis. Servis AC, bayar token listrik',
                        ),
                        validator: (v) => (v == null || v.trim().isEmpty)
                            ? 'Judul wajib diisi'
                            : null,
                      ),
                      const SizedBox(height: 14),
                      InkWell(
                        onTap: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: _dueDate,
                            firstDate: DateTime.now(),
                            lastDate: DateTime.now()
                                .add(const Duration(days: 365 * 2)),
                          );
                          if (picked != null) {
                            setState(() => _dueDate = picked);
                          }
                        },
                        child: InputDecorator(
                          decoration: const InputDecoration(
                              labelText: 'Tanggal jatuh tempo'),
                          child: Text(formatDate(_dueDate)),
                        ),
                      ),
                      const SizedBox(height: 28),
                      FilledButton(
                        onPressed: _busy ? null : _save,
                        child: _busy
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2, color: Colors.white))
                            : const Text('Simpan reminder'),
                      ),
                    ],
                  ),
                ),
    );
  }
}
