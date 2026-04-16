import 'package:flutter/material.dart';

import '../app/app_session_controller.dart';
import '../main.dart';
import 'forgot_password_screen.dart';
import 'register_screen.dart';

const _authBackground = Color(0xFF060708);
const _authSurface = Color(0xFF0D1013);
const _authSurfaceAlt = Color(0xFF15191D);
const _authText = Color(0xFFF5F3EF);
const _authMuted = Color(0xFFA8AFBC);
const _authBlue = Color(0xFF1836B9);
const _authBorder = Color(0xFF242A31);

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
      backgroundColor: _authBackground,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(22, 22, 22, 28),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: MediaQuery.sizeOf(context).height -
                  MediaQuery.paddingOf(context).top -
                  MediaQuery.paddingOf(context).bottom -
                  50,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const _BrandHeader(),
                const SizedBox(height: 42),
                const Text(
                  'Guvenli erisim',
                  style: TextStyle(
                    color: _authText,
                    fontSize: 42,
                    height: 0.95,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -1.6,
                  ),
                ),
                const SizedBox(height: 14),
                const Text(
                  'Indoor navigasyon, QR konum ve canli otopark verilerine tek hesapla erisin.',
                  style: TextStyle(
                    color: _authMuted,
                    fontSize: 15.5,
                    height: 1.55,
                  ),
                ),
                const SizedBox(height: 30),
                Container(
                  decoration: BoxDecoration(
                    color: _authSurface,
                    border: Border.all(color: _authBorder),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  padding: const EdgeInsets.all(18),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const _FieldLabel('E-posta adresi'),
                        TextFormField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.next,
                          onChanged: (_) => widget.sessionController.clearErrorMessage(),
                          style: const TextStyle(color: _authText),
                          decoration: authInputDecoration('ornek@mail.com'),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'E-posta adresi gerekli.';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 18),
                        Row(
                          children: [
                            const _FieldLabel('Sifre'),
                            const Spacer(),
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute<void>(
                                    builder: (_) => ForgotPasswordScreen(
                                      sessionController: widget.sessionController,
                                      initialEmail: _emailController.text.trim(),
                                    ),
                                  ),
                                );
                              },
                              style: TextButton.styleFrom(
                                foregroundColor: const Color(0xFF8EA6FF),
                                padding: EdgeInsets.zero,
                                minimumSize: const Size(0, 24),
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                              child: const Text('Sifremi unuttum'),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _passwordController,
                          obscureText: _obscureText,
                          onChanged: (_) => widget.sessionController.clearErrorMessage(),
                          style: const TextStyle(color: _authText),
                          decoration: authInputDecoration('••••••••').copyWith(
                            suffixIcon: IconButton(
                              onPressed: () {
                                setState(() => _obscureText = !_obscureText);
                              },
                              icon: Icon(
                                _obscureText
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined,
                                color: _authMuted,
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
                        if (errorMessage != null) ...[
                          const SizedBox(height: 16),
                          _AuthMessage(message: errorMessage),
                        ],
                        const SizedBox(height: 22),
                        SizedBox(
                          width: double.infinity,
                          child: FilledButton(
                            onPressed: widget.sessionController.isBusy ? null : _submit,
                            style: FilledButton.styleFrom(
                              backgroundColor: _authBlue,
                              foregroundColor: _authText,
                              disabledBackgroundColor: _authSurfaceAlt,
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
                                    'Giris yap',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                          ),
                        ),
                        if (AppConfig.googleSignInEnabled) ...[
                          const SizedBox(height: 12),
                          _SecondaryAuthButton(
                            label: 'Google ile devam et',
                            icon: Icons.g_mobiledata_rounded,
                            onPressed: widget.sessionController.isBusy ? null : _signInWithGoogle,
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 22),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Hesabiniz yok mu?',
                      style: TextStyle(color: _authMuted),
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
                        foregroundColor: const Color(0xFF8EA6FF),
                      ),
                      child: const Text('Kayit ol'),
                    ),
                  ],
                ),
                const SizedBox(height: 34),
                const Center(
                  child: Text(
                    'BULOCATION SECURE ACCESS',
                    style: TextStyle(
                      color: Color(0xFF687080),
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 2.8,
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

class _BrandHeader extends StatelessWidget {
  const _BrandHeader();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Image.asset(
          'assets/logo_removed_bg.png',
          height: 48,
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
        const Spacer(),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
          decoration: BoxDecoration(
            color: _authSurface,
            border: Border.all(color: _authBorder),
            borderRadius: BorderRadius.circular(999),
          ),
          child: const Text(
            'v1.0',
            style: TextStyle(
              color: _authMuted,
              fontSize: 11,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.2,
            ),
          ),
        ),
      ],
    );
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        label,
        style: const TextStyle(
          color: _authMuted,
          fontSize: 12,
          fontWeight: FontWeight.w800,
          letterSpacing: 1.1,
        ),
      ),
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

class _SecondaryAuthButton extends StatelessWidget {
  const _SecondaryAuthButton({
    required this.label,
    required this.icon,
    required this.onPressed,
  });

  final String label;
  final IconData icon;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: _authText,
          side: const BorderSide(color: _authBorder),
          minimumSize: const Size.fromHeight(54),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        icon: Icon(icon, size: 28),
        label: Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
    );
  }
}

InputDecoration authInputDecoration(String hint) {
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
