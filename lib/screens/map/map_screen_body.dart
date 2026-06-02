import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../models/facility_models.dart';
import '../../models/graph_data.dart';
import '../../widgets/embedded_scanner.dart';
import 'map_screen_content_card.dart';
import 'map_screen_header.dart';
import 'map_screen_notice.dart';

class MapScreenBody extends StatelessWidget {
  const MapScreenBody({
    super.key,
    required this.hasMap,
    required this.isBusy,
    required this.showActivityOverlay,
    required this.activityTitle,
    required this.activityMessage,
    required this.buildingTitle,
    required this.routeStatusTitle,
    required this.routeStatusMessage,
    required this.mapBottomInset,
    required this.activeNodeId,
    required this.displayNodes,
    required this.navigationRoute,
    required this.occupancy,
    required this.mapAssetPath,
    required this.mapAssetContentType,
    required this.mapWidth,
    required this.mapHeight,
    required this.notices,
    required this.scannerController,
    required this.organizations,
    required this.selectedOrganizationId,
    required this.sites,
    required this.selectedSiteId,
    required this.buildings,
    required this.selectedBuildingId,
    required this.floors,
    required this.selectedFloorId,
    required this.routeFloorIds,
    required this.onBack,
    required this.onDismissNotice,
    required this.onCollapseSheet,
    required this.onQrDetected,
    required this.onOrganizationChanged,
    required this.onSiteChanged,
    required this.onBuildingChanged,
    required this.onFloorChanged,
    required this.onMapFloorChanged,
    required this.onMapNodeSelected,
  });

  final bool hasMap;
  final bool isBusy;
  final bool showActivityOverlay;
  final String? activityTitle;
  final String? activityMessage;
  final String buildingTitle;
  final String? routeStatusTitle;
  final String? routeStatusMessage;
  final double mapBottomInset;
  final String? activeNodeId;
  final List<MapNode> displayNodes;
  final List<MapNode>? navigationRoute;
  final Map<String, bool> occupancy;
  final String? mapAssetPath;
  final String? mapAssetContentType;
  final int? mapWidth;
  final int? mapHeight;
  final List<MapScreenNotice> notices;
  final MobileScannerController scannerController;
  final List<OrganizationSummary> organizations;
  final String? selectedOrganizationId;
  final List<SiteHierarchy> sites;
  final String? selectedSiteId;
  final List<BuildingHierarchy> buildings;
  final String? selectedBuildingId;
  final List<FloorHierarchy> floors;
  final String? selectedFloorId;
  final Set<String> routeFloorIds;
  final VoidCallback onBack;
  final ValueChanged<int> onDismissNotice;
  final VoidCallback onCollapseSheet;
  final void Function(BarcodeCapture capture) onQrDetected;
  final ValueChanged<String?> onOrganizationChanged;
  final ValueChanged<String?> onSiteChanged;
  final ValueChanged<String?> onBuildingChanged;
  final ValueChanged<String?> onFloorChanged;
  final ValueChanged<String?> onMapFloorChanged;
  final ValueChanged<MapNode> onMapNodeSelected;

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
                  floors: floors,
                  selectedFloorId: selectedFloorId,
                  routeFloorIds: routeFloorIds,
                  onBack: onBack,
                  onFloorChanged: onMapFloorChanged,
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 6, 20, 0),
                  child: EmbeddedScanner(
                    controller: scannerController,
                    onDetect: onQrDetected,
                    isLoading: isBusy,
                  ),
                ),
                _FloorContextStrip(
                  hasMap: hasMap,
                  floors: floors,
                  selectedFloorId: selectedFloorId,
                  routeFloorIds: routeFloorIds,
                ),
                MapScreenContentCard(
                  hasMap: hasMap,
                  routeStatusTitle:
                      showActivityOverlay ? null : routeStatusTitle,
                  routeStatusMessage:
                      showActivityOverlay ? null : routeStatusMessage,
                  mapBottomInset: mapBottomInset,
                  activeNodeId: activeNodeId,
                  displayNodes: displayNodes,
                  navigationRoute: navigationRoute,
                  occupancy: occupancy,
                  mapAssetPath: mapAssetPath,
                  mapAssetContentType: mapAssetContentType,
                  mapWidth: mapWidth,
                  mapHeight: mapHeight,
                  notices: notices,
                  onDismissNotice: onDismissNotice,
                  onMapNodeSelected: onMapNodeSelected,
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

class _FloorContextStrip extends StatelessWidget {
  const _FloorContextStrip({
    required this.hasMap,
    required this.floors,
    required this.selectedFloorId,
    required this.routeFloorIds,
  });

  final bool hasMap;
  final List<FloorHierarchy> floors;
  final String? selectedFloorId;
  final Set<String> routeFloorIds;

  @override
  Widget build(BuildContext context) {
    if (!hasMap || selectedFloorId == null) {
      return const SizedBox(height: 8);
    }

    final selectedFloor =
        floors.where((floor) => floor.id == selectedFloorId).firstOrNull;
    if (selectedFloor == null) {
      return const SizedBox(height: 8);
    }

    final isRouteFloor = routeFloorIds.contains(selectedFloor.id);
    return Padding(
      padding: const EdgeInsets.fromLTRB(22, 8, 22, 0),
      child: Container(
        height: 42,
        padding: const EdgeInsets.symmetric(horizontal: 13),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.96),
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(18),
            bottom: Radius.circular(10),
          ),
          border: Border.all(color: const Color(0xFFE2E8F0)),
          boxShadow: const [
            BoxShadow(
              color: Color(0x0F0F172A),
              blurRadius: 16,
              offset: Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 28,
              height: 28,
              alignment: Alignment.center,
              decoration: const BoxDecoration(
                color: Color(0xFFEEF2FF),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.layers_rounded,
                color: Color(0xFF6366F1),
                size: 16,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                selectedFloor.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Color(0xFF0F172A),
                  fontSize: 13,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            if (routeFloorIds.isNotEmpty)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
                decoration: BoxDecoration(
                  color: isRouteFloor
                      ? const Color(0xFFEEF2FF)
                      : const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(
                    color: isRouteFloor
                        ? const Color(0xFFC7D2FE)
                        : const Color(0xFFE2E8F0),
                  ),
                ),
                child: Text(
                  isRouteFloor ? 'Rota üzerinde' : 'Rotanın dışında',
                  style: TextStyle(
                    color: isRouteFloor
                        ? const Color(0xFF4F46E5)
                        : const Color(0xFF64748B),
                    fontSize: 10.5,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
