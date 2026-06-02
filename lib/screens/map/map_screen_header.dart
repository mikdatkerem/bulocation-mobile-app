import 'package:flutter/material.dart';

import '../../models/facility_models.dart';
import 'map_floor_picker.dart';

class MapScreenHeader extends StatelessWidget {
  const MapScreenHeader({
    super.key,
    required this.title,
    required this.floors,
    required this.selectedFloorId,
    required this.routeFloorIds,
    required this.onBack,
    required this.onFloorChanged,
  });

  final String title;
  final List<FloorHierarchy> floors;
  final String? selectedFloorId;
  final Set<String> routeFloorIds;
  final VoidCallback onBack;
  final ValueChanged<String?> onFloorChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 10, 16, 0),
      child: Row(
        children: [
          IconButton(
            onPressed: onBack,
            icon: const Icon(Icons.arrow_back_ios_new_rounded),
            style: IconButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: const Color(0xFF182033),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Color(0xFF182033),
              ),
            ),
          ),
          const SizedBox(width: 10),
          MapFloorPicker(
            floors: floors,
            selectedFloorId: selectedFloorId,
            routeFloorIds: routeFloorIds,
            onFloorChanged: onFloorChanged,
          ),
        ],
      ),
    );
  }
}
