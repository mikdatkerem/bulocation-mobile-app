import 'package:flutter/material.dart';

import '../app/app_session_controller.dart';
import 'auth_screen_styles.dart';

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
      backgroundColor: authBackground,
      body: AuthDottedBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(8, 8, 8, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const AuthLogo(),
                const SizedBox(height: 0),
                const Text(
                  'Yeni hesap oluştur',
                  style: TextStyle(
                    color: authText,
                    fontFamily: 'Manrope',
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.8,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Gerekli bilgileri doldurarak platforma katılın.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: authMuted,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 28),
                AuthCard(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: AuthField(
                                label: 'AD',
                                child: TextFormField(
                                  controller: _firstNameController,
                                  textInputAction: TextInputAction.next,
                                  onChanged: (_) =>
                                      widget.sessionController.clearErrorMessage(),
                                  style: const TextStyle(
                                    color: authText,
                                    fontWeight: FontWeight.w700,
                                  ),
                                  decoration: authFieldDecoration('Adınız'),
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
                              child: AuthField(
                                label: 'SOYAD',
                                child: TextFormField(
                                  controller: _lastNameController,
                                  textInputAction: TextInputAction.next,
                                  onChanged: (_) =>
                                      widget.sessionController.clearErrorMessage(),
                                  style: const TextStyle(
                                    color: authText,
                                    fontWeight: FontWeight.w700,
                                  ),
                                  decoration: authFieldDecoration(
                                    'Soyadınız',
                                  ),
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
                        const SizedBox(height: 16),
                        AuthField(
                          label: 'KULLANICI ADI',
                          child: TextFormField(
                            controller: _userNameController,
                            textInputAction: TextInputAction.next,
                            onChanged: (_) =>
                                widget.sessionController.clearErrorMessage(),
                            style: const TextStyle(
                              color: authText,
                              fontWeight: FontWeight.w700,
                            ),
                            decoration: authFieldDecoration(
                              'kullanici_adi',
                              prefixIcon: Icons.alternate_email_rounded,
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Kullanıcı adı gerekli.';
                              }
                              if (value.trim().length < 3) {
                                return 'En az 3 karakter olmalı.';
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(height: 16),
                        AuthField(
                          label: 'E-POSTA',
                          child: TextFormField(
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            textInputAction: TextInputAction.next,
                            onChanged: (_) =>
                                widget.sessionController.clearErrorMessage(),
                            style: const TextStyle(
                              color: authText,
                              fontWeight: FontWeight.w700,
                            ),
                            decoration: authFieldDecoration(
                              'ornek@email.com',
                              prefixIcon: Icons.email_rounded,
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'E-posta adresi gerekli.';
                              }
                              if (!value.contains('@')) {
                                return 'Geçerli e-posta gir.';
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(height: 16),
                        AuthField(
                          label: 'ŞİFRE',
                          child: TextFormField(
                            controller: _passwordController,
                            obscureText: _obscurePassword,
                            textInputAction: TextInputAction.next,
                            onChanged: (_) =>
                                widget.sessionController.clearErrorMessage(),
                            style: const TextStyle(
                              color: authText,
                              fontWeight: FontWeight.w700,
                            ),
                            decoration: authFieldDecoration(
                              '........',
                              prefixIcon: Icons.lock_rounded,
                              suffixIcon: IconButton(
                                onPressed: () {
                                  setState(() {
                                    _obscurePassword = !_obscurePassword;
                                  });
                                },
                                icon: Icon(
                                  _obscurePassword
                                      ? Icons.visibility_outlined
                                      : Icons.visibility_off_outlined,
                                  color: authMuted,
                                  size: 18,
                                ),
                              ),
                            ),
                            validator: (value) {
                              final text = value ?? '';
                              if (text.isEmpty) {
                                return 'Şifre gerekli.';
                              }
                              if (text.length < 8) {
                                return 'En az 8 karakter olmalı.';
                              }
                              if (!RegExp(r'[A-Z]').hasMatch(text) ||
                                  !RegExp(r'[a-z]').hasMatch(text) ||
                                  !RegExp(r'[0-9]').hasMatch(text)) {
                                return 'Büyük harf, küçük harf ve rakam içermeli.';
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(height: 16),
                        AuthField(
                          label: 'ŞİFRE TEKRAR',
                          child: TextFormField(
                            controller: _confirmPasswordController,
                            obscureText: _obscureConfirmPassword,
                            textInputAction: TextInputAction.done,
                            onChanged: (_) =>
                                widget.sessionController.clearErrorMessage(),
                            onFieldSubmitted: (_) => _submit(),
                            style: const TextStyle(
                              color: authText,
                              fontWeight: FontWeight.w700,
                            ),
                            decoration: authFieldDecoration(
                              '........',
                              prefixIcon: Icons.lock_rounded,
                              suffixIcon: IconButton(
                                onPressed: () {
                                  setState(() {
                                    _obscureConfirmPassword =
                                        !_obscureConfirmPassword;
                                  });
                                },
                                icon: Icon(
                                  _obscureConfirmPassword
                                      ? Icons.visibility_outlined
                                      : Icons.visibility_off_outlined,
                                  color: authMuted,
                                  size: 18,
                                ),
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Şifre tekrar gerekli.';
                              }
                              if (value != _passwordController.text) {
                                return 'Şifreler aynı değil.';
                              }
                              return null;
                            },
                          ),
                        ),
                        if (errorMessage != null) ...[
                          const SizedBox(height: 12),
                          AuthInlineError(message: errorMessage),
                        ],
                        const SizedBox(height: 24),
                        AuthPrimaryButton(
                          label: 'Kaydı Tamamla',
                          busy: widget.sessionController.isBusy,
                          onPressed: _submit,
                        ),
                        const SizedBox(height: 22),
                        const AuthDivider(label: 'VEYA'),
                        const SizedBox(height: 18),
                        AuthGoogleButton(
                          label: 'Google ile devam et',
                          onPressed: widget.sessionController.isBusy
                              ? null
                              : _signInWithGoogle,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 22),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Zaten üye misin?',
                      style: TextStyle(
                        color: authMuted,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    TextButton(
                      onPressed: widget.sessionController.isBusy
                          ? null
                          : () => Navigator.of(context).maybePop(),
                      style: TextButton.styleFrom(
                        foregroundColor: authPrimary,
                        padding: const EdgeInsets.only(left: 6),
                        minimumSize: const Size(0, 28),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: const Text(
                        'Giriş Yap',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
