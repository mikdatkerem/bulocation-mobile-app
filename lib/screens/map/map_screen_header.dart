import 'package:flutter/material.dart';

import '../../models/facility_models.dart';
import 'map_floor_picker.dart';

class MapScreenHeader extends StatelessWidget {
  const MapScreenHeader({
    super.key,
    required this.title,
    required this.floors,
    required this.selectedFloorId,
    required this.routeFloorIds,
    required this.onBack,
    required this.onFloorChanged,
  });

  final String title;
  final List<FloorHierarchy> floors;
  final String? selectedFloorId;
  final Set<String> routeFloorIds;
  final VoidCallback onBack;
  final ValueChanged<String?> onFloorChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 10, 16, 0),
      child: Row(
        children: [
          IconButton(
            onPressed: onBack,
            icon: const Icon(Icons.arrow_back_ios_new_rounded),
            style: IconButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: const Color(0xFF182033),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _MarqueeTitle(
              title,
            ),
          ),
          const SizedBox(width: 10),
          MapFloorPicker(
            floors: floors,
            selectedFloorId: selectedFloorId,
            routeFloorIds: routeFloorIds,
            onFloorChanged: onFloorChanged,
          ),
        ],
      ),
    );
  }
}

class _MarqueeTitle extends StatefulWidget {
  const _MarqueeTitle(this.title);

  final String title;

  @override
  State<_MarqueeTitle> createState() => _MarqueeTitleState();
}

class _MarqueeTitleState extends State<_MarqueeTitle> {
  late final ScrollController _controller;

  @override
  void initState() {
    super.initState();
    _controller = ScrollController();
    WidgetsBinding.instance.addPostFrameCallback((_) => _startMarquee());
  }

  @override
  void didUpdateWidget(covariant _MarqueeTitle oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.title == widget.title) {
      return;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) => _startMarquee());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _startMarquee() async {
    if (!mounted || !_controller.hasClients) {
      return;
    }

    await _controller.animateTo(
      0,
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOut,
    );

    final maxScroll = _controller.position.maxScrollExtent;
    if (maxScroll <= 1 || !mounted) {
      return;
    }

    await Future<void>.delayed(const Duration(milliseconds: 900));
    if (!mounted || !_controller.hasClients) {
      return;
    }

    await _controller.animateTo(
      maxScroll,
      duration:
          Duration(milliseconds: (maxScroll * 42).clamp(2600, 6200).round()),
      curve: Curves.linear,
    );
    if (!mounted || !_controller.hasClients) {
      return;
    }

    await Future<void>.delayed(const Duration(milliseconds: 800));
    if (!mounted || !_controller.hasClients) {
      return;
    }

    await _controller.animateTo(
      0,
      duration: const Duration(milliseconds: 520),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      shaderCallback: (bounds) {
        return const LinearGradient(
          colors: [
            Colors.transparent,
            Colors.black,
            Colors.black,
            Colors.transparent,
          ],
          stops: [0, 0.08, 0.92, 1],
        ).createShader(bounds);
      },
      blendMode: BlendMode.dstIn,
      child: SingleChildScrollView(
        controller: _controller,
        scrollDirection: Axis.horizontal,
        physics: const NeverScrollableScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 2),
          child: Text(
            widget.title,
            maxLines: 1,
            softWrap: false,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Color(0xFF182033),
            ),
          ),
        ),
      ),
    );
  }
}
