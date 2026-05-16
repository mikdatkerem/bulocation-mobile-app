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
    if (_lastScan == referenceId &&
        _lastScanTime != null &&
        now.difference(_lastScanTime!) < const Duration(seconds: 3)) {
      return;
    }

    _lastScan = referenceId;
    _lastScanTime = now;
    await openByQrReference(referenceId);
  }

  Future<void> openByQrReference(String referenceId) async {
    final normalizedReferenceId = _normalizeQrReference(referenceId);
    if (normalizedReferenceId.isEmpty || _busy) {
      return;
    }

    await HapticFeedback.mediumImpact();
    if (mounted) {
      setState(() {
        _busy = true;
        _setActivity(
          title: 'QR doğrulanıyor',
          message: 'Konumunuz bulunuyor ve doğru harita hazırlanıyor.',
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
        _busy = false;
        if (_map != null) {
          _setActivity(
            title: 'Harita hazır',
            message:
                'Şimdi hedef seçebilir veya yönlendirmeyi başlatabilirsiniz.',
          );
        } else {
          _clearActivity();
        }
      });

      if (_targetPark != null) {
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
        _busy = false;
        _clearActivity();
      });
      _showError(error);
    }
  }

  Future<void> openSelection(MapOpenRequest request) async {
    if (_busy) {
      return;
    }

    if (mounted) {
      setState(() {
        _loading = true;
        _setActivity(
          title: 'Seçim hazırlanıyor',
          message: 'Kurum ve bina bilgileri getiriliyor.',
        );
      });
    }

    try {
      final hierarchy = _hierarchy?.id == request.organizationId
          ? _hierarchy!
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
        _hierarchy = hierarchy;
        _site = site;
        _building = building;
        _floor = null;
        _map = null;
        _route = null;
        _multiRoute = null;
        _targetPark = null;
        _displayNodes = const [];
        _mapNodes = const [];
        _buildingDestinations = const [];
        _displayMapAssetPath = null;
        _displayMapAssetContentType = null;
        _displayMapWidth = null;
        _displayMapHeight = null;
        _occupancy = {};
        _loading = false;
        _clearActivity();
      });
    } catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        _loading = false;
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
    final hierarchy = _hierarchy?.id == context.organizationId
        ? _hierarchy!
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

    if (_floor?.id != floor.id || _hierarchy?.id != hierarchy.id) {
      await _applySelection(
        hierarchy: hierarchy,
        site: site,
        building: building,
        floor: floor,
      );
    }

    _lastScan = context.referenceId;
  }

  Future<void> _updateRoute(String fromReferenceId) async {
    if (_targetPark == null || _floor == null) {
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
        floorId: _floor!.id,
        fromReferenceId: fromReferenceId,
        toReferenceId: _targetPark!.externalReferenceId ?? _targetPark!.id,
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
        toReferenceId: _targetPark!.externalReferenceId ?? _targetPark!.id,
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
        _multiRoute = multiRoute;
        _activeRouteSegmentIndex = 0;
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
      _multiRoute = null;
      _activeRouteSegmentIndex = 0;
      _route = result.nodes;
      _displayNodes = _mapNodes;
      _displayMapAssetPath = _map?.assetPath;
      _displayMapAssetContentType = _map?.assetContentType;
      _displayMapWidth = _map?.width;
      _displayMapHeight = _map?.height;
      _clearActivity();
    });
  }

  Future<void> _showRouteSegment(int index) async {
    final multiRoute = _multiRoute;
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
      _activeRouteSegmentIndex = index;
      _route = segment.nodes;
      _displayNodes = segmentMap.nodes;
      _mapNodes = segmentMap.nodes;
      _occupancy = _normalizeOccupancy(occupancy);
      _displayMapAssetPath = segmentMap.assetPath;
      _displayMapAssetContentType = segmentMap.assetContentType;
      _displayMapWidth = segmentMap.width;
      _displayMapHeight = segmentMap.height;
      _clearActivity();
    });
  }

  void _showSuggestionDialog() {
    if (_lastScan == null) {
      return;
    }

    showDialog(
      context: context,
      barrierColor: Colors.black26,
      builder: (_) => ParkSuggestionDialog(
        nearestToUser: _pathfinder.nearestEmptyParkToUser(
          _lastScan!,
          _occupancy,
          _mapNodes,
        ),
        nearestToHospital: null,
        onSelected: (park) {
          setState(() {
            _targetPark = park;
            _route = null;
            _multiRoute = null;
          });
          unawaited(_updateRoute(_lastScan!));
        },
      ),
    );
  }

  Future<void> _navigateToBestExit() async {
    if (_lastScan == null) {
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
          await _pathfinder.findBestExitRoute(fromReferenceId: _lastScan!);
      if (result == null || result.segments.isEmpty) {
        if (mounted) {
          setState(_clearActivity);
        }
        _showError('Çıkış rotası bulunamadı.');
        return;
      }

      setState(() {
        _targetPark = null;
        _multiRoute = result;
        _activeRouteSegmentIndex = 0;
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
    if (_lastScan == null) {
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
        fromReferenceId: _lastScan!,
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
        _targetPark = target;
        _multiRoute = MultiRouteResult(
          segments: result.segments,
          distanceMeters: result.distanceMeters,
          distanceLabel: result.distanceLabel,
        );
        _activeRouteSegmentIndex = 0;
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
    final park = _mapNodes
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
            _parkedAt = park;
            _targetPark = null;
            _route = null;
            _multiRoute = null;
            _displayNodes = _mapNodes;
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

  MapPanelMode get _mapPanelMode =>
      resolveMapPanelMode(site: _site, building: _building, floor: _floor);

  List<MapNode> get _destinationNodes {
    final nodes = _buildingDestinations.isNotEmpty
        ? _buildingDestinations
        : resolveDestinationNodes(mapNodes: _mapNodes, mode: _mapPanelMode);
    final activeReference = _lastScan?.toUpperCase();

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
      _targetPark = park;
      _route = null;
      _multiRoute = null;
      _setActivity(
        title: 'Hedef seçildi',
        message: '${park.label} için rota hazırlanıyor.',
      );
    });
    if (_lastScan != null) {
      unawaited(_updateRoute(_lastScan!));
    }
  }

  void _navigateToCar() {
    if (_parkedAt == null || _lastScan == null) {
      return;
    }

    setState(() {
      _targetPark = _parkedAt;
      _setActivity(
        title: 'Aracınıza gidiliyor',
        message: '${_parkedAt!.label} için rota hazırlanıyor.',
      );
    });
    unawaited(_updateRoute(_lastScan!));
  }

  void _clearNavigation() {
    setState(() {
      _targetPark = null;
      _route = null;
      _multiRoute = null;
      _displayNodes = _mapNodes;
      _clearActivity();
    });
  }

  void _navigateToNearestToUser() {
    if (_lastScan == null) {
      return;
    }

    final park = _pathfinder.nearestEmptyParkToUser(
      _lastScan!,
      _occupancy,
      _mapNodes,
    );
    if (park == null) {
      return;
    }

    setState(() {
      _targetPark = park;
      _multiRoute = null;
      _setActivity(
        title: 'En yakın park seçildi',
        message: '${park.label} için rota hazırlanıyor.',
      );
    });
    unawaited(_updateRoute(_lastScan!));
  }
}
