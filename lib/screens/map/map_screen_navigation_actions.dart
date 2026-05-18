part of '../home_screen.dart';

mixin _MapScreenNavigationActions on MapsScreenStateBase {
  Future<void> _onQrDetected(BarcodeCapture capture) async {
    final value = capture.barcodes.firstOrNull?.rawValue?.trim();
    if (value == null || value.isEmpty) {
      return;
    }

    final referenceId = _normalizeQrReference(value);
    if (referenceId.isEmpty) {
      return;
    }

    final now = DateTime.now();
    if (_mapState.lastScan == referenceId &&
        _mapState.lastScanTime != null &&
        now.difference(_mapState.lastScanTime!) < const Duration(seconds: 3)) {
      return;
    }

    _mapState.lastScan = referenceId;
    _mapState.lastScanTime = now;
    await openByQrReference(referenceId);
  }

  Future<void> openByQrReference(String referenceId) async {
    final normalizedReferenceId = _normalizeQrReference(referenceId);
    if (normalizedReferenceId.isEmpty || _mapState.busy) {
      return;
    }

    await HapticFeedback.mediumImpact();
    if (mounted) {
      setState(() {
        _mapState.busy = true;
        _setActivity(
          title: 'QR doğrulanıyor',
          message: 'Konumunuz bulunuyor ve harita hazırlanıyor.',
        );
      });
    }

    try {
      final context =
          await _facilityService.resolveQrScanContext(normalizedReferenceId);
      await _applyScanContext(context);
      if (!mounted) {
        return;
      }

      setState(() {
        _mapState.busy = false;
        if (_mapState.map != null) {
          _setActivity(
            title: 'Harita hazır',
            message: 'Şimdi hedef seçebilir veya yönlendirmeyi başlatabilirsiniz.',
          );
        } else {
          _clearActivity();
        }
      });

      if (_mapState.targetPark != null) {
        await _updateRoute(normalizedReferenceId);
      } else if (_mapPanelMode == MapPanelMode.parking) {
        _showSuggestionDialog();
      } else if (mounted) {
        await Future<void>.delayed(const Duration(milliseconds: 850));
        if (!mounted) {
          return;
        }
        setState(_clearActivity);
      }
    } catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        _mapState.busy = false;
        _clearActivity();
      });
      _showError(error);
    }
  }

  Future<void> openSelection(MapOpenRequest request) async {
    if (_mapState.busy) {
      return;
    }

    if (mounted) {
      setState(() {
        _mapState.loading = true;
        _setActivity(
          title: 'Seçim hazırlanıyor',
          message: 'Kurum ve bina bilgileri getiriliyor.',
        );
      });
    }

    try {
      final hierarchy = _mapState.hierarchy?.id == request.organizationId
          ? _mapState.hierarchy!
          : await _facilityService
              .getOrganizationHierarchy(request.organizationId);

      final site = request.siteId == null
          ? null
          : hierarchy.sites
              .where((item) => item.id == request.siteId)
              .firstOrNull;
      final building = request.buildingId == null
          ? null
          : site?.buildings
              .where((item) => item.id == request.buildingId)
              .firstOrNull;
      final floor = request.floorId == null
          ? null
          : building?.floors
              .where((item) => item.id == request.floorId)
              .firstOrNull;

      if (site != null && building != null && floor != null) {
        await _applySelection(
          hierarchy: hierarchy,
          site: site,
          building: building,
          floor: floor,
        );
        return;
      }

      if (!mounted) {
        return;
      }

      setState(() {
        _mapState.hierarchy = hierarchy;
        _mapState.site = site;
        _mapState.building = building;
        _mapState.floor = null;
        _mapState.map = null;
        _mapState.route = null;
        _mapState.multiRoute = null;
        _mapState.targetPark = null;
        _mapState.displayNodes = const [];
        _mapState.mapNodes = const [];
        _mapState.buildingDestinations = const [];
        _mapState.displayMapAssetPath = null;
        _mapState.displayMapAssetContentType = null;
        _mapState.displayMapWidth = null;
        _mapState.displayMapHeight = null;
        _mapState.occupancy = {};
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

  String _normalizeQrReference(String rawValue) {
    final value = rawValue.trim();
    final uri = Uri.tryParse(value);
    final ref = uri?.queryParameters['ref']?.trim();

    if (ref != null && ref.isNotEmpty) {
      return ref;
    }

    return value;
  }

  Future<void> _applyScanContext(QrScanContext context) async {
    final hierarchy = _mapState.hierarchy?.id == context.organizationId
        ? _mapState.hierarchy!
        : await _facilityService
            .getOrganizationHierarchy(context.organizationId);
    final site =
        hierarchy.sites.where((item) => item.id == context.siteId).firstOrNull;
    final building = site?.buildings
        .where((item) => item.id == context.buildingId)
        .firstOrNull;
    final floor = building?.floors
        .where((item) => item.id == context.floorId)
        .firstOrNull;

    if (site == null || building == null || floor == null) {
      throw Exception('QR bağlamı için kat bulunamadı.');
    }

    if (_mapState.floor?.id != floor.id || _mapState.hierarchy?.id != hierarchy.id) {
      await _applySelection(
        hierarchy: hierarchy,
        site: site,
        building: building,
        floor: floor,
      );
    }

    _mapState.lastScan = context.referenceId;
  }

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

  void _showSuggestionDialog() {
    final lastScan = _mapState.lastScan;
    if (lastScan == null) {
      return;
    }

    showDialog(
      context: context,
      barrierColor: Colors.black26,
      builder: (_) => ParkSuggestionDialog(
        nearestToUser: _pathfinder.nearestEmptyParkToUser(
          lastScan,
          _mapState.occupancy,
          _mapState.mapNodes,
        ),
        nearestToHospital: null,
        onSelected: (park) {
          setState(() {
            _mapState.targetPark = park;
            _mapState.route = null;
            _mapState.multiRoute = null;
          });
          unawaited(_updateRoute(lastScan));
        },
      ),
    );
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

  @override
  void _showParkConfirmDialog(String spotId) {
    final park = _mapState.mapNodes
        .where((node) =>
            (node.externalReferenceId ?? node.id).toUpperCase() == spotId)
        .firstOrNull;
    if (park == null) {
      return;
    }

    showDialog(
      context: context,
      barrierColor: Colors.black26,
      builder: (_) => ParkConfirmDialog(
        park: park,
        onConfirm: () {
          Navigator.pop(context);
          setState(() {
            _mapState.parkedAt = park;
            _mapState.targetPark = null;
            _mapState.route = null;
            _mapState.multiRoute = null;
            _mapState.displayNodes = _mapState.mapNodes;
            _clearActivity();
          });
        },
        onDeny: () => Navigator.pop(context),
      ),
    );
  }

  @override
  void _showError(Object error) {
    final message = error.toString().replaceFirst('Exception: ', '');
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          margin: const EdgeInsets.all(16),
        ),
      );
  }

  void _collapseSheet() {
    if (!_sheetController.isAttached) {
      return;
    }

    _sheetController.animateTo(
      ParkBottomSheet.peekSize,
      duration: const Duration(milliseconds: 240),
      curve: Curves.easeOutCubic,
    );
  }

  MapPanelMode get _mapPanelMode => resolveMapPanelMode(
    site: _mapState.site,
    building: _mapState.building,
    floor: _mapState.floor,
  );

  List<MapNode> get _destinationNodes {
    final nodes = _mapState.buildingDestinations.isNotEmpty
        ? _mapState.buildingDestinations
        : resolveDestinationNodes(
            mapNodes: _mapState.mapNodes,
            mode: _mapPanelMode,
          );
    final activeReference = _mapState.lastScan?.toUpperCase();

    if (activeReference == null) {
      return nodes;
    }

    return nodes
        .where((node) =>
            (node.externalReferenceId ?? node.id).toUpperCase() !=
            activeReference)
        .toList();
  }

  void _selectParkTarget(MapNode park) {
    _sheetController.animateTo(
      ParkBottomSheet.peekSize,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
    );
    setState(() {
      _mapState.targetPark = park;
      _mapState.route = null;
      _mapState.multiRoute = null;
      _setActivity(
        title: 'Hedef seçildi',
        message: '${park.label} için rota hazırlanıyor.',
      );
    });
    if (_mapState.lastScan != null) {
      unawaited(_updateRoute(_mapState.lastScan!));
    }
  }

  void _navigateToCar() {
    if (_mapState.parkedAt == null || _mapState.lastScan == null) {
      return;
    }

    setState(() {
      _mapState.targetPark = _mapState.parkedAt;
      _setActivity(
        title: 'Aracınıza gidiliyor',
        message: '${_mapState.parkedAt!.label} için rota hazırlanıyor.',
      );
    });
    unawaited(_updateRoute(_mapState.lastScan!));
  }

  void _clearNavigation() {
    setState(() {
      _mapState.targetPark = null;
      _mapState.route = null;
      _mapState.multiRoute = null;
      _mapState.displayNodes = _mapState.mapNodes;
      _clearActivity();
    });
  }

  void _navigateToNearestToUser() {
    final lastScan = _mapState.lastScan;
    if (lastScan == null) {
      return;
    }

    final park = _pathfinder.nearestEmptyParkToUser(
      lastScan,
      _mapState.occupancy,
      _mapState.mapNodes,
    );
    if (park == null) {
      return;
    }

    setState(() {
      _mapState.targetPark = park;
      _mapState.multiRoute = null;
      _setActivity(
        title: 'En yakın park seçildi',
        message: '${park.label} için rota hazırlanıyor.',
      );
    });
    unawaited(_updateRoute(lastScan));
  }
}
