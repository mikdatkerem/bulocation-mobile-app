import 'package:dio/dio.dart';

import '../core/api_client.dart';
import '../models/auth_models.dart';
import '../models/exceptions.dart';

class AuthService {
  AuthService({Dio? dio}) : _dio = dio ?? ApiClient.instance;

  final Dio _dio;

  Future<AuthSession> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>('/auth/login', data: {
        'emailOrUserName': email.trim(),
        'password': password,
      });

      return _toSession(response.data!);
    } on DioException catch (error) {
      throw _toApiException(
        error,
        overrideMessage: _mapLoginMessage(error),
      );
    }
  }

  Future<AuthSession> register({
    required String userName,
    required String email,
    required String firstName,
    required String lastName,
    required String password,
  }) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>('/auth/register', data: {
        'userName': userName.trim(),
        'email': email.trim(),
        'firstName': firstName.trim(),
        'lastName': lastName.trim(),
        'password': password,
      });

      return _toSession(response.data!);
    } on DioException catch (error) {
      throw _toApiException(
        error,
        overrideMessage: _mapRegisterMessage(error),
      );
    }
  }

  Future<AuthSession> loginWithGoogle(String idToken) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '/auth/google',
        data: {'idToken': idToken},
      );

      return _toSession(response.data!);
    } on DioException catch (error) {
      throw _toApiException(
        error,
        overrideMessage: _mapGoogleMessage(error),
      );
    }
  }

  Future<void> logout(String refreshToken) async {
    try {
      await _dio.post<void>(
        '/auth/logout',
        data: {'refreshToken': refreshToken},
      );
    } on DioException {
      // Local session kapanisi icin burada sessiz geciyoruz.
    } finally {
      ApiClient.clearAccessToken();
    }
  }

  Future<AuthSession> refreshSession(String refreshToken) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '/auth/refresh-token',
        data: {'refreshToken': refreshToken},
      );

      return _toSession(response.data!);
    } on DioException catch (error) {
      throw _toApiException(
        error,
        overrideMessage: _mapRefreshMessage(error),
      );
    }
  }

  Future<void> forgotPassword(String email) async {
    try {
      await _dio.post<void>(
        '/auth/forgot-password',
        data: {'email': email.trim()},
      );
    } on DioException catch (error) {
      throw _toApiException(
        error,
        overrideMessage: _mapForgotPasswordMessage(error),
      );
    }
  }

  Future<void> resetPassword({
    required String token,
    required String newPassword,
  }) async {
    try {
      await _dio.post<void>(
        '/auth/reset-password',
        data: {'token': token.trim(), 'newPassword': newPassword},
      );
    } on DioException catch (error) {
      throw _toApiException(
        error,
        overrideMessage: _mapResetPasswordMessage(error),
      );
    }
  }

  Future<void> resendEmailVerification(String email) async {
    try {
      await _dio.post<void>(
        '/auth/resend-email-verification',
        data: {'email': email.trim()},
      );
    } on DioException catch (error) {
      throw _toApiException(
        error,
        overrideMessage: _mapResendVerificationMessage(error),
      );
    }
  }

  Future<void> verifyEmail(String token) async {
    try {
      await _dio.post<void>(
        '/auth/verify-email',
        data: {'token': token.trim()},
      );
    } on DioException catch (error) {
      throw _toApiException(
        error,
        overrideMessage: _mapVerifyEmailMessage(error),
      );
    }
  }

  Future<UserProfile> getCurrentUser() async {
    try {
      final response = await _dio.get<Map<String, dynamic>>('/auth/me');
      return UserProfile.fromJson(response.data!);
    } on DioException catch (error) {
      throw _toApiException(
        error,
        overrideMessage: _mapProfileMessage(error),
      );
    }
  }

  Future<AuthSession> _toSession(Map<String, dynamic> body) async {
    final accessToken = body['accessToken'] as String;
    final refreshToken = body['refreshToken'] as String;

    ApiClient.setAccessToken(accessToken);
    final profile = await getCurrentUser();

    return AuthSession(
      accessToken: accessToken,
      refreshToken: refreshToken,
      profile: profile,
    );
  }

  String _mapLoginMessage(DioException error) {
    switch (_problemCode(error)) {
      case 'auth.invalid_credentials':
        return 'E-posta veya kullanici adi ya da sifre hatali.';
      case 'auth.account_locked':
        return 'Hesap gecici olarak kilitlendi. Bir sure sonra tekrar deneyin.';
      case 'auth.account_inactive':
        return 'Hesabiniz aktif degil. Yonetici ile iletisime gecin.';
      case 'validation_failed':
        return _firstValidationMessage(error) ?? 'Form alanlarini kontrol edin.';
    }

    final detail = _problemDetail(error);
    return detail ?? error.message ?? 'Giris sirasinda bir hata olustu.';
  }

  String _mapProfileMessage(DioException error) {
    return _problemDetail(error) ??
        error.message ??
        'Kullanici profili yuklenemedi.';
  }

  String _mapRegisterMessage(DioException error) {
    switch (_problemCode(error)) {
      case 'conflict.email_in_use':
        return 'Bu e-posta adresi zaten kullaniliyor.';
      case 'conflict.username_in_use':
        return 'Bu kullanici adi zaten kullaniliyor.';
      case 'validation_failed':
        return _firstValidationMessage(error) ?? 'Kayit alanlarini kontrol edin.';
    }

    return _problemDetail(error) ??
        error.message ??
        'Kayit olusturulurken bir hata olustu.';
  }

  String _mapGoogleMessage(DioException error) {
    switch (_problemCode(error)) {
      case 'auth.google_not_configured':
        return 'Google ile giris bu ortamda aktif degil.';
      case 'auth.invalid_credentials':
        return 'Google hesabi dogrulanamadi.';
      case 'auth.account_inactive':
        return 'Hesabiniz aktif degil. Yonetici ile iletisime gecin.';
      default:
        return _problemDetail(error) ??
            error.message ??
            'Google ile giris yapilirken bir hata olustu.';
    }
  }

  String _mapRefreshMessage(DioException error) {
    switch (_problemCode(error)) {
      case 'invalid_token':
        return 'Oturumunuzun suresi doldu. Lutfen yeniden giris yapin.';
      case 'auth.account_inactive':
        return 'Hesabiniz aktif degil. Yonetici ile iletisime gecin.';
      default:
        return _problemDetail(error) ??
            error.message ??
            'Oturum yenilenemedi.';
    }
  }

  String _mapForgotPasswordMessage(DioException error) {
    if (_problemCode(error) == 'validation_failed') {
      return _firstValidationMessage(error) ?? 'Gecerli bir e-posta adresi girin.';
    }

    return _problemDetail(error) ??
        error.message ??
        'Sifre sifirlama talebi gonderilemedi.';
  }

  String _mapResetPasswordMessage(DioException error) {
    switch (_problemCode(error)) {
      case 'invalid_token':
        return 'Sifre sifirlama kodu gecersiz veya suresi dolmus.';
      case 'validation_failed':
        return _firstValidationMessage(error) ?? 'Yeni sifre alanlarini kontrol edin.';
      default:
        return _problemDetail(error) ??
            error.message ??
            'Sifre guncellenemedi.';
    }
  }

  String _mapResendVerificationMessage(DioException error) {
    if (_problemCode(error) == 'validation_failed') {
      return _firstValidationMessage(error) ?? 'Gecerli bir e-posta adresi girin.';
    }

    return _problemDetail(error) ??
        error.message ??
        'Dogrulama e-postasi yeniden gonderilemedi.';
  }

  String _mapVerifyEmailMessage(DioException error) {
    switch (_problemCode(error)) {
      case 'invalid_token':
        return 'Dogrulama kodu gecersiz veya suresi dolmus.';
      case 'validation_failed':
        return _firstValidationMessage(error) ?? 'Dogrulama kodunu kontrol edin.';
      default:
        return _problemDetail(error) ??
            error.message ??
            'E-posta dogrulanamadi.';
    }
  }

  ApiException _toApiException(
    DioException error, {
    required String overrideMessage,
  }) {
    return ApiException(
      overrideMessage,
      statusCode: error.response?.statusCode,
      code: _problemCode(error),
      errors: _problemErrors(error),
    );
  }

  String? _problemDetail(DioException error) {
    final body = error.response?.data;
    if (body is! Map<String, dynamic>) {
      return null;
    }

    return body['detail']?.toString() ?? body['title']?.toString();
  }

  String? _problemCode(DioException error) {
    final body = error.response?.data;
    if (body is! Map<String, dynamic>) {
      return null;
    }

    return body['code']?.toString();
  }

  Map<String, List<String>>? _problemErrors(DioException error) {
    final body = error.response?.data;
    if (body is! Map<String, dynamic>) {
      return null;
    }

    final rawErrors = body['errors'];
    if (rawErrors is! Map) {
      return null;
    }

    return rawErrors.map((key, value) {
      final messages = value is List
          ? value.map((item) => item.toString()).toList()
          : <String>[value.toString()];
      return MapEntry(key.toString(), messages);
    });
  }

  String? _firstValidationMessage(DioException error) {
    final errors = _problemErrors(error);
    if (errors == null || errors.isEmpty) {
      return null;
    }

    for (final messages in errors.values) {
      if (messages.isNotEmpty) {
        return messages.first;
      }
    }

    return null;
  }
}
