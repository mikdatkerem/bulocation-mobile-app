import 'dart:ui';

import 'package:flutter/material.dart';

import '../models/graph_data.dart';
import '../services/pathfinding_service.dart';

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
      MapPanelMode.parking => 'Rota ve park alanlari',
      MapPanelMode.hospital => 'Hastane hedefleri',
      MapPanelMode.mall => 'AVM hedefleri',
      MapPanelMode.other => 'Navigasyon hedefleri',
    };
  }

  String get _destinationTitle {
    return switch (widget.mode) {
      MapPanelMode.parking => 'Park Alanlari',
      MapPanelMode.hospital => 'Bolumler',
      MapPanelMode.mall => 'Magazalar',
      MapPanelMode.other => 'Noktalar',
    };
  }

  String get _summaryText {
    if (_isParking) {
      return '${widget.emptyCount} BOS - ${widget.fullCount} DOLU - ${widget.totalCount} TOPLAM';
    }

    final active = widget.activeReference ?? 'QR bekleniyor';
    return '${widget.destinations.length} HEDEF - $active';
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
    final targets = _isParking ? widget.parks : widget.destinations;

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
                color: const Color(0xFF6D6F75).withValues(alpha: 0.78),
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(30)),
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
                          color: Colors.white.withValues(alpha: 0.36),
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
                            label: 'Rotayi Temizle',
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
}

class _PanelHeader extends StatelessWidget {
  const _PanelHeader({
    required this.icon,
    required this.mapName,
    required this.summary,
    required this.title,
    required this.trailingIcon,
  });

  final IconData icon;
  final String mapName;
  final String summary;
  final String title;
  final IconData trailingIcon;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(icon, color: const Color(0xFF2155D6), size: 28),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                mapName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 17,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                summary,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: const Color(0xFF7EF0B3).withValues(alpha: 0.95),
                  fontWeight: FontWeight.w800,
                  fontSize: 11,
                  letterSpacing: 0.3,
                ),
              ),
              Text(
                title.toUpperCase(),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.6),
                  fontWeight: FontWeight.w700,
                  fontSize: 11,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
        ),
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.14),
            shape: BoxShape.circle,
          ),
          child: Icon(trailingIcon, color: Colors.white),
        ),
      ],
    );
  }
}

class _RouteSegments extends StatelessWidget {
  const _RouteSegments({
    required this.result,
    required this.activeIndex,
    required this.onSegmentTap,
  });

  final MultiRouteResult result;
  final int activeIndex;
  final ValueChanged<int> onSegmentTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 42,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: result.segments.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final segment = result.segments[index];
          final active = index == activeIndex;
          return InkWell(
            onTap: () => onSegmentTap(index),
            borderRadius: BorderRadius.circular(14),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: active
                    ? Colors.white
                    : Colors.white.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(14),
              ),
              alignment: Alignment.center,
              child: Text(
                '${segment.buildingName} / ${segment.floorName}',
                style: TextStyle(
                  color: active ? const Color(0xFF182033) : Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _ModeSwitcher extends StatelessWidget {
  const _ModeSwitcher({
    required this.showDestinations,
    required this.destinationLabel,
    required this.hasDestinations,
    required this.onNavigationTap,
    required this.onDestinationsTap,
  });

  final bool showDestinations;
  final String destinationLabel;
  final bool hasDestinations;
  final VoidCallback onNavigationTap;
  final VoidCallback onDestinationsTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(
            child: _ModeButton(
              active: !showDestinations,
              label: 'Navigasyon',
              onTap: onNavigationTap,
            ),
          ),
          if (hasDestinations)
            Expanded(
              child: _ModeButton(
                active: showDestinations,
                label: destinationLabel,
                onTap: onDestinationsTap,
              ),
            ),
        ],
      ),
    );
  }
}

class _NavigationActions extends StatelessWidget {
  const _NavigationActions({
    required this.mode,
    required this.hasParkedCar,
    required this.hasDestinations,
    required this.destinationTitle,
    required this.onShowDestinations,
    required this.onNearestToUser,
    required this.onNearestToHospital,
    required this.onNavigateToCar,
    required this.onNavigateToExit,
  });

  final MapPanelMode mode;
  final bool hasParkedCar;
  final bool hasDestinations;
  final String destinationTitle;
  final VoidCallback onShowDestinations;
  final VoidCallback onNearestToUser;
  final VoidCallback onNearestToHospital;
  final VoidCallback? onNavigateToCar;
  final VoidCallback onNavigateToExit;

  bool get _isParking => mode == MapPanelMode.parking;

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.52,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        if (_isParking)
          _ActionCard(
            icon: Icons.near_me_rounded,
            title: 'Bana En\nYakin',
            enabled: true,
            onTap: onNearestToUser,
          ),
        if (_isParking)
          _ActionCard(
            icon: Icons.local_hospital_outlined,
            title: 'Hastane\nGirisi',
            enabled: true,
            onTap: onNearestToHospital,
          ),
        if (_isParking)
          _ActionCard(
            icon: Icons.directions_car_outlined,
            title: 'Aracima\nGit',
            enabled: hasParkedCar,
            onTap: onNavigateToCar,
          ),
        if (!_isParking)
          _ActionCard(
            icon: _iconForMode(mode),
            title: destinationTitle,
            enabled: hasDestinations,
            onTap: hasDestinations ? onShowDestinations : null,
          ),
        _ActionCard(
          icon: Icons.logout_rounded,
          title: 'Cikisa Git',
          enabled: true,
          onTap: onNavigateToExit,
        ),
      ],
    );
  }

  IconData _iconForMode(MapPanelMode mode) {
    return switch (mode) {
      MapPanelMode.parking => Icons.local_parking_rounded,
      MapPanelMode.hospital => Icons.local_hospital_rounded,
      MapPanelMode.mall => Icons.store_mall_directory_rounded,
      MapPanelMode.other => Icons.place_rounded,
    };
  }
}

class _TargetGrid extends StatelessWidget {
  const _TargetGrid({
    required this.isParking,
    required this.targets,
    required this.targetPark,
    required this.occupancyMap,
    required this.onSelected,
  });

  final bool isParking;
  final List<MapNode> targets;
  final MapNode? targetPark;
  final Map<String, bool> occupancyMap;
  final void Function(MapNode) onSelected;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 1.15,
      ),
      itemCount: targets.length,
      itemBuilder: (context, index) {
        final target = targets[index];
        final targetKey =
            (target.externalReferenceId ?? target.id).toUpperCase();
        final isOccupied = occupancyMap[targetKey];
        final isTarget = targetPark?.id == target.id;

        return InkWell(
          onTap: () => onSelected(target),
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            decoration: BoxDecoration(
              color: isTarget
                  ? Colors.white
                  : Colors.white.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isTarget
                    ? Colors.white
                    : Colors.white.withValues(alpha: 0.12),
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  target.label,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: isTarget ? const Color(0xFF182033) : Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: target.label.length > 10 ? 11 : 13,
                  ),
                ),
                const SizedBox(height: 6),
                if (isParking)
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: _spotColor(isOccupied, isTarget),
                      shape: BoxShape.circle,
                    ),
                  )
                else
                  Icon(
                    _iconForNode(target),
                    size: 16,
                    color: isTarget
                        ? const Color(0xFF2155D6)
                        : Colors.white.withValues(alpha: 0.78),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Color _spotColor(bool? isOccupied, bool isTarget) {
    if (isTarget) {
      return const Color(0xFF2155D6);
    }
    if (isOccupied == null) {
      return const Color(0xFFB5BECE);
    }
    return isOccupied ? const Color(0xFFE25757) : const Color(0xFF1C9B67);
  }

  IconData _iconForNode(MapNode node) {
    return switch (node.type) {
      NodeType.entrance => Icons.login_rounded,
      NodeType.exit => Icons.logout_rounded,
      NodeType.park => Icons.local_parking_rounded,
      NodeType.qr => Icons.qr_code_2_rounded,
      NodeType.other => Icons.place_rounded,
    };
  }
}

class _ModeButton extends StatelessWidget {
  const _ModeButton({
    required this.active,
    required this.label,
    required this.onTap,
  });

  final bool active;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        height: 42,
        decoration: BoxDecoration(
          color: active
              ? Colors.white.withValues(alpha: 0.22)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            color: Colors.white.withValues(alpha: active ? 1 : 0.72),
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  const _ActionCard({
    required this.icon,
    required this.title,
    required this.enabled,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final bool enabled;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: enabled ? onTap : null,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: enabled ? 0.12 : 0.08),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color:
                    enabled ? const Color(0xFF2155D6) : const Color(0xFFA4ACB9),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: enabled ? 1 : 0.55),
                  fontWeight: FontWeight.w700,
                  height: 1.2,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GhostAction extends StatelessWidget {
  const _GhostAction({
    required this.label,
    required this.onTap,
  });

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        height: 42,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}
