import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../models/auth_models.dart';
import '../models/facility_models.dart';
import '../services/facility_service.dart';
import 'map/map_selection_panel.dart';

part 'home/home_overview_actions.dart';
part 'home/home_overview_qr_scene.dart';
part 'home/home_overview_theme.dart';
part 'home/home_overview_tiles.dart';
part 'home/quick_scanner_sheet.dart';

class HomeOverviewScreen extends StatefulWidget {
  const HomeOverviewScreen({
    super.key,
    required this.onOpenMaps,
    required this.onQuickScan,
    required this.onOpenProfile,
    required this.onManualPageVisibleChanged,
    required this.profile,
  });

  final ValueChanged<MapOpenRequest?> onOpenMaps;
  final Future<void> Function(String referenceId) onQuickScan;
  final VoidCallback onOpenProfile;
  final ValueChanged<bool> onManualPageVisibleChanged;
  final UserProfile? profile;

  @override
  State<HomeOverviewScreen> createState() => HomeOverviewScreenState();
}

class HomeOverviewScreenState extends State<HomeOverviewScreen>
    with SingleTickerProviderStateMixin {
  final _facilityService = FacilityService();
  late final PageController _pageController = PageController();

  late final AnimationController _pulseController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2600),
  )..repeat(reverse: true);

  bool _loading = true;
  String? _error;
  bool _manualPageVisible = false;
  String? _selectedOrganizationId;
  String? _selectedSiteId;
  String? _selectedBuildingId;
  String? _selectedFloorId;
  List<OrganizationSummary> _organizations = const [];
  List<OrganizationHierarchy> _hierarchies = const [];

  @override
  void initState() {
    super.initState();
    _loadOverview();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  void _setManualPageVisible(bool visible) {
    if (_manualPageVisible == visible) {
      return;
    }

    _manualPageVisible = visible;
    widget.onManualPageVisibleChanged(visible);
  }

  Future<void> showHeroPage() async {
    _setManualPageVisible(false);
    if (!_pageController.hasClients) {
      return;
    }

    await _pageController.animateToPage(
      0,
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOutCubic,
    );
  }

  Future<void> _loadOverview() async {
    try {
      final organizations = await _facilityService.getOrganizations();
      final hierarchies = <OrganizationHierarchy>[];

      for (final organization in organizations) {
        hierarchies.add(
          await _facilityService.getOrganizationHierarchy(organization.id),
        );
      }

      if (!mounted) {
        return;
      }

      setState(() {
        _organizations = organizations;
        _hierarchies = hierarchies;
        _loading = false;
        _error = null;
      });
    } catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        _error = error.toString().replaceFirst('Exception: ', '');
        _loading = false;
      });
    }
  }

  String get _displayName {
    final profile = widget.profile;
    if (profile == null) {
      return 'Merhaba';
    }

    if (profile.firstName.trim().isNotEmpty) {
      return 'Merhaba, ${profile.firstName.trim()}';
    }

    if (profile.fullName.trim().isNotEmpty) {
      return 'Merhaba, ${profile.fullName.trim()}';
    }

    return 'Merhaba';
  }

  OrganizationHierarchy? get _selectedHierarchy => _hierarchies
      .where((item) => item.id == _selectedOrganizationId)
      .firstOrNull;

  List<SiteHierarchy> get _availableSites =>
      _selectedHierarchy?.sites ?? const [];

  SiteHierarchy? get _selectedSite =>
      _availableSites.where((item) => item.id == _selectedSiteId).firstOrNull;

  List<BuildingHierarchy> get _availableBuildings =>
      _selectedSite?.buildings ?? const [];

  BuildingHierarchy? get _selectedBuilding => _availableBuildings
      .where((item) => item.id == _selectedBuildingId)
      .firstOrNull;

  List<FloorHierarchy> get _availableFloors =>
      _selectedBuilding?.floors
          .where((item) => item.hasPublishedMap)
          .toList() ??
      const [];

  String get _introDescription {
    if (_organizations.isEmpty) {
      return 'Önce QR ile başlayın. Kurum erişimleri tanımlandığında harita seçimi burada açılacak.';
    }

    return 'Girişteki veya bulunduğunuz kattaki QR kodunu okutun.';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: _loading
            ? const Center(child: CircularProgressIndicator(color: _accent))
            : _error != null
                ? _OverviewError(message: _error!, onRetry: _loadOverview)
                : PageView(
                    controller: _pageController,
                    scrollDirection: Axis.vertical,
                    onPageChanged: (index) => _setManualPageVisible(index == 1),
                    children: [
                      LayoutBuilder(
                        builder: (context, constraints) {
                          const headerHeight = 64.0;
                          final heroHeight =
                              (constraints.maxHeight - headerHeight)
                                  .clamp(560.0, double.infinity);

                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 18),
                            child: Column(
                              children: [
                                _Header(onOpenProfile: widget.onOpenProfile),
                                _HeroScene(
                                  greeting: _displayName,
                                  description: _introDescription,
                                  pulse: _pulseController,
                                  onPrimaryTap: () => _showQuickScanner(
                                    context,
                                  ),
                                  height: heroHeight,
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(18, 18, 18, 136),
                        child: MapSelectionPanel(
                          organizations: _organizations,
                          selectedOrganizationId: _selectedOrganizationId,
                          sites: _availableSites,
                          selectedSiteId: _selectedSiteId,
                          buildings: _availableBuildings,
                          selectedBuildingId: _selectedBuildingId,
                          floors: _availableFloors,
                          selectedFloorId: _selectedFloorId,
                          onOrganizationChanged: _onOrganizationChanged,
                          onSiteChanged: _onSiteChanged,
                          onBuildingChanged: _onBuildingChanged,
                          onFloorChanged: _onFloorChanged,
                          alignment: Alignment.topCenter,
                        ),
                      ),
                    ],
                  ),
      ),
    );
  }

  Future<void> _showQuickScanner(BuildContext context) async {
    final scanner = MobileScannerController(
      detectionSpeed: DetectionSpeed.noDuplicates,
    );

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _QuickScannerSheet(
        controller: scanner,
        onDetect: (referenceId) async {
          Navigator.pop(context);
          await widget.onQuickScan(referenceId);
        },
      ),
    );

    await scanner.dispose();
  }

  void _onOrganizationChanged(String? organizationId) {
    if (organizationId == null) {
      return;
    }

    setState(() {
      _selectedOrganizationId = organizationId;
      _selectedSiteId = null;
      _selectedBuildingId = null;
      _selectedFloorId = null;
    });
  }

  void _onSiteChanged(String? siteId) {
    if (siteId == null) {
      return;
    }

    setState(() {
      _selectedSiteId = siteId;
      _selectedBuildingId = null;
      _selectedFloorId = null;
    });
  }

  void _onBuildingChanged(String? buildingId) {
    if (buildingId == null) {
      return;
    }

    setState(() {
      _selectedBuildingId = buildingId;
      _selectedFloorId = null;
    });
  }

  void _onFloorChanged(String? floorId) {
    final organizationId = _selectedOrganizationId;
    final siteId = _selectedSiteId;
    final buildingId = _selectedBuildingId;
    if (floorId == null ||
        organizationId == null ||
        siteId == null ||
        buildingId == null) {
      return;
    }

    setState(() => _selectedFloorId = floorId);
    widget.onOpenMaps(
      MapOpenRequest(
        organizationId: organizationId,
        siteId: siteId,
        buildingId: buildingId,
        floorId: floorId,
      ),
    );
  }
}
