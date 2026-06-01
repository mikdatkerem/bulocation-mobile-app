import 'package:dio/dio.dart';

import '../core/api_client.dart';
import '../models/exceptions.dart';
import '../models/facility_models.dart';

class FacilityService {
  FacilityService({Dio? dio}) : _dio = dio ?? ApiClient.instance;

  final Dio _dio;

  Future<List<OrganizationSummary>> getOrganizations() async {
    try {
      final response =
          await _dio.get<List<dynamic>>('/client/facilities/organizations');
      return response.data!
          .map(
            (item) =>
                OrganizationSummary.fromJson(item as Map<String, dynamic>),
          )
          .toList();
    } on DioException catch (error) {
      throw ApiException(
        _extractMessage(
          error,
          'Kurum listesi alınamadı. Bağlantınızı kontrol edip tekrar deneyin.',
        ),
      );
    }
  }

  Future<OrganizationHierarchy> getOrganizationHierarchy(
    String organizationId,
  ) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '/client/facilities/organizations/$organizationId',
      );
      return OrganizationHierarchy.fromJson(response.data!);
    } on DioException catch (error) {
      throw ApiException(
        _extractMessage(
          error,
          'Kurum detayları yüklenemedi. Kurumu tekrar seçmeyi deneyin.',
        ),
      );
    }
  }

  Future<PublishedMapData> getPublishedMap(String floorId) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '/client/facilities/floors/$floorId/published-map',
      );
      return PublishedMapData.fromJson(response.data!);
    } on DioException catch (error) {
      throw ApiException(
        _extractMessage(
          error,
          'Bu katın yayındaki haritası açılamadı. Farklı bir kat seçin veya QR kodu tekrar okutun.',
        ),
      );
    }
  }

  Future<QrScanContext> resolveQrScanContext(String referenceId) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '/client/facilities/scan-context/$referenceId',
      );
      return QrScanContext.fromJson(response.data!);
    } on DioException catch (error) {
      throw ApiException(
        _extractMessage(
          error,
          'Bu QR kodu okunamadı. Kodun doğru kurum ve kata ait olduğundan emin olup tekrar deneyin.',
        ),
      );
    }
  }

  Future<List<FacilityDestinationSearchResult>> searchBuildingDestinations(
    String buildingId, {
    String? query,
    int limit = 50,
  }) async {
    try {
      final qp = <String, dynamic>{
        'limit': limit,
        if (query != null && query.trim().isNotEmpty) 'query': query.trim(),
      };
      final response = await _dio.get<List<dynamic>>(
        '/client/facilities/buildings/$buildingId/destinations/search',
        queryParameters: qp,
      );
      return response.data!
          .map(
            (item) => FacilityDestinationSearchResult.fromJson(
              item as Map<String, dynamic>,
            ),
          )
          .toList();
    } on DioException catch (error) {
      throw ApiException(
        _extractMessage(
          error,
          'Bu bina için hedef listesi alınamadı. Haritayı açıp giriş ve çıkış noktalarını kullanabilirsiniz.',
        ),
      );
    }
  }

  String _extractMessage(DioException error, String fallback) {
    final statusCode = error.response?.statusCode;
    if (statusCode == 401) {
      return 'Oturumunuzun süresi doldu. Lütfen tekrar giriş yapın.';
    }
    if (statusCode == 403) {
      return 'Bu haritaya erişim izniniz bulunmuyor.';
    }
    if (statusCode == 404) {
      return fallback;
    }

    final body = error.response?.data;
    final detail =
        body is Map<String, dynamic> ? body['detail']?.toString() : null;
    final sanitizedDetail = _sanitizeBackendMessage(detail);
    if (sanitizedDetail != null) {
      return sanitizedDetail;
    }

    return fallback;
  }

  String? _sanitizeBackendMessage(String? message) {
    final value = message?.trim();
    if (value == null || value.isEmpty) {
      return null;
    }

    final lower = value.toLowerCase();
    final looksTechnical = lower.contains('exception') ||
        lower.contains('stack') ||
        lower.contains('http') ||
        lower.contains('sql') ||
        lower.contains('trace') ||
        lower.contains('system.');

    return looksTechnical ? null : value;
  }
}
