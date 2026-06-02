import 'package:flutter/material.dart';

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
