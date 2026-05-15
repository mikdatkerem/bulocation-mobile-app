import 'package:flutter/material.dart';

class HomeGuideScreen extends StatefulWidget {
  const HomeGuideScreen({
    super.key,
    required this.onComplete,
  });

  final Future<void> Function() onComplete;

  @override
  State<HomeGuideScreen> createState() => _HomeGuideScreenState();
}

class _HomeGuideScreenState extends State<HomeGuideScreen> {
  final PageController _pageController = PageController();

  int _currentIndex = 0;
  bool _finishing = false;

  static const _slides = [
    _GuideSlideData(
      eyebrow: 'ADIM 1',
      title: 'QR ile\nbaşlayın',
      description:
          'Binanın girişindeki veya bulunduğunuz kattaki QR kodunu okutun. Uygulama doğru haritayı otomatik açsın.',
      cta: 'Devam et',
      accent: Color(0xFF6366F1),
      secondary: Color(0xFF22D3EE),
      type: _GuideArtworkType.qrStart,
    ),
    _GuideSlideData(
      eyebrow: 'ADIM 2',
      title: 'Harita anında\nhazır olsun',
      description:
          'Konumunuz açıldığında kat planı, yönlendirme noktaları ve ilgili bina bilgileri doğrudan ekranda görünür.',
      cta: 'Devam et',
      accent: Color(0xFF4F46E5),
      secondary: Color(0xFF93C5FD),
      type: _GuideArtworkType.mapOpen,
    ),
    _GuideSlideData(
      eyebrow: 'ADIM 3',
      title: 'Hedef seçin,\nyola çıkın',
      description:
          'Otopark, hastane girişi veya içeride gitmek istediğiniz hedefi seçin. Rota size anında çizilsin.',
      cta: 'Başla',
      accent: Color(0xFF6366F1),
      secondary: Color(0xFF22C55E),
      type: _GuideArtworkType.routeGo,
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _handleNext() async {
    if (_finishing) {
      return;
    }

    if (_currentIndex == _slides.length - 1) {
      setState(() => _finishing = true);
      await widget.onComplete();
      return;
    }

    await _pageController.nextPage(
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeOutCubic,
    );
  }

  Future<void> _handleSkip() async {
    if (_finishing) {
      return;
    }
    setState(() => _finishing = true);
    await widget.onComplete();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FD),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(22, 8, 22, 22),
          child: Column(
            children: [
              Row(
                children: [
                  const Spacer(),
                  TextButton(
                    onPressed: _finishing ? null : _handleSkip,
                    child: const Text(
                      'Geç',
                      style: TextStyle(
                        color: Color(0xFF64748B),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: _slides.length,
                  onPageChanged: (value) =>
                      setState(() => _currentIndex = value),
                  itemBuilder: (context, index) {
                    final slide = _slides[index];
                    return _GuideSlide(
                      data: slide,
                      currentIndex: _currentIndex,
                      slideCount: _slides.length,
                    );
                  },
                ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  _slides.length,
                  (index) => AnimatedContainer(
                    duration: const Duration(milliseconds: 220),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: _currentIndex == index ? 24 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: _currentIndex == index
                          ? const Color(0xFF6366F1)
                          : const Color(0xFFD7DEEB),
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _finishing ? null : _handleNext,
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF6366F1),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(22),
                    ),
                  ),
                  child: Text(
                    _finishing ? 'Hazırlanıyor...' : _slides[_currentIndex].cta,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
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

class _GuideSlide extends StatelessWidget {
  const _GuideSlide({
    required this.data,
    required this.currentIndex,
    required this.slideCount,
  });

  final _GuideSlideData data;
  final int currentIndex;
  final int slideCount;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(36),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x140F172A),
                  blurRadius: 36,
                  offset: Offset(0, 18),
                ),
              ],
            ),
            child: Stack(
              children: [
                Positioned(
                  top: -28,
                  right: -12,
                  child: _SoftGlow(
                    size: 170,
                    color: data.accent.withValues(alpha: 0.10),
                  ),
                ),
                Positioned(
                  bottom: 82,
                  left: -18,
                  child: _SoftGlow(
                    size: 130,
                    color: data.secondary.withValues(alpha: 0.14),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 26, 24, 26),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _GuideTopBar(
                          currentIndex: currentIndex, slideCount: slideCount),
                      const SizedBox(height: 28),
                      Expanded(
                        child: Center(
                          child: _GuideArtwork(data: data),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        data.eyebrow,
                        style: TextStyle(
                          color: data.accent,
                          fontSize: 12,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.8,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        data.title,
                        style: const TextStyle(
                          color: Color(0xFF0F172A),
                          fontSize: 34,
                          height: 0.98,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -1.3,
                        ),
                      ),
                      const SizedBox(height: 14),
                      Text(
                        data.description,
                        style: const TextStyle(
                          color: Color(0xFF475569),
                          fontSize: 15,
                          height: 1.65,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _GuideTopBar extends StatelessWidget {
  const _GuideTopBar({
    required this.currentIndex,
    required this.slideCount,
  });

  final int currentIndex;
  final int slideCount;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: const Color(0xFFEEF2FF),
            borderRadius: BorderRadius.circular(14),
          ),
          child: const Icon(
            Icons.place_rounded,
            color: Color(0xFF6366F1),
          ),
        ),
        const SizedBox(width: 12),
        const Expanded(
          child: Text(
            'Bulocation',
            style: TextStyle(
              color: Color(0xFF0F172A),
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        Text(
          '${currentIndex + 1}/$slideCount',
          style: const TextStyle(
            color: Color(0xFF94A3B8),
            fontSize: 12,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}

class _GuideArtwork extends StatelessWidget {
  const _GuideArtwork({required this.data});

  final _GuideSlideData data;

  @override
  Widget build(BuildContext context) {
    switch (data.type) {
      case _GuideArtworkType.qrStart:
        return _QrStartArtwork(data: data);
      case _GuideArtworkType.mapOpen:
        return _MapOpenArtwork(data: data);
      case _GuideArtworkType.routeGo:
        return _RouteGoArtwork(data: data);
    }
  }
}

class _QrStartArtwork extends StatelessWidget {
  const _QrStartArtwork({required this.data});

  final _GuideSlideData data;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 290,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Transform.rotate(
            angle: -0.14,
            child: _TiltedCard(
              width: 178,
              height: 226,
              color: const Color(0xFFF6F8FF),
              borderColor: data.accent.withValues(alpha: 0.20),
            ),
          ),
          Positioned(
            right: 34,
            top: 18,
            child: Transform.rotate(
              angle: 0.08,
              child: _QrMiniCard(data: data),
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
                  width: 108,
                  height: 40,
                  decoration: BoxDecoration(
                    color: data.accent,
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
  const _MapOpenArtwork({required this.data});

  final _GuideSlideData data;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 290,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 260,
            height: 220,
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFF),
              borderRadius: BorderRadius.circular(32),
              border: Border.all(color: data.accent.withValues(alpha: 0.14)),
            ),
            child: CustomPaint(
              painter: _MapPatternPainter(
                accent: data.accent.withValues(alpha: 0.7),
                secondary: data.secondary.withValues(alpha: 0.42),
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
            left: 24,
            top: 46,
            child: _GuideChip(
              icon: Icons.layers_outlined,
              label: 'Doğru kat',
              color: data.accent,
            ),
          ),
        ],
      ),
    );
  }
}

class _RouteGoArtwork extends StatelessWidget {
  const _RouteGoArtwork({required this.data});

  final _GuideSlideData data;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 290,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Transform.rotate(
            angle: 0.04,
            child: Container(
              width: 240,
              height: 210,
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
            top: 38,
            child: _GuideChip(
              icon: Icons.local_parking_rounded,
              label: 'Otopark',
              color: data.accent,
            ),
          ),
          Positioned(
            right: 28,
            bottom: 42,
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
      width: 94,
      height: 112,
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
            width: 36,
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
      width: 176,
      height: 274,
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

class _SoftGlow extends StatelessWidget {
  const _SoftGlow({
    required this.size,
    required this.color,
  });

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
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

enum _GuideArtworkType {
  qrStart,
  mapOpen,
  routeGo,
}

class _GuideSlideData {
  const _GuideSlideData({
    required this.eyebrow,
    required this.title,
    required this.description,
    required this.cta,
    required this.accent,
    required this.secondary,
    required this.type,
  });

  final String eyebrow;
  final String title;
  final String description;
  final String cta;
  final Color accent;
  final Color secondary;
  final _GuideArtworkType type;
}
