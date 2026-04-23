part of '../home_overview_screen.dart';

class _QuickLocationData {
  const _QuickLocationData({
    required this.organizationId,
    required this.organizationName,
    required this.siteId,
    required this.siteName,
    required this.buildingId,
    required this.buildingName,
    required this.floorId,
    required this.floorName,
  });

  final String organizationId;
  final String organizationName;
  final String siteId;
  final String siteName;
  final String buildingId;
  final String buildingName;
  final String floorId;
  final String floorName;
}

class _SiteListItemData {
  const _SiteListItemData({
    required this.organizationId,
    required this.organizationName,
    required this.siteId,
    required this.siteName,
    required this.buildingCount,
    required this.readyFloorCount,
  });

  final String organizationId;
  final String organizationName;
  final String siteId;
  final String siteName;
  final int buildingCount;
  final int readyFloorCount;
}
