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
              label: 'Aksiyonlar',
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
    final actions = _isParking ? _parkingActions : _facilityActions;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: _isParking ? 1.55 : 1.75,
      ),
      itemCount: actions.length,
      itemBuilder: (context, index) {
        final action = actions[index];
        return _ActionCard(
          icon: action.icon,
          title: action.title,
          enabled: action.enabled,
          onTap: action.onTap,
          highlight: action.highlight,
        );
      },
    );
  }

  List<_ActionData> get _parkingActions => [
        _ActionData(
          icon: Icons.near_me_rounded,
          title: 'Bana en yakın',
          enabled: true,
          onTap: onNearestToUser,
          highlight: true,
        ),
        _ActionData(
          icon: Icons.local_hospital_outlined,
          title: 'Hastane girişine yakın',
          enabled: true,
          onTap: onNearestToHospital,
        ),
        _ActionData(
          icon: Icons.directions_car_outlined,
          title: 'Aracıma git',
          enabled: hasParkedCar,
          onTap: onNavigateToCar,
        ),
        _ActionData(
          icon: Icons.logout_rounded,
          title: 'Otopark çıkışına git',
          enabled: true,
          onTap: onNavigateToExit,
        ),
      ];

  List<_ActionData> get _facilityActions {
    return [
      _ActionData(
        icon: _facilityIcon,
        title: destinationTitle,
        enabled: hasDestinations,
        onTap: hasDestinations ? onShowDestinations : null,
        highlight: true,
      ),
      _ActionData(
        icon: Icons.logout_rounded,
        title: 'Bina çıkışına git',
        enabled: true,
        onTap: onNavigateToExit,
      ),
    ];
  }

  IconData get _facilityIcon {
    return switch (mode) {
      MapPanelMode.hospital => Icons.local_hospital_rounded,
      MapPanelMode.mall => Icons.storefront_rounded,
      MapPanelMode.other => Icons.place_rounded,
      MapPanelMode.parking => Icons.local_parking_rounded,
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
    this.highlight = false,
  });

  final IconData icon;
  final String title;
  final bool enabled;
  final VoidCallback? onTap;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    final bgColor = highlight && enabled
        ? const Color(0xFFEEF2FF)
        : const Color(0xFFF8FAFC);
    final borderColor = highlight && enabled
        ? const Color(0xFFCBD5FF)
        : enabled
            ? const Color(0xFFE2E8F0)
            : const Color(0xFFE8EDF5);

    return InkWell(
      onTap: enabled ? onTap : null,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: borderColor),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color:
                    enabled ? const Color(0xFFFFFFFF) : const Color(0xFFF1F5F9),
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
                  fontWeight: FontWeight.w800,
                  fontSize: 14.5,
                  height: 1.15,
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

class _ActionData {
  const _ActionData({
    required this.icon,
    required this.title,
    required this.enabled,
    required this.onTap,
    this.highlight = false,
  });

  final IconData icon;
  final String title;
  final bool enabled;
  final VoidCallback? onTap;
  final bool highlight;
}
