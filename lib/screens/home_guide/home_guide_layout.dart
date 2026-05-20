part of '../home_guide_screen.dart';

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
