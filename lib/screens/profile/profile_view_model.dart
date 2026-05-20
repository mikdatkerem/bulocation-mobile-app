part of '../profile_screen.dart';

class _ProfileViewModel {
  const _ProfileViewModel({
    required this.initials,
    required this.fullName,
    required this.userName,
    required this.email,
    required this.roles,
    required this.emailVerified,
    required this.isActive,
  });

  final String initials;
  final String fullName;
  final String userName;
  final String email;
  final List<String> roles;
  final bool emailVerified;
  final bool isActive;

  String get primaryRole => roles.first;

  String get roleSummary => roles.join(', ');

  String get accountStatusLabel => isActive ? 'Aktif hesap' : 'Pasif hesap';

  static _ProfileViewModel fromProfile(UserProfile? profile) {
    final fullName = profile?.fullName.trim().isNotEmpty == true
        ? profile!.fullName.trim()
        : profile?.userName.trim().isNotEmpty == true
            ? profile!.userName.trim()
            : 'Kullanıcı';

    final userName = profile?.userName.trim().isNotEmpty == true
        ? profile!.userName.trim()
        : '-';

    final email =
        profile?.email.trim().isNotEmpty == true ? profile!.email.trim() : '-';

    final roles = profile?.roles.isNotEmpty == true
        ? profile!.roles.map(_normalizeRole).toList(growable: false)
        : const <String>['Kullanıcı'];

    return _ProfileViewModel(
      initials: _initials(fullName),
      fullName: fullName,
      userName: userName,
      email: email,
      roles: roles,
      emailVerified: profile?.emailVerified == true,
      isActive: profile?.isActive != false,
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
