part of 'shipping_calculator_bloc.dart';

/// Distinct origin/destination pair pulled from a rate's routes.
typedef RouteChoice = ({String origin, String destination});

/// Result of a breakweight pricing calculation — covers all 7 bracket-pricing
/// options (Fixed/Flat/Cumulative/Excess, each with a "Minimum …" floor
/// variant). [tierRate] is null for Cumulative variants, which span multiple
/// tiers rather than pricing off a single one.
class CalcResult extends Equatable {
  const CalcResult({
    this.actualWeight,
    this.volumetricWeight,
    this.cbm,
    this.chargeableWeight,
    this.matchedTierMin,
    this.matchedTierMax,
    this.tierRate,
    this.baseFreight,
    this.fuelSurcharge,
    this.flatFees = const {},
    this.subTotal,
    this.error,
    this.routeTiers = const [],
  });

  final num? actualWeight;
  final num? volumetricWeight;
  final num? cbm;
  final num? chargeableWeight;
  final num? matchedTierMin;
  final num? matchedTierMax;
  final num? tierRate;
  final num? baseFreight;
  final num? fuelSurcharge;
  final Map<String, num> flatFees;

  /// The resolved route's breakweight brackets — populated whenever a route
  /// was found for the origin/destination, even on error (e.g. "no tier
  /// covers X kg"), so the error UI can show what brackets actually exist.
  final List<RatrixBreakweight> routeTiers;

  /// Base freight + fuel surcharge + flat fees, before VAT. VAT and rounding
  /// are applied on top of this at render time from the current toggle
  /// state, so changing those toggles doesn't require recomputing anything.
  final num? subTotal;

  /// Set instead of the numeric fields when the calculation couldn't be
  /// performed (e.g. non-Fixed-Breakweight pricing option, or no matching
  /// breakweight tier for the chargeable weight).
  final String? error;

  @override
  List<Object?> get props => [
        actualWeight,
        volumetricWeight,
        cbm,
        chargeableWeight,
        matchedTierMin,
        matchedTierMax,
        tierRate,
        baseFreight,
        fuelSurcharge,
        flatFees,
        subTotal,
        error,
        routeTiers,
      ];
}

enum VatMode { standard, exempt, zeroRated }

class ShippingCalculatorState extends Equatable {
  final RateType rateType;
  final FreightMode freightMode;
  final ServiceMode serviceMode;
  final ServiceLevel serviceLevel;

  final List<ClientRate> clientRates;
  final bool ratesLoading;
  final String? selectedChargeCode;
  final String? selectedRateId;

  /// Full rate record for the selected rate table — origin/destination
  /// choices and the calculation itself are both derived from its routes,
  /// addons, and pricing option, since only a route actually saved on this
  /// rate can be priced against it.
  final RatrixRate? selectedRate;
  final bool routesLoading;

  final CalcResult? calcResult;
  final bool roundedDisplay;
  final VatMode vatMode;
  final bool vatInclusive;

  final String origin;
  final String destination;

  final String length;
  final String width;
  final String height;
  final String divisor;
  final String weight;
  final String declaredValue;
  final CalcChargeBasis chargeBasis;

  final bool resultComputed;
  final String? submitError;

  const ShippingCalculatorState({
    this.rateType = RateType.custom,
    this.freightMode = FreightMode.air,
    this.serviceMode = ServiceMode.doorToDoor,
    this.serviceLevel = ServiceLevel.regular,
    this.clientRates = const [],
    this.ratesLoading = false,
    this.selectedChargeCode,
    this.selectedRateId,
    this.selectedRate,
    this.routesLoading = false,
    this.calcResult,
    this.roundedDisplay = false,
    this.vatMode = VatMode.standard,
    this.vatInclusive = false,
    this.origin = '',
    this.destination = '',
    this.length = '',
    this.width = '',
    this.height = '',
    this.divisor = '6000',
    this.weight = '',
    this.declaredValue = '',
    this.chargeBasis = CalcChargeBasis.higher,
    this.resultComputed = false,
    this.submitError,
  });

  /// Rate tables (charge codes) available for the currently selected
  /// freight mode + service mode — the calculator only offers a rate table
  /// that was actually saved under this exact combination, so it can't
  /// compute against a rate that doesn't apply to the selected scenario.
  List<ClientRate> get availableRateTables => clientRates
      .where((r) => r.freightMode == freightMode && r.serviceMode == serviceMode)
      .toList();

  /// Distinct origin/destination pairs actually saved on the selected rate
  /// table — the only choices Origin/Destination may offer, since pricing
  /// only exists for a route this specific rate defines.
  List<RouteChoice> get routeChoices {
    final seen = <String>{};
    final choices = <RouteChoice>[];
    for (final route in selectedRate?.routes ?? const <RatrixRoute>[]) {
      final origin = route.origin?.displayLabel;
      final destination = route.destination?.displayLabel;
      if (origin == null || destination == null) continue;
      final key = '$origin|$destination';
      if (!seen.add(key)) continue;
      choices.add((origin: origin, destination: destination));
    }
    return choices;
  }

  /// Breakweight brackets for the currently selected origin/destination
  /// route, sorted ascending by `min` — `[]` if no route is selected yet or
  /// none matches. Shared by the calc-error mini table and the Cargo
  /// Details "preview brackets" popup, so both read the same route.
  List<RatrixBreakweight> get selectedRouteTiers {
    for (final route in selectedRate?.routes ?? const <RatrixRoute>[]) {
      if (route.origin?.displayLabel == origin && route.destination?.displayLabel == destination) {
        return [...route.breakweights]..sort((a, b) => a.min.compareTo(b.min));
      }
    }
    return const [];
  }

  List<String> get availableOrigins => {for (final c in routeChoices) c.origin}.toList();

  List<String> get availableDestinations {
    if (origin.isEmpty) return {for (final c in routeChoices) c.destination}.toList();
    return {for (final c in routeChoices) if (c.origin == origin) c.destination}.toList();
  }

  /// True when the selected rate's pricing option is one of the 3 "Minimum
  /// …" breakweight variants — the first bracket's rate is a flat fee
  /// instead of per-kg for these (see `ShippingCalculatorBloc._freightFor`).
  bool get requiresMinimumCharge {
    final chargeOptionId = selectedRate?.chargeOption?.id;
    if (chargeOptionId == null) return false;
    final pricingOption = RatesFkIds.pricingOptionFromId[chargeOptionId];
    return const {
      PricingOption.minimumFixedBreakweight,
      PricingOption.minimumCummulativeBreakweight,
      PricingOption.minimumExcessBreakweight,
    }.contains(pricingOption);
  }

  static const vatRate = 0.12;

  /// VAT amount on top of [CalcResult.subTotal], per the current VAT
  /// toggles — 0 for Exempt/Zero Rated, or 12% of the sub-total for
  /// Exclusive, or the VAT already folded into an Inclusive sub-total
  /// (backed out via subTotal / 1.12 * 0.12) for Inclusive.
  num get vatAmount {
    final subTotal = calcResult?.subTotal;
    if (subTotal == null || vatMode != VatMode.standard) return 0;
    return vatInclusive ? subTotal - (subTotal / (1 + vatRate)) : subTotal * vatRate;
  }

  num get grandTotal {
    final subTotal = calcResult?.subTotal ?? 0;
    return vatInclusive ? subTotal : subTotal + vatAmount;
  }

  ShippingCalculatorState copyWith({
    RateType? rateType,
    FreightMode? freightMode,
    ServiceMode? serviceMode,
    ServiceLevel? serviceLevel,
    List<ClientRate>? clientRates,
    bool? ratesLoading,
    String? selectedChargeCode,
    bool clearRateTable = false,
    String? selectedRateId,
    RatrixRate? selectedRate,
    bool? routesLoading,
    CalcResult? calcResult,
    bool clearCalcResult = false,
    bool? roundedDisplay,
    VatMode? vatMode,
    bool? vatInclusive,
    String? origin,
    String? destination,
    String? length,
    String? width,
    String? height,
    String? divisor,
    String? weight,
    String? declaredValue,
    CalcChargeBasis? chargeBasis,
    bool? resultComputed,
    String? submitError,
    bool clearSubmitError = false,
  }) {
    return ShippingCalculatorState(
      rateType: rateType ?? this.rateType,
      freightMode: freightMode ?? this.freightMode,
      serviceMode: serviceMode ?? this.serviceMode,
      serviceLevel: serviceLevel ?? this.serviceLevel,
      clientRates: clientRates ?? this.clientRates,
      ratesLoading: ratesLoading ?? this.ratesLoading,
      selectedChargeCode: clearRateTable ? null : (selectedChargeCode ?? this.selectedChargeCode),
      selectedRateId: clearRateTable ? null : (selectedRateId ?? this.selectedRateId),
      selectedRate: clearRateTable ? null : (selectedRate ?? this.selectedRate),
      routesLoading: routesLoading ?? this.routesLoading,
      calcResult: clearCalcResult || clearRateTable ? null : (calcResult ?? this.calcResult),
      roundedDisplay: roundedDisplay ?? this.roundedDisplay,
      vatMode: vatMode ?? this.vatMode,
      vatInclusive: vatInclusive ?? this.vatInclusive,
      origin: clearRateTable ? '' : (origin ?? this.origin),
      destination: clearRateTable ? '' : (destination ?? this.destination),
      length: length ?? this.length,
      width: width ?? this.width,
      height: height ?? this.height,
      divisor: divisor ?? this.divisor,
      weight: weight ?? this.weight,
      declaredValue: declaredValue ?? this.declaredValue,
      chargeBasis: chargeBasis ?? this.chargeBasis,
      resultComputed: resultComputed ?? this.resultComputed,
      submitError: clearSubmitError ? null : (submitError ?? this.submitError),
    );
  }

  @override
  List<Object?> get props => [
        rateType,
        freightMode,
        serviceMode,
        serviceLevel,
        clientRates,
        ratesLoading,
        selectedChargeCode,
        selectedRateId,
        selectedRate,
        routesLoading,
        calcResult,
        roundedDisplay,
        vatMode,
        vatInclusive,
        origin,
        destination,
        length,
        width,
        height,
        divisor,
        weight,
        declaredValue,
        chargeBasis,
        resultComputed,
        submitError,
      ];
}
