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
    final roleLabels = profile?.roles.isNotEmpty == true
        ? profile!.roles.map(_normalizeRole).toList(growable: false)
        : const <String>['Kullanıcı'];

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 120),
          children: [
            const Text(
              'Profil',
              style: TextStyle(
                fontFamily: 'Manrope',
                fontSize: 28,
                fontWeight: FontWeight.w900,
                color: Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 18),
            _ProfileHeroCard(
              initials: _initials(fullName),
              fullName: fullName,
              email: profile?.email ?? '-',
              primaryRole: roleLabels.first,
              emailVerified: profile?.emailVerified == true,
              isActive: profile?.isActive != false,
            ),
            if (profile != null && !profile.emailVerified) ...[
              const SizedBox(height: 16),
              _VerificationCard(
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
            ],
            const SizedBox(height: 18),
            const _SectionLabel('Hesap'),
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
              subtitle: roleLabels.join(', '),
            ),
            _ProfileMenuTile(
              icon: Icons.verified_user_outlined,
              title: 'Hesap durumu',
              subtitle:
                  profile?.isActive == false ? 'Pasif hesap' : 'Aktif hesap',
            ),
            const SizedBox(height: 18),
            const _SectionLabel('İşlemler'),
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

class _ProfileHeroCard extends StatelessWidget {
  const _ProfileHeroCard({
    required this.initials,
    required this.fullName,
    required this.email,
    required this.primaryRole,
    required this.emailVerified,
    required this.isActive,
  });

  final String initials;
  final String fullName;
  final String email;
  final String primaryRole;
  final bool emailVerified;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFFFF),
        borderRadius: BorderRadius.circular(26),
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
                width: 76,
                height: 76,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  color: const Color(0xFFEEF2FF),
                ),
                alignment: Alignment.center,
                child: Text(
                  initials,
                  style: const TextStyle(
                    fontSize: 26,
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
                      email,
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
              _InfoChip(
                label: primaryRole,
                background: const Color(0xFFEEF2FF),
                foreground: const Color(0xFF4338CA),
              ),
              _InfoChip(
                label: emailVerified
                    ? 'E-posta doğrulandı'
                    : 'E-posta doğrulanmadı',
                background: emailVerified
                    ? const Color(0xFFECFDF5)
                    : const Color(0xFFFEF2F2),
                foreground: emailVerified
                    ? const Color(0xFF15803D)
                    : const Color(0xFFB91C1C),
              ),
              _InfoChip(
                label: isActive ? 'Aktif hesap' : 'Pasif hesap',
                background: isActive
                    ? const Color(0xFFE0F2FE)
                    : const Color(0xFFF8FAFC),
                foreground: isActive
                    ? const Color(0xFF0369A1)
                    : const Color(0xFF64748B),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _VerificationCard extends StatelessWidget {
  const _VerificationCard({required this.onTap});

  final Future<void> Function() onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
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
                  'Şifre sıfırlama ve güvenlik işlemleri için hesabınızı doğrulayın.',
                  style: TextStyle(
                    color: Color(0xFF92400E),
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: () async => onTap(),
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
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: const TextStyle(
        color: Color(0xFF64748B),
        fontSize: 12,
        fontWeight: FontWeight.w900,
        letterSpacing: 1.8,
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({
    required this.label,
    required this.background,
    required this.foreground,
  });

  final String label;
  final Color background;
  final Color foreground;

  @override
  Widget build(BuildContext context) {
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
