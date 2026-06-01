import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../core/api_client.dart';
import '../main.dart';
import '../models/graph_data.dart';
import 'floor_plan/map_viewport_controller.dart';
import 'navigation_route_painter.dart';
import 'pulse_marker.dart';
import 'skeleton.dart';

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
    this.onNodeSelected,
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
  final ValueChanged<MapNode>? onNodeSelected;

  String? get targetParkId {
    if (navigationRoute == null || navigationRoute!.isEmpty) {
      return null;
    }
    final lastNode = navigationRoute!.last;
    return lastNode.isPark ? lastNode.id : null;
  }

  String? get targetNodeId {
    if (navigationRoute == null || navigationRoute!.isEmpty) {
      return null;
    }

    return navigationRoute!.last.id;
  }

  @override
  State<FloorPlanWidget> createState() => _FloorPlanWidgetState();
}

class _FloorPlanWidgetState extends State<FloorPlanWidget>
    with TickerProviderStateMixin {
  late final AnimationController _glowController;
  late final Animation<double> _glowAnimation;
  late final MapViewportController _viewportController;
  Timer? _previewTimer;
  MapNode? _previewNode;

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
    _previewTimer?.cancel();
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
      _hideNodePreview();
      _viewportController.handleMapChanged(
        mapWidth: _mapWidth,
        mapHeight: _mapHeight,
        activeNode: _activeNode,
      );
      return;
    }

    if (oldWidget.activeZoneId != widget.activeZoneId) {
      _hideNodePreview();
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
    _hideNodePreview();
    _viewportController.handleDoubleTap(
      mapWidth: _mapWidth,
      mapHeight: _mapHeight,
      activeNode: _activeNode,
    );
  }

  void _handleNodeTap(MapNode node) {
    _hideNodePreview();
    widget.onNodeSelected?.call(node);
  }

  void _showNodePreview(MapNode node) {
    _previewTimer?.cancel();
    setState(() => _previewNode = node);
    _previewTimer = Timer(const Duration(seconds: 3), _hideNodePreview);
  }

  void _hideNodePreview() {
    _previewTimer?.cancel();
    _previewTimer = null;
    if (_previewNode == null || !mounted) {
      return;
    }
    setState(() => _previewNode = null);
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
    final markerNodes = sourceNodes
        .where((node) => !node.isPark && node.id != activeNode?.id)
        .toList();

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
          ...markerNodes.map(_buildMapNodeMarker),
          if (activeNode != null) _buildActiveNodeMarker(activeNode),
          if (_previewNode case final previewNode?
              when sourceNodes.any((node) => node.id == previewNode.id))
            _buildNodePreview(previewNode),
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
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => _handleNodeTap(node),
        onLongPress: () => _showNodePreview(node),
        child: _ParkCell(
          key: ValueKey(node.id),
          node: node,
          isOccupied: node.occupancyFrom(widget.occupancyMap),
          isTarget: widget.targetParkId == node.id,
        ),
      ),
    );
  }

  Widget _buildMapNodeMarker(MapNode node) {
    final nodeX = node.resolveX(_mapWidth);
    final nodeY = node.resolveY(_mapHeight);
    final isTarget = widget.targetNodeId == node.id;
    final markerWidth = node.type == NodeType.other ? 72.0 : 58.0;
    final markerHeight = node.type == NodeType.other ? 34.0 : 32.0;

    return Positioned(
      left: nodeX - markerWidth / 2,
      top: nodeY - markerHeight / 2,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => _handleNodeTap(node),
        onLongPress: () => _showNodePreview(node),
        child: _MapNodeMarker(
          key: ValueKey('map-node-${node.type}-${node.id}'),
          node: node,
          width: markerWidth,
          height: markerHeight,
          isTarget: isTarget,
        ),
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

  Widget _buildNodePreview(MapNode node) {
    const tooltipWidth = 172.0;
    const tooltipMinHeight = 40.0;
    final nodeX = node.resolveX(_mapWidth);
    final nodeY = node.resolveY(_mapHeight);
    final left =
        (nodeX - tooltipWidth / 2).clamp(8.0, _mapWidth - tooltipWidth - 8);
    final top = (nodeY - 58).clamp(8.0, _mapHeight - tooltipMinHeight - 8);

    return Positioned(
      left: left,
      top: top,
      child: IgnorePointer(
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 160),
          opacity: 1,
          child: Container(
            width: tooltipWidth,
            constraints: const BoxConstraints(minHeight: tooltipMinHeight),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
            decoration: BoxDecoration(
              color: const Color(0xEE0F172A),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x330F172A),
                  blurRadius: 14,
                  offset: Offset(0, 7),
                ),
              ],
            ),
            child: Text(
              node.displayLabel,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                height: 1.15,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ),
      ),
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
                onInteractionStart: (_) {
                  _hideNodePreview();
                  _viewportController.onInteractionStart();
                },
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

class _MapNodeMarker extends StatelessWidget {
  const _MapNodeMarker({
    super.key,
    required this.node,
    required this.width,
    required this.height,
    required this.isTarget,
  });

  final MapNode node;
  final double width;
  final double height;
  final bool isTarget;

  @override
  Widget build(BuildContext context) {
    final color = _color;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      width: width,
      height: height,
      padding: const EdgeInsets.symmetric(horizontal: 7),
      decoration: BoxDecoration(
        color: isTarget ? const Color(0xFF4F46E5) : Colors.white,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: isTarget
              ? const Color(0xFF4F46E5)
              : color.withValues(alpha: 0.36),
          width: isTarget ? 1.6 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: (isTarget ? const Color(0xFF4F46E5) : color)
                .withValues(alpha: isTarget ? 0.28 : 0.18),
            blurRadius: isTarget ? 9 : 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _icon,
            size: node.type == NodeType.other ? 13 : 14,
            color: isTarget ? Colors.white : color,
          ),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              _label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: isTarget ? Colors.white : const Color(0xFF0F172A),
                fontSize: node.type == NodeType.other ? 8.6 : 9.2,
                height: 1,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String get _label {
    final fallback = switch (node.type) {
      NodeType.qr => 'QR',
      NodeType.entrance => 'Giriş',
      NodeType.exit => 'Çıkış',
      NodeType.elevator => 'Asansör',
      NodeType.stair => 'Merdiven',
      NodeType.parkingEntrance => 'P Giriş',
      NodeType.parkingExit => 'P Çıkış',
      NodeType.other => node.displayLabel,
      NodeType.park => node.displayLabel,
    };
    final value = fallback.trim();
    if (value.length <= 12) {
      return value;
    }

    return '${value.substring(0, 11)}…';
  }

  IconData get _icon {
    return switch (node.type) {
      NodeType.qr => Icons.qr_code_2_rounded,
      NodeType.entrance => Icons.login_rounded,
      NodeType.exit => Icons.logout_rounded,
      NodeType.elevator => Icons.elevator_rounded,
      NodeType.stair => Icons.stairs_rounded,
      NodeType.parkingEntrance => Icons.local_parking_rounded,
      NodeType.parkingExit => Icons.exit_to_app_rounded,
      NodeType.park => Icons.local_parking_rounded,
      NodeType.other => Icons.place_rounded,
    };
  }

  Color get _color {
    return switch (node.type) {
      NodeType.qr => const Color(0xFF6366F1),
      NodeType.entrance => const Color(0xFF0284C7),
      NodeType.exit => const Color(0xFFE11D48),
      NodeType.elevator => const Color(0xFF4F46E5),
      NodeType.stair => const Color(0xFF9333EA),
      NodeType.parkingEntrance => const Color(0xFF16A34A),
      NodeType.parkingExit => const Color(0xFFEA580C),
      NodeType.park => const Color(0xFF4F46E5),
      NodeType.other => const Color(0xFF475569),
    };
  }
}
