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
    final selectedOrganization = organizations
        .where((item) => item.id == selectedOrganizationId)
        .firstOrNull;
    final selectedSite =
        sites.where((item) => item.id == selectedSiteId).firstOrNull;
    final selectedBuilding =
        buildings.where((item) => item.id == selectedBuildingId).firstOrNull;
    final selectedFloor =
        floors.where((item) => item.id == selectedFloorId).firstOrNull;

    return Container(
      color: const Color(0xFFF8FAFC),
      child: Align(
        alignment: Alignment.center,
        child: Padding(
          padding: const EdgeInsets.all(22),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 420),
            padding: const EdgeInsets.fromLTRB(20, 22, 20, 22),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFE2E8F0)),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x1A0F172A),
                  blurRadius: 30,
                  offset: Offset(0, 18),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: const Color(0xFFEEF2FF),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.map_rounded,
                    color: Color(0xFF6366F1),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Harita seçin',
                  style: TextStyle(
                    fontFamily: 'Manrope',
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.6,
                    color: Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Önce kurum seçin. Sonrasında yerleşke, bina ve kat adımları sırayla açılır.',
                  style: TextStyle(
                    fontSize: 13,
                    height: 1.5,
                    color: Color(0xFF64748B),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 22),
                _SearchField<OrganizationSummary>(
                  label: 'Kurum',
                  value: selectedOrganization,
                  items: organizations,
                  title: (item) => item.name,
                  onSelected: (item) => onOrganizationChanged(item.id),
                ),
                if (selectedOrganization != null) ...[
                  const SizedBox(height: 14),
                  _SearchField<SiteHierarchy>(
                    label: 'Yerleşke',
                    value: selectedSite,
                    items: sites,
                    title: (item) => item.name,
                    onSelected: (item) => onSiteChanged(item.id),
                  ),
                ],
                if (selectedSite != null) ...[
                  const SizedBox(height: 14),
                  _SearchField<BuildingHierarchy>(
                    label: 'Bina',
                    value: selectedBuilding,
                    items: buildings,
                    title: (item) => item.name,
                    onSelected: (item) => onBuildingChanged(item.id),
                  ),
                ],
                if (selectedBuilding != null) ...[
                  const SizedBox(height: 14),
                  _SearchField<FloorHierarchy>(
                    label: 'Kat',
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

class _SearchField<T> extends StatelessWidget {
  const _SearchField({
    required this.label,
    required this.value,
    required this.items,
    required this.title,
    required this.onSelected,
  });

  final String label;
  final T? value;
  final List<T> items;
  final String Function(T item) title;
  final ValueChanged<T> onSelected;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 2, bottom: 8),
          child: Text(
            label,
            style: const TextStyle(
              color: Color(0xFF64748B),
              fontSize: 12,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.4,
            ),
          ),
        ),
        InkWell(
          onTap: items.isEmpty
              ? null
              : () async {
                  final selected = await Navigator.of(context).push<T>(
                    MaterialPageRoute<T>(
                      fullscreenDialog: true,
                      builder: (_) => _SearchPickerPage<T>(
                        label: label,
                        items: items,
                        value: value,
                        title: title,
                      ),
                    ),
                  );

                  if (selected != null) {
                    onSelected(selected);
                  }
                },
          borderRadius: BorderRadius.circular(10),
          child: Ink(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 15),
            decoration: BoxDecoration(
              color: items.isEmpty
                  ? const Color(0xFFF8FAFC)
                  : const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: items.isEmpty
                    ? const Color(0xFFE2E8F0)
                    : const Color(0x00000000),
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.search_rounded,
                  color: Color(0xFF64748B),
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    value == null ? '$label arayın' : title(value as T),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: value == null
                          ? const Color(0xFF94A3B8)
                          : const Color(0xFF0F172A),
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                  Icons.chevron_right_rounded,
                  color: items.isEmpty
                      ? const Color(0xFFCBD5E1)
                      : const Color(0xFF6366F1),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _SearchPickerPage<T> extends StatefulWidget {
  const _SearchPickerPage({
    required this.label,
    required this.items,
    required this.value,
    required this.title,
  });

  final String label;
  final List<T> items;
  final T? value;
  final String Function(T item) title;

  @override
  State<_SearchPickerPage<T>> createState() => _SearchPickerPageState<T>();
}

class _SearchPickerPageState<T> extends State<_SearchPickerPage<T>> {
  late final TextEditingController _controller;
  String _query = '';

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final items = _rankedItems(
      widget.items,
      _query,
      widget.title,
    );

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF8FAFC),
        surfaceTintColor: Colors.transparent,
        title: Text(
          '${widget.label} seçin',
          style: const TextStyle(
            fontWeight: FontWeight.w800,
            color: Color(0xFF0F172A),
          ),
        ),
      ),
      body: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: _controller,
                autofocus: true,
                onChanged: (value) => setState(() => _query = value),
                decoration: InputDecoration(
                  hintText: '${widget.label} yazın',
                  hintStyle: const TextStyle(
                    color: Color(0xFF94A3B8),
                    fontWeight: FontWeight.w600,
                  ),
                  prefixIcon: const Icon(
                    Icons.search_rounded,
                    color: Color(0xFF64748B),
                  ),
                  suffixIcon: _query.isEmpty
                      ? null
                      : IconButton(
                          onPressed: () {
                            _controller.clear();
                            setState(() => _query = '');
                          },
                          icon: const Icon(
                            Icons.close_rounded,
                            color: Color(0xFF94A3B8),
                          ),
                        ),
                  filled: true,
                  fillColor: const Color(0xFFFFFFFF),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 14,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(
                      color: Color(0xFF6366F1),
                      width: 1.2,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: _query.trim().isEmpty
                    ? const Center(
                        child: Text(
                          'Aramaya başlayın.',
                          style: TextStyle(
                            color: Color(0xFF64748B),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      )
                    : items.isEmpty
                        ? const Center(
                            child: Text(
                              'Sonuç bulunamadı.',
                              style: TextStyle(
                                color: Color(0xFF64748B),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          )
                        : ListView.separated(
                            itemCount: items.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(height: 8),
                            itemBuilder: (context, index) {
                              final item = items[index];
                              final selected = widget.value == item;

                              return InkWell(
                                onTap: () => Navigator.of(context).pop(item),
                                borderRadius: BorderRadius.circular(14),
                                child: Ink(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 16,
                                  ),
                                  decoration: BoxDecoration(
                                    color: selected
                                        ? const Color(0xFFEEF2FF)
                                        : const Color(0xFFFFFFFF),
                                    borderRadius: BorderRadius.circular(14),
                                    border: Border.all(
                                      color: selected
                                          ? const Color(0xFF6366F1)
                                          : const Color(0xFFE2E8F0),
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          widget.title(item),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            color: selected
                                                ? const Color(0xFF4338CA)
                                                : const Color(0xFF0F172A),
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ),
                                      if (selected)
                                        const Icon(
                                          Icons.check_rounded,
                                          color: Color(0xFF6366F1),
                                          size: 18,
                                        ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<T> _rankedItems(
    List<T> items,
    String query,
    String Function(T item) title,
  ) {
    final normalized = query.trim().toLowerCase();
    if (normalized.isEmpty) {
      return const [];
    }

    final startsWith = <T>[];
    final contains = <T>[];

    for (final item in items) {
      final value = title(item).toLowerCase();
      if (value.startsWith(normalized)) {
        startsWith.add(item);
      } else if (value.contains(normalized)) {
        contains.add(item);
      }
    }

    int compare(T a, T b) =>
        title(a).toLowerCase().compareTo(title(b).toLowerCase());

    startsWith.sort(compare);
    contains.sort(compare);

    return [...startsWith, ...contains];
  }
}
