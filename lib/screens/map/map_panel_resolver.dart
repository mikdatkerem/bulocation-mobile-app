import '../../models/facility_models.dart';
import '../../models/graph_data.dart';
import '../../widgets/park_bottom_sheet.dart';

MapPanelMode resolveMapPanelMode({
  required SiteHierarchy? site,
  required BuildingHierarchy? building,
  required FloorHierarchy? floor,
}) {
  final buildingType = _normalizeType(building?.buildingType);
  final siteType = _normalizeType(site?.siteType);
  final buildingName = _normalizeType(building?.name);
  final siteName = _normalizeType(site?.name);
  final floorName = _normalizeType(floor?.name);

  if (buildingType == '4' ||
      buildingType == 'parking' ||
      siteType == '2' ||
      siteType == 'parkingcampus' ||
      buildingName.contains('otopark') ||
      buildingName.contains('parking') ||
      floorName.contains('otopark') ||
      floorName.contains('parking')) {
    return MapPanelMode.parking;
  }

  if (siteType == '1' ||
      siteType == 'hospital' ||
      buildingType == '2' ||
      buildingType == 'clinic' ||
      buildingType == '3' ||
      buildingType == 'emergency' ||
      siteName.contains('hastane') ||
      siteName.contains('hospital') ||
      buildingName.contains('hastane') ||
      buildingName.contains('hospital')) {
    return MapPanelMode.hospital;
  }

  if (siteType == '3' ||
      siteType == 'mall' ||
      siteName.contains('avm') ||
      siteName.contains('mall') ||
      buildingName.contains('avm') ||
      buildingName.contains('mall')) {
    return MapPanelMode.mall;
  }

  return MapPanelMode.other;
}

List<MapNode> resolveDestinationNodes({
  required List<MapNode> mapNodes,
  required MapPanelMode mode,
}) {
  final destinations = mapNodes
      .where(
        (node) => !node.isQr && (mode == MapPanelMode.parking || !node.isPark),
      )
      .toList()
    ..sort((left, right) {
      final score = _nodeSortScore(left).compareTo(_nodeSortScore(right));
      if (score != 0) {
        return score;
      }
      return left.label.compareTo(right.label);
    });

  return destinations;
}

int _nodeSortScore(MapNode node) {
  return switch (node.type) {
    NodeType.entrance => 0,
    NodeType.exit => 1,
    NodeType.elevator => 2,
    NodeType.stair => 2,
    NodeType.parkingEntrance => 2,
    NodeType.parkingExit => 2,
    NodeType.other => 3,
    NodeType.park => 4,
    NodeType.qr => 5,
  };
}

String _normalizeType(String? value) {
  return (value ?? '').trim().toLowerCase().replaceAll(RegExp(r'[\s_\-]'), '');
}
