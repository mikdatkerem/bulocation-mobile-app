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
