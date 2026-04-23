part of '../home_screen.dart';

mixin _MapScreenFacilityActions on MapsScreenStateBase {
  Future<void> _bootstrap() async {
    await _loadFacilityContext();
    await _parkingService.startListening();
  }

  Future<void> _loadFacilityContext() async {
    try {
      final organizations = await _facilityService.getOrganizations();
      if (!mounted) {
        return;
      }

      setState(() {
        _organizations = organizations;
        _loading = false;
      });
    } catch (error) {
      if (!mounted) {
        return;
      }

      setState(() => _loading = false);
      _showError(error);
    }
  }

  List<SiteHierarchy> get _availableSites => _hierarchy?.sites ?? const [];

  List<BuildingHierarchy> get _availableBuildings =>
      _site?.buildings ?? const [];

  List<FloorHierarchy> get _availableFloors =>
      _building?.floors.where((item) => item.hasPublishedMap).toList() ??
      const [];

  Future<void> _onOrganizationChanged(String? organizationId) async {
    if (organizationId == null) {
      return;
    }

    setState(() {
      _loading = true;
      _hierarchy = null;
      _site = null;
      _building = null;
      _floor = null;
      _map = null;
      _route = null;
      _multiRoute = null;
      _targetPark = null;
      _displayNodes = const [];
      _mapNodes = const [];
      _displayMapAssetPath = null;
      _displayMapAssetContentType = null;
      _displayMapWidth = null;
      _displayMapHeight = null;
      _occupancy = {};
    });

    try {
      final hierarchy =
          await _facilityService.getOrganizationHierarchy(organizationId);
      if (!mounted) {
        return;
      }

      setState(() {
        _hierarchy = hierarchy;
        _loading = false;
      });
    } catch (error) {
      if (!mounted) {
        return;
      }

      setState(() => _loading = false);
      _showError(error);
    }
  }

  void _onSiteChanged(String? siteId) {
    if (siteId == null || _hierarchy == null) {
      return;
    }

    final site =
        _hierarchy!.sites.where((item) => item.id == siteId).firstOrNull;
    if (site == null) {
      return;
    }

    setState(() {
      _site = site;
      _building = null;
      _floor = null;
      _map = null;
      _route = null;
      _multiRoute = null;
      _targetPark = null;
      _displayNodes = const [];
      _mapNodes = const [];
      _displayMapAssetPath = null;
      _displayMapAssetContentType = null;
      _displayMapWidth = null;
      _displayMapHeight = null;
      _occupancy = {};
    });
  }

  void _onBuildingChanged(String? buildingId) {
    if (buildingId == null || _site == null) {
      return;
    }

    final building =
        _site!.buildings.where((item) => item.id == buildingId).firstOrNull;
    if (building == null) {
      return;
    }

    setState(() {
      _building = building;
      _floor = null;
      _map = null;
      _route = null;
      _multiRoute = null;
      _targetPark = null;
      _displayNodes = const [];
      _mapNodes = const [];
      _displayMapAssetPath = null;
      _displayMapAssetContentType = null;
      _displayMapWidth = null;
      _displayMapHeight = null;
      _occupancy = {};
    });
  }

  Future<void> _onFloorChanged(String? floorId) async {
    if (floorId == null ||
        _hierarchy == null ||
        _site == null ||
        _building == null) {
      return;
    }

    final floor =
        _building!.floors.where((item) => item.id == floorId).firstOrNull;
    if (floor == null) {
      return;
    }

    await _applySelection(
      hierarchy: _hierarchy!,
      site: _site!,
      building: _building!,
      floor: floor,
    );
  }

  void _clearSelectedMap() {
    setState(() {
      _site = null;
      _building = null;
      _floor = null;
      _map = null;
      _route = null;
      _multiRoute = null;
      _targetPark = null;
      _displayNodes = const [];
      _mapNodes = const [];
      _displayMapAssetPath = null;
      _displayMapAssetContentType = null;
      _displayMapWidth = null;
      _displayMapHeight = null;
      _occupancy = {};
      _lastScan = null;
    });
  }

  Future<void> _loadOccupancy() async {
    final floor = _floor;
    if (floor == null) {
      return;
    }

    try {
      final occupancy = await _parkingService.getOccupancyMap(floor.id);
      if (mounted) {
        setState(() => _occupancy = _normalizeOccupancy(occupancy));
      }
    } catch (error) {
      if (mounted) {
        _showError('Park durumu yuklenemedi: $error');
      }
    }
  }

  @override
  Map<String, bool> _normalizeOccupancy(Map<String, bool> occupancy) =>
      occupancy.map((key, value) => MapEntry(key.toUpperCase(), value));

  @override
  Future<PublishedMapData> _getPublishedMap(String floorId) async {
    final cached = _publishedMapCache[floorId];
    if (cached != null) {
      return cached;
    }

    final publishedMap = await _facilityService.getPublishedMap(floorId);
    _publishedMapCache[floorId] = publishedMap;
    return publishedMap;
  }

  @override
  Future<void> _applySelection({
    required OrganizationHierarchy hierarchy,
    required SiteHierarchy site,
    required BuildingHierarchy building,
    required FloorHierarchy floor,
    List<OrganizationSummary>? organizations,
  }) async {
    if (mounted) {
      setState(() => _loading = true);
    }

    final publishedMap = await _getPublishedMap(floor.id);

    if (!mounted) {
      return;
    }

    setState(() {
      _organizations = organizations ?? _organizations;
      _hierarchy = hierarchy;
      _site = site;
      _building = building;
      _floor = floor;
      _map = publishedMap;
      _displayNodes = publishedMap.nodes;
      _mapNodes = publishedMap.nodes;
      _displayMapAssetPath = publishedMap.assetPath;
      _displayMapAssetContentType = publishedMap.assetContentType;
      _displayMapWidth = publishedMap.width;
      _displayMapHeight = publishedMap.height;
      _loading = false;
      _targetPark = null;
      _route = null;
      _multiRoute = null;
      _activeRouteSegmentIndex = 0;
      _lastScan = null;
    });

    await _loadOccupancy();
  }

  void _onOccupancyChanged(String spotId, bool isOccupied) {
    if (!mounted) {
      return;
    }

    final key = spotId.toUpperCase();
    if (!_occupancy.containsKey(key)) {
      return;
    }

    final wasEmpty = _occupancy[key] == false;
    setState(() => _occupancy[key] = isOccupied);
    final targetRef =
        (_targetPark?.externalReferenceId ?? _targetPark?.id)?.toUpperCase();
    if (isOccupied && wasEmpty && targetRef == key) {
      _showParkConfirmDialog(key);
    }
  }
}
