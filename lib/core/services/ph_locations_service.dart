import 'package:dio/dio.dart';

/// Nationwide city/province name lists for the origin/destination
/// autocomplete, sourced from the CerroV5 backend's `locations/search`
/// endpoint (`q=&all=1&type=city|province`, same Dio client/base URL as
/// the rest of the app) rather than a bundled offline PSGC dataset.
class PhLocationsService {
  PhLocationsService(this._dio);

  final Dio _dio;

  List<String>? _cities;
  List<String>? _provinces;

  List<String> get cities => _cities ?? const [];
  List<String> get provinces => _provinces ?? const [];
  bool get isLoaded => _cities != null && _provinces != null;

  Future<void> ensureLoaded() async {
    if (isLoaded) return;

    final results = await Future.wait([
      _fetchNames(type: 'city', key: 'cities'),
      _fetchNames(type: 'province', key: 'provinces'),
    ]);

    _cities = results[0];
    _provinces = results[1];
  }

  Future<List<String>> _fetchNames({required String type, required String key}) async {
    try {
      final res = await _dio.get(
        'api/locations/search',
        queryParameters: {'q': '', 'all': 1, 'type': type},
      );
      final body = res.data;
      final data = body is Map<String, dynamic> ? body['data'] as Map<String, dynamic>? : null;
      final rows = data?[key] as List<dynamic>? ?? const [];
      return rows
          .whereType<Map<String, dynamic>>()
          .map((row) => row['name']?.toString())
          .whereType<String>()
          .toSet()
          .toList()
        ..sort();
    } catch (_) {
      // Leave the list empty — the origin/destination fields just show no
      // suggestions rather than getting stuck.
      return const [];
    }
  }
}
