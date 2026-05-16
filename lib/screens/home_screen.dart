import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../models/facility_models.dart';
import '../models/graph_data.dart';
import '../services/facility_service.dart';
import '../services/parking_service.dart';
import '../services/pathfinding_service.dart';
import '../widgets/park_bottom_sheet.dart';
import '../widgets/park_confirm_dialog.dart';
import '../widgets/park_suggestion_dialog.dart';
import 'map/map_bottom_panel.dart';
import 'map/map_panel_resolver.dart';
import 'map/map_screen_body.dart';

part 'map/map_screen_facility_actions.dart';
part 'map/map_screen_navigation_actions.dart';

class MapsScreen extends StatefulWidget {
  const MapsScreen({super.key, required this.onBack});

  final VoidCallback onBack;

  @override
  State<MapsScreen> createState() => MapsScreenState();
}

abstract class MapsScreenStateBase extends State<MapsScreen> {
  final _facilityService = FacilityService();
  final _pathfinder = PathfindingService();
  final _scannerController =
      MobileScannerController(detectionSpeed: DetectionSpeed.noDuplicates);
  final _sheetController = DraggableScrollableController();
  late final ParkingService _parkingService;

  List<OrganizationSummary> _organizations = [];
  OrganizationHierarchy? _hierarchy;
  SiteHierarchy? _site;
  BuildingHierarchy? _building;
  FloorHierarchy? _floor;
  PublishedMapData? _map;
  List<MapNode> _displayNodes = const [];
  List<MapNode> _mapNodes = const [];
  List<MapNode> _buildingDestinations = const [];
  String? _displayMapAssetPath;
  String? _displayMapAssetContentType;
  int? _displayMapWidth;
  int? _displayMapHeight;
  final Map<String, PublishedMapData> _publishedMapCache = {};

  bool _busy = false;
  bool _loading = true;
  String? _activityTitle;
  String? _activityMessage;
  MapNode? _targetPark;
  MapNode? _parkedAt;
  List<MapNode>? _route;
  MultiRouteResult? _multiRoute;
  int _activeRouteSegmentIndex = 0;
  String? _lastScan;
  DateTime? _lastScanTime;
  Map<String, bool> _occupancy = {};

  void _resetMapViewState({
    bool clearHierarchy = false,
    bool clearSite = false,
    bool clearBuilding = false,
    bool clearFloor = false,
    bool clearLastScan = false,
  }) {
    if (clearHierarchy) {
      _hierarchy = null;
    }
    if (clearSite) {
      _site = null;
    }
    if (clearBuilding) {
      _building = null;
    }
    if (clearFloor) {
      _floor = null;
    }
    if (clearLastScan) {
      _lastScan = null;
      _lastScanTime = null;
    }

    _map = null;
    _targetPark = null;
    _parkedAt = null;
    _route = null;
    _multiRoute = null;
    _activeRouteSegmentIndex = 0;
    _displayNodes = const [];
    _mapNodes = const [];
    _buildingDestinations = const [];
    _displayMapAssetPath = null;
    _displayMapAssetContentType = null;
    _displayMapWidth = null;
    _displayMapHeight = null;
    _occupancy = {};
  }

  void _showError(Object error);
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
  });
}

class MapsScreenState extends MapsScreenStateBase
    with _MapScreenFacilityActions, _MapScreenNavigationActions {
  @override
  void initState() {
    super.initState();
    _parkingService = ParkingService(onOccupancyChanged: _onOccupancyChanged);
    unawaited(_bootstrap());
  }

  @override
  void dispose() {
    _scannerController.dispose();
    _sheetController.dispose();
    _parkingService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final emptyCount =
        _occupancy.values.where((value) => value == false).length;
    final fullCount = _occupancy.values.where((value) => value == true).length;
    final hasMap = _map != null;
    final showInlineOverlay = _busy ||
        (_loading &&
            (_hierarchy != null ||
                _site != null ||
                _building != null ||
                _floor != null ||
                hasMap));
    final panelMode = _mapPanelMode;
    final destinationNodes = _destinationNodes;
    final mapBottomInset = hasMap
        ? MediaQuery.of(context).size.height * ParkBottomSheet.peekSize + 12
        : 0.0;
    final activeNodeId = _lastScan == null
        ? null
        : _displayNodes
            .where((node) => node.externalReferenceId == _lastScan)
            .firstOrNull
            ?.id;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: _loading && !showInlineOverlay
          ? const Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                MapScreenBody(
                  hasMap: hasMap,
                  isBusy: _busy,
                  showActivityOverlay: showInlineOverlay,
                  activityTitle: _activityTitle,
                  activityMessage: _activityMessage,
                  buildingTitle: _building?.name ?? 'Bina seçin',
                  mapBottomInset: mapBottomInset,
                  activeNodeId: activeNodeId,
                  displayNodes: _displayNodes,
                  navigationRoute: _route,
                  occupancy: _occupancy,
                  mapAssetPath: _displayMapAssetPath,
                  mapAssetContentType: _displayMapAssetContentType,
                  mapWidth: _displayMapWidth,
                  mapHeight: _displayMapHeight,
                  scannerController: _scannerController,
                  organizations: _organizations,
                  selectedOrganizationId: _hierarchy?.id,
                  sites: _availableSites,
                  selectedSiteId: _site?.id,
                  buildings: _availableBuildings,
                  selectedBuildingId: _building?.id,
                  floors: _availableFloors,
                  selectedFloorId: _floor?.id,
                  onBack: widget.onBack,
                  onClearSelectedMap: _clearSelectedMap,
                  onCollapseSheet: _collapseSheet,
                  onQrDetected: _onQrDetected,
                  onOrganizationChanged: _onOrganizationChanged,
                  onSiteChanged: _onSiteChanged,
                  onBuildingChanged: _onBuildingChanged,
                  onFloorChanged: _onFloorChanged,
                ),
                if (hasMap)
                  MapBottomPanel(
                    controller: _sheetController,
                    mode: panelMode,
                    occupancyMap: _occupancy,
                    targetPark: _targetPark,
                    parkedAt: _parkedAt,
                    mapName: _map?.name ?? 'Harita',
                    activeReference: _lastScan,
                    emptyCount: emptyCount,
                    fullCount: fullCount,
                    totalCount: _occupancy.length,
                    multiRoute: _multiRoute,
                    activeSegmentIndex: _activeRouteSegmentIndex,
                    parks: _mapNodes.where((node) => node.isPark).toList(),
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
  }) {
    _activityTitle = title;
    _activityMessage = message;
  }

  @override
  void _clearActivity() {
    _activityTitle = null;
    _activityMessage = null;
  }
}
