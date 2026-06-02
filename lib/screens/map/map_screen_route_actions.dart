part of '../home_screen.dart';

mixin _MapScreenRouteActions on MapsScreenStateBase {
  @override
  Future<void> _updateRoute(String fromReferenceId) async {
    if (_mapState.targetPark == null || _mapState.floor == null) {
      if (mounted) {
        setState(_clearActivity);
      }
      return;
    }

    try {
      if (mounted) {
        setState(() {
          _setActivity(
            title: 'Rota hazırlanıyor',
            message: 'Seçtiğiniz hedef için en uygun yol hesaplanıyor.',
          );
        });
      }

      final result = await _pathfinder.findFacilityRoute(
        floorId: _mapState.floor!.id,
        fromReferenceId: fromReferenceId,
        toReferenceId: _mapState.targetPark!.externalReferenceId ??
            _mapState.targetPark!.id,
      );

      if (!mounted) {
        return;
      }

      if (result != null) {
        _applySingleFloorRoute(result);
        _collapseSheet();
        return;
      }

      final multiRoute = await _pathfinder.findFacilityMultiRoute(
        fromReferenceId: fromReferenceId,
        toReferenceId: _mapState.targetPark!.externalReferenceId ??
            _mapState.targetPark!.id,
      );

      if (!mounted) {
        return;
      }

      if (multiRoute == null || multiRoute.segments.isEmpty) {
        setState(_clearActivity);
        _showError(
          'Bu noktadan seçili hedefe rota bulunamadı. Yakındaki bir QR kodu tekrar okutun veya sheet içinden farklı bir hedef seçin.',
        );
        return;
      }

      setState(() {
        _mapState.multiRoute = multiRoute;
        _mapState.singleFloorRoute = null;
        _mapState.singleFloorRouteFloorId = null;
        _mapState.activeRouteSegmentIndex = 0;
      });

      await _showRouteSegment(0);
      _collapseSheet();
    } catch (error) {
      if (mounted) {
        setState(_clearActivity);
      }
      _showError(
        'Rota hazırlanamadı. QR kodu tekrar okutun veya hedefi yeniden seçin. Detay: $error',
      );
    }
  }

  void _applySingleFloorRoute(RouteResult result) {
    setState(() {
      _mapState.multiRoute = null;
      _mapState.activeRouteSegmentIndex = 0;
      _mapState.route = result.nodes;
      _mapState.singleFloorRoute = result.nodes;
      _mapState.singleFloorRouteFloorId = _mapState.floor?.id;
      _mapState.displayNodes = _mapState.mapNodes;
      _mapState.displayMapAssetPath = _mapState.map?.assetPath;
      _mapState.displayMapAssetContentType = _mapState.map?.assetContentType;
      _mapState.displayMapWidth = _mapState.map?.width;
      _mapState.displayMapHeight = _mapState.map?.height;
      _clearActivity();
    });
  }

  @override
  Future<void> _showRouteSegment(int index) async {
    final multiRoute = _mapState.multiRoute;
    if (multiRoute == null ||
        index < 0 ||
        index >= multiRoute.segments.length) {
      return;
    }

    final segment = multiRoute.segments[index];
    final segmentMap = await _getPublishedMap(segment.floorId);
    final occupancy = await _parkingService.getOccupancyMap(segment.floorId);
    if (!mounted) {
      return;
    }

    final site = _mapState.hierarchy?.sites
        .where((item) => item.id == segment.siteId)
        .firstOrNull;
    final building = site?.buildings
        .where((item) => item.id == segment.buildingId)
        .firstOrNull;
    final floor = building?.floors
        .where((item) => item.id == segment.floorId)
        .firstOrNull;

    setState(() {
      if (site != null) {
        _mapState.site = site;
      }
      if (building != null) {
        _mapState.building = building;
      }
      if (floor != null) {
        _mapState.floor = floor;
      }
      _mapState.map = segmentMap;
      _mapState.activeRouteSegmentIndex = index;
      _mapState.route = segment.nodes;
      _mapState.singleFloorRoute = null;
      _mapState.singleFloorRouteFloorId = null;
      _mapState.displayNodes = segmentMap.nodes;
      _mapState.mapNodes = segmentMap.nodes;
      _mapState.occupancy = _normalizeOccupancy(occupancy);
      _mapState.displayMapAssetPath = segmentMap.assetPath;
      _mapState.displayMapAssetContentType = segmentMap.assetContentType;
      _mapState.displayMapWidth = segmentMap.width;
      _mapState.displayMapHeight = segmentMap.height;
      _clearActivity();
    });
  }

  Future<void> _navigateToBestExit() async {
    final startReference = _activeStartReference();
    if (startReference == null) {
      _showError(
        'Çıkış rotasını başlatmak için önce bulunduğunuz noktadaki QR kodu okutun.',
      );
      return;
    }

    try {
      if (mounted) {
        setState(() {
          _setActivity(
            title: 'Çıkış rotası hazırlanıyor',
            message: 'En uygun çıkış yönlendirmesi hesaplanıyor.',
          );
        });
      }

      final result = await _pathfinder.findBestExitRoute(
        fromReferenceId: startReference,
        exitTarget: _mapPanelMode == MapPanelMode.parking
            ? ExitTargetType.parking
            : ExitTargetType.facility,
      );
      if (result == null || result.segments.isEmpty) {
        if (mounted) {
          setState(_clearActivity);
        }
        _showError(
          'Bu noktadan uygun çıkış rotası bulunamadı. Yakındaki farklı bir QR kodu okutmayı deneyin.',
        );
        return;
      }

      setState(() {
        _mapState.targetPark = null;
        _mapState.multiRoute = result;
        _mapState.singleFloorRoute = null;
        _mapState.singleFloorRouteFloorId = null;
        _mapState.activeRouteSegmentIndex = 0;
      });

      await _showRouteSegment(0);
      _collapseSheet();
    } catch (error) {
      if (mounted) {
        setState(_clearActivity);
      }
      _showError(
        'Çıkış rotası hazırlanamadı. Lütfen QR kodu tekrar okutun. Detay: $error',
      );
    }
  }

  Future<void> _selectParkingNearEntrance() async {
    final startReference = _activeStartReference();
    if (startReference == null) {
      _showError(
        'Park önerisi için önce bulunduğunuz noktadaki QR kodu okutun.',
      );
      return;
    }

    try {
      if (mounted) {
        setState(() {
          _setActivity(
            title: 'Park önerisi hazırlanıyor',
            message: 'Girişe en yakın uygun alan aranıyor.',
          );
        });
      }

      final result = await _pathfinder.findRecommendedParkingNearEntrance(
        fromReferenceId: startReference,
      );

      if (result == null || result.segments.isEmpty) {
        if (mounted) {
          setState(_clearActivity);
        }
        _showError(
          'Girişe yakın uygun boş park alanı bulunamadı. Park listesinden farklı bir alan seçebilirsiniz.',
        );
        return;
      }

      final lastNode = result.segments.last.nodes.last;
      final target = MapNode(
        id: result.target.code.toUpperCase(),
        label: result.target.label,
        x: lastNode.x,
        y: lastNode.y,
        type: NodeType.park,
        externalReferenceId: result.target.externalReferenceId,
      );

      setState(() {
        _mapState.targetPark = target;
        _mapState.multiRoute = MultiRouteResult(
          segments: result.segments,
          distanceMeters: result.distanceMeters,
          distanceLabel: result.distanceLabel,
        );
        _mapState.singleFloorRoute = null;
        _mapState.singleFloorRouteFloorId = null;
        _mapState.activeRouteSegmentIndex = 0;
      });

      await _showRouteSegment(0);
      _collapseSheet();
    } catch (error) {
      if (mounted) {
        setState(_clearActivity);
      }
      _showError(
        'Girişe yakın park önerisi alınamadı. Bir park alanını manuel seçmeyi deneyin. Detay: $error',
      );
    }
  }
}
