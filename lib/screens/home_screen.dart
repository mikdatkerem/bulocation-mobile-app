import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../models/facility_models.dart';
import '../models/graph_data.dart';
import '../models/recent_map.dart';
import '../services/facility_service.dart';
import '../services/parking_service.dart';
import '../services/pathfinding_service.dart';
import '../services/recent_maps_storage.dart';
import '../widgets/park_bottom_sheet.dart';
import '../widgets/park_confirm_dialog.dart';
import '../widgets/park_suggestion_dialog.dart';
import 'map/map_bottom_panel.dart';
import 'map/map_panel_resolver.dart';
import 'map/map_screen_notice.dart';
import 'map/map_screen_body.dart';
import 'map/map_screen_skeleton.dart';
import 'map/map_screen_state_controller.dart';

part 'map/map_screen_facility_actions.dart';
part 'map/map_screen_panel_actions.dart';
part 'map/map_screen_qr_actions.dart';
part 'map/map_screen_route_actions.dart';

class MapsScreen extends StatefulWidget {
  const MapsScreen({super.key, required this.onBack});

  final VoidCallback onBack;

  @override
  State<MapsScreen> createState() => MapsScreenState();
}

abstract class MapsScreenStateBase extends State<MapsScreen> {
  final _facilityService = FacilityService();
  final _pathfinder = PathfindingService();
  final _scannerController = MobileScannerController(
    autoStart: false,
    detectionSpeed: DetectionSpeed.noDuplicates,
  );
  final _sheetController = DraggableScrollableController();
  final _mapState = MapScreenStateController();
  final List<MapScreenNotice> _notices = [];
  late final ParkingService _parkingService;
  int _nextNoticeId = 0;

  void _resetMapViewState({
    bool clearHierarchy = false,
    bool clearSite = false,
    bool clearBuilding = false,
    bool clearFloor = false,
    bool clearLastScan = false,
  }) =>
      _mapState.resetMapViewState(
        clearHierarchy: clearHierarchy,
        clearSite: clearSite,
        clearBuilding: clearBuilding,
        clearFloor: clearFloor,
        clearLastScan: clearLastScan,
      );

  void _showError(Object error);
  void _showNotice({
    required String title,
    String? message,
    MapScreenNoticeLevel level = MapScreenNoticeLevel.info,
  });
  void _showParkConfirmDialog(String spotId);
  Map<String, bool> _normalizeOccupancy(Map<String, bool> occupancy);
  Future<PublishedMapData> _getPublishedMap(String floorId);
  void _setActivity({
    required String title,
    required String message,
  });
  void _clearActivity();
  Future<void> _applySelection({
    required OrganizationHierarchy hierarchy,
    required SiteHierarchy site,
    required BuildingHierarchy building,
    required FloorHierarchy floor,
    bool preserveNavigation = false,
  });
  Future<void> _updateRoute(String fromReferenceId);
  // ignore: unused_element
  Future<void> _showRouteSegment(int index);
  void _showSuggestionDialog();
  void _collapseSheet();
  String? _activeStartReference();
  MapPanelMode get _mapPanelMode;
}

class MapsScreenState extends MapsScreenStateBase
    with
        WidgetsBindingObserver,
        _MapScreenFacilityActions,
        _MapScreenPanelActions,
        _MapScreenRouteActions,
        _MapScreenQrActions {
  bool _scannerVisible = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _parkingService = ParkingService(onOccupancyChanged: _onOccupancyChanged);
    unawaited(_bootstrap());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _scannerController.dispose();
    _sheetController.dispose();
    _parkingService.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && _scannerVisible) {
      unawaited(_startScanner());
      return;
    }

    if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached) {
      unawaited(_stopScanner());
    }
  }

  Future<void> activateScanner() async {
    _scannerVisible = true;
    await _startScanner();
  }

  Future<void> deactivateScanner() async {
    _scannerVisible = false;
    await _stopScanner();
  }

  Future<void> _startScanner() async {
    if (_scannerController.value.isRunning) {
      return;
    }

    try {
      await _scannerController.start();
    } on MobileScannerException catch (error) {
      if (mounted) {
        _showNotice(
          title: 'Kamera açılamadı',
          message: _scannerErrorMessage(error),
          level: MapScreenNoticeLevel.warning,
        );
      }
    } catch (_) {
      if (mounted) {
        _showNotice(
          title: 'Kamera açılamadı',
          message: 'Kamera başlatılamadı. İzinleri kontrol edin.',
          level: MapScreenNoticeLevel.warning,
        );
      }
    }
  }

  Future<void> _stopScanner() async {
    if (!_scannerController.value.isRunning) {
      return;
    }

    try {
      await _scannerController.stop();
    } catch (_) {
      // Kamera zaten kapanmış olabilir; görünürlük değişiminde sessiz geçiyoruz.
    }
  }

  String _scannerErrorMessage(MobileScannerException error) {
    return switch (error.errorCode) {
      MobileScannerErrorCode.permissionDenied =>
        'Kamera izni kapalı. Uygulama izinlerinden kamerayı açın.',
      MobileScannerErrorCode.unsupported =>
        'Bu cihazda kamera ile QR okuma desteklenmiyor.',
      _ => 'Kamera başlatılamadı. Lütfen tekrar deneyin.',
    };
  }

  @override
  Widget build(BuildContext context) {
    final state = _mapState;
    final emptyCount =
        state.occupancy.values.where((value) => value == false).length;
    final fullCount =
        state.occupancy.values.where((value) => value == true).length;
    final hasMap = state.map != null;
    final showInlineOverlay = state.busy ||
        (state.loading &&
            (state.hierarchy != null ||
                state.site != null ||
                state.building != null ||
                state.floor != null ||
                hasMap));
    final panelMode = _mapPanelMode;
    final destinationNodes = _destinationNodes;
    final mapBottomInset = hasMap
        ? MediaQuery.of(context).size.height * ParkBottomSheet.peekSize + 4
        : 0.0;
    final activeReference = _activeStartReference()?.toUpperCase();
    final activeNodeId = activeReference == null
        ? null
        : state.displayNodes
            .where((node) =>
                (node.externalReferenceId ?? node.id).toUpperCase() ==
                activeReference)
            .firstOrNull
            ?.id;
    final routeStatusTitle = _routeStatusTitle(panelMode);
    final routeStatusMessage = _routeStatusMessage(panelMode);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: state.loading && !showInlineOverlay
          ? MapScreenSkeleton(onBack: widget.onBack)
          : Stack(
              children: [
                MapScreenBody(
                  hasMap: hasMap,
                  isBusy: state.busy,
                  showActivityOverlay: showInlineOverlay,
                  activityTitle: state.activityTitle,
                  activityMessage: state.activityMessage,
                  buildingTitle: state.building?.name ?? 'Bina seçin',
                  routeStatusTitle: routeStatusTitle,
                  routeStatusMessage: routeStatusMessage,
                  mapBottomInset: mapBottomInset,
                  activeNodeId: activeNodeId,
                  displayNodes: state.displayNodes,
                  navigationRoute: state.route,
                  occupancy: state.occupancy,
                  mapAssetPath: state.displayMapAssetPath,
                  mapAssetContentType: state.displayMapAssetContentType,
                  mapWidth: state.displayMapWidth,
                  mapHeight: state.displayMapHeight,
                  notices: _notices,
                  scannerController: _scannerController,
                  organizations: state.organizations,
                  selectedOrganizationId: state.hierarchy?.id,
                  sites: _availableSites,
                  selectedSiteId: state.site?.id,
                  buildings: _availableBuildings,
                  selectedBuildingId: state.building?.id,
                  floors: _availableFloors,
                  selectedFloorId: state.floor?.id,
                  onBack: widget.onBack,
                  onDismissNotice: _dismissNotice,
                  onCollapseSheet: _collapseSheet,
                  onQrDetected: _onQrDetected,
                  onOrganizationChanged: _onOrganizationChanged,
                  onSiteChanged: _onSiteChanged,
                  onBuildingChanged: _onBuildingChanged,
                  onFloorChanged: _onFloorChanged,
                  onMapNodeSelected: _selectParkTarget,
                ),
                if (hasMap)
                  MapBottomPanel(
                    controller: _sheetController,
                    mode: panelMode,
                    occupancyMap: state.occupancy,
                    targetPark: state.targetPark,
                    parkedAt: state.parkedAt,
                    mapName: state.map?.name ?? 'Harita',
                    currentFloorId: state.floor?.id,
                    currentFloorName: state.floor?.name,
                    activeReference: state.lastScan,
                    emptyCount: emptyCount,
                    fullCount: fullCount,
                    totalCount: state.occupancy.length,
                    multiRoute: state.multiRoute,
                    activeSegmentIndex: state.activeRouteSegmentIndex,
                    parks: state.mapNodes.where((node) => node.isPark).toList(),
                    destinations: destinationNodes,
                    onSegmentTap: (index) =>
                        unawaited(_showRouteSegment(index)),
                    onParkSelected: _selectParkTarget,
                    onNavigateToExit: () => unawaited(_navigateToBestExit()),
                    onNavigateToCar: _navigateToCar,
                    onClearNav: _clearNavigation,
                    onNearestToUser: _navigateToNearestToUser,
                    onNearestToHospital: () =>
                        unawaited(_selectParkingNearEntrance()),
                  ),
              ],
            ),
    );
  }

  @override
  void _setActivity({
    required String title,
    required String message,
  }) =>
      _mapState.setActivity(title: title, message: message);

  @override
  void _clearActivity() => _mapState.clearActivity();

  String? _routeStatusTitle(MapPanelMode panelMode) {
    final state = _mapState;
    if (state.busy || state.loading) {
      return null;
    }

    if (state.targetPark != null &&
        (state.route?.isNotEmpty == true || state.multiRoute != null)) {
      return panelMode == MapPanelMode.parking
          ? '${state.targetPark!.displayLabel} için rota hazır'
          : 'Seçili hedef için rota hazır';
    }

    if (state.targetPark != null) {
      return panelMode == MapPanelMode.parking
          ? '${state.targetPark!.displayLabel} hedef olarak seçildi'
          : 'Hedef seçildi';
    }

    if (state.lastScan != null) {
      return 'Konum doğrulandı';
    }

    if (state.map != null) {
      return 'Harita hazır';
    }

    return null;
  }

  String? _routeStatusMessage(MapPanelMode panelMode) {
    final state = _mapState;
    if (state.busy || state.loading) {
      return null;
    }

    if (state.targetPark != null && state.multiRoute != null) {
      final segmentCount = state.multiRoute!.segments.length;
      final segmentLabel =
          segmentCount > 1 ? '$segmentCount kat adımı' : 'tek kat yönlendirme';
      final distanceLabel = state.multiRoute!.distanceLabel;
      return '$segmentLabel · $distanceLabel';
    }

    if (state.targetPark != null && state.route?.isNotEmpty == true) {
      return panelMode == MapPanelMode.parking
          ? 'Park alanına yönlendirme aktif.'
          : 'Seçili hedefe yönlendirme aktif.';
    }

    if (state.targetPark != null) {
      return 'Rota birkaç saniye içinde hazır olur.';
    }

    if (state.lastScan != null) {
      return 'Şimdi hedef seçebilir veya önerilen aksiyonlardan devam edebilirsiniz.';
    }

    if (state.map != null) {
      return 'Başlamak için QR okutun veya alttaki aksiyonları kullanın.';
    }

    return null;
  }
}
