part of '../home_screen.dart';

mixin _MapScreenFacilityActions on MapsScreenStateBase {
  Future<void> _bootstrap() async {
    await _loadFacilityContext();
    try {
      await _parkingService.startListening();
    } catch (_) {
      // Canlı doluluk akışı geç bağlansa bile temel ekran kullanılabilsin.
    }
  }

  Future<void> _loadFacilityContext() async {
    try {
      final organizations = await _facilityService.getOrganizations();
      if (!mounted) {
        return;
      }

      setState(() {
        _mapState.organizations = organizations;
        _mapState.loading = false;
      });
    } catch (error) {
      if (!mounted) {
        return;
      }

      setState(() => _mapState.loading = false);
      _showError(error);
    }
  }

  List<SiteHierarchy> get _availableSites =>
      _mapState.hierarchy?.sites ?? const [];

  List<BuildingHierarchy> get _availableBuildings =>
      _mapState.site?.buildings ?? const [];

  List<FloorHierarchy> get _availableFloors =>
      _mapState.building?.floors
          .where((item) => item.hasPublishedMap)
          .toList() ??
      const [];

  Future<void> _onOrganizationChanged(String? organizationId) async {
    if (organizationId == null) {
      return;
    }

    setState(() {
      _mapState.loading = true;
      _setActivity(
        title: 'Kurum hazırlanıyor',
        message: 'Yerleşke ve bina yapısı yükleniyor.',
      );
      _resetMapViewState(
        clearHierarchy: true,
        clearSite: true,
        clearBuilding: true,
        clearFloor: true,
        clearLastScan: true,
      );
    });

    try {
      final hierarchy =
          await _facilityService.getOrganizationHierarchy(organizationId);
      if (!mounted) {
        return;
      }

      setState(() {
        _mapState.hierarchy = hierarchy;
        _mapState.loading = false;
        _clearActivity();
      });
    } catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        _mapState.loading = false;
        _clearActivity();
      });
      _showError(error);
    }
  }

  void _onSiteChanged(String? siteId) {
    final hierarchy = _mapState.hierarchy;
    if (siteId == null || hierarchy == null) {
      return;
    }

    final site = hierarchy.sites.where((item) => item.id == siteId).firstOrNull;
    if (site == null) {
      return;
    }

    setState(() {
      _mapState.site = site;
      _resetMapViewState(
        clearBuilding: true,
        clearFloor: true,
        clearLastScan: true,
      );
    });
  }

  void _onBuildingChanged(String? buildingId) {
    final site = _mapState.site;
    if (buildingId == null || site == null) {
      return;
    }

    final building =
        site.buildings.where((item) => item.id == buildingId).firstOrNull;
    if (building == null) {
      return;
    }

    setState(() {
      _mapState.building = building;
      _resetMapViewState(
        clearFloor: true,
        clearLastScan: true,
      );
    });
  }

  Future<void> _onFloorChanged(String? floorId) async {
    final hierarchy = _mapState.hierarchy;
    final site = _mapState.site;
    final building = _mapState.building;
    if (floorId == null ||
        hierarchy == null ||
        site == null ||
        building == null) {
      return;
    }

    final floor =
        building.floors.where((item) => item.id == floorId).firstOrNull;
    if (floor == null) {
      return;
    }

    try {
      if (mounted) {
        setState(() {
          _mapState.loading = true;
          _setActivity(
            title: 'Kat hazırlanıyor',
            message: 'Seçtiğiniz harita ve hedefler yükleniyor.',
          );
        });
      }
      await _applySelection(
        hierarchy: hierarchy,
        site: site,
        building: building,
        floor: floor,
      );
    } catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        _mapState.loading = false;
        _clearActivity();
      });
      _showError(error);
    }
  }

  void _clearSelectedMap() {
    setState(() {
      _resetMapViewState(
        clearSite: true,
        clearBuilding: true,
        clearFloor: true,
        clearLastScan: true,
      );
    });
  }

  Future<void> _loadOccupancy() async {
    final floor = _mapState.floor;
    if (floor == null) {
      return;
    }

    try {
      final occupancy = await _parkingService.getOccupancyMap(floor.id);
      if (mounted) {
        setState(() => _mapState.occupancy = _normalizeOccupancy(occupancy));
      }
    } catch (error) {
      if (mounted) {
        _showError('Park durumu yüklenemedi: $error');
      }
    }
  }

  @override
  Map<String, bool> _normalizeOccupancy(Map<String, bool> occupancy) =>
      occupancy.map((key, value) => MapEntry(key.toUpperCase(), value));

  @override
  Future<PublishedMapData> _getPublishedMap(String floorId) async {
    final cached = _mapState.publishedMapCache[floorId];
    if (cached != null) {
      return cached;
    }

    final publishedMap = await _facilityService.getPublishedMap(floorId);
    _mapState.publishedMapCache[floorId] = publishedMap;
    return publishedMap;
  }

  Future<List<MapNode>> _loadBuildingDestinations(String buildingId) async {
    late final List<FacilityDestinationSearchResult> results;
    try {
      results = await _facilityService.searchBuildingDestinations(
        buildingId,
        limit: 100,
      );
    } catch (_) {
      return const [];
    }

    final nodes = results
        .where((item) => item.externalReferenceId != null)
        .map((item) => item.toMapNode())
        .toList()
      ..sort((left, right) => left.label.compareTo(right.label));

    return nodes;
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
      setState(() {
        _mapState.loading = true;
        _setActivity(
          title: 'Harita hazırlanıyor',
          message: '${building.name} · ${floor.name} açılıyor.',
        );
      });
    }

    final publishedMap = await _getPublishedMap(floor.id);
    final buildingDestinations = await _loadBuildingDestinations(building.id);
    await RecentMapsStorage().upsert(
      RecentMapEntry(
        organizationId: hierarchy.id,
        organizationName: hierarchy.name,
        siteId: site.id,
        siteName: site.name,
        buildingId: building.id,
        buildingName: building.name,
        floorId: floor.id,
        floorName: floor.name,
        mapVersionId: publishedMap.id,
        mapName: publishedMap.name,
        assetPath: publishedMap.assetPath,
        assetContentType: publishedMap.assetContentType,
        usedAt: DateTime.now(),
      ),
    );

    if (!mounted) {
      return;
    }

    setState(() {
      _mapState.organizations = organizations ?? _mapState.organizations;
      _mapState.hierarchy = hierarchy;
      _mapState.site = site;
      _mapState.building = building;
      _mapState.floor = floor;
      _mapState.map = publishedMap;
      _mapState.displayNodes = publishedMap.nodes;
      _mapState.mapNodes = publishedMap.nodes;
      _mapState.buildingDestinations = buildingDestinations;
      _mapState.displayMapAssetPath = publishedMap.assetPath;
      _mapState.displayMapAssetContentType = publishedMap.assetContentType;
      _mapState.displayMapWidth = publishedMap.width;
      _mapState.displayMapHeight = publishedMap.height;
      _mapState.loading = false;
      _clearActivity();
      _mapState.targetPark = null;
      _mapState.parkedAt = null;
      _mapState.route = null;
      _mapState.multiRoute = null;
      _mapState.activeRouteSegmentIndex = 0;
      _mapState.lastScan = null;
      _mapState.lastScanTime = null;
    });

    await _loadOccupancy();
  }

  void _onOccupancyChanged(String spotId, bool isOccupied) {
    if (!mounted) {
      return;
    }

    final key = spotId.toUpperCase();
    if (!_mapState.occupancy.containsKey(key)) {
      return;
    }

    final wasEmpty = _mapState.occupancy[key] == false;
    setState(() => _mapState.occupancy[key] = isOccupied);
    final targetRef =
        (_mapState.targetPark?.externalReferenceId ?? _mapState.targetPark?.id)
            ?.toUpperCase();
    if (isOccupied && wasEmpty && targetRef == key) {
      _showParkConfirmDialog(key);
    }
  }
}
