class RecentMapEntry {
  const RecentMapEntry({
    required this.organizationId,
    required this.organizationName,
    required this.siteId,
    required this.siteName,
    required this.buildingId,
    required this.buildingName,
    required this.floorId,
    required this.floorName,
    required this.mapVersionId,
    required this.mapName,
    required this.assetPath,
    required this.assetContentType,
    required this.usedAt,
  });

  final String organizationId;
  final String organizationName;
  final String siteId;
  final String siteName;
  final String buildingId;
  final String buildingName;
  final String floorId;
  final String floorName;
  final String mapVersionId;
  final String mapName;
  final String assetPath;
  final String assetContentType;
  final DateTime usedAt;

  factory RecentMapEntry.fromJson(Map<String, dynamic> json) {
    return RecentMapEntry(
      organizationId: json['organizationId'] as String,
      organizationName: json['organizationName'] as String,
      siteId: json['siteId'] as String,
      siteName: json['siteName'] as String,
      buildingId: json['buildingId'] as String,
      buildingName: json['buildingName'] as String,
      floorId: json['floorId'] as String,
      floorName: json['floorName'] as String,
      mapVersionId: json['mapVersionId'] as String,
      mapName: json['mapName'] as String,
      assetPath: json['assetPath'] as String,
      assetContentType: json['assetContentType'] as String,
      usedAt: DateTime.parse(json['usedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'organizationId': organizationId,
      'organizationName': organizationName,
      'siteId': siteId,
      'siteName': siteName,
      'buildingId': buildingId,
      'buildingName': buildingName,
      'floorId': floorId,
      'floorName': floorName,
      'mapVersionId': mapVersionId,
      'mapName': mapName,
      'assetPath': assetPath,
      'assetContentType': assetContentType,
      'usedAt': usedAt.toIso8601String(),
    };
  }
}
