import 'package:flutter/material.dart';

import '../app/app_session_controller.dart';
import '../models/auth_models.dart';
import 'verify_email_screen.dart';

part 'profile/profile_hero_card.dart';
part 'profile/profile_menu_tile.dart';
part 'profile/profile_shared.dart';
part 'profile/profile_verification_card.dart';
part 'profile/profile_view_model.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key, required this.sessionController});

  final AppSessionController sessionController;

  @override
  Widget build(BuildContext context) {
    final viewModel = _ProfileViewModel.fromProfile(sessionController.profile);
    final profile = sessionController.profile;

    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FD),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 120),
          children: [
            const _ProfileHeader(),
            const SizedBox(height: 18),
            _ProfileHeroCard(viewModel: viewModel),
            if (profile != null && !profile.emailVerified) ...[
              const SizedBox(height: 16),
              _VerificationCard(
                onTap: () => _openVerification(context, profile.email),
              ),
            ],
            const SizedBox(height: 22),
            const _SectionLabel('Hesap bilgileri'),
            const SizedBox(height: 10),
            _ProfileMenuTile(
              icon: Icons.badge_outlined,
              title: 'Kullanıcı adı',
              subtitle: viewModel.userName,
            ),
            _ProfileMenuTile(
              icon: Icons.mail_outline_rounded,
              title: 'E-posta adresi',
              subtitle: viewModel.email,
            ),
            _ProfileMenuTile(
              icon: Icons.admin_panel_settings_outlined,
              title: 'Rol',
              subtitle: viewModel.roleSummary,
            ),
            _ProfileMenuTile(
              icon: Icons.verified_user_outlined,
              title: 'Hesap durumu',
              subtitle: viewModel.accountStatusLabel,
            ),
            const SizedBox(height: 20),
            const _SectionLabel('İşlemler'),
            const SizedBox(height: 10),
            if (profile != null && !profile.emailVerified)
              _ProfileMenuTile(
                icon: Icons.verified_outlined,
                title: 'E-posta doğrulama',
                subtitle: 'Doğrulama ekranını aç',
                onTap: () => _openVerification(context, profile.email),
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

  Future<void> _openVerification(BuildContext context, String email) async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => VerifyEmailScreen(
          sessionController: sessionController,
          email: email,
        ),
      ),
    );
  }
}
