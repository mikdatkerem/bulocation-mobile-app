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
    required this.showActivityOverlay,
    required this.activityTitle,
    required this.activityMessage,
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
  final bool showActivityOverlay;
  final String? activityTitle;
  final String? activityMessage;
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
        child: Stack(
          children: [
            Column(
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
            if (showActivityOverlay)
              Positioned.fill(
                child: IgnorePointer(
                  ignoring: true,
                  child: AnimatedOpacity(
                    duration: const Duration(milliseconds: 180),
                    opacity: 1,
                    child: Container(
                      color: const Color(0x66F8FAFC),
                      alignment: Alignment.center,
                      child: Container(
                        constraints: const BoxConstraints(maxWidth: 320),
                        margin: const EdgeInsets.symmetric(horizontal: 24),
                        padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.96),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x140F172A),
                              blurRadius: 28,
                              offset: Offset(0, 16),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: const Color(0xFFEEF2FF),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: const Padding(
                                padding: EdgeInsets.all(10),
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.4,
                                  valueColor: AlwaysStoppedAnimation(
                                    Color(0xFF6366F1),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    activityTitle ?? 'Harita hazırlanıyor',
                                    style: const TextStyle(
                                      color: Color(0xFF0F172A),
                                      fontSize: 16,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    activityMessage ??
                                        'Lütfen kısa bir süre bekleyin.',
                                    style: const TextStyle(
                                      color: Color(0xFF64748B),
                                      fontSize: 13,
                                      height: 1.45,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
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
