import 'package:flutter/material.dart';

const authBackground = Color(0xFF060708);
const authCard = Color(0xFF121315);
const authInput = Color(0xFF292A2B);
const authInputDark = Color(0xFF1F2021);
const authText = Color(0xFFE3E2E3);
const authMuted = Color(0xFF8F8FA0);
const authSubtleText = Color(0xFFC5C5D6);
const authPrimary = Color(0xFF1836B9);
const authPrimaryText = Color(0xFFA4B1FF);
const authBorder = Color(0xFF444654);
const authDanger = Color(0xFFFFB4AB);
const authSecondary = Color(0xFF4B18B9);

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
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 370),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: authCard,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.48),
              blurRadius: 34,
              offset: const Offset(0, 22),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 22, 20, 22),
                child: child,
              ),
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: Container(
                  height: 3,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [
                        authCard,
                        Color(0xFF101527),
                        Color(0xFF14236C),
                        authPrimary,
                        Color(0xFF182B93),
                        Color(0xFF111735),
                      ],
                      stops: [0, 0.16, 0.36, 0.66, 0.84, 1],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: authPrimary.withValues(alpha: 0.42),
                        blurRadius: 14,
                        spreadRadius: 0.2,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class AuthBrand extends StatelessWidget {
  const AuthBrand({super.key, this.centered = false});

  final bool centered;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment:
          centered ? MainAxisAlignment.center : MainAxisAlignment.start,
      children: [
        Container(
          width: 16,
          height: 16,
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
            fontFamily: 'Manrope',
            fontSize: 15,
            fontWeight: FontWeight.w900,
            letterSpacing: 0.6,
          ),
        ),
      ],
    );
  }
}

class AuthLogo extends StatelessWidget {
  const AuthLogo({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: MediaQuery.sizeOf(context).width * 0.92,
        height: 150,
        child: Image.asset(
          'assets/logo_removed_bg.png',
          fit: BoxFit.contain,
          filterQuality: FilterQuality.high,
        ),
      ),
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
          letterSpacing: 1.35,
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
    hintStyle: const TextStyle(
      color: Color(0xFF686A72),
      fontWeight: FontWeight.w700,
      fontSize: 13,
    ),
    prefixIcon: prefixIcon == null
        ? null
        : Icon(prefixIcon, size: 15, color: const Color(0xFF5F626A)),
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
          foregroundColor: authPrimaryText,
          minimumSize: const Size.fromHeight(48),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(7)),
        ),
        child: busy
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                    strokeWidth: 2.2, color: authText),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      fontFamily: 'Manrope',
                      fontWeight: FontWeight.w800,
                      fontSize: 13,
                    ),
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
  const AuthGoogleButton(
      {super.key, required this.label, required this.onPressed});

  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          backgroundColor: const Color(0xFF343536),
          foregroundColor: authText,
          side: BorderSide.none,
          minimumSize: const Size.fromHeight(44),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(
              width: 18,
              height: 18,
              child: CustomPaint(
                painter: _GoogleLogoPainter(),
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

class _GoogleLogoPainter extends CustomPainter {
  const _GoogleLogoPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final strokeWidth = size.width * 0.16;
    final rect = Rect.fromLTWH(
      strokeWidth / 2,
      strokeWidth / 2,
      size.width - strokeWidth,
      size.height - strokeWidth,
    );

    void drawArc(Color color, double start, double sweep) {
      final paint = Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.square;
      canvas.drawArc(rect, start, sweep, false, paint);
    }

    drawArc(const Color(0xFF4285F4), -0.15, 1.55);
    drawArc(const Color(0xFF34A853), 1.35, 1.18);
    drawArc(const Color(0xFFFBBC05), 2.5, 0.9);
    drawArc(const Color(0xFFEA4335), 3.35, 1.52);

    final bluePaint = Paint()
      ..color = const Color(0xFF4285F4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.square;
    final centerY = size.height * 0.52;
    canvas.drawLine(
      Offset(size.width * 0.52, centerY),
      Offset(size.width * 0.9, centerY),
      bluePaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
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
