part of 'shipping_calculator_bloc.dart';

/// Distinct origin/destination pair pulled from a rate's routes.
typedef RouteChoice = ({String origin, String destination});

/// One piece's L x W x H — the cargo can have multiple pieces, each with
/// its own dimensions, and volumetric weight sums across all of them.
class CalcDimension extends Equatable {
  const CalcDimension({this.length = '', this.width = '', this.height = ''});

  final String length;
  final String width;
  final String height;

  CalcDimension copyWith({String? length, String? width, String? height}) {
    return CalcDimension(
      length: length ?? this.length,
      width: width ?? this.width,
      height: height ?? this.height,
    );
  }

  @override
  List<Object?> get props => [length, width, height];
}

/// Result of a breakweight pricing calculation — covers all 7 bracket-pricing
/// options (Fixed/Flat/Cumulative/Excess, each with a "Minimum …" floor
/// variant). [tierRate] is null for Cumulative variants, which span multiple
/// tiers rather than pricing off a single one.
class CalcResult extends Equatable {
  const CalcResult({
    this.volumetricWeight,
    this.cbm,
    this.chargeableWeight,
    this.matchedTierMin,
    this.matchedTierMax,
    this.tierRate,
    this.baseFreight,
    this.fuelSurcharge,
    this.flatFees = const {},
    this.nonVatableTotal = 0,
    this.subTotal,
    this.error,
    this.routeTiers = const [],
  });

  final num? volumetricWeight;
  final num? cbm;
  final num? chargeableWeight;
  final num? matchedTierMin;
  final num? matchedTierMax;
  final num? tierRate;
  final num? baseFreight;
  final num? fuelSurcharge;
  final Map<String, num> flatFees;

  /// Portion of [subTotal] that's excluded from VAT — "Other fees"
  /// (`others_non_vat`), which the API itself names as non-VAT. Still part
  /// of the sub-total/grand total shown to the user, just not taxed.
  final num nonVatableTotal;

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
        volumetricWeight,
        cbm,
        chargeableWeight,
        matchedTierMin,
        matchedTierMax,
        tierRate,
        baseFreight,
        fuelSurcharge,
        flatFees,
        nonVatableTotal,
        subTotal,
        error,
        routeTiers,
      ];
}

enum VatMode { standard, exempt, zeroRated }

extension VatModeLabel on VatMode {
  /// BIR-required phrase for official receipts under RR 16-2005/TRAIN —
  /// exempt and zero-rated sales must print this on the document even
  /// though both compute the same ₱0 VAT. `null` for standard, which
  /// prints the usual Inclusive/Exclusive VAT status instead.
  String? get saleLabel => switch (this) {
        VatMode.exempt => 'VAT-Exempt Sale',
        VatMode.zeroRated => 'Zero-Rated Sale',
        VatMode.standard => null,
      };
}

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

  /// Whether the docked `FreightBreakdownPanel` (desktop) is allowed to
  /// actually show [calcResult] yet. [calcResult] itself is computed the
  /// instant Calculate is pressed — needed right away so the calculating
  /// popup's LCD tape has real numbers to type out — but the panel stays
  /// hidden behind that popup's blur until `CalcResultRevealed` fires
  /// (once the popup finishes or is skipped), so the answer doesn't show
  /// through before the popup does its thing.
  final bool calcResultRevealed;

  final bool roundedDisplay;
  final VatMode vatMode;
  final bool vatInclusive;

  final String origin;
  final String destination;

  /// What's actually billed — freely typed on the main screen, or filled in
  /// via the CBM popup's "Use this value" action (whichever of actual vs
  /// volumetric weight was higher there).
  final String weight;

  /// Bumped only when the CBM popup's "Use this value" overwrites [weight]
  /// externally — the weight field is keyed on this (not on [weight]
  /// itself) so it remounts and picks up the new value only for that case,
  /// not on every normal keystroke while typing.
  final int weightAppliedFromCbm;

  /// Scratch inputs for the CBM popup only — not read by pricing directly;
  /// the popup computes from these and the result is copied into [weight].
  final List<CalcDimension> dimensions;
  final String divisor;
  final String declaredValue;

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
    this.calcResultRevealed = false,
    this.roundedDisplay = false,
    this.vatMode = VatMode.standard,
    this.vatInclusive = false,
    this.origin = '',
    this.destination = '',
    this.weight = '',
    this.weightAppliedFromCbm = 0,
    this.dimensions = const [CalcDimension()],
    this.divisor = '6000',
    this.declaredValue = '',
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

  /// Whether the selected rate has an Express rate set on at least one
  /// breakweight bracket, on any route — gates the Express option in the
  /// Service Level picker, since a rate created with no Express column
  /// filled in has nothing to price against.
  bool get hasExpressRates =>
      selectedRate?.routes.any((r) => r.breakweights.any((bw) => bw.expressRate != null)) ?? false;

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

  /// Whether the form has enough filled in to actually compute a result —
  /// shared by the bloc (to decide whether to compute or surface
  /// [ShippingCalculatorBloc._onSubmitRequested]'s inline error) and the UI
  /// (to decide whether pressing Calculate should open the result popup at
  /// all, or just trigger that inline error).
  bool get canSubmit =>
      selectedChargeCode != null &&
      origin.isNotEmpty &&
      destination.isNotEmpty &&
      weight.trim().isNotEmpty;

  /// Sum of `(L × W × H) / divisor` across every dimension entry in the CBM
  /// popup — `null` when the divisor isn't a usable positive number yet.
  /// Popup-only preview; pricing itself reads [weight] directly, not this.
  num? get popupVolumetricWeight {
    final divisor = num.tryParse(this.divisor.trim());
    if (divisor == null || divisor <= 0) return null;
    num total = 0;
    for (final d in dimensions) {
      final length = num.tryParse(d.length.trim()) ?? 0;
      final width = num.tryParse(d.width.trim()) ?? 0;
      final height = num.tryParse(d.height.trim()) ?? 0;
      total += (length * width * height) / divisor;
    }
    return total;
  }

  static const vatRate = 0.12;

  /// VAT amount on top of [CalcResult.subTotal], per the current VAT
  /// toggles — 0 for Exempt/Zero Rated, or 12% of the VATable base for
  /// Exclusive, or the VAT already folded into an Inclusive VATable base
  /// (backed out via base / 1.12 * 0.12) for Inclusive. The base excludes
  /// [CalcResult.nonVatableTotal] ("Other fees" / others_non_vat) — that
  /// portion is never taxed, even though it's still part of the sub-total
  /// shown to the user.
  num get vatAmount {
    final result = calcResult;
    if (result?.subTotal == null || vatMode != VatMode.standard) return 0;
    final vatableBase = result!.subTotal! - result.nonVatableTotal;
    return vatInclusive ? vatableBase - (vatableBase / (1 + vatRate)) : vatableBase * vatRate;
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
    bool? calcResultRevealed,
    bool? roundedDisplay,
    VatMode? vatMode,
    bool? vatInclusive,
    String? origin,
    String? destination,
    String? weight,
    int? weightAppliedFromCbm,
    List<CalcDimension>? dimensions,
    String? divisor,
    String? declaredValue,
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
      calcResultRevealed: calcResultRevealed ?? this.calcResultRevealed,
      roundedDisplay: roundedDisplay ?? this.roundedDisplay,
      vatMode: vatMode ?? this.vatMode,
      vatInclusive: vatInclusive ?? this.vatInclusive,
      origin: clearRateTable ? '' : (origin ?? this.origin),
      destination: clearRateTable ? '' : (destination ?? this.destination),
      weight: weight ?? this.weight,
      weightAppliedFromCbm: weightAppliedFromCbm ?? this.weightAppliedFromCbm,
      dimensions: dimensions ?? this.dimensions,
      divisor: divisor ?? this.divisor,
      declaredValue: declaredValue ?? this.declaredValue,
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
        calcResultRevealed,
        roundedDisplay,
        vatMode,
        vatInclusive,
        origin,
        destination,
        weight,
        weightAppliedFromCbm,
        dimensions,
        divisor,
        declaredValue,
        resultComputed,
        submitError,
      ];
}
