import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/services/ph_locations_service.dart';
import '../../data/repositories/rates_repository.dart';
import '../../domain/entities/breakweight.dart';
import '../../domain/entities/matrix_row.dart';
import '../../domain/entities/rate_wizard_payload_mapper.dart';
import '../../domain/entities/rates_enums.dart';
import '../../domain/entities/rates_fk_ids.dart';

part 'rate_wizard_event.dart';
part 'rate_wizard_state.dart';

class RateWizardBloc extends Bloc<RateWizardEvent, RateWizardState> {
  RateWizardBloc({
    required bool isCustom,
    required PhLocationsService phLocationsService,
    required RatesRepository ratesRepository,
    String? clientId,
    String? clientName,
  })  : _phLocationsService = phLocationsService,
        _ratesRepository = ratesRepository,
        super(RateWizardState(isCustom: isCustom, clientId: clientId, clientName: clientName)) {
    on<WizardStepChanged>((event, emit) => emit(state.copyWith(step: event.step)));
    on<WizardNextStepRequested>((event, emit) {
      if (state.step < 3) emit(state.copyWith(step: state.step + 1));
    });
    on<WizardBackStepRequested>((event, emit) {
      if (state.step > 0) emit(state.copyWith(step: state.step - 1));
    });

    on<FreightModeChanged>((event, emit) {
      final validServiceModes = RatesFkIds.serviceModeOptionsByFreightMode[event.mode]!;
      final validChargeBases = RatesFkIds.chargeBasisOptionsByFreightMode[event.mode]!;
      emit(state.copyWith(
        freightMode: event.mode,
        serviceMode: validServiceModes.contains(state.serviceMode) ? state.serviceMode : validServiceModes.first,
        chargeBasis: validChargeBases.contains(state.chargeBasis) ? state.chargeBasis : validChargeBases.first,
      ));
    });
    on<ServiceModeChanged>((event, emit) => emit(state.copyWith(serviceMode: event.mode)));
    on<ChargeBasisChanged>((event, emit) => emit(state.copyWith(chargeBasis: event.basis)));
    on<PricingOptionChanged>((event, emit) => emit(state.copyWith(pricingOption: event.option)));
    on<ChargeCodeSuffixChanged>((event, emit) => emit(state.copyWith(chargeCodeSuffix: event.value)));
    on<ExpiryDateChanged>((event, emit) => emit(state.copyWith(expiryDate: event.date)));

    on<MatrixTabChanged>((event, emit) => emit(state.copyWith(matrixTab: event.tab)));
    on<MarkupChanged>((event, emit) => emit(state.copyWith(markup: event.value)));
    on<LocationBasisChanged>((event, emit) => emit(state.copyWith(locationBasis: event.basis)));

    on<RouteAdded>((event, emit) {
      final rates = List.filled(state.breakweights.length, '');
      emit(state.copyWith(matrixRows: [...state.matrixRows, MatrixRow(rates: rates)]));
    });
    on<RouteRemoveRequested>((event, emit) => emit(state.copyWith(removeRouteIndex: event.index)));
    on<RouteRemoveCancelled>((event, emit) => emit(state.copyWith(clearRemoveRouteIndex: true)));
    on<RouteRemoveConfirmed>((event, emit) {
      final index = state.removeRouteIndex;
      if (index == null) return;
      final rows = [...state.matrixRows]..removeAt(index);
      emit(state.copyWith(matrixRows: rows, clearRemoveRouteIndex: true));
    });

    on<OriginChanged>((event, emit) {
      final rows = state.matrixRows
          .asMap()
          .entries
          .map((e) => e.key == event.rowIndex ? e.value.copyWith(origin: event.value) : e.value)
          .toList();
      emit(state.copyWith(matrixRows: rows));
    });
    on<DestinationChanged>((event, emit) {
      final rows = state.matrixRows
          .asMap()
          .entries
          .map((e) => e.key == event.rowIndex ? e.value.copyWith(destination: event.value) : e.value)
          .toList();
      emit(state.copyWith(matrixRows: rows));
    });
    on<CellChanged>((event, emit) {
      final rows = state.matrixRows.asMap().entries.map((e) {
        if (e.key != event.rowIndex) return e.value;
        final rates = [...e.value.rates];
        rates[event.breakweightIndex] = event.value;
        return e.value.copyWith(rates: rates);
      }).toList();
      emit(state.copyWith(matrixRows: rows));
    });

    on<BreakweightAdded>((event, emit) {
      emit(state.copyWith(
        breakweights: [...state.breakweights, const Breakweight()],
        matrixRows: state.matrixRows.map((r) => r.copyWith(rates: [...r.rates, ''])).toList(),
      ));
    });
    on<BreakweightRemoved>((event, emit) {
      if (state.breakweights.length <= 1) return;
      emit(state.copyWith(
        breakweights: [...state.breakweights]..removeAt(event.index),
        matrixRows: state.matrixRows
            .map((r) => r.copyWith(rates: [...r.rates]..removeAt(event.index)))
            .toList(),
      ));
    });
    on<BreakweightMinChanged>((event, emit) {
      final list = state.breakweights
          .asMap()
          .entries
          .map((e) => e.key == event.index ? e.value.copyWith(min: event.value) : e.value)
          .toList();
      emit(state.copyWith(breakweights: list));
    });
    on<BreakweightMaxChanged>((event, emit) {
      final list = state.breakweights
          .asMap()
          .entries
          .map((e) => e.key == event.index ? e.value.copyWith(max: event.value) : e.value)
          .toList();
      emit(state.copyWith(breakweights: list));
    });

    on<AddonValueChanged>((event, emit) => emit(state.copyWith(addonValues: {...state.addonValues, event.key: event.value})));
    on<AddonModeChanged>((event, emit) => emit(state.copyWith(addonModes: {...state.addonModes, event.key: event.mode})));

    on<ConditionalTypeChanged>((event, emit) => emit(state.copyWith(conditionalType: event.type)));
    on<ConditionalPricingOptionChanged>((event, emit) => emit(state.copyWith(conditionalPricingOption: event.option)));

    on<ConditionalRouteAdded>((event, emit) {
      final rates = List.filled(state.conditionalBreakweights.length, '');
      emit(state.copyWith(conditionalMatrixRows: [...state.conditionalMatrixRows, MatrixRow(rates: rates)]));
    });
    on<ConditionalOriginChanged>((event, emit) {
      final rows = state.conditionalMatrixRows
          .asMap()
          .entries
          .map((e) => e.key == event.rowIndex ? e.value.copyWith(origin: event.value) : e.value)
          .toList();
      emit(state.copyWith(conditionalMatrixRows: rows));
    });
    on<ConditionalDestinationChanged>((event, emit) {
      final rows = state.conditionalMatrixRows
          .asMap()
          .entries
          .map((e) => e.key == event.rowIndex ? e.value.copyWith(destination: event.value) : e.value)
          .toList();
      emit(state.copyWith(conditionalMatrixRows: rows));
    });
    on<ConditionalCellChanged>((event, emit) {
      final rows = state.conditionalMatrixRows.asMap().entries.map((e) {
        if (e.key != event.rowIndex) return e.value;
        final rates = [...e.value.rates];
        rates[event.breakweightIndex] = event.value;
        return e.value.copyWith(rates: rates);
      }).toList();
      emit(state.copyWith(conditionalMatrixRows: rows));
    });

    on<ConditionalBreakweightAdded>((event, emit) {
      emit(state.copyWith(
        conditionalBreakweights: [...state.conditionalBreakweights, const Breakweight()],
        conditionalMatrixRows:
            state.conditionalMatrixRows.map((r) => r.copyWith(rates: [...r.rates, ''])).toList(),
      ));
    });
    on<ConditionalBreakweightRemoved>((event, emit) {
      if (state.conditionalBreakweights.length <= 1) return;
      emit(state.copyWith(
        conditionalBreakweights: [...state.conditionalBreakweights]..removeAt(event.index),
        conditionalMatrixRows: state.conditionalMatrixRows
            .map((r) => r.copyWith(rates: [...r.rates]..removeAt(event.index)))
            .toList(),
      ));
    });
    on<ConditionalBreakweightMinChanged>((event, emit) {
      final list = state.conditionalBreakweights
          .asMap()
          .entries
          .map((e) => e.key == event.index ? e.value.copyWith(min: event.value) : e.value)
          .toList();
      emit(state.copyWith(conditionalBreakweights: list));
    });
    on<ConditionalBreakweightMaxChanged>((event, emit) {
      final list = state.conditionalBreakweights
          .asMap()
          .entries
          .map((e) => e.key == event.index ? e.value.copyWith(max: event.value) : e.value)
          .toList();
      emit(state.copyWith(conditionalBreakweights: list));
    });

    on<PhLocationsLoaded>((event, emit) => emit(state.copyWith(phCities: event.cities, phProvinces: event.provinces)));

    on<RateSubmitRequested>(_onSubmitRequested);

    _phLocationsService.ensureLoaded().then((_) {
      if (isClosed) return;
      add(PhLocationsLoaded(_phLocationsService.cities, _phLocationsService.provinces));
    });
  }

  final PhLocationsService _phLocationsService;
  final RatesRepository _ratesRepository;

  Future<void> _onSubmitRequested(RateSubmitRequested event, Emitter<RateWizardState> emit) async {
    emit(state.copyWith(isSubmitting: true, clearSubmitError: true, clearSubmitSucceeded: true));

    final payload = RateWizardPayloadMapper.buildPayload(
      isCustom: state.isCustom,
      clientId: state.clientId,
      freightMode: state.freightMode,
      serviceMode: state.serviceMode,
      chargeBasis: state.chargeBasis,
      pricingOption: state.pricingOption,
      fullChargeCode: state.fullChargeCode,
      expiryDate: state.expiryDate,
      rows: [
        for (final row in state.matrixRows) (origin: row.origin, destination: row.destination, rates: row.rates),
      ],
      breakweightBounds: [
        for (final bw in state.breakweights) (min: bw.min, max: bw.max),
      ],
      addonValues: state.addonValues,
      addonModes: state.addonModes,
    );

    try {
      await _ratesRepository.createRate(payload);
      emit(state.copyWith(isSubmitting: false, submitSucceeded: true));
    } on RatesApiException catch (e) {
      emit(state.copyWith(isSubmitting: false, submitError: e.message));
    } catch (e) {
      emit(state.copyWith(isSubmitting: false, submitError: e.toString()));
    }
  }
}
