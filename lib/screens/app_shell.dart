import 'package:flutter/material.dart';

import '../app/app_session_controller.dart';
import '../models/facility_models.dart';
import 'home_overview_screen.dart';
import 'home_screen.dart';
import 'profile_screen.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key, required this.sessionController});

  final AppSessionController sessionController;

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _currentIndex = 0;
  final GlobalKey<MapsScreenState> _mapsKey = GlobalKey<MapsScreenState>();

  @override
  Widget build(BuildContext context) {
    final pages = [
      HomeOverviewScreen(
        onOpenMaps: _handleOpenMaps,
        onQuickScan: _handleQuickScan,
        profile: widget.sessionController.profile,
      ),
      MapsScreen(
        key: _mapsKey,
        onBack: () => setState(() => _currentIndex = 0),
      ),
      ProfileScreen(sessionController: widget.sessionController),
    ];

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: pages,
      ),
      bottomNavigationBar: _currentIndex == 1
          ? null
          : SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(18, 0, 18, 14),
                child: Container(
                  height: 66,
                  decoration: BoxDecoration(
                    color: const Color(0xFF111418),
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(color: const Color(0x1AF5F3EF)),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x4D000000),
                        blurRadius: 18,
                        offset: Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      _NavItem(
                        icon: Icons.home_outlined,
                        activeIcon: Icons.home_rounded,
                        label: 'Ana Sayfa',
                        selected: _currentIndex == 0,
                        onTap: () => setState(() => _currentIndex = 0),
                      ),
                      _NavItem(
                        icon: Icons.map_outlined,
                        activeIcon: Icons.map_rounded,
                        label: 'Bul',
                        selected: _currentIndex == 1,
                        onTap: () => setState(() => _currentIndex = 1),
                      ),
                      _NavItem(
                        icon: Icons.person_outline_rounded,
                        activeIcon: Icons.person_rounded,
                        label: 'Profil',
                        selected: _currentIndex == 2,
                        onTap: () => setState(() => _currentIndex = 2),
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  Future<void> _handleQuickScan(String referenceId) async {
    setState(() => _currentIndex = 1);
    await Future<void>.delayed(const Duration(milliseconds: 80));
    await _mapsKey.currentState?.openByQrReference(referenceId);
  }

  Future<void> _handleOpenMaps(MapOpenRequest? request) async {
    setState(() => _currentIndex = 1);
    await Future<void>.delayed(const Duration(milliseconds: 80));
    if (request != null) {
      await _mapsKey.currentState?.openSelection(request);
    }
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = selected ? const Color(0xFFF5F3EF) : const Color(0xFF8F96A3);

    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          margin: const EdgeInsets.symmetric(horizontal: 5, vertical: 8),
          decoration: BoxDecoration(
            color: selected ? const Color(0xFF1836B9) : Colors.transparent,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                selected ? activeIcon : icon,
                color: selected ? const Color(0xFFF5F3EF) : color,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  color: color,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
