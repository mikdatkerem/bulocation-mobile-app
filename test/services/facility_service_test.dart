import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qr_location_app/models/exceptions.dart';
import 'package:qr_location_app/services/facility_service.dart';

void main() {
  group('FacilityService', () {
    test('getOrganizations parses organization list', () async {
      final dio = _buildFakeDio(
        onRequest: (options) {
          if (options.path == '/client/facilities/organizations') {
            return Response<List<dynamic>>(
              requestOptions: options,
              data: const [
                {
                  'id': 'org-1',
                  'code': 'KALKAN',
                  'name': 'Kalkan Hastaneleri',
                },
              ],
              statusCode: 200,
            );
          }

          throw StateError('Unexpected path: ${options.path}');
        },
      );

      final service = FacilityService(dio: dio);
      final organizations = await service.getOrganizations();

      expect(organizations, hasLength(1));
      expect(organizations.first.id, 'org-1');
      expect(organizations.first.name, 'Kalkan Hastaneleri');
    });

    test('getPublishedMap parses normalized map nodes', () async {
      final dio = _buildFakeDio(
        onRequest: (options) {
          if (options.path == '/client/facilities/floors/floor-1/published-map') {
            return Response<Map<String, dynamic>>(
              requestOptions: options,
              data: {
                'id': 'map-1',
                'floorId': 'floor-1',
                'name': 'Zemin Kat',
                'assetPath': '/storage/maps/floor-1.svg',
                'assetContentType': 'image/svg+xml',
                'width': 1920,
                'height': 1080,
                'nodes': [
                  {
                    'id': 'node-1',
                    'code': 'P1',
                    'label': 'P1 / Park',
                    'pixelX': 960,
                    'pixelY': 540,
                    'normalizedX': 0.5,
                    'normalizedY': 0.5,
                    'nodeType': 8,
                    'externalReferenceId': 'P1',
                  },
                ],
                'connections': const [],
              },
              statusCode: 200,
            );
          }

          throw StateError('Unexpected path: ${options.path}');
        },
      );

      final service = FacilityService(dio: dio);
      final map = await service.getPublishedMap('floor-1');

      expect(map.name, 'Zemin Kat');
      expect(map.nodes, hasLength(1));
      expect(map.nodes.first.id, 'P1');
      expect(map.nodes.first.resolveX(1920), 960);
      expect(map.nodes.first.resolveY(1080), 540);
    });

    test('searchBuildingDestinations surfaces backend detail when present', () async {
      final dio = _buildFakeDio(
        onRequest: (options) {
          if (options.path == '/client/facilities/buildings/building-1/destinations/search') {
            throw DioException(
              requestOptions: options,
              response: Response<Map<String, dynamic>>(
                requestOptions: options,
                statusCode: 500,
                data: {'detail': 'Hedef servisi geçici olarak kullanılamıyor.'},
              ),
              type: DioExceptionType.badResponse,
            );
          }

          throw StateError('Unexpected path: ${options.path}');
        },
      );

      final service = FacilityService(dio: dio);

      expect(
        () => service.searchBuildingDestinations('building-1', query: 'derma'),
        throwsA(
          isA<ApiException>().having(
            (error) => error.message,
            'message',
            'Hedef servisi geçici olarak kullanılamıyor.',
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
