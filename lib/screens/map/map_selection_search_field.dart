import 'package:flutter/material.dart';

import 'map_selection_search_picker_page.dart';

class MapSelectionSearchField<T> extends StatelessWidget {
  const MapSelectionSearchField({
    super.key,
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
                      pageBuilder: (_, __, ___) => MapSelectionSearchPickerPage<T>(
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
