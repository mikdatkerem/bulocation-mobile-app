import 'dart:math' as math;

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

class _HomeGuideScreenState extends State<HomeGuideScreen>
    with TickerProviderStateMixin {
  final PageController _pageController = PageController();

  late final AnimationController _ambientController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 4200),
  )..repeat(reverse: true);

  int _currentIndex = 0;
  bool _finishing = false;

  static const _slides = [
    _GuideSlideData(
      stepLabel: 'ADIM 1',
      title: 'QR ile başlayın',
      headline: 'Harita girişte açılsın.',
      description:
          'Binanın girişindeki veya bulunduğunuz kattaki QR kodunu okutun. Uygulama doğru haritayı otomatik açsın.',
      cta: 'Devam et',
      accent: Color(0xFF6366F1),
      secondary: Color(0xFF22D3EE),
      type: _GuideArtworkType.qrStart,
      highlights: [
        'QR okut',
        'Konum aç',
        'Doğru kat',
      ],
    ),
    _GuideSlideData(
      stepLabel: 'ADIM 2',
      title: 'Harita anında hazır',
      headline: 'Kat planını hemen görün.',
      description:
          'Konum açıldığında kat planı, yönlendirme noktaları ve ilgili bina bilgileri doğrudan ekranda görünür.',
      cta: 'Devam et',
      accent: Color(0xFF4F46E5),
      secondary: Color(0xFF93C5FD),
      type: _GuideArtworkType.mapOpen,
      highlights: [
        'Kat planı',
        'Konum noktası',
        'Hazır bilgiler',
      ],
    ),
    _GuideSlideData(
      stepLabel: 'ADIM 3',
      title: 'Hedef seçip yola çıkın',
      headline: 'Rota anında çizilsin.',
      description:
          'Otopark, hastane girişi veya içeride gitmek istediğiniz hedefi seçin. Yönlendirme size anında hazırlansın.',
      cta: 'Başla',
      accent: Color(0xFF6366F1),
      secondary: Color(0xFF22C55E),
      type: _GuideArtworkType.routeGo,
      highlights: [
        'Hedef seç',
        'Rota oluştur',
        'Takip et',
      ],
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    _ambientController.dispose();
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
      duration: const Duration(milliseconds: 360),
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
    final currentSlide = _slides[_currentIndex];

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FC),
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFF8FAFF),
              Color(0xFFF2F6FC),
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 6, 20, 22),
            child: Column(
              children: [
                _GuideHeader(
                  currentIndex: _currentIndex,
                  slideCount: _slides.length,
                  onSkip: _finishing ? null : _handleSkip,
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: AnimatedBuilder(
                    animation: _ambientController,
                    builder: (context, _) => Stack(
                      children: [
                        Positioned(
                          top: 36,
                          left: -18,
                          child: _AmbientGlow(
                            size: 180,
                            color: currentSlide.accent.withValues(alpha: 0.10),
                            dx: -12,
                            dy: 18 * _ambientController.value,
                          ),
                        ),
                        Positioned(
                          top: 210,
                          right: -26,
                          child: _AmbientGlow(
                            size: 170,
                            color:
                                currentSlide.secondary.withValues(alpha: 0.12),
                            dx: 10,
                            dy: -14 * _ambientController.value,
                          ),
                        ),
                        PageView.builder(
                          controller: _pageController,
                          itemCount: _slides.length,
                          onPageChanged: (value) =>
                              setState(() => _currentIndex = value),
                          itemBuilder: (context, index) {
                            final slide = _slides[index];
                            return _GuideSlide(
                              key: ValueKey(slide.title),
                              data: slide,
                              isActive: index == _currentIndex,
                              ambientValue: _ambientController.value,
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                _GuideFooter(
                  currentIndex: _currentIndex,
                  slideCount: _slides.length,
                  cta: _finishing ? 'Hazırlanıyor...' : currentSlide.cta,
                  onNext: _finishing ? null : _handleNext,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _GuideHeader extends StatelessWidget {
  const _GuideHeader({
    required this.currentIndex,
    required this.slideCount,
    required this.onSkip,
  });

  final int currentIndex;
  final int slideCount;
  final VoidCallback? onSkip;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.78),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: const Color(0x14FFFFFF)),
            boxShadow: const [
              BoxShadow(
                color: Color(0x100F172A),
                blurRadius: 16,
                offset: Offset(0, 10),
              ),
            ],
          ),
          child: const Row(
            children: [
              Icon(
                Icons.place_rounded,
                color: Color(0xFF6366F1),
                size: 18,
              ),
              SizedBox(width: 8),
              Text(
                'Bulocation',
                style: TextStyle(
                  color: Color(0xFF0F172A),
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
        const Spacer(),
        Text(
          '${currentIndex + 1}/$slideCount',
          style: const TextStyle(
            color: Color(0xFF94A3B8),
            fontSize: 12,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(width: 8),
        TextButton(
          onPressed: onSkip,
          child: const Text(
            'Geç',
            style: TextStyle(
              color: Color(0xFF64748B),
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}

class _GuideSlide extends StatelessWidget {
  const _GuideSlide({
    super.key,
    required this.data,
    required this.isActive,
    required this.ambientValue,
  });

  final _GuideSlideData data;
  final bool isActive;
  final double ambientValue;

  @override
  Widget build(BuildContext context) {
    final artworkOffset =
        isActive ? (math.sin(ambientValue * math.pi) * 8) : 0.0;

    return AnimatedOpacity(
      duration: const Duration(milliseconds: 260),
      opacity: isActive ? 1 : 0.78,
      child: Padding(
        padding: const EdgeInsets.only(top: 8, bottom: 4),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.94),
            borderRadius: BorderRadius.circular(36),
            boxShadow: const [
              BoxShadow(
                color: Color(0x120F172A),
                blurRadius: 32,
                offset: Offset(0, 18),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(22, 24, 22, 22),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data.stepLabel,
                  style: TextStyle(
                    color: data.accent,
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.8,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  data.title,
                  style: const TextStyle(
                    color: Color(0xFF0F172A),
                    fontSize: 30,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -1.0,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  data.headline,
                  style: TextStyle(
                    color: data.accent,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  data.description,
                  style: const TextStyle(
                    color: Color(0xFF475569),
                    fontSize: 14.5,
                    height: 1.65,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 18),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: data.highlights
                      .map(
                        (item) => _GuidePill(
                          label: item,
                          accent: data.accent,
                        ),
                      )
                      .toList(),
                ),
                const SizedBox(height: 14),
                Expanded(
                  child: Center(
                    child: Transform.translate(
                      offset: Offset(0, artworkOffset),
                      child: _GuideArtwork(
                        data: data,
                        ambientValue: ambientValue,
                      ),
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

class _GuidePill extends StatelessWidget {
  const _GuidePill({
    required this.label,
    required this.accent,
  });

  final String label;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: accent,
          fontSize: 12,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _GuideFooter extends StatelessWidget {
  const _GuideFooter({
    required this.currentIndex,
    required this.slideCount,
    required this.cta,
    required this.onNext,
  });

  final int currentIndex;
  final int slideCount;
  final String cta;
  final VoidCallback? onNext;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Row(
            children: List.generate(
              slideCount,
              (index) => AnimatedContainer(
                duration: const Duration(milliseconds: 240),
                margin: const EdgeInsets.only(right: 7),
                width: currentIndex == index ? 28 : 8,
                height: 8,
                decoration: BoxDecoration(
                  color: currentIndex == index
                      ? const Color(0xFF6366F1)
                      : const Color(0xFFD9E1EE),
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          flex: 2,
          child: FilledButton(
            onPressed: onNext,
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFF6366F1),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 18),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(22),
              ),
              elevation: 0,
            ),
            child: Text(
              cta,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

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
              label: 'Doğru kat',
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
        Offset(size.width - 54, size.height * 0.46), 7, nodePaint);

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
    required this.stepLabel,
    required this.title,
    required this.headline,
    required this.description,
    required this.cta,
    required this.accent,
    required this.secondary,
    required this.type,
    required this.highlights,
  });

  final String stepLabel;
  final String title;
  final String headline;
  final String description;
  final String cta;
  final Color accent;
  final Color secondary;
  final _GuideArtworkType type;
  final List<String> highlights;
}
