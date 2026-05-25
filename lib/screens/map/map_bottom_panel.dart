import 'package:flutter/material.dart';

import '../../models/graph_data.dart';
import '../../services/pathfinding_service.dart';
import '../../widgets/park_bottom_sheet.dart';

class MapBottomPanel extends StatelessWidget {
  const MapBottomPanel({
    super.key,
    required this.controller,
    required this.mode,
    required this.occupancyMap,
    required this.targetPark,
    required this.parkedAt,
    required this.mapName,
    required this.currentFloorId,
    required this.currentFloorName,
    required this.activeReference,
    required this.emptyCount,
    required this.fullCount,
    required this.totalCount,
    required this.multiRoute,
    required this.activeSegmentIndex,
    required this.parks,
    required this.destinations,
    required this.onSegmentTap,
    required this.onParkSelected,
    required this.onNavigateToExit,
    required this.onNavigateToCar,
    required this.onClearNav,
    required this.onNearestToUser,
    required this.onNearestToHospital,
  });

  final DraggableScrollableController controller;
  final MapPanelMode mode;
  final Map<String, bool> occupancyMap;
  final MapNode? targetPark;
  final MapNode? parkedAt;
  final String mapName;
  final String? currentFloorId;
  final String? currentFloorName;
  final String? activeReference;
  final int emptyCount;
  final int fullCount;
  final int totalCount;
  final MultiRouteResult? multiRoute;
  final int activeSegmentIndex;
  final List<MapNode> parks;
  final List<MapNode> destinations;
  final ValueChanged<int> onSegmentTap;
  final ValueChanged<MapNode> onParkSelected;
  final VoidCallback onNavigateToExit;
  final VoidCallback onNavigateToCar;
  final VoidCallback onClearNav;
  final VoidCallback onNearestToUser;
  final VoidCallback onNearestToHospital;

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: ParkBottomSheet(
        controller: controller,
        mode: mode,
        occupancyMap: occupancyMap,
        targetPark: targetPark,
        parkedAt: parkedAt,
        mapName: mapName,
        currentFloorId: currentFloorId,
        currentFloorName: currentFloorName,
        activeReference: activeReference,
        emptyCount: emptyCount,
        fullCount: fullCount,
        totalCount: totalCount,
        multiRoute: multiRoute,
        activeSegmentIndex: activeSegmentIndex,
        onSegmentTap: onSegmentTap,
        onParkSelected: onParkSelected,
        onNavigateToExit: onNavigateToExit,
        onNavigateToCar: onNavigateToCar,
        onClearNav: onClearNav,
        onNearestToUser: onNearestToUser,
        onNearestToHospital: onNearestToHospital,
        parks: parks,
        destinations: destinations,
      ),
    );
  }
}
