part of '../home_guide_screen.dart';

enum _GuideArtworkType {
  qrStart,
  mapOpen,
  routeGo,
}

class _GuideSlideData {
  const _GuideSlideData({
    required this.stepLabel,
    required this.title,
    required this.headline,
    required this.description,
    required this.cta,
    required this.accent,
    required this.secondary,
    required this.type,
    required this.highlights,
  });

  final String stepLabel;
  final String title;
  final String headline;
  final String description;
  final String cta;
  final Color accent;
  final Color secondary;
  final _GuideArtworkType type;
  final List<String> highlights;
}
