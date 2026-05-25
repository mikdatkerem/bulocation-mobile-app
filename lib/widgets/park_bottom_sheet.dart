import 'dart:ui';

import 'package:flutter/material.dart';

import '../models/graph_data.dart';
import '../services/pathfinding_service.dart';

part 'parking_panel/navigation_actions.dart';
part 'parking_panel/panel_header_route.dart';
part 'parking_panel/panel_presenter.dart';
part 'parking_panel/target_grid.dart';

enum MapPanelMode { parking, hospital, mall, other }

class ParkBottomSheet extends StatefulWidget {
  const ParkBottomSheet({
    super.key,
    this.controller,
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
    required this.onSegmentTap,
    required this.onParkSelected,
    required this.onNavigateToExit,
    required this.onNavigateToCar,
    required this.onClearNav,
    required this.onNearestToUser,
    required this.onNearestToHospital,
    required this.parks,
    required this.destinations,
  });

  static const double peekSize = 0.07;
  static const double mediumSize = 0.36;
  static const double fullSize = 0.82;

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
  final ValueChanged<int> onSegmentTap;
  final void Function(MapNode) onParkSelected;
  final VoidCallback onNavigateToExit;
  final VoidCallback onNavigateToCar;
  final VoidCallback onClearNav;
  final VoidCallback onNearestToUser;
  final VoidCallback onNearestToHospital;
  final List<MapNode> parks;
  final List<MapNode> destinations;
  final DraggableScrollableController? controller;

  @override
  State<ParkBottomSheet> createState() => _ParkBottomSheetState();
}

class _ParkBottomSheetState extends State<ParkBottomSheet> {
  bool _showDestinations = false;
  double _extent = ParkBottomSheet.peekSize;

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).padding.bottom;
    final presenter = _ParkBottomSheetPresenter(
      mode: widget.mode,
      mapName: widget.mapName,
      activeReference: widget.activeReference,
      currentFloorId: widget.currentFloorId,
      currentFloorName: widget.currentFloorName,
      emptyCount: widget.emptyCount,
      fullCount: widget.fullCount,
      totalCount: widget.totalCount,
      parks: widget.parks,
      destinations: widget.destinations,
    );
    final targetGroups = presenter.targetGroupsForPanel();

    if (!presenter.isParking && _showDestinations && targetGroups.isEmpty) {
      _showDestinations = false;
    }

    return NotificationListener<DraggableScrollableNotification>(
      onNotification: (notification) {
        if ((_extent - notification.extent).abs() > 0.004) {
          setState(() => _extent = notification.extent);
        }
        return false;
      },
      child: DraggableScrollableSheet(
        controller: widget.controller,
        expand: false,
        initialChildSize: ParkBottomSheet.peekSize,
        minChildSize: ParkBottomSheet.peekSize,
        maxChildSize: ParkBottomSheet.fullSize,
        snap: true,
        snapSizes: const [
          ParkBottomSheet.peekSize,
          ParkBottomSheet.mediumSize,
          ParkBottomSheet.fullSize,
        ],
        builder: (context, scrollController) {
          final isCollapsed = _extent <= ParkBottomSheet.peekSize + 0.025;

          return ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFFFFFFF).withValues(alpha: 0.96),
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(30)),
                  border: const Border(
                    top: BorderSide(color: Color(0xFFE2E8F0)),
                  ),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x1A0F172A),
                      blurRadius: 28,
                      offset: Offset(0, -12),
                    ),
                  ],
                ),
                child: CustomScrollView(
                  controller: scrollController,
                  physics: const ClampingScrollPhysics(),
                  slivers: [
                    SliverPersistentHeader(
                      pinned: true,
                      delegate: _SheetGrabberHeaderDelegate(),
                    ),
                    SliverPadding(
                      padding: EdgeInsets.fromLTRB(18, 0, 18, bottom + 18),
                      sliver: SliverToBoxAdapter(
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 180),
                          switchInCurve: Curves.easeOutCubic,
                          switchOutCurve: Curves.easeInCubic,
                          child: isCollapsed
                              ? const SizedBox(
                                  key: ValueKey('sheet-collapsed'),
                                  height: 1,
                                )
                              : _SheetExpandedContent(
                                  key: ValueKey(
                                    'sheet-expanded-${widget.mode}-${widget.multiRoute?.segments.length ?? 0}',
                                  ),
                                  presenter: presenter,
                                  targetGroups: targetGroups,
                                  showDestinations: _showDestinations,
                                  activeSegmentIndex: widget.activeSegmentIndex,
                                  mode: widget.mode,
                                  multiRoute: widget.multiRoute,
                                  targetPark: widget.targetPark,
                                  parkedAt: widget.parkedAt,
                                  occupancyMap: widget.occupancyMap,
                                  onSegmentTap: widget.onSegmentTap,
                                  onParkSelected: widget.onParkSelected,
                                  onNavigateToExit: widget.onNavigateToExit,
                                  onNavigateToCar: widget.onNavigateToCar,
                                  onClearNav: widget.onClearNav,
                                  onNearestToUser: widget.onNearestToUser,
                                  onNearestToHospital:
                                      widget.onNearestToHospital,
                                  onNavigationTap: () =>
                                      setState(() => _showDestinations = false),
                                  onDestinationsTap: () =>
                                      setState(() => _showDestinations = true),
                                ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _SheetGrabberHeaderDelegate extends SliverPersistentHeaderDelegate {
  @override
  double get minExtent => 52;

  @override
  double get maxExtent => 52;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(
      color: const Color(0xFFFFFFFF).withValues(alpha: 0.96),
      height: 52,
      child: Center(
        child: Container(
          width: 58,
          height: 6,
          decoration: BoxDecoration(
            color: const Color(0xFFCBD5E1),
            borderRadius: BorderRadius.circular(999),
          ),
        ),
      ),
    );
  }

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) =>
      false;
}

class _SheetExpandedContent extends StatelessWidget {
  const _SheetExpandedContent({
    super.key,
    required this.presenter,
    required this.targetGroups,
    required this.showDestinations,
    required this.activeSegmentIndex,
    required this.mode,
    required this.multiRoute,
    required this.targetPark,
    required this.parkedAt,
    required this.occupancyMap,
    required this.onSegmentTap,
    required this.onParkSelected,
    required this.onNavigateToExit,
    required this.onNavigateToCar,
    required this.onClearNav,
    required this.onNearestToUser,
    required this.onNearestToHospital,
    required this.onNavigationTap,
    required this.onDestinationsTap,
  });

  final _ParkBottomSheetPresenter presenter;
  final List<TargetGroup> targetGroups;
  final bool showDestinations;
  final int activeSegmentIndex;
  final MapPanelMode mode;
  final MultiRouteResult? multiRoute;
  final MapNode? targetPark;
  final MapNode? parkedAt;
  final Map<String, bool> occupancyMap;
  final ValueChanged<int> onSegmentTap;
  final void Function(MapNode) onParkSelected;
  final VoidCallback onNavigateToExit;
  final VoidCallback onNavigateToCar;
  final VoidCallback onClearNav;
  final VoidCallback onNearestToUser;
  final VoidCallback onNearestToHospital;
  final VoidCallback onNavigationTap;
  final VoidCallback onDestinationsTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _PanelHeader(
          icon: presenter.modeIcon,
          mapName: presenter.mapName,
          summary: presenter.summaryText,
          title: presenter.panelTitle,
        ),
        if (multiRoute != null && multiRoute!.segments.length > 1) ...[
          const SizedBox(height: 14),
          _RouteSegments(
            result: multiRoute!,
            activeIndex: activeSegmentIndex,
            onSegmentTap: onSegmentTap,
          ),
        ],
        const SizedBox(height: 16),
        _ModeSwitcher(
          showDestinations: showDestinations,
          destinationLabel: presenter.destinationTitle,
          hasDestinations: targetGroups.isNotEmpty,
          onNavigationTap: onNavigationTap,
          onDestinationsTap: onDestinationsTap,
        ),
        const SizedBox(height: 16),
        if (!showDestinations)
          _NavigationActions(
            mode: mode,
            hasParkedCar: parkedAt != null,
            hasDestinations: targetGroups.isNotEmpty,
            destinationTitle: presenter.destinationTitle,
            onShowDestinations: onDestinationsTap,
            onNearestToUser: onNearestToUser,
            onNearestToHospital: onNearestToHospital,
            onNavigateToCar: parkedAt != null ? onNavigateToCar : null,
            onNavigateToExit: onNavigateToExit,
          )
        else
          _TargetGrid(
            mode: mode,
            groups: targetGroups,
            targetPark: targetPark,
            occupancyMap: occupancyMap,
            onSelected: onParkSelected,
          ),
        if (targetPark != null) ...[
          const SizedBox(height: 12),
          _GhostAction(
            label: 'Rotayı temizle',
            onTap: onClearNav,
          ),
        ],
      ],
    );
  }
}
