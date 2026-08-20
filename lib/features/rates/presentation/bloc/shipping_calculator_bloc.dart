import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/repositories/rates_repository.dart';
import '../../domain/entities/client_rate.dart';
import '../../domain/entities/rates_enums.dart';

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
    on<CalcRateTableChanged>((event, emit) => emit(state.copyWith(selectedChargeCode: event.chargeCode)));
    on<CalcOriginChanged>((event, emit) => emit(state.copyWith(origin: event.value)));
    on<CalcDestinationChanged>((event, emit) => emit(state.copyWith(destination: event.value)));
    on<CalcLengthChanged>((event, emit) => emit(state.copyWith(length: event.value)));
    on<CalcWidthChanged>((event, emit) => emit(state.copyWith(width: event.value)));
    on<CalcHeightChanged>((event, emit) => emit(state.copyWith(height: event.value)));
    on<CalcDivisorChanged>((event, emit) => emit(state.copyWith(divisor: event.value)));
    on<CalcWeightChanged>((event, emit) => emit(state.copyWith(weight: event.value)));
    on<CalcDeclaredValueChanged>((event, emit) => emit(state.copyWith(declaredValue: event.value)));
    on<CalcChargeBasisChanged>((event, emit) => emit(state.copyWith(chargeBasis: event.basis)));
    on<CalcSubmitRequested>(_onSubmitRequested);

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

  Future<void> _onSubmitRequested(CalcSubmitRequested event, Emitter<ShippingCalculatorState> emit) async {
    // Calculation isn't wired to a live endpoint yet — this just validates
    // the minimum required fields are present. Swap in the real API call
    // once the freight-calculation endpoint contract is known.
    if (state.selectedChargeCode == null || state.weight.trim().isEmpty) {
      emit(state.copyWith(submitError: 'Select a rate table and enter a weight before calculating.'));
      return;
    }
    emit(state.copyWith(clearSubmitError: true, resultComputed: true));
  }
}
