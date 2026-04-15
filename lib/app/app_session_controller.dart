import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/api_client.dart';
import '../models/auth_models.dart';
import '../models/exceptions.dart';
import '../services/auth_service.dart';

class AppSessionController extends ChangeNotifier {
  static const _accessTokenKey = 'auth.accessToken';
  static const _refreshTokenKey = 'auth.refreshToken';
  static const _profileKey = 'auth.profile';

  final AuthService _authService = AuthService();

  SharedPreferences? _prefs;
  bool _restoring = true;
  bool _busy = false;
  String? _errorMessage;
  UserProfile? _profile;
  String? _accessToken;
  String? _refreshToken;

  bool get isRestoring => _restoring;
  bool get isBusy => _busy;
  bool get isAuthenticated => _accessToken?.isNotEmpty == true && _profile != null;
  String? get errorMessage => _errorMessage;
  UserProfile? get profile => _profile;

  void clearErrorMessage() {
    if (_errorMessage == null) {
      return;
    }

    _errorMessage = null;
    notifyListeners();
  }

  Future<void> restore() async {
    _prefs = await SharedPreferences.getInstance();
    _accessToken = _prefs!.getString(_accessTokenKey);
    _refreshToken = _prefs!.getString(_refreshTokenKey);
    final profileRaw = _prefs!.getString(_profileKey);

    if (profileRaw != null) {
      _profile = UserProfile.fromJson(jsonDecode(profileRaw) as Map<String, dynamic>);
    }

    if (_accessToken?.isNotEmpty == true) {
      ApiClient.setAccessToken(_accessToken);
    }

    if (_refreshToken?.isNotEmpty == true) {
      try {
        if (_accessToken?.isNotEmpty == true) {
          _profile = await _authService.getCurrentUser();
        } else {
          final refreshedSession = await _authService.refreshSession(_refreshToken!);
          _accessToken = refreshedSession.accessToken;
          _refreshToken = refreshedSession.refreshToken;
          _profile = refreshedSession.profile;
          await _prefs!.setString(_accessTokenKey, refreshedSession.accessToken);
          await _prefs!.setString(_refreshTokenKey, refreshedSession.refreshToken);
        }

        await _prefs!.setString(_profileKey, jsonEncode(_profile!.toJson()));
      } catch (_) {
        if (_refreshToken?.isNotEmpty == true) {
          try {
            final refreshedSession = await _authService.refreshSession(_refreshToken!);
            _accessToken = refreshedSession.accessToken;
            _refreshToken = refreshedSession.refreshToken;
            _profile = refreshedSession.profile;
            await _prefs!.setString(_accessTokenKey, refreshedSession.accessToken);
            await _prefs!.setString(_refreshTokenKey, refreshedSession.refreshToken);
            await _prefs!.setString(_profileKey, jsonEncode(_profile!.toJson()));
          } catch (_) {
            await clearSession(notify: false);
          }
        } else {
          await clearSession(notify: false);
        }
      }
    }

    _restoring = false;
    notifyListeners();
  }

  Future<bool> signIn({
    required String email,
    required String password,
  }) async {
    _busy = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final session = await _authService.login(email: email, password: password);
      _accessToken = session.accessToken;
      _refreshToken = session.refreshToken;
      _profile = session.profile;

      await _prefs?.setString(_accessTokenKey, session.accessToken);
      await _prefs?.setString(_refreshTokenKey, session.refreshToken);
      await _prefs?.setString(_profileKey, jsonEncode(session.profile.toJson()));

      _busy = false;
      notifyListeners();
      return true;
    } catch (error) {
      _busy = false;
      _errorMessage = error is ApiException
          ? error.message
          : error.toString().replaceFirst('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  Future<bool> signUp({
    required String userName,
    required String email,
    required String firstName,
    required String lastName,
    required String password,
  }) async {
    _busy = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final session = await _authService.register(
        userName: userName,
        email: email,
        firstName: firstName,
        lastName: lastName,
        password: password,
      );
      _accessToken = session.accessToken;
      _refreshToken = session.refreshToken;
      _profile = session.profile;

      await _prefs?.setString(_accessTokenKey, session.accessToken);
      await _prefs?.setString(_refreshTokenKey, session.refreshToken);
      await _prefs?.setString(_profileKey, jsonEncode(session.profile.toJson()));

      _busy = false;
      notifyListeners();
      return true;
    } catch (error) {
      _busy = false;
      _errorMessage = error is ApiException
          ? error.message
          : error.toString().replaceFirst('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  Future<void> signOut() async {
    final refreshToken = _refreshToken;
    if (refreshToken?.isNotEmpty == true) {
      await _authService.logout(refreshToken!);
    }
    await clearSession();
  }

  Future<void> clearSession({bool notify = true}) async {
    _accessToken = null;
    _refreshToken = null;
    _profile = null;
    _errorMessage = null;
    ApiClient.clearAccessToken();
    await _prefs?.remove(_accessTokenKey);
    await _prefs?.remove(_refreshTokenKey);
    await _prefs?.remove(_profileKey);
    if (notify) {
      notifyListeners();
    }
  }
}
