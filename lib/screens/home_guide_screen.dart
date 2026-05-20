import 'dart:math' as math;

import 'package:flutter/material.dart';

part 'home_guide/home_guide_artwork.dart';
part 'home_guide/home_guide_layout.dart';
part 'home_guide/home_guide_models.dart';

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
          'Binanın girişindeki veya bulunduğunuz kattaki QR kodunu okutun. Uygulama haritayı otomatik açsın.',
      cta: 'Devam et',
      accent: Color(0xFF6366F1),
      secondary: Color(0xFF22D3EE),
      type: _GuideArtworkType.qrStart,
      highlights: [
        'QR okut',
        'Konum aç',
        'Katı gör',
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
