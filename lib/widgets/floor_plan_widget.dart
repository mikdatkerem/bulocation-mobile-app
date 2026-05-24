import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../core/api_client.dart';
import '../main.dart';
import '../models/graph_data.dart';
import 'floor_plan/map_viewport_controller.dart';
import 'navigation_route_painter.dart';
import 'pulse_marker.dart';

part 'floor_plan/map_asset_surface.dart';
part 'floor_plan/park_cell.dart';

class FloorPlanWidget extends StatefulWidget {
  const FloorPlanWidget({
    super.key,
    required this.visitedIds,
    required this.occupancyMap,
    this.activeZoneId,
    this.navigationRoute,
    this.nodes,
    this.mapAssetPath,
    this.mapAssetContentType,
    this.mapWidth,
    this.mapHeight,
  });

  final Set<String> visitedIds;
  final String? activeZoneId;
  final List<MapNode>? navigationRoute;
  final Map<String, bool> occupancyMap;
  final List<MapNode>? nodes;
  final String? mapAssetPath;
  final String? mapAssetContentType;
  final int? mapWidth;
  final int? mapHeight;

  String? get targetParkId {
    if (navigationRoute == null || navigationRoute!.isEmpty) {
      return null;
    }
    final lastNode = navigationRoute!.last;
    return lastNode.isPark ? lastNode.id : null;
  }

  @override
  State<FloorPlanWidget> createState() => _FloorPlanWidgetState();
}

class _FloorPlanWidgetState extends State<FloorPlanWidget>
    with TickerProviderStateMixin {
  late final AnimationController _glowController;
  late final Animation<double> _glowAnimation;
  late final MapViewportController _viewportController;

  @override
  void initState() {
    super.initState();
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _glowAnimation = CurvedAnimation(
      parent: _glowController,
      curve: Curves.easeInOut,
    );
    _viewportController = MapViewportController(
      vsync: this,
      onChanged: () {
        if (mounted) {
          setState(() {});
        }
      },
    );
  }

  @override
  void dispose() {
    _glowController.dispose();
    _viewportController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant FloorPlanWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    final mapChanged = oldWidget.mapAssetPath != widget.mapAssetPath ||
        oldWidget.mapWidth != widget.mapWidth ||
        oldWidget.mapHeight != widget.mapHeight;

    if (mapChanged) {
      _viewportController.handleMapChanged(
        mapWidth: _mapWidth,
        mapHeight: _mapHeight,
        activeNode: _activeNode,
      );
      return;
    }

    if (oldWidget.activeZoneId != widget.activeZoneId) {
      _viewportController.handleActiveNodeChanged(
        mapWidth: _mapWidth,
        mapHeight: _mapHeight,
        activeNode: _activeNode,
      );
    }
  }

  MapNode? get _activeNode {
    final activeZoneId = widget.activeZoneId;
    if (activeZoneId == null) {
      return null;
    }
    final sourceNodes = widget.nodes ?? const <MapNode>[];
    return sourceNodes.where((node) => node.id == activeZoneId).firstOrNull;
  }

  double get _mapWidth => (widget.mapWidth ?? 1920).toDouble();
  double get _mapHeight => (widget.mapHeight ?? 1080).toDouble();
  int get _zoomPercentage => _viewportController.zoomPercentage;

  void _handleDoubleTap() {
    _viewportController.handleDoubleTap(
      mapWidth: _mapWidth,
      mapHeight: _mapHeight,
      activeNode: _activeNode,
    );
  }

  Widget _buildZoomBadge() {
    return Positioned(
      left: 12,
      top: 12,
      child: Container(
        height: 34,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.86),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withValues(alpha: 0.7)),
          boxShadow: const [
            BoxShadow(
              color: Color(0x140F172A),
              blurRadius: 14,
              offset: Offset(0, 6),
            ),
          ],
        ),
        child: Text(
          '${_zoomPercentage.clamp(100, (_viewportController.maxZoomMultiplier * 100).round())}%',
          style: const TextStyle(
            color: Color(0xFF182033),
            fontSize: 12,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }

  Widget _buildMapLayerStack({
    required List<MapNode> sourceNodes,
    required MapNode? activeNode,
  }) {
    final parkNodes = sourceNodes.where((node) => node.isPark).toList();

    return SizedBox(
      width: _mapWidth,
      height: _mapHeight,
      child: Stack(
        clipBehavior: Clip.hardEdge,
        children: [
          Positioned.fill(
            child: _MapAssetSurface(
              url: _resolveMapAssetUrl(),
              contentType: widget.mapAssetContentType,
            ),
          ),
          if (widget.navigationRoute != null &&
              widget.navigationRoute!.length >= 2)
            Positioned.fill(
              child: CustomPaint(
                painter: NavigationRoutePainter(
                  routeNodes: widget.navigationRoute!,
                  svgWidth: _mapWidth,
                  svgHeight: _mapHeight,
                  animation: _glowAnimation,
                ),
              ),
            ),
          ...parkNodes.map(_buildParkCell),
          if (activeNode != null) _buildActiveNodeMarker(activeNode),
        ],
      ),
    );
  }

  Widget _buildParkCell(MapNode node) {
    const cellWidth = 36.0;
    const cellHeight = 22.0;
    final nodeX = node.resolveX(_mapWidth);
    final nodeY = node.resolveY(_mapHeight);

    return Positioned(
      left: nodeX - cellWidth / 2,
      top: nodeY - cellHeight / 2,
      child: _ParkCell(
        key: ValueKey(node.id),
        node: node,
        isOccupied: widget.occupancyMap[node.id],
        isTarget: widget.targetParkId == node.id,
      ),
    );
  }

  Widget _buildActiveNodeMarker(MapNode activeNode) {
    return Positioned(
      left: activeNode.resolveX(_mapWidth) - 20,
      top: activeNode.resolveY(_mapHeight) - 20,
      child: const PulseMarker(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final nextViewportSize =
            Size(constraints.maxWidth, constraints.maxHeight);
        final nextFitScale = [
          constraints.maxWidth / _mapWidth,
          constraints.maxHeight / _mapHeight,
        ].reduce((value, element) => value < element ? value : element);
        final activeNode = _activeNode;
        final sourceNodes = widget.nodes ?? const <MapNode>[];
        _viewportController.updateLayout(
          nextViewportSize: nextViewportSize,
          nextFitScale: nextFitScale,
          mapWidth: _mapWidth,
          mapHeight: _mapHeight,
          activeNode: activeNode,
        );

        return Stack(
          children: [
            GestureDetector(
              onDoubleTapDown: (details) =>
                  _viewportController.lastDoubleTapDownDetails = details,
              onDoubleTap: _handleDoubleTap,
              child: InteractiveViewer(
                transformationController:
                    _viewportController.transformationController,
                constrained: false,
                clipBehavior: Clip.hardEdge,
                scaleEnabled: true,
                panEnabled: true,
                minScale: _viewportController.fitScale,
                maxScale: _viewportController.fitScale *
                    _viewportController.maxZoomMultiplier,
                boundaryMargin:
                    EdgeInsets.all(_viewportController.panBoundaryMargin),
                onInteractionStart: (_) =>
                    _viewportController.onInteractionStart(),
                onInteractionEnd: (_) => _viewportController.settleViewport(
                  mapWidth: _mapWidth,
                  mapHeight: _mapHeight,
                  activeNode: activeNode,
                ),
                child: _buildMapLayerStack(
                  sourceNodes: sourceNodes,
                  activeNode: activeNode,
                ),
              ),
            ),
            _buildZoomBadge(),
          ],
        );
      },
    );
  }

  String _resolveMapAssetUrl() {
    final assetPath = widget.mapAssetPath;
    if (assetPath == null || assetPath.isEmpty) {
      return AppConfig.mapSvgUrl;
    }

    if (assetPath.startsWith('http://') || assetPath.startsWith('https://')) {
      return assetPath;
    }

    return '${AppConfig.baseHost}$assetPath';
  }
}
