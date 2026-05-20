part of '../home_overview_screen.dart';

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 116,
      child: Center(
        child: SizedBox(
          height: 108,
          child: Image.asset(
            'assets/logo_removed_bg.png',
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }
}

class _HeroScene extends StatelessWidget {
  const _HeroScene({
    required this.greeting,
    required this.description,
    required this.readyFloorCount,
    required this.siteCount,
    required this.pulse,
    required this.onPrimaryTap,
  });

  final String greeting;
  final String description;
  final int readyFloorCount;
  final int siteCount;
  final Animation<double> pulse;
  final VoidCallback onPrimaryTap;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: pulse,
      builder: (context, _) {
        return SizedBox(
          height: 500,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              const Positioned(
                top: 12,
                left: -24,
                child: _AmbientGlow(
                  size: 160,
                  color: Color(0x126366F1),
                ),
              ),
              const Positioned(
                top: 210,
                right: -20,
                child: _AmbientGlow(
                  size: 180,
                  color: Color(0x1022D3EE),
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    greeting,
                    style: const TextStyle(
                      color: _soft,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 18),
                  const Text(
                    'Harita\nkapıda başlasın.',
                    style: TextStyle(
                      color: _ink,
                      fontSize: 48,
                      height: 0.94,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -2.2,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'QR TABANLI BAŞLANGIÇ',
                    style: TextStyle(
                      color: _accent,
                      fontSize: 13,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.8,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 330),
                    child: Text(
                      description,
                      style: const TextStyle(
                        color: _soft,
                        fontSize: 15,
                        height: 1.7,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    '$readyFloorCount hazır kat · $siteCount yerleşke',
                    style: const TextStyle(
                      color: _muted,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 26),
                  Expanded(
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Positioned.fill(
                          child: Align(
                            alignment: Alignment.topCenter,
                            child: _QrStage(pulse: pulse),
                          ),
                        ),
                        Positioned(
                          left: 0,
                          right: 0,
                          bottom: 48,
                          child: _PrimaryAction(
                            title: 'QR ile başla',
                            subtitle:
                                'Bulunduğunuz noktadaki QR kodunu okutun, harita anında açılsın.',
                            icon: Icons.qr_code_scanner_rounded,
                            onTap: onPrimaryTap,
                          ),
                        ),
                        const Positioned(
                          left: 0,
                          right: 0,
                          bottom: 6,
                          child: _HeroScrollHint(),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class _PrimaryAction extends StatelessWidget {
  const _PrimaryAction({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(28),
      child: Ink(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
        decoration: BoxDecoration(
          color: _accent,
          borderRadius: BorderRadius.circular(28),
          boxShadow: const [
            BoxShadow(
              color: Color(0x256366F1),
              blurRadius: 34,
              offset: Offset(0, 18),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 54,
              height: 54,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.16),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Icon(icon, color: _text, size: 30),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: _text,
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: _text.withValues(alpha: 0.78),
                      fontSize: 13,
                      height: 1.45,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            const Icon(Icons.arrow_forward_rounded, color: _text),
          ],
        ),
      ),
    );
  }
}

class _HeroScrollHint extends StatelessWidget {
  const _HeroScrollHint();

  @override
  Widget build(BuildContext context) {
    return const Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.keyboard_arrow_down_rounded, color: _muted, size: 24),
        SizedBox(height: 2),
        Text(
          'Manuel seçim aşağıda',
          style: TextStyle(
            color: _muted,
            fontSize: 11,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}
