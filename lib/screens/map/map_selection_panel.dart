import 'package:flutter/material.dart';

import '../../models/facility_models.dart';

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
    return Container(
      color: const Color(0xFFF8FAFD),
      child: Align(
        alignment: Alignment.bottomCenter,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: const Color(0xFFE4EAF5)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Harita secin',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF182033),
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'QR okutursaniz ilgili kat otomatik acilir. Elle secmek icin kurum, yerleske, bina ve kati belirleyin.',
                  style: TextStyle(
                    fontSize: 13,
                    height: 1.5,
                    color: Color(0xFF6E7890),
                  ),
                ),
                const SizedBox(height: 18),
                _PickerField<OrganizationSummary>(
                  label: 'Kurum',
                  value: organizations
                      .where((item) => item.id == selectedOrganizationId)
                      .firstOrNull,
                  items: organizations,
                  onChanged: (item) => onOrganizationChanged(item?.id),
                  title: (item) => item.name,
                ),
                const SizedBox(height: 12),
                _PickerField<SiteHierarchy>(
                  label: 'Yerleske',
                  value: sites
                      .where((item) => item.id == selectedSiteId)
                      .firstOrNull,
                  items: sites,
                  onChanged: (item) => onSiteChanged(item?.id),
                  title: (item) => item.name,
                ),
                const SizedBox(height: 12),
                _PickerField<BuildingHierarchy>(
                  label: 'Bina',
                  value: buildings
                      .where((item) => item.id == selectedBuildingId)
                      .firstOrNull,
                  items: buildings,
                  onChanged: (item) => onBuildingChanged(item?.id),
                  title: (item) => item.name,
                ),
                const SizedBox(height: 12),
                _PickerField<FloorHierarchy>(
                  label: 'Kat',
                  value: floors
                      .where((item) => item.id == selectedFloorId)
                      .firstOrNull,
                  items: floors,
                  onChanged: (item) => onFloorChanged(item?.id),
                  title: (item) => item.name,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PickerField<T> extends StatelessWidget {
  const _PickerField({
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
    required this.title,
  });

  final String label;
  final T? value;
  final List<T> items;
  final ValueChanged<T?> onChanged;
  final String Function(T item) title;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<T>(
      initialValue: value,
      isExpanded: true,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: const Color(0xFFF5F7FB),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide.none,
        ),
      ),
      items: items
          .map(
            (item) => DropdownMenuItem<T>(
              value: item,
              child: Text(
                title(item),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          )
          .toList(),
      onChanged: items.isEmpty ? null : onChanged,
    );
  }
}
