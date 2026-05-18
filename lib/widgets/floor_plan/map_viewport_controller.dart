import 'package:flutter/material.dart';

import '../../models/graph_data.dart';

class MapViewportController {
  MapViewportController({
    required TickerProvider vsync,
    required VoidCallback onChanged,
    this.maxZoomMultiplier = 5.0,
    this.panBoundaryMargin = 120.0,
  }) : _onChanged = onChanged {
    animationController = AnimationController(
      vsync: vsync,
      duration: const Duration(milliseconds: 180),
    );
    transformationController = TransformationController()
      ..addListener(_handleTransformChanged);
  }

  final VoidCallback _onChanged;
  final double maxZoomMultiplier;
  final double panBoundaryMargin;

  late final AnimationController animationController;
  late final TransformationController transformationController;

  bool hasUserMovedViewport = false;
  bool followActiveNode = true;
  Size? viewportSize;
  double fitScale = 1;
  bool _centeringScheduled = false;
  TapDownDetails? lastDoubleTapDownDetails;

  void dispose() {
    animationController.dispose();
    transformationController.removeListener(_handleTransformChanged);
    transformationController.dispose();
  }

  double get currentScale => transformationController.value.storage[0];
  double get currentTranslateX => transformationController.value.storage[12];
  double get currentTranslateY => transformationController.value.storage[13];
  int get zoomPercentage => ((currentScale / fitScale) * 100).round();

  void updateLayout({
    required Size nextViewportSize,
    required double nextFitScale,
    required double mapWidth,
    required double mapHeight,
    required MapNode? activeNode,
  }) {
    final viewportChanged = viewportSize != nextViewportSize;
    final fitScaleChanged = fitScale != nextFitScale;
    viewportSize = nextViewportSize;
    fitScale = nextFitScale;
    if ((viewportChanged || fitScaleChanged) && !hasUserMovedViewport) {
      scheduleCenterOnActiveNode(
        mapWidth: mapWidth,
        mapHeight: mapHeight,
        activeNode: activeNode,
      );
    }
  }

  void handleMapChanged({
    required double mapWidth,
    required double mapHeight,
    required MapNode? activeNode,
  }) {
    hasUserMovedViewport = false;
    followActiveNode = true;
    scheduleCenterOnActiveNode(
      mapWidth: mapWidth,
      mapHeight: mapHeight,
      activeNode: activeNode,
      force: true,
    );
  }

  void handleActiveNodeChanged({
    required double mapWidth,
    required double mapHeight,
    required MapNode? activeNode,
    bool force = true,
  }) {
    if ((followActiveNode || !hasUserMovedViewport)) {
      scheduleCenterOnActiveNode(
        mapWidth: mapWidth,
        mapHeight: mapHeight,
        activeNode: activeNode,
        force: force,
      );
    }
  }

  void scheduleCenterOnActiveNode({
    required double mapWidth,
    required double mapHeight,
    required MapNode? activeNode,
    bool force = false,
  }) {
    if (_centeringScheduled) {
      return;
    }

    _centeringScheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _centeringScheduled = false;
      centerOnActiveNode(
        mapWidth: mapWidth,
        mapHeight: mapHeight,
        activeNode: activeNode,
        force: force,
      );
    });
  }

  void centerOnActiveNode({
    required double mapWidth,
    required double mapHeight,
    required MapNode? activeNode,
    bool force = false,
  }) {
    final currentViewportSize = viewportSize;
    if (currentViewportSize == null) {
      return;
    }

    if (!followActiveNode && !force) {
      return;
    }

    final target = _centerMatrixForActiveNode(
      viewportSize: currentViewportSize,
      mapWidth: mapWidth,
      mapHeight: mapHeight,
      activeNode: activeNode,
    );
    if (_matrixEquals(transformationController.value, target)) {
      return;
    }
    _animateToMatrix(target);
  }

  void zoom({
    required double factor,
    required double mapWidth,
    required double mapHeight,
    required MapNode? activeNode,
  }) {
    final currentViewportSize = viewportSize;
    if (currentViewportSize == null) {
      return;
    }

    final minScale = fitScale;
    final maxScale = fitScale * maxZoomMultiplier;
    final nextScale = (currentScale * factor).clamp(minScale, maxScale);
    if ((nextScale - currentScale).abs() < 0.0001) {
      return;
    }

    final wasFollowing = followActiveNode;
    hasUserMovedViewport = true;
    followActiveNode = false;
    final focalPoint = wasFollowing && activeNode != null
        ? Offset(
            (activeNode.resolveX(mapWidth) * currentScale) + currentTranslateX,
            (activeNode.resolveY(mapHeight) * currentScale) + currentTranslateY,
          )
        : Offset(
            currentViewportSize.width / 2,
            currentViewportSize.height / 2,
          );

    final sceneX = (focalPoint.dx - currentTranslateX) / currentScale;
    final sceneY = (focalPoint.dy - currentTranslateY) / currentScale;
    final nextTranslateX = focalPoint.dx - (sceneX * nextScale);
    final nextTranslateY = focalPoint.dy - (sceneY * nextScale);

    _animateToMatrix(
      _clampMatrix(
        _buildMatrix(
          scale: nextScale,
          translateX: nextTranslateX,
          translateY: nextTranslateY,
        ),
        viewportSize: currentViewportSize,
        mapWidth: mapWidth,
        mapHeight: mapHeight,
      ),
    );
  }

  void recenter({
    required double mapWidth,
    required double mapHeight,
    required MapNode? activeNode,
  }) {
    final currentViewportSize = viewportSize;
    if (currentViewportSize == null) {
      return;
    }

    followActiveNode = true;
    hasUserMovedViewport = false;
    _animateToMatrix(
      _centerMatrixForActiveNode(
        viewportSize: currentViewportSize,
        mapWidth: mapWidth,
        mapHeight: mapHeight,
        activeNode: activeNode,
      ),
    );
  }

  void handleDoubleTap({
    required double mapWidth,
    required double mapHeight,
    required MapNode? activeNode,
  }) {
    final details = lastDoubleTapDownDetails;
    final currentViewportSize = viewportSize;
    if (details == null || currentViewportSize == null) {
      return;
    }

    final maxScale = fitScale * maxZoomMultiplier;
    final nextScale = currentScale < (fitScale * 1.6)
        ? (currentScale * 1.8).clamp(fitScale, maxScale)
        : fitScale;
    final focalPoint = details.localPosition;
    final sceneX = (focalPoint.dx - currentTranslateX) / currentScale;
    final sceneY = (focalPoint.dy - currentTranslateY) / currentScale;
    final nextTranslateX = focalPoint.dx - (sceneX * nextScale);
    final nextTranslateY = focalPoint.dy - (sceneY * nextScale);

    hasUserMovedViewport = nextScale > fitScale;
    followActiveNode = nextScale == fitScale;
    _animateToMatrix(
      nextScale == fitScale
          ? _centerMatrixForActiveNode(
              viewportSize: currentViewportSize,
              mapWidth: mapWidth,
              mapHeight: mapHeight,
              activeNode: activeNode,
            )
          : _clampMatrix(
              _buildMatrix(
                scale: nextScale,
                translateX: nextTranslateX,
                translateY: nextTranslateY,
              ),
              viewportSize: currentViewportSize,
              mapWidth: mapWidth,
              mapHeight: mapHeight,
            ),
    );
  }

  void onInteractionStart() {
    animationController.stop();
    hasUserMovedViewport = true;
    followActiveNode = false;
  }

  void settleViewport({
    required double mapWidth,
    required double mapHeight,
    required MapNode? activeNode,
  }) {
    final currentViewportSize = viewportSize;
    if (currentViewportSize == null) {
      return;
    }

    if (currentScale < fitScale) {
      hasUserMovedViewport = false;
      _animateToMatrix(
        _centerMatrixForActiveNode(
          viewportSize: currentViewportSize,
          mapWidth: mapWidth,
          mapHeight: mapHeight,
          activeNode: activeNode,
        ),
      );
      return;
    }

    final clamped = _clampMatrix(
      transformationController.value.clone(),
      viewportSize: currentViewportSize,
      mapWidth: mapWidth,
      mapHeight: mapHeight,
    );
    if (_matrixEquals(transformationController.value, clamped)) {
      return;
    }

    _animateToMatrix(clamped);
  }

  Matrix4 _centerMatrixForActiveNode({
    required Size viewportSize,
    required double mapWidth,
    required double mapHeight,
    required MapNode? activeNode,
  }) {
    final scale = fitScale;
    final scaledWidth = mapWidth * scale;
    final scaledHeight = mapHeight * scale;

    double translateX = (viewportSize.width - scaledWidth) / 2;
    double translateY = (viewportSize.height - scaledHeight) / 2;

    if (activeNode != null) {
      final desiredX =
          viewportSize.width / 2 - (activeNode.resolveX(mapWidth) * scale);
      final desiredY =
          viewportSize.height / 2 - (activeNode.resolveY(mapHeight) * scale);
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
    animationController.stop();
    final tween = Matrix4Tween(
      begin: transformationController.value.clone(),
      end: target,
    );
    final animation = CurvedAnimation(
      parent: animationController,
      curve: Curves.easeOutCubic,
    );

    void listener() {
      transformationController.value = tween.evaluate(animation);
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
    animationController
      ..value = 0
      ..forward();
  }

  Matrix4 _clampMatrix(
    Matrix4 matrix, {
    required Size viewportSize,
    required double mapWidth,
    required double mapHeight,
  }) {
    final currentScale = matrix.storage[0];
    final clampedScale =
        currentScale.clamp(fitScale, fitScale * maxZoomMultiplier);
    final scaledWidth = mapWidth * clampedScale;
    final scaledHeight = mapHeight * clampedScale;

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

  bool _matrixEquals(Matrix4 a, Matrix4 b) {
    for (var i = 0; i < 16; i++) {
      if ((a.storage[i] - b.storage[i]).abs() > 0.0001) {
        return false;
      }
    }
    return true;
  }

  void _handleTransformChanged() {
    _onChanged();
  }
}
