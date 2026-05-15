import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../models/auth_models.dart';
import '../models/facility_models.dart';
import '../services/facility_service.dart';

part 'home/home_overview_actions.dart';
part 'home/home_overview_models.dart';
part 'home/home_overview_theme.dart';
part 'home/home_overview_tiles.dart';
part 'home/quick_scanner_sheet.dart';

class HomeOverviewScreen extends StatefulWidget {
  const HomeOverviewScreen({
    super.key,
    required this.onOpenMaps,
    required this.onQuickScan,
    required this.profile,
  });

  final ValueChanged<MapOpenRequest?> onOpenMaps;
  final Future<void> Function(String referenceId) onQuickScan;
  final UserProfile? profile;

  @override
  State<HomeOverviewScreen> createState() => _HomeOverviewScreenState();
}

class _HomeOverviewScreenState extends State<HomeOverviewScreen>
    with SingleTickerProviderStateMixin {
  final _facilityService = FacilityService();

  late final AnimationController _pulseController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2600),
  )..repeat(reverse: true);

  bool _loading = true;
  String? _error;
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
    super.dispose();
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

  int get _publishedFloorCount => _quickLocations.length;

  int get _siteCount => _siteItems.length;

  String get _introDescription {
    if (_organizations.isEmpty) {
      return 'Önce QR ile başlayın. Kurum erişimleri tanımlandığında yayınlanan katlar burada görünecek.';
    }

    return 'Binanın girişindeki veya bulunduğunuz kattaki QR kodunu okutun. Doğru harita anında açılsın.';
  }

  List<_QuickLocationData> get _quickLocations => [
        for (final hierarchy in _hierarchies)
          for (final site in hierarchy.sites)
            for (final building in site.buildings)
              for (final floor in building.floors)
                if (floor.hasPublishedMap)
                  _QuickLocationData(
                    organizationId: hierarchy.id,
                    organizationName: hierarchy.name,
                    siteId: site.id,
                    siteName: site.name,
                    buildingId: building.id,
                    buildingName: building.name,
                    floorId: floor.id,
                    floorName: floor.name,
                  ),
      ];

  List<_SiteListItemData> get _siteItems => [
        for (final hierarchy in _hierarchies)
          for (final site in hierarchy.sites)
            _SiteListItemData(
              organizationId: hierarchy.id,
              organizationName: hierarchy.name,
              siteId: site.id,
              siteName: site.name,
              buildingCount: site.buildings.length,
              readyFloorCount: site.buildings
                  .expand((building) => building.floors)
                  .where((floor) => floor.hasPublishedMap)
                  .length,
            ),
      ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: _loading
            ? const Center(child: CircularProgressIndicator(color: _accent))
            : _error != null
                ? _OverviewError(message: _error!, onRetry: _loadOverview)
                : RefreshIndicator(
                    color: _accent,
                    backgroundColor: _surface,
                    onRefresh: _loadOverview,
                    child: ListView(
                      physics: const AlwaysScrollableScrollPhysics(
                        parent: BouncingScrollPhysics(),
                      ),
                      padding: const EdgeInsets.fromLTRB(18, 0, 18, 136),
                      children: [
                        const _Header(),
                        const SizedBox(height: 6),
                        _HeroScene(
                          greeting: _displayName,
                          description: _introDescription,
                          readyFloorCount: _publishedFloorCount,
                          siteCount: _siteCount,
                          pulse: _pulseController,
                          onPrimaryTap: () => _showQuickScanner(context),
                        ),
                        const SizedBox(height: 26),
                        _ManualSelectionPanel(
                          onTap: () => widget.onOpenMaps(null),
                        ),
                        const SizedBox(height: 28),
                        _SectionHeader(
                          title: 'Hazır başlangıçlar',
                          actionLabel:
                              _quickLocations.length > 3 ? 'Tümünü gör' : null,
                          onAction: _quickLocations.length > 3
                              ? () => widget.onOpenMaps(null)
                              : null,
                        ),
                        const SizedBox(height: 12),
                        if (_quickLocations.isEmpty)
                          const _EmptyBlock(
                            title: 'Henüz yayınlanan kat yok',
                            subtitle:
                                'İlk yayınlanan katlar hazır olduğunda hızlı başlangıçlar burada görünecek.',
                          )
                        else
                          ..._quickLocations.take(3).map(
                                (item) => Padding(
                                  padding: const EdgeInsets.only(bottom: 10),
                                  child: _QuickLocationTile(
                                    item: item,
                                    onTap: () => widget.onOpenMaps(
                                      MapOpenRequest(
                                        organizationId: item.organizationId,
                                        siteId: item.siteId,
                                        buildingId: item.buildingId,
                                        floorId: item.floorId,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                        const SizedBox(height: 28),
                        const _SectionHeader(
                          title: 'Kurum ve yerleşkeler',
                          actionLabel: null,
                          onAction: null,
                        ),
                        const SizedBox(height: 12),
                        if (_siteItems.isEmpty)
                          const _EmptyBlock(
                            title: 'Kurum bulunamadı',
                            subtitle:
                                'Yetkili olduğunuz kurum ve yerleşkeler burada listelenecek.',
                          )
                        else
                          ..._siteItems.map(
                            (item) => Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: _SiteListTile(
                                item: item,
                                onTap: () => widget.onOpenMaps(
                                  MapOpenRequest(
                                    organizationId: item.organizationId,
                                    siteId: item.siteId,
                                  ),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
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
}
