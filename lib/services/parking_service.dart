import 'dart:async';
import 'dart:convert';
import 'dart:developer' as developer;

import 'package:http/http.dart' as http;
import 'package:signalr_netcore/ihub_protocol.dart';
import 'package:signalr_netcore/signalr_client.dart';

import '../core/api_client.dart';
import '../main.dart';

class ParkingService {
  ParkingService({http.Client? client, this.onOccupancyChanged})
      : _client = client ?? http.Client();

  final http.Client _client;
  final void Function(String spotId, bool isOccupied)? onOccupancyChanged;

  String get _baseUrl => AppConfig.apiBaseUrl;
  String get _hubUrl => AppConfig.hubBaseUrl;

  HubConnection? _hubConnection;
  String? _activeFloorId;
  String? _subscribedFloorId;

  Future<Map<String, bool>> getOccupancyMap(String floorId) async {
    final uri =
        Uri.parse('$_baseUrl/client/facilities/floors/$floorId/occupancy');
    final response = await _client
        .get(
          uri,
          headers: ApiClient.buildHeaders(includeJsonContentType: false),
        )
        .timeout(const Duration(seconds: 10));

    if (response.statusCode != 200) {
      throw Exception('HTTP ${response.statusCode}: ${response.body}');
    }

    final list = jsonDecode(response.body) as List<dynamic>;
    final result = <String, bool>{};
    for (final item in list) {
      final map = item as Map<String, dynamic>;
      final id = ((map['id'] ?? map['Id']) as String).toUpperCase();
      final isOccupied = (map['isOccupied'] ?? map['IsOccupied']) as bool;
      result[id] = isOccupied;
    }

    developer.log(
      'Kat bazli park durumu yuklendi: ${result.length} alan',
      name: 'ParkingService',
    );

    return result;
  }

  Future<void> startListening({String? floorId}) async {
    if (floorId != null && floorId.trim().isNotEmpty) {
      _activeFloorId = floorId.trim();
    }

    if (_hubConnection != null) {
      await _subscribeToActiveFloor();
      return;
    }

    developer.log('SignalR baglaniyor: $_hubUrl', name: 'ParkingService');

    final messageHeaders = MessageHeaders();
    final baseHeaders = ApiClient.buildHeaders(
        includeJsonContentType: false, includeAuth: false);
    for (final entry in baseHeaders.entries) {
      messageHeaders.setHeaderValue(entry.key, entry.value);
    }

    final connectionOptions = HttpConnectionOptions(
      headers: messageHeaders,
      accessTokenFactory: () async =>
          await ApiClient.getRealtimeAccessToken() ?? '',
    );

    _hubConnection = HubConnectionBuilder()
        .withUrl(_hubUrl, options: connectionOptions)
        .withAutomaticReconnect()
        .build();

    _hubConnection!.on('ParkingUpdated', (args) {
      developer.log('ParkingUpdated alindi: $args', name: 'ParkingService');
      if (args == null || args.isEmpty) {
        return;
      }

      try {
        final payload = args.first as Map<String, dynamic>;
        final spotId =
            ((payload['spotId'] ?? payload['SpotId']) as String).toUpperCase();
        final isOccupied =
            (payload['isOccupied'] ?? payload['IsOccupied']) as bool;
        onOccupancyChanged?.call(spotId, isOccupied);
      } catch (error) {
        developer.log(
          'ParkingUpdated parse hatasi: $error',
          name: 'ParkingService',
        );
      }
    });

    _hubConnection!.onclose(({error}) {
      developer.log(
        'SignalR baglantisi kapandi: $error',
        name: 'ParkingService',
      );
      _subscribedFloorId = null;
      _hubConnection = null;
    });

    _hubConnection!.onreconnecting(({error}) {
      developer.log(
        'SignalR yeniden baglaniyor: $error',
        name: 'ParkingService',
      );
    });

    _hubConnection!.onreconnected(({connectionId}) {
      developer.log(
        'SignalR yeniden baglandi: $connectionId',
        name: 'ParkingService',
      );
      _subscribedFloorId = null;
      unawaited(_subscribeToActiveFloor());
    });

    await _hubConnection!.start();
    await _subscribeToActiveFloor();
    developer.log('SignalR baglandi', name: 'ParkingService');
  }

  Future<void> subscribeToFloor(String floorId) async {
    if (floorId.trim().isEmpty) {
      return;
    }

    _activeFloorId = floorId.trim();
    await _subscribeToActiveFloor();
  }

  Future<void> _subscribeToActiveFloor() async {
    final floorId = _activeFloorId;
    final connection = _hubConnection;
    if (floorId == null || connection == null) {
      return;
    }

    if (_subscribedFloorId == floorId) {
      return;
    }

    try {
      final previousFloorId = _subscribedFloorId;
      if (previousFloorId != null) {
        await connection.invoke(
          'UnsubscribeFromFloor',
          args: <Object>[previousFloorId],
        );
      }

      await connection.invoke('SubscribeToFloor', args: <Object>[floorId]);
      _subscribedFloorId = floorId;
    } catch (error) {
      developer.log(
        'SignalR kat aboneligi yapilamadi: $error',
        name: 'ParkingService',
      );
    }
  }

  Future<void> stopListening() async {
    await _hubConnection?.stop();
    _hubConnection = null;
    _subscribedFloorId = null;
  }

  void dispose() {
    stopListening();
    _client.close();
  }
}
