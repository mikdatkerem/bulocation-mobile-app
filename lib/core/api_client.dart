import 'package:dio/dio.dart';

import '../main.dart';

class ApiClient {
  ApiClient._();

  static final Dio _dio = _createDio();
  static String? _accessToken;
  static Future<String?>? _refreshFuture;
  static Future<String?> Function()? _refreshAccessToken;
  static Future<void> Function()? _onSessionExpired;

  static Dio get instance => _dio;
  static String? get accessToken => _accessToken;

  static void setAccessToken(String? accessToken) {
    _accessToken = accessToken;
  }

  static void clearAccessToken() {
    _accessToken = null;
  }

  static void configureAuthHandlers({
    Future<String?> Function()? onRefreshAccessToken,
    Future<void> Function()? onSessionExpired,
  }) {
    _refreshAccessToken = onRefreshAccessToken;
    _onSessionExpired = onSessionExpired;
  }

  static Map<String, String> buildHeaders({
    bool includeJsonContentType = true,
    bool includeAuth = true,
  }) {
    final headers = <String, String>{
      'Accept': 'application/json',
    };

    if (includeJsonContentType) {
      headers['Content-Type'] = 'application/json';
    }

    if (AppConfig.appSecret.isNotEmpty) {
      headers['x-app-secret'] = AppConfig.appSecret;
    }

    if (includeAuth && _accessToken?.isNotEmpty == true) {
      headers['Authorization'] = 'Bearer $_accessToken';
    }

    return headers;
  }

  static Dio _createDio() {
    final dio = Dio(
      BaseOptions(
        baseUrl: AppConfig.apiBaseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
      ),
    );

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          options.headers.addAll(buildHeaders());
          handler.next(options);
        },
        onError: (error, handler) async {
          final request = error.requestOptions;
          final shouldTryRefresh =
              error.response?.statusCode == 401 &&
              request.headers['Authorization'] != null &&
              request.extra['skipAuthRefresh'] != true &&
              request.extra['authRetry'] != true &&
              _refreshAccessToken != null;

          if (shouldTryRefresh) {
            final refreshedToken = await _refreshWithSingleFlight();
            if (refreshedToken?.isNotEmpty == true) {
              final retriedRequest = request.copyWith(
                headers: {
                  ...request.headers,
                  'Authorization': 'Bearer $refreshedToken',
                },
                extra: {
                  ...request.extra,
                  'authRetry': true,
                },
              );

              try {
                final response = await _dio.fetch<dynamic>(retriedRequest);
                handler.resolve(response);
                return;
              } on DioException catch (retryError) {
                error = retryError;
              }
            } else if (_onSessionExpired != null) {
              await _onSessionExpired!();
            }
          }

          if (error.response?.statusCode == 401) {
            error = error.copyWith(
              message: 'Oturumunuzun suresi doldu. Lutfen yeniden giris yapin.',
            );
          }
          handler.next(error);
        },
      ),
    );

    return dio;
  }

  static Future<String?> _refreshWithSingleFlight() async {
    final pendingRefresh = _refreshFuture;
    if (pendingRefresh != null) {
      return pendingRefresh;
    }

    final refreshHandler = _refreshAccessToken;
    if (refreshHandler == null) {
      return null;
    }

    final future = refreshHandler();
    _refreshFuture = future;

    try {
      return await future;
    } finally {
      if (identical(_refreshFuture, future)) {
        _refreshFuture = null;
      }
    }
  }
}
