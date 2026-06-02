import '../../models/facility_models.dart';
import '../../models/graph_data.dart';
import '../../services/pathfinding_service.dart';

class MapScreenStateController {
  List<OrganizationSummary> organizations = [];
  OrganizationHierarchy? hierarchy;
  SiteHierarchy? site;
  BuildingHierarchy? building;
  FloorHierarchy? floor;
  PublishedMapData? map;
  List<MapNode> displayNodes = const [];
  List<MapNode> mapNodes = const [];
  List<MapNode> buildingDestinations = const [];
  String? displayMapAssetPath;
  String? displayMapAssetContentType;
  int? displayMapWidth;
  int? displayMapHeight;
  final Map<String, PublishedMapData> publishedMapCache = {};

  bool busy = false;
  bool loading = true;
  String? activityTitle;
  String? activityMessage;
  MapNode? targetPark;
  MapNode? parkedAt;
  List<MapNode>? route;
  List<MapNode>? singleFloorRoute;
  String? singleFloorRouteFloorId;
  MultiRouteResult? multiRoute;
  int activeRouteSegmentIndex = 0;
  String? lastScan;
  DateTime? lastScanTime;
  Map<String, bool> occupancy = {};

  void resetMapViewState({
    bool clearHierarchy = false,
    bool clearSite = false,
    bool clearBuilding = false,
    bool clearFloor = false,
    bool clearLastScan = false,
  }) {
    if (clearHierarchy) {
      hierarchy = null;
    }
    if (clearSite) {
      site = null;
    }
    if (clearBuilding) {
      building = null;
    }
    if (clearFloor) {
      floor = null;
    }
    if (clearLastScan) {
      lastScan = null;
      lastScanTime = null;
    }

    map = null;
    targetPark = null;
    parkedAt = null;
    route = null;
    singleFloorRoute = null;
    singleFloorRouteFloorId = null;
    multiRoute = null;
    activeRouteSegmentIndex = 0;
    displayNodes = const [];
    mapNodes = const [];
    buildingDestinations = const [];
    displayMapAssetPath = null;
    displayMapAssetContentType = null;
    displayMapWidth = null;
    displayMapHeight = null;
    occupancy = {};
  }

  void setActivity({
    required String title,
    required String message,
  }) {
    activityTitle = title;
    activityMessage = message;
  }

  void clearActivity() {
    activityTitle = null;
    activityMessage = null;
  }
}
