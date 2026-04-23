import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../core/api_client.dart';
import '../main.dart';
import '../models/graph_data.dart';
import 'navigation_route_painter.dart';
import 'pulse_marker.dart';

part 'floor_plan/map_asset_surface.dart';
part 'floor_plan/park_cell.dart';
part 'floor_plan/zoom_button.dart';

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
  static const double _maxZoomMultiplier = 5.0;
  static const double _panBoundaryMargin = 120.0;

  late final AnimationController _glowController;
  late final AnimationController _viewportAnimationController;
  late final Animation<double> _glowAnimation;
  late final TransformationController _transformationController;
  bool _hasUserMovedViewport = false;
  Size? _viewportSize;
  double _fitScale = 1;
  bool _centeringScheduled = false;

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
    _viewportAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 180),
    );
    _transformationController = TransformationController();
  }

  @override
  void dispose() {
    _glowController.dispose();
    _viewportAnimationController.dispose();
    _transformationController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant FloorPlanWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    final mapChanged = oldWidget.mapAssetPath != widget.mapAssetPath ||
        oldWidget.mapWidth != widget.mapWidth ||
        oldWidget.mapHeight != widget.mapHeight;

    if (mapChanged) {
      _hasUserMovedViewport = false;
      _scheduleCenterOnActiveNode(force: true);
      return;
    }

    if (!_hasUserMovedViewport &&
        oldWidget.activeZoneId != widget.activeZoneId) {
      _scheduleCenterOnActiveNode(force: true);
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

  void _scheduleCenterOnActiveNode({bool force = false}) {
    if (_centeringScheduled) {
      return;
    }

    _centeringScheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _centeringScheduled = false;
      if (!mounted) {
        return;
      }
      _centerOnActiveNode(force: force);
    });
  }

  void _centerOnActiveNode({bool force = false}) {
    final viewportSize = _viewportSize;
    if (viewportSize == null) {
      return;
    }

    if (_hasUserMovedViewport && !force) {
      return;
    }

    _viewportAnimationController.stop();
    _transformationController.value = _centerMatrixForActiveNode(viewportSize);
  }

  void _zoom(double factor) {
    final viewportSize = _viewportSize;
    if (viewportSize == null) {
      return;
    }

    final currentScale = _currentScale;
    final minScale = _fitScale;
    final maxScale = _fitScale * _maxZoomMultiplier;
    final nextScale = (currentScale * factor).clamp(minScale, maxScale);
    if ((nextScale - currentScale).abs() < 0.0001) {
      return;
    }

    _hasUserMovedViewport = true;
    final focalPoint = Offset(viewportSize.width / 2, viewportSize.height / 2);
    final currentTranslateX = _currentTranslateX;
    final currentTranslateY = _currentTranslateY;

    final sceneX = (focalPoint.dx - currentTranslateX) / currentScale;
    final sceneY = (focalPoint.dy - currentTranslateY) / currentScale;

    final nextTranslateX = focalPoint.dx - (sceneX * nextScale);
    final nextTranslateY = focalPoint.dy - (sceneY * nextScale);

    _animateToMatrix(_clampMatrix(
      _buildMatrix(
        scale: nextScale,
        translateX: nextTranslateX,
        translateY: nextTranslateY,
      ),
    ));
  }

  void _settleViewport() {
    final viewportSize = _viewportSize;
    if (viewportSize == null) {
      return;
    }

    final currentScale = _currentScale;
    if (currentScale < _fitScale) {
      _hasUserMovedViewport = false;
      _animateToMatrix(_centerMatrixForActiveNode(viewportSize));
      return;
    }

    final clamped = _clampMatrix(_transformationController.value.clone());
    if (_matrixEquals(_transformationController.value, clamped)) {
      return;
    }

    _animateToMatrix(clamped);
  }

  Matrix4 _centerMatrixForActiveNode(Size viewportSize) {
    final scale = _fitScale;
    final scaledWidth = _mapWidth * scale;
    final scaledHeight = _mapHeight * scale;
    final activeNode = _activeNode;

    double translateX = (viewportSize.width - scaledWidth) / 2;
    double translateY = (viewportSize.height - scaledHeight) / 2;

    if (activeNode != null) {
      final desiredX =
          viewportSize.width / 2 - (activeNode.resolveX(_mapWidth) * scale);
      final desiredY =
          viewportSize.height / 2 - (activeNode.resolveY(_mapHeight) * scale);
      final minTranslateX = viewportSize.width - scaledWidth;
      final minTranslateY = viewportSize.height - scaledHeight;

      translateX = scaledWidth <= viewportSize.width
          ? translateX
          : desiredX.clamp(minTranslateX, 0.0);
      translateY = scaledHeight <= viewportSize.height
          ? translateY
          : desiredY.clamp(minTranslateY, 0.0);
    }

    return _buildMatrix(
      scale: scale,
      translateX: translateX,
      translateY: translateY,
    );
  }

  void _animateToMatrix(Matrix4 target) {
    _viewportAnimationController.stop();
    final tween = Matrix4Tween(
      begin: _transformationController.value.clone(),
      end: target,
    );
    final animation = CurvedAnimation(
      parent: _viewportAnimationController,
      curve: Curves.easeOutCubic,
    );

    void listener() {
      _transformationController.value = tween.evaluate(animation);
    }

    void statusListener(AnimationStatus status) {
      if (status == AnimationStatus.completed ||
          status == AnimationStatus.dismissed) {
        animation.removeListener(listener);
        animation.removeStatusListener(statusListener);
        animation.dispose();
      }
    }

    animation
      ..addListener(listener)
      ..addStatusListener(statusListener);
    _viewportAnimationController
      ..value = 0
      ..forward();
  }

  Matrix4 _clampMatrix(Matrix4 matrix) {
    final viewportSize = _viewportSize;
    if (viewportSize == null) {
      return matrix;
    }

    final currentScale = matrix.storage[0];
    final clampedScale =
        currentScale.clamp(_fitScale, _fitScale * _maxZoomMultiplier);
    final scaledWidth = _mapWidth * clampedScale;
    final scaledHeight = _mapHeight * clampedScale;

    final currentTranslateX = matrix.storage[12];
    final currentTranslateY = matrix.storage[13];

    final minTranslateX = viewportSize.width - scaledWidth;
    final minTranslateY = viewportSize.height - scaledHeight;

    final translateX = scaledWidth <= viewportSize.width
        ? (viewportSize.width - scaledWidth) / 2
        : currentTranslateX.clamp(minTranslateX, 0.0);
    final translateY = scaledHeight <= viewportSize.height
        ? (viewportSize.height - scaledHeight) / 2
        : currentTranslateY.clamp(minTranslateY, 0.0);

    return _buildMatrix(
      scale: clampedScale,
      translateX: translateX,
      translateY: translateY,
    );
  }

  Matrix4 _buildMatrix({
    required double scale,
    required double translateX,
    required double translateY,
  }) {
    final matrix = Matrix4.identity();
    matrix.storage[0] = scale;
    matrix.storage[5] = scale;
    matrix.storage[10] = 1;
    matrix.storage[15] = 1;
    matrix.storage[12] = translateX;
    matrix.storage[13] = translateY;
    return matrix;
  }

  double get _currentScale => _transformationController.value.storage[0];
  double get _currentTranslateX => _transformationController.value.storage[12];
  double get _currentTranslateY => _transformationController.value.storage[13];

  bool _matrixEquals(Matrix4 a, Matrix4 b) {
    for (var i = 0; i < 16; i++) {
      if ((a.storage[i] - b.storage[i]).abs() > 0.0001) {
        return false;
      }
    }
    return true;
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
        final viewportChanged = _viewportSize != nextViewportSize;
        final fitScaleChanged = _fitScale != nextFitScale;
        _viewportSize = nextViewportSize;
        _fitScale = nextFitScale;
        if ((viewportChanged || fitScaleChanged) && !_hasUserMovedViewport) {
          _scheduleCenterOnActiveNode();
        }
        final activeNode = _activeNode;
        final sourceNodes = widget.nodes ?? const <MapNode>[];
        final parkNodes = sourceNodes.where((node) => node.isPark).toList();

        return Stack(
          children: [
            InteractiveViewer(
              transformationController: _transformationController,
              constrained: false,
              clipBehavior: Clip.hardEdge,
              scaleEnabled: true,
              panEnabled: true,
              minScale: _fitScale,
              maxScale: _fitScale * _maxZoomMultiplier,
              boundaryMargin: const EdgeInsets.all(_panBoundaryMargin),
              onInteractionStart: (_) {
                _viewportAnimationController.stop();
                _hasUserMovedViewport = true;
              },
              onInteractionEnd: (_) => _settleViewport(),
              child: SizedBox(
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
                    ...parkNodes.map((node) {
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
                    }),
                    if (activeNode != null)
                      Positioned(
                        left: activeNode.resolveX(_mapWidth) - 20,
                        top: activeNode.resolveY(_mapHeight) - 20,
                        child: const PulseMarker(),
                      ),
                  ],
                ),
              ),
            ),
            Positioned(
              right: 16,
              bottom: 92,
              child: Column(
                children: [
                  _ZoomButton(
                    icon: Icons.add_rounded,
                    onTap: () => _zoom(1.2),
                  ),
                  const SizedBox(height: 10),
                  _ZoomButton(
                    icon: Icons.remove_rounded,
                    onTap: () => _zoom(0.84),
                  ),
                ],
              ),
            ),
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
