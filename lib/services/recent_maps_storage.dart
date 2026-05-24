import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/recent_map.dart';

class RecentMapsStorage {
  static const _key = 'recent.maps';
  static const _maxEntries = 8;

  Future<List<RecentMapEntry>> read() async {
    final preferences = await SharedPreferences.getInstance();
    final raw = preferences.getString(_key);
    if (raw == null || raw.isEmpty) {
      return const [];
    }

    try {
      final items = jsonDecode(raw) as List<dynamic>;
      return items
          .map((item) => RecentMapEntry.fromJson(item as Map<String, dynamic>))
          .toList()
        ..sort((left, right) => right.usedAt.compareTo(left.usedAt));
    } catch (_) {
      return const [];
    }
  }

  Future<void> upsert(RecentMapEntry entry) async {
    final preferences = await SharedPreferences.getInstance();
    final entries = await read();
    final nextEntries = [
      entry,
      ...entries.where((item) => item.floorId != entry.floorId),
    ].take(_maxEntries).toList();

    await preferences.setString(
      _key,
      jsonEncode(nextEntries.map((item) => item.toJson()).toList()),
    );
  }
}
