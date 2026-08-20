import 'package:dio/dio.dart';

class RatesDataSource {
  RatesDataSource(this._dio);

  final Dio _dio;

  Future<Response<dynamic>> fetchRates({String? rateType, int? clientId}) => _dio.get(
        'api/rates',
        queryParameters: {
          if (rateType != null) 'rate_type': rateType,
          if (clientId != null) 'client_id': clientId,
        },
      );

  Future<Response<dynamic>> createRate(Map<String, dynamic> body) => _dio.post('api/rates', data: body);

  /// `id` may be a numeric rate id, or the literal `publish`/`custom` to get
  /// a paginated list filtered by rate type (see `fetchRatesByType`).
  Future<Response<dynamic>> fetchRate(String id) => _dio.get('api/rates/$id');

  Future<Response<dynamic>> fetchRatesByType(
    String rateType, {
    int? clientId,
    int? perPage,
  }) =>
      _dio.get(
        'api/rates/$rateType',
        queryParameters: {
          if (clientId != null) 'client_id': clientId,
          if (perPage != null) 'per_page': perPage,
        },
      );

  Future<Response<dynamic>> updateRate(String id, Map<String, dynamic> body) => _dio.put('api/rates/$id', data: body);

  Future<Response<dynamic>> deleteRate(String id) => _dio.delete('api/rates/$id');

  Future<Response<dynamic>> lookupRate(Map<String, dynamic> queryParameters) => _dio.get(
        'api/rates/lookup',
        queryParameters: queryParameters,
      );

  Future<Response<dynamic>> fetchLastUpdated() => _dio.get('api/rates/last-updated');

  Future<Response<dynamic>> fetchAuditLogs({Map<String, dynamic>? queryParameters}) => _dio.get(
        'api/rates/audit-logs',
        queryParameters: queryParameters,
      );

  Future<Response<dynamic>> fetchAuditLog(String id) => _dio.get('api/rates/audit-logs/$id');
}
