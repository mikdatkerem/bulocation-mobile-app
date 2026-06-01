part of '../park_bottom_sheet.dart';

class _PanelHeader extends StatelessWidget {
  const _PanelHeader({
    required this.icon,
    required this.mapName,
    required this.summary,
    required this.title,
  });

  final IconData icon;
  final String mapName;
  final String summary;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFFEEF2FF),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: const Color(0xFF6366F1), size: 28),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF0F172A),
                    fontWeight: FontWeight.w800,
                    fontSize: 17,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  mapName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF475569),
                    fontWeight: FontWeight.w700,
                    fontSize: 12.5,
                  ),
                ),
                if (summary.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  _HeaderChip(label: summary),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HeaderChip extends StatelessWidget {
  const _HeaderChip({
    required this.label,
  });

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 18,
            height: 18,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              color: Color(0xFFEEF2FF),
              shape: BoxShape.circle,
            ),
            child: const Text(
              'P',
              style: TextStyle(
                color: Color(0xFF6366F1),
                fontSize: 11,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFF334155),
              fontWeight: FontWeight.w700,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}

class _RouteSegments extends StatelessWidget {
  const _RouteSegments({
    required this.result,
    required this.activeIndex,
    required this.onSegmentTap,
  });

  final MultiRouteResult result;
  final int activeIndex;
  final ValueChanged<int> onSegmentTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(
              Icons.route_rounded,
              color: Color(0xFF6366F1),
              size: 17,
            ),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                'Kat geçişleri · ${activeIndex + 1}/${result.segments.length}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Color(0xFF475569),
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.2,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 9),
        SizedBox(
          height: 54,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: result.segments.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              final segment = result.segments[index];
              final active = index == activeIndex;
              final completed = index < activeIndex;
              return InkWell(
                onTap: () => onSegmentTap(index),
                borderRadius: BorderRadius.circular(16),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  width: active ? 172 : 148,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
                  decoration: BoxDecoration(
                    color: active
                        ? const Color(0xFF6366F1)
                        : completed
                            ? const Color(0xFFEFF6FF)
                            : const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: active
                          ? const Color(0xFF6366F1)
                          : const Color(0xFFE2E8F0),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 28,
                        height: 28,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: active
                              ? Colors.white.withValues(alpha: 0.18)
                              : completed
                                  ? const Color(0xFFDBEAFE)
                                  : const Color(0xFFEEF2FF),
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          '${index + 1}',
                          style: TextStyle(
                            color:
                                active ? Colors.white : const Color(0xFF4F46E5),
                            fontSize: 12,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                      const SizedBox(width: 9),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              active
                                  ? 'Açık kat'
                                  : completed
                                      ? 'Geçildi'
                                      : 'Sıradaki',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: active
                                    ? Colors.white.withValues(alpha: 0.82)
                                    : const Color(0xFF64748B),
                                fontSize: 10,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 0.4,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              segment.floorName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: active
                                    ? Colors.white
                                    : const Color(0xFF0F172A),
                                fontSize: 12,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
