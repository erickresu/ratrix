import 'ratrix_rate.dart' show RatrixBreakweight;

/// One matched-location entry inside an ODA/Pickup Fee bracket-config —
/// e.g. "if the destination is Mandaue City, Cebu, charge per this
/// breakweight table." [locationId] is whatever geography id level the
/// config was authored at (city/province/etc, per the parent config's own
/// `format`) — matched against any of the selected route's origin/
/// destination geography ids, not just one fixed level, since `format` can
/// vary per rate.
class ConditionalAddonRoute {
  const ConditionalAddonRoute({
    this.locationId,
    this.locationLabel,
    this.breakweights = const [],
  });

  final int? locationId;
  final String? locationLabel;
  final List<RatrixBreakweight> breakweights;
}

/// Parsed `custom_addons.oda_config` / `custom_addons.pickup_fee_config` —
/// both are identical in shape, differing only in whether each route entry
/// keys off `destination`/`destination_id` (ODA) or `origin`/`origin_id`
/// (Pickup Fee). `chargeOptionId` mirrors the main breakweight pricing
/// options (see `RatesFkIds.chargeOptionIds`) — `3` (Flat Breakweight) is
/// the only value seen in practice: whichever tier the chargeable weight
/// falls into is charged at that tier's flat rate, no per-kg multiplication.
class ConditionalAddonConfig {
  const ConditionalAddonConfig({this.chargeOptionId, this.routes = const []});

  final int? chargeOptionId;
  final List<ConditionalAddonRoute> routes;

  static int? _asInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value.toString());
  }

  static ConditionalAddonConfig? fromJson(
    dynamic json, {
    required String locationKey,
    required String locationIdKey,
  }) {
    if (json is! Map<String, dynamic>) return null;
    final routesJson = json['routes'];
    if (routesJson is! List) return null;
    return ConditionalAddonConfig(
      chargeOptionId: _asInt(json['charge_option']),
      routes: routesJson.whereType<Map<String, dynamic>>().map((r) {
        return ConditionalAddonRoute(
          locationId: _asInt(r[locationIdKey]),
          locationLabel: r[locationKey]?.toString(),
          breakweights: (r['breakweights'] as List<dynamic>? ?? const [])
              .whereType<Map<String, dynamic>>()
              .map(RatrixBreakweight.fromJson)
              .toList(),
        );
      }).toList(),
    );
  }
}
