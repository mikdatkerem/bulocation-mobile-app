enum NodeType {
  qr,
  park,
  entrance,
  exit,
  elevator,
  stair,
  parkingEntrance,
  parkingExit,
  other,
}

String normalizeSearchText(String value) {
  const replacements = {
    '\u00E7': 'c',
    '\u011F': 'g',
    '\u0131': 'i',
    '\u00F6': 'o',
    '\u015F': 's',
    '\u00FC': 'u',
  };

  final lower = value.trim().toLowerCase().replaceAllMapped(
        RegExp(r'[\u00E7\u011F\u0131\u00F6\u015F\u00FC]'),
        (match) => replacements[match.group(0)] ?? match.group(0)!,
      );

  return lower;
}

int compareNodeLabelsNatural(String left, String right) {
  final leftNormalized = normalizeSearchText(left);
  final rightNormalized = normalizeSearchText(right);
  final chunkPattern = RegExp(r'(\d+|\D+)');
  final leftChunks = chunkPattern
      .allMatches(leftNormalized)
      .map((match) => match.group(0)!)
      .toList();
  final rightChunks = chunkPattern
      .allMatches(rightNormalized)
      .map((match) => match.group(0)!)
      .toList();
  final max = leftChunks.length < rightChunks.length
      ? leftChunks.length
      : rightChunks.length;

  for (var index = 0; index < max; index++) {
    final leftChunk = leftChunks[index];
    final rightChunk = rightChunks[index];
    final leftNumber = int.tryParse(leftChunk);
    final rightNumber = int.tryParse(rightChunk);

    if (leftNumber != null && rightNumber != null) {
      final result = leftNumber.compareTo(rightNumber);
      if (result != 0) {
        return result;
      }
      continue;
    }

    final result = leftChunk.compareTo(rightChunk);
    if (result != 0) {
      return result;
    }
  }

  return leftChunks.length.compareTo(rightChunks.length);
}

NodeType nodeTypeFromFacilityInt(int nodeType) {
  return switch (nodeType) {
    2 => NodeType.qr,
    3 => NodeType.entrance,
    4 => NodeType.exit,
    5 => NodeType.elevator,
    6 => NodeType.stair,
    8 => NodeType.park,
    9 => NodeType.parkingEntrance,
    10 => NodeType.parkingExit,
    _ => NodeType.other,
  };
}

class MapNode {
  const MapNode({
    required this.id,
    required this.label,
    required this.x,
    required this.y,
    required this.type,
    this.normalizedX,
    this.normalizedY,
    this.externalReferenceId,
  });

  final String id;
  final String label;
  final double x;
  final double y;
  final NodeType type;
  final double? normalizedX;
  final double? normalizedY;
  final String? externalReferenceId;

  factory MapNode.fromLegacyJson(Map<String, dynamic> json) {
    final nodeTypeInt = json['nodeType'] as int? ?? 1;
    final type = switch (nodeTypeInt) {
      2 => NodeType.park,
      _ => NodeType.qr,
    };

    final id = (json['id'] as String).toUpperCase();
    return MapNode(
      id: id,
      label: json['label'] as String? ?? id,
      x: (json['x'] as num).toDouble(),
      y: (json['y'] as num).toDouble(),
      type: type,
      normalizedX: null,
      normalizedY: null,
      externalReferenceId: id,
    );
  }

  factory MapNode.fromFacilityJson(Map<String, dynamic> json) {
    final nodeTypeInt = json['nodeType'] as int? ?? 1;
    final type = nodeTypeFromFacilityInt(nodeTypeInt);

    final code = (json['code'] as String?) ?? (json['id']?.toString() ?? '');
    return MapNode(
      id: code.toUpperCase(),
      label: (json['label'] as String?) ?? code,
      x: (json['pixelX'] as num).toDouble(),
      y: (json['pixelY'] as num).toDouble(),
      type: type,
      normalizedX: (json['normalizedX'] as num?)?.toDouble(),
      normalizedY: (json['normalizedY'] as num?)?.toDouble(),
      externalReferenceId: json['externalReferenceId'] as String?,
    );
  }

  factory MapNode.fromDestination({
    required String id,
    required String label,
    required int nodeType,
    required double pixelX,
    required double pixelY,
    required double normalizedX,
    required double normalizedY,
    required String? externalReferenceId,
  }) {
    return MapNode(
      id: id.toUpperCase(),
      label: label,
      x: pixelX,
      y: pixelY,
      type: nodeTypeFromFacilityInt(nodeType),
      normalizedX: normalizedX,
      normalizedY: normalizedY,
      externalReferenceId: externalReferenceId,
    );
  }

  bool get isPark => type == NodeType.park;
  bool get isQr => type == NodeType.qr;
  String get occupancyKey => (externalReferenceId?.trim().isNotEmpty == true
          ? externalReferenceId!.trim()
          : id)
      .toUpperCase();
  bool? occupancyFrom(Map<String, bool> occupancyMap) {
    final externalKey = externalReferenceId?.trim().toUpperCase();
    if (externalKey?.isNotEmpty == true &&
        occupancyMap.containsKey(externalKey)) {
      return occupancyMap[externalKey];
    }

    return occupancyMap[id.toUpperCase()];
  }

  bool get isConnector =>
      type == NodeType.entrance ||
      type == NodeType.exit ||
      type == NodeType.elevator ||
      type == NodeType.stair ||
      type == NodeType.parkingEntrance ||
      type == NodeType.parkingExit;

  double resolveX(double mapWidth) =>
      normalizedX != null ? normalizedX!.clamp(0, 1) * mapWidth : x;
  double resolveY(double mapHeight) =>
      normalizedY != null ? normalizedY!.clamp(0, 1) * mapHeight : y;
}

class MapEdge {
  const MapEdge({required this.from, required this.to});

  final String from;
  final String to;
}
