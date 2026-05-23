import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../models/auth_models.dart';
import '../models/facility_models.dart';
import '../services/facility_service.dart';

part 'home/home_overview_actions.dart';
part 'home/home_overview_manual_selection.dart';
part 'home/home_overview_qr_scene.dart';
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

  int get _publishedFloorCount => _hierarchies
      .expand((hierarchy) => hierarchy.sites)
      .expand((site) => site.buildings)
      .expand((building) => building.floors)
      .where((floor) => floor.hasPublishedMap)
      .length;

  String get _introDescription {
    if (_organizations.isEmpty) {
      return 'Önce QR ile başlayın. Kurum erişimleri tanımlandığında harita seçimi burada açılacak.';
    }

    return 'Girişteki veya bulunduğunuz kattaki QR kodunu okutun. Harita anında açılsın.';
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
                          pulse: _pulseController,
                          onPrimaryTap: () => _showQuickScanner(context),
                        ),
                        const SizedBox(height: 36),
                        _ManualSelectionPanel(
                          availableFloorCount: _publishedFloorCount,
                          organizationCount: _organizations.length,
                          onTap: () => widget.onOpenMaps(null),
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
