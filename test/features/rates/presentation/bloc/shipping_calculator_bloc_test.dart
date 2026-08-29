import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:ratrix/features/rates/data/repositories/rates_repository.dart';
import 'package:ratrix/features/rates/domain/entities/client_rate.dart';
import 'package:ratrix/features/rates/domain/entities/ratrix_rate.dart';
import 'package:ratrix/features/rates/domain/entities/rates_enums.dart';
import 'package:ratrix/features/rates/domain/entities/rates_fk_ids.dart';
import 'package:ratrix/features/rates/presentation/bloc/shipping_calculator_bloc.dart';

class MockRatesRepository extends Mock implements RatesRepository {}

RatrixRate _buildRate({
  required int chargeOptionId,
  required List<RatrixBreakweight> breakweights,
  RatrixAddons? addons,
  String freightModeCode = 'AIR',
}) {
  return RatrixRate(
    id: 'rate-1',
    chargeCode: 'CC-1',
    rateType: 'custom',
    freightMode: RatrixLookupOption(id: 1, name: 'Air', code: freightModeCode),
    chargeOption: RatrixLookupOption(id: chargeOptionId, name: 'opt'),
    addons: addons,
    routes: [
      RatrixRoute(
        origin: const RatrixAddress(label: 'Manila'),
        destination: const RatrixAddress(label: 'Cebu'),
        breakweights: breakweights,
      ),
    ],
  );
}

const _clientRate = ClientRate(
  id: 'rate-1',
  clientId: 'c1',
  chargeCode: 'CC-1',
  freightMode: FreightMode.air,
  serviceMode: ServiceMode.doorToDoor,
  routeCount: 1,
  status: RateStatus.active,
  expiryLabel: 'Active',
);

void main() {
  late MockRatesRepository repository;

  setUp(() {
    repository = MockRatesRepository();
    when(
      () => repository.fetchClientRates(any()),
    ).thenAnswer((_) async => const <ClientRate>[]);
  });

  /// Builds a bloc, selects [rate]'s single Manila→Cebu route, and submits
  /// [weight] kg for pricing. Returns the resulting [CalcResult].
  Future<CalcResult> priceRoute(RatrixRate rate, String weight, {String declaredValue = ''}) async {
    when(() => repository.fetchRateById(any())).thenAnswer((_) async => rate);

    final bloc = ShippingCalculatorBloc(repository, clientId: 'c1');
    await bloc.stream.firstWhere((s) => !s.ratesLoading);

    bloc.add(const CalcRateTableChanged(_clientRate));
    await bloc.stream.firstWhere((s) => s.selectedRate != null);

    bloc.add(const CalcOriginChanged('Manila'));
    bloc.add(const CalcDestinationChanged('Cebu'));
    bloc.add(CalcWeightChanged(weight));
    if (declaredValue.isNotEmpty) {
      bloc.add(CalcDeclaredValueChanged(declaredValue));
    }
    bloc.add(const CalcSubmitRequested());
    await bloc.stream.firstWhere((s) => s.calcResult != null);

    final result = bloc.state.calcResult!;
    await bloc.close();
    return result;
  }

  group('fixedBreakweight', () {
    test('prices chargeableWeight * tier rate', () async {
      final rate = _buildRate(
        chargeOptionId: RatesFkIds.chargeOptionIds[PricingOption.fixedBreakweight]!,
        breakweights: const [RatrixBreakweight(min: 1, max: 50, rate: 100)],
      );
      final result = await priceRoute(rate, '30');
      expect(result.error, isNull);
      expect(result.baseFreight, 30 * 100);
    });

    test('errors when no bracket covers the weight', () async {
      final rate = _buildRate(
        chargeOptionId: RatesFkIds.chargeOptionIds[PricingOption.fixedBreakweight]!,
        breakweights: const [RatrixBreakweight(min: 1, max: 50, rate: 100)],
      );
      final result = await priceRoute(rate, '999');
      expect(result.baseFreight, isNull);
      expect(result.error, 'No breakweight tier covers 999.00 kg for this route.');
    });
  });

  group('minimumFixedBreakweight', () {
    final rate = _buildRate(
      chargeOptionId: RatesFkIds.chargeOptionIds[PricingOption.minimumFixedBreakweight]!,
      breakweights: const [
        RatrixBreakweight(min: 1, max: 50, rate: 100),
        RatrixBreakweight(min: 51, max: 100, rate: 90),
      ],
    );

    test('flat fee within the first bracket regardless of actual weight', () async {
      final result = await priceRoute(rate, '10');
      expect(result.baseFreight, 100);
    });

    test('normal per-kg pricing beyond the first bracket', () async {
      final result = await priceRoute(rate, '60');
      expect(result.baseFreight, 60 * 90);
    });
  });

  group('flatBreakweight', () {
    final rate = _buildRate(
      chargeOptionId: RatesFkIds.chargeOptionIds[PricingOption.flatBreakweight]!,
      breakweights: const [
        RatrixBreakweight(min: 1, max: 50, rate: 100),
        RatrixBreakweight(min: 51, max: 100, rate: 90),
      ],
    );

    test('always flat, even in a later bracket', () async {
      final result = await priceRoute(rate, '60');
      expect(result.baseFreight, 90);
    });
  });

  group('cummulativeBreakweight', () {
    // Worked example from the bloc's own inclusive-bracket comment: 85kg
    // over [1,50]@100 + [51,100]@95 should charge 50*100 + 35*95 = 8325.
    final rate = _buildRate(
      chargeOptionId: RatesFkIds.chargeOptionIds[PricingOption.cummulativeBreakweight]!,
      breakweights: const [
        RatrixBreakweight(min: 1, max: 50, rate: 100),
        RatrixBreakweight(min: 51, max: 100, rate: 95),
      ],
    );

    test('sums each bracket portion using inclusive bounds', () async {
      final result = await priceRoute(rate, '85');
      expect(result.baseFreight, 8325);
    });

    test('single-bracket weight charges only that bracket', () async {
      final result = await priceRoute(rate, '30');
      expect(result.baseFreight, 30 * 100);
    });

    test('errors beyond the last bracket', () async {
      final result = await priceRoute(rate, '150');
      expect(result.error, 'No breakweight tier covers 150.00 kg for this route.');
    });
  });

  group('minimumCummulativeBreakweight', () {
    final rate = _buildRate(
      chargeOptionId: RatesFkIds.chargeOptionIds[PricingOption.minimumCummulativeBreakweight]!,
      breakweights: const [
        RatrixBreakweight(min: 1, max: 50, rate: 100),
        RatrixBreakweight(min: 51, max: 100, rate: 95),
      ],
    );

    test('first bracket is a flat entrance fee, later brackets are per-kg portions', () async {
      final result = await priceRoute(rate, '85');
      // 100 (flat entrance) + 35*95 (portion of second bracket) = 3425.
      expect(result.baseFreight, 100 + 35 * 95);
    });
  });

  group('excessBreakweight', () {
    final rate = _buildRate(
      chargeOptionId: RatesFkIds.chargeOptionIds[PricingOption.excessBreakweight]!,
      breakweights: const [
        RatrixBreakweight(min: 1, max: 50, rate: 100),
        RatrixBreakweight(min: 51, max: 100, rate: 90),
      ],
    );

    test('within base bracket prices per-kg like Fixed', () async {
      final result = await priceRoute(rate, '30');
      expect(result.baseFreight, 30 * 100);
    });

    test('beyond base bracket adds the excess tier rate on the remainder only', () async {
      final result = await priceRoute(rate, '80');
      // Base bracket fully charged at its max (50*100) + 30kg excess at 90/kg.
      expect(result.baseFreight, 50 * 100 + 30 * 90);
    });
  });

  group('minimumExcessBreakweight', () {
    final rate = _buildRate(
      chargeOptionId: RatesFkIds.chargeOptionIds[PricingOption.minimumExcessBreakweight]!,
      breakweights: const [
        RatrixBreakweight(min: 1, max: 50, rate: 100),
        RatrixBreakweight(min: 51, max: 100, rate: 90),
      ],
    );

    test('base bracket is a flat fee, not multiplied by weight', () async {
      final result = await priceRoute(rate, '30');
      expect(result.baseFreight, 100);
    });

    test('excess portion still prices per-kg on top of the flat base', () async {
      final result = await priceRoute(rate, '80');
      expect(result.baseFreight, 100 + 30 * 90);
    });
  });

  group('addons', () {
    test('percentage fuel surcharge is a percentage of base freight', () async {
      final rate = _buildRate(
        chargeOptionId: RatesFkIds.chargeOptionIds[PricingOption.fixedBreakweight]!,
        breakweights: const [RatrixBreakweight(min: 1, max: 50, rate: 100)],
        addons: const RatrixAddons(fuelSurcharge: 10, fuelSurchargeType: 'percentage'),
      );
      final result = await priceRoute(rate, '30');
      expect(result.baseFreight, 3000);
      expect(result.fuelSurcharge, 3000 * 0.10);
    });

    test('percentage valuation is a percentage of declared value, not base freight', () async {
      final rate = _buildRate(
        chargeOptionId: RatesFkIds.chargeOptionIds[PricingOption.fixedBreakweight]!,
        breakweights: const [RatrixBreakweight(min: 1, max: 50, rate: 100)],
        addons: const RatrixAddons(valuation: 2, valuationType: 'percentage'),
      );
      final result = await priceRoute(rate, '30', declaredValue: '50000');
      expect(result.baseFreight, 3000);
      expect(result.flatFees['Valuation'], 50000 * 0.02);
    });
  });
}
