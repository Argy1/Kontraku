import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../services/api_client.dart';
import '../../services/storage_service.dart';
import '../../theme/app_colors.dart';

/// Dialog untuk mengatur alamat backend. Berguna saat IP LAN PC berubah
/// (tidak perlu build ulang APK).
class ServerSettingsSheet extends StatefulWidget {
  const ServerSettingsSheet({super.key});

  static Future<void> show(BuildContext context) => showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        builder: (_) => const ServerSettingsSheet(),
      );

  @override
  State<ServerSettingsSheet> createState() => _ServerSettingsSheetState();
}

class _ServerSettingsSheetState extends State<ServerSettingsSheet> {
  late final _url = TextEditingController(
    text: context.read<ApiClient>().baseUrl,
  );
  bool _testing = false;
  bool? _ok; // null = belum dites

  @override
  void dispose() {
    _url.dispose();
    super.dispose();
  }

  Future<void> _test() async {
    setState(() {
      _testing = true;
      _ok = null;
    });
    final ok = await context.read<ApiClient>().checkHealth(
          testUrl: _url.text.trim(),
        );
    if (mounted) {
      setState(() {
        _testing = false;
        _ok = ok;
      });
    }
  }

  Future<void> _save() async {
    final url = _url.text.trim();
    final storage = context.read<StorageService>();
    context.read<ApiClient>().setBaseUrl(url);
    await storage.saveApiBaseUrl(url);
    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Alamat server disimpan: $url')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Pengaturan server',
              style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 6),
          Text(
            'Isi alamat backend. Untuk HP di Wi-Fi yang sama, pakai IP komputer '
            '(cek dengan "ipconfig"), mis. http://192.168.1.10:8000',
            style: TextStyle(fontSize: 13, color: c.textSecondary),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: _url,
            keyboardType: TextInputType.url,
            autocorrect: false,
            decoration: const InputDecoration(
              labelText: 'Alamat backend',
              hintText: 'http://192.168.x.x:8000',
              prefixIcon: Icon(Icons.dns_outlined),
            ),
          ),
          const SizedBox(height: 10),
          if (_ok != null)
            Row(
              children: [
                Icon(
                  _ok! ? Icons.check_circle : Icons.error_outline,
                  size: 18,
                  color: _ok! ? c.statusFilledText : c.contractText,
                ),
                const SizedBox(width: 8),
                Text(
                  _ok! ? 'Backend terhubung ✓' : 'Tidak bisa menghubungi backend',
                  style: TextStyle(
                    color: _ok! ? c.statusFilledText : c.contractText,
                  ),
                ),
              ],
            ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _testing ? null : _test,
                  icon: _testing
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.wifi_tethering),
                  label: const Text('Tes koneksi'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton(
                  onPressed: _save,
                  child: const Text('Simpan'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
