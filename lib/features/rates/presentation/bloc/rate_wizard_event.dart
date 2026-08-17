part of 'rate_wizard_bloc.dart';

sealed class RateWizardEvent extends Equatable {
  const RateWizardEvent();

  @override
  List<Object?> get props => [];
}

class PhLocationsLoaded extends RateWizardEvent {
  const PhLocationsLoaded(this.cities, this.provinces);

  final List<String> cities;
  final List<String> provinces;

  @override
  List<Object?> get props => [cities, provinces];
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

class MatrixTabChanged extends RateWizardEvent {
  const MatrixTabChanged(this.tab);

  final String tab;

  @override
  List<Object?> get props => [tab];
}

class MarkupChanged extends RateWizardEvent {
  const MarkupChanged(this.value);

  final String value;

  @override
  List<Object?> get props => [value];
}

class LocationBasisChanged extends RateWizardEvent {
  const LocationBasisChanged(this.basis);

  final LocationBasis basis;

  @override
  List<Object?> get props => [basis];
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
  const CellChanged(this.rowIndex, this.breakweightIndex, this.value);

  final int rowIndex;
  final int breakweightIndex;
  final String value;

  @override
  List<Object?> get props => [rowIndex, breakweightIndex, value];
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
