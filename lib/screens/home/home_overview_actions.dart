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
      builder: (context, _) => SizedBox(
        height: 540,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned(
              top: 8,
              left: -14,
              child: _GlowOrb(
                size: 140,
                color: const Color(0x1A6366F1),
                offset: Offset(-18, 12 * pulse.value),
              ),
            ),
            Positioned(
              top: 148,
              right: -4,
              child: _GlowOrb(
                size: 170,
                color: const Color(0x1222D3EE),
                offset: Offset(10, -8 * pulse.value),
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  greeting,
                  style: const TextStyle(
                    color: _soft,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.1,
                  ),
                ),
                const SizedBox(height: 14),
                const Text(
                  'Harita\nkapıda başlasın.',
                  style: TextStyle(
                    color: _ink,
                    fontSize: 46,
                    height: 0.94,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -2.1,
                  ),
                ),
                const SizedBox(height: 18),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 320),
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
                const SizedBox(height: 22),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    _MetricPill(label: '$readyFloorCount hazır kat'),
                    _MetricPill(label: '$siteCount yerleşke'),
                    const _MetricPill(label: 'QR ile anında açılış'),
                  ],
                ),
                const SizedBox(height: 28),
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
                        bottom: 54,
                        child: _PrimaryAction(
                          title: 'QR ile başla',
                          subtitle:
                              'Bulunduğunuz noktadaki QR kodunu okutun, doğru harita anında açılsın.',
                          icon: Icons.qr_code_scanner_rounded,
                          onTap: onPrimaryTap,
                        ),
                      ),
                      const Positioned(
                        left: 0,
                        right: 0,
                        bottom: 8,
                        child: _HeroScrollHint(),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _GlowOrb extends StatelessWidget {
  const _GlowOrb({
    required this.size,
    required this.color,
    required this.offset,
  });

  final double size;
  final Color color;
  final Offset offset;

  @override
  Widget build(BuildContext context) {
    return Transform.translate(
      offset: offset,
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
    final haloScale = 0.96 + (pulse.value * 0.08);
    final ringOpacity = 0.28 + (pulse.value * 0.18);

    return SizedBox(
      height: 248,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Transform.scale(
            scale: haloScale,
            child: Container(
              width: 256,
              height: 256,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    _accent.withValues(alpha: ringOpacity),
                    _accent.withValues(alpha: 0.02),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          Container(
            width: 296,
            height: 208,
            decoration: BoxDecoration(
              color: const Color(0xFFF6F8FF),
              borderRadius: BorderRadius.circular(40),
              border: Border.all(color: const Color(0x356366F1)),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x140F172A),
                  blurRadius: 28,
                  offset: Offset(0, 18),
                ),
              ],
            ),
          ),
          Transform.rotate(
            angle: -0.12,
            child: Container(
              width: 152,
              height: 152,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(36),
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFFEEF2FF),
                    Color(0xFFDDE5FF),
                  ],
                ),
                border: Border.all(color: const Color(0x3A6366F1)),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x146366F1),
                    blurRadius: 22,
                    offset: Offset(0, 16),
                  ),
                ],
              ),
            ),
          ),
          Container(
            width: 172,
            height: 172,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(38),
              border: Border.all(color: const Color(0x3F6366F1), width: 1.4),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x140F172A),
                  blurRadius: 28,
                  offset: Offset(0, 20),
                ),
              ],
            ),
            child: const Padding(
              padding: EdgeInsets.all(22),
              child: _QrGlyph(),
            ),
          ),
          const Positioned(
            top: 16,
            left: 18,
            child: _FloatingTag(
              icon: Icons.local_hospital_outlined,
              label: 'Hastane',
            ),
          ),
          const Positioned(
            top: 34,
            right: 14,
            child: _FloatingTag(
              icon: Icons.apartment_rounded,
              label: 'Kampüs',
            ),
          ),
          const Positioned(
            bottom: 12,
            left: 34,
            child: _FloatingTag(
              icon: Icons.storefront_outlined,
              label: 'AVM',
            ),
          ),
        ],
      ),
    );
  }
}

class _QrGlyph extends StatelessWidget {
  const _QrGlyph();

  @override
  Widget build(BuildContext context) {
    Widget cell(Color color, {double radius = 10}) {
      return Container(
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(radius),
        ),
      );
    }

    return Stack(
      children: [
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(26),
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFFF7F8FF),
                  Color(0xFFF0F4FF),
                ],
              ),
            ),
          ),
        ),
        Column(
          children: [
            Expanded(
              child: Row(
                children: [
                  Expanded(flex: 3, child: cell(_accent)),
                  const Spacer(),
                  Expanded(flex: 2, child: cell(const Color(0xFFC7D2FE))),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: Row(
                children: [
                  Expanded(flex: 2, child: cell(const Color(0xFFC7D2FE))),
                  const SizedBox(width: 10),
                  Expanded(flex: 3, child: cell(_accent)),
                  const SizedBox(width: 10),
                  Expanded(child: cell(const Color(0xFF22D3EE))),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: Row(
                children: [
                  Expanded(child: cell(const Color(0xFF22D3EE))),
                  const SizedBox(width: 10),
                  Expanded(flex: 2, child: cell(const Color(0xFFC7D2FE))),
                  const SizedBox(width: 10),
                  Expanded(flex: 2, child: cell(_accent)),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _FloatingTag extends StatelessWidget {
  const _FloatingTag({
    required this.icon,
    required this.label,
  });

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: const Color(0x18FFFFFF)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x120F172A),
            blurRadius: 18,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: _accent),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(
              color: _ink,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _MetricPill extends StatelessWidget {
  const _MetricPill({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.82),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: _line),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: _ink,
          fontSize: 12,
          fontWeight: FontWeight.w800,
        ),
      ),
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
            'Manuel seçim',
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
            'Önce kurum seçin. Ardından yerleşke, bina ve kat adımlarıyla doğru haritayı açın.',
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
