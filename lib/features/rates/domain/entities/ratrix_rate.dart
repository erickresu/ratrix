// Domain entities mirroring the real `api/rates` JSON shape from the
// CerroV5 backend (see `ratrix_rates`/`ratrix_routes`/`ratrix_addons`
// tables). Plain classes with `fromJson`/`toJson`, matching the style of
// `lib/features/clients/domain/entities/client.dart`.

class RatrixLookupOption {
  const RatrixLookupOption({required this.id, required this.name, this.code});

  final int id;
  final String name;
  final String? code;

  factory RatrixLookupOption.fromJson(Map<String, dynamic> json) => RatrixLookupOption(
        id: json['id'] as int,
        name: (json['name'] ?? '').toString(),
        code: json['code']?.toString(),
      );
}

class RatrixAddress {
  const RatrixAddress({
    this.cityId,
    this.provinceId,
    this.regionId,
    this.islandId,
    this.barangayId,
    this.zipcode,
    this.label,
    this.address1,
  });

  final int? cityId;
  final int? provinceId;
  final int? regionId;
  final int? islandId;
  final int? barangayId;
  final String? zipcode;
  final String? label;
  final String? address1;

  factory RatrixAddress.fromJson(Map<String, dynamic> json) => RatrixAddress(
        cityId: json['city_id'] as int?,
        provinceId: json['province_id'] as int?,
        regionId: json['region_id'] as int?,
        islandId: json['island_id'] as int?,
        barangayId: json['barangay_id'] as int?,
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

class RatrixBreakweight {
  const RatrixBreakweight({required this.min, required this.max, required this.rate});

  final num min;
  final num max;
  final num rate;

  factory RatrixBreakweight.fromJson(Map<String, dynamic> json) => RatrixBreakweight(
        min: (json['breakweight_min'] as num?) ?? 0,
        max: (json['breakweight_max'] as num?) ?? 0,
        rate: (json['rate'] as num?) ?? 0,
      );

  Map<String, dynamic> toJson() => {
        'breakweight_min': min,
        'breakweight_max': max,
        'rate': rate,
      };
}

class RatrixRoute {
  const RatrixRoute({
    this.id,
    this.vehicleTypeId,
    this.containerSizeId,
    this.frequencyBasisId,
    this.minDistance,
    this.maxDistance,
    this.numberOfTrips,
    this.excessRate,
    this.timeInHours,
    this.rate,
    this.breakweights = const [],
    this.origin,
    this.destination,
  });

  final String? id;
  final int? vehicleTypeId;
  final int? containerSizeId;
  final int? frequencyBasisId;
  final num? minDistance;
  final num? maxDistance;
  final int? numberOfTrips;
  final num? excessRate;
  final num? timeInHours;
  final num? rate;
  final List<RatrixBreakweight> breakweights;
  final RatrixAddress? origin;
  final RatrixAddress? destination;

  factory RatrixRoute.fromJson(Map<String, dynamic> json) => RatrixRoute(
        id: json['id']?.toString(),
        vehicleTypeId: json['vehicle_type_id'] as int?,
        containerSizeId: json['container_size_id'] as int?,
        frequencyBasisId: json['frequency_basis_id'] as int?,
        minDistance: json['min_distance'] as num?,
        maxDistance: json['max_distance'] as num?,
        numberOfTrips: json['number_of_trips'] as int?,
        excessRate: json['excess_rate'] as num?,
        timeInHours: json['time_in_hours'] as num?,
        rate: json['rate'] as num?,
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

class RatrixAddons {
  const RatrixAddons({
    this.baseFreightRate,
    this.fuelSurcharge,
    this.fuelSurchargeType,
    this.securitySurcharge,
    this.oda,
    this.waybillFee,
    this.bookingHandlingFee,
    this.documentationFee,
    this.participationFee,
    this.permitFeesNonVat,
    this.insurance,
    this.valuation,
    this.valuationType,
    this.pickupFee,
    this.deliveryFee,
    this.cratingFee,
    this.packingFee,
    this.airThc,
    this.seaThc,
    this.arrastre,
    this.demurrageDetention,
    this.waitingTime,
    this.roadToll,
    this.othersNonVat,
    this.hazardousGoodsHandling,
  });

  final num? baseFreightRate;
  final num? fuelSurcharge;
  final String? fuelSurchargeType;
  final num? securitySurcharge;
  final num? oda;
  final num? waybillFee;
  final num? bookingHandlingFee;
  final num? documentationFee;
  final num? participationFee;
  final num? permitFeesNonVat;
  final num? insurance;
  final num? valuation;
  final String? valuationType;
  final num? pickupFee;
  final num? deliveryFee;
  final num? cratingFee;
  final num? packingFee;
  final num? airThc;
  final num? seaThc;
  final num? arrastre;
  final num? demurrageDetention;
  final num? waitingTime;
  final num? roadToll;
  final num? othersNonVat;
  final num? hazardousGoodsHandling;

  factory RatrixAddons.fromJson(Map<String, dynamic> json) => RatrixAddons(
        baseFreightRate: json['base_freight_rate'] as num?,
        fuelSurcharge: json['fuel_surcharge'] as num?,
        fuelSurchargeType: json['fuel_surcharge_type']?.toString(),
        securitySurcharge: json['security_surcharge'] as num?,
        // `oda`/`pickup_fee` can also be a bracket-config object — only the
        // flat-decimal form is supported here (see repository TODO).
        oda: json['oda'] is num ? json['oda'] as num : null,
        waybillFee: json['waybill_fee'] as num?,
        bookingHandlingFee: json['booking_handling_fee'] as num?,
        documentationFee: json['documentation_fee'] as num?,
        participationFee: json['participation_fee'] as num?,
        permitFeesNonVat: json['permit_fees_non_vat'] as num?,
        insurance: json['insurance'] as num?,
        valuation: json['valuation'] as num?,
        valuationType: json['valuation_type']?.toString(),
        pickupFee: json['pickup_fee'] is num ? json['pickup_fee'] as num : null,
        deliveryFee: json['delivery_fee'] as num?,
        cratingFee: json['crating_fee'] as num?,
        packingFee: json['packing_fee'] as num?,
        airThc: json['air_thc'] as num?,
        seaThc: json['sea_thc'] as num?,
        arrastre: json['arrastre'] as num?,
        demurrageDetention: json['demurrage_detention'] as num?,
        waitingTime: json['waiting_time'] as num?,
        roadToll: json['road_toll'] as num?,
        othersNonVat: json['others_non_vat'] as num?,
        hazardousGoodsHandling: json['hazardous_goods_handling'] as num?,
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

class RatrixRate {
  const RatrixRate({
    required this.id,
    this.chargeCode,
    required this.rateType,
    this.rateExpiry,
    this.clientId,
    this.freightMode,
    this.serviceMode,
    this.chargeOption,
    this.chargeBasis,
    this.routes = const [],
    this.addons,
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String? chargeCode;
  final String rateType; // 'publish' | 'custom'
  final DateTime? rateExpiry;
  final int? clientId;
  final RatrixLookupOption? freightMode;
  final RatrixLookupOption? serviceMode;
  final RatrixLookupOption? chargeOption;
  final RatrixLookupOption? chargeBasis;
  final List<RatrixRoute> routes;
  final RatrixAddons? addons;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  factory RatrixRate.fromJson(Map<String, dynamic> json) => RatrixRate(
        id: json['id'].toString(),
        chargeCode: json['charge_code']?.toString(),
        rateType: (json['rate_type'] ?? 'publish').toString(),
        rateExpiry: DateTime.tryParse(json['rate_expiry']?.toString() ?? ''),
        clientId: json['client_id'] as int?,
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
