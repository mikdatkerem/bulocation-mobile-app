part of '../home_guide_screen.dart';

class _GuideArtwork extends StatelessWidget {
  const _GuideArtwork({
    required this.data,
    required this.ambientValue,
  });

  final _GuideSlideData data;
  final double ambientValue;

  @override
  Widget build(BuildContext context) {
    switch (data.type) {
      case _GuideArtworkType.qrStart:
        return _QrStartArtwork(
          data: data,
          ambientValue: ambientValue,
        );
      case _GuideArtworkType.mapOpen:
        return _MapOpenArtwork(
          data: data,
          ambientValue: ambientValue,
        );
      case _GuideArtworkType.routeGo:
        return _RouteGoArtwork(
          data: data,
          ambientValue: ambientValue,
        );
    }
  }
}

class _QrStartArtwork extends StatelessWidget {
  const _QrStartArtwork({
    required this.data,
    required this.ambientValue,
  });

  final _GuideSlideData data;
  final double ambientValue;

  @override
  Widget build(BuildContext context) {
    final floatingShift = math.sin(ambientValue * math.pi) * 10;

    return SizedBox(
      height: 290,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Transform.rotate(
            angle: -0.16,
            child: _TiltedCard(
              width: 182,
              height: 230,
              color: const Color(0xFFF6F8FF),
              borderColor: data.accent.withValues(alpha: 0.16),
            ),
          ),
          Positioned(
            right: 28,
            top: 18 + floatingShift,
            child: Transform.rotate(
              angle: 0.08,
              child: _QrMiniCard(data: data),
            ),
          ),
          Positioned(
            left: 14,
            top: 34 - (floatingShift * 0.5),
            child: _GuideChip(
              icon: Icons.qr_code_rounded,
              label: 'QR hazır',
              color: data.accent,
            ),
          ),
          _PhoneFrame(
            child: Column(
              children: [
                const SizedBox(height: 18),
                const _PhoneBar(),
                const Spacer(),
                _QrCodeBox(accent: data.accent),
                const Spacer(),
                Container(
                  width: 112,
                  height: 40,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [data.accent, data.secondary],
                    ),
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                const SizedBox(height: 18),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MapOpenArtwork extends StatelessWidget {
  const _MapOpenArtwork({
    required this.data,
    required this.ambientValue,
  });

  final _GuideSlideData data;
  final double ambientValue;

  @override
  Widget build(BuildContext context) {
    final chipShift = math.cos(ambientValue * math.pi) * 9;

    return SizedBox(
      height: 290,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 258,
            height: 220,
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFF),
              borderRadius: BorderRadius.circular(32),
              border: Border.all(color: data.accent.withValues(alpha: 0.14)),
            ),
            child: CustomPaint(
              painter: _MapPatternPainter(
                accent: data.accent.withValues(alpha: 0.78),
                secondary: data.secondary.withValues(alpha: 0.46),
              ),
            ),
          ),
          _PhoneFrame(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  const _PhoneBar(),
                  const SizedBox(height: 18),
                  Expanded(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFF),
                        borderRadius: BorderRadius.circular(22),
                      ),
                      child: CustomPaint(
                        painter: _MapPatternPainter(
                          accent: data.accent,
                          secondary: data.secondary,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            left: 22,
            top: 44 + chipShift,
            child: _GuideChip(
              icon: Icons.layers_outlined,
              label: 'Kat planı',
              color: data.accent,
            ),
          ),
          Positioned(
            right: 18,
            bottom: 34 - (chipShift * 0.6),
            child: _GuideChip(
              icon: Icons.info_outline_rounded,
              label: 'Bina bilgisi',
              color: data.secondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _RouteGoArtwork extends StatelessWidget {
  const _RouteGoArtwork({
    required this.data,
    required this.ambientValue,
  });

  final _GuideSlideData data;
  final double ambientValue;

  @override
  Widget build(BuildContext context) {
    final chipShift = math.sin(ambientValue * math.pi) * 10;

    return SizedBox(
      height: 290,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Transform.rotate(
            angle: 0.04,
            child: Container(
              width: 242,
              height: 212,
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFF),
                borderRadius: BorderRadius.circular(34),
                border: Border.all(color: data.accent.withValues(alpha: 0.14)),
              ),
              child: CustomPaint(
                painter: _RoutePainter(
                  accent: data.accent,
                  success: data.secondary,
                ),
              ),
            ),
          ),
          Positioned(
            left: 28,
            top: 40 - chipShift,
            child: _GuideChip(
              icon: Icons.local_parking_rounded,
              label: 'Otopark',
              color: data.accent,
            ),
          ),
          Positioned(
            right: 24,
            bottom: 40 + chipShift,
            child: _GuideChip(
              icon: Icons.route_rounded,
              label: 'Rota hazır',
              color: data.secondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _TiltedCard extends StatelessWidget {
  const _TiltedCard({
    required this.width,
    required this.height,
    required this.color,
    required this.borderColor,
  });

  final double width;
  final double height;
  final Color color;
  final Color borderColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: borderColor),
      ),
    );
  }
}

class _QrMiniCard extends StatelessWidget {
  const _QrMiniCard({required this.data});

  final _GuideSlideData data;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 96,
      height: 116,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: const [
          BoxShadow(
            color: Color(0x120F172A),
            blurRadius: 18,
            offset: Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        children: [
          Expanded(child: _QrCodeBox(accent: data.accent)),
          const SizedBox(height: 10),
          Container(
            width: 38,
            height: 4,
            decoration: BoxDecoration(
              color: const Color(0xFFCBD5E1),
              borderRadius: BorderRadius.circular(999),
            ),
          ),
        ],
      ),
    );
  }
}

class _PhoneFrame extends StatelessWidget {
  const _PhoneFrame({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 178,
      height: 276,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(34),
        border: Border.all(color: const Color(0xFFF1F5F9)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x140F172A),
            blurRadius: 24,
            offset: Offset(0, 16),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _PhoneBar extends StatelessWidget {
  const _PhoneBar();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 64,
      height: 6,
      decoration: BoxDecoration(
        color: const Color(0xFFE2E8F0),
        borderRadius: BorderRadius.circular(999),
      ),
    );
  }
}

class _QrCodeBox extends StatelessWidget {
  const _QrCodeBox({required this.accent});

  final Color accent;

  @override
  Widget build(BuildContext context) {
    Widget square(double size, {Color? color}) {
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: color ?? const Color(0xFF111827),
          borderRadius: BorderRadius.circular(size * 0.18),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFF),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Stack(
        children: [
          GridView.count(
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 5,
            mainAxisSpacing: 4,
            crossAxisSpacing: 4,
            shrinkWrap: true,
            children: [
              square(10),
              square(10),
              square(10, color: accent),
              square(10),
              square(10),
              square(10),
              square(10, color: accent),
              square(10),
              square(10),
              square(10),
              square(10),
              square(10),
              square(10),
              square(10, color: accent),
              square(10),
              square(10, color: accent),
              square(10),
              square(10),
              square(10),
              square(10),
              square(10),
              square(10),
              square(10, color: accent),
              square(10),
              square(10),
            ],
          ),
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                border: Border.all(color: accent.withValues(alpha: 0.35)),
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _GuideChip extends StatelessWidget {
  const _GuideChip({
    required this.icon,
    required this.label,
    required this.color,
  });

  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(999),
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
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFF0F172A),
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _AmbientGlow extends StatelessWidget {
  const _AmbientGlow({
    required this.size,
    required this.color,
    required this.dx,
    required this.dy,
  });

  final double size;
  final Color color;
  final double dx;
  final double dy;

  @override
  Widget build(BuildContext context) {
    return Transform.translate(
      offset: Offset(dx, dy),
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

class _MapPatternPainter extends CustomPainter {
  _MapPatternPainter({
    required this.accent,
    required this.secondary,
  });

  final Color accent;
  final Color secondary;

  @override
  void paint(Canvas canvas, Size size) {
    final outline = Paint()
      ..color = const Color(0xFFCBD5E1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    final route = Paint()
      ..color = accent
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;

    final guide = Paint()
      ..color = secondary
      ..style = PaintingStyle.fill;

    final frame = RRect.fromRectAndRadius(
      Rect.fromLTWH(18, 18, size.width - 36, size.height - 36),
      const Radius.circular(26),
    );
    canvas.drawRRect(frame, outline);

    for (var i = 0; i < 5; i++) {
      final y = 44 + (i * 28.0);
      canvas.drawLine(Offset(34, y), Offset(size.width - 34, y), outline);
    }

    final path = Path()
      ..moveTo(size.width * 0.24, size.height * 0.74)
      ..lineTo(size.width * 0.24, size.height * 0.48)
      ..lineTo(size.width * 0.56, size.height * 0.48)
      ..lineTo(size.width * 0.74, size.height * 0.30);
    canvas.drawPath(path, route);

    canvas.drawCircle(Offset(size.width * 0.24, size.height * 0.74), 7, guide);
    canvas.drawCircle(Offset(size.width * 0.74, size.height * 0.30), 7, guide);
  }

  @override
  bool shouldRepaint(covariant _MapPatternPainter oldDelegate) {
    return oldDelegate.accent != accent || oldDelegate.secondary != secondary;
  }
}

class _RoutePainter extends CustomPainter {
  _RoutePainter({
    required this.accent,
    required this.success,
  });

  final Color accent;
  final Color success;

  @override
  void paint(Canvas canvas, Size size) {
    final lanePaint = Paint()
      ..color = const Color(0xFFE2E8F0)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    for (var i = 0; i < 4; i++) {
      final top = 30 + (i * 36.0);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(26, top, size.width - 52, 26),
          const Radius.circular(12),
        ),
        lanePaint,
      );
    }

    final routePaint = Paint()
      ..color = accent
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final path = Path()
      ..moveTo(54, size.height - 46)
      ..lineTo(size.width * 0.45, size.height - 46)
      ..lineTo(size.width * 0.45, size.height * 0.46)
      ..lineTo(size.width - 54, size.height * 0.46);
    canvas.drawPath(path, routePaint);

    final nodePaint = Paint()..color = success;
    canvas.drawCircle(Offset(54, size.height - 46), 7, nodePaint);
    canvas.drawCircle(
      Offset(size.width - 54, size.height * 0.46),
      7,
      nodePaint,
    );

    final selectedPaint = Paint()
      ..color = accent
      ..style = PaintingStyle.fill;

    const slotWidth = 34.0;
    const slotHeight = 18.0;
    for (var i = 0; i < 6; i++) {
      final x = 40 + ((i % 3) * 54.0);
      final y = 38 + ((i ~/ 3) * 108.0);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(x, y, slotWidth, slotHeight),
          const Radius.circular(6),
        ),
        i == 4 ? selectedPaint : lanePaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _RoutePainter oldDelegate) {
    return oldDelegate.accent != accent || oldDelegate.success != success;
  }
}
