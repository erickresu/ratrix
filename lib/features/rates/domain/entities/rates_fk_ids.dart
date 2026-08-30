import 'rates_enums.dart';

/// Maps the wizard's local enums to the real numeric FK ids the backend
/// expects (`freight_mode_id`, `service_mode_id`, `charge_basis_id`,
/// `charge_option_id`).
///
/// There is no dedicated "resolve FK from enum" endpoint, but the backend
/// (`cerrov5-server`) exposes `GET api/freight-modes`, `api/service-modes`,
/// `api/charge-basis`, and `api/charge-options` (confirmed live: these
/// routes 401 "Unauthenticated" rather than 404, and Laravel's
/// `Route::apiResource` registrations for all four are present in
/// `routes/api.php`). The authoritative values below come directly from
/// that backend's seeder — `database/seeders/RatrixSeeder.php` in the
/// `cerrov5-server` repo, which is `DB::table(...)->upsert([...])`'d with
/// fixed, manually-assigned ids (the models declare `incrementing = false`
/// specifically because ids are seeded, not autoincremented) — so these are
/// not guesses:
///
/// types_freight_modes: 1=Air(AIR), 2=Land(LND), 3=Sea(SEA)
/// types_service_modes: 1=Door to Door(D2D), 2=Door to Port(D2P),
///                       3=Port to Door(P2D), 4=Port to Port(P2P)
/// types_charge_basis:  1=Kilo(K), 2=Cubic Meter(CBM), 3=Full Truck Load(FTL),
///                       4=LTL(Kilo), 5=LTL(CBM), 6=Full Container Load(FCL),
///                       7=LCL(Kilo), 8=LCL(CBM)
/// types_charge_options: 1=Fixed Bracket Pricing(FBP) ... 7=Minimum Excess
///                       Bracket Pricing(MEBP), 8-15=distance/FTL-only
///                       options, 16-17=FCL-only options.
///
/// The wizard only ever exposes Kilo/CBM for charge basis and the 7
/// bracket-pricing options for pricing option, so only those rows are
/// mapped here. If the wizard is ever extended to surface FTL/FCL charge
/// bases or their distance/route/time-based pricing options, this table
/// needs new entries — those ids (8 onward) are already known from the
/// seeder above, just not wired to any current UI control.
class RatesFkIds {
  const RatesFkIds._();

  static const Map<FreightMode, int> freightModeIds = {
    FreightMode.air: 1,
    FreightMode.land: 2,
    FreightMode.sea: 3,
  };

  static const Map<ServiceMode, int> serviceModeIds = {
    ServiceMode.doorToDoor: 1,
    ServiceMode.doorToPort: 2,
    ServiceMode.portToDoor: 3,
    ServiceMode.portToPort: 4,
  };

  static const Map<ChargeBasis, int> chargeBasisIds = {
    ChargeBasis.kilo: 1,
    ChargeBasis.cbm: 2,
    ChargeBasis.fullTruckLoad: 3,
    ChargeBasis.ltlKilo: 4,
    ChargeBasis.ltlCbm: 5,
    ChargeBasis.fullContainerLoad: 6,
    ChargeBasis.lclKilo: 7,
    ChargeBasis.lclCbm: 8,
  };

  static const Map<PricingOption, int> chargeOptionIds = {
    PricingOption.fixedBreakweight: 1,
    PricingOption.minimumFixedBreakweight: 2,
    PricingOption.flatBreakweight: 3,
    PricingOption.cummulativeBreakweight: 4,
    PricingOption.minimumCummulativeBreakweight: 5,
    PricingOption.excessBreakweight: 6,
    PricingOption.minimumExcessBreakweight: 7,
    PricingOption.routeBased: 16,
    PricingOption.timeBased: 17,
  };

  static const List<PricingOption> _bracketPricingOptions = [
    PricingOption.fixedBreakweight,
    PricingOption.minimumFixedBreakweight,
    PricingOption.flatBreakweight,
    PricingOption.cummulativeBreakweight,
    PricingOption.minimumCummulativeBreakweight,
    PricingOption.excessBreakweight,
    PricingOption.minimumExcessBreakweight,
  ];

  /// `types_charge_basis_charge_options` pivot — which [PricingOption]
  /// values are valid for a given [ChargeBasis]. Confirmed against the
  /// live backend's validation logic (`RatrixRateController::
  /// isValidChargeOptionForBasis`, which checks this exact DB table) for
  /// Full Container Load (Route-Based/Time-Based, ids 16-17) and every
  /// other charge basis using the 7 bracket-pricing options.
  ///
  /// Full Truck Load is deliberately left as an **empty list**, not a
  /// guess: the RatrixSeeder.php file that would normally document its
  /// real ids (8-15) is known to be stale/out of date with the live DB, so
  /// there is currently no trustworthy source for what FTL's valid
  /// options actually are. An empty list here means "no known-valid
  /// options" — the UI disables the Pricing Option picker entirely for
  /// this basis rather than guessing and risking another 422. Replace this
  /// entry with the real list once confirmed against the live DB (query
  /// `types_charge_basis_charge_options` where charge_basis_id = 3) or the
  /// backend team.
  static const Map<ChargeBasis, List<PricingOption>> pricingOptionsByChargeBasis = {
    ChargeBasis.kilo: _bracketPricingOptions,
    ChargeBasis.cbm: _bracketPricingOptions,
    ChargeBasis.fullTruckLoad: [],
    ChargeBasis.ltlKilo: _bracketPricingOptions,
    ChargeBasis.ltlCbm: _bracketPricingOptions,
    ChargeBasis.fullContainerLoad: [PricingOption.routeBased, PricingOption.timeBased],
    ChargeBasis.lclKilo: _bracketPricingOptions,
    ChargeBasis.lclCbm: _bracketPricingOptions,
  };

  /// Charge bases with no known-valid pricing options yet (an empty entry
  /// in [pricingOptionsByChargeBasis]) — the Charge Basis picker disables
  /// and sorts these to the end instead of letting them be selected only
  /// to hit a dead-end Pricing Option field.
  static final Set<ChargeBasis> chargeBasisNotYetImplemented = {
    for (final e in pricingOptionsByChargeBasis.entries)
      if (e.value.isEmpty) e.key,
  };

  /// [chargeBasisNotYetImplemented] plus Full Container Load (options are
  /// confirmed, but no pricing formula for them exists in the calculator).
  static final Set<ChargeBasis> chargeBasisDisabledInWizard = {
    ...chargeBasisNotYetImplemented,
    ChargeBasis.fullContainerLoad,
  };

  /// `types_freight_mode_charge_basis` pivot — which [ChargeBasis] values are
  /// valid for a given [FreightMode]. The wizard's charge-basis picker must
  /// only offer these, and reset to the first valid option whenever the
  /// freight mode changes to one that no longer allows the current selection.
  static const Map<FreightMode, List<ChargeBasis>> chargeBasisOptionsByFreightMode = {
    FreightMode.air: [ChargeBasis.kilo, ChargeBasis.cbm],
    FreightMode.land: [ChargeBasis.fullTruckLoad, ChargeBasis.ltlKilo, ChargeBasis.ltlCbm],
    FreightMode.sea: [ChargeBasis.fullContainerLoad, ChargeBasis.lclKilo, ChargeBasis.lclCbm],
  };

  /// `types_freight_mode_service_mode` pivot — which [ServiceMode] values are
  /// valid for a given [FreightMode]. Land only ever allows Door to Door.
  static const Map<FreightMode, List<ServiceMode>> serviceModeOptionsByFreightMode = {
    FreightMode.air: ServiceMode.values,
    FreightMode.land: [ServiceMode.doorToDoor],
    FreightMode.sea: ServiceMode.values,
  };

  // ---------------------------------------------------------------------
  // Reverse lookups (id -> enum), used when loading an existing rate for
  // edit. Derived from the forward maps above rather than hardcoding a
  // second copy of the id numbers, so the two can never drift apart.
  // ---------------------------------------------------------------------

  static final Map<int, FreightMode> freightModeFromId = {
    for (final e in freightModeIds.entries) e.value: e.key,
  };

  static final Map<int, ServiceMode> serviceModeFromId = {
    for (final e in serviceModeIds.entries) e.value: e.key,
  };

  static final Map<int, ChargeBasis> chargeBasisFromId = {
    for (final e in chargeBasisIds.entries) e.value: e.key,
  };

  static final Map<int, PricingOption> pricingOptionFromId = {
    for (final e in chargeOptionIds.entries) e.value: e.key,
  };
}
