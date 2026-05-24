part of '../home_overview_screen.dart';

class _HomeOverviewSkeleton extends StatelessWidget {
  const _HomeOverviewSkeleton();

  @override
  Widget build(BuildContext context) {
    return SkeletonShimmer(
      child: PageView(
        scrollDirection: Axis.vertical,
        physics: const NeverScrollableScrollPhysics(),
        children: const [
          _HomeHeroSkeletonPage(),
          _HomeManualSkeletonPage(),
        ],
      ),
    );
  }
}

class _HomeHeroSkeletonPage extends StatelessWidget {
  const _HomeHeroSkeletonPage();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 14),
          const Row(
            children: [
              SkeletonBox(width: 128, height: 34, radius: 14),
              Spacer(),
              SkeletonBox(width: 44, height: 44, radius: 18),
            ],
          ),
          const SizedBox(height: 46),
          const SkeletonLine(width: 132, height: 14),
          const SizedBox(height: 18),
          const SkeletonLine(width: 292, height: 42),
          const SizedBox(height: 10),
          const SkeletonLine(width: 248, height: 42),
          const SizedBox(height: 18),
          const SkeletonLine(width: 190, height: 12),
          const SizedBox(height: 14),
          const SkeletonLine(width: 318),
          const SizedBox(height: 8),
          const SkeletonLine(width: 274),
          const Spacer(),
          Center(
            child: Container(
              width: 176,
              height: 176,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.9),
                borderRadius: BorderRadius.circular(34),
                border: Border.all(color: _line),
              ),
              child: const Center(
                child: SkeletonBox(width: 116, height: 116, radius: 28),
              ),
            ),
          ),
          const Spacer(),
          const SkeletonBox(height: 88, radius: 28),
          const SizedBox(height: 46),
        ],
      ),
    );
  }
}

class _HomeManualSkeletonPage extends StatelessWidget {
  const _HomeManualSkeletonPage();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 136),
      child: Column(
        children: [
          const SkeletonPanel(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    SkeletonBox(width: 48, height: 48, radius: 16),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SkeletonLine(width: 112, height: 10),
                          SizedBox(height: 10),
                          SkeletonLine(width: 164, height: 20),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 18),
                SkeletonLine(width: double.infinity),
                SizedBox(height: 8),
                SkeletonLine(width: 260),
                SizedBox(height: 22),
                SkeletonBox(height: 58, radius: 18),
                SizedBox(height: 14),
                SkeletonBox(height: 58, radius: 18),
                SizedBox(height: 14),
                SkeletonBox(height: 58, radius: 18),
              ],
            ),
          ),
          const SizedBox(height: 18),
          const Align(
            alignment: Alignment.centerLeft,
            child: SkeletonLine(width: 188, height: 11),
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 164,
            child: ListView.separated(
              physics: const NeverScrollableScrollPhysics(),
              scrollDirection: Axis.horizontal,
              itemCount: 2,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (_, __) => const SkeletonBox(
                width: 244,
                height: 164,
                radius: 26,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
