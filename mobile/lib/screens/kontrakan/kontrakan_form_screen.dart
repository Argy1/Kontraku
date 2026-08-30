import 'dart:typed_data';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../models/models.dart';
import '../../services/api_client.dart';
import '../../services/kontrakan_service.dart';
import '../../theme/app_colors.dart';

/// Hasil yang dikembalikan layar form ke pemanggil.
class KontrakanFormResult {
  const KontrakanFormResult({this.deleted = false});
  final bool deleted;
}

class _PickedPhoto {
  _PickedPhoto(this.bytes, this.name);
  final Uint8List bytes;
  final String name;
}

class KontrakanFormScreen extends StatefulWidget {
  const KontrakanFormScreen({super.key, this.existing});

  /// null = tambah baru, tidak null = edit.
  final KontrakanDetail? existing;

  bool get isEdit => existing != null;

  @override
  State<KontrakanFormScreen> createState() => _KontrakanFormScreenState();
}

class _KontrakanFormScreenState extends State<KontrakanFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final _name = TextEditingController(text: widget.existing?.name ?? '');
  late final _address =
      TextEditingController(text: widget.existing?.address ?? '');
  late final _lat = TextEditingController(
      text: widget.existing?.latitude?.toString() ?? '');
  late final _lng = TextEditingController(
      text: widget.existing?.longitude?.toString() ?? '');

  final _picker = ImagePicker();
  final List<_PickedPhoto> _newPhotos = [];
  late List<DocumentItem> _existingPhotos = widget.existing?.documents
          .where((d) => d.type == DocumentType.foto)
          .toList() ??
      [];

  bool _busy = false;

  KontrakanService get _service => context.read<KontrakanService>();

  @override
  void dispose() {
    _name.dispose();
    _address.dispose();
    _lat.dispose();
    _lng.dispose();
    super.dispose();
  }

  Future<void> _pickPhotos() async {
    final files = await _picker.pickMultiImage(imageQuality: 80);
    for (final f in files) {
      _newPhotos.add(_PickedPhoto(await f.readAsBytes(), f.name));
    }
    if (mounted) setState(() {});
  }

  Future<void> _deleteExistingPhoto(DocumentItem doc) async {
    try {
      await _service.deleteDocument(widget.existing!.id, doc.id);
      setState(() => _existingPhotos =
          _existingPhotos.where((d) => d.id != doc.id).toList());
    } on ApiException catch (e) {
      _snack(e.message);
    }
  }

  double? _parseCoord(TextEditingController ctrl) =>
      ctrl.text.trim().isEmpty ? null : double.tryParse(ctrl.text.trim());

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    setState(() => _busy = true);

    try {
      final lat = _parseCoord(_lat);
      final lng = _parseCoord(_lng);
      final int kontrakanId;

      if (widget.isEdit) {
        await _service.update(
          widget.existing!.id,
          name: _name.text.trim(),
          address: _address.text.trim(),
          latitude: lat,
          longitude: lng,
        );
        kontrakanId = widget.existing!.id;
      } else {
        final created = await _service.create(
          name: _name.text.trim(),
          address: _address.text.trim(),
          latitude: lat,
          longitude: lng,
        );
        kontrakanId = created.id;
      }

      for (final photo in _newPhotos) {
        await _service.uploadDocument(
          kontrakanId,
          bytes: photo.bytes,
          filename: photo.name,
          type: DocumentType.foto,
        );
      }

      if (mounted) Navigator.of(context).pop(const KontrakanFormResult());
    } on ApiException catch (e) {
      _snack(e.message);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _delete() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Hapus kontrakan?'),
        content: const Text(
          'Semua unit, penyewa, pembayaran, dan reminder di dalamnya '
          'ikut terhapus. Tindakan ini tidak bisa dibatalkan.',
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Batal')),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(
                backgroundColor: AppColors.of(context).contractBar),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
    if (ok != true) return;

    setState(() => _busy = true);
    try {
      await _service.delete(widget.existing!.id);
      if (mounted) {
        Navigator.of(context).pop(const KontrakanFormResult(deleted: true));
      }
    } on ApiException catch (e) {
      _snack(e.message);
      setState(() => _busy = false);
    }
  }

  void _snack(String m) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(m)));

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isEdit ? 'Ubah kontrakan' : 'Tambah kontrakan'),
      ),
      body: AbsorbPointer(
        absorbing: _busy,
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text('Foto kontrakan',
                  style: Theme.of(context).textTheme.labelLarge),
              const SizedBox(height: 8),
              _PhotoStrip(
                existing: _existingPhotos,
                picked: _newPhotos,
                onAdd: _pickPhotos,
                onRemoveExisting: _deleteExistingPhoto,
                onRemovePicked: (i) => setState(() => _newPhotos.removeAt(i)),
              ),
              const SizedBox(height: 18),
              Text('Nama kontrakan',
                  style: Theme.of(context).textTheme.labelLarge),
              const SizedBox(height: 8),
              TextFormField(
                controller: _name,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(hintText: 'mis. Kontrakan melati'),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Wajib diisi' : null,
              ),
              const SizedBox(height: 18),
              Text('Alamat', style: Theme.of(context).textTheme.labelLarge),
              const SizedBox(height: 8),
              TextFormField(
                controller: _address,
                maxLines: 2,
                decoration:
                    const InputDecoration(hintText: 'Jl. ... no. ..., kota'),
              ),
              const SizedBox(height: 18),
              Text('Lokasi (opsional)',
                  style: Theme.of(context).textTheme.labelLarge),
              const SizedBox(height: 4),
              Text(
                'Sementara isi manual. Pilih-di-peta menyusul setelah '
                'Google Maps API key disiapkan.',
                style: TextStyle(fontSize: 12, color: c.textMuted),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _lat,
                      keyboardType: const TextInputType.numberWithOptions(
                          decimal: true, signed: true),
                      decoration: const InputDecoration(labelText: 'Latitude'),
                      validator: _coordValidator(-90, 90),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _lng,
                      keyboardType: const TextInputType.numberWithOptions(
                          decimal: true, signed: true),
                      decoration: const InputDecoration(labelText: 'Longitude'),
                      validator: _coordValidator(-180, 180),
                    ),
                  ),
                ],
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
                    : Text(widget.isEdit ? 'Simpan perubahan' : 'Simpan kontrakan'),
              ),
              if (widget.isEdit) ...[
                const SizedBox(height: 12),
                TextButton.icon(
                  onPressed: _busy ? null : _delete,
                  icon: Icon(Icons.delete_outline, color: c.contractText),
                  label: Text('Hapus kontrakan',
                      style: TextStyle(color: c.contractText)),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  String? Function(String?) _coordValidator(double min, double max) {
    return (v) {
      if (v == null || v.trim().isEmpty) return null;
      final n = double.tryParse(v.trim());
      if (n == null) return 'Angka tidak valid';
      if (n < min || n > max) return 'Di luar rentang $min..$max';
      return null;
    };
  }
}

class _PhotoStrip extends StatelessWidget {
  const _PhotoStrip({
    required this.existing,
    required this.picked,
    required this.onAdd,
    required this.onRemoveExisting,
    required this.onRemovePicked,
  });

  final List<DocumentItem> existing;
  final List<_PickedPhoto> picked;
  final VoidCallback onAdd;
  final ValueChanged<DocumentItem> onRemoveExisting;
  final ValueChanged<int> onRemovePicked;

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    return SizedBox(
      height: 72,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          for (final doc in existing)
            _thumb(
              child: CachedNetworkImage(
                  imageUrl: doc.fileUrl, fit: BoxFit.cover, width: 64, height: 64),
              onRemove: () => onRemoveExisting(doc),
            ),
          for (var i = 0; i < picked.length; i++)
            _thumb(
              child: Image.memory(picked[i].bytes,
                  fit: BoxFit.cover, width: 64, height: 64),
              onRemove: () => onRemovePicked(i),
            ),
          InkWell(
            onTap: onAdd,
            child: Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: c.inputBorder, width: 1.5),
              ),
              child: Icon(Icons.add, color: c.textMuted),
            ),
          ),
        ],
      ),
    );
  }

  Widget _thumb({required Widget child, required VoidCallback onRemove}) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: Stack(
        children: [
          ClipRRect(borderRadius: BorderRadius.circular(12), child: child),
          Positioned(
            top: -6,
            right: -6,
            child: IconButton(
              onPressed: onRemove,
              iconSize: 16,
              icon: const CircleAvatar(
                radius: 10,
                backgroundColor: Colors.black54,
                child: Icon(Icons.close, size: 12, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
