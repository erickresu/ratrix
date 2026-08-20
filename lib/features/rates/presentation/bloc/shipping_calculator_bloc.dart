import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/repositories/rates_repository.dart';
import '../../domain/entities/client_rate.dart';
import '../../domain/entities/ratrix_rate.dart';
import '../../domain/entities/rates_enums.dart';
import '../../domain/entities/rates_fk_ids.dart';

part 'shipping_calculator_event.dart';
part 'shipping_calculator_state.dart';

class ShippingCalculatorBloc extends Bloc<ShippingCalculatorEvent, ShippingCalculatorState> {
  ShippingCalculatorBloc(this._ratesRepository, {required String clientId})
      : _clientId = clientId,
        super(const ShippingCalculatorState()) {
    on<CalcRatesRequested>(_onRatesRequested);
    on<CalcRateCategoryChanged>((event, emit) => emit(state.copyWith(rateType: event.rateType, clearRateTable: true)));
    on<CalcFreightModeChanged>((event, emit) => emit(state.copyWith(freightMode: event.mode, clearRateTable: true)));
    on<CalcServiceModeChanged>((event, emit) => emit(state.copyWith(serviceMode: event.mode, clearRateTable: true)));
    on<CalcServiceLevelChanged>((event, emit) => emit(state.copyWith(serviceLevel: event.level)));
    on<CalcRateTableChanged>(_onRateTableChanged);
    on<CalcOriginChanged>(
      (event, emit) => emit(state.copyWith(origin: event.value, destination: '', clearCalcResult: true)),
    );
    on<CalcDestinationChanged>(
      (event, emit) => emit(state.copyWith(destination: event.value, clearCalcResult: true)),
    );
    on<CalcLengthChanged>((event, emit) => emit(state.copyWith(length: event.value, clearCalcResult: true)));
    on<CalcWidthChanged>((event, emit) => emit(state.copyWith(width: event.value, clearCalcResult: true)));
    on<CalcHeightChanged>((event, emit) => emit(state.copyWith(height: event.value, clearCalcResult: true)));
    on<CalcDivisorChanged>((event, emit) => emit(state.copyWith(divisor: event.value, clearCalcResult: true)));
    on<CalcWeightChanged>((event, emit) => emit(state.copyWith(weight: event.value, clearCalcResult: true)));
    on<CalcDeclaredValueChanged>(
      (event, emit) => emit(state.copyWith(declaredValue: event.value, clearCalcResult: true)),
    );
    on<CalcChargeBasisChanged>(
      (event, emit) => emit(state.copyWith(chargeBasis: event.basis, clearCalcResult: true)),
    );
    on<CalcSubmitRequested>(_onSubmitRequested);
    on<CalcRoundedDisplayToggled>((event, emit) => emit(state.copyWith(roundedDisplay: event.rounded)));
    on<CalcVatModeChanged>((event, emit) => emit(state.copyWith(vatMode: event.mode)));
    on<CalcVatInclusiveToggled>((event, emit) => emit(state.copyWith(vatInclusive: event.inclusive)));
    on<CalcResultDismissed>((event, emit) => emit(state.copyWith(clearCalcResult: true)));

    add(const CalcRatesRequested());
  }

  final RatesRepository _ratesRepository;
  final String _clientId;

  Future<void> _onRatesRequested(CalcRatesRequested event, Emitter<ShippingCalculatorState> emit) async {
    emit(state.copyWith(ratesLoading: true));
    List<ClientRate> rates = const [];
    try {
      rates = await _ratesRepository.fetchClientRates(_clientId);
    } catch (_) {
      // Leave rates empty — the rate-table dropdown just shows no options.
    }
    emit(state.copyWith(clientRates: rates, ratesLoading: false));
  }

  Future<void> _onRateTableChanged(CalcRateTableChanged event, Emitter<ShippingCalculatorState> emit) async {
    emit(state.copyWith(
      selectedChargeCode: event.rate.chargeCode,
      selectedRateId: event.rate.id,
      routesLoading: true,
    ));
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

  Future<void> _onSubmitRequested(CalcSubmitRequested event, Emitter<ShippingCalculatorState> emit) async {
    if (state.selectedChargeCode == null || state.origin.isEmpty || state.destination.isEmpty || state.weight.trim().isEmpty) {
      emit(state.copyWith(
        submitError: 'Select a rate table, origin, destination, and weight before calculating.',
      ));
      return;
    }

    emit(state.copyWith(clearSubmitError: true, calcResult: _calculate()));
  }

  /// Fixed Breakweight Pricing: chargeable weight × the breakweight tier
  /// whose [min, max] range contains it, plus a flat sum of the rate's
  /// addons (fuel surcharge applied as % of base freight if the rate's
  /// `fuel_surcharge_type` is percentage, otherwise as a flat add). Other
  /// pricing options aren't modeled — see `CalcResult.error`.
  CalcResult _calculate() {
    final rate = state.selectedRate;
    if (rate == null) return const CalcResult(error: 'Rate details not loaded — try reselecting the rate table.');

    final pricingOption = rate.chargeOption?.id != null ? RatesFkIds.pricingOptionFromId[rate.chargeOption!.id] : null;
    if (pricingOption != PricingOption.fixedBreakweight) {
      final label = pricingOption?.label ?? 'this rate\'s pricing option';
      return CalcResult(error: '$label isn\'t supported by the calculator yet — only Fixed Breakweight Pricing is.');
    }

    RatrixRoute? route;
    for (final r in rate.routes) {
      if (r.origin?.displayLabel == state.origin && r.destination?.displayLabel == state.destination) {
        route = r;
        break;
      }
    }
    if (route == null || route.breakweights.isEmpty) {
      return const CalcResult(error: 'No breakweight tiers found for this route.');
    }

    final actualWeight = num.tryParse(state.weight.trim());
    if (actualWeight == null) return const CalcResult(error: 'Enter a valid weight.');

    final length = num.tryParse(state.length.trim()) ?? 0;
    final width = num.tryParse(state.width.trim()) ?? 0;
    final height = num.tryParse(state.height.trim()) ?? 0;
    final divisor = num.tryParse(state.divisor.trim());
    final cbm = (length * width * height) / 1000000;
    final volumetricWeight = (divisor != null && divisor > 0) ? (length * width * height) / divisor : 0;

    final chargeableWeight = switch (state.chargeBasis) {
      CalcChargeBasis.actual => actualWeight,
      CalcChargeBasis.volumetric => volumetricWeight,
      CalcChargeBasis.higher => actualWeight > volumetricWeight ? actualWeight : volumetricWeight,
    };

    RatrixBreakweight? tier;
    for (final bw in route.breakweights) {
      if (chargeableWeight >= bw.min && chargeableWeight <= bw.max) {
        tier = bw;
        break;
      }
    }
    if (tier == null) {
      return CalcResult(
        actualWeight: actualWeight,
        volumetricWeight: volumetricWeight,
        cbm: cbm,
        chargeableWeight: chargeableWeight,
        error: 'No breakweight tier covers ${chargeableWeight.toStringAsFixed(2)} kg for this route.',
      );
    }

    final baseFreight = chargeableWeight * tier.rate;

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
      addFlat('THC', rate.freightMode?.code == 'SEA' ? addons.seaThc : addons.airThc);
      addFlat('Demurrage/detention', addons.demurrageDetention);
      addFlat('Hazardous goods handling', addons.hazardousGoodsHandling);
      addFlat('Other fees', addons.othersNonVat);
    }

    final subTotal = baseFreight + fuelSurcharge + flatFees.values.fold<num>(0, (sum, v) => sum + v);

    return CalcResult(
      actualWeight: actualWeight,
      volumetricWeight: volumetricWeight,
      cbm: cbm,
      chargeableWeight: chargeableWeight,
      matchedTierMin: tier.min,
      matchedTierMax: tier.max,
      tierRate: tier.rate,
      baseFreight: baseFreight,
      fuelSurcharge: fuelSurcharge,
      flatFees: flatFees,
      subTotal: subTotal,
    );
  }
}
