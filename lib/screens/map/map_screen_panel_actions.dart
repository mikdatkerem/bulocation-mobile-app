part of '../home_screen.dart';

mixin _MapScreenPanelActions on MapsScreenStateBase {
  @override
  void _showSuggestionDialog() {
    final startReference = _activeStartReference();
    if (startReference == null) {
      _showError('Rota başlatmak için önce QR okutun.');
      return;
    }

    showDialog(
      context: context,
      barrierColor: Colors.black26,
      builder: (_) => ParkSuggestionDialog(
        nearestToUser: _pathfinder.nearestEmptyParkToUser(
          startReference,
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
          unawaited(_updateRoute(startReference));
        },
      ),
    );
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
    _showNotice(
      title: 'Uyarı',
      message: message,
      level: MapScreenNoticeLevel.warning,
    );
  }

  @override
  void _showNotice({
    required String title,
    String? message,
    MapScreenNoticeLevel level = MapScreenNoticeLevel.info,
  }) {
    if (!mounted) {
      return;
    }

    setState(() {
      _notices
        ..removeWhere(
          (notice) =>
              notice.title == title &&
              notice.message == message &&
              notice.level == level,
        )
        ..insert(
          0,
          MapScreenNotice(
            id: _nextNoticeId++,
            title: title,
            message: message,
            level: level,
          ),
        );
      if (_notices.length > 3) {
        _notices.removeRange(3, _notices.length);
      }
    });
  }

  void _dismissNotice(int id) {
    if (!mounted) {
      return;
    }

    setState(() => _notices.removeWhere((notice) => notice.id == id));
  }

  @override
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

  @override
  String? _activeStartReference() {
    final lastScan = _mapState.lastScan?.trim();
    if (lastScan?.isNotEmpty == true) {
      return lastScan;
    }

    final routeStart = _mapState.route?.firstOrNull;
    final routeReference = routeStart?.externalReferenceId ?? routeStart?.id;
    if (routeReference?.trim().isNotEmpty == true) {
      return routeReference;
    }

    final qrNode = _mapState.mapNodes.where((node) => node.isQr).firstOrNull;
    final qrReference = qrNode?.externalReferenceId ?? qrNode?.id;
    if (qrReference?.trim().isNotEmpty == true) {
      return qrReference;
    }

    return null;
  }

  @override
  MapPanelMode get _mapPanelMode => resolveMapPanelMode(
        site: _mapState.site,
        building: _mapState.building,
        floor: _mapState.floor,
      );

  List<MapNode> get _destinationNodes {
    final mapDestinations = resolveDestinationNodes(
      mapNodes: _mapState.mapNodes,
      mode: _mapPanelMode,
    );
    final nodes = _mapState.buildingDestinations.isEmpty
        ? mapDestinations
        : _mergeDestinationNodes(
            _mapState.buildingDestinations,
            mapDestinations,
          );
    final activeReference = _activeStartReference()?.toUpperCase();

    return nodes.where((node) {
      if (_mapPanelMode != MapPanelMode.parking && node.isQr) {
        return false;
      }

      if (activeReference == null) {
        return true;
      }

      return (node.externalReferenceId ?? node.id).toUpperCase() !=
          activeReference;
    }).toList();
  }

  List<MapNode> _mergeDestinationNodes(
    List<MapNode> primaryNodes,
    List<MapNode> mapNodes,
  ) {
    final merged = <String, MapNode>{};
    for (final node in primaryNodes) {
      merged[_destinationNodeKey(node)] = node;
    }
    for (final node in mapNodes) {
      merged.putIfAbsent(_destinationNodeKey(node), () => node);
    }

    return merged.values.toList()
      ..sort((left, right) =>
          compareNodeLabelsNatural(left.displayLabel, right.displayLabel));
  }

  String _destinationNodeKey(MapNode node) {
    return (node.externalReferenceId?.trim().isNotEmpty == true
            ? node.externalReferenceId!.trim()
            : node.id)
        .toUpperCase();
  }

  void _selectParkTarget(MapNode park) {
    final startReference = _activeStartReference();
    _collapseSheet();
    setState(() {
      _mapState.targetPark = park;
      _mapState.route = null;
      _mapState.multiRoute = null;
      _setActivity(
        title: 'Hedef seçildi',
        message: '${park.displayLabel} için rota hazırlanıyor.',
      );
    });

    if (startReference != null) {
      unawaited(_updateRoute(startReference));
      return;
    }

    setState(_clearActivity);
    _showError('Rota başlatmak için önce QR okutun.');
  }

  void _navigateToCar() {
    final startReference = _activeStartReference();
    if (_mapState.parkedAt == null || startReference == null) {
      return;
    }

    setState(() {
      _mapState.targetPark = _mapState.parkedAt;
      _setActivity(
        title: 'Aracınıza gidiliyor',
        message: '${_mapState.parkedAt!.displayLabel} için rota hazırlanıyor.',
      );
    });
    _collapseSheet();
    unawaited(_updateRoute(startReference));
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
    final startReference = _activeStartReference();
    if (startReference == null) {
      _showError('Rota başlatmak için önce QR okutun.');
      return;
    }

    final park = _pathfinder.nearestEmptyParkToUser(
      startReference,
      _mapState.occupancy,
      _mapState.mapNodes,
    );
    if (park == null) {
      _showError('Uygun boş park alanı bulunamadı.');
      return;
    }

    setState(() {
      _mapState.targetPark = park;
      _mapState.multiRoute = null;
      _setActivity(
        title: 'En yakın park seçildi',
        message: '${park.displayLabel} için rota hazırlanıyor.',
      );
    });
    _collapseSheet();
    unawaited(_updateRoute(startReference));
  }
}
