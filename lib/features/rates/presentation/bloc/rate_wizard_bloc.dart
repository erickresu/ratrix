import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/services/ph_locations_service.dart';
import '../../data/repositories/rates_repository.dart';
import '../../domain/entities/breakweight.dart';
import '../../domain/entities/matrix_row.dart';
import '../../domain/entities/rate_wizard_payload_mapper.dart';
import '../../domain/entities/ratrix_rate.dart';
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
    RatrixRate? existingRate,
  }) : _phLocationsService = phLocationsService,
       _ratesRepository = ratesRepository,
       _existingRate = existingRate,
       super(
         existingRate != null
             ? _buildStateFromExistingRate(
                 existingRate,
                 isCustom: isCustom,
                 clientId: clientId,
                 clientName: clientName,
               )
             : RateWizardState(
                 isCustom: isCustom,
                 clientId: clientId,
                 clientName: clientName,
               ),
       ) {
    on<WizardStepChanged>((event, emit) {
      if (event.step > 0 && !state.canLeaveStep0) return;
      emit(state.copyWith(step: event.step));
    });
    on<WizardNextStepRequested>((event, emit) {
      if (state.step == 0 && !state.canLeaveStep0) return;
      if (state.step < 3) emit(state.copyWith(step: state.step + 1));
    });
    on<WizardBackStepRequested>((event, emit) {
      if (state.step > 0) emit(state.copyWith(step: state.step - 1));
    });

    on<FreightModeChanged>((event, emit) {
      final validServiceModes =
          RatesFkIds.serviceModeOptionsByFreightMode[event.mode]!;
      final validChargeBases =
          RatesFkIds.chargeBasisOptionsByFreightMode[event.mode]!;
      emit(
        state.copyWith(
          freightMode: event.mode,
          serviceMode: validServiceModes.contains(state.serviceMode)
              ? state.serviceMode
              : validServiceModes.first,
          chargeBasis: validChargeBases.contains(state.chargeBasis)
              ? state.chargeBasis
              : validChargeBases.first,
        ),
      );
    });
    on<ServiceModeChanged>(
      (event, emit) => emit(state.copyWith(serviceMode: event.mode)),
    );
    on<ChargeBasisChanged>(
      (event, emit) => emit(state.copyWith(chargeBasis: event.basis)),
    );
    on<PricingOptionChanged>(
      (event, emit) => emit(state.copyWith(pricingOption: event.option)),
    );
    on<ChargeCodeSuffixChanged>(
      (event, emit) => emit(state.copyWith(chargeCodeSuffix: event.value)),
    );
    on<ExpiryDateChanged>(
      (event, emit) => emit(state.copyWith(expiryDate: event.date)),
    );

    on<MatrixTabChanged>(
      (event, emit) => emit(state.copyWith(matrixTab: event.tab)),
    );
    on<MarkupChanged>(
      (event, emit) => emit(state.copyWith(markup: event.value)),
    );
    on<LocationBasisChanged>(
      (event, emit) => emit(state.copyWith(locationBasis: event.basis)),
    );

    on<RouteAdded>((event, emit) {
      final rates = List.filled(state.breakweights.length, '');
      emit(
        state.copyWith(
          matrixRows: [
            ...state.matrixRows,
            MatrixRow(rates: rates),
          ],
        ),
      );
    });
    on<RouteRemoveRequested>(
      (event, emit) => emit(state.copyWith(removeRouteIndex: event.index)),
    );
    on<RouteRemoveCancelled>(
      (event, emit) => emit(state.copyWith(clearRemoveRouteIndex: true)),
    );
    on<RouteRemoveConfirmed>((event, emit) {
      final index = state.removeRouteIndex;
      if (index == null) return;
      final rows = [...state.matrixRows]..removeAt(index);
      emit(state.copyWith(matrixRows: rows, clearRemoveRouteIndex: true));
    });

    on<OriginChanged>((event, emit) {
      final rows = state.matrixRows.asMap().entries.map((e) {
        if (e.key != event.rowIndex) return e.value;
        // Text no longer matches what `originId` was resolved for — clear
        // it so submit doesn't send a stale id for a relabeled location.
        if (e.value.origin == event.value) return e.value;
        return e.value.copyWith(origin: event.value, originId: null);
      }).toList();
      emit(state.copyWith(matrixRows: rows));
    });
    on<DestinationChanged>((event, emit) {
      final rows = state.matrixRows.asMap().entries.map((e) {
        if (e.key != event.rowIndex) return e.value;
        if (e.value.destination == event.value) return e.value;
        return e.value.copyWith(destination: event.value, destinationId: null);
      }).toList();
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
      final prevMax = state.breakweights.isNotEmpty
          ? num.tryParse(state.breakweights.last.max)
          : null;
      final nextMin = prevMax != null ? _numToString(prevMax + 1) : '1';
      emit(
        state.copyWith(
          breakweights: [
            ...state.breakweights,
            Breakweight(min: nextMin),
          ],
          matrixRows: state.matrixRows
              .map((r) => r.copyWith(rates: [...r.rates, '']))
              .toList(),
        ),
      );
    });
    on<BreakweightRemoved>((event, emit) {
      if (state.breakweights.length <= 1) return;
      emit(
        state.copyWith(
          breakweights: [...state.breakweights]..removeAt(event.index),
          matrixRows: state.matrixRows
              .map(
                (r) => r.copyWith(rates: [...r.rates]..removeAt(event.index)),
              )
              .toList(),
        ),
      );
    });
    on<BreakweightMinChanged>((event, emit) {
      final list = state.breakweights
          .asMap()
          .entries
          .map(
            (e) => e.key == event.index
                ? e.value.copyWith(min: event.value)
                : e.value,
          )
          .toList();
      emit(state.copyWith(breakweights: list));
    });
    on<BreakweightMaxChanged>((event, emit) {
      final list = state.breakweights
          .asMap()
          .entries
          .map(
            (e) => e.key == event.index
                ? e.value.copyWith(max: event.value)
                : e.value,
          )
          .toList();
      // Editing a tier's max leaves the next tier's min stale — cascade it
      // forward so the ranges stay contiguous instead of gapping/overlapping.
      final nextIndex = event.index + 1;
      if (nextIndex < list.length) {
        final newMax = num.tryParse(event.value);
        if (newMax != null) {
          list[nextIndex] = list[nextIndex].copyWith(
            min: _numToString(newMax + 1),
          );
        }
      }
      emit(state.copyWith(breakweights: list));
    });

    on<AddonValueChanged>(
      (event, emit) => emit(
        state.copyWith(
          addonValues: {...state.addonValues, event.key: event.value},
        ),
      ),
    );
    on<AddonModeChanged>(
      (event, emit) => emit(
        state.copyWith(
          addonModes: {...state.addonModes, event.key: event.mode},
        ),
      ),
    );

    on<ConditionalTypeChanged>(
      (event, emit) => emit(state.copyWith(conditionalType: event.type)),
    );
    on<ConditionalPricingOptionChanged>(
      (event, emit) =>
          emit(state.copyWith(conditionalPricingOption: event.option)),
    );

    on<ConditionalRouteAdded>((event, emit) {
      final rates = List.filled(state.conditionalBreakweights.length, '');
      emit(
        state.copyWith(
          conditionalMatrixRows: [
            ...state.conditionalMatrixRows,
            MatrixRow(rates: rates),
          ],
        ),
      );
    });
    on<ConditionalOriginChanged>((event, emit) {
      final rows = state.conditionalMatrixRows
          .asMap()
          .entries
          .map(
            (e) => e.key == event.rowIndex
                ? e.value.copyWith(origin: event.value)
                : e.value,
          )
          .toList();
      emit(state.copyWith(conditionalMatrixRows: rows));
    });
    on<ConditionalDestinationChanged>((event, emit) {
      final rows = state.conditionalMatrixRows
          .asMap()
          .entries
          .map(
            (e) => e.key == event.rowIndex
                ? e.value.copyWith(destination: event.value)
                : e.value,
          )
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
      final prevMax = state.conditionalBreakweights.isNotEmpty
          ? num.tryParse(state.conditionalBreakweights.last.max)
          : null;
      final nextMin = prevMax != null ? _numToString(prevMax + 1) : '1';
      emit(
        state.copyWith(
          conditionalBreakweights: [
            ...state.conditionalBreakweights,
            Breakweight(min: nextMin),
          ],
          conditionalMatrixRows: state.conditionalMatrixRows
              .map((r) => r.copyWith(rates: [...r.rates, '']))
              .toList(),
        ),
      );
    });
    on<ConditionalBreakweightRemoved>((event, emit) {
      if (state.conditionalBreakweights.length <= 1) return;
      emit(
        state.copyWith(
          conditionalBreakweights: [...state.conditionalBreakweights]
            ..removeAt(event.index),
          conditionalMatrixRows: state.conditionalMatrixRows
              .map(
                (r) => r.copyWith(rates: [...r.rates]..removeAt(event.index)),
              )
              .toList(),
        ),
      );
    });
    on<ConditionalBreakweightMinChanged>((event, emit) {
      final list = state.conditionalBreakweights
          .asMap()
          .entries
          .map(
            (e) => e.key == event.index
                ? e.value.copyWith(min: event.value)
                : e.value,
          )
          .toList();
      emit(state.copyWith(conditionalBreakweights: list));
    });
    on<ConditionalBreakweightMaxChanged>((event, emit) {
      final list = state.conditionalBreakweights
          .asMap()
          .entries
          .map(
            (e) => e.key == event.index
                ? e.value.copyWith(max: event.value)
                : e.value,
          )
          .toList();
      // Editing a tier's max leaves the next tier's min stale — cascade it
      // forward so the ranges stay contiguous instead of gapping/overlapping.
      final nextIndex = event.index + 1;
      if (nextIndex < list.length) {
        final newMax = num.tryParse(event.value);
        if (newMax != null) {
          list[nextIndex] = list[nextIndex].copyWith(
            min: _numToString(newMax + 1),
          );
        }
      }
      emit(state.copyWith(conditionalBreakweights: list));
    });

    on<PhLocationsLoaded>(
      (event, emit) => emit(
        state.copyWith(phCities: event.cities, phProvinces: event.provinces),
      ),
    );

    on<RateSubmitRequested>(_onSubmitRequested);

    _phLocationsService.ensureLoaded().then((_) {
      if (isClosed) return;
      add(
        PhLocationsLoaded(
          _phLocationsService.cities,
          _phLocationsService.provinces,
        ),
      );
    });
  }

  final PhLocationsService _phLocationsService;
  final RatesRepository _ratesRepository;
  final RatrixRate? _existingRate;

  Future<void> _onSubmitRequested(
    RateSubmitRequested event,
    Emitter<RateWizardState> emit,
  ) async {
    emit(
      state.copyWith(
        isSubmitting: true,
        clearSubmitError: true,
        clearSubmitSucceeded: true,
      ),
    );

    final originalRoutesById = {
      for (final r in _existingRate?.routes ?? const <RatrixRoute>[])
        if (r.id != null) r.id!: r,
    };

    final seenRoutes = <String>{};
    for (var i = 0; i < state.matrixRows.length; i++) {
      final row = state.matrixRows[i];
      final key =
          '${row.origin.trim().toLowerCase()}|${row.destination.trim().toLowerCase()}';
      if (key == '|') continue; // both blank — not a meaningful duplicate.
      if (!seenRoutes.add(key)) {
        emit(
          state.copyWith(
            isSubmitting: false,
            submitError:
                'Route ${i + 1} has the same origin and destination as another row. '
                'Make them different (e.g. add the barangay or zip code) before saving.',
          ),
        );
        return;
      }
    }

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
        for (final row in state.matrixRows)
          (
            origin: row.origin,
            destination: row.destination,
            rates: row.rates,
            // Row untouched since load (still carries its original route id)
            // — resend the server's own route/origin/destination JSON as-is
            // instead of reconstructing an id-less version of it.
            original: row.routeId != null
                ? originalRoutesById[row.routeId]?.toJson()
                : null,
            routeId: row.routeId,
            originId: row.originId,
            destinationId: row.destinationId,
          ),
      ],
      breakweightBounds: [
        for (final bw in state.breakweights) (min: bw.min, max: bw.max),
      ],
      addonValues: state.addonValues,
      addonModes: state.addonModes,
    );

    try {
      final editingRateId = state.editingRateId;
      if (editingRateId != null) {
        await _ratesRepository.updateRate(editingRateId, payload);
      } else {
        await _ratesRepository.createRate(payload);
      }
      emit(
        state.copyWith(
          isSubmitting: false,
          submitSucceeded: true,
          lastSubmitStayedOnPage: event.stayOnPage,
        ),
      );
    } on RatesApiException catch (e) {
      emit(state.copyWith(isSubmitting: false, submitError: e.message));
    } catch (e) {
      emit(state.copyWith(isSubmitting: false, submitError: e.toString()));
    }
  }

  /// Builds the wizard's initial state FROM an existing [RatrixRate], for
  /// edit mode. This is the reverse of [RateWizardPayloadMapper.buildPayload]
  /// — see the class doc there for the forward direction.
  static RateWizardState _buildStateFromExistingRate(
    RatrixRate rate, {
    required bool isCustom,
    String? clientId,
    String? clientName,
  }) {
    final freightMode = rate.freightMode?.id != null
        ? RatesFkIds.freightModeFromId[rate.freightMode!.id]
        : null;
    final serviceMode =
        (rate.serviceMode?.id != null
            ? RatesFkIds.serviceModeFromId[rate.serviceMode!.id]
            : null) ??
        ServiceMode.doorToDoor;
    final chargeBasis =
        (rate.chargeBasis?.id != null
            ? RatesFkIds.chargeBasisFromId[rate.chargeBasis!.id]
            : null) ??
        ChargeBasis.kilo;
    final pricingOption =
        (rate.chargeOption?.id != null
            ? RatesFkIds.pricingOptionFromId[rate.chargeOption!.id]
            : null) ??
        PricingOption.fixedBreakweight;

    // charge_code suffix: the wizard always derives a prefix from
    // freight/service mode (`RateWizardState.chargeCodePrefix`) and appends
    // whatever the user typed as the suffix. If the existing rate's
    // charge_code cleanly starts with the prefix this rate would regenerate,
    // strip it off so re-editing doesn't double the prefix. Otherwise (the
    // stored code doesn't match — e.g. it predates this convention, or was
    // set by hand) just use the full existing code as the "suffix"; on next
    // save the prefix will be prepended again, producing a duplicated-looking
    // code. This is a known, accepted tradeoff — see task brief.
    final derivedPrefix =
        '${(freightMode?.name ?? '').toUpperCase()}_${serviceMode.abbreviation}';
    final existingCode = rate.chargeCode ?? '';
    String chargeCodeSuffix;
    if (existingCode.startsWith('${derivedPrefix}_')) {
      chargeCodeSuffix = existingCode.substring(derivedPrefix.length + 1);
    } else if (existingCode == derivedPrefix) {
      chargeCodeSuffix = '';
    } else {
      chargeCodeSuffix = existingCode;
    }

    // Matrix reconciliation: the wizard UI assumes one shared breakweight
    // column set applied to every route, but the API's `RatrixRoute` each
    // carry their own independent `breakweights[]`. Full N-route
    // reconciliation across mismatched boundary sets is out of scope — this
    // is a "best effort, first-route-wins" pre-fill: the FIRST route's
    // breakweight boundaries become the wizard's shared columns, and every
    // route's cells are filled by matching its own breakweights against
    // those exact (min, max) boundaries. A route whose breakweight
    // boundaries differ from the first route's will show blank cells for
    // any slot it has no exact match for, rather than guessing.
    final firstRouteBreakweights = rate.routes.isNotEmpty
        ? rate.routes.first.breakweights
        : const <RatrixBreakweight>[];
    final breakweights = firstRouteBreakweights.isNotEmpty
        ? [
            for (final bw in firstRouteBreakweights)
              Breakweight(min: _numToString(bw.min), max: _numToString(bw.max)),
          ]
        : const [Breakweight()];

    final matrixRows = rate.routes.isNotEmpty
        ? [
            for (final route in rate.routes)
              MatrixRow(
                origin: route.origin?.displayLabel ?? '',
                destination: route.destination?.displayLabel ?? '',
                rates: [
                  for (final slot in firstRouteBreakweights)
                    _findMatchingRate(route.breakweights, slot),
                ],
                routeId: route.id,
                originId: route.origin?.id,
                destinationId: route.destination?.id,
              ),
          ]
        : const [MatrixRow()];

    // Addons: reverse of `RateWizardPayloadMapper.mapAddons` — only the flat
    // decimal fields it supports going wizard->API are reversed here.
    // `oda`/`pickup_fee` bracket-config pricing is skipped, same as the
    // forward mapper.
    final addonValues = <String, String>{};
    final addonModes = <String, AddonMode>{};
    final addons = rate.addons;
    if (addons != null) {
      void put(String key, num? value) {
        if (value != null) addonValues[key] = _numToString(value);
      }

      put('fuel', addons.fuelSurcharge);
      put('security', addons.securitySurcharge);
      put('booking', addons.bookingHandlingFee);
      put('documentation', addons.documentationFee);
      put('permit', addons.permitFeesNonVat);
      put('insurance', addons.insurance);
      put('valuation', addons.valuation);
      put('waybill', addons.waybillFee);
      put('delivery', addons.deliveryFee);
      put('crating', addons.cratingFee);
      put('packing', addons.packingFee);
      put('demurrage', addons.demurrageDetention);
      put('hazardous', addons.hazardousGoodsHandling);
      put('othersNonVat', addons.othersNonVat);
      // thc: air_thc/sea_thc both map back to the single wizard "thc" field,
      // matching whichever the forward mapper would have written for this
      // freight mode.
      final thc = freightMode == FreightMode.sea
          ? addons.seaThc
          : addons.airThc;
      put('thc', thc);

      if (addons.fuelSurchargeType != null && addonValues.containsKey('fuel')) {
        addonModes['fuel'] = addons.fuelSurchargeType == 'percentage'
            ? AddonMode.percentage
            : AddonMode.exact;
      }
      if (addons.valuationType != null &&
          addonValues.containsKey('valuation')) {
        addonModes['valuation'] = addons.valuationType == 'percentage'
            ? AddonMode.percentage
            : AddonMode.exact;
      }
    }

    return RateWizardState(
      isCustom: isCustom,
      clientId: clientId,
      clientName: clientName,
      editingRateId: rate.id,
      freightMode: freightMode,
      serviceMode: serviceMode,
      chargeBasis: chargeBasis,
      pricingOption: pricingOption,
      chargeCodeSuffix: chargeCodeSuffix,
      expiryDate: rate.rateExpiry,
      matrixRows: matrixRows,
      breakweights: breakweights,
      addonValues: addonValues,
      addonModes: addonModes,
    );
  }

  /// Finds the rate in [routeBreakweights] whose (min, max) exactly matches
  /// [slot], returning it as a string for the matrix cell, or `''` if this
  /// route has no breakweight with that exact boundary pair (see the
  /// "first-route-wins" tradeoff note above).
  static String _findMatchingRate(
    List<RatrixBreakweight> routeBreakweights,
    RatrixBreakweight slot,
  ) {
    for (final bw in routeBreakweights) {
      if (bw.min == slot.min && bw.max == slot.max)
        return _numToString(bw.rate);
    }
    return '';
  }

  static String _numToString(num value) {
    // Avoid trailing ".0" for whole numbers, matching how the wizard's text
    // fields are typically populated by hand (e.g. "50" not "50.0").
    if (value == value.toInt()) return value.toInt().toString();
    return value.toString();
  }
}
