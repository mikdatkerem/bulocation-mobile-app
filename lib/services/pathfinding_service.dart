import 'dart:math';

import 'package:dio/dio.dart';

import '../core/api_client.dart';
import '../models/exceptions.dart';
import '../models/graph_data.dart';

enum ExitTargetType {
  any('any'),
  facility('facility'),
  parking('parking');

  const ExitTargetType(this.apiValue);

  final String apiValue;
}

class PathfindingService {
  PathfindingService({Dio? dio}) : _dio = dio ?? ApiClient.instance;

  final Dio _dio;

  Map<String, List<MapNode>> getParkGroups(List<MapNode> nodes) {
    final parks = nodes.where((node) => node.isPark).toList()
      ..sort(
          (left, right) => compareNodeLabelsNatural(left.label, right.label));
    return {'parks': parks};
  }

  MapNode? nearestEmptyParkToUser(
    String fromReferenceId,
    Map<String, bool> occupancyMap,
    List<MapNode> nodes,
  ) {
    final source = nodes.where((node) {
      final reference = (node.externalReferenceId ?? node.id).toUpperCase();
      return reference == fromReferenceId.toUpperCase();
    }).firstOrNull;

    if (source == null) {
      return null;
    }

    final availableParks = nodes.where(
      (node) => node.isPark && node.occupancyFrom(occupancyMap) == false,
    );

    MapNode? bestPark;
    var bestDistance = double.infinity;

    for (final park in availableParks) {
      final dx = source.x - park.x;
      final dy = source.y - park.y;
      final distance = sqrt(dx * dx + dy * dy);
      if (distance < bestDistance) {
        bestDistance = distance;
        bestPark = park;
      }
    }

    return bestPark;
  }

  Future<RouteResult?> findFacilityRoute({
    required String floorId,
    required String fromReferenceId,
    required String toReferenceId,
    bool accessibleOnly = false,
  }) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '/navigation/facility-route',
        queryParameters: {
          'floorId': floorId,
          'fromReferenceId': fromReferenceId,
          'toReferenceId': toReferenceId,
          'accessibleOnly': accessibleOnly,
        },
      );
      return RouteResult.fromFacilityJson(response.data!);
    } on DioException catch (error) {
      if (error.response?.statusCode == 404) {
        return null;
      }
      if (error.response?.statusCode == 401) {
        throw const ApiException('Kimlik doğrulama hatası');
      }
      final detail = error.response?.data is Map<String, dynamic>
          ? (error.response!.data['detail']?.toString())
          : null;
      throw ApiException(detail ?? error.message ?? 'Rota hesaplanamadı');
    }
  }

  Future<MultiRouteResult?> findFacilityMultiRoute({
    required String fromReferenceId,
    required String toReferenceId,
    bool accessibleOnly = false,
  }) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '/navigation/facility-multi-route',
        queryParameters: {
          'fromReferenceId': fromReferenceId,
          'toReferenceId': toReferenceId,
          'accessibleOnly': accessibleOnly,
        },
      );
      return MultiRouteResult.fromJson(response.data!);
    } on DioException catch (error) {
      if (error.response?.statusCode == 404) {
        return null;
      }
      if (error.response?.statusCode == 401) {
        throw const ApiException('Kimlik doğrulama hatası');
      }
      final detail = error.response?.data is Map<String, dynamic>
          ? (error.response!.data['detail']?.toString())
          : null;
      throw ApiException(
        detail ?? error.message ?? 'Çok katlı rota hesaplanamadı',
      );
    }
  }

  Future<MultiRouteResult?> findBestExitRoute({
    required String fromReferenceId,
    bool accessibleOnly = false,
    ExitTargetType exitTarget = ExitTargetType.any,
  }) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '/navigation/facility-best-exit-route',
        queryParameters: {
          'fromReferenceId': fromReferenceId,
          'accessibleOnly': accessibleOnly,
          'exitTarget': exitTarget.apiValue,
        },
      );
      return MultiRouteResult.fromJson(response.data!);
    } on DioException catch (error) {
      if (error.response?.statusCode == 404) {
        return null;
      }
      final detail = error.response?.data is Map<String, dynamic>
          ? (error.response!.data['detail']?.toString())
          : null;
      throw ApiException(
          detail ?? error.message ?? 'Çıkış rotası hesaplanamadı');
    }
  }

  Future<RecommendedRouteResult?> findRecommendedParkingNearEntrance({
    required String fromReferenceId,
    bool accessibleOnly = false,
  }) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '/navigation/facility-recommended-parking-near-entrance',
        queryParameters: {
          'fromReferenceId': fromReferenceId,
          'accessibleOnly': accessibleOnly,
        },
      );
      return RecommendedRouteResult.fromJson(response.data!);
    } on DioException catch (error) {
      if (error.response?.statusCode == 404) {
        return null;
      }
      final detail = error.response?.data is Map<String, dynamic>
          ? (error.response!.data['detail']?.toString())
          : null;
      throw ApiException(
        detail ?? error.message ?? 'Girişe yakın park önerisi alınamadı',
      );
    }
  }

  Future<RecommendedRouteResult?> findRecommendedParkingNearestToUser({
    required String fromReferenceId,
    bool accessibleOnly = false,
  }) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '/navigation/facility-recommended-parking-nearest-to-user',
        queryParameters: {
          'fromReferenceId': fromReferenceId,
          'accessibleOnly': accessibleOnly,
        },
      );
      return RecommendedRouteResult.fromJson(response.data!);
    } on DioException catch (error) {
      if (error.response?.statusCode == 404) {
        return null;
      }
      final detail = error.response?.data is Map<String, dynamic>
          ? (error.response!.data['detail']?.toString())
          : null;
      throw ApiException(
        detail ?? error.message ?? 'Size en yakın park önerisi alınamadı',
      );
    }
  }

  Future<RecommendedRouteResult?> findRecommendedParkingNearParkingEntrance({
    required String fromReferenceId,
    bool accessibleOnly = false,
  }) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '/navigation/facility-recommended-parking-near-parking-entrance',
        queryParameters: {
          'fromReferenceId': fromReferenceId,
          'accessibleOnly': accessibleOnly,
        },
      );
      return RecommendedRouteResult.fromJson(response.data!);
    } on DioException catch (error) {
      if (error.response?.statusCode == 404) {
        return null;
      }
      final detail = error.response?.data is Map<String, dynamic>
          ? (error.response!.data['detail']?.toString())
          : null;
      throw ApiException(
        detail ?? error.message ?? 'Girişe en yakın park önerisi alınamadı',
      );
    }
  }

  Future<MapNode?> findClosestAvailableParking(
    String fromNodeId,
    List<MapNode> nodes,
    List<MapEdge> edges,
    Map<String, bool> occupancyMap,
  ) async {
    final availableParks = nodes.where(
      (node) => node.isPark && node.occupancyFrom(occupancyMap) == false,
    );

    MapNode? bestPark;
    var bestDistance = double.infinity;

    for (final park in availableParks) {
      final route = _dijkstra(
        start: fromNodeId,
        goal: park.id,
        nodes: nodes,
        edges: edges,
      );
      if (route == null) {
        continue;
      }

      if (route.distance < bestDistance) {
        bestDistance = route.distance;
        bestPark = park;
      }
    }

    return bestPark;
  }

  _RouteComputationResult? _dijkstra({
    required String start,
    required String goal,
    required List<MapNode> nodes,
    required List<MapEdge> edges,
  }) {
    final adjacency = <String, List<String>>{};
    for (final edge in edges) {
      adjacency.putIfAbsent(edge.from, () => <String>[]).add(edge.to);
      adjacency.putIfAbsent(edge.to, () => <String>[]).add(edge.from);
    }

    final nodeById = {for (final node in nodes) node.id: node};
    final distances = <String, double>{start: 0};
    final previous = <String, String?>{};
    final queue = <String>{start};

    while (queue.isNotEmpty) {
      final current = queue.reduce(
        (left, right) => (distances[left] ?? double.infinity) <=
                (distances[right] ?? double.infinity)
            ? left
            : right,
      );
      queue.remove(current);

      if (current == goal) {
        break;
      }

      final currentNode = nodeById[current];
      if (currentNode == null) {
        continue;
      }

      for (final neighbor in adjacency[current] ?? const <String>[]) {
        final neighborNode = nodeById[neighbor];
        if (neighborNode == null) {
          continue;
        }

        final dx = currentNode.x - neighborNode.x;
        final dy = currentNode.y - neighborNode.y;
        final distance = sqrt(dx * dx + dy * dy);
        final candidate = (distances[current] ?? double.infinity) + distance;

        if (candidate < (distances[neighbor] ?? double.infinity)) {
          distances[neighbor] = candidate;
          previous[neighbor] = current;
          queue.add(neighbor);
        }
      }
    }

    if (!distances.containsKey(goal)) {
      return null;
    }

    final route = <String>[];
    String? current = goal;
    while (current != null) {
      route.add(current);
      current = previous[current];
    }

    return _RouteComputationResult(
      distance: distances[goal]!,
      nodeIds: route.reversed.toList(),
    );
  }
}

class _RouteComputationResult {
  const _RouteComputationResult({
    required this.distance,
    required this.nodeIds,
  });

  final double distance;
  final List<String> nodeIds;
}

class RouteResult {
  const RouteResult({
    required this.nodes,
    required this.distanceMeters,
    required this.distanceLabel,
    required this.mapAssetPath,
    required this.mapWidth,
    required this.mapHeight,
  });

  final List<MapNode> nodes;
  final double distanceMeters;
  final String distanceLabel;
  final String? mapAssetPath;
  final int? mapWidth;
  final int? mapHeight;

  factory RouteResult.fromFacilityJson(Map<String, dynamic> json) {
    final nodeList = (json['nodes'] as List<dynamic>)
        .map((item) => MapNode.fromFacilityJson(item as Map<String, dynamic>))
        .toList();

    return RouteResult(
      nodes: nodeList,
      distanceMeters: (json['distanceMeters'] as num).toDouble(),
      distanceLabel: json['distanceLabel'] as String,
      mapAssetPath: json['mapAssetPath'] as String?,
      mapWidth: json['mapWidth'] as int?,
      mapHeight: json['mapHeight'] as int?,
    );
  }
}

class MultiRouteSegment {
  const MultiRouteSegment({
    required this.mapVersionId,
    required this.floorId,
    required this.floorName,
    required this.buildingId,
    required this.buildingName,
    required this.siteId,
    required this.siteName,
    required this.mapName,
    required this.mapAssetPath,
    required this.mapAssetContentType,
    required this.mapWidth,
    required this.mapHeight,
    required this.nodes,
  });

  final String mapVersionId;
  final String floorId;
  final String floorName;
  final String buildingId;
  final String buildingName;
  final String siteId;
  final String siteName;
  final String mapName;
  final String mapAssetPath;
  final String mapAssetContentType;
  final int mapWidth;
  final int mapHeight;
  final List<MapNode> nodes;

  factory MultiRouteSegment.fromJson(Map<String, dynamic> json) {
    return MultiRouteSegment(
      mapVersionId: json['mapVersionId'] as String,
      floorId: json['floorId'] as String,
      floorName: json['floorName'] as String,
      buildingId: json['buildingId'] as String,
      buildingName: json['buildingName'] as String,
      siteId: json['siteId'] as String,
      siteName: json['siteName'] as String,
      mapName: json['mapName'] as String,
      mapAssetPath: json['mapAssetPath'] as String,
      mapAssetContentType: json['mapAssetContentType'] as String,
      mapWidth: json['mapWidth'] as int,
      mapHeight: json['mapHeight'] as int,
      nodes: (json['nodes'] as List<dynamic>)
          .map((item) => MapNode.fromFacilityJson(item as Map<String, dynamic>))
          .toList(),
    );
  }
}

class MultiRouteResult {
  const MultiRouteResult({
    required this.segments,
    required this.distanceMeters,
    required this.distanceLabel,
  });

  final List<MultiRouteSegment> segments;
  final double distanceMeters;
  final String distanceLabel;

  factory MultiRouteResult.fromJson(Map<String, dynamic> json) {
    return MultiRouteResult(
      segments: (json['segments'] as List<dynamic>)
          .map((item) =>
              MultiRouteSegment.fromJson(item as Map<String, dynamic>))
          .toList(),
      distanceMeters: (json['distanceMeters'] as num).toDouble(),
      distanceLabel: json['distanceLabel'] as String,
    );
  }
}

class RecommendedRouteTarget {
  const RecommendedRouteTarget({
    required this.code,
    required this.label,
    required this.externalReferenceId,
  });

  final String code;
  final String label;
  final String? externalReferenceId;

  factory RecommendedRouteTarget.fromJson(Map<String, dynamic> json) {
    return RecommendedRouteTarget(
      code: json['code'] as String,
      label: json['label'] as String,
      externalReferenceId: json['externalReferenceId'] as String?,
    );
  }
}

class RecommendedRouteResult {
  const RecommendedRouteResult({
    required this.target,
    required this.segments,
    required this.distanceMeters,
    required this.distanceLabel,
  });

  final RecommendedRouteTarget target;
  final List<MultiRouteSegment> segments;
  final double distanceMeters;
  final String distanceLabel;

  factory RecommendedRouteResult.fromJson(Map<String, dynamic> json) {
    return RecommendedRouteResult(
      target: RecommendedRouteTarget.fromJson(
          json['target'] as Map<String, dynamic>),
      segments: (json['segments'] as List<dynamic>)
          .map((item) =>
              MultiRouteSegment.fromJson(item as Map<String, dynamic>))
          .toList(),
      distanceMeters: (json['distanceMeters'] as num).toDouble(),
      distanceLabel: json['distanceLabel'] as String,
    );
  }
}
