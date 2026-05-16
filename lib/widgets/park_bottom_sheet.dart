import 'dart:ui';

import 'package:flutter/material.dart';

import '../models/graph_data.dart';
import '../services/pathfinding_service.dart';

part 'parking_panel/navigation_actions.dart';
part 'parking_panel/panel_header_route.dart';
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

  static const double peekSize = 0.08;
  static const double mediumSize = 0.32;
  static const double fullSize = 0.76;

  final MapPanelMode mode;
  final Map<String, bool> occupancyMap;
  final MapNode? targetPark;
  final MapNode? parkedAt;
  final String mapName;
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

  bool get _isParking => widget.mode == MapPanelMode.parking;

  String get _panelTitle {
    return switch (widget.mode) {
      MapPanelMode.parking => 'Rota ve park alanları',
      MapPanelMode.hospital => 'Hastane hedefleri',
      MapPanelMode.mall => 'AVM hedefleri',
      MapPanelMode.other => 'Navigasyon hedefleri',
    };
  }

  String get _destinationTitle {
    return switch (widget.mode) {
      MapPanelMode.parking =>
        widget.destinations.isNotEmpty ? 'Hedefler' : 'Park Alanları',
      MapPanelMode.hospital => 'Bölümler',
      MapPanelMode.mall => 'Mağazalar',
      MapPanelMode.other => 'Noktalar',
    };
  }

  String get _summaryText {
    if (_isParking) {
      return '${widget.emptyCount} BOS - ${widget.fullCount} DOLU - ${widget.totalCount} TOPLAM';
    }

    final active = widget.activeReference ?? 'QR bekleniyor';
    return '${widget.destinations.length} hedef · başlangıç $active';
  }

  IconData get _modeIcon {
    return switch (widget.mode) {
      MapPanelMode.parking => Icons.local_parking_rounded,
      MapPanelMode.hospital => Icons.local_hospital_rounded,
      MapPanelMode.mall => Icons.store_mall_directory_rounded,
      MapPanelMode.other => Icons.navigation_rounded,
    };
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).padding.bottom;
    final targets = _targetsForPanel();

    if (!_isParking && _showDestinations && targets.isEmpty) {
      _showDestinations = false;
    }

    return DraggableScrollableSheet(
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
              child: Stack(
                children: [
                  Positioned(
                    top: 10,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: Container(
                        width: 54,
                        height: 5,
                        decoration: BoxDecoration(
                          color: const Color(0xFFCBD5E1),
                          borderRadius: BorderRadius.circular(999),
                        ),
                      ),
                    ),
                  ),
                  Positioned.fill(
                    top: 22,
                    child: ListView(
                      controller: scrollController,
                      padding: EdgeInsets.fromLTRB(18, 18, 18, bottom + 18),
                      children: [
                        _PanelHeader(
                          icon: _modeIcon,
                          mapName: widget.mapName,
                          summary: _summaryText,
                          title: _panelTitle,
                          trailingIcon: _showDestinations
                              ? Icons.grid_view_rounded
                              : _modeIcon,
                        ),
                        if (widget.multiRoute != null &&
                            widget.multiRoute!.segments.length > 1) ...[
                          const SizedBox(height: 14),
                          _RouteSegments(
                            result: widget.multiRoute!,
                            activeIndex: widget.activeSegmentIndex,
                            onSegmentTap: widget.onSegmentTap,
                          ),
                        ],
                        const SizedBox(height: 16),
                        _ModeSwitcher(
                          showDestinations: _showDestinations,
                          destinationLabel: _destinationTitle,
                          hasDestinations: targets.isNotEmpty,
                          onNavigationTap: () =>
                              setState(() => _showDestinations = false),
                          onDestinationsTap: () =>
                              setState(() => _showDestinations = true),
                        ),
                        const SizedBox(height: 16),
                        if (!_showDestinations)
                          _NavigationActions(
                            mode: widget.mode,
                            hasParkedCar: widget.parkedAt != null,
                            hasDestinations: targets.isNotEmpty,
                            destinationTitle: _destinationTitle,
                            onShowDestinations: () =>
                                setState(() => _showDestinations = true),
                            onNearestToUser: widget.onNearestToUser,
                            onNearestToHospital: widget.onNearestToHospital,
                            onNavigateToCar: widget.parkedAt != null
                                ? widget.onNavigateToCar
                                : null,
                            onNavigateToExit: widget.onNavigateToExit,
                          )
                        else
                          _TargetGrid(
                            isParking: _isParking,
                            targets: targets,
                            targetPark: widget.targetPark,
                            occupancyMap: widget.occupancyMap,
                            onSelected: widget.onParkSelected,
                          ),
                        if (widget.targetPark != null) ...[
                          const SizedBox(height: 12),
                          _GhostAction(
                            label: 'Rotayı Temizle',
                            onTap: widget.onClearNav,
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  List<MapNode> _targetsForPanel() {
    if (!_isParking) {
      return widget.destinations;
    }

    if (widget.destinations.isEmpty) {
      return widget.parks;
    }

    final nodesByKey = <String, MapNode>{};
    for (final park in widget.parks) {
      nodesByKey[(park.externalReferenceId ?? park.id).toUpperCase()] = park;
    }
    for (final destination in widget.destinations) {
      nodesByKey[(destination.externalReferenceId ?? destination.id)
          .toUpperCase()] = destination;
    }

    final nodes = nodesByKey.values.toList()
      ..sort(
          (left, right) => compareNodeLabelsNatural(left.label, right.label));
    return nodes;
  }
}
