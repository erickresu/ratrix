// Domain entities mirroring the real `api/rates` JSON shape from the
// CerroV5 backend (see `ratrix_rates`/`ratrix_routes`/`ratrix_addons`
// tables). Freezed classes with hand-written `fromJson`/`toJson` (no
// json_serializable codegen — these need the same defensive Laravel
// decimal-string parsing `client.dart` doesn't).

import 'package:freezed_annotation/freezed_annotation.dart';

part 'ratrix_rate.freezed.dart';

/// Laravel decimal-cast columns (all the `ratrix_addons` money fields,
/// breakweight rates, etc) serialize as JSON strings (e.g. `"10.00"`), not
/// numbers — a plain `json[key] as num?` throws on every non-null value and,
/// caught by an outer blanket try/catch, silently drops the whole rate from
/// the list. Parse defensively instead: accept a real num as-is, or a string
/// via `num.tryParse`.
num? _asNum(dynamic value) {
  if (value == null) return null;
  if (value is num) return value;
  return num.tryParse(value.toString());
}

int? _asInt(dynamic value) => _asNum(value)?.toInt();

@freezed
abstract class RatrixLookupOption with _$RatrixLookupOption {
  const factory RatrixLookupOption({required int id, required String name, String? code}) = _RatrixLookupOption;

  static RatrixLookupOption fromJson(Map<String, dynamic> json) => RatrixLookupOption(
        id: _asInt(json['id'])!,
        name: (json['name'] ?? '').toString(),
        code: json['code']?.toString(),
      );
}

@freezed
abstract class RatrixAddress with _$RatrixAddress {
  const factory RatrixAddress({
    int? id,
    int? cityId,
    int? provinceId,
    int? regionId,
    int? islandId,
    int? barangayId,
    String? zipcode,
    String? label,
    String? address1,
  }) = _RatrixAddress;

  const RatrixAddress._();

  static RatrixAddress fromJson(Map<String, dynamic> json) => RatrixAddress(
        id: _asInt(json['id']),
        cityId: _asInt(json['city_id']),
        provinceId: _asInt(json['province_id']),
        regionId: _asInt(json['region_id']),
        islandId: _asInt(json['island_id']),
        barangayId: _asInt(json['barangay_id']),
        zipcode: json['zipcode']?.toString(),
        label: json['label']?.toString(),
        address1: json['address1']?.toString(),
      );

  Map<String, dynamic> toJson() => {
        if (islandId != null) 'island_id': islandId,
        if (regionId != null) 'region_id': regionId,
        if (provinceId != null) 'province_id': provinceId,
        if (cityId != null) 'city_id': cityId,
        if (barangayId != null) 'barangay_id': barangayId,
        if (zipcode != null) 'zipcode': zipcode,
        if (label != null) 'label': label,
        if (address1 != null) 'address1': address1,
      };

  /// A short human-readable label used by dashboard/recent-rates display.
  String get displayLabel => label ?? address1 ?? zipcode ?? '—';
}

@freezed
abstract class RatrixBreakweight with _$RatrixBreakweight {
  const factory RatrixBreakweight({required num min, required num max, required num rate, num? expressRate}) = _RatrixBreakweight;

  const RatrixBreakweight._();

  static RatrixBreakweight fromJson(Map<String, dynamic> json) => RatrixBreakweight(
        min: (_asNum(json['breakweight_min'])) ?? 0,
        max: (_asNum(json['breakweight_max'])) ?? 0,
        rate: (_asNum(json['rate'])) ?? 0,
        expressRate: _asNum(json['express_rate']),
      );

  Map<String, dynamic> toJson() => {
        'breakweight_min': min,
        'breakweight_max': max,
        'rate': rate,
        if (expressRate != null) 'express_rate': expressRate,
      };

  /// The wizard sends `999999999` as this tier's max for Excess/Minimum
  /// Excess pricing's uncapped 2nd tier (the backend has no real "no
  /// limit" value) — display it as "No limit" instead of the raw sentinel.
  bool get isUncapped => max >= 999999999;
}

@freezed
abstract class RatrixRoute with _$RatrixRoute {
  const factory RatrixRoute({
    String? id,
    int? vehicleTypeId,
    int? containerSizeId,
    int? frequencyBasisId,
    num? minDistance,
    num? maxDistance,
    int? numberOfTrips,
    num? excessRate,
    num? timeInHours,
    num? rate,
    @Default(<RatrixBreakweight>[]) List<RatrixBreakweight> breakweights,
    RatrixAddress? origin,
    RatrixAddress? destination,
  }) = _RatrixRoute;

  const RatrixRoute._();

  static RatrixRoute fromJson(Map<String, dynamic> json) => RatrixRoute(
        id: json['id']?.toString(),
        vehicleTypeId: _asInt(json['vehicle_type_id']),
        containerSizeId: _asInt(json['container_size_id']),
        frequencyBasisId: _asInt(json['frequency_basis_id']),
        minDistance: _asNum(json['min_distance']),
        maxDistance: _asNum(json['max_distance']),
        numberOfTrips: _asInt(json['number_of_trips']),
        excessRate: _asNum(json['excess_rate']),
        timeInHours: _asNum(json['time_in_hours']),
        rate: _asNum(json['rate']),
        breakweights: (json['breakweights'] as List<dynamic>? ?? const [])
            .whereType<Map<String, dynamic>>()
            .map(RatrixBreakweight.fromJson)
            .toList(),
        origin: json['origin'] is Map<String, dynamic> ? RatrixAddress.fromJson(json['origin'] as Map<String, dynamic>) : null,
        destination: json['destination'] is Map<String, dynamic> ? RatrixAddress.fromJson(json['destination'] as Map<String, dynamic>) : null,
      );

  Map<String, dynamic> toJson() => {
        if (vehicleTypeId != null) 'vehicle_type_id': vehicleTypeId,
        if (containerSizeId != null) 'container_size_id': containerSizeId,
        if (frequencyBasisId != null) 'frequency_basis_id': frequencyBasisId,
        if (minDistance != null) 'min_distance': minDistance,
        if (maxDistance != null) 'max_distance': maxDistance,
        if (numberOfTrips != null) 'number_of_trips': numberOfTrips,
        if (excessRate != null) 'excess_rate': excessRate,
        if (timeInHours != null) 'time_in_hours': timeInHours,
        if (rate != null) 'rate': rate,
        if (breakweights.isNotEmpty) 'breakweights': breakweights.map((b) => b.toJson()).toList(),
        if (origin != null) 'origin': origin!.toJson(),
        if (destination != null) 'destination': destination!.toJson(),
      };

  /// "Origin → Destination" label for dashboard/recent-rates display.
  String get routeLabel => '${origin?.displayLabel ?? '—'} → ${destination?.displayLabel ?? '—'}';
}

@freezed
abstract class RatrixAddons with _$RatrixAddons {
  const factory RatrixAddons({
    num? baseFreightRate,
    num? fuelSurcharge,
    String? fuelSurchargeType,
    num? securitySurcharge,
    num? oda,
    num? waybillFee,
    num? bookingHandlingFee,
    num? documentationFee,
    num? participationFee,
    num? permitFeesNonVat,
    num? insurance,
    num? valuation,
    String? valuationType,
    num? pickupFee,
    num? deliveryFee,
    num? cratingFee,
    num? packingFee,
    num? airThc,
    num? seaThc,
    num? arrastre,
    num? demurrageDetention,
    num? waitingTime,
    num? roadToll,
    num? othersNonVat,
    num? hazardousGoodsHandling,
  }) = _RatrixAddons;

  const RatrixAddons._();

  static RatrixAddons fromJson(Map<String, dynamic> json) => RatrixAddons(
        baseFreightRate: _asNum(json['base_freight_rate']),
        fuelSurcharge: _asNum(json['fuel_surcharge']),
        fuelSurchargeType: json['fuel_surcharge_type']?.toString(),
        securitySurcharge: _asNum(json['security_surcharge']),
        // `oda`/`pickup_fee` can also be a bracket-config object — only the
        // flat-decimal form is supported here (see repository TODO).
        oda: json['oda'] is num ? json['oda'] as num : null,
        waybillFee: _asNum(json['waybill_fee']),
        bookingHandlingFee: _asNum(json['booking_handling_fee']),
        documentationFee: _asNum(json['documentation_fee']),
        participationFee: _asNum(json['participation_fee']),
        permitFeesNonVat: _asNum(json['permit_fees_non_vat']),
        insurance: _asNum(json['insurance']),
        valuation: _asNum(json['valuation']),
        valuationType: json['valuation_type']?.toString(),
        pickupFee: json['pickup_fee'] is num ? json['pickup_fee'] as num : null,
        deliveryFee: _asNum(json['delivery_fee']),
        cratingFee: _asNum(json['crating_fee']),
        packingFee: _asNum(json['packing_fee']),
        airThc: _asNum(json['air_thc']),
        seaThc: _asNum(json['sea_thc']),
        arrastre: _asNum(json['arrastre']),
        demurrageDetention: _asNum(json['demurrage_detention']),
        waitingTime: _asNum(json['waiting_time']),
        roadToll: _asNum(json['road_toll']),
        othersNonVat: _asNum(json['others_non_vat']),
        hazardousGoodsHandling: _asNum(json['hazardous_goods_handling']),
      );

  Map<String, dynamic> toJson() => {
        if (baseFreightRate != null) 'base_freight_rate': baseFreightRate,
        if (fuelSurcharge != null) 'fuel_surcharge': fuelSurcharge,
        if (fuelSurchargeType != null) 'fuel_surcharge_type': fuelSurchargeType,
        if (securitySurcharge != null) 'security_surcharge': securitySurcharge,
        if (oda != null) 'oda': oda,
        if (waybillFee != null) 'waybill_fee': waybillFee,
        if (bookingHandlingFee != null) 'booking_handling_fee': bookingHandlingFee,
        if (documentationFee != null) 'documentation_fee': documentationFee,
        if (participationFee != null) 'participation_fee': participationFee,
        if (permitFeesNonVat != null) 'permit_fees_non_vat': permitFeesNonVat,
        if (insurance != null) 'insurance': insurance,
        if (valuation != null) 'valuation': valuation,
        if (valuationType != null) 'valuation_type': valuationType,
        if (pickupFee != null) 'pickup_fee': pickupFee,
        if (deliveryFee != null) 'delivery_fee': deliveryFee,
        if (cratingFee != null) 'crating_fee': cratingFee,
        if (packingFee != null) 'packing_fee': packingFee,
        if (airThc != null) 'air_thc': airThc,
        if (seaThc != null) 'sea_thc': seaThc,
        if (arrastre != null) 'arrastre': arrastre,
        if (demurrageDetention != null) 'demurrage_detention': demurrageDetention,
        if (waitingTime != null) 'waiting_time': waitingTime,
        if (roadToll != null) 'road_toll': roadToll,
        if (othersNonVat != null) 'others_non_vat': othersNonVat,
        if (hazardousGoodsHandling != null) 'hazardous_goods_handling': hazardousGoodsHandling,
      };
}

@freezed
abstract class RatrixRate with _$RatrixRate {
  const factory RatrixRate({
    required String id,
    String? chargeCode,
    required String rateType, // 'publish' | 'custom'
    DateTime? rateExpiry,
    int? clientId,
    RatrixLookupOption? freightMode,
    RatrixLookupOption? serviceMode,
    RatrixLookupOption? chargeOption,
    RatrixLookupOption? chargeBasis,
    @Default(<RatrixRoute>[]) List<RatrixRoute> routes,
    RatrixAddons? addons,
    // Percentage markup used to derive each breakweight's `express_rate`
    // from its `rate` — see [RatrixBreakweight.expressRate].
    num? expressMarkup,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _RatrixRate;

  const RatrixRate._();

  static RatrixRate fromJson(Map<String, dynamic> json) => RatrixRate(
        id: json['id'].toString(),
        chargeCode: json['charge_code']?.toString(),
        rateType: (json['rate_type'] ?? 'publish').toString(),
        rateExpiry: DateTime.tryParse(json['rate_expiry']?.toString() ?? ''),
        clientId: _asInt(json['client_id']),
        expressMarkup: _asNum(json['express_markup']),
        freightMode: json['freight_mode'] is Map<String, dynamic>
            ? RatrixLookupOption.fromJson(json['freight_mode'] as Map<String, dynamic>)
            : null,
        serviceMode: json['service_mode'] is Map<String, dynamic>
            ? RatrixLookupOption.fromJson(json['service_mode'] as Map<String, dynamic>)
            : null,
        chargeOption: json['charge_option'] is Map<String, dynamic>
            ? RatrixLookupOption.fromJson(json['charge_option'] as Map<String, dynamic>)
            : null,
        chargeBasis: json['charge_basis'] is Map<String, dynamic>
            ? RatrixLookupOption.fromJson(json['charge_basis'] as Map<String, dynamic>)
            : null,
        routes: (json['routes'] as List<dynamic>? ?? const [])
            .whereType<Map<String, dynamic>>()
            .map(RatrixRoute.fromJson)
            .toList(),
        addons: json['addons'] is Map<String, dynamic> ? RatrixAddons.fromJson(json['addons'] as Map<String, dynamic>) : null,
        createdAt: DateTime.tryParse(json['created_at']?.toString() ?? ''),
        updatedAt: DateTime.tryParse(json['updated_at']?.toString() ?? ''),
      );

  bool get isCustom => rateType == 'custom';

  bool get isExpired => rateExpiry != null && rateExpiry!.isBefore(DateTime.now());
}
