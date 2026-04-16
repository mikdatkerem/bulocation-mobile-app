import 'package:flutter/material.dart';

import '../app/app_session_controller.dart';
import '../main.dart';

const _authBackground = Color(0xFF060708);
const _authSurface = Color(0xFF0D1013);
const _authText = Color(0xFFF5F3EF);
const _authMuted = Color(0xFFA8AFBC);
const _authBlue = Color(0xFF1836B9);
const _authBorder = Color(0xFF242A31);

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key, required this.sessionController});

  final AppSessionController sessionController;

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _userNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _userNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final success = await widget.sessionController.signUp(
      userName: _userNameController.text,
      email: _emailController.text,
      firstName: _firstNameController.text,
      lastName: _lastNameController.text,
      password: _passwordController.text,
    );

    if (!mounted || success) {
      return;
    }

    setState(() {});
  }

  Future<void> _signInWithGoogle() async {
    final success = await widget.sessionController.signInWithGoogle();
    if (!mounted || success) {
      return;
    }

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final errorMessage = widget.sessionController.errorMessage;

    return Scaffold(
      backgroundColor: _authBackground,
      appBar: AppBar(
        backgroundColor: _authBackground,
        foregroundColor: _authText,
        title: const Text(
          'Kayit ol',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(22, 10, 22, 28),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Image.asset(
                    'assets/logo_removed_bg.png',
                    height: 54,
                    fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) => const Text(
                      'Bulocation',
                      style: TextStyle(
                        color: _authText,
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 34),
                const Text(
                  'Yeni hesap olustur',
                  style: TextStyle(
                    color: _authText,
                    fontSize: 34,
                    height: 1,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -1.1,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Kurum haritalari, QR konum acilisi ve kapali alan navigasyonu icin guvenli hesabini olustur.',
                  style: TextStyle(
                    color: _authMuted,
                    fontSize: 15,
                    height: 1.55,
                  ),
                ),
                const SizedBox(height: 26),
                Container(
                  decoration: BoxDecoration(
                    color: _authSurface,
                    border: Border.all(color: _authBorder),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: _LabeledField(
                              label: 'Ad',
                              child: TextFormField(
                                controller: _firstNameController,
                                textInputAction: TextInputAction.next,
                                onChanged: (_) => widget.sessionController.clearErrorMessage(),
                                style: const TextStyle(color: _authText),
                                decoration: _authInputDecoration('Ahmet'),
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'Ad gerekli.';
                                  }
                                  return null;
                                },
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _LabeledField(
                              label: 'Soyad',
                              child: TextFormField(
                                controller: _lastNameController,
                                textInputAction: TextInputAction.next,
                                onChanged: (_) => widget.sessionController.clearErrorMessage(),
                                style: const TextStyle(color: _authText),
                                decoration: _authInputDecoration('Yilmaz'),
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'Soyad gerekli.';
                                  }
                                  return null;
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),
                      _LabeledField(
                        label: 'Kullanici adi',
                        child: TextFormField(
                          controller: _userNameController,
                          textInputAction: TextInputAction.next,
                          onChanged: (_) => widget.sessionController.clearErrorMessage(),
                          style: const TextStyle(color: _authText),
                          decoration: _authInputDecoration('ahmetyilmaz'),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Kullanici adi gerekli.';
                            }
                            if (value.trim().length < 3) {
                              return 'En az 3 karakter olmali.';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(height: 18),
                      _LabeledField(
                        label: 'E-posta adresi',
                        child: TextFormField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.next,
                          onChanged: (_) => widget.sessionController.clearErrorMessage(),
                          style: const TextStyle(color: _authText),
                          decoration: _authInputDecoration('ornek@mail.com'),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'E-posta adresi gerekli.';
                            }
                            if (!value.contains('@')) {
                              return 'Gecerli e-posta gir.';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(height: 18),
                      _LabeledField(
                        label: 'Sifre',
                        child: TextFormField(
                          controller: _passwordController,
                          obscureText: _obscurePassword,
                          textInputAction: TextInputAction.next,
                          onChanged: (_) => widget.sessionController.clearErrorMessage(),
                          style: const TextStyle(color: _authText),
                          decoration: _authInputDecoration('En az 8 karakter').copyWith(
                            suffixIcon: IconButton(
                              onPressed: () {
                                setState(() => _obscurePassword = !_obscurePassword);
                              },
                              icon: Icon(
                                _obscurePassword
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined,
                                color: _authMuted,
                              ),
                            ),
                          ),
                          validator: (value) {
                            final text = value ?? '';
                            if (text.isEmpty) {
                              return 'Sifre gerekli.';
                            }
                            if (text.length < 8) {
                              return 'En az 8 karakter olmali.';
                            }
                            if (!RegExp(r'[A-Z]').hasMatch(text) ||
                                !RegExp(r'[a-z]').hasMatch(text) ||
                                !RegExp(r'[0-9]').hasMatch(text)) {
                              return 'Buyuk harf, kucuk harf ve rakam icermeli.';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(height: 18),
                      _LabeledField(
                        label: 'Sifre tekrari',
                        child: TextFormField(
                          controller: _confirmPasswordController,
                          obscureText: _obscureConfirmPassword,
                          textInputAction: TextInputAction.done,
                          onChanged: (_) => widget.sessionController.clearErrorMessage(),
                          onFieldSubmitted: (_) => _submit(),
                          style: const TextStyle(color: _authText),
                          decoration: _authInputDecoration('Sifreni tekrar gir').copyWith(
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
                                color: _authMuted,
                              ),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Sifre tekrar gerekli.';
                            }
                            if (value != _passwordController.text) {
                              return 'Sifreler ayni degil.';
                            }
                            return null;
                          },
                        ),
                      ),
                      if (errorMessage != null) ...[
                        const SizedBox(height: 18),
                        _AuthMessage(message: errorMessage),
                      ],
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton(
                          onPressed: widget.sessionController.isBusy ? null : _submit,
                          style: FilledButton.styleFrom(
                            backgroundColor: _authBlue,
                            foregroundColor: _authText,
                            minimumSize: const Size.fromHeight(56),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: widget.sessionController.isBusy
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.2,
                                    color: _authText,
                                  ),
                                )
                              : const Text(
                                  'Kaydi tamamla',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                        ),
                      ),
                      if (AppConfig.googleSignInEnabled) ...[
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            onPressed: widget.sessionController.isBusy
                                ? null
                                : _signInWithGoogle,
                            style: OutlinedButton.styleFrom(
                              foregroundColor: _authText,
                              side: const BorderSide(color: _authBorder),
                              minimumSize: const Size.fromHeight(54),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            icon: const Icon(Icons.g_mobiledata_rounded, size: 28),
                            label: const Text(
                              'Google ile kayit ol',
                              style: TextStyle(fontWeight: FontWeight.w800),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: widget.sessionController.isBusy
                        ? null
                        : () => Navigator.of(context).maybePop(),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: _authText,
                      side: const BorderSide(color: _authBorder),
                      minimumSize: const Size.fromHeight(54),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Girise don',
                      style: TextStyle(fontWeight: FontWeight.w800),
                    ),
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

class _LabeledField extends StatelessWidget {
  const _LabeledField({required this.label, required this.child});

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: _authMuted,
            fontSize: 12,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.1,
          ),
        ),
        const SizedBox(height: 8),
        child,
      ],
    );
  }
}

class _AuthMessage extends StatelessWidget {
  const _AuthMessage({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF2A1013),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF6B252B)),
      ),
      child: Text(
        message,
        style: const TextStyle(
          color: Color(0xFFFFCDD2),
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

InputDecoration _authInputDecoration(String hint) {
  return InputDecoration(
    hintText: hint,
    hintStyle: const TextStyle(color: Color(0xFF606A78)),
    filled: true,
    fillColor: const Color(0xFF090C0F),
    errorStyle: const TextStyle(
      color: Color(0xFFFFA4AC),
      fontWeight: FontWeight.w700,
    ),
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: _authBorder),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: _authBorder),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: Color(0xFF3854E8), width: 1.3),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: Color(0xFF9B2D36)),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: Color(0xFFFF6B76)),
    ),
  );
}
