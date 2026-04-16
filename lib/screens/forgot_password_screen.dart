import 'package:flutter/material.dart';

import '../app/app_session_controller.dart';
import 'reset_password_screen.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({
    super.key,
    required this.sessionController,
    this.initialEmail,
  });

  final AppSessionController sessionController;
  final String? initialEmail;

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _emailController;
  bool _submitted = false;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController(text: widget.initialEmail ?? '');
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    try {
      await widget.sessionController.forgotPassword(_emailController.text);
      if (!mounted) {
        return;
      }
      setState(() => _submitted = true);
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final errorMessage = widget.sessionController.errorMessage;

    return Scaffold(
      appBar: AppBar(title: const Text('Sifre Sifirlama')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Sifre sifirlama baglantisi gonder',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF1B2842),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Kayitli e-posta adresini gir. Sana sifre yenileme kodu gonderecegiz.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: const Color(0xFF667086),
                  ),
                ),
                const SizedBox(height: 24),
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  onChanged: (_) => widget.sessionController.clearErrorMessage(),
                  decoration: const InputDecoration(
                    labelText: 'E-posta Adresi',
                    hintText: 'ornek@mail.com',
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'E-posta adresi gerekli.';
                    }
                    if (!value.contains('@')) {
                      return 'Gecerli bir e-posta adresi gir.';
                    }
                    return null;
                  },
                ),
                if (errorMessage != null) ...[
                  const SizedBox(height: 16),
                  _AuthMessageBox(
                    message: errorMessage,
                    destructive: true,
                  ),
                ],
                if (_submitted) ...[
                  const SizedBox(height: 16),
                  const _AuthMessageBox(
                    message:
                        'E-posta sistemde kayitliysa sifre sifirlama kodu gonderildi.',
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
                        : const Text('Sifirlama Kodu Gonder'),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => ResetPasswordScreen(
                            sessionController: widget.sessionController,
                            initialEmail: _emailController.text.trim(),
                          ),
                        ),
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size.fromHeight(52),
                    ),
                    child: const Text('Kodum Var, Sifreyi Yenile'),
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

class _AuthMessageBox extends StatelessWidget {
  const _AuthMessageBox({
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
