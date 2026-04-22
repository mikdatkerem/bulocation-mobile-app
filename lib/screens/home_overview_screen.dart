import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../models/auth_models.dart';
import '../models/facility_models.dart';
import '../services/facility_service.dart';

const _bg = Color(0xFF060708);
const _surface = Color(0xFF0D1013);
const _surfaceStrong = Color(0xFF11161D);
const _line = Color(0x1AF5F3EF);
const _text = Color(0xFFF5F3EF);
const _muted = Color(0xFF8F96A3);
const _soft = Color(0xFFD7D2CA);
const _accent = Color(0xFF1836B9);

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

class _HomeOverviewScreenState extends State<HomeOverviewScreen> {
  final _facilityService = FacilityService();

  bool _loading = true;
  String? _error;
  List<OrganizationSummary> _organizations = const [];
  List<OrganizationHierarchy> _hierarchies = const [];

  @override
  void initState() {
    super.initState();
    _loadOverview();
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
                      padding: const EdgeInsets.fromLTRB(20, 18, 20, 120),
                      children: [
                        _Header(
                          initials: _initials(
                            widget.profile?.fullName ??
                                widget.profile?.userName ??
                                'BL',
                          ),
                        ),
                        const SizedBox(height: 34),
                        const Text(
                          'Nereye gitmek istiyorsunuz?',
                          style: TextStyle(
                            color: _text,
                            fontSize: 30,
                            height: 1.05,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -1.1,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          _organizations.isEmpty
                              ? 'Kurum verisi yuklenince QR veya kurum aramasi ile baslayabilirsiniz.'
                              : 'QR okutun ya da kurum, bina veya kat secerek navigasyona baslayin.',
                          style: const TextStyle(
                            color: _soft,
                            fontSize: 14,
                            height: 1.55,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 24),
                        _PrimaryAction(
                          title: 'QR ile basla',
                          subtitle: 'Bulundugunuz noktayi otomatik acin.',
                          icon: Icons.qr_code_scanner_rounded,
                          onTap: () => _showQuickScanner(context),
                        ),
                        const SizedBox(height: 12),
                        _SearchAction(
                          label: 'Kurum, bina veya kat sec',
                          onTap: () => widget.onOpenMaps(null),
                        ),
                        if (_quickLocations.isNotEmpty) ...[
                          const SizedBox(height: 34),
                          _SectionHeader(
                            title: 'Hizli giris',
                            actionLabel: 'Tumunu ac',
                            onAction: () => widget.onOpenMaps(null),
                          ),
                          const SizedBox(height: 12),
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
                        ],
                        const SizedBox(height: 28),
                        const _SectionHeader(
                          title: 'Kurumlar',
                          actionLabel: null,
                          onAction: null,
                        ),
                        const SizedBox(height: 12),
                        if (_siteItems.isEmpty)
                          const _EmptyBlock(
                            title: 'Kurum bulunamadi',
                            subtitle:
                                'Yetkili oldugunuz kurumlar burada listelenecek.',
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

  String _initials(String input) {
    final parts = input
        .split(RegExp(r'\s+'))
        .where((item) => item.trim().isNotEmpty)
        .toList();
    if (parts.isEmpty) {
      return 'BL';
    }
    if (parts.length == 1) {
      return parts.first.substring(0, 1).toUpperCase();
    }
    return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.initials});

  final String initials;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Image.asset(
          'assets/logo_removed_bg.png',
          height: 34,
          fit: BoxFit.contain,
        ),
        const Spacer(),
        Container(
          width: 42,
          height: 42,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: _surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: _line),
          ),
          child: Text(
            initials,
            style: const TextStyle(
              color: _text,
              fontWeight: FontWeight.w800,
              fontSize: 13,
            ),
          ),
        ),
      ],
    );
  }
}

class _PrimaryAction extends StatelessWidget {
  const _PrimaryAction({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Ink(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: _accent,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, color: _text, size: 28),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: _text,
                      fontSize: 17,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: _text.withValues(alpha: 0.74),
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_rounded, color: _text),
          ],
        ),
      ),
    );
  }
}

class _SearchAction extends StatelessWidget {
  const _SearchAction({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Ink(
        height: 60,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: _surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: _line),
        ),
        child: Row(
          children: [
            const Icon(Icons.search_rounded, color: _muted),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  color: _soft,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const Icon(Icons.tune_rounded, color: _muted),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.title,
    required this.actionLabel,
    required this.onAction,
  });

  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title.toUpperCase(),
            style: const TextStyle(
              color: _muted,
              fontSize: 12,
              fontWeight: FontWeight.w900,
              letterSpacing: 2.4,
            ),
          ),
        ),
        if (actionLabel != null)
          TextButton(
            onPressed: onAction,
            style: TextButton.styleFrom(
              foregroundColor: _soft,
              padding: EdgeInsets.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Text(actionLabel!),
          ),
      ],
    );
  }
}

class _QuickLocationData {
  const _QuickLocationData({
    required this.organizationId,
    required this.organizationName,
    required this.siteId,
    required this.siteName,
    required this.buildingId,
    required this.buildingName,
    required this.floorId,
    required this.floorName,
  });

  final String organizationId;
  final String organizationName;
  final String siteId;
  final String siteName;
  final String buildingId;
  final String buildingName;
  final String floorId;
  final String floorName;
}

class _QuickLocationTile extends StatelessWidget {
  const _QuickLocationTile({
    required this.item,
    required this.onTap,
  });

  final _QuickLocationData item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return _DarkTile(
      icon: Icons.map_outlined,
      title: item.buildingName,
      subtitle: '${item.siteName} - ${item.floorName}',
      meta: item.organizationName,
      onTap: onTap,
    );
  }
}

class _SiteListItemData {
  const _SiteListItemData({
    required this.organizationId,
    required this.organizationName,
    required this.siteId,
    required this.siteName,
    required this.buildingCount,
    required this.readyFloorCount,
  });

  final String organizationId;
  final String organizationName;
  final String siteId;
  final String siteName;
  final int buildingCount;
  final int readyFloorCount;
}

class _SiteListTile extends StatelessWidget {
  const _SiteListTile({
    required this.item,
    required this.onTap,
  });

  final _SiteListItemData item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return _DarkTile(
      icon: Icons.location_city_rounded,
      title: item.siteName,
      subtitle:
          '${item.organizationName} - ${item.buildingCount} bina - ${item.readyFloorCount} hazir kat',
      meta: 'Kurum sec',
      onTap: onTap,
    );
  }
}

class _DarkTile extends StatelessWidget {
  const _DarkTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.meta,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final String meta;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Ink(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: _surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: _line),
        ),
        child: Row(
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: _surfaceStrong,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: _line),
              ),
              child: Icon(icon, color: _soft),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: _text,
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: _muted,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  meta.toUpperCase(),
                  style: const TextStyle(
                    color: _soft,
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.1,
                  ),
                ),
                const SizedBox(height: 8),
                const Icon(Icons.chevron_right_rounded, color: _muted),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyBlock extends StatelessWidget {
  const _EmptyBlock({
    required this.title,
    required this.subtitle,
  });

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: _text,
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: const TextStyle(
              color: _muted,
              height: 1.55,
            ),
          ),
        ],
      ),
    );
  }
}

class _OverviewError extends StatelessWidget {
  const _OverviewError({
    required this.message,
    required this.onRetry,
  });

  final String message;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline_rounded, size: 34, color: _soft),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: _soft),
            ),
            const SizedBox(height: 18),
            FilledButton(
              onPressed: onRetry,
              style: FilledButton.styleFrom(
                backgroundColor: _accent,
                foregroundColor: _text,
              ),
              child: const Text('Tekrar dene'),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickScannerSheet extends StatelessWidget {
  const _QuickScannerSheet({
    required this.controller,
    required this.onDetect,
  });

  final MobileScannerController controller;
  final Future<void> Function(String referenceId) onDetect;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 52,
                  height: 5,
                  decoration: BoxDecoration(
                    color: _line,
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              const Text(
                'QR okut',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: _text,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'QR hangi kat veya binaya aitse harita otomatik acilir.',
                style: TextStyle(
                  height: 1.5,
                  color: _soft,
                ),
              ),
              const SizedBox(height: 18),
              ClipRRect(
                borderRadius: BorderRadius.circular(22),
                child: SizedBox(
                  height: 320,
                  child: MobileScanner(
                    controller: controller,
                    onDetect: (capture) async {
                      final value =
                          capture.barcodes.firstOrNull?.rawValue?.trim();
                      if (value == null || value.isEmpty) {
                        return;
                      }
                      await onDetect(value);
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
