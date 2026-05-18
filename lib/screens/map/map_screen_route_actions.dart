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
        _showError('Bu konumdan hedefe rota bulunamadı.');
        return;
      }

      setState(() {
        _mapState.multiRoute = multiRoute;
        _mapState.activeRouteSegmentIndex = 0;
      });

      await _showRouteSegment(0);
    } catch (error) {
      if (mounted) {
        setState(_clearActivity);
      }
      _showError('Rota hesaplanamadı: $error');
    }
  }

  void _applySingleFloorRoute(RouteResult result) {
    setState(() {
      _mapState.multiRoute = null;
      _mapState.activeRouteSegmentIndex = 0;
      _mapState.route = result.nodes;
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

    setState(() {
      _mapState.activeRouteSegmentIndex = index;
      _mapState.route = segment.nodes;
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
    final lastScan = _mapState.lastScan;
    if (lastScan == null) {
      _showError('Önce bir QR kodu okutun.');
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

      final result =
          await _pathfinder.findBestExitRoute(fromReferenceId: lastScan);
      if (result == null || result.segments.isEmpty) {
        if (mounted) {
          setState(_clearActivity);
        }
        _showError('Çıkış rotası bulunamadı.');
        return;
      }

      setState(() {
        _mapState.targetPark = null;
        _mapState.multiRoute = result;
        _mapState.activeRouteSegmentIndex = 0;
      });

      await _showRouteSegment(0);
    } catch (error) {
      if (mounted) {
        setState(_clearActivity);
      }
      _showError('Çıkış rotası hesaplanamadı: $error');
    }
  }

  Future<void> _selectParkingNearEntrance() async {
    final lastScan = _mapState.lastScan;
    if (lastScan == null) {
      _showError('Önce bir QR kodu okutun.');
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
        fromReferenceId: lastScan,
      );

      if (result == null || result.segments.isEmpty) {
        if (mounted) {
          setState(_clearActivity);
        }
        _showError('Girişe yakın uygun park alanı bulunamadı.');
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
        _mapState.activeRouteSegmentIndex = 0;
      });

      await _showRouteSegment(0);
    } catch (error) {
      if (mounted) {
        setState(_clearActivity);
      }
      _showError('Girişe yakın park önerisi alınamadı: $error');
    }
  }
}
