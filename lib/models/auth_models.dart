class UserProfile {
  const UserProfile({
    required this.id,
    required this.userName,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.fullName,
    required this.emailVerified,
    required this.isActive,
    required this.roles,
  });

  final String id;
  final String userName;
  final String email;
  final String firstName;
  final String lastName;
  final String fullName;
  final bool emailVerified;
  final bool isActive;
  final List<String> roles;

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] as String,
      userName: json['userName'] as String,
      email: json['email'] as String,
      firstName: json['firstName'] as String? ?? '',
      lastName: json['lastName'] as String? ?? '',
      fullName: json['fullName'] as String? ??
          '${json['firstName'] ?? ''} ${json['lastName'] ?? ''}'.trim(),
      emailVerified: json['emailVerified'] as bool? ?? false,
      isActive: json['isActive'] as bool? ?? true,
      roles: ((json['roles'] as List<dynamic>?) ?? const <dynamic>[])
          .map((item) => item.toString())
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userName': userName,
      'email': email,
      'firstName': firstName,
      'lastName': lastName,
      'fullName': fullName,
      'emailVerified': emailVerified,
      'isActive': isActive,
      'roles': roles,
    };
  }
}

class AuthSession {
  const AuthSession({
    required this.accessToken,
    required this.refreshToken,
    required this.profile,
  });

  final String accessToken;
  final String refreshToken;
  final UserProfile profile;
}
