# Rate Wizard: Freight Mode / Charge Basis / Pricing Option rules

## The problem this solves

The rate wizard (Step 0: Rate Setup) has three dropdowns that all depend on
each other:

- **Freight Mode** — Air / Land / Sea
- **Charge Basis** — Kilo, CBM, Full Truck Load, LTL Kilo, LTL CBM, Full
  Container Load, LCL Kilo, LCL CBM
- **Pricing Option** ("Charge Option" in the backend) — Fixed/Flat/
  Cumulative/Excess Breakweight Pricing, Route-Based Pricing, Time-Based
  Pricing, etc.

The backend does **not** allow every combination of these three. It enforces
its own valid-pairs rules server-side, and if the app lets a user pick an
invalid combo, the create/update-rate call fails at the very last step with
a 422 like:

```
{"charge_option_id": ["The selected charge option is not valid for the selected charge basis."]}
```

This is exactly what happened before this fix: Land + Full Truck Load +
Flat Breakweight Pricing is not a valid combo, but the app let you pick it
anyway and only found out on submit.

## Where the real rules live

The source of truth is the backend's seeder, not this app:

```
/Users/erickresurreccion/cerrov5-server/database/seeders/RatrixSeeder.php
```

That file directly populates the pivot tables the backend validates
against:

- `types_freight_mode_charge_basis` — which Charge Basis values are valid
  for which Freight Mode
- `types_freight_mode_service_mode` — which Service Mode values are valid
  for which Freight Mode
- `types_charge_basis_charge_options` — which Pricing Option values are
  valid for which Charge Basis

**If you need to add or fix a combination, go read that seeder file first.**
Don't guess ids or valid pairs — they're hardcoded there (the backend models
use `incrementing = false` because these ids are seeded, not
auto-generated), so it's the same list every time, not something that
changes per-environment.

## How the app mirrors those rules

All of the id numbers and valid-pairs tables live in one file:

```
lib/features/rates/domain/entities/rates_fk_ids.dart
```

This file has two kinds of maps:

1. **Id maps** — `freightModeIds`, `serviceModeIds`, `chargeBasisIds`,
   `chargeOptionIds`. Each maps a Dart enum value (defined in
   `rates_enums.dart`) to the real numeric id the backend expects. These are
   what get sent in the API payload (`freight_mode_id`, `charge_basis_id`,
   `charge_option_id`, etc.) — see `rate_wizard_payload_mapper.dart`.

2. **Valid-pairs (pivot) maps** — `chargeBasisOptionsByFreightMode`,
   `serviceModeOptionsByFreightMode`, `pricingOptionsByChargeBasis`. Each one
   is `Map<X, List<Y>>` and mirrors one of the backend pivot tables above.
   These are what restrict what the dropdowns are allowed to show.

**The pattern is always the same. If you need to add a new restriction, or
fix an existing one, this is the pattern to copy:**

```dart
static const Map<FreightMode, List<ChargeBasis>> chargeBasisOptionsByFreightMode = {
  FreightMode.air: [ChargeBasis.kilo, ChargeBasis.cbm],
  FreightMode.land: [ChargeBasis.fullTruckLoad, ChargeBasis.ltlKilo, ChargeBasis.ltlCbm],
  FreightMode.sea: [ChargeBasis.fullContainerLoad, ChargeBasis.lclKilo, ChargeBasis.lclCbm],
};
```

## How a restriction gets applied (3 places, every time)

Every one of these pivot maps needs to be wired into exactly 3 places to
actually work end-to-end. Miss one and you get either a dropdown that shows
invalid options, or a stale selection that doesn't get reset when it should.

### 1. The dropdown only shows valid options

In the widget (e.g. `step0_rate_setup.dart`), compute the filtered list from
the pivot map, then render only those options:

```dart
final chargeBasisOptions = state.freightMode == null
    ? ChargeBasis.values
    : RatesFkIds.chargeBasisOptionsByFreightMode[state.freightMode]!;
```

```dart
ShadSelect<ChargeBasis>(
  key: ValueKey('charge-basis-${state.freightMode}'), // see note below
  initialValue: state.chargeBasis,
  selectedOptionBuilder: (context, value) => Text(value.label),
  onChanged: (value) {
    if (value != null) bloc.add(ChargeBasisChanged(value));
  },
  options: [
    for (final b in chargeBasisOptions)
      ShadOption(value: b, child: Text(b.label)),
  ],
)
```

**Why the `ValueKey`:** `ShadSelect` (like most Flutter dropdown widgets)
keeps its own internal display state. If the valid option list changes out
from under it (e.g. Freight Mode changes from Air to Land, so Charge
Basis's valid list changes) but the widget itself isn't rebuilt as a new
instance, it can keep showing a stale label. Keying it on whatever value
the restriction depends on (`state.freightMode` here) forces Flutter to
throw away the old widget and build a fresh one whenever that value
changes.

### 2. The bloc resets the selection if it becomes invalid

When the thing a dropdown depends on changes, the bloc must check: is the
*currently selected* value still in the new valid list? If yes, keep it (so
we don't clobber a still-valid user choice). If no, fall back to the first
valid option.

```dart
on<FreightModeChanged>((event, emit) {
  final validChargeBases = RatesFkIds.chargeBasisOptionsByFreightMode[event.mode]!;
  emit(state.copyWith(
    freightMode: event.mode,
    chargeBasis: validChargeBases.contains(state.chargeBasis)
        ? state.chargeBasis
        : validChargeBases.first,
  ));
});
```

This is why `PricingOptionChanged`'s sibling, `ChargeBasisChanged`, also
needs to reset `pricingOption` now — Charge Basis changing can invalidate
whichever Pricing Option was selected, exactly the same way Freight Mode
changing can invalidate Charge Basis. **A change can cascade**: changing
Freight Mode can force Charge Basis to change, which can in turn force
Pricing Option to change. Each handler only needs to look one level down —
`FreightModeChanged` resets `chargeBasis` first, then uses that *new*
`chargeBasis` value to also reset `pricingOption`, so the cascade happens
in one place instead of needing Charge Basis's own reset logic to fire a
second time.

### 3. The submit payload just uses whatever the id maps say

By the time the user hits Publish, the state fields are already guaranteed
valid (steps 1 and 2 keep them that way at all times) — the payload mapper
doesn't do any additional validation, it just looks up ids:

```dart
final chargeBasisId = RatesFkIds.chargeBasisIds[chargeBasis];
final chargeOptionId = RatesFkIds.chargeOptionIds[pricingOption];
```

If you add a new enum value but forget to add it to the id map, the lookup
returns `null` and the field is silently omitted from the payload (see
`rate_wizard_payload_mapper.dart`) — which will likely fail differently at
the backend (a required-field error instead of an invalid-combo error), so
always add new enum values to **both** the id map and whichever pivot
map(s) apply to it.

## Current state of the pivot maps (as of this writing)

| Pivot | Status |
|---|---|
| `chargeBasisOptionsByFreightMode` | Fully wired for Air, Land, Sea |
| `serviceModeOptionsByFreightMode` | Fully wired for Air, Land, Sea |
| `pricingOptionsByChargeBasis` | Fully wired for **Sea** (Full Container Load → Route-Based/Time-Based; LCL Kilo/CBM → the 7 bracket options). **Land's Full Truck Load is NOT yet fixed** — it's still mapped to the 7 bracket options as a placeholder, which is what caused the original bug report. The real valid set for Full Truck Load is ids 8-15 (distance-based options) in the seeder, not yet added to `PricingOption` or this map. This is the next thing to fix, following the exact same pattern as Sea. |

## Extending this to Land (the next step)

1. Read `types_charge_options` ids 8-15 and the
   `types_charge_basis_charge_options` rows for `charge_basis_id = 3` (Full
   Truck Load) in the seeder — these are the real names/ids, don't guess.
2. Add each missing option as a new `PricingOption` enum value in
   `rates_enums.dart`.
3. Add each one's real id to `chargeOptionIds` in `rates_fk_ids.dart`.
4. Update `pricingOptionsByChargeBasis[ChargeBasis.fullTruckLoad]` to point
   at the new list instead of `_bracketPricingOptions`.
5. That's it — the dropdown, the bloc reset logic, and the submit payload
   all already read from this same map, so nothing else needs to change.

## A note on `step3_conditional_addons.dart`

The Conditional Add-ons step has its own separate dropdown
(`conditionalPricingOption`) that also renders `PricingOption` values, but
it currently has **no restriction logic at all** — it always shows every
`PricingOption.values`, regardless of Charge Basis. This hasn't been
reported as broken, so it hasn't been touched, but it has the exact same
latent bug shape as the one this doc describes fixing. If it ever gets
reported, the fix is identical: reuse `pricingOptionsByChargeBasis`, same 3
places (dropdown filter, bloc reset, nothing needed at submit).
