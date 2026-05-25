part of '../park_bottom_sheet.dart';

class _ParkBottomSheetPresenter {
  const _ParkBottomSheetPresenter({
    required this.mode,
    required this.mapName,
    required this.activeReference,
    required this.emptyCount,
    required this.fullCount,
    required this.totalCount,
    required this.parks,
    required this.destinations,
  });

  final MapPanelMode mode;
  final String mapName;
  final String? activeReference;
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
        ..sort((left, right) =>
            compareNodeLabelsNatural(left.displayLabel, right.displayLabel));
    }

    if (destinations.isEmpty) {
      return parks;
    }

    final nodesByKey = <String, MapNode>{};
    for (final park in parks) {
      nodesByKey[(park.externalReferenceId ?? park.id).toUpperCase()] = park;
    }
    for (final destination in destinations.where((node) => !node.isQr)) {
      nodesByKey[(destination.externalReferenceId ?? destination.id)
          .toUpperCase()] = destination;
    }

    final nodes = nodesByKey.values.toList()
      ..sort((left, right) =>
          compareNodeLabelsNatural(left.displayLabel, right.displayLabel));
    return nodes;
  }
}
