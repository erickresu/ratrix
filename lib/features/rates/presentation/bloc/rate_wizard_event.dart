part of 'rate_wizard_bloc.dart';

sealed class RateWizardEvent extends Equatable {
  const RateWizardEvent();

  @override
  List<Object?> get props => [];
}

class WizardStepChanged extends RateWizardEvent {
  const WizardStepChanged(this.step);

  final int step;

  @override
  List<Object?> get props => [step];
}

class WizardNextStepRequested extends RateWizardEvent {
  const WizardNextStepRequested();
}

class WizardBackStepRequested extends RateWizardEvent {
  const WizardBackStepRequested();
}

class FreightModeChanged extends RateWizardEvent {
  const FreightModeChanged(this.mode);

  final FreightMode mode;

  @override
  List<Object?> get props => [mode];
}

class ServiceModeChanged extends RateWizardEvent {
  const ServiceModeChanged(this.mode);

  final ServiceMode mode;

  @override
  List<Object?> get props => [mode];
}

class ChargeBasisChanged extends RateWizardEvent {
  const ChargeBasisChanged(this.basis);

  final ChargeBasis basis;

  @override
  List<Object?> get props => [basis];
}

class PricingOptionChanged extends RateWizardEvent {
  const PricingOptionChanged(this.option);

  final PricingOption option;

  @override
  List<Object?> get props => [option];
}

class ChargeCodeSuffixChanged extends RateWizardEvent {
  const ChargeCodeSuffixChanged(this.value);

  final String value;

  @override
  List<Object?> get props => [value];
}

class ExpiryDateChanged extends RateWizardEvent {
  const ExpiryDateChanged(this.date);

  final DateTime date;

  @override
  List<Object?> get props => [date];
}

class ServiceLevelChanged extends RateWizardEvent {
  const ServiceLevelChanged(this.level);

  final ServiceLevel level;

  @override
  List<Object?> get props => [level];
}

/// Computes every row's Express rate from its Standard rate + the current
/// [RateWizardState.markup] percentage — a bulk fill, not a lock: cells can
/// still be hand-edited afterward via `CellChanged(isExpress: true)`. Rows
/// whose Standard cell isn't a parseable number are left untouched.
class MarkupApplied extends RateWizardEvent {
  const MarkupApplied();
}

class MarkupChanged extends RateWizardEvent {
  const MarkupChanged(this.value);

  final String value;

  @override
  List<Object?> get props => [value];
}

/// Distinguishes which of the two independent Origin/Destination search
/// pipelines an event applies to — each field has its own filter type,
/// results, and loading state.
enum LocationField { origin, destination }

class LocationSearchTypeChanged extends RateWizardEvent {
  const LocationSearchTypeChanged(this.field, this.searchType);

  final LocationField field;
  final LocationSearchType searchType;

  @override
  List<Object?> get props => [field, searchType];
}

class LocationSearchQueryChanged extends RateWizardEvent {
  const LocationSearchQueryChanged(this.field, this.query);

  final LocationField field;
  final String query;

  @override
  List<Object?> get props => [field, query];
}

class LocationSearchCleared extends RateWizardEvent {
  const LocationSearchCleared(this.field);

  final LocationField field;

  @override
  List<Object?> get props => [field];
}

/// Fired when the user picks a suggestion from the Origin field's overlay.
/// Carries the full [LocationOption] (not just its display string) so the
/// bloc can store it on `MatrixRow.originOption` for the submit payload.
class OriginLocationSelected extends RateWizardEvent {
  const OriginLocationSelected(this.rowIndex, this.option, this.displayText);

  final int rowIndex;
  final LocationOption option;
  final String displayText;

  @override
  List<Object?> get props => [rowIndex, option, displayText];
}

class DestinationLocationSelected extends RateWizardEvent {
  const DestinationLocationSelected(this.rowIndex, this.option, this.displayText);

  final int rowIndex;
  final LocationOption option;
  final String displayText;

  @override
  List<Object?> get props => [rowIndex, option, displayText];
}

class RouteAdded extends RateWizardEvent {
  const RouteAdded();
}

class RouteRemoveRequested extends RateWizardEvent {
  const RouteRemoveRequested(this.index);

  final int index;

  @override
  List<Object?> get props => [index];
}

class RouteRemoveCancelled extends RateWizardEvent {
  const RouteRemoveCancelled();
}

class RouteRemoveConfirmed extends RateWizardEvent {
  const RouteRemoveConfirmed();
}

class OriginChanged extends RateWizardEvent {
  const OriginChanged(this.rowIndex, this.value);

  final int rowIndex;
  final String value;

  @override
  List<Object?> get props => [rowIndex, value];
}

class DestinationChanged extends RateWizardEvent {
  const DestinationChanged(this.rowIndex, this.value);

  final int rowIndex;
  final String value;

  @override
  List<Object?> get props => [rowIndex, value];
}

class CellChanged extends RateWizardEvent {
  const CellChanged(
    this.rowIndex,
    this.breakweightIndex,
    this.value, {
    this.isExpress = false,
  });

  final int rowIndex;
  final int breakweightIndex;
  final String value;

  /// True when editing the Express-tier rate column
  /// ([MatrixRow.expressRates]) rather than the Standard one
  /// ([MatrixRow.rates]).
  final bool isExpress;

  @override
  List<Object?> get props => [rowIndex, breakweightIndex, value, isExpress];
}

class BreakweightAdded extends RateWizardEvent {
  const BreakweightAdded();
}

class BreakweightRemoved extends RateWizardEvent {
  const BreakweightRemoved(this.index);

  final int index;

  @override
  List<Object?> get props => [index];
}

class BreakweightMinChanged extends RateWizardEvent {
  const BreakweightMinChanged(this.index, this.value);

  final int index;
  final String value;

  @override
  List<Object?> get props => [index, value];
}

class BreakweightMaxChanged extends RateWizardEvent {
  const BreakweightMaxChanged(this.index, this.value);

  final int index;
  final String value;

  @override
  List<Object?> get props => [index, value];
}

class AddonValueChanged extends RateWizardEvent {
  const AddonValueChanged(this.key, this.value);

  final String key;
  final String value;

  @override
  List<Object?> get props => [key, value];
}

class AddonModeChanged extends RateWizardEvent {
  const AddonModeChanged(this.key, this.mode);

  final String key;
  final AddonMode mode;

  @override
  List<Object?> get props => [key, mode];
}

class ConditionalTypeChanged extends RateWizardEvent {
  const ConditionalTypeChanged(this.type);

  final ConditionalType type;

  @override
  List<Object?> get props => [type];
}

class ConditionalPricingOptionChanged extends RateWizardEvent {
  const ConditionalPricingOptionChanged(this.option);

  final PricingOption option;

  @override
  List<Object?> get props => [option];
}

class ConditionalRouteAdded extends RateWizardEvent {
  const ConditionalRouteAdded();
}

class ConditionalOriginChanged extends RateWizardEvent {
  const ConditionalOriginChanged(this.rowIndex, this.value);

  final int rowIndex;
  final String value;

  @override
  List<Object?> get props => [rowIndex, value];
}

class ConditionalDestinationChanged extends RateWizardEvent {
  const ConditionalDestinationChanged(this.rowIndex, this.value);

  final int rowIndex;
  final String value;

  @override
  List<Object?> get props => [rowIndex, value];
}

/// Mirrors [OriginLocationSelected] for the Conditional Add-ons matrix —
/// carries the full [LocationOption] so it lands on
/// `conditionalMatrixRows[i].originOption` (destination_id/origin_id the
/// backend actually matches ODA/Pickup Fee against), not just the display
/// text `ConditionalOriginChanged` alone would capture.
class ConditionalOriginSelected extends RateWizardEvent {
  const ConditionalOriginSelected(this.rowIndex, this.option, this.displayText);

  final int rowIndex;
  final LocationOption option;
  final String displayText;

  @override
  List<Object?> get props => [rowIndex, option, displayText];
}

class ConditionalDestinationSelected extends RateWizardEvent {
  const ConditionalDestinationSelected(this.rowIndex, this.option, this.displayText);

  final int rowIndex;
  final LocationOption option;
  final String displayText;

  @override
  List<Object?> get props => [rowIndex, option, displayText];
}

class ConditionalCellChanged extends RateWizardEvent {
  const ConditionalCellChanged(this.rowIndex, this.breakweightIndex, this.value);

  final int rowIndex;
  final int breakweightIndex;
  final String value;

  @override
  List<Object?> get props => [rowIndex, breakweightIndex, value];
}

class ConditionalBreakweightAdded extends RateWizardEvent {
  const ConditionalBreakweightAdded();
}

class ConditionalBreakweightRemoved extends RateWizardEvent {
  const ConditionalBreakweightRemoved(this.index);

  final int index;

  @override
  List<Object?> get props => [index];
}

class ConditionalBreakweightMinChanged extends RateWizardEvent {
  const ConditionalBreakweightMinChanged(this.index, this.value);

  final int index;
  final String value;

  @override
  List<Object?> get props => [index, value];
}

class ConditionalBreakweightMaxChanged extends RateWizardEvent {
  const ConditionalBreakweightMaxChanged(this.index, this.value);

  final int index;
  final String value;

  @override
  List<Object?> get props => [index, value];
}

/// Submits the wizard's current state via create/update. When [stayOnPage]
/// is true (the per-step "Save changes" button while editing), the wizard
/// listener skips the post-success navigation back to the dashboard so the
/// user stays on the step they were editing.
class RateSubmitRequested extends RateWizardEvent {
  const RateSubmitRequested({this.stayOnPage = false});

  final bool stayOnPage;

  @override
  List<Object?> get props => [stayOnPage];
}
