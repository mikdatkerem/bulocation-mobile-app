import 'package:flutter/material.dart';

const authBackground = Color(0xFF08090B);
const authCard = Color(0xFF0D0F12);
const authInput = Color(0xFF292B2D);
const authInputDark = Color(0xFF202225);
const authText = Color(0xFFE5E7EB);
const authMuted = Color(0xFF8B9099);
const authPrimary = Color(0xFF213CD3);
const authBorder = Color(0xFF2A2F38);
const authDanger = Color(0xFFE46C72);

class AuthDottedBackground extends StatelessWidget {
  const AuthDottedBackground({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: authBackground,
      child: child,
    );
  }
}

class AuthCard extends StatelessWidget {
  const AuthCard({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(maxWidth: 370),
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 22),
      decoration: BoxDecoration(
        color: authCard,
        borderRadius: BorderRadius.circular(7),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.45),
            blurRadius: 28,
            offset: const Offset(0, 20),
          ),
        ],
      ),
      child: child,
    );
  }
}

class AuthBrand extends StatelessWidget {
  const AuthBrand({super.key, this.centered = false});

  final bool centered;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: centered ? MainAxisAlignment.center : MainAxisAlignment.start,
      children: [
        Container(
          width: 15,
          height: 15,
          decoration: const BoxDecoration(
            color: authPrimary,
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.navigation_rounded,
            size: 10,
            color: authCard,
          ),
        ),
        const SizedBox(width: 8),
        const Text(
          'BULOCATION',
          style: TextStyle(
            color: Color(0xFF2947E7),
            fontSize: 15,
            fontWeight: FontWeight.w900,
            letterSpacing: 0.6,
          ),
        ),
      ],
    );
  }
}

class AuthLabel extends StatelessWidget {
  const AuthLabel(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: const TextStyle(
          color: authMuted,
          fontSize: 10,
          fontWeight: FontWeight.w900,
          letterSpacing: 1.1,
        ),
      ),
    );
  }
}

InputDecoration authFieldDecoration(
  String hint, {
  IconData? prefixIcon,
  Widget? suffixIcon,
}) {
  return InputDecoration(
    hintText: hint,
    hintStyle: const TextStyle(color: Color(0xFF777C84), fontWeight: FontWeight.w600),
    prefixIcon: prefixIcon == null
        ? null
        : Icon(prefixIcon, size: 16, color: const Color(0xFF747983)),
    suffixIcon: suffixIcon,
    filled: true,
    fillColor: authInput,
    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
    errorStyle: const TextStyle(
      color: Color(0xFFFF9BA1),
      fontSize: 11,
      fontWeight: FontWeight.w700,
    ),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(7),
      borderSide: BorderSide.none,
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(7),
      borderSide: BorderSide.none,
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(7),
      borderSide: const BorderSide(color: authPrimary, width: 1.2),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(7),
      borderSide: const BorderSide(color: authDanger, width: 1.1),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(7),
      borderSide: const BorderSide(color: authDanger, width: 1.1),
    ),
  );
}

class AuthPrimaryButton extends StatelessWidget {
  const AuthPrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    required this.busy,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool busy;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: FilledButton(
        onPressed: busy ? null : onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: authPrimary,
          disabledBackgroundColor: const Color(0xFF172058),
          foregroundColor: authText,
          minimumSize: const Size.fromHeight(48),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(7)),
        ),
        child: busy
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2.2, color: authText),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    label,
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(width: 8),
                  const Icon(Icons.arrow_forward_rounded, size: 16),
                ],
              ),
      ),
    );
  }
}

class AuthGoogleButton extends StatelessWidget {
  const AuthGoogleButton({super.key, required this.label, required this.onPressed});

  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          backgroundColor: const Color(0xFF303234),
          foregroundColor: authText,
          side: BorderSide.none,
          minimumSize: const Size.fromHeight(44),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'G',
              style: TextStyle(
                color: Color(0xFF4BA3FF),
                fontWeight: FontWeight.w900,
                fontSize: 18,
              ),
            ),
            const SizedBox(width: 10),
            Text(label, style: const TextStyle(fontWeight: FontWeight.w800)),
          ],
        ),
      ),
    );
  }
}

class AuthDivider extends StatelessWidget {
  const AuthDivider({super.key, required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(child: Divider(color: Color(0xFF282C31))),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            label,
            style: const TextStyle(
              color: authMuted,
              fontSize: 10,
              fontWeight: FontWeight.w900,
              letterSpacing: 2,
            ),
          ),
        ),
        const Expanded(child: Divider(color: Color(0xFF282C31))),
      ],
    );
  }
}

class AuthInlineError extends StatelessWidget {
  const AuthInlineError({super.key, required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Text(
      message,
      style: const TextStyle(
        color: Color(0xFFFF9BA1),
        fontSize: 11.5,
        fontWeight: FontWeight.w700,
      ),
    );
  }
}
