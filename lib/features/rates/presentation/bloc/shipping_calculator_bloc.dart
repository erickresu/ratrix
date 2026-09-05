import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/repositories/rates_repository.dart';
import '../../domain/entities/client_rate.dart';
import '../../domain/entities/conditional_addon_config.dart';
import '../../domain/entities/ratrix_rate.dart';
import '../../domain/entities/rates_enums.dart';
import '../../domain/entities/rates_fk_ids.dart';

part 'shipping_calculator_event.dart';
part 'shipping_calculator_state.dart';

class ShippingCalculatorBloc
    extends Bloc<ShippingCalculatorEvent, ShippingCalculatorState> {
  ShippingCalculatorBloc(
    this._ratesRepository, {
    required String clientId,
    String? autoSelectChargeCode,
  }) : _clientId = clientId,
       _autoSelectChargeCode = autoSelectChargeCode,
       super(const ShippingCalculatorState()) {
    on<CalcRatesRequested>(_onRatesRequested);
    on<CalcRateCategoryChanged>(
      (event, emit) =>
          emit(state.copyWith(rateType: event.rateType, clearRateTable: true)),
    );
    on<CalcFreightModeChanged>(
      (event, emit) => emit(
        state.copyWith(
          freightMode: event.mode,
          // Sea freight prices by CBM (cubic meters), not kg — L×W×H in cm
          // over 1,000,000 gives m³ directly, vs air's usual /6000
          // volumetric-kg divisor.
          divisor: event.mode == FreightMode.sea ? '1000000' : '6000',
          clearRateTable: true,
        ),
      ),
    );
    on<CalcServiceModeChanged>(
      (event, emit) =>
          emit(state.copyWith(serviceMode: event.mode, clearRateTable: true)),
    );
    on<CalcServiceLevelChanged>(
      (event, emit) => emit(
        state.copyWith(serviceLevel: event.level, clearCalcResult: true),
      ),
    );
    on<CalcRateTableChanged>(_onRateTableChanged);
    on<CalcOriginChanged>(
      (event, emit) => emit(
        state.copyWith(
          origin: event.value,
          destination: '',
          clearCalcResult: true,
        ),
      ),
    );
    on<CalcDestinationChanged>(
      (event, emit) =>
          emit(state.copyWith(destination: event.value, clearCalcResult: true)),
    );
    // Dimension/divisor/actual-weight fields live only in the CBM popup —
    // they're scratch inputs for that calculator, not the priced value
    // itself, so changing them doesn't invalidate an existing calc result.
    on<CalcDimensionAdded>(
      (event, emit) => emit(
        state.copyWith(dimensions: [...state.dimensions, const CalcDimension()]),
      ),
    );
    on<CalcDimensionRemoved>((event, emit) {
      if (state.dimensions.length <= 1) return;
      emit(state.copyWith(dimensions: [...state.dimensions]..removeAt(event.index)));
    });
    on<CalcDimensionLengthChanged>(
      (event, emit) => _updateDimension(
        emit,
        event.index,
        (d) => d.copyWith(length: event.value),
      ),
    );
    on<CalcDimensionWidthChanged>(
      (event, emit) => _updateDimension(
        emit,
        event.index,
        (d) => d.copyWith(width: event.value),
      ),
    );
    on<CalcDimensionHeightChanged>(
      (event, emit) => _updateDimension(
        emit,
        event.index,
        (d) => d.copyWith(height: event.value),
      ),
    );
    on<CalcDimensionPackagesChanged>(
      (event, emit) => _updateDimension(
        emit,
        event.index,
        (d) => d.copyWith(packages: event.value),
      ),
    );
    on<CalcDivisorChanged>(
      (event, emit) => emit(state.copyWith(divisor: event.value)),
    );
    on<CalcWeightChanged>(
      (event, emit) =>
          emit(state.copyWith(weight: event.value, clearCalcResult: true)),
    );
    on<CalcCbmResultApplied>((event, emit) {
      final result = state.popupVolumetricWeight;
      if (result == null) return;
      emit(
        state.copyWith(
          weight: result.toStringAsFixed(2),
          weightAppliedFromCbm: state.weightAppliedFromCbm + 1,
          clearCalcResult: true,
        ),
      );
    });
    on<CalcDeclaredValueChanged>(
      (event, emit) => emit(
        state.copyWith(declaredValue: event.value, clearCalcResult: true),
      ),
    );
    on<CalcSubmitRequested>(_onSubmitRequested);
    on<CalcRoundedDisplayToggled>(
      (event, emit) => emit(state.copyWith(roundedDisplay: event.rounded)),
    );
    on<CalcVatModeChanged>(
      (event, emit) => emit(state.copyWith(vatMode: event.mode)),
    );
    on<CalcVatInclusiveToggled>(
      (event, emit) => emit(state.copyWith(vatInclusive: event.inclusive)),
    );
    on<CalcResultDismissed>(
      (event, emit) => emit(state.copyWith(clearCalcResult: true)),
    );
    on<CalcResultRevealed>(
      (event, emit) => emit(state.copyWith(calcResultRevealed: true)),
    );
    on<CalcFormReset>(
      (event, emit) =>
          emit(ShippingCalculatorState(clientRates: state.clientRates)),
    );

    add(const CalcRatesRequested());
  }

  final RatesRepository _ratesRepository;
  final String _clientId;

  /// Set when arriving here via a rate table's "Try in calculator" action —
  /// once `clientRates` loads, auto-selects the matching rate table instead
  /// of leaving the picker empty.
  final String? _autoSelectChargeCode;

  void _updateDimension(
    Emitter<ShippingCalculatorState> emit,
    int index,
    CalcDimension Function(CalcDimension) update,
  ) {
    final dimensions = [...state.dimensions];
    dimensions[index] = update(dimensions[index]);
    emit(state.copyWith(dimensions: dimensions));
  }

  Future<void> _onRatesRequested(
    CalcRatesRequested event,
    Emitter<ShippingCalculatorState> emit,
  ) async {
    emit(state.copyWith(ratesLoading: true));
    List<ClientRate> rates = const [];
    try {
      rates = await _ratesRepository.fetchClientRates(_clientId);
    } catch (_) {
      // Leave rates empty — the rate-table dropdown just shows no options.
    }
    emit(state.copyWith(clientRates: rates, ratesLoading: false));

    final target = _autoSelectChargeCode;
    if (target == null) return;
    ClientRate? match;
    for (final r in rates) {
      if (r.chargeCode == target) {
        match = r;
        break;
      }
    }
    if (match == null) return;
    // Match the rate's own freight/service mode first — `availableRateTables`
    // filters by those, so the dropdown needs to agree with what's selected
    // below or it'd show a table list that doesn't contain this rate.
    emit(state.copyWith(freightMode: match.freightMode, serviceMode: match.serviceMode));
    add(CalcRateTableChanged(match));
  }

  Future<void> _onRateTableChanged(
    CalcRateTableChanged event,
    Emitter<ShippingCalculatorState> emit,
  ) async {
    emit(
      state.copyWith(
        selectedChargeCode: event.rate.chargeCode,
        selectedRateId: event.rate.id,
        routesLoading: true,
        // A new rate may not have Express pricing set — don't carry over an
        // Express selection from whatever was picked before.
        serviceLevel: ServiceLevel.regular,
        clearCalcResult: true,
        // A different rate has its own routes/breakweights — the previous
        // origin/destination/weight/cargo details don't necessarily apply
        // to it, so start the input side over rather than leaving stale
        // values that look valid but weren't priced against this rate.
        origin: '',
        destination: '',
        weight: '',
        declaredValue: '',
        dimensions: const [CalcDimension()],
        // Respect the currently selected freight mode's default rather
        // than always resetting to air/land's 6000 — this fires whenever a
        // rate table is picked, which happens right after selecting a sea
        // freight mode and was clobbering that mode's 1,000,000 default.
        divisor: state.freightMode == FreightMode.sea ? '1000000' : '6000',
        resultComputed: false,
        clearSubmitError: true,
      ),
    );
    RatrixRate? fullRate;
    try {
      fullRate = await _ratesRepository.fetchRateById(event.rate.id);
    } catch (_) {
      // Leave selectedRate unset — Origin/Destination just show no options.
    }
    // Guard against a stale response landing after the user picked a
    // different rate table in the meantime.
    if (state.selectedRateId != event.rate.id) return;
    emit(state.copyWith(selectedRate: fullRate, routesLoading: false));
  }

  Future<void> _onSubmitRequested(
    CalcSubmitRequested event,
    Emitter<ShippingCalculatorState> emit,
  ) async {
    if (!state.canSubmit) {
      emit(
        state.copyWith(
          submitError:
              'Select a rate table, origin, destination, and weight before calculating.',
        ),
      );
      return;
    }

    emit(
      state.copyWith(
        clearSubmitError: true,
        calcResult: _calculate(),
        // Hidden again until the calculating popup reveals it — otherwise
        // a stale `true` from a previous calculation would let this new
        // result show through the docked panel before its own popup runs.
        calcResultRevealed: false,
      ),
    );
  }

  /// Computes freight for whichever of the 7 breakweight pricing options the
  /// selected rate uses, then adds the rate's addons on top. Chargeable
  /// weight and tier lookup are shared; only the tier(s)-to-freight formula
  /// differs per option — see `_freightFor`.
  CalcResult _calculate() {
    final rate = state.selectedRate;
    if (rate == null)
      return const CalcResult(
        error: 'Rate details not loaded — try reselecting the rate table.',
      );

    final pricingOption = rate.chargeOption?.id != null
        ? RatesFkIds.pricingOptionFromId[rate.chargeOption!.id]
        : null;
    if (pricingOption == null) {
      return const CalcResult(
        error: 'This rate has no recognized pricing option configured.',
      );
    }

    RatrixRoute? route;
    for (final r in rate.routes) {
      if (r.origin?.displayLabel == state.origin &&
          r.destination?.displayLabel == state.destination) {
        route = r;
        break;
      }
    }
    if (route == null || route.breakweights.isEmpty) {
      return const CalcResult(
        error: 'No breakweight tiers found for this route.',
      );
    }

    final chargeableWeight = num.tryParse(state.weight.trim());
    if (chargeableWeight == null)
      return const CalcResult(error: 'Enter a valid chargeable weight.');

    // Volumetric/CBM are informational only, sourced from the CBM popup's
    // scratch dimension fields — blank ("—" in the breakdown) unless the
    // user opened that popup at least once for this calculation.
    num cbm = 0;
    for (final d in state.dimensions) {
      final length = num.tryParse(d.length.trim()) ?? 0;
      final width = num.tryParse(d.width.trim()) ?? 0;
      final height = num.tryParse(d.height.trim()) ?? 0;
      final packages = num.tryParse(d.packages.trim()) ?? 1;
      cbm += (length * width * height) / 1000000 * packages;
    }
    final volumetricWeight = state.popupVolumetricWeight;

    final tiers = [...route.breakweights]
      ..sort((a, b) => a.min.compareTo(b.min));

    final freight = _freightFor(
      pricingOption,
      tiers,
      route,
      chargeableWeight,
      useExpress: state.serviceLevel == ServiceLevel.express,
    );
    if (freight.error != null) {
      return CalcResult(
        volumetricWeight: volumetricWeight,
        cbm: cbm,
        chargeableWeight: chargeableWeight,
        error: freight.error,
        routeTiers: tiers,
      );
    }

    final baseFreight = freight.amount!;

    final addons = rate.addons;
    num fuelSurcharge = 0;
    final flatFees = <String, num>{};
    if (addons != null) {
      void addFlat(String label, num? value) {
        if (value != null && value != 0) flatFees[label] = value;
      }

      if (addons.fuelSurcharge != null && addons.fuelSurcharge != 0) {
        fuelSurcharge = addons.fuelSurchargeType == 'percentage'
            ? baseFreight * (addons.fuelSurcharge! / 100)
            : addons.fuelSurcharge!;
      }
      addFlat('Security surcharge', addons.securitySurcharge);
      addFlat('Waybill fee', addons.waybillFee);
      addFlat('Booking/handling fee', addons.bookingHandlingFee);
      addFlat('Documentation fee', addons.documentationFee);
      addFlat('Permit fees', addons.permitFeesNonVat);
      addFlat('Insurance', addons.insurance);
      if (addons.valuation != null && addons.valuation != 0) {
        final declaredValue = num.tryParse(state.declaredValue.trim()) ?? 0;
        addFlat(
          'Valuation',
          // Percentage valuation is a percentage of the shipment's
          // declared value, not of the base freight (unlike fuel
          // surcharge, which IS a percentage of base freight).
          addons.valuationType == 'percentage'
              ? declaredValue * (addons.valuation! / 100)
              : addons.valuation,
        );
      }
      addFlat('Delivery fee', addons.deliveryFee);
      addFlat('Crating fee', addons.cratingFee);
      addFlat('Packing fee', addons.packingFee);
      addFlat(
        'THC',
        rate.freightMode?.code == 'SEA' ? addons.seaThc : addons.airThc,
      );
      addFlat('Demurrage/detention', addons.demurrageDetention);
      addFlat('Arrastre charge', addons.arrastre);
      addFlat('Hazardous goods handling', addons.hazardousGoodsHandling);
      addFlat('Other fees', addons.othersNonVat);
      // ODA/Pickup Fee: a plain decimal on the rate always wins; otherwise
      // auto-looked-up from the bracket-config against this route's
      // destination/origin (see _conditionalCharge).
      addFlat(
        'ODA',
        addons.oda ??
            _conditionalCharge(addons.odaConfig, route.destination, chargeableWeight),
      );
      addFlat(
        'Pickup fee',
        addons.pickupFee ??
            _conditionalCharge(addons.pickupFeeConfig, route.origin, chargeableWeight),
      );
    }

    final subTotal =
        baseFreight +
        fuelSurcharge +
        flatFees.values.fold<num>(0, (sum, v) => sum + v);

    // "Other fees" (others_non_vat) is still part of the sub-total but is
    // excluded from VAT — the API's own field name says non-VAT. Matched by
    // the same display label used above (addFlat('Other fees', ...)) so
    // this stays in sync without a second bookkeeping structure.
    final nonVatableTotal = flatFees['Other fees'] ?? 0;

    return CalcResult(
      volumetricWeight: volumetricWeight,
      cbm: cbm,
      chargeableWeight: chargeableWeight,
      matchedTierMin: freight.tierMin,
      matchedTierMax: freight.tierMax,
      tierRate: freight.tierRate,
      baseFreight: baseFreight,
      fuelSurcharge: fuelSurcharge,
      flatFees: flatFees,
      nonVatableTotal: nonVatableTotal,
      subTotal: subTotal,
    );
  }

  /// Resolves one of the 7 breakweight pricing formulas against
  /// [chargeableWeight]. [tiers] must be sorted ascending by `min`.
  /// For the 3 "Minimum …" variants, the first (lowest) breakweight
  /// bracket's `rate` is authored as a flat peso amount rather than a
  /// per-kg rate — it's a direct formula swap for that one bracket, not a
  /// floor/max comparison against the whole calculation. Every other
  /// bracket keeps its normal per-kg meaning.
  _FreightResult _freightFor(
    PricingOption pricingOption,
    List<RatrixBreakweight> tiers,
    RatrixRoute route,
    num chargeableWeight, {
    required bool useExpress,
  }) {
    // Express prices off `expressRate` per bracket, falling back to the
    // standard `rate` for any bracket that has no express rate set (e.g. the
    // rate was only partially filled in) — never null, never a hard error.
    num rateOf(RatrixBreakweight bw) =>
        useExpress ? (bw.expressRate ?? bw.rate) : bw.rate;

    RatrixBreakweight? matchTier() {
      for (final bw in tiers) {
        if (chargeableWeight >= bw.min && chargeableWeight <= bw.max) return bw;
      }
      return null;
    }

    switch (pricingOption) {
      case PricingOption.fixedBreakweight:
      case PricingOption.minimumFixedBreakweight:
      case PricingOption.flatBreakweight:
        final tier = matchTier();
        if (tier == null) return _noTierError(chargeableWeight);
        // flatBreakweight: always a flat per-tier fee. minimumFixedBreakweight:
        // flat fee only within the first (lowest) bracket, no matter how
        // light — beyond it, normal per-kg pricing like fixedBreakweight.
        final isFlat =
            pricingOption == PricingOption.flatBreakweight ||
            (pricingOption == PricingOption.minimumFixedBreakweight &&
                identical(tier, tiers.first));
        final tierRate = rateOf(tier);
        return _FreightResult(
          amount: isFlat ? tierRate : chargeableWeight * tierRate,
          tierMin: tier.min,
          tierMax: tier.max,
          tierRate: tierRate,
        );

      case PricingOption.cummulativeBreakweight:
      case PricingOption.minimumCummulativeBreakweight:
        if (tiers.isEmpty || chargeableWeight > tiers.last.max) {
          return _noTierError(chargeableWeight);
        }
        final isMinimum =
            pricingOption == PricingOption.minimumCummulativeBreakweight;
        num total = 0;
        for (var i = 0; i < tiers.length; i++) {
          final tier = tiers[i];
          if (chargeableWeight < tier.min) break;
          if (isMinimum && i == 0) {
            total += rateOf(tier); // flat entrance fee for the first bracket
          } else {
            // A bracket [min, max] is inclusive on both ends — e.g. [1, 50]
            // spans 50 kg, not 49 — so the portion already covered by earlier
            // brackets is (min - 1), not min. Using `min` directly undercounts
            // every bracket by 1 (e.g. 85kg over [1,50]@100 + [51,100]@95
            // should charge 50*100 + 35*95 = 8325, not 49*100 + 34*95 = 8130).
            final portion =
                (chargeableWeight < tier.max ? chargeableWeight : tier.max) -
                (tier.min - 1);
            total += portion * rateOf(tier);
          }
        }
        return _FreightResult(
          amount: total,
          tierMin: tiers.first.min,
          tierMax: chargeableWeight,
          tierRate: null,
        );

      // Excess: base bracket (tier 1) priced per-kg (chargeableWeight ×
      // rate) same as Fixed. Minimum Excess: base bracket is a flat fee
      // instead (no multiplier) — e.g. first 50kg = flat ₱4,500 regardless
      // of actual weight within it. In both cases, once chargeableWeight
      // exceeds the base bracket's max, whichever LATER breakweight tier's
      // [min, max] range actually covers the weight supplies the "excess"
      // per-kg rate — applied only to the portion beyond base.max, not the
      // whole weight (that portion is already covered by the base charge
      // above). There's no separate standalone excess-rate field: the
      // second/third/etc. breakweight tier's own `rate` IS the excess rate
      // for that range, same as how the wizard's "Add breakweight" already
      // lets a rate carry multiple tiers.
      case PricingOption.excessBreakweight:
      case PricingOption.minimumExcessBreakweight:
        final base = tiers.first;
        final isMinimum = pricingOption == PricingOption.minimumExcessBreakweight;
        final baseRate = rateOf(base);

        if (chargeableWeight <= base.max) {
          final amount = isMinimum ? baseRate : chargeableWeight * baseRate;
          return _FreightResult(
            amount: amount,
            tierMin: base.min,
            tierMax: base.max,
            tierRate: baseRate,
          );
        }

        final excessTier = matchTier();
        if (excessTier == null || identical(excessTier, base)) {
          return _noTierError(chargeableWeight);
        }
        final excessRate = rateOf(excessTier);
        final baseAmount = isMinimum ? baseRate : base.max * baseRate;
        final amount =
            baseAmount + (chargeableWeight - base.max) * excessRate;
        return _FreightResult(
          amount: amount,
          tierMin: base.min,
          tierMax: excessTier.max,
          tierRate: excessRate,
        );

      // Route-Based/Time-Based Pricing (Full Container Load) don't use
      // breakweight-tier math at all — no formula for either is
      // implemented yet, so surface a clear error instead of silently
      // running one of the breakweight formulas against the wrong pricing
      // model.
      case PricingOption.routeBased:
      case PricingOption.timeBased:
        return _FreightResult(
          error:
              '${pricingOption.label} isn\'t supported by the calculator yet.',
        );
    }
  }

  /// ODA/Pickup Fee auto-lookup: [config] is null when the rate has no
  /// bracket-config for this addon (nothing to charge). Otherwise, matches
  /// [location] (the selected route's destination for ODA, origin for
  /// Pickup Fee) against each configured entry's `locationId` — checked
  /// against every one of the address's own geography ids (city/province/
  /// region/island/barangay) rather than one fixed level, since the config
  /// was authored at whichever granularity its own `format` used. On a
  /// match, charges the breakweight tier [chargeableWeight] falls into at
  /// that tier's flat rate (no per-kg multiplication) — the only formula
  /// seen in practice (`charge_option: 3`, Flat Breakweight). No match, or
  /// weight outside every tier, means no charge — not an error, since ODA/
  /// Pickup Fee are conditional add-ons, not required pricing.
  num? _conditionalCharge(
    ConditionalAddonConfig? config,
    RatrixAddress? location,
    num chargeableWeight,
  ) {
    if (config == null || location == null) return null;
    final locationIds = {
      location.id,
      location.cityId,
      location.provinceId,
      location.regionId,
      location.islandId,
      location.barangayId,
    }..removeWhere((id) => id == null);
    if (locationIds.isEmpty) return null;

    for (final entry in config.routes) {
      if (entry.locationId == null || !locationIds.contains(entry.locationId)) {
        continue;
      }
      for (final tier in entry.breakweights) {
        if (chargeableWeight >= tier.min && chargeableWeight <= tier.max) {
          return tier.rate;
        }
      }
    }
    return null;
  }
}

_FreightResult _noTierError(num chargeableWeight) => _FreightResult(
  error:
      'No breakweight tier covers ${chargeableWeight.toStringAsFixed(2)} kg for this route.',
);

/// Internal result of one breakweight pricing formula — either an [amount]
/// (plus the tier bounds/rate to surface in [CalcResult]) or an [error].
class _FreightResult {
  const _FreightResult({
    this.amount,
    this.tierMin,
    this.tierMax,
    this.tierRate,
    this.error,
  });

  final num? amount;
  final num? tierMin;
  final num? tierMax;
  final num? tierRate;
  final String? error;
}
