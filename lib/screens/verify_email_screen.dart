import 'package:flutter/material.dart';

import '../app/app_session_controller.dart';

class VerifyEmailScreen extends StatefulWidget {
  const VerifyEmailScreen({
    super.key,
    required this.sessionController,
    required this.email,
  });

  final AppSessionController sessionController;
  final String email;

  @override
  State<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends State<VerifyEmailScreen> {
  final _formKey = GlobalKey<FormState>();
  final _tokenController = TextEditingController();
  bool _verified = false;
  bool _resent = false;

  @override
  void dispose() {
    _tokenController.dispose();
    super.dispose();
  }

  Future<void> _verify() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    try {
      await widget.sessionController.verifyEmail(_tokenController.text);
      if (!mounted) {
        return;
      }
      setState(() => _verified = true);
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() {});
    }
  }

  Future<void> _resend() async {
    try {
      await widget.sessionController.resendEmailVerification(widget.email);
      if (!mounted) {
        return;
      }
      setState(() => _resent = true);
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
      appBar: AppBar(title: const Text('E-posta Dogrulama')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.email,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1B2842),
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'E-postana gonderilen dogrulama kodunu gir. Gerekirse yeniden gonderebilirsin.',
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
                    labelText: 'Dogrulama Kodu',
                    hintText: 'Kodu yapistir',
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Dogrulama kodu gerekli.';
                    }
                    return null;
                  },
                ),
                if (errorMessage != null) ...[
                  const SizedBox(height: 16),
                  _Message(message: errorMessage, destructive: true),
                ],
                if (_verified) ...[
                  const SizedBox(height: 16),
                  const _Message(message: 'E-posta adresin dogrulandi.'),
                ],
                if (_resent) ...[
                  const SizedBox(height: 16),
                  const _Message(
                    message: 'Dogrulama e-postasi tekrar gonderildi.',
                  ),
                ],
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: widget.sessionController.isBusy ? null : _verify,
                    style: FilledButton.styleFrom(
                      minimumSize: const Size.fromHeight(54),
                    ),
                    child: widget.sessionController.isBusy
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2.2),
                          )
                        : const Text('E-postayi Dogrula'),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: widget.sessionController.isBusy ? null : _resend,
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size.fromHeight(52),
                    ),
                    child: const Text('Kodu Yeniden Gonder'),
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

class _Message extends StatelessWidget {
  const _Message({
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
