part of '../home_overview_screen.dart';

class _QuickLocationTile extends StatelessWidget {
  const _QuickLocationTile({
    required this.item,
    required this.onTap,
  });

  final _QuickLocationData item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return _SurfaceTile(
      icon: Icons.map_outlined,
      title: item.buildingName,
      subtitle: '${item.siteName} - ${item.floorName}',
      meta: 'Haritayı aç',
      caption: item.organizationName,
      onTap: onTap,
    );
  }
}

class _SiteListTile extends StatelessWidget {
  const _SiteListTile({
    required this.item,
    required this.onTap,
  });

  final _SiteListItemData item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return _SurfaceTile(
      icon: Icons.location_city_rounded,
      title: item.siteName,
      subtitle:
          '${item.organizationName} - ${item.buildingCount} bina - ${item.readyFloorCount} hazır kat',
      meta: 'Yerleşkeyi aç',
      onTap: onTap,
    );
  }
}

class _SurfaceTile extends StatelessWidget {
  const _SurfaceTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.meta,
    this.caption,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final String meta;
  final String? caption;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Ink(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: _card,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0x12000000)),
          boxShadow: const [
            BoxShadow(
              color: Color(0x18000000),
              blurRadius: 18,
              offset: Offset(0, 10),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: const Color(0xFFE8ECF6),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: _accent),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (caption != null) ...[
                    Text(
                      caption!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: _accent,
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.6,
                      ),
                    ),
                    const SizedBox(height: 6),
                  ],
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: _ink,
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: _cardMuted,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  meta.toUpperCase(),
                  style: const TextStyle(
                    color: _accent,
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.1,
                  ),
                ),
                const SizedBox(height: 8),
                const Icon(Icons.chevron_right_rounded, color: _cardMuted),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyBlock extends StatelessWidget {
  const _EmptyBlock({
    required this.title,
    required this.subtitle,
  });

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0x12000000)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: _ink,
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: const TextStyle(
              color: _cardMuted,
              height: 1.55,
            ),
          ),
        ],
      ),
    );
  }
}

class _OverviewError extends StatelessWidget {
  const _OverviewError({
    required this.message,
    required this.onRetry,
  });

  final String message;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline_rounded, size: 34, color: _soft),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: _soft),
            ),
            const SizedBox(height: 18),
            FilledButton(
              onPressed: onRetry,
              style: FilledButton.styleFrom(
                backgroundColor: _accent,
                foregroundColor: _text,
              ),
              child: const Text('Tekrar dene'),
            ),
          ],
        ),
      ),
    );
  }
}
