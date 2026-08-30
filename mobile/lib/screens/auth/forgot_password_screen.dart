import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../services/api_client.dart';
import '../../theme/app_colors.dart';

/// Alur reset password.
///
/// Backend mode development mengembalikan `reset_token` langsung di response
/// (tidak kirim email), jadi di sini token otomatis terisi supaya bisa dites.
class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _email = TextEditingController();
  final _token = TextEditingController();
  final _newPassword = TextEditingController();

  bool _busy = false;
  bool _tokenRequested = false;

  @override
  void dispose() {
    _email.dispose();
    _token.dispose();
    _newPassword.dispose();
    super.dispose();
  }

  Future<void> _requestToken() async {
    if (!_email.text.contains('@')) {
      _snack('Masukkan email yang valid');
      return;
    }
    setState(() => _busy = true);
    try {
      final token =
          await context.read<AuthProvider>().forgotPassword(_email.text.trim());
      setState(() {
        _tokenRequested = true;
        if (token != null) _token.text = token;
      });
      _snack(token != null
          ? 'Token dev otomatis diisi. Lanjut buat password baru.'
          : 'Kalau email terdaftar, instruksi reset sudah dikirim.');
    } on ApiException catch (e) {
      _snack(e.message);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _reset() async {
    if (_token.text.isEmpty || _newPassword.text.length < 6) {
      _snack('Isi token dan password baru (min 6 karakter)');
      return;
    }
    setState(() => _busy = true);
    try {
      await context.read<AuthProvider>().resetPassword(
            token: _token.text.trim(),
            newPassword: _newPassword.text,
          );
      if (!mounted) return;
      _snack('Password berhasil diubah. Silakan masuk.');
      Navigator.of(context).pop();
    } on ApiException catch (e) {
      _snack(e.message);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _snack(String m) => ScaffoldMessenger.of(context)
      .showSnackBar(SnackBar(content: Text(m)));

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Lupa password')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextField(
                    controller: _email,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      labelText: 'Email akun',
                      prefixIcon: Icon(Icons.mail_outline),
                    ),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton(
                    onPressed: _busy ? null : _requestToken,
                    child: const Text('Kirim token reset'),
                  ),
                  if (_tokenRequested) ...[
                    const Divider(height: 40),
                    Text('Buat password baru',
                        style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _token,
                      decoration: const InputDecoration(
                        labelText: 'Token reset',
                        prefixIcon: Icon(Icons.vpn_key_outlined),
                      ),
                      style: TextStyle(fontSize: 12, color: c.textSecondary),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _newPassword,
                      obscureText: true,
                      decoration: const InputDecoration(
                        labelText: 'Password baru',
                        prefixIcon: Icon(Icons.lock_outline),
                      ),
                    ),
                    const SizedBox(height: 20),
                    FilledButton(
                      onPressed: _busy ? null : _reset,
                      child: const Text('Ubah password'),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
