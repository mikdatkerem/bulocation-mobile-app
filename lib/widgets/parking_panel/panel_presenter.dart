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
      MapPanelMode.parking => 'Rota ve park alanları',
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
      return '$emptyCount boş · $fullCount dolu · $totalCount toplam';
    }

    final active = activeReference ?? 'QR bekleniyor';
    return '${destinations.length} hedef · başlangıç $active';
  }

  String get headerHelperText {
    return switch (mode) {
      MapPanelMode.parking =>
        'Canlı doluluk takibi ile uygun alan ve çıkış yönlendirmesi',
      MapPanelMode.hospital =>
        'Bölümler, giriş bağlantıları ve kat geçişleri burada listelenir',
      MapPanelMode.mall =>
        'Mağaza, servis noktası ve çıkış hedefleri buradan açılır',
      MapPanelMode.other =>
        'Haritadaki hedefler ve bağlantı noktaları buradan yönetilir',
    };
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
      return destinations;
    }

    if (destinations.isEmpty) {
      return parks;
    }

    final nodesByKey = <String, MapNode>{};
    for (final park in parks) {
      nodesByKey[(park.externalReferenceId ?? park.id).toUpperCase()] = park;
    }
    for (final destination in destinations) {
      nodesByKey[(destination.externalReferenceId ?? destination.id).toUpperCase()] =
          destination;
    }

    final nodes = nodesByKey.values.toList()
      ..sort((left, right) => compareNodeLabelsNatural(left.label, right.label));
    return nodes;
  }
}
