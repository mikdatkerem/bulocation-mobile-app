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
                  'QR okutursanız ilgili kat otomatik açılır. Elle seçmek için kurum, yerleşke, bina ve katı belirleyin.',
                  style: TextStyle(
                    fontSize: 13,
                    height: 1.5,
                    color: Color(0xFF64748B),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 22),
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
                  label: 'Yerleşke',
                  value: sites.where((item) => item.id == selectedSiteId).firstOrNull,
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
                  value: floors.where((item) => item.id == selectedFloorId).firstOrNull,
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

class _PickerField<T> extends StatefulWidget {
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
  State<_PickerField<T>> createState() => _PickerFieldState<T>();
}

class _PickerFieldState<T> extends State<_PickerField<T>> {
  late final TextEditingController _controller;
  late final FocusNode _focusNode;
  String _query = '';

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: _selectedText);
    _focusNode = FocusNode()
      ..addListener(() {
        if (!_focusNode.hasFocus && mounted) {
          setState(() {});
        }
      });
  }

  @override
  void didUpdateWidget(covariant _PickerField<T> oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.value != oldWidget.value || widget.items != oldWidget.items) {
      final nextText = _selectedText;
      if (_controller.text != nextText && _query.isEmpty) {
        _controller.text = nextText;
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  String get _selectedText {
    final value = widget.value;
    return value == null ? '' : widget.title(value);
  }

  List<T> get _filteredItems {
    final query = _query.trim().toLowerCase();
    if (query.isEmpty) {
      return const [];
    }

    return widget.items
        .where((item) => widget.title(item).toLowerCase().contains(query))
        .toList(growable: false);
  }

  @override
  Widget build(BuildContext context) {
    final enabled = widget.items.isNotEmpty;
    final filteredItems = _filteredItems;
    final showResults = enabled && _focusNode.hasFocus && _query.trim().isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 2, bottom: 8),
          child: Text(
            widget.label,
            style: const TextStyle(
              color: Color(0xFF64748B),
              fontSize: 12,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.4,
            ),
          ),
        ),
        TextField(
          controller: _controller,
          focusNode: _focusNode,
          enabled: enabled,
          onChanged: (value) {
            setState(() => _query = value);
          },
          decoration: InputDecoration(
            hintText: enabled ? '${widget.label} yazın' : '${widget.label} yok',
            hintStyle: const TextStyle(
              color: Color(0xFF94A3B8),
              fontWeight: FontWeight.w600,
            ),
            prefixIcon: const Icon(
              Icons.search_rounded,
              color: Color(0xFF64748B),
            ),
            suffixIcon: _controller.text.isEmpty
                ? null
                : IconButton(
                    onPressed: () {
                      _controller.clear();
                      setState(() => _query = '');
                      widget.onChanged(null);
                    },
                    icon: const Icon(
                      Icons.close_rounded,
                      color: Color(0xFF94A3B8),
                    ),
                  ),
            filled: true,
            fillColor: enabled ? const Color(0xFFF1F5F9) : const Color(0xFFF8FAFC),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 15),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide:
                  const BorderSide(color: Color(0xFF6366F1), width: 1.2),
            ),
          ),
        ),
        if (showResults) ...[
          const SizedBox(height: 8),
          DecoratedBox(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: filteredItems.isEmpty
                ? const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    child: Text(
                      'Sonuç bulunamadı.',
                      style: TextStyle(
                        color: Color(0xFF64748B),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  )
                : ConstrainedBox(
                    constraints: const BoxConstraints(maxHeight: 220),
                    child: ListView.separated(
                      shrinkWrap: true,
                      padding: const EdgeInsets.all(8),
                      itemCount: filteredItems.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 6),
                      itemBuilder: (context, index) {
                        final item = filteredItems[index];
                        final selected = widget.value == item;

                        return InkWell(
                          onTap: () {
                            _controller.text = widget.title(item);
                            _query = '';
                            widget.onChanged(item);
                            _focusNode.unfocus();
                            setState(() {});
                          },
                          borderRadius: BorderRadius.circular(10),
                          child: Ink(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              color: selected
                                  ? const Color(0xFFEEF2FF)
                                  : const Color(0xFFF8FAFC),
                              borderRadius: BorderRadius.circular(10),
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
          ),
        ],
      ],
    );
  }
}
