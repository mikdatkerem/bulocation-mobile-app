import 'dart:ui';

import 'package:flutter/material.dart';

import '../app/app_session_controller.dart';
import '../models/facility_models.dart';
import '../services/session_storage.dart';
import 'home_overview_screen.dart';
import 'home_guide_screen.dart';
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
  final SessionStorage _sessionStorage = SessionStorage();
  bool _guideReady = false;
  bool _showGuide = false;

  @override
  void initState() {
    super.initState();
    _loadGuideState();
  }

  Future<void> _loadGuideState() async {
    final seen = await _sessionStorage.isHomeGuideSeen();
    if (!mounted) {
      return;
    }
    setState(() {
      _guideReady = true;
      _showGuide = !seen;
    });
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      HomeOverviewScreen(
        onOpenMaps: _handleOpenMaps,
        onQuickScan: _handleQuickScan,
        onOpenProfile: () => setState(() => _currentIndex = 2),
        profile: widget.sessionController.profile,
      ),
      MapsScreen(
        key: _mapsKey,
        onBack: () => setState(() => _currentIndex = 0),
      ),
      ProfileScreen(sessionController: widget.sessionController),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: !_guideReady
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF6366F1)),
            )
          : _showGuide
              ? HomeGuideScreen(onComplete: _completeGuide)
              : IndexedStack(
                  index: _currentIndex,
                  children: pages,
                ),
      bottomNavigationBar: _currentIndex == 0 ||
              _currentIndex == 1 ||
              _showGuide ||
              !_guideReady
          ? null
          : ColoredBox(
              color: const Color(0xFFF8FAFC),
              child: SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(18, 0, 18, 14),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(28),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
                      child: Container(
                        height: 72,
                        decoration: BoxDecoration(
                          color:
                              const Color(0xFFFFFFFF).withValues(alpha: 0.76),
                          borderRadius: BorderRadius.circular(28),
                          border: Border.all(
                            color:
                                const Color(0xFFFFFFFF).withValues(alpha: 0.72),
                          ),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x140F172A),
                              blurRadius: 24,
                              offset: Offset(0, 14),
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
                              label: 'Harita',
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

  Future<void> _completeGuide() async {
    await _sessionStorage.markHomeGuideSeen();
    if (!mounted) {
      return;
    }
    setState(() => _showGuide = false);
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
    final color = selected ? const Color(0xFFFFFFFF) : const Color(0xFF64748B);

    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 10),
          decoration: BoxDecoration(
            color: selected
                ? const Color(0xFF6366F1).withValues(alpha: 0.96)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(20),
            border: selected
                ? Border.all(
                    color: const Color(0xFFFFFFFF).withValues(alpha: 0.42),
                  )
                : null,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                selected ? activeIcon : icon,
                color: color,
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
