import 'package:flutter/material.dart';

import '../../models/facility_models.dart';
import 'map_selection_search_field.dart';
import 'map_selection_step_meter.dart';

class MapSelectionPanel extends StatelessWidget {
  const MapSelectionPanel({
    super.key,
    required this.organizations,
    required this.selectedOrganizationId,
    required this.sites,
    required this.selectedSiteId,
    required this.buildings,
    required this.selectedBuildingId,
    required this.floors,
    required this.selectedFloorId,
    required this.onOrganizationChanged,
    required this.onSiteChanged,
    required this.onBuildingChanged,
    required this.onFloorChanged,
  });

  final List<OrganizationSummary> organizations;
  final String? selectedOrganizationId;
  final List<SiteHierarchy> sites;
  final String? selectedSiteId;
  final List<BuildingHierarchy> buildings;
  final String? selectedBuildingId;
  final List<FloorHierarchy> floors;
  final String? selectedFloorId;
  final ValueChanged<String?> onOrganizationChanged;
  final ValueChanged<String?> onSiteChanged;
  final ValueChanged<String?> onBuildingChanged;
  final ValueChanged<String?> onFloorChanged;

  @override
  Widget build(BuildContext context) {
    final selectedOrganization = organizations
        .where((item) => item.id == selectedOrganizationId)
        .firstOrNull;
    final selectedSite =
        sites.where((item) => item.id == selectedSiteId).firstOrNull;
    final selectedBuilding =
        buildings.where((item) => item.id == selectedBuildingId).firstOrNull;
    final selectedFloor =
        floors.where((item) => item.id == selectedFloorId).firstOrNull;

    final completedSteps = [
      selectedOrganization != null,
      selectedSite != null,
      selectedBuilding != null,
      selectedFloor != null,
    ].where((value) => value).length;

    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFFF8FAFF),
            Color(0xFFF3F6FC),
          ],
        ),
      ),
      child: Align(
        alignment: Alignment.center,
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 430),
            padding: const EdgeInsets.fromLTRB(20, 22, 20, 22),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.96),
              borderRadius: BorderRadius.circular(30),
              border: Border.all(color: const Color(0xFFE2E8F0)),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x140F172A),
                  blurRadius: 30,
                  offset: Offset(0, 18),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _SelectionHeader(completedSteps: completedSteps),
                const SizedBox(height: 14),
                const Text(
                  'Önce kurum seçin. Sonraki adımlar sadece önceki seçiminize göre açılır.',
                  style: TextStyle(
                    fontSize: 14,
                    height: 1.55,
                    color: Color(0xFF64748B),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 18),
                MapSelectionStepMeter(
                  currentStep: completedSteps,
                  labels: const ['Kurum', 'Yerleşke', 'Bina', 'Kat'],
                ),
                if (completedSteps > 0) ...[
                  const SizedBox(height: 18),
                  _SelectedPathSummary(
                    organization: selectedOrganization?.name,
                    site: selectedSite?.name,
                    building: selectedBuilding?.name,
                    floor: selectedFloor?.name,
                  ),
                ],
                const SizedBox(height: 22),
                _ActiveSelectionStep(
                  selectedOrganization: selectedOrganization,
                  selectedSite: selectedSite,
                  selectedBuilding: selectedBuilding,
                  selectedFloor: selectedFloor,
                  organizations: organizations,
                  sites: sites,
                  buildings: buildings,
                  floors: floors,
                  onOrganizationChanged: onOrganizationChanged,
                  onSiteChanged: onSiteChanged,
                  onBuildingChanged: onBuildingChanged,
                  onFloorChanged: onFloorChanged,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SelectionHeader extends StatelessWidget {
  const _SelectionHeader({required this.completedSteps});

  final int completedSteps;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: const Color(0xFFEEF2FF),
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Icon(
            Icons.map_rounded,
            color: Color(0xFF6366F1),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'MANUEL SEÇİM',
                style: TextStyle(
                  color: Color(0xFF6366F1),
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.8,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                completedSteps == 0
                    ? 'Kurum seçin'
                    : '$completedSteps/4 adım tamamlandı',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.5,
                  color: Color(0xFF0F172A),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ActiveSelectionStep extends StatelessWidget {
  const _ActiveSelectionStep({
    required this.selectedOrganization,
    required this.selectedSite,
    required this.selectedBuilding,
    required this.selectedFloor,
    required this.organizations,
    required this.sites,
    required this.buildings,
    required this.floors,
    required this.onOrganizationChanged,
    required this.onSiteChanged,
    required this.onBuildingChanged,
    required this.onFloorChanged,
  });

  final OrganizationSummary? selectedOrganization;
  final SiteHierarchy? selectedSite;
  final BuildingHierarchy? selectedBuilding;
  final FloorHierarchy? selectedFloor;
  final List<OrganizationSummary> organizations;
  final List<SiteHierarchy> sites;
  final List<BuildingHierarchy> buildings;
  final List<FloorHierarchy> floors;
  final ValueChanged<String?> onOrganizationChanged;
  final ValueChanged<String?> onSiteChanged;
  final ValueChanged<String?> onBuildingChanged;
  final ValueChanged<String?> onFloorChanged;

  @override
  Widget build(BuildContext context) {
    if (selectedOrganization == null) {
      return MapSelectionSearchField<OrganizationSummary>(
        label: 'Kurum',
        helper: 'Arama ile kurum seçin.',
        value: selectedOrganization,
        items: organizations,
        title: (item) => item.name,
        onSelected: (item) => onOrganizationChanged(item.id),
      );
    }

    if (selectedSite == null) {
      return MapSelectionSearchField<SiteHierarchy>(
        label: 'Yerleşke',
        helper: 'Seçilen kuruma ait yerleşkeler.',
        value: selectedSite,
        items: sites,
        title: (item) => item.name,
        onSelected: (item) => onSiteChanged(item.id),
      );
    }

    if (selectedBuilding == null) {
      return MapSelectionSearchField<BuildingHierarchy>(
        label: 'Bina',
        helper: 'Seçilen yerleşkeye ait binalar.',
        value: selectedBuilding,
        items: buildings,
        title: (item) => item.name,
        onSelected: (item) => onBuildingChanged(item.id),
      );
    }

    return MapSelectionSearchField<FloorHierarchy>(
      label: 'Kat',
      helper: selectedFloor == null
          ? 'Haritayı açmak için son adım.'
          : 'Seçilen kat haritası açılıyor.',
      value: selectedFloor,
      items: floors,
      title: (item) => item.name,
      onSelected: (item) => onFloorChanged(item.id),
    );
  }
}

class _SelectedPathSummary extends StatelessWidget {
  const _SelectedPathSummary({
    required this.organization,
    required this.site,
    required this.building,
    required this.floor,
  });

  final String? organization;
  final String? site;
  final String? building;
  final String? floor;

  @override
  Widget build(BuildContext context) {
    final items = [
      if (organization != null) ('Kurum', organization!),
      if (site != null) ('Yerleşke', site!),
      if (building != null) ('Bina', building!),
      if (floor != null) ('Kat', floor!),
    ];

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final item in items)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFF),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Text(
              '${item.$1}: ${item.$2}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Color(0xFF475569),
                fontSize: 12,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
      ],
    );
  }
}
