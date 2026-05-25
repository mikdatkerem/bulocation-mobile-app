part of '../park_bottom_sheet.dart';

class _TargetGrid extends StatelessWidget {
  const _TargetGrid({
    required this.mode,
    required this.groups,
    required this.targetPark,
    required this.occupancyMap,
    required this.onSelected,
  });

  final MapPanelMode mode;
  final List<TargetGroup> groups;
  final MapNode? targetPark;
  final Map<String, bool> occupancyMap;
  final void Function(MapNode) onSelected;

  bool get _isParking => mode == MapPanelMode.parking;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final group in groups) ...[
          _TargetGroupHeader(group: group),
          const SizedBox(height: 10),
          _buildGrid(group.nodes),
          const SizedBox(height: 18),
        ],
      ],
    );
  }

  Widget _buildGrid(List<MapNode> targets) {
    if (_isParking) {
      return GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          childAspectRatio: 1.15,
        ),
        itemCount: targets.length,
        itemBuilder: (context, index) => _buildParkingCard(targets[index]),
      );
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: mode == MapPanelMode.hospital ? 1.7 : 1.78,
      ),
      itemCount: targets.length,
      itemBuilder: (context, index) => _buildFacilityCard(targets[index]),
    );
  }

  Widget _buildParkingCard(MapNode target) {
    final isOccupied = target.occupancyFrom(occupancyMap);
    final isTarget = targetPark?.id == target.id;
    final label = target.displayLabel;

    return InkWell(
      onTap: () => onSelected(target),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6),
        decoration: BoxDecoration(
          color: isTarget ? const Color(0xFF6366F1) : const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isTarget ? const Color(0xFF6366F1) : const Color(0xFFE2E8F0),
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              label,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: isTarget
                    ? const Color(0xFFFFFFFF)
                    : const Color(0xFF0F172A),
                fontWeight: FontWeight.w800,
                fontSize: label.length > 10 ? 11 : 13,
              ),
            ),
            const SizedBox(height: 6),
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: _spotColor(isOccupied, isTarget),
                shape: BoxShape.circle,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFacilityCard(MapNode target) {
    final isTarget = targetPark?.id == target.id;
    final label = target.displayLabel;

    return InkWell(
      onTap: () => onSelected(target),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isTarget ? const Color(0xFF6366F1) : const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isTarget ? const Color(0xFF6366F1) : const Color(0xFFE2E8F0),
          ),
          boxShadow: isTarget
              ? const [
                  BoxShadow(
                    color: Color(0x1D6366F1),
                    blurRadius: 18,
                    offset: Offset(0, 10),
                  ),
                ]
              : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: isTarget
                        ? Colors.white.withValues(alpha: 0.18)
                        : _iconSurfaceColor(target),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    _iconForNode(target),
                    size: 20,
                    color:
                        isTarget ? const Color(0xFFFFFFFF) : _iconColor(target),
                  ),
                ),
                const Spacer(),
                if (_badgeLabel(target) case final badge?)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                    decoration: BoxDecoration(
                      color: isTarget
                          ? Colors.white.withValues(alpha: 0.18)
                          : const Color(0xFFEEF2FF),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      badge,
                      style: TextStyle(
                        color: isTarget
                            ? const Color(0xFFFFFFFF)
                            : const Color(0xFF4F46E5),
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.4,
                      ),
                    ),
                  ),
              ],
            ),
            const Spacer(),
            Text(
              label,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: isTarget
                    ? const Color(0xFFFFFFFF)
                    : const Color(0xFF0F172A),
                fontWeight: FontWeight.w800,
                fontSize: 15,
                height: 1.16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String? _badgeLabel(MapNode node) {
    return switch (node.type) {
      NodeType.entrance => 'BİNA',
      NodeType.exit => 'BİNA',
      NodeType.elevator => 'ASANSÖR',
      NodeType.stair => 'MERDİVEN',
      NodeType.parkingEntrance => 'ARAÇ GİRİŞ',
      NodeType.parkingExit => 'ARAÇ ÇIKIŞ',
      NodeType.qr => null,
      NodeType.park => mode == MapPanelMode.mall ? 'PARK' : null,
      NodeType.other => null,
    };
  }

  Color _spotColor(bool? isOccupied, bool isTarget) {
    if (isTarget) {
      return const Color(0xFFFFFFFF);
    }
    if (isOccupied == null) {
      return const Color(0xFFB5BECE);
    }
    return isOccupied ? const Color(0xFFE25757) : const Color(0xFF1C9B67);
  }

  Color _iconSurfaceColor(MapNode node) {
    return switch (node.type) {
      NodeType.entrance => const Color(0xFFE0F2FE),
      NodeType.exit => const Color(0xFFFFE4E6),
      NodeType.elevator => const Color(0xFFEEF2FF),
      NodeType.stair => const Color(0xFFF3E8FF),
      NodeType.parkingEntrance => const Color(0xFFDCFCE7),
      NodeType.parkingExit => const Color(0xFFFFEDD5),
      NodeType.qr => const Color(0xFFEEF2FF),
      NodeType.park => const Color(0xFFEEF2FF),
      NodeType.other => const Color(0xFFF1F5F9),
    };
  }

  Color _iconColor(MapNode node) {
    return switch (node.type) {
      NodeType.entrance => const Color(0xFF0284C7),
      NodeType.exit => const Color(0xFFE11D48),
      NodeType.elevator => const Color(0xFF4F46E5),
      NodeType.stair => const Color(0xFF9333EA),
      NodeType.parkingEntrance => const Color(0xFF16A34A),
      NodeType.parkingExit => const Color(0xFFEA580C),
      NodeType.qr => const Color(0xFF4F46E5),
      NodeType.park => const Color(0xFF4F46E5),
      NodeType.other => const Color(0xFF475569),
    };
  }

  IconData _iconForNode(MapNode node) {
    return switch (node.type) {
      NodeType.entrance => Icons.login_rounded,
      NodeType.exit => Icons.logout_rounded,
      NodeType.elevator => Icons.elevator_rounded,
      NodeType.stair => Icons.stairs_rounded,
      NodeType.parkingEntrance => Icons.local_parking_rounded,
      NodeType.parkingExit => Icons.exit_to_app_rounded,
      NodeType.park => Icons.local_parking_rounded,
      NodeType.qr => Icons.qr_code_2_rounded,
      NodeType.other => Icons.place_rounded,
    };
  }
}

class _TargetGroupHeader extends StatelessWidget {
  const _TargetGroupHeader({required this.group});

  final TargetGroup group;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            group.isCurrentFloor ? '${group.title} · açık harita' : group.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Color(0xFF475569),
              fontSize: 12,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.7,
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
          decoration: BoxDecoration(
            color: group.isCurrentFloor
                ? const Color(0xFFEEF2FF)
                : const Color(0xFFF1F5F9),
            borderRadius: BorderRadius.circular(999),
          ),
          child: Text(
            '${group.nodes.length}',
            style: TextStyle(
              color: group.isCurrentFloor
                  ? const Color(0xFF4F46E5)
                  : const Color(0xFF64748B),
              fontSize: 11,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
      ],
    );
  }
}
