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
      }, options: Options(extra: const {'skipAuthRefresh': true}));

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
      }, options: Options(extra: const {'skipAuthRefresh': true}));

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
        options: Options(extra: const {'skipAuthRefresh': true}),
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
        options: Options(extra: const {'skipAuthRefresh': true}),
      );
    } on DioException {
      // Local session kapanışı için burada sessiz geçiyoruz.
    } finally {
      ApiClient.clearAccessToken();
    }
  }

  Future<AuthSession> refreshSession(String refreshToken) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '/auth/refresh-token',
        data: {'refreshToken': refreshToken},
        options: Options(extra: const {'skipAuthRefresh': true}),
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
        options: Options(extra: const {'skipAuthRefresh': true}),
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
        options: Options(extra: const {'skipAuthRefresh': true}),
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
        options: Options(extra: const {'skipAuthRefresh': true}),
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
        options: Options(extra: const {'skipAuthRefresh': true}),
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
        return 'E-posta veya kullanıcı adı ya da şifre hatalı.';
      case 'auth.account_locked':
        return 'Hesap gecici olarak kilitlendi. Bir sure sonra tekrar deneyin.';
      case 'auth.account_inactive':
        return 'Hesabınız aktif değil. Yönetici ile iletişime geçin.';
      case 'validation_failed':
        return _firstValidationMessage(error) ?? 'Form alanlarını kontrol edin.';
    }

    return _problemDetail(error) ?? 'Giriş sırasında bir hata oluştu.';
  }

  String _mapProfileMessage(DioException error) {
    return _problemDetail(error) ?? 'Kullanıcı profili yüklenemedi.';
  }

  String _mapRegisterMessage(DioException error) {
    switch (_problemCode(error)) {
      case 'conflict.email_in_use':
        return 'Bu e-posta adresi zaten kullanılıyor.';
      case 'conflict.username_in_use':
        return 'Bu kullanıcı adı zaten kullanılıyor.';
      case 'validation_failed':
        return _firstValidationMessage(error) ?? 'Kayıt alanlarını kontrol edin.';
    }

    return _problemDetail(error) ??
        _statusMessage(error, 'Kayıt oluşturulurken bir hata oluştu.');
  }

  String _mapGoogleMessage(DioException error) {
    switch (_problemCode(error)) {
      case 'auth.google_not_configured':
        return 'Google ile giriş bu ortamda aktif değil.';
      case 'auth.invalid_credentials':
        return 'Google hesabı doğrulanamadı.';
      case 'auth.account_inactive':
        return 'Hesabınız aktif değil. Yönetici ile iletişime geçin.';
      default:
        return _problemDetail(error) ??
            'Google ile giriş yapılırken bir hata oluştu.';
    }
  }

  String _mapRefreshMessage(DioException error) {
    switch (_problemCode(error)) {
      case 'invalid_token':
        return 'Oturumunuzun süresi doldu. Lütfen yeniden giriş yapın.';
      case 'auth.account_inactive':
        return 'Hesabınız aktif değil. Yönetici ile iletişime geçin.';
      default:
        return _problemDetail(error) ?? 'Oturum yenilenemedi.';
    }
  }

  String _mapForgotPasswordMessage(DioException error) {
    if (_problemCode(error) == 'validation_failed') {
      return _firstValidationMessage(error) ?? 'Geçerli bir e-posta adresi girin.';
    }

    return _problemDetail(error) ??
        'Şifre sıfırlama talebi gönderilemedi.';
  }

  String _mapResetPasswordMessage(DioException error) {
    switch (_problemCode(error)) {
      case 'invalid_token':
        return 'Şifre sıfırlama kodu geçersiz veya süresi dolmuş.';
      case 'validation_failed':
        return _firstValidationMessage(error) ?? 'Yeni şifre alanlarını kontrol edin.';
      default:
        return _problemDetail(error) ?? 'Şifre güncellenemedi.';
    }
  }

  String _mapResendVerificationMessage(DioException error) {
    if (_problemCode(error) == 'validation_failed') {
      return _firstValidationMessage(error) ?? 'Geçerli bir e-posta adresi girin.';
    }

    return _problemDetail(error) ??
        'Doğrulama e-postası yeniden gönderilemedi.';
  }

  String _mapVerifyEmailMessage(DioException error) {
    switch (_problemCode(error)) {
      case 'invalid_token':
        return 'Doğrulama kodu geçersiz veya süresi dolmuş.';
      case 'validation_failed':
        return _firstValidationMessage(error) ?? 'Doğrulama kodunu kontrol edin.';
      default:
        return _problemDetail(error) ?? 'E-posta doğrulanamadı.';
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

    final detail = body['detail']?.toString() ?? body['title']?.toString();
    if (detail == null || _looksTechnical(detail)) {
      return null;
    }

    return detail;
  }

  String _statusMessage(DioException error, String fallback) {
    return switch (error.response?.statusCode) {
      400 => 'Bilgileri kontrol edip tekrar deneyin.',
      403 => 'Bu işlem için gerekli izin sağlanamadı.',
      409 => 'Bu bilgilerle oluşturulmuş bir hesap zaten var.',
      _ => fallback,
    };
  }

  bool _looksTechnical(String message) {
    final normalized = message.toLowerCase();
    return normalized.contains('dioexception') ||
        normalized.contains('requestoptions') ||
        normalized.contains('validatestatus') ||
        normalized.contains('stacktrace');
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

    for (final entry in errors.entries) {
      final messages = entry.value;
      if (messages.isNotEmpty) {
        return _friendlyValidationMessage(entry.key, messages.first);
      }
    }

    return null;
  }

  String _friendlyValidationMessage(String field, String message) {
    final normalizedField = field.toLowerCase();
    final normalizedMessage = message.toLowerCase();

    if (normalizedField.contains('password')) {
      if (normalizedMessage.contains('empty')) {
        return 'Şifre alanı boş bırakılamaz.';
      }
      return 'Şifreniz en az 8 karakter olmalı; büyük harf, küçük harf ve rakam içermeli.';
    }

    if (normalizedField.contains('email')) {
      return 'Geçerli bir e-posta adresi girin.';
    }

    if (normalizedField.contains('username')) {
      return 'Kullanıcı adını kontrol edin.';
    }

    return message;
  }
}
