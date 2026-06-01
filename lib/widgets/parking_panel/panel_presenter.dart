part of '../park_bottom_sheet.dart';

class _ParkBottomSheetPresenter {
  const _ParkBottomSheetPresenter({
    required this.mode,
    required this.mapName,
    required this.activeReference,
    required this.currentFloorId,
    required this.currentFloorName,
    required this.emptyCount,
    required this.fullCount,
    required this.totalCount,
    required this.parks,
    required this.destinations,
  });

  final MapPanelMode mode;
  final String mapName;
  final String? activeReference;
  final String? currentFloorId;
  final String? currentFloorName;
  final int emptyCount;
  final int fullCount;
  final int totalCount;
  final List<MapNode> parks;
  final List<MapNode> destinations;

  bool get isParking => mode == MapPanelMode.parking;

  String get panelTitle {
    return switch (mode) {
      MapPanelMode.parking => 'Park alanları',
      MapPanelMode.hospital => 'Hastane hedefleri',
      MapPanelMode.mall => 'AVM hedefleri',
      MapPanelMode.other => 'Navigasyon hedefleri',
    };
  }

  String get destinationTitle {
    return switch (mode) {
      MapPanelMode.parking =>
        destinations.isNotEmpty ? 'Hedefler' : 'Park alanları',
      MapPanelMode.hospital => 'Bölümler',
      MapPanelMode.mall => 'Mağazalar',
      MapPanelMode.other => 'Noktalar',
    };
  }

  String get searchHintText {
    return switch (mode) {
      MapPanelMode.parking => 'Park, giriş veya çıkış ara',
      MapPanelMode.hospital => 'Bölüm, giriş veya asansör ara',
      MapPanelMode.mall => 'Mağaza, giriş veya kat geçişi ara',
      MapPanelMode.other => 'Hedef, giriş veya çıkış ara',
    };
  }

  String get summaryText {
    if (isParking) {
      return '$emptyCount boş · $fullCount dolu';
    }

    return '';
  }

  IconData get modeIcon {
    return switch (mode) {
      MapPanelMode.parking => Icons.local_parking_rounded,
      MapPanelMode.hospital => Icons.local_hospital_rounded,
      MapPanelMode.mall => Icons.store_mall_directory_rounded,
      MapPanelMode.other => Icons.navigation_rounded,
    };
  }

  List<MapNode> targetsForPanel() {
    if (!isParking) {
      return destinations.where((node) => !node.isQr).toList()
        ..sort(_compareTargets);
    }

    if (destinations.isEmpty) {
      return parks.toList()..sort(_compareTargets);
    }

    final nodesByKey = <String, MapNode>{};
    for (final park in parks) {
      nodesByKey[(park.externalReferenceId ?? park.id).toUpperCase()] = park;
    }
    for (final destination in destinations.where((node) => !node.isQr)) {
      nodesByKey[(destination.externalReferenceId ?? destination.id)
          .toUpperCase()] = destination;
    }

    return nodesByKey.values.toList()..sort(_compareTargets);
  }

  List<TargetGroup> targetGroupsForPanel({String query = ''}) {
    final normalizedQuery = normalizeSearchText(query);
    final grouped = <String, TargetGroup>{};
    for (final node in targetsForPanel().where(
      (node) => _matchesQuery(node, normalizedQuery),
    )) {
      final floorId = node.floorId ?? currentFloorId ?? 'current';
      final floorName = node.floorName ?? currentFloorName ?? 'Bu kat';
      final isCurrent = _isCurrentFloor(floorId, floorName);
      final existing = grouped[floorId];
      if (existing == null) {
        grouped[floorId] = TargetGroup(
          floorId: floorId,
          title: floorName,
          sectionTitle: isCurrent ? 'Bu katta öne çıkanlar' : 'Diğer katlar',
          nodes: [node],
          isCurrentFloor: isCurrent,
        );
        continue;
      }

      existing.nodes.add(node);
    }

    final groups = grouped.values.toList()
      ..sort((left, right) {
        if (left.isCurrentFloor != right.isCurrentFloor) {
          return left.isCurrentFloor ? -1 : 1;
        }
        return compareNodeLabelsNatural(left.title, right.title);
      });

    for (final group in groups) {
      group.nodes.sort(_compareTargets);
    }

    return groups;
  }

  bool _matchesQuery(MapNode node, String normalizedQuery) {
    if (normalizedQuery.isEmpty) {
      return true;
    }

    final searchable = [
      node.displayLabel,
      node.label,
      node.id,
      node.externalReferenceId ?? '',
      node.floorName ?? '',
    ].map(normalizeSearchText).join(' ');

    return searchable.contains(normalizedQuery);
  }

  int _compareTargets(MapNode left, MapNode right) {
    final score = _targetPriority(left).compareTo(_targetPriority(right));
    if (score != 0) {
      return score;
    }

    return compareNodeLabelsNatural(left.displayLabel, right.displayLabel);
  }

  int _targetPriority(MapNode node) {
    return switch (mode) {
      MapPanelMode.parking => switch (node.type) {
          NodeType.park => 0,
          NodeType.parkingExit => 1,
          NodeType.parkingEntrance => 2,
          NodeType.entrance => 3,
          NodeType.exit => 4,
          NodeType.elevator || NodeType.stair => 5,
          NodeType.other => 6,
          NodeType.qr => 7,
        },
      MapPanelMode.hospital => switch (node.type) {
          NodeType.entrance => 0,
          NodeType.other => 1,
          NodeType.elevator || NodeType.stair => 2,
          NodeType.exit => 3,
          NodeType.parkingEntrance || NodeType.parkingExit => 4,
          NodeType.park => 5,
          NodeType.qr => 6,
        },
      MapPanelMode.mall => switch (node.type) {
          NodeType.other => 0,
          NodeType.entrance => 1,
          NodeType.elevator || NodeType.stair => 2,
          NodeType.exit => 3,
          NodeType.park => 4,
          NodeType.parkingEntrance || NodeType.parkingExit => 5,
          NodeType.qr => 6,
        },
      MapPanelMode.other => switch (node.type) {
          NodeType.entrance => 0,
          NodeType.other => 1,
          NodeType.elevator || NodeType.stair => 2,
          NodeType.exit => 3,
          NodeType.parkingEntrance || NodeType.parkingExit => 4,
          NodeType.park => 5,
          NodeType.qr => 6,
        },
    };
  }

  bool _isCurrentFloor(String floorId, String floorName) {
    final currentId = currentFloorId?.trim();
    if (currentId?.isNotEmpty == true) {
      return floorId == currentId;
    }

    final currentName = currentFloorName?.trim();
    return currentName?.isNotEmpty == true && floorName == currentName;
  }
}

class TargetGroup {
  TargetGroup({
    required this.floorId,
    required this.title,
    required this.sectionTitle,
    required this.nodes,
    required this.isCurrentFloor,
  });

  final String floorId;
  final String title;
  final String sectionTitle;
  final List<MapNode> nodes;
  final bool isCurrentFloor;
}
