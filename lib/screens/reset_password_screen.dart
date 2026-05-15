import 'package:flutter/material.dart';

import '../app/app_session_controller.dart';

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({
    super.key,
    required this.sessionController,
    this.initialEmail,
  });

  final AppSessionController sessionController;
  final String? initialEmail;

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _tokenController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _completed = false;

  @override
  void dispose() {
    _tokenController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    try {
      await widget.sessionController.resetPassword(
        token: _tokenController.text,
        newPassword: _passwordController.text,
      );
      if (!mounted) {
        return;
      }
      setState(() => _completed = true);
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final errorMessage = widget.sessionController.errorMessage;

    return Scaffold(
      appBar: AppBar(title: const Text('Yeni Şifre Belirle')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'E-postadaki sıfırlama kodunu gir ve yeni şifreni belirle.',
                  style: TextStyle(
                    color: Color(0xFF667086),
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 24),
                TextFormField(
                  controller: _tokenController,
                  onChanged: (_) => widget.sessionController.clearErrorMessage(),
                  decoration: const InputDecoration(
                    labelText: 'Sıfırlama Kodu',
                    hintText: 'Kodunu buraya yapıştır',
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Sıfırlama kodu gerekli.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 18),
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  onChanged: (_) => widget.sessionController.clearErrorMessage(),
                  decoration: InputDecoration(
                    labelText: 'Yeni Şifre',
                    hintText: 'En az 8 karakter',
                    suffixIcon: IconButton(
                      onPressed: () {
                        setState(() => _obscurePassword = !_obscurePassword);
                      },
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                      ),
                    ),
                  ),
                  validator: (value) {
                    final text = value ?? '';
                    if (text.isEmpty) {
                      return 'Yeni sifre gerekli.';
                    }
                    if (text.length < 8) {
                      return 'Şifre en az 8 karakter olmalı.';
                    }
                    if (!RegExp(r'[A-Z]').hasMatch(text) ||
                        !RegExp(r'[a-z]').hasMatch(text) ||
                        !RegExp(r'[0-9]').hasMatch(text)) {
                      return 'Şifre büyük harf, küçük harf ve rakam içermeli.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 18),
                TextFormField(
                  controller: _confirmPasswordController,
                  obscureText: _obscureConfirmPassword,
                  onChanged: (_) => widget.sessionController.clearErrorMessage(),
                  decoration: InputDecoration(
                    labelText: 'Yeni Şifre Tekrarı',
                    hintText: 'Şifreyi tekrar gir',
                    suffixIcon: IconButton(
                      onPressed: () {
                        setState(() {
                          _obscureConfirmPassword = !_obscureConfirmPassword;
                        });
                      },
                      icon: Icon(
                        _obscureConfirmPassword
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                      ),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Şifre tekrarı gerekli.';
                    }
                    if (value != _passwordController.text) {
                      return 'Şifreler aynı değil.';
                    }
                    return null;
                  },
                ),
                if (errorMessage != null) ...[
                  const SizedBox(height: 16),
                  _MessageBox(message: errorMessage, destructive: true),
                ],
                if (_completed) ...[
                  const SizedBox(height: 16),
                  const _MessageBox(
                    message: 'Şifren güncellendi. Artık yeni şifrenle giriş yapabilirsin.',
                  ),
                ],
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: widget.sessionController.isBusy ? null : _submit,
                    style: FilledButton.styleFrom(
                      minimumSize: const Size.fromHeight(54),
                    ),
                    child: widget.sessionController.isBusy
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2.2),
                          )
                        : const Text('Şifreyi Güncelle'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _MessageBox extends StatelessWidget {
  const _MessageBox({
    required this.message,
    this.destructive = false,
  });

  final String message;
  final bool destructive;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: destructive ? const Color(0xFFFDECEC) : const Color(0xFFEFFAF3),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: destructive ? const Color(0xFFF6C7C7) : const Color(0xFFBDE7C9),
        ),
      ),
      child: Text(
        message,
        style: TextStyle(
          color: destructive ? const Color(0xFF8A1F1F) : const Color(0xFF18603A),
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
