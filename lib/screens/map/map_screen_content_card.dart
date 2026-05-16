import 'package:flutter/material.dart';

import '../../models/facility_models.dart';
import '../../models/graph_data.dart';
import '../../widgets/floor_plan_widget.dart';
import 'map_selection_panel.dart';

class MapScreenContentCard extends StatelessWidget {
  const MapScreenContentCard({
    super.key,
    required this.hasMap,
    required this.mapBottomInset,
    required this.activeNodeId,
    required this.displayNodes,
    required this.navigationRoute,
    required this.occupancy,
    required this.mapAssetPath,
    required this.mapAssetContentType,
    required this.mapWidth,
    required this.mapHeight,
    required this.organizations,
    required this.selectedOrganizationId,
    required this.sites,
    required this.selectedSiteId,
    required this.buildings,
    required this.selectedBuildingId,
    required this.floors,
    required this.selectedFloorId,
    required this.onOrganizationChanged,
    required this.onSiteChanged,
    required this.onBuildingChanged,
    required this.onFloorChanged,
  });

  final bool hasMap;
  final double mapBottomInset;
  final String? activeNodeId;
  final List<MapNode> displayNodes;
  final List<MapNode>? navigationRoute;
  final Map<String, bool> occupancy;
  final String? mapAssetPath;
  final String? mapAssetContentType;
  final int? mapWidth;
  final int? mapHeight;
  final List<OrganizationSummary> organizations;
  final String? selectedOrganizationId;
  final List<SiteHierarchy> sites;
  final String? selectedSiteId;
  final List<BuildingHierarchy> buildings;
  final String? selectedBuildingId;
  final List<FloorHierarchy> floors;
  final String? selectedFloorId;
  final ValueChanged<String?> onOrganizationChanged;
  final ValueChanged<String?> onSiteChanged;
  final ValueChanged<String?> onBuildingChanged;
  final ValueChanged<String?> onFloorChanged;

  @override
  Widget build(BuildContext context) {
    final child = hasMap
        ? FloorPlanWidget(
            key: const ValueKey('floor-plan'),
            visitedIds: const {},
            activeZoneId: activeNodeId,
            navigationRoute: navigationRoute,
            occupancyMap: occupancy,
            nodes: displayNodes,
            mapAssetPath: mapAssetPath,
            mapAssetContentType: mapAssetContentType,
            mapWidth: mapWidth,
            mapHeight: mapHeight,
          )
        : MapSelectionPanel(
            key: const ValueKey('map-selection'),
            organizations: organizations,
            selectedOrganizationId: selectedOrganizationId,
            sites: sites,
            selectedSiteId: selectedSiteId,
            buildings: buildings,
            selectedBuildingId: selectedBuildingId,
            floors: floors,
            selectedFloorId: selectedFloorId,
            onOrganizationChanged: onOrganizationChanged,
            onSiteChanged: onSiteChanged,
            onBuildingChanged: onBuildingChanged,
            onFloorChanged: onFloorChanged,
          );

    return Expanded(
      child: Padding(
        padding: EdgeInsets.fromLTRB(12, 12, 12, mapBottomInset),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(28),
            boxShadow: const [
              BoxShadow(
                color: Color(0x100F172A),
                blurRadius: 24,
                offset: Offset(0, 12),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(28),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 320),
              switchInCurve: Curves.easeOutCubic,
              switchOutCurve: Curves.easeInCubic,
              transitionBuilder: (child, animation) {
                return FadeTransition(
                  opacity: animation,
                  child: ScaleTransition(
                    scale: Tween<double>(
                      begin: 0.985,
                      end: 1,
                    ).animate(animation),
                    child: child,
                  ),
                );
              },
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}
