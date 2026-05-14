import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../models/facility_models.dart';
import '../../models/graph_data.dart';
import '../../widgets/embedded_scanner.dart';
import 'map_screen_content_card.dart';
import 'map_screen_header.dart';

class MapScreenBody extends StatelessWidget {
  const MapScreenBody({
    super.key,
    required this.hasMap,
    required this.isBusy,
    required this.buildingTitle,
    required this.mapBottomInset,
    required this.activeNodeId,
    required this.displayNodes,
    required this.navigationRoute,
    required this.occupancy,
    required this.mapAssetPath,
    required this.mapAssetContentType,
    required this.mapWidth,
    required this.mapHeight,
    required this.scannerController,
    required this.organizations,
    required this.selectedOrganizationId,
    required this.sites,
    required this.selectedSiteId,
    required this.buildings,
    required this.selectedBuildingId,
    required this.floors,
    required this.selectedFloorId,
    required this.onBack,
    required this.onClearSelectedMap,
    required this.onCollapseSheet,
    required this.onQrDetected,
    required this.onOrganizationChanged,
    required this.onSiteChanged,
    required this.onBuildingChanged,
    required this.onFloorChanged,
  });

  final bool hasMap;
  final bool isBusy;
  final String buildingTitle;
  final double mapBottomInset;
  final String? activeNodeId;
  final List<MapNode> displayNodes;
  final List<MapNode>? navigationRoute;
  final Map<String, bool> occupancy;
  final String? mapAssetPath;
  final String? mapAssetContentType;
  final int? mapWidth;
  final int? mapHeight;
  final MobileScannerController scannerController;
  final List<OrganizationSummary> organizations;
  final String? selectedOrganizationId;
  final List<SiteHierarchy> sites;
  final String? selectedSiteId;
  final List<BuildingHierarchy> buildings;
  final String? selectedBuildingId;
  final List<FloorHierarchy> floors;
  final String? selectedFloorId;
  final VoidCallback onBack;
  final VoidCallback onClearSelectedMap;
  final VoidCallback onCollapseSheet;
  final void Function(BarcodeCapture capture) onQrDetected;
  final ValueChanged<String?> onOrganizationChanged;
  final ValueChanged<String?> onSiteChanged;
  final ValueChanged<String?> onBuildingChanged;
  final ValueChanged<String?> onFloorChanged;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: hasMap ? onCollapseSheet : null,
      child: SafeArea(
        child: Column(
          children: [
            MapScreenHeader(
              title: buildingTitle,
              hasMap: hasMap,
              onBack: onBack,
              onClearSelectedMap: onClearSelectedMap,
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
              child: EmbeddedScanner(
                controller: scannerController,
                onDetect: onQrDetected,
                isLoading: isBusy,
              ),
            ),
            MapScreenContentCard(
              hasMap: hasMap,
              mapBottomInset: mapBottomInset,
              activeNodeId: activeNodeId,
              displayNodes: displayNodes,
              navigationRoute: navigationRoute,
              occupancy: occupancy,
              mapAssetPath: mapAssetPath,
              mapAssetContentType: mapAssetContentType,
              mapWidth: mapWidth,
              mapHeight: mapHeight,
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
            ),
          ],
        ),
      ),
    );
  }
}
