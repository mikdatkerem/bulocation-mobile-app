import 'package:flutter/material.dart';

import '../../models/facility_models.dart';
import '../../models/graph_data.dart';

class MapFloorPicker extends StatelessWidget {
  const MapFloorPicker({
    super.key,
    required this.floors,
    required this.selectedFloorId,
    required this.routeFloorIds,
    required this.onFloorChanged,
  });

  final List<FloorHierarchy> floors;
  final String? selectedFloorId;
  final Set<String> routeFloorIds;
  final ValueChanged<String?> onFloorChanged;

  @override
  Widget build(BuildContext context) {
    if (floors.length <= 1) {
      return const SizedBox.shrink();
    }

    final sortedFloors = [...floors]..sort((left, right) {
        final levelCompare = left.level.compareTo(right.level);
        if (levelCompare != 0) {
          return levelCompare;
        }
        return compareNodeLabelsNatural(left.name, right.name);
      });
    return PopupMenuButton<String>(
      elevation: 16,
      offset: const Offset(0, 10),
      color: Colors.white,
      surfaceTintColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      onSelected: onFloorChanged,
      itemBuilder: (context) => [
        for (final floor in sortedFloors)
          PopupMenuItem<String>(
            value: floor.id,
            child: _FloorPickerMenuItem(
              floor: floor,
              selected: floor.id == selectedFloorId,
              onRoute: routeFloorIds.contains(floor.id),
            ),
          ),
      ],
      child: Container(
        height: 40,
        width: 48,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFFE2E8F0)),
          boxShadow: const [
            BoxShadow(
              color: Color(0x100F172A),
              blurRadius: 14,
              offset: Offset(0, 7),
            ),
          ],
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.max,
          children: [
            Icon(
              Icons.layers_rounded,
              size: 18,
              color: Color(0xFF6366F1),
            ),
            SizedBox(width: 2),
            Icon(
              Icons.keyboard_arrow_down_rounded,
              size: 15,
              color: Color(0xFF64748B),
            ),
          ],
        ),
      ),
    );
  }
}

class _FloorPickerMenuItem extends StatelessWidget {
  const _FloorPickerMenuItem({
    required this.floor,
    required this.selected,
    required this.onRoute,
  });

  final FloorHierarchy floor;
  final bool selected;
  final bool onRoute;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 220,
      child: Row(
        children: [
          Container(
            width: 30,
            height: 30,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color:
                  selected ? const Color(0xFF6366F1) : const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              selected ? Icons.check_rounded : Icons.layers_rounded,
              size: 17,
              color: selected ? Colors.white : const Color(0xFF64748B),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  floor.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF0F172A),
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                Text(
                  onRoute ? 'Rota üzerinde' : 'Haritayı göster',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: onRoute
                        ? const Color(0xFF6366F1)
                        : const Color(0xFF64748B),
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
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
