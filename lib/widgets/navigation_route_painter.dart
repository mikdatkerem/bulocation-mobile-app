import 'package:flutter/material.dart';

import '../models/graph_data.dart';

class NavigationRoutePainter extends CustomPainter {
  NavigationRoutePainter({
    required this.routeNodes,
    required this.svgWidth,
    required this.svgHeight,
    required this.animation,
  }) : super(repaint: animation);

  final List<MapNode> routeNodes;
  final double svgWidth;
  final double svgHeight;
  final Animation<double> animation;

  @override
  void paint(Canvas canvas, Size size) {
    if (routeNodes.length < 2) {
      return;
    }

    final points = routeNodes
        .map(
          (node) => Offset(
            node.resolveX(svgWidth),
            node.resolveY(svgHeight),
          ),
        )
        .toList();

    final shadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.15)
      ..strokeWidth = 5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final linePaint = Paint()
      ..color = Colors.blue.shade600
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final glowPaint = Paint()
      ..color = Colors.lightBlueAccent.withValues(alpha: 0.4 * animation.value)
      ..strokeWidth = 6
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final path = Path()..moveTo(points.first.dx, points.first.dy);
    for (var index = 1; index < points.length; index++) {
      path.lineTo(points[index].dx, points[index].dy);
    }

    canvas.drawPath(path, shadowPaint);
    canvas.drawPath(path, linePaint);
    canvas.drawPath(path, glowPaint);
  }

  @override
  bool shouldRepaint(NavigationRoutePainter oldDelegate) =>
      oldDelegate.routeNodes != routeNodes;
}
