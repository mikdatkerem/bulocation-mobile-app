import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qr_location_app/models/exceptions.dart';
import 'package:qr_location_app/services/auth_service.dart';

void main() {
  group('AuthService', () {
    test('login returns session and loads current user profile', () async {
      final dio = _buildFakeDio(
        onRequest: (options) {
          if (options.path == '/auth/login') {
            expect(options.data['emailOrUserName'], 'user@example.com');
            expect(options.data['password'], 'Secret123!');
            expect(options.extra['skipAuthRefresh'], true);

            return Response<Map<String, dynamic>>(
              requestOptions: options,
              data: {
                'accessToken': 'access-token',
                'refreshToken': 'refresh-token',
              },
              statusCode: 200,
            );
          }

          if (options.path == '/auth/me') {
            return Response<Map<String, dynamic>>(
              requestOptions: options,
              data: {
                'id': 'user-1',
                'userName': 'mikdat',
                'email': 'user@example.com',
                'firstName': 'Mikdat',
                'lastName': 'Kerem',
                'fullName': 'Mikdat Kerem',
                'emailVerified': true,
                'isActive': true,
                'roles': ['User'],
              },
              statusCode: 200,
            );
          }

          throw StateError('Unexpected path: ${options.path}');
        },
      );

      final service = AuthService(dio: dio);
      final session = await service.login(
        email: '  user@example.com  ',
        password: 'Secret123!',
      );

      expect(session.accessToken, 'access-token');
      expect(session.refreshToken, 'refresh-token');
      expect(session.profile.email, 'user@example.com');
      expect(session.profile.fullName, 'Mikdat Kerem');
    });

    test('login maps invalid credentials to user-friendly api exception', () async {
      final dio = _buildFakeDio(
        onRequest: (options) {
          if (options.path == '/auth/login') {
            throw DioException(
              requestOptions: options,
              response: Response<Map<String, dynamic>>(
                requestOptions: options,
                statusCode: 401,
                data: {
                  'code': 'auth.invalid_credentials',
                  'detail': 'Raw backend detail',
                },
              ),
              type: DioExceptionType.badResponse,
            );
          }

          throw StateError('Unexpected path: ${options.path}');
        },
      );

      final service = AuthService(dio: dio);

      expect(
        () => service.login(email: 'user@example.com', password: 'wrong'),
        throwsA(
          isA<ApiException>()
              .having((error) => error.code, 'code', 'auth.invalid_credentials')
              .having(
                (error) => error.message,
                'message',
                'E-posta veya kullanıcı adı ya da şifre hatalı.',
              ),
        ),
      );
    });

    test('refresh maps invalid token to expired session message', () async {
      final dio = _buildFakeDio(
        onRequest: (options) {
          if (options.path == '/auth/refresh-token') {
            throw DioException(
              requestOptions: options,
              response: Response<Map<String, dynamic>>(
                requestOptions: options,
                statusCode: 401,
                data: {'code': 'invalid_token'},
              ),
              type: DioExceptionType.badResponse,
            );
          }

          throw StateError('Unexpected path: ${options.path}');
        },
      );

      final service = AuthService(dio: dio);

      expect(
        () => service.refreshSession('expired-refresh-token'),
        throwsA(
          isA<ApiException>().having(
            (error) => error.message,
            'message',
            'Oturumunuzun süresi doldu. Lütfen yeniden giriş yapın.',
          ),
        ),
      );
    });
  });
}

Dio _buildFakeDio({
  required FutureOr<Response<dynamic>> Function(RequestOptions options) onRequest,
}) {
  final dio = Dio();
  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) async {
        try {
          final response = await onRequest(options);
          handler.resolve(response);
        } on DioException catch (error) {
          handler.reject(error);
        } catch (error) {
          handler.reject(
            DioException(
              requestOptions: options,
              error: error,
              type: DioExceptionType.unknown,
            ),
          );
        }
      },
    ),
  );
  return dio;
}
