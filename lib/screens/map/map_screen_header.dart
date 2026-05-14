import 'package:flutter/material.dart';

class MapScreenHeader extends StatelessWidget {
  const MapScreenHeader({
    super.key,
    required this.title,
    required this.hasMap,
    required this.onBack,
    required this.onClearSelectedMap,
  });

  final String title;
  final bool hasMap;
  final VoidCallback onBack;
  final VoidCallback onClearSelectedMap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 10, 16, 0),
      child: Row(
        children: [
          IconButton(
            onPressed: onBack,
            icon: const Icon(Icons.arrow_back_ios_new_rounded),
            style: IconButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: const Color(0xFF182033),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Color(0xFF182033),
              ),
            ),
          ),
          if (hasMap)
            IconButton(
              onPressed: onClearSelectedMap,
              icon: const Icon(Icons.layers_clear_rounded),
              style: IconButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: const Color(0xFF182033),
              ),
            ),
        ],
      ),
    );
  }
}
