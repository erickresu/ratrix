import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/repositories/rates_repository.dart';
import '../../domain/entities/client_rate.dart';
import '../../domain/entities/ratrix_rate.dart';
import '../../domain/entities/rates_enums.dart';
import '../../domain/entities/rates_fk_ids.dart';

part 'shipping_calculator_event.dart';
part 'shipping_calculator_state.dart';

class ShippingCalculatorBloc
    extends Bloc<ShippingCalculatorEvent, ShippingCalculatorState> {
  ShippingCalculatorBloc(this._ratesRepository, {required String clientId})
    : _clientId = clientId,
      super(const ShippingCalculatorState()) {
    on<CalcRatesRequested>(_onRatesRequested);
    on<CalcRateCategoryChanged>(
      (event, emit) =>
          emit(state.copyWith(rateType: event.rateType, clearRateTable: true)),
    );
    on<CalcFreightModeChanged>(
      (event, emit) =>
          emit(state.copyWith(freightMode: event.mode, clearRateTable: true)),
    );
    on<CalcServiceModeChanged>(
      (event, emit) =>
          emit(state.copyWith(serviceMode: event.mode, clearRateTable: true)),
    );
    on<CalcServiceLevelChanged>(
      (event, emit) => emit(state.copyWith(serviceLevel: event.level)),
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
    on<CalcLengthChanged>(
      (event, emit) =>
          emit(state.copyWith(length: event.value, clearCalcResult: true)),
    );
    on<CalcWidthChanged>(
      (event, emit) =>
          emit(state.copyWith(width: event.value, clearCalcResult: true)),
    );
    on<CalcHeightChanged>(
      (event, emit) =>
          emit(state.copyWith(height: event.value, clearCalcResult: true)),
    );
    on<CalcDivisorChanged>(
      (event, emit) =>
          emit(state.copyWith(divisor: event.value, clearCalcResult: true)),
    );
    on<CalcWeightChanged>(
      (event, emit) =>
          emit(state.copyWith(weight: event.value, clearCalcResult: true)),
    );
    on<CalcDeclaredValueChanged>(
      (event, emit) => emit(
        state.copyWith(declaredValue: event.value, clearCalcResult: true),
      ),
    );
    on<CalcChargeBasisChanged>((event, emit) {
      // Recompute in place rather than clearing the result — the breakdown
      // popup keeps this switch live, so toggling it shouldn't dismiss the
      // dialog the user is looking at.
      emit(state.copyWith(chargeBasis: event.basis));
      if (state.calcResult != null)
        emit(state.copyWith(calcResult: _calculate()));
    });
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
    on<CalcFormReset>(
      (event, emit) =>
          emit(ShippingCalculatorState(clientRates: state.clientRates)),
    );

    add(const CalcRatesRequested());
  }

  final RatesRepository _ratesRepository;
  final String _clientId;

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
    if (state.selectedChargeCode == null ||
        state.origin.isEmpty ||
        state.destination.isEmpty ||
        state.weight.trim().isEmpty) {
      emit(
        state.copyWith(
          submitError:
              'Select a rate table, origin, destination, and weight before calculating.',
        ),
      );
      return;
    }

    emit(state.copyWith(clearSubmitError: true, calcResult: _calculate()));
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

    final actualWeight = num.tryParse(state.weight.trim());
    if (actualWeight == null)
      return const CalcResult(error: 'Enter a valid weight.');

    final length = num.tryParse(state.length.trim()) ?? 0;
    final width = num.tryParse(state.width.trim()) ?? 0;
    final height = num.tryParse(state.height.trim()) ?? 0;
    final divisor = num.tryParse(state.divisor.trim());
    final cbm = (length * width * height) / 1000000;
    final volumetricWeight = (divisor != null && divisor > 0)
        ? (length * width * height) / divisor
        : 0;

    final chargeableWeight = switch (state.chargeBasis) {
      CalcChargeBasis.actual => actualWeight,
      CalcChargeBasis.volumetric => volumetricWeight,
      CalcChargeBasis.higher =>
        actualWeight > volumetricWeight ? actualWeight : volumetricWeight,
    };

    final tiers = [...route.breakweights]
      ..sort((a, b) => a.min.compareTo(b.min));

    final freight = _freightFor(pricingOption, tiers, route, chargeableWeight);
    if (freight.error != null) {
      return CalcResult(
        actualWeight: actualWeight,
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
      addFlat('Delivery fee', addons.deliveryFee);
      addFlat('Crating fee', addons.cratingFee);
      addFlat('Packing fee', addons.packingFee);
      addFlat(
        'THC',
        rate.freightMode?.code == 'SEA' ? addons.seaThc : addons.airThc,
      );
      addFlat('Demurrage/detention', addons.demurrageDetention);
      addFlat('Hazardous goods handling', addons.hazardousGoodsHandling);
      addFlat('Other fees', addons.othersNonVat);
    }

    final subTotal =
        baseFreight +
        fuelSurcharge +
        flatFees.values.fold<num>(0, (sum, v) => sum + v);

    return CalcResult(
      actualWeight: actualWeight,
      volumetricWeight: volumetricWeight,
      cbm: cbm,
      chargeableWeight: chargeableWeight,
      matchedTierMin: freight.tierMin,
      matchedTierMax: freight.tierMax,
      tierRate: freight.tierRate,
      baseFreight: baseFreight,
      fuelSurcharge: fuelSurcharge,
      flatFees: flatFees,
      subTotal: subTotal,
    );
  }

  /// Resolves one of the 7 breakweight pricing formulas against
  /// [chargeableWeight]. [tiers] must be sorted ascending by `min`. The 3
  /// For the 3 "Minimum …" variants, the first (lowest) breakweight
  /// bracket's `rate` is authored as a flat peso amount rather than a
  /// per-kg rate — it's a direct formula swap for that one bracket, not a
  /// floor/max comparison against the whole calculation. Every other
  /// bracket keeps its normal per-kg meaning.
  _FreightResult _freightFor(
    PricingOption pricingOption,
    List<RatrixBreakweight> tiers,
    RatrixRoute route,
    num chargeableWeight,
  ) {
    RatrixBreakweight? matchTier() {
      for (final bw in tiers) {
        if (chargeableWeight >= bw.min && chargeableWeight <= bw.max) return bw;
      }
      return null;
    }

    switch (pricingOption) {
      case PricingOption.fixedBreakweight:
        final tier = matchTier();
        if (tier == null) {
          return _FreightResult(
            error:
                'No breakweight tier covers ${chargeableWeight.toStringAsFixed(2)} kg for this route.',
          );
        }
        return _FreightResult(
          amount: chargeableWeight * tier.rate,
          tierMin: tier.min,
          tierMax: tier.max,
          tierRate: tier.rate,
        );

      case PricingOption.minimumFixedBreakweight:
        final tier = matchTier();
        if (tier == null) {
          return _FreightResult(
            error:
                'No breakweight tier covers ${chargeableWeight.toStringAsFixed(2)} kg for this route.',
          );
        }
        // Within the first bracket: flat fee, no matter how light. Beyond
        // it: normal per-kg fixed pricing, same as the non-minimum variant.
        final amount = identical(tier, tiers.first)
            ? tier.rate
            : chargeableWeight * tier.rate;
        return _FreightResult(
          amount: amount,
          tierMin: tier.min,
          tierMax: tier.max,
          tierRate: tier.rate,
        );

      case PricingOption.flatBreakweight:
        final tier = matchTier();
        if (tier == null) {
          return _FreightResult(
            error:
                'No breakweight tier covers ${chargeableWeight.toStringAsFixed(2)} kg for this route.',
          );
        }
        return _FreightResult(
          amount: tier.rate,
          tierMin: tier.min,
          tierMax: tier.max,
          tierRate: tier.rate,
        );

      case PricingOption.cummulativeBreakweight:
        if (tiers.isEmpty || chargeableWeight > tiers.last.max) {
          return _FreightResult(
            error:
                'No breakweight tier covers ${chargeableWeight.toStringAsFixed(2)} kg for this route.',
          );
        }
        num total = 0;
        for (final tier in tiers) {
          if (chargeableWeight <= tier.min) break;
          final portion =
              (chargeableWeight < tier.max ? chargeableWeight : tier.max) -
              tier.min;
          total += portion * tier.rate;
        }
        return _FreightResult(
          amount: total,
          tierMin: tiers.first.min,
          tierMax: chargeableWeight,
          tierRate: null,
        );

      case PricingOption.minimumCummulativeBreakweight:
        if (tiers.isEmpty || chargeableWeight > tiers.last.max) {
          return _FreightResult(
            error:
                'No breakweight tier covers ${chargeableWeight.toStringAsFixed(2)} kg for this route.',
          );
        }
        num total = 0;
        for (var i = 0; i < tiers.length; i++) {
          final tier = tiers[i];
          if (chargeableWeight <= tier.min) break;
          if (i == 0) {
            total += tier.rate; // flat entrance fee for the first bracket
          } else {
            final portion =
                (chargeableWeight < tier.max ? chargeableWeight : tier.max) -
                tier.min;
            total += portion * tier.rate;
          }
        }
        return _FreightResult(
          amount: total,
          tierMin: tiers.first.min,
          tierMax: chargeableWeight,
          tierRate: null,
        );

      // Excess and Minimum Excess compute identically — the base bracket's
      // rate is already a flat amount in both, so there's nothing for
      // "minimum" to change.
      case PricingOption.excessBreakweight:
      case PricingOption.minimumExcessBreakweight:
        final base = tiers.first;
        final excessRate = route.excessRate;
        num amount = base.rate;
        if (chargeableWeight > base.max) {
          if (excessRate == null) {
            return const _FreightResult(
              error:
                  'Route has no excess rate configured for this pricing option.',
            );
          }
          amount += (chargeableWeight - base.max) * excessRate;
        }
        return _FreightResult(
          amount: amount,
          tierMin: base.min,
          tierMax: base.max,
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
          error: '${pricingOption.label} isn\'t supported by the calculator yet.',
        );
    }
  }
}

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
