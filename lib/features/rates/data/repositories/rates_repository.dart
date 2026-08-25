import 'package:dio/dio.dart';

import '../../domain/entities/audit_log.dart';
import '../../domain/entities/client_rate.dart';
import '../../domain/entities/location_option.dart';
import '../../domain/entities/published_rate.dart';
import '../../domain/entities/rate_stat.dart';
import '../../domain/entities/ratrix_rate.dart';
import '../../domain/entities/rates_enums.dart';
import '../../domain/entities/recent_rate.dart';
import '../datasources/rates_data_source.dart';

class RatesApiException implements Exception {
  const RatesApiException(this.message, {this.fieldErrors});

  final String message;

  /// Raw `errors` map from a 422 validation response, if any
  /// (field name -> list of messages), so callers can surface specifics.
  final Map<String, dynamic>? fieldErrors;

  @override
  String toString() => message;
}

class RatesRepository {
  RatesRepository(this._dataSource);

  final RatesDataSource _dataSource;

  // ---------------------------------------------------------------------
  // Reads
  // ---------------------------------------------------------------------

  Future<List<RatrixRate>> _fetchAllRates({
    String? rateType,
    int? clientId,
  }) async {
    final res = await _dataSource.fetchRates(
      rateType: rateType,
      clientId: clientId,
    );
    final rows = _asList(res.data);
    return rows
        .whereType<Map<String, dynamic>>()
        .map(RatrixRate.fromJson)
        .toList();
  }

  /// Same as [_fetchAllRates] but via the paginated `GET api/rates/{type}`
  /// endpoint (only `publish`/`custom` are valid `rateType` values here) —
  /// use this when filtering by client, since it's the endpoint built for
  /// that query shape rather than fetching the unbounded full list.
  Future<List<RatrixRate>> _fetchRatesByType(
    String rateType, {
    int? clientId,
    int perPage = 5000,
  }) async {
    final res = await _dataSource.fetchRatesByType(
      rateType,
      clientId: clientId,
      page: 1,
      perPage: perPage,
    );
    final rows = _asList(res.data);
    return rows
        .whereType<Map<String, dynamic>>()
        .map(RatrixRate.fromJson)
        .toList();
  }

  List<dynamic> _asList(dynamic body) {
    if (body is List) return body;
    if (body is Map<String, dynamic> && body['data'] is List)
      return body['data'] as List;
    return const [];
  }

  /// Dashboard stat cards, derived from `GET api/rates` — there's no
  /// dedicated stats endpoint. "This week" deltas aren't derivable without
  /// inventing numbers, so the delta string is left blank when unknown.
  Future<List<RateStat>> fetchStats() async {
    final rates = await _fetchAllRates();

    final activeCount = rates.where((r) => !r.isExpired).length;
    final clientIds = rates
        .where((r) => r.isCustom && r.clientId != null)
        .map((r) => r.clientId)
        .toSet();
    final totalRoutes = rates.fold<int>(0, (sum, r) => sum + r.routes.length);

    final now = DateTime.now();
    final weekAgo = now.subtract(const Duration(days: 7));
    String deltaFor(bool Function(RatrixRate) matches) {
      final createdThisWeek = rates
          .where(
            (r) =>
                r.createdAt != null &&
                r.createdAt!.isAfter(weekAgo) &&
                matches(r),
          )
          .length;
      return createdThisWeek > 0 ? '+$createdThisWeek this week' : '';
    }

    return [
      RateStat(
        label: 'Active rates',
        value: '$activeCount',
        delta: deltaFor((r) => !r.isExpired),
      ),
      RateStat(label: 'Clients', value: '${clientIds.length}', delta: ''),
      RateStat(
        label: 'Total routes',
        value: '$totalRoutes',
        delta: deltaFor((_) => true),
      ),
    ];
  }

  /// Most-recently-created rates from `GET api/rates`, mapped into the
  /// dashboard's `RecentRate` shape. `clientNamesById` (keyed by the same
  /// string ids `ClientsRepository`/`RatesShellBloc` use) resolves the
  /// client column for custom rates — pass the shell's already-fetched
  /// client list; falls back to the raw id, then '—', when unavailable.
  Future<List<RecentRate>> fetchRecentRates({
    int limit = 5,
    Map<String, String>? clientNamesById,
  }) async {
    final rates = await _fetchAllRates();
    final sorted = [...rates]
      ..sort((a, b) {
        if (a.createdAt != null && b.createdAt != null)
          return b.createdAt!.compareTo(a.createdAt!);
        return b.id.compareTo(a.id);
      });

    return sorted
        .take(limit)
        .map((r) => _mapRecentRate(r, clientNamesById))
        .toList();
  }

  RecentRate _mapRecentRate(
    RatrixRate rate,
    Map<String, String>? clientNamesById,
  ) {
    final route = rate.routes.isNotEmpty ? rate.routes.first.routeLabel : '—';
    final price = _formatPrice(rate);
    String client = '—';
    if (rate.isCustom && rate.clientId != null) {
      final idStr = rate.clientId.toString();
      client = clientNamesById?[idStr] ?? idStr;
    }
    return RecentRate(
      route: route,
      client: client,
      type: rate.isCustom ? RateType.custom : RateType.published,
      price: price,
      status: rate.isExpired ? RateStatus.expired : RateStatus.active,
    );
  }

  String _formatPrice(RatrixRate rate) {
    num? amount;
    if (rate.routes.isNotEmpty) {
      final firstRoute = rate.routes.first;
      if (firstRoute.rate != null) {
        amount = firstRoute.rate;
      } else if (firstRoute.breakweights.isNotEmpty) {
        amount = firstRoute.breakweights.first.rate;
      }
    }
    amount ??= rate.addons?.baseFreightRate;
    if (amount == null) return '—';
    return '₱${amount.toStringAsFixed(2)}';
  }

  /// Rates for one client (used by the custom-client-rates panel), mapped
  /// into the existing flattened `ClientRate` shape the UI already renders.
  Future<List<ClientRate>> fetchClientRates(String clientId) async {
    final id = int.tryParse(clientId);
    if (id == null) return const [];
    final rates = await _fetchRatesByType('custom', clientId: id);
    return rates.map((r) => _mapClientRate(r, clientId)).toList();
  }

  Future<List<ClientRate>> fetchAllClientRates() async {
    final rates = await _fetchAllRates(rateType: 'custom');
    return rates
        .where((r) => r.clientId != null)
        .map((r) => _mapClientRate(r, r.clientId!.toString()))
        .toList();
  }

  /// All standard (non-custom) rates, for the Published Rates list.
  Future<List<PublishedRate>> fetchAllPublishedRates() async {
    final rates = await _fetchRatesByType('publish');
    return rates.map(_mapPublishedRate).toList();
  }

  PublishedRate _mapPublishedRate(RatrixRate rate) {
    final freightMode =
        _freightModeFromCode(rate.freightMode?.code) ?? FreightMode.air;
    final serviceMode =
        _serviceModeFromCode(rate.serviceMode?.code) ?? ServiceMode.doorToDoor;
    final isExpired = rate.isExpired;
    final expiryLabel = rate.rateExpiry == null
        ? (isExpired ? 'Expired' : 'Active')
        : (isExpired
              ? 'Expired ${_formatDate(rate.rateExpiry!)}'
              : 'Active until ${_formatDate(rate.rateExpiry!)}');

    return PublishedRate(
      id: rate.id,
      chargeCode: rate.chargeCode ?? '—',
      freightMode: freightMode,
      serviceMode: serviceMode,
      routeLabel: rate.routes.isNotEmpty ? rate.routes.first.routeLabel : '—',
      routeCount: rate.routes.length,
      status: isExpired ? RateStatus.expired : RateStatus.active,
      expiryLabel: expiryLabel,
      expiryDate: rate.rateExpiry,
    );
  }

  ClientRate _mapClientRate(RatrixRate rate, String clientId) {
    final freightMode =
        _freightModeFromCode(rate.freightMode?.code) ?? FreightMode.air;
    final serviceMode =
        _serviceModeFromCode(rate.serviceMode?.code) ?? ServiceMode.doorToDoor;
    final isExpired = rate.isExpired;
    final expiryLabel = rate.rateExpiry == null
        ? (isExpired ? 'Expired' : 'Active')
        : (isExpired
              ? 'Expired ${_formatDate(rate.rateExpiry!)}'
              : 'Active until ${_formatDate(rate.rateExpiry!)}');

    return ClientRate(
      id: rate.id,
      clientId: clientId,
      chargeCode: rate.chargeCode ?? '—',
      freightMode: freightMode,
      serviceMode: serviceMode,
      routeCount: rate.routes.length,
      status: isExpired ? RateStatus.expired : RateStatus.active,
      expiryLabel: expiryLabel,
      expiryDate: rate.rateExpiry,
    );
  }

  String _formatDate(DateTime d) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${months[d.month - 1]} ${d.day}, ${d.year}';
  }

  FreightMode? _freightModeFromCode(String? code) => switch (code) {
    'AIR' => FreightMode.air,
    'LND' => FreightMode.land,
    'SEA' => FreightMode.sea,
    _ => null,
  };

  ServiceMode? _serviceModeFromCode(String? code) => switch (code) {
    'D2D' => ServiceMode.doorToDoor,
    'D2P' => ServiceMode.doorToPort,
    'P2D' => ServiceMode.portToDoor,
    'P2P' => ServiceMode.portToPort,
    _ => null,
  };

  /// Single rate by numeric id.
  Future<RatrixRate> fetchRateById(String id) async {
    final res = await _dataSource.fetchRate(id);
    return RatrixRate.fromJson(res.data as Map<String, dynamic>);
  }

  /// `GET api/rates/lookup` — quote lookup. Not wired to any screen yet;
  /// kept for completeness per the API surface.
  Future<Map<String, dynamic>> lookupRate(Map<String, dynamic> query) async {
    final res = await _dataSource.lookupRate(query);
    return (res.data as Map<String, dynamic>?) ?? const {};
  }

  Future<DateTime?> lastUpdated() async {
    final res = await _dataSource.fetchLastUpdated();
    final body = res.data;
    if (body is Map<String, dynamic>) {
      return DateTime.tryParse(body['updated_at']?.toString() ?? '');
    }
    return null;
  }

  /// Live per-keystroke location search for the rate wizard's
  /// origin/destination picker (`GET api/locations/search`). A search
  /// failure just returns no results rather than throwing, so a flaky
  /// network doesn't crash the picker.
  Future<List<LocationOption>> searchLocations({required String q, String? type}) async {
    try {
      final res = await _dataSource.searchLocations(q: q, type: type);
      final body = res.data;
      var rows = <dynamic>[];
      if (body is Map<String, dynamic>) {
        final data = body['data'];
        if (data is Map<String, dynamic>) {
          // Real shape: `data` splits results by category —
          // `islands`/`regions`/`provinces`/`cities`/`barangays`/`iata` —
          // rather than one flat list. Pick the sub-array matching the
          // requested `type` (pluralized; `iata` has no plural form).
          final key = switch (type) {
            'island' => 'islands',
            'region' => 'regions',
            'province' => 'provinces',
            'city' => 'cities',
            'barangay' => 'barangays',
            'iata' => 'iata',
            _ => null,
          };
          final picked = key == null ? null : data[key];
          if (picked is List) {
            rows = picked;
          } else if (data['results'] is List) {
            rows = data['results'] as List;
          }
        } else if (data is List) {
          rows = data;
        }
      } else if (body is List) {
        rows = body;
      }
      // TEMP DEBUG — remove once the iata-type response shape is confirmed.
      // ignore: avoid_print
      print('[searchLocations] q=$q type=$type rawRows=$rows');
      return rows.whereType<Map<String, dynamic>>().map(LocationOption.fromJson).toList();
    } catch (e) {
      // ignore: avoid_print
      print('[searchLocations] EXCEPTION: $e');
      return const [];
    }
  }

  Future<List<AuditLog>> fetchAuditLogs({
    String? recordId,
    String? tableName,
    String? action,
    int perPage = 100,
  }) async {
    final res = await _dataSource.fetchAuditLogs(
      queryParameters: {
        if (recordId != null) 'record_id': recordId,
        if (tableName != null) 'table_name': tableName,
        if (action != null) 'action': action,
        'per_page': perPage,
      },
    );
    final rows = _asList(res.data);
    return rows
        .whereType<Map<String, dynamic>>()
        .map(AuditLog.fromJson)
        .toList();
  }

  Future<AuditLog?> fetchAuditLog(String id) async {
    final res = await _dataSource.fetchAuditLog(id);
    final data = res.data;
    return data is Map<String, dynamic> ? AuditLog.fromJson(data) : null;
  }

  // ---------------------------------------------------------------------
  // Writes
  // ---------------------------------------------------------------------

  Future<RatrixRate> createRate(Map<String, dynamic> payload) async {
    try {
      final res = await _dataSource.createRate(payload);
      return RatrixRate.fromJson(res.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _mapError(e);
    }
  }

  Future<RatrixRate> updateRate(String id, Map<String, dynamic> payload) async {
    try {
      final res = await _dataSource.updateRate(id, payload);
      return RatrixRate.fromJson(res.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _mapError(e);
    }
  }

  /// Hard delete — callers must confirm with the user first (no UI
  /// currently calls this; see `remove_route_dialog.dart` for the confirm
  /// pattern to reuse).
  Future<void> deleteRate(String id) async {
    try {
      await _dataSource.deleteRate(id);
    } on DioException catch (e) {
      throw _mapError(e);
    }
  }

  RatesApiException _mapError(DioException e) {
    final data = e.response?.data;
    if (data is Map<String, dynamic>) {
      final message = data['message']?.toString();
      // Laravel validation errors: { "field": ["message", ...], ... }
      final looksLikeFieldErrors = data.values.every((v) => v is List);
      if (looksLikeFieldErrors && data.isNotEmpty) {
        final firstMessage = (data.values.first as List).isNotEmpty
            ? (data.values.first as List).first.toString()
            : 'Validation failed.';
        return RatesApiException(firstMessage, fieldErrors: data);
      }
      if (message != null && message.isNotEmpty) {
        return RatesApiException(
          message,
          fieldErrors: data['errors'] as Map<String, dynamic>?,
        );
      }
    }
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout ||
        e.type == DioExceptionType.connectionError) {
      return const RatesApiException(
        'Could not reach the server. Check your connection.',
      );
    }
    return RatesApiException(
      e.message ?? 'Something went wrong. Please try again.',
    );
  }
}
