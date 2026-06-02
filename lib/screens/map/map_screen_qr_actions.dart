part of '../home_screen.dart';

mixin _MapScreenQrActions on MapsScreenStateBase {
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

    _mapState.lastScanTime = now;
    await openByQrReference(referenceId);
  }

  Future<void> openByQrReference(String referenceId) async {
    final normalizedReferenceId = _normalizeQrReference(referenceId);
    if (normalizedReferenceId.isEmpty || _mapState.busy) {
      return;
    }
    final hadActiveNavigation = _hasActiveNavigation;

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
      final routeSegmentIndex = _routeSegmentIndexForScan(context);
      if (_mapState.multiRoute != null && routeSegmentIndex == null) {
        if (!mounted) {
          return;
        }

        setState(() {
          _mapState.busy = false;
          _clearActivity();
        });
        _showNotice(
          title: 'Rota korunuyor',
          message:
              'Okuttuğunuz QR mevcut rotadaki katlarla eşleşmedi. Rotanız bozulmadan açık haritada kaldı.',
          level: MapScreenNoticeLevel.warning,
        );
        return;
      }

      await _applyScanContext(
        context,
        preserveNavigation: hadActiveNavigation,
      );
      if (!mounted) {
        return;
      }

      setState(() {
        _mapState.busy = false;
        if (_mapState.map != null) {
          _setActivity(
            title: 'Harita hazır',
            message:
                'Şimdi hedef seçebilir veya yönlendirmeyi başlatabilirsiniz.',
          );
        } else {
          _clearActivity();
        }
      });

      if (_mapState.multiRoute != null && routeSegmentIndex != null) {
        await _showRouteSegment(routeSegmentIndex);
        _showNotice(
          title: 'Kat rotası açıldı',
          message:
              'Rotanız korunuyor. Bu kat için ilgili rota segmenti gösteriliyor.',
        );
        _collapseSheet();
      } else if (_mapState.targetPark != null) {
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
        _mapState.singleFloorRoute = null;
        _mapState.singleFloorRouteFloorId = null;
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

  Future<void> _applyScanContext(
    QrScanContext context, {
    bool preserveNavigation = false,
  }) async {
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

    if (_mapState.floor?.id != floor.id ||
        _mapState.hierarchy?.id != hierarchy.id) {
      await _applySelection(
        hierarchy: hierarchy,
        site: site,
        building: building,
        floor: floor,
        preserveNavigation: preserveNavigation,
      );
    }

    _mapState.lastScan = context.referenceId;
  }

  bool get _hasActiveNavigation =>
      _mapState.targetPark != null ||
      _mapState.multiRoute != null ||
      (_mapState.route?.isNotEmpty == true);

  int? _routeSegmentIndexForScan(QrScanContext context) {
    final multiRoute = _mapState.multiRoute;
    if (multiRoute == null) {
      return null;
    }

    final referenceId = context.referenceId.toUpperCase();
    for (var index = 0; index < multiRoute.segments.length; index++) {
      final segment = multiRoute.segments[index];
      final hasScannedNode = segment.nodes.any(
        (node) =>
            (node.externalReferenceId ?? node.id).toUpperCase() == referenceId,
      );
      if (hasScannedNode) {
        return index;
      }
    }

    for (var index = 0; index < multiRoute.segments.length; index++) {
      if (multiRoute.segments[index].floorId == context.floorId) {
        return index;
      }
    }

    return null;
  }
}
