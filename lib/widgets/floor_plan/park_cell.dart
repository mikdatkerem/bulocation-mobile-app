part of '../floor_plan_widget.dart';

class _ParkCell extends StatelessWidget {
  const _ParkCell({
    super.key,
    required this.node,
    required this.isOccupied,
    required this.isTarget,
  });

  final MapNode node;
  final bool? isOccupied;
  final bool isTarget;

  Color get _cellColor {
    if (isTarget) {
      return const Color(0xFF2155D6);
    }
    if (isOccupied == null) {
      return const Color(0xFFB5BECE);
    }
    return isOccupied! ? const Color(0xFFE25757) : const Color(0xFF1C9B67);
  }

  String get _displayText {
    final label = node.label.trim();
    if (label.isEmpty) {
      return node.id.trim();
    }

    if (label.length <= 6) {
      return label.toUpperCase();
    }

    return label.substring(0, 6).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final cellColor = _cellColor;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 280),
      width: 36,
      height: 22,
      decoration: BoxDecoration(
        color: cellColor,
        borderRadius: BorderRadius.circular(4),
        border:
            Border.all(color: Colors.white.withValues(alpha: 0.8), width: 0.7),
        boxShadow: [
          BoxShadow(
            color: cellColor.withValues(alpha: 0.28),
            blurRadius: 4,
          ),
        ],
      ),
      alignment: Alignment.center,
      child: Text(
        _displayText,
        style: TextStyle(
          color: Colors.white,
          fontSize: _displayText.length > 4 ? 7 : 8,
          fontWeight: FontWeight.w700,
          height: 1,
        ),
      ),
    );
  }
}
