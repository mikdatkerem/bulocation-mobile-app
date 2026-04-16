import 'package:flutter/material.dart';

import '../app/app_session_controller.dart';
import 'auth_screen_styles.dart';
import 'forgot_password_screen.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key, required this.sessionController});

  final AppSessionController sessionController;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _obscureText = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final success = await widget.sessionController.signIn(
      email: _emailController.text,
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
            padding: const EdgeInsets.fromLTRB(8, 12, 8, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const AuthLogo(),
                const SizedBox(height: 0),
                const Center(
                  child: Text(
                    'Welcome back',
                    style: TextStyle(
                      color: authText,
                      fontFamily: 'Manrope',
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.8,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                const Center(
                  child: Text(
                    'Indoor navigation and map infrastructure via QR.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: authMuted,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Center(
                  child: AuthCard(
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const AuthLabel('EMAIL ADDRESS'),
                          TextFormField(
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            textInputAction: TextInputAction.next,
                            onChanged: (_) =>
                                widget.sessionController.clearErrorMessage(),
                            style: const TextStyle(
                                color: authText, fontWeight: FontWeight.w700),
                            decoration: authFieldDecoration(
                              'invalid@mail',
                              prefixIcon: Icons.email_rounded,
                              suffixIcon: errorMessage == null
                                  ? null
                                  : const Icon(Icons.error_rounded,
                                      size: 15, color: authDanger),
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Please enter a valid corporate email.';
                              }
                              return null;
                            },
                          ),
                          if (errorMessage != null) ...[
                            const SizedBox(height: 8),
                            AuthInlineError(message: errorMessage),
                          ],
                          const SizedBox(height: 18),
                          Row(
                            children: [
                              const AuthLabel('PASSWORD'),
                              const Spacer(),
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute<void>(
                                      builder: (_) => ForgotPasswordScreen(
                                        sessionController:
                                            widget.sessionController,
                                        initialEmail:
                                            _emailController.text.trim(),
                                      ),
                                    ),
                                  );
                                },
                                style: TextButton.styleFrom(
                                  foregroundColor: const Color(0xFF9EA6FF),
                                  padding: EdgeInsets.zero,
                                  minimumSize: const Size(0, 22),
                                  tapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                ),
                                child: const Text(
                                  'Forgot password?',
                                  style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w800),
                                ),
                              ),
                            ],
                          ),
                          TextFormField(
                            controller: _passwordController,
                            obscureText: _obscureText,
                            onChanged: (_) =>
                                widget.sessionController.clearErrorMessage(),
                            style: const TextStyle(
                                color: authText, fontWeight: FontWeight.w700),
                            decoration: authFieldDecoration(
                              '........',
                              prefixIcon: Icons.lock_rounded,
                              suffixIcon: IconButton(
                                onPressed: () {
                                  setState(() => _obscureText = !_obscureText);
                                },
                                icon: Icon(
                                  _obscureText
                                      ? Icons.visibility_outlined
                                      : Icons.visibility_off_outlined,
                                  color: authMuted,
                                  size: 18,
                                ),
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Sifre gerekli.';
                              }
                              return null;
                            },
                            onFieldSubmitted: (_) => _submit(),
                          ),
                          const SizedBox(height: 20),
                          AuthPrimaryButton(
                            label: 'Giris Yap',
                            busy: widget.sessionController.isBusy,
                            onPressed: _submit,
                          ),
                          const SizedBox(height: 24),
                          const AuthDivider(label: 'OR CONTINUE WITH'),
                          const SizedBox(height: 18),
                          AuthGoogleButton(
                            label: 'Google',
                            onPressed: widget.sessionController.isBusy
                                ? null
                                : _signInWithGoogle,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Hesabin yok mu?',
                      style: TextStyle(
                        color: authMuted,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    TextButton(
                      onPressed: widget.sessionController.isBusy
                          ? null
                          : () {
                              Navigator.of(context).push(
                                MaterialPageRoute<void>(
                                  builder: (_) => RegisterScreen(
                                    sessionController: widget.sessionController,
                                  ),
                                ),
                              );
                            },
                      style: TextButton.styleFrom(
                        foregroundColor: const Color(0xFFB7BDFF),
                        padding: const EdgeInsets.only(left: 6),
                        minimumSize: const Size(0, 28),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: const Text(
                        'Kayit Ol',
                        style: TextStyle(
                            fontSize: 12, fontWeight: FontWeight.w900),
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
