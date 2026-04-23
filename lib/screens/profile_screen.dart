import 'package:flutter/material.dart';

import '../app/app_session_controller.dart';
import 'verify_email_screen.dart';

part 'profile/profile_menu_tile.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key, required this.sessionController});

  final AppSessionController sessionController;

  @override
  Widget build(BuildContext context) {
    final profile = sessionController.profile;
    final fullName = profile?.fullName.trim().isNotEmpty == true
        ? profile!.fullName
        : profile?.userName ?? 'Kullanıcı';
    final initials = _initials(fullName);
    final roleLabels = profile?.roles.isNotEmpty == true
        ? profile!.roles
        : const <String>['Kullanıcı'];

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 120),
          children: [
            Row(
              children: [
                const Text(
                  'Profil',
                  style: TextStyle(
                    fontFamily: 'Manrope',
                    fontSize: 26,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF0F172A),
                  ),
                ),
                const Spacer(),
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFFFFF),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: const Icon(
                    Icons.verified_user_outlined,
                    color: Color(0xFF6366F1),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 22),
            Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                color: const Color(0xFFFFFFFF),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: const Color(0xFFE2E8F0)),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x120F172A),
                    blurRadius: 24,
                    offset: Offset(0, 14),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 72,
                        height: 72,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(22),
                          color: const Color(0xFFEEF2FF),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          initials,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF4338CA),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              fullName,
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF0F172A),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              profile?.email ?? '-',
                              style: const TextStyle(
                                fontSize: 14,
                                color: Color(0xFF64748B),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final role in roleLabels)
                        _RoleChip(label: _normalizeRole(role)),
                      _StatusChip(
                        label: profile?.emailVerified == true
                            ? 'E-posta doğrulandı'
                            : 'E-posta doğrulanmadı',
                        positive: profile?.emailVerified == true,
                      ),
                      _StatusChip(
                        label: profile?.isActive == false
                            ? 'Pasif hesap'
                            : 'Aktif hesap',
                        positive: profile?.isActive != false,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            if (profile != null && !profile.emailVerified) ...[
              const SizedBox(height: 18),
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFFBEB),
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: const Color(0xFFFDE68A)),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.mark_email_unread_outlined,
                      color: Color(0xFFA16207),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'E-posta doğrulaması bekleniyor',
                            style: TextStyle(
                              color: Color(0xFF713F12),
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Şifre sıfırlama ve güvenlik akışları için hesabınızı doğrulayın.',
                            style: TextStyle(
                              color: Color(0xFF92400E),
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) => VerifyEmailScreen(
                              sessionController: sessionController,
                              email: profile.email,
                            ),
                          ),
                        );
                      },
                      style: TextButton.styleFrom(
                        foregroundColor: const Color(0xFFA16207),
                      ),
                      child: const Text(
                        'Doğrula',
                        style: TextStyle(fontWeight: FontWeight.w800),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 18),
            const Text(
              'Hesap',
              style: TextStyle(
                color: Color(0xFF64748B),
                fontSize: 12,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.8,
              ),
            ),
            const SizedBox(height: 10),
            _ProfileMenuTile(
              icon: Icons.badge_outlined,
              title: 'Kullanıcı adı',
              subtitle: profile?.userName ?? '-',
            ),
            _ProfileMenuTile(
              icon: Icons.mail_outline_rounded,
              title: 'E-posta adresi',
              subtitle: profile?.email ?? '-',
            ),
            _ProfileMenuTile(
              icon: Icons.admin_panel_settings_outlined,
              title: 'Rol bilgisi',
              subtitle: roleLabels.map(_normalizeRole).join(', '),
            ),
            const SizedBox(height: 18),
            const Text(
              'İşlemler',
              style: TextStyle(
                color: Color(0xFF64748B),
                fontSize: 12,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.8,
              ),
            ),
            const SizedBox(height: 10),
            if (profile != null && !profile.emailVerified)
              _ProfileMenuTile(
                icon: Icons.verified_outlined,
                title: 'E-posta doğrulama',
                subtitle: 'Doğrulama ekranını aç',
                onTap: () async {
                  await Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => VerifyEmailScreen(
                        sessionController: sessionController,
                        email: profile.email,
                      ),
                    ),
                  );
                },
              ),
            _ProfileMenuTile(
              icon: Icons.logout_rounded,
              title: 'Çıkış yap',
              subtitle: 'Bu cihazdaki oturumu kapat',
              destructive: true,
              onTap: sessionController.signOut,
            ),
          ],
        ),
      ),
    );
  }

  static String _initials(String name) {
    final parts =
        name.trim().split(RegExp(r'\s+')).where((part) => part.isNotEmpty);
    final initials = parts.take(2).map((part) => part[0].toUpperCase()).join();
    return initials.isEmpty ? 'BK' : initials;
  }

  static String _normalizeRole(String role) {
    return switch (role.toLowerCase()) {
      'superadmin' => 'Süper Admin',
      'organizationadmin' => 'Organizasyon Admini',
      'admin' => 'Admin',
      'viewer' => 'İzleyici',
      _ => 'Kullanıcı',
    };
  }
}

class _RoleChip extends StatelessWidget {
  const _RoleChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFEEF2FF),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Color(0xFF4338CA),
          fontWeight: FontWeight.w800,
          fontSize: 12,
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({
    required this.label,
    required this.positive,
  });

  final String label;
  final bool positive;

  @override
  Widget build(BuildContext context) {
    final background =
        positive ? const Color(0xFFECFDF5) : const Color(0xFFFEF2F2);
    final foreground =
        positive ? const Color(0xFF15803D) : const Color(0xFFB91C1C);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: foreground,
          fontWeight: FontWeight.w800,
          fontSize: 12,
        ),
      ),
    );
  }
}
