import 'package:flutter/material.dart';

import '../app/app_session_controller.dart';
import 'verify_email_screen.dart';

part 'profile/profile_header.dart';
part 'profile/profile_menu_tile.dart';
part 'profile/profile_stat.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key, required this.sessionController});

  final AppSessionController sessionController;

  @override
  Widget build(BuildContext context) {
    final profile = sessionController.profile;
    final fullName = profile?.fullName.isNotEmpty == true
        ? profile!.fullName
        : profile?.userName ?? 'Kullanici';

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Profil',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.notifications_none_rounded),
          ),
        ],
      ),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 120),
          children: [
            Center(
              child: Column(
                children: [
                  Stack(
                    children: [
                      Container(
                        width: 108,
                        height: 108,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: const Color(0xFFD8E0EF),
                          border: Border.all(color: Colors.white, width: 4),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          _initials(fullName),
                          style: const TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF233353),
                          ),
                        ),
                      ),
                      Positioned(
                        right: 2,
                        bottom: 2,
                        child: Container(
                          width: 34,
                          height: 34,
                          decoration: BoxDecoration(
                            color: const Color(0xFF2155D6),
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 3),
                          ),
                          child: const Icon(
                            Icons.edit_outlined,
                            color: Colors.white,
                            size: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  Text(
                    fullName,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF1A2236),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    profile?.email ?? 'profil@bulocation.dev',
                    style: const TextStyle(
                      fontSize: 16,
                      color: Color(0xFF687287),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),
            if (profile != null && !profile.emailVerified) ...[
              Container(
                margin: const EdgeInsets.only(bottom: 20),
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF8E8),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFF1DEAA)),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.mark_email_unread_outlined,
                      color: Color(0xFF9E6A00),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'E-posta dogrulama bekleniyor',
                            style: TextStyle(
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF5C4300),
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Sifirlama ve guvenlik akislari icin hesabini dogrula.',
                            style: TextStyle(color: Color(0xFF7A5E16)),
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
                      child: const Text('Dogrula'),
                    ),
                  ],
                ),
              ),
            ],
            const Row(
              children: [
                Expanded(
                  child: _ProfileStat(
                    icon: Icons.local_parking_rounded,
                    value: '42',
                    label: 'TOPLAM\nPARK',
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: _ProfileStat(
                    icon: Icons.schedule_rounded,
                    value: '12sa',
                    label: 'KAZANILAN\nZAMAN',
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: _ProfileStat(
                    icon: Icons.star_border_rounded,
                    value: 'P4',
                    label: 'FAVORI\nYER',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF2155D6),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Row(
                children: [
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Premium Uyelik',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            fontSize: 18,
                          ),
                        ),
                        SizedBox(height: 6),
                        Text(
                          'Yillik Plan - 12 Ay',
                          style: TextStyle(
                            color: Color(0xFFDCE6FF),
                            fontSize: 15,
                          ),
                        ),
                      ],
                    ),
                  ),
                  FilledButton(
                    onPressed: () {},
                    style: FilledButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: const Color(0xFF2155D6),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Text('Yonet'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const _ProfileMenuTile(
              icon: Icons.history_rounded,
              title: 'Gecmis Islemler',
            ),
            const _ProfileMenuTile(
              icon: Icons.credit_card_rounded,
              title: 'Odeme Yontemleri',
            ),
            const _ProfileMenuTile(
              icon: Icons.settings_outlined,
              title: 'Uygulama Ayarlari',
            ),
            const SizedBox(height: 10),
            _ProfileMenuTile(
              icon: Icons.logout_rounded,
              title: 'Cikis Yap',
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
    return parts.take(2).map((part) => part[0].toUpperCase()).join();
  }
}
