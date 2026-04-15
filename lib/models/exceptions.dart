class LocationNotFoundException implements Exception {
  const LocationNotFoundException(this.locationId);

  final String locationId;

  @override
  String toString() => 'Konum bulunamadi: $locationId';
}

class ApiException implements Exception {
  const ApiException(
    this.message, {
    this.statusCode,
    this.code,
    this.errors,
  });

  final String message;
  final int? statusCode;
  final String? code;
  final Map<String, List<String>>? errors;

  @override
  String toString() => message;
}
