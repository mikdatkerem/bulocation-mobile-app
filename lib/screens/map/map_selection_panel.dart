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
              color: Colors.white.withValues(alpha: 0.94),
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
                Row(
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
                                ? 'Harita seçin'
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
                ),
                const SizedBox(height: 14),
                const Text(
                  'Önce kurum seçin. Sonrasında yerleşke, bina ve kat adımları sırasıyla açılır.',
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
                const SizedBox(height: 22),
                MapSelectionSearchField<OrganizationSummary>(
                  label: 'Kurum',
                  helper: 'İlk adım. Arama ile kurum seçin.',
                  value: selectedOrganization,
                  items: organizations,
                  title: (item) => item.name,
                  onSelected: (item) => onOrganizationChanged(item.id),
                ),
                if (selectedOrganization != null) ...[
                  const SizedBox(height: 14),
                  MapSelectionSearchField<SiteHierarchy>(
                    label: 'Yerleşke',
                    helper: 'Seçilen kuruma ait yerleşkeler',
                    value: selectedSite,
                    items: sites,
                    title: (item) => item.name,
                    onSelected: (item) => onSiteChanged(item.id),
                  ),
                ],
                if (selectedSite != null) ...[
                  const SizedBox(height: 14),
                  MapSelectionSearchField<BuildingHierarchy>(
                    label: 'Bina',
                    helper: 'Seçilen yerleşkeye ait binalar',
                    value: selectedBuilding,
                    items: buildings,
                    title: (item) => item.name,
                    onSelected: (item) => onBuildingChanged(item.id),
                  ),
                ],
                if (selectedBuilding != null) ...[
                  const SizedBox(height: 14),
                  MapSelectionSearchField<FloorHierarchy>(
                    label: 'Kat',
                    helper: 'Haritayı açmak için son adım',
                    value: selectedFloor,
                    items: floors,
                    title: (item) => item.name,
                    onSelected: (item) => onFloorChanged(item.id),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
