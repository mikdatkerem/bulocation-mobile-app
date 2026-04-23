part of '../park_bottom_sheet.dart';

class _ModeSwitcher extends StatelessWidget {
  const _ModeSwitcher({
    required this.showDestinations,
    required this.destinationLabel,
    required this.hasDestinations,
    required this.onNavigationTap,
    required this.onDestinationsTap,
  });

  final bool showDestinations;
  final String destinationLabel;
  final bool hasDestinations;
  final VoidCallback onNavigationTap;
  final VoidCallback onDestinationsTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(
            child: _ModeButton(
              active: !showDestinations,
              label: 'Navigasyon',
              onTap: onNavigationTap,
            ),
          ),
          if (hasDestinations)
            Expanded(
              child: _ModeButton(
                active: showDestinations,
                label: destinationLabel,
                onTap: onDestinationsTap,
              ),
            ),
        ],
      ),
    );
  }
}

class _NavigationActions extends StatelessWidget {
  const _NavigationActions({
    required this.mode,
    required this.hasParkedCar,
    required this.hasDestinations,
    required this.destinationTitle,
    required this.onShowDestinations,
    required this.onNearestToUser,
    required this.onNearestToHospital,
    required this.onNavigateToCar,
    required this.onNavigateToExit,
  });

  final MapPanelMode mode;
  final bool hasParkedCar;
  final bool hasDestinations;
  final String destinationTitle;
  final VoidCallback onShowDestinations;
  final VoidCallback onNearestToUser;
  final VoidCallback onNearestToHospital;
  final VoidCallback? onNavigateToCar;
  final VoidCallback onNavigateToExit;

  bool get _isParking => mode == MapPanelMode.parking;

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.52,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        if (_isParking)
          _ActionCard(
            icon: Icons.near_me_rounded,
            title: 'Bana En\nYakın',
            enabled: true,
            onTap: onNearestToUser,
          ),
        if (_isParking)
          _ActionCard(
            icon: Icons.local_hospital_outlined,
            title: 'Hastane\nGirişi',
            enabled: true,
            onTap: onNearestToHospital,
          ),
        if (_isParking)
          _ActionCard(
            icon: Icons.directions_car_outlined,
            title: 'Aracıma\nGit',
            enabled: hasParkedCar,
            onTap: onNavigateToCar,
          ),
        if (!_isParking)
          _ActionCard(
            icon: _iconForMode(mode),
            title: destinationTitle,
            enabled: hasDestinations,
            onTap: hasDestinations ? onShowDestinations : null,
          ),
        _ActionCard(
          icon: Icons.logout_rounded,
          title: 'Çıkışa Git',
          enabled: true,
          onTap: onNavigateToExit,
        ),
      ],
    );
  }

  IconData _iconForMode(MapPanelMode mode) {
    return switch (mode) {
      MapPanelMode.parking => Icons.local_parking_rounded,
      MapPanelMode.hospital => Icons.local_hospital_rounded,
      MapPanelMode.mall => Icons.store_mall_directory_rounded,
      MapPanelMode.other => Icons.place_rounded,
    };
  }
}

class _ModeButton extends StatelessWidget {
  const _ModeButton({
    required this.active,
    required this.label,
    required this.onTap,
  });

  final bool active;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        height: 42,
        decoration: BoxDecoration(
          color: active ? const Color(0xFFFFFFFF) : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            color: active ? const Color(0xFF0F172A) : const Color(0xFF64748B),
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  const _ActionCard({
    required this.icon,
    required this.title,
    required this.enabled,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final bool enabled;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: enabled ? onTap : null,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: enabled ? const Color(0xFFF1F5F9) : const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: const Color(0xFFFFFFFF),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color:
                    enabled ? const Color(0xFF6366F1) : const Color(0xFF94A3B8),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: enabled
                      ? const Color(0xFF0F172A)
                      : const Color(0xFF94A3B8),
                  fontWeight: FontWeight.w700,
                  height: 1.2,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GhostAction extends StatelessWidget {
  const _GhostAction({
    required this.label,
    required this.onTap,
  });

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        height: 42,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFCBD5E1)),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: const TextStyle(
            color: Color(0xFF334155),
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}
