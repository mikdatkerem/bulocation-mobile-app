import 'package:flutter/material.dart';

import '../../models/facility_models.dart';
import '../../models/graph_data.dart';
import '../../widgets/floor_plan_widget.dart';
import 'map_screen_notice.dart';
import 'map_screen_notice_overlay.dart';

class MapScreenContentCard extends StatelessWidget {
  const MapScreenContentCard({
    super.key,
    required this.hasMap,
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
    required this.organizations,
    required this.selectedOrganizationId,
    required this.sites,
    required this.selectedSiteId,
    required this.buildings,
    required this.selectedBuildingId,
    required this.floors,
    required this.selectedFloorId,
    required this.routeFloorIds,
    required this.onOrganizationChanged,
    required this.onSiteChanged,
    required this.onBuildingChanged,
    required this.onFloorChanged,
    required this.onDismissNotice,
    required this.onMapNodeSelected,
  });

  final bool hasMap;
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
  final List<OrganizationSummary> organizations;
  final String? selectedOrganizationId;
  final List<SiteHierarchy> sites;
  final String? selectedSiteId;
  final List<BuildingHierarchy> buildings;
  final String? selectedBuildingId;
  final List<FloorHierarchy> floors;
  final String? selectedFloorId;
  final Set<String> routeFloorIds;
  final ValueChanged<String?> onOrganizationChanged;
  final ValueChanged<String?> onSiteChanged;
  final ValueChanged<String?> onBuildingChanged;
  final ValueChanged<String?> onFloorChanged;
  final ValueChanged<int> onDismissNotice;
  final ValueChanged<MapNode> onMapNodeSelected;

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
            onNodeSelected: onMapNodeSelected,
          )
        : const _MapEmptyState(key: ValueKey('map-empty-state'));

    return Expanded(
      child: Padding(
        padding: EdgeInsets.fromLTRB(12, 8, 12, mapBottomInset),
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
            child: Stack(
              children: [
                Positioned.fill(
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
                if (hasMap)
                  Positioned(
                    top: 12,
                    right: 12,
                    child: _MapFloorPicker(
                      floors: floors,
                      selectedFloorId: selectedFloorId,
                      routeFloorIds: routeFloorIds,
                      onFloorChanged: onFloorChanged,
                    ),
                  ),
                if (hasMap)
                  Positioned(
                    top: 54,
                    left: 12,
                    right: 12,
                    child: MapScreenNoticeOverlay(
                      notices: notices,
                      infoTitle: routeStatusTitle,
                      infoMessage: routeStatusMessage,
                      infoScopeKey:
                          '${mapAssetPath ?? ''}|${activeNodeId ?? ''}|${navigationRoute?.length ?? 0}',
                      onDismissNotice: onDismissNotice,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _MapFloorPicker extends StatelessWidget {
  const _MapFloorPicker({
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
    final selectedFloor =
        sortedFloors.where((floor) => floor.id == selectedFloorId).firstOrNull;

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
        height: 42,
        constraints: const BoxConstraints(minWidth: 96, maxWidth: 164),
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.92),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.white.withValues(alpha: 0.74)),
          boxShadow: const [
            BoxShadow(
              color: Color(0x180F172A),
              blurRadius: 18,
              offset: Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 24,
              height: 24,
              alignment: Alignment.center,
              decoration: const BoxDecoration(
                color: Color(0xFFEEF2FF),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.layers_rounded,
                size: 15,
                color: Color(0xFF6366F1),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                selectedFloor?.name ?? 'Kat seç',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Color(0xFF0F172A),
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            const SizedBox(width: 4),
            const Icon(
              Icons.keyboard_arrow_down_rounded,
              size: 18,
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

class _MapEmptyState extends StatelessWidget {
  const _MapEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFFF8FAFF),
            Color(0xFFF3F6FC),
          ],
        ),
      ),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: const Color(0xFFEEF2FF),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: const Icon(
                  Icons.qr_code_scanner_rounded,
                  color: Color(0xFF6366F1),
                  size: 34,
                ),
              ),
              const SizedBox(height: 18),
              const Text(
                'Haritayı QR ile başlatın',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFF0F172A),
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.6,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Manuel seçim ana sayfadaki ikinci ekrana taşındı.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFF64748B),
                  fontSize: 14,
                  height: 1.55,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
