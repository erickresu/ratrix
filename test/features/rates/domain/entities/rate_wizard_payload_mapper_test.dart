import 'package:flutter_test/flutter_test.dart';
import 'package:ratrix/features/rates/domain/entities/location_option.dart';
import 'package:ratrix/features/rates/domain/entities/rate_wizard_payload_mapper.dart';
import 'package:ratrix/features/rates/domain/entities/rates_enums.dart';
import 'package:ratrix/features/rates/domain/entities/rates_fk_ids.dart';

void main() {
  group('buildPayload', () {
    Map<String, dynamic> build({
      bool isCustom = false,
      String? clientId,
      FreightMode? freightMode = FreightMode.air,
      ServiceMode serviceMode = ServiceMode.doorToDoor,
      ChargeBasis chargeBasis = ChargeBasis.kilo,
      PricingOption pricingOption = PricingOption.fixedBreakweight,
      String fullChargeCode = 'ABC-123',
      DateTime? expiryDate,
      List<({String origin, String destination, List<String> rates, LocationOption? originOption, LocationOption? destinationOption})> rows = const [],
      List<({String min, String max})> breakweightBounds = const [],
      Map<String, String> addonValues = const {},
      Map<String, AddonMode> addonModes = const {},
    }) {
      return RateWizardPayloadMapper.buildPayload(
        isCustom: isCustom,
        clientId: clientId,
        freightMode: freightMode,
        serviceMode: serviceMode,
        chargeBasis: chargeBasis,
        pricingOption: pricingOption,
        fullChargeCode: fullChargeCode,
        expiryDate: expiryDate,
        rows: rows,
        breakweightBounds: breakweightBounds,
        addonValues: addonValues,
        addonModes: addonModes,
      );
    }

    test('maps enum fields to their real backend FK ids', () {
      final payload = build();
      expect(payload['freight_mode_id'], RatesFkIds.freightModeIds[FreightMode.air]);
      expect(payload['service_mode_id'], RatesFkIds.serviceModeIds[ServiceMode.doorToDoor]);
      expect(payload['charge_basis_id'], RatesFkIds.chargeBasisIds[ChargeBasis.kilo]);
      expect(payload['charge_option_id'], RatesFkIds.chargeOptionIds[PricingOption.fixedBreakweight]);
    });

    test('publish rate omits client_id and rate_expiry even if given', () {
      final payload = build(
        isCustom: false,
        clientId: '42',
        expiryDate: DateTime(2026, 3, 5),
      );
      expect(payload['rate_type'], 'publish');
      expect(payload.containsKey('client_id'), isFalse);
      expect(payload.containsKey('rate_expiry'), isFalse);
    });

    test('custom rate includes client_id and a zero-padded rate_expiry', () {
      final payload = build(
        isCustom: true,
        clientId: '42',
        expiryDate: DateTime(2026, 3, 5),
      );
      expect(payload['rate_type'], 'custom');
      expect(payload['client_id'], 42);
      expect(payload['rate_expiry'], '2026-03-05');
    });

    test('blank charge code is omitted, non-blank is trimmed', () {
      expect(build(fullChargeCode: '   ').containsKey('charge_code'), isFalse);
      expect(build(fullChargeCode: '  ABC-1  ')['charge_code'], 'ABC-1');
    });

    test('freight_mode_id is omitted when freight mode is unset', () {
      final payload = build(freightMode: null);
      expect(payload.containsKey('freight_mode_id'), isFalse);
    });

    test('zips each row\'s rates with the shared breakweight bounds', () {
      final payload = build(
        rows: const [
          (
            origin: 'Manila',
            destination: 'Cebu',
            rates: ['100', '95'],
            originOption: null,
            destinationOption: null,
          ),
        ],
        breakweightBounds: const [(min: '1', max: '50'), (min: '51', max: '100')],
      );
      final routes = payload['routes'] as List;
      expect(routes, hasLength(1));
      final breakweights = (routes.first as Map)['breakweights'] as List;
      expect(breakweights, [
        {'breakweight_min': 1, 'breakweight_max': 50, 'rate': 100},
        {'breakweight_min': 51, 'breakweight_max': 100, 'rate': 95},
      ]);
    });

    test('skips a breakweight slot with an unparseable rate rather than dropping the whole row', () {
      final payload = build(
        rows: const [
          (
            origin: 'Manila',
            destination: 'Cebu',
            rates: ['100', 'not-a-number'],
            originOption: null,
            destinationOption: null,
          ),
        ],
        breakweightBounds: const [(min: '1', max: '50'), (min: '51', max: '100')],
      );
      final route = (payload['routes'] as List).first as Map;
      final breakweights = route['breakweights'] as List;
      expect(breakweights, hasLength(1));
      expect(breakweights.single, {'breakweight_min': 1, 'breakweight_max': 50, 'rate': 100});
    });

    test('stops zipping at the shorter of rates vs breakweight bounds', () {
      final payload = build(
        rows: const [
          (
            origin: 'Manila',
            destination: 'Cebu',
            rates: ['100'],
            originOption: null,
            destinationOption: null,
          ),
        ],
        breakweightBounds: const [(min: '1', max: '50'), (min: '51', max: '100')],
      );
      final route = (payload['routes'] as List).first as Map;
      expect((route['breakweights'] as List), hasLength(1));
    });

    test('blank origin/destination are omitted from the route entry entirely', () {
      final payload = build(
        rows: const [
          (
            origin: '  ',
            destination: '  ',
            rates: <String>[],
            originOption: null,
            destinationOption: null,
          ),
        ],
      );
      final route = (payload['routes'] as List).first as Map;
      expect(route.containsKey('origin'), isFalse);
      expect(route.containsKey('destination'), isFalse);
    });

    test('sends the picked geography ids alongside the trimmed label', () {
      const origin = LocationOption(
        value: 'manila',
        label: 'Manila',
        cityId: 7,
        provinceId: 3,
        zipcode: '1000',
      );
      final payload = build(
        rows: [
          (
            origin: '  Manila  ',
            destination: 'Cebu',
            rates: <String>[],
            originOption: origin,
            destinationOption: null,
          ),
        ],
      );
      final route = (payload['routes'] as List).first as Map;
      expect(route['origin'], {
        'city_id': 7,
        'province_id': 3,
        'zipcode': '1000',
        'label': 'Manila',
      });
      // No geography ids picked for destination — only the label is sent.
      expect(route['destination'], {'label': 'Cebu'});
    });
  });

  group('mapAddons', () {
    test('maps a plain addon key to its API field', () {
      final addons = RateWizardPayloadMapper.mapAddons(
        addonValues: const {'fuel': '10'},
        addonModes: const {},
        freightMode: FreightMode.air,
      );
      expect(addons, {'fuel_surcharge': 10});
    });

    test('skips blank or unparseable values', () {
      final addons = RateWizardPayloadMapper.mapAddons(
        addonValues: const {'fuel': '  ', 'insurance': 'abc'},
        addonModes: const {},
        freightMode: FreightMode.air,
      );
      expect(addons, isEmpty);
    });

    test('skips an unknown addon key', () {
      final addons = RateWizardPayloadMapper.mapAddons(
        addonValues: const {'not_a_real_key': '5'},
        addonModes: const {},
        freightMode: FreightMode.air,
      );
      expect(addons, isEmpty);
    });

    test('thc resolves to air_thc for air freight and sea_thc for sea freight', () {
      final air = RateWizardPayloadMapper.mapAddons(
        addonValues: const {'thc': '20'},
        addonModes: const {},
        freightMode: FreightMode.air,
      );
      expect(air, {'air_thc': 20});

      final sea = RateWizardPayloadMapper.mapAddons(
        addonValues: const {'thc': '20'},
        addonModes: const {},
        freightMode: FreightMode.sea,
      );
      expect(sea, {'sea_thc': 20});
    });

    test('thc is omitted entirely for land freight, which has no thc field', () {
      final addons = RateWizardPayloadMapper.mapAddons(
        addonValues: const {'thc': '20'},
        addonModes: const {},
        freightMode: FreightMode.land,
      );
      expect(addons, isEmpty);
    });

    test('attaches the exact/percentage mode only when its value was actually set', () {
      final withValue = RateWizardPayloadMapper.mapAddons(
        addonValues: const {'fuel': '10'},
        addonModes: const {'fuel': AddonMode.percentage},
        freightMode: FreightMode.air,
      );
      expect(withValue, {'fuel_surcharge': 10, 'fuel_surcharge_type': 'percentage'});

      // No 'fuel' value at all — the mode flag must not be attached to a
      // field that was never set.
      final withoutValue = RateWizardPayloadMapper.mapAddons(
        addonValues: const {},
        addonModes: const {'fuel': AddonMode.percentage},
        freightMode: FreightMode.air,
      );
      expect(withoutValue, isEmpty);
    });

    test('exact mode is sent as the literal string "exact"', () {
      final addons = RateWizardPayloadMapper.mapAddons(
        addonValues: const {'valuation': '2'},
        addonModes: const {'valuation': AddonMode.exact},
        freightMode: FreightMode.air,
      );
      expect(addons, {'valuation': 2, 'valuation_type': 'exact'});
    });
  });
}
