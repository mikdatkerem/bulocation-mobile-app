import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../models/auth_models.dart';

class StoredSession {
  const StoredSession({
    required this.accessToken,
    required this.refreshToken,
    required this.profile,
  });

  final String? accessToken;
  final String? refreshToken;
  final UserProfile? profile;
}

class SessionStorage {
  SessionStorage({FlutterSecureStorage? secureStorage})
      : _secureStorage = secureStorage ??
            const FlutterSecureStorage(
              aOptions: AndroidOptions(
                encryptedSharedPreferences: true,
              ),
              iOptions: IOSOptions(
                accessibility: KeychainAccessibility.first_unlock_this_device,
              ),
            );

  static const _accessTokenKey = 'auth.accessToken';
  static const _refreshTokenKey = 'auth.refreshToken';
  static const _profileKey = 'auth.profile';

  final FlutterSecureStorage _secureStorage;

  Future<StoredSession> read() async {
    final accessToken = await _secureStorage.read(key: _accessTokenKey);
    final refreshToken = await _secureStorage.read(key: _refreshTokenKey);
    final profileRaw = await _secureStorage.read(key: _profileKey);
    final profile = profileRaw == null || profileRaw.isEmpty
        ? null
        : UserProfile.fromJson(jsonDecode(profileRaw) as Map<String, dynamic>);

    return StoredSession(
      accessToken: accessToken,
      refreshToken: refreshToken,
      profile: profile,
    );
  }

  Future<void> writeSession(AuthSession session) async {
    await _secureStorage.write(
      key: _accessTokenKey,
      value: session.accessToken,
    );
    await _secureStorage.write(
      key: _refreshTokenKey,
      value: session.refreshToken,
    );
    await _secureStorage.write(
      key: _profileKey,
      value: jsonEncode(session.profile.toJson()),
    );
  }

  Future<void> writeProfile(UserProfile profile) async {
    await _secureStorage.write(
      key: _profileKey,
      value: jsonEncode(profile.toJson()),
    );
  }

  Future<void> writeTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    await _secureStorage.write(key: _accessTokenKey, value: accessToken);
    await _secureStorage.write(key: _refreshTokenKey, value: refreshToken);
  }

  Future<void> clear() async {
    await _secureStorage.delete(key: _accessTokenKey);
    await _secureStorage.delete(key: _refreshTokenKey);
    await _secureStorage.delete(key: _profileKey);
  }
}
