part of '../park_bottom_sheet.dart';

class _TargetGrid extends StatelessWidget {
  const _TargetGrid({
    required this.isParking,
    required this.targets,
    required this.targetPark,
    required this.occupancyMap,
    required this.onSelected,
  });

  final bool isParking;
  final List<MapNode> targets;
  final MapNode? targetPark;
  final Map<String, bool> occupancyMap;
  final void Function(MapNode) onSelected;

  @override
  Widget build(BuildContext context) {
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
      itemBuilder: (context, index) {
        final target = targets[index];
        final targetKey =
            (target.externalReferenceId ?? target.id).toUpperCase();
        final isOccupied = occupancyMap[targetKey];
        final isTarget = targetPark?.id == target.id;
        final isParkTarget = isParking && target.isPark;

        return InkWell(
          onTap: () => onSelected(target),
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            decoration: BoxDecoration(
              color:
                  isTarget ? const Color(0xFF6366F1) : const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isTarget
                    ? const Color(0xFF6366F1)
                    : const Color(0xFFE2E8F0),
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  target.label,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: isTarget
                        ? const Color(0xFFFFFFFF)
                        : const Color(0xFF0F172A),
                    fontWeight: FontWeight.w800,
                    fontSize: target.label.length > 10 ? 11 : 13,
                  ),
                ),
                const SizedBox(height: 6),
                if (isParkTarget)
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: _spotColor(isOccupied, isTarget),
                      shape: BoxShape.circle,
                    ),
                  )
                else
                  Icon(
                    _iconForNode(target),
                    size: 16,
                    color: isTarget
                        ? const Color(0xFFFFFFFF)
                        : const Color(0xFF64748B),
                  ),
              ],
            ),
          ),
        );
      },
    );
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
