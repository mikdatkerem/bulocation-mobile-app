import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../models/facility_models.dart';
import '../../models/graph_data.dart';
import '../../widgets/embedded_scanner.dart';
import '../../widgets/floor_plan_widget.dart';
import 'map_selection_panel.dart';

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
            Padding(
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
                      buildingTitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF182033),
                      ),
                    ),
                  ),
                  if (hasMap)
                    IconButton(
                      onPressed: onClearSelectedMap,
                      icon: const Icon(Icons.layers_clear_rounded),
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: const Color(0xFF182033),
                      ),
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
              child: EmbeddedScanner(
                controller: scannerController,
                onDetect: onQrDetected,
                isLoading: isBusy,
              ),
            ),
            Expanded(
              child: Padding(
                padding: EdgeInsets.fromLTRB(12, 12, 12, mapBottomInset),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(28),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(28),
                    child: hasMap
                        ? FloorPlanWidget(
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
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
