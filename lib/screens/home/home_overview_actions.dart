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

class _AmbientGlow extends StatelessWidget {
  const _AmbientGlow({
    required this.size,
    required this.color,
  });

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [
              color,
              color.withValues(alpha: 0),
            ],
          ),
        ),
      ),
    );
  }
}

class _QrStage extends StatelessWidget {
  const _QrStage({required this.pulse});

  final Animation<double> pulse;

  @override
  Widget build(BuildContext context) {
    final scanOffset = 22 + (pulse.value * 72);

    return SizedBox(
      height: 224,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 308,
            height: 212,
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFF),
              borderRadius: BorderRadius.circular(40),
              border: Border.all(color: const Color(0x226366F1)),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x120F172A),
                  blurRadius: 28,
                  offset: Offset(0, 18),
                ),
              ],
            ),
          ),
          Container(
            width: 196,
            height: 196,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.98),
              borderRadius: BorderRadius.circular(34),
              border: Border.all(color: const Color(0x336366F1), width: 1.4),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x140F172A),
                  blurRadius: 24,
                  offset: Offset(0, 18),
                ),
              ],
            ),
            child: Stack(
              children: [
                const Positioned.fill(
                  child: Padding(
                    padding: EdgeInsets.all(22),
                    child: _QrFrame(),
                  ),
                ),
                Positioned(
                  left: 26,
                  right: 26,
                  top: scanOffset,
                  child: Container(
                    height: 3,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(999),
                      gradient: const LinearGradient(
                        colors: [
                          Color(0x0022D3EE),
                          Color(0xAA22D3EE),
                          Color(0xAA6366F1),
                          Color(0x0022D3EE),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _QrFrame extends StatelessWidget {
  const _QrFrame();

  @override
  Widget build(BuildContext context) {
    return const Stack(
      children: [
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(22)),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFFF8FAFF),
                  Color(0xFFF2F5FF),
                ],
              ),
            ),
          ),
        ),
        Positioned.fill(
          child: CustomPaint(
            painter: _QrCornerPainter(),
          ),
        ),
        Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.qr_code_2_rounded,
                size: 62,
                color: Color(0xFF4F46E5),
              ),
              SizedBox(height: 10),
              Text(
                'QR okut',
                style: TextStyle(
                  color: _ink,
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
              SizedBox(height: 4),
              Text(
                'Harita anında açılsın',
                style: TextStyle(
                  color: _soft,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _QrCornerPainter extends CustomPainter {
  const _QrCornerPainter();

  @override
  void paint(Canvas canvas, Size size) {
    const color = Color(0xFF6366F1);
    final paint = Paint()
      ..color = color
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    const corner = 18.0;
    const inset = 12.0;

    void drawCorner(Offset start, Offset horizontalEnd, Offset verticalEnd) {
      canvas.drawLine(start, horizontalEnd, paint);
      canvas.drawLine(start, verticalEnd, paint);
    }

    drawCorner(
      const Offset(inset, inset),
      const Offset(inset + corner, inset),
      const Offset(inset, inset + corner),
    );
    drawCorner(
      Offset(size.width - inset, inset),
      Offset(size.width - inset - corner, inset),
      Offset(size.width - inset, inset + corner),
    );
    drawCorner(
      Offset(inset, size.height - inset),
      Offset(inset + corner, size.height - inset),
      Offset(inset, size.height - inset - corner),
    );
    drawCorner(
      Offset(size.width - inset, size.height - inset),
      Offset(size.width - inset - corner, size.height - inset),
      Offset(size.width - inset, size.height - inset - corner),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
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

class _ManualSelectionPanel extends StatelessWidget {
  const _ManualSelectionPanel({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 18),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: _line),
        boxShadow: const [
          BoxShadow(
            color: Color(0x100F172A),
            blurRadius: 20,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'MANUEL SEÇİM',
            style: TextStyle(
              color: _muted,
              fontSize: 12,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.8,
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'QR yoksa kurum seçerek devam edin.',
            style: TextStyle(
              color: _ink,
              fontSize: 22,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.6,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Önce kurum seçin. Ardından yerleşke, bina ve kat adımlarıyla ilgili haritayı açın.',
            style: TextStyle(
              color: _soft,
              fontSize: 14,
              height: 1.6,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 18),
          InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(22),
            child: Ink(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              decoration: BoxDecoration(
                color: _surfaceMuted,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: _line),
              ),
              child: const Row(
                children: [
                  Icon(Icons.search_rounded, color: _accent, size: 22),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Kurum, bina veya kat seç',
                      style: TextStyle(
                        color: _soft,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  Icon(Icons.arrow_forward_rounded, color: _ink),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.title,
    required this.actionLabel,
    required this.onAction,
  });

  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              color: _muted,
              fontSize: 12,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.8,
            ),
          ),
        ),
        if (actionLabel != null)
          TextButton(
            onPressed: onAction,
            style: TextButton.styleFrom(
              foregroundColor: _soft,
              padding: EdgeInsets.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Text(actionLabel!),
          ),
      ],
    );
  }
}
