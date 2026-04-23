part of '../auth_screen_styles.dart';

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
              color: const Color(0xFF0F172A).withValues(alpha: 0.10),
              blurRadius: 30,
              offset: const Offset(0, 18),
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
                        Color(0xFFFFFFFF),
                        Color(0xFFE0E7FF),
                        Color(0xFFC7D2FE),
                        authPrimary,
                        Color(0xFF818CF8),
                        Color(0xFFE0F2FE),
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
            color: Colors.white,
          ),
        ),
        const SizedBox(width: 8),
        const Text(
          'BULOCATION',
          style: TextStyle(
            color: authPrimary,
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
