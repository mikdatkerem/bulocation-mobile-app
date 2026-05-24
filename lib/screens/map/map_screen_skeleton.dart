import 'package:flutter/material.dart';

import '../../widgets/park_bottom_sheet.dart';
import '../../widgets/skeleton.dart';
import 'map_screen_header.dart';

class MapScreenSkeleton extends StatelessWidget {
  const MapScreenSkeleton({super.key, required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final bottomInset =
        MediaQuery.of(context).size.height * ParkBottomSheet.peekSize + 4;

    return SafeArea(
      child: SkeletonShimmer(
        child: Column(
          children: [
            MapScreenHeader(title: 'Harita hazirlaniyor', onBack: onBack),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 6, 20, 0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: const SkeletonBox(
                  height: 112,
                  radius: 10,
                  color: Color(0xFFDDE5F1),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: EdgeInsets.fromLTRB(12, 8, 12, bottomInset),
                child: SkeletonPanel(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SkeletonLine(width: 54, height: 34),
                      const SizedBox(height: 18),
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFFE8EEF7),
                            borderRadius: BorderRadius.circular(22),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const _MapSheetHandleSkeleton(),
          ],
        ),
      ),
    );
  }
}

class _MapSheetHandleSkeleton extends StatelessWidget {
  const _MapSheetHandleSkeleton();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * ParkBottomSheet.peekSize,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      child: const Center(
        child: SkeletonLine(width: 58, height: 6),
      ),
    );
  }
}
