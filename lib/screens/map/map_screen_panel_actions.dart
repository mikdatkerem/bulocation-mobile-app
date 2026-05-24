part of '../home_screen.dart';

mixin _MapScreenPanelActions on MapsScreenStateBase {
  @override
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
