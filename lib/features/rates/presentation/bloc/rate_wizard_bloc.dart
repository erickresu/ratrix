import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/repositories/rates_repository.dart';
import '../../domain/entities/breakweight.dart';
import '../../domain/entities/location_option.dart';
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
    required RatesRepository ratesRepository,
    String? clientId,
    String? clientName,
    RatrixRate? existingRate,
  }) : _ratesRepository = ratesRepository,
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
      final newChargeBasis = validChargeBases.contains(state.chargeBasis)
          ? state.chargeBasis
          // Prefer a charge basis that's actually usable over one that's
          // only listed as "valid for this freight mode" but not yet
          // implemented (e.g. Full Truck Load) — otherwise switching to
          // Land would default straight into a disabled Pricing Option.
          : validChargeBases.firstWhere(
              (b) => !RatesFkIds.chargeBasisNotYetImplemented.contains(b),
              orElse: () => validChargeBases.first,
            );
      emit(
        state.copyWith(
          freightMode: event.mode,
          serviceMode: validServiceModes.contains(state.serviceMode)
              ? state.serviceMode
              : validServiceModes.first,
          chargeBasis: newChargeBasis,
          pricingOption: _resolvePricingOption(
            newChargeBasis,
            state.pricingOption,
          ),
        ),
      );
    });
    on<ServiceModeChanged>(
      (event, emit) => emit(state.copyWith(serviceMode: event.mode)),
    );
    on<ChargeBasisChanged>((event, emit) {
      emit(
        state.copyWith(
          chargeBasis: event.basis,
          pricingOption: _resolvePricingOption(
            event.basis,
            state.pricingOption,
          ),
        ),
      );
    });
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
    on<LocationSearchTypeChanged>((event, emit) {
      // A stale result set from the old type shouldn't linger under the
      // newly selected one.
      switch (event.field) {
        case LocationField.origin:
          emit(state.copyWith(originSearchType: event.searchType, originSearchResults: const [], originSearchLoading: false));
        case LocationField.destination:
          emit(
            state.copyWith(
              destinationSearchType: event.searchType,
              destinationSearchResults: const [],
              destinationSearchLoading: false,
            ),
          );
      }
    });
    on<LocationSearchQueryChanged>((event, emit) async {
      final isOrigin = event.field == LocationField.origin;
      (isOrigin ? _originSearchDebounce : _destinationSearchDebounce)?.cancel();

      // An empty query still searches — the datasource sends `all=1` in
      // that case, so a focused-but-untyped field shows every option for
      // the current "match by" type instead of an empty menu.
      emit(
        isOrigin
            ? state.copyWith(originSearchLoading: true)
            : state.copyWith(destinationSearchLoading: true),
      );

      final requestId = isOrigin ? ++_latestOriginRequestId : ++_latestDestinationRequestId;
      final completer = Completer<void>();
      final timer = Timer(const Duration(milliseconds: 300), () => completer.complete());
      if (isOrigin) {
        _originSearchDebounce = timer;
      } else {
        _destinationSearchDebounce = timer;
      }
      await completer.future;
      if (isClosed) return;

      final searchType = isOrigin ? state.originSearchType : state.destinationSearchType;
      final results = await _ratesRepository.searchLocations(q: event.query, type: searchType.apiType);
      if (isClosed) return;
      // Discard a response from a keystroke that's no longer the latest —
      // network jitter can make an earlier request resolve after a later
      // one, and debouncing alone doesn't prevent that.
      final isStillLatest = isOrigin ? requestId == _latestOriginRequestId : requestId == _latestDestinationRequestId;
      if (!isStillLatest) return;
      emit(
        isOrigin
            ? state.copyWith(originSearchResults: results, originSearchLoading: false)
            : state.copyWith(destinationSearchResults: results, destinationSearchLoading: false),
      );
    });
    on<LocationSearchCleared>((event, emit) {
      switch (event.field) {
        case LocationField.origin:
          emit(state.copyWith(originSearchResults: const [], originSearchLoading: false));
        case LocationField.destination:
          emit(state.copyWith(destinationSearchResults: const [], destinationSearchLoading: false));
      }
    });
    on<OriginLocationSelected>((event, emit) {
      final rows = _updateAt(
        state.matrixRows,
        event.rowIndex,
        (r) => r.copyWith(origin: event.displayText, originOption: event.option),
      );
      emit(state.copyWith(matrixRows: rows));
    });
    on<DestinationLocationSelected>((event, emit) {
      final rows = _updateAt(
        state.matrixRows,
        event.rowIndex,
        (r) => r.copyWith(
          destination: event.displayText,
          destinationOption: event.option,
        ),
      );
      emit(state.copyWith(matrixRows: rows));
    });

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
      // Text no longer matches what `originOption` was resolved for — clear
      // it so submit doesn't send stale geography ids for a relabeled
      // location.
      final rows = _updateAt(
        state.matrixRows,
        event.rowIndex,
        (r) => r.origin == event.value
            ? r
            : r.copyWith(origin: event.value, originOption: null),
      );
      emit(state.copyWith(matrixRows: rows));
    });
    on<DestinationChanged>((event, emit) {
      final rows = _updateAt(
        state.matrixRows,
        event.rowIndex,
        (r) => r.destination == event.value
            ? r
            : r.copyWith(destination: event.value, destinationOption: null),
      );
      emit(state.copyWith(matrixRows: rows));
    });
    on<CellChanged>((event, emit) {
      final rows = _updateAt(state.matrixRows, event.rowIndex, (r) {
        final rates = [...r.rates];
        rates[event.breakweightIndex] = event.value;
        return r.copyWith(rates: rates);
      });
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
      final list = _updateAt(
        state.breakweights,
        event.index,
        (b) => b.copyWith(min: event.value),
      );
      emit(state.copyWith(breakweights: list));
    });
    on<BreakweightMaxChanged>((event, emit) {
      final list = _updateAt(
        state.breakweights,
        event.index,
        (b) => b.copyWith(max: event.value),
      );
      _cascadeBreakweightMins(list, event.index + 1);
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
      final rows = _updateAt(
        state.conditionalMatrixRows,
        event.rowIndex,
        (r) => r.copyWith(origin: event.value),
      );
      emit(state.copyWith(conditionalMatrixRows: rows));
    });
    on<ConditionalDestinationChanged>((event, emit) {
      final rows = _updateAt(
        state.conditionalMatrixRows,
        event.rowIndex,
        (r) => r.copyWith(destination: event.value),
      );
      emit(state.copyWith(conditionalMatrixRows: rows));
    });
    on<ConditionalCellChanged>((event, emit) {
      final rows = _updateAt(state.conditionalMatrixRows, event.rowIndex, (r) {
        final rates = [...r.rates];
        rates[event.breakweightIndex] = event.value;
        return r.copyWith(rates: rates);
      });
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
      final list = _updateAt(
        state.conditionalBreakweights,
        event.index,
        (b) => b.copyWith(min: event.value),
      );
      emit(state.copyWith(conditionalBreakweights: list));
    });
    on<ConditionalBreakweightMaxChanged>((event, emit) {
      final list = _updateAt(
        state.conditionalBreakweights,
        event.index,
        (b) => b.copyWith(max: event.value),
      );
      _cascadeBreakweightMins(list, event.index + 1);
      emit(state.copyWith(conditionalBreakweights: list));
    });

    on<RateSubmitRequested>(_onSubmitRequested);
  }

  final RatesRepository _ratesRepository;

  Timer? _originSearchDebounce;
  Timer? _destinationSearchDebounce;
  int _latestOriginRequestId = 0;
  int _latestDestinationRequestId = 0;

  @override
  Future<void> close() {
    _originSearchDebounce?.cancel();
    _destinationSearchDebounce?.cancel();
    return super.close();
  }


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

    // Belt-and-suspenders: the Pricing Option picker is disabled in the UI
    // for a charge basis with no known-valid options, but guard submit too
    // in case a stale selection slips through some other path.
    final validPricingOptions =
        RatesFkIds.pricingOptionsByChargeBasis[state.chargeBasis];
    if (validPricingOptions != null && validPricingOptions.isEmpty) {
      emit(
        state.copyWith(
          isSubmitting: false,
          submitError:
              'Pricing options for ${state.chargeBasis.label} aren\'t available yet. '
              'Choose a different charge basis to continue.',
        ),
      );
      return;
    }

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
            originOption: row.originOption,
            destinationOption: row.destinationOption,
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
      final savedRate = editingRateId != null
          ? await _ratesRepository.updateRate(editingRateId, payload)
          : await _ratesRepository.createRate(payload);
      emit(
        state.copyWith(
          isSubmitting: false,
          submitSucceeded: true,
          lastSubmitStayedOnPage: event.stayOnPage,
          savedChargeCode: savedRate.chargeCode,
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
  /// Infers which "match by" filter type an existing rate's saved
  /// origin/destination was originally picked with. The API never stored
  /// which filter was used — only the resolved address — so this is a
  /// best-effort read of which id field is actually populated:
  /// `cityId` set → City search; only `provinceId` set → Province search;
  /// only `islandId` set → Island search. Falls back to Island (the
  /// wizard's default) when nothing is set, e.g. a brand-new route.
  static LocationSearchType _inferSearchType(RatrixAddress? address) {
    if (address == null) return LocationSearchType.island;
    if (address.cityId != null) return LocationSearchType.cityProvince;
    if (address.provinceId != null) return LocationSearchType.province;
    if (address.islandId != null) return LocationSearchType.island;
    return LocationSearchType.island;
  }

  /// Rebuilds the `LocationOption` a saved route's address represents, so a
  /// loaded-for-edit row carries the same shape a fresh search-and-select
  /// would have produced — the payload mapper only ever reads
  /// `MatrixRow.originOption`/`destinationOption`, so an edit-loaded row
  /// needs one too, not just display text.
  static LocationOption? _optionFromAddress(RatrixAddress? address) {
    if (address == null) return null;
    final name = address.displayLabel;
    return LocationOption(
      id: address.id?.toString(),
      value: name,
      label: name,
      islandId: address.islandId,
      regionId: address.regionId,
      provinceId: address.provinceId,
      cityId: address.cityId,
      barangayId: address.barangayId,
      zipcode: address.zipcode,
      address1: address.address1,
    );
  }

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
                originOption: _optionFromAddress(route.origin),
                destinationOption: _optionFromAddress(route.destination),
              ),
          ]
        : const [MatrixRow()];

    // Same "first route wins" tradeoff as the breakweight columns above —
    // the wizard has one shared match-by filter per column, not per row, so
    // infer it from the first route's saved address granularity.
    final firstRoute = rate.routes.isNotEmpty ? rate.routes.first : null;
    final originSearchType = _inferSearchType(firstRoute?.origin);
    final destinationSearchType = _inferSearchType(firstRoute?.destination);

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
      originSearchType: originSearchType,
      destinationSearchType: destinationSearchType,
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

  static List<T> _updateAt<T>(List<T> list, int index, T Function(T) update) {
    return list
        .asMap()
        .entries
        .map((e) => e.key == index ? update(e.value) : e.value)
        .toList();
  }

  // A charge basis change can leave the current pricing option invalid for
  // the new basis — fall back to the new basis's first option, unless it has
  // no known-valid options yet (e.g. Full Truck Load), in which case the UI
  // disables the picker and the stale value is left in place since it can't
  // be submitted anyway.
  static PricingOption _resolvePricingOption(
    ChargeBasis basis,
    PricingOption current,
  ) {
    final validOptions =
        RatesFkIds.pricingOptionsByChargeBasis[basis] ?? PricingOption.values;
    return validOptions.isEmpty || validOptions.contains(current)
        ? current
        : validOptions.first;
  }

  // Min is never user-edited — every tier's min is always derived from the
  // previous tier's max — so changing an earlier tier's max must cascade all
  // the way to the end, not just the next tier, or every tier after the
  // immediate neighbor is left showing a stale min. Stops at the first
  // invalid tier (max <= its own min) instead of deriving later tiers from a
  // broken range.
  static void _cascadeBreakweightMins(List<Breakweight> list, int fromIndex) {
    for (var i = fromIndex; i < list.length; i++) {
      final prevMin = num.tryParse(list[i - 1].min);
      final prevMax = num.tryParse(list[i - 1].max);
      if (prevMax == null || (prevMin != null && prevMax <= prevMin)) break;
      list[i] = list[i].copyWith(min: _numToString(prevMax + 1));
    }
  }

  static String _numToString(num value) {
    // Avoid trailing ".0" for whole numbers, matching how the wizard's text
    // fields are typically populated by hand (e.g. "50" not "50.0").
    if (value == value.toInt()) return value.toInt().toString();
    return value.toString();
  }
}
