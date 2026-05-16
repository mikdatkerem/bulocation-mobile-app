import 'package:flutter/material.dart';

import '../../models/facility_models.dart';
import '../../models/graph_data.dart';

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
                _StepMeter(
                  currentStep: completedSteps,
                  labels: const ['Kurum', 'Yerleşke', 'Bina', 'Kat'],
                ),
                const SizedBox(height: 22),
                _SearchField<OrganizationSummary>(
                  label: 'Kurum',
                  helper: 'İlk adım. Arama ile kurum seçin.',
                  value: selectedOrganization,
                  items: organizations,
                  title: (item) => item.name,
                  onSelected: (item) => onOrganizationChanged(item.id),
                ),
                if (selectedOrganization != null) ...[
                  const SizedBox(height: 14),
                  _SearchField<SiteHierarchy>(
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
                  _SearchField<BuildingHierarchy>(
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
                  _SearchField<FloorHierarchy>(
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

class _StepMeter extends StatelessWidget {
  const _StepMeter({
    required this.currentStep,
    required this.labels,
  });

  final int currentStep;
  final List<String> labels;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(labels.length, (index) {
        final active = index < currentStep;
        final current = index == currentStep && currentStep < labels.length;

        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(right: index == labels.length - 1 ? 0 : 8),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: active || current
                    ? const Color(0xFFEEF2FF)
                    : const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: active || current
                      ? const Color(0xFF6366F1)
                      : const Color(0xFFE2E8F0),
                ),
              ),
              child: Column(
                children: [
                  Icon(
                    active
                        ? Icons.check_circle_rounded
                        : current
                            ? Icons.adjust_rounded
                            : Icons.circle_outlined,
                    size: 18,
                    color: active || current
                        ? const Color(0xFF6366F1)
                        : const Color(0xFF94A3B8),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    labels[index],
                    style: TextStyle(
                      color: active || current
                          ? const Color(0xFF4338CA)
                          : const Color(0xFF94A3B8),
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }
}

class _SearchField<T> extends StatelessWidget {
  const _SearchField({
    required this.label,
    required this.helper,
    required this.value,
    required this.items,
    required this.title,
    required this.onSelected,
  });

  final String label;
  final String helper;
  final T? value;
  final List<T> items;
  final String Function(T item) title;
  final ValueChanged<T> onSelected;

  @override
  Widget build(BuildContext context) {
    final isDisabled = items.isEmpty;
    final hasValue = value != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: const TextStyle(
            color: Color(0xFF64748B),
            fontSize: 11,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.4,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          helper,
          style: const TextStyle(
            color: Color(0xFF94A3B8),
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 10),
        InkWell(
          onTap: isDisabled
              ? null
              : () async {
                  final selected = await Navigator.of(context).push<T>(
                    PageRouteBuilder<T>(
                      pageBuilder: (_, __, ___) => _SearchPickerPage<T>(
                        label: label,
                        items: items,
                        value: value,
                        title: title,
                      ),
                      transitionsBuilder: (_, animation, __, child) {
                        final curved = CurvedAnimation(
                          parent: animation,
                          curve: Curves.easeOutCubic,
                        );
                        return FadeTransition(
                          opacity: curved,
                          child: SlideTransition(
                            position: Tween(
                              begin: const Offset(0, 0.04),
                              end: Offset.zero,
                            ).animate(curved),
                            child: child,
                          ),
                        );
                      },
                    ),
                  );

                  if (selected != null) {
                    onSelected(selected);
                  }
                },
          borderRadius: BorderRadius.circular(20),
          child: Ink(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: BoxDecoration(
              color:
                  hasValue ? const Color(0xFFF8FAFF) : const Color(0xFFF9FBFF),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: hasValue
                    ? const Color(0xFFCBD5FF)
                    : const Color(0xFFE2E8F0),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: hasValue
                        ? const Color(0xFFEEF2FF)
                        : const Color(0xFFFFFFFF),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.search_rounded,
                    color: isDisabled
                        ? const Color(0xFFCBD5E1)
                        : const Color(0xFF6366F1),
                    size: 18,
                  ),
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
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                  Icons.arrow_forward_rounded,
                  color: isDisabled
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
    final items = _rankedItems(widget.items, _query, widget.title);

    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FD),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF6F8FD),
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
              Container(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x100F172A),
                      blurRadius: 18,
                      offset: Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${widget.label.toUpperCase()} ARA',
                      style: const TextStyle(
                        color: Color(0xFF6366F1),
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.6,
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Aramaya harf yazarak başlayın. Sonuçlar anında filtrelenir.',
                      style: TextStyle(
                        color: Color(0xFF64748B),
                        fontSize: 13,
                        height: 1.45,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 14),
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
                        fillColor: const Color(0xFFF8FAFC),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 14,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: const BorderSide(
                            color: Color(0xFF6366F1),
                            width: 1.2,
                          ),
                        ),
                      ),
                    ),
                  ],
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
                                borderRadius: BorderRadius.circular(18),
                                child: Ink(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 16,
                                  ),
                                  decoration: BoxDecoration(
                                    color: selected
                                        ? const Color(0xFFEEF2FF)
                                        : const Color(0xFFFFFFFF),
                                    borderRadius: BorderRadius.circular(18),
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
    final normalizedQuery = normalizeSearchText(query);
    if (normalizedQuery.isEmpty) {
      return const [];
    }

    final startsWith = <T>[];
    final contains = <T>[];

    for (final item in items) {
      final normalizedTitle = normalizeSearchText(title(item));
      if (normalizedTitle.startsWith(normalizedQuery)) {
        startsWith.add(item);
      } else if (normalizedTitle.contains(normalizedQuery)) {
        contains.add(item);
      }
    }

    startsWith.sort(
      (left, right) => compareNodeLabelsNatural(title(left), title(right)),
    );
    contains.sort(
      (left, right) => compareNodeLabelsNatural(title(left), title(right)),
    );

    return [...startsWith, ...contains];
  }
}
