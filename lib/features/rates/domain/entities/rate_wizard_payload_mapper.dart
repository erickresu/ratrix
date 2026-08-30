import 'location_option.dart';
import 'rates_enums.dart';
import 'rates_fk_ids.dart';

/// Builds the `POST/PUT api/rates` JSON body from `RateWizardState`.
///
/// Kept free of any bloc/state imports beyond what's needed for the field
/// types below so it can be unit tested independently; the wizard bloc
/// passes its own state fields in directly.
class RateWizardPayloadMapper {
  const RateWizardPayloadMapper._();

  /// `addonValues` short key -> API `addons` field name. Only the keys the
  /// API actually supports are mapped; `thc` is resolved separately below
  /// since it depends on `freightMode` (air -> air_thc, sea -> sea_thc).
  static const Map<String, String> _addonKeyToApiField = {
    'fuel': 'fuel_surcharge',
    'security': 'security_surcharge',
    'booking': 'booking_handling_fee',
    'documentation': 'documentation_fee',
    'permit': 'permit_fees_non_vat',
    'insurance': 'insurance',
    'valuation': 'valuation',
    'waybill': 'waybill_fee',
    'delivery': 'delivery_fee',
    'crating': 'crating_fee',
    'packing': 'packing_fee',
    'demurrage': 'demurrage_detention',
    'hazardous': 'hazardous_goods_handling',
    'othersNonVat': 'others_non_vat',
    'arrastre': 'arrastre',
  };

  /// Only these addon keys have an API `_type` (exact/percentage) field.
  static const Map<String, String> _addonModeKeyToApiField = {
    'fuel': 'fuel_surcharge_type',
    'valuation': 'valuation_type',
  };

  /// Builds one API `routes[]` entry from a matrix row + the shared
  /// breakweight columns. Every row shares the same breakweight set in the
  /// wizard UI, so `MatrixRow.rates[i]` pairs with `breakweights[i]`
  /// losslessly.
  ///
  /// [originOption]/[destinationOption] carry whichever geography id
  /// actually applies (city/province/region/island/barangay) from the
  /// picked search result (or, in edit mode, reconstructed from the loaded
  /// route's address) — these are sent as the real `*_id` fields the
  /// backend's `Address` model reads. The backend has no "reuse an existing
  /// address by id" path at all (`RatrixRateController::store`/`update` both
  /// call `Address::create(...)` unconditionally for every route, and
  /// `update()` deletes and recreates all routes first), so there is no
  /// benefit to resending a route's own id here — only the geography ids +
  /// label matter, every time.
  static Map<String, dynamic> _mapRoute({
    required String origin,
    required String destination,
    required List<String> rates,
    required List<String> expressRates,
    required List<({String min, String max})> breakweightBounds,
    LocationOption? originOption,
    LocationOption? destinationOption,
  }) {
    final breakweights = <Map<String, dynamic>>[];
    for (var i = 0; i < breakweightBounds.length && i < rates.length; i++) {
      final min = num.tryParse(breakweightBounds[i].min);
      final max = num.tryParse(breakweightBounds[i].max);
      final rate = num.tryParse(rates[i]);
      if (min == null || max == null || rate == null) continue;
      final expressRate = i < expressRates.length ? num.tryParse(expressRates[i]) : null;
      breakweights.add({
        'breakweight_min': min,
        'breakweight_max': max,
        'rate': rate,
        if (expressRate != null) 'express_rate': expressRate,
      });
    }

    Map<String, dynamic> address(String label, LocationOption? option) => {
          if (option?.islandId != null) 'island_id': option!.islandId,
          if (option?.regionId != null) 'region_id': option!.regionId,
          if (option?.provinceId != null) 'province_id': option!.provinceId,
          if (option?.cityId != null) 'city_id': option!.cityId,
          if (option?.barangayId != null) 'barangay_id': option!.barangayId,
          if (option?.zipcode != null) 'zipcode': option!.zipcode,
          if (option?.address1 != null) 'address1': option!.address1,
          'label': label,
        };

    return {
      if (origin.trim().isNotEmpty) 'origin': address(origin.trim(), originOption),
      if (destination.trim().isNotEmpty) 'destination': address(destination.trim(), destinationOption),
      if (breakweights.isNotEmpty) 'breakweights': breakweights,
    };
  }

  static String? _thcAddonField(FreightMode? mode) => switch (mode) {
        FreightMode.air => 'air_thc',
        FreightMode.sea => 'sea_thc',
        // Land has no THC field in the API; there's no natural fallback,
        // so the "thc" addon value is simply omitted for land freight.
        FreightMode.land => null,
        null => null,
      };

  /// Builds the full `addons` object from the wizard's flat `addonValues`
  /// map. `oda`/`pickup_fee` bracket-config pricing (the "Conditional
  /// Add-ons" step) is NOT included — see the TODO in
  /// `RatesRepository`/this file's class doc for why.
  static Map<String, dynamic> mapAddons({
    required Map<String, String> addonValues,
    required Map<String, AddonMode> addonModes,
    required FreightMode? freightMode,
  }) {
    final addons = <String, dynamic>{};

    for (final entry in addonValues.entries) {
      final trimmed = entry.value.trim();
      if (trimmed.isEmpty) continue;
      final value = num.tryParse(trimmed);
      if (value == null) continue;

      if (entry.key == 'thc') {
        final field = _thcAddonField(freightMode);
        if (field != null) addons[field] = value;
        continue;
      }

      final apiField = _addonKeyToApiField[entry.key];
      if (apiField == null) continue; // unsupported/unknown key — skip.
      addons[apiField] = value;
    }

    for (final entry in addonModes.entries) {
      final apiField = _addonModeKeyToApiField[entry.key];
      if (apiField == null) continue;
      // Only attach the mode if the corresponding value was actually set.
      final hasValue = entry.key == 'fuel' ? addons.containsKey('fuel_surcharge') : addons.containsKey('valuation');
      if (!hasValue) continue;
      addons[apiField] = entry.value == AddonMode.percentage ? 'percentage' : 'exact';
    }

    return addons;
  }

  /// Full `POST/PUT api/rates` body.
  ///
  /// `matrixRows`/`breakweights` are the wizard's raw
  /// `List<MatrixRow>`/`List<Breakweight>` — typed loosely here (via the
  /// `rows`/`bwBounds` record lists) so this file stays free of a direct
  /// `MatrixRow`/bloc-state dependency; the wizard bloc adapts its state
  /// into these shapes when calling in. `LocationOption` (a peer domain
  /// entity, not bloc state) is used directly for the geography-id fields.
  static Map<String, dynamic> buildPayload({
    required bool isCustom,
    required String? clientId,
    required FreightMode? freightMode,
    required ServiceMode serviceMode,
    required ChargeBasis chargeBasis,
    required PricingOption pricingOption,
    required String? expressMarkup,
    required String fullChargeCode,
    required DateTime? expiryDate,
    required List<({String origin, String destination, List<String> rates, List<String> expressRates, LocationOption? originOption, LocationOption? destinationOption})> rows,
    required List<({String min, String max})> breakweightBounds,
    required Map<String, String> addonValues,
    required Map<String, AddonMode> addonModes,
  }) {
    final freightModeId = freightMode != null ? RatesFkIds.freightModeIds[freightMode] : null;
    final serviceModeId = RatesFkIds.serviceModeIds[serviceMode];
    final chargeBasisId = RatesFkIds.chargeBasisIds[chargeBasis];
    final chargeOptionId = RatesFkIds.chargeOptionIds[pricingOption];
    final expressMarkupValue = expressMarkup != null ? num.tryParse(expressMarkup) : null;

    final routes = [
      for (final row in rows)
        _mapRoute(
          origin: row.origin,
          destination: row.destination,
          rates: row.rates,
          expressRates: row.expressRates,
          breakweightBounds: breakweightBounds,
          originOption: row.originOption,
          destinationOption: row.destinationOption,
        ),
    ];

    final addons = mapAddons(addonValues: addonValues, addonModes: addonModes, freightMode: freightMode);

    return {
      if (fullChargeCode.trim().isNotEmpty) 'charge_code': fullChargeCode.trim(),
      'rate_type': isCustom ? 'custom' : 'publish',
      if (isCustom && expiryDate != null) 'rate_expiry': _formatDate(expiryDate),
      if (isCustom && clientId != null) 'client_id': int.tryParse(clientId),
      if (freightModeId != null) 'freight_mode_id': freightModeId,
      if (serviceModeId != null) 'service_mode_id': serviceModeId,
      if (chargeOptionId != null) 'charge_option_id': chargeOptionId,
      if (chargeBasisId != null) 'charge_basis_id': chargeBasisId,
      if (expressMarkupValue != null) 'express_markup': expressMarkupValue,
      'routes': routes,
      if (addons.isNotEmpty) 'addons': addons,
    };
  }

  static String _formatDate(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
}
