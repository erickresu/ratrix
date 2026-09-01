part of 'shipping_calculator_bloc.dart';

sealed class ShippingCalculatorEvent extends Equatable {
  const ShippingCalculatorEvent();

  @override
  List<Object?> get props => [];
}

class CalcRatesRequested extends ShippingCalculatorEvent {
  const CalcRatesRequested();
}

class CalcRateCategoryChanged extends ShippingCalculatorEvent {
  const CalcRateCategoryChanged(this.rateType);

  final RateType rateType;

  @override
  List<Object?> get props => [rateType];
}

class CalcFreightModeChanged extends ShippingCalculatorEvent {
  const CalcFreightModeChanged(this.mode);

  final FreightMode mode;

  @override
  List<Object?> get props => [mode];
}

class CalcServiceModeChanged extends ShippingCalculatorEvent {
  const CalcServiceModeChanged(this.mode);

  final ServiceMode mode;

  @override
  List<Object?> get props => [mode];
}

class CalcServiceLevelChanged extends ShippingCalculatorEvent {
  const CalcServiceLevelChanged(this.level);

  final ServiceLevel level;

  @override
  List<Object?> get props => [level];
}

class CalcRateTableChanged extends ShippingCalculatorEvent {
  const CalcRateTableChanged(this.rate);

  final ClientRate rate;

  @override
  List<Object?> get props => [rate];
}

class CalcOriginChanged extends ShippingCalculatorEvent {
  const CalcOriginChanged(this.value);

  final String value;

  @override
  List<Object?> get props => [value];
}

class CalcDestinationChanged extends ShippingCalculatorEvent {
  const CalcDestinationChanged(this.value);

  final String value;

  @override
  List<Object?> get props => [value];
}

class CalcDimensionAdded extends ShippingCalculatorEvent {
  const CalcDimensionAdded();
}

class CalcDimensionRemoved extends ShippingCalculatorEvent {
  const CalcDimensionRemoved(this.index);

  final int index;

  @override
  List<Object?> get props => [index];
}

class CalcDimensionLengthChanged extends ShippingCalculatorEvent {
  const CalcDimensionLengthChanged(this.index, this.value);

  final int index;
  final String value;

  @override
  List<Object?> get props => [index, value];
}

class CalcDimensionWidthChanged extends ShippingCalculatorEvent {
  const CalcDimensionWidthChanged(this.index, this.value);

  final int index;
  final String value;

  @override
  List<Object?> get props => [index, value];
}

class CalcDimensionHeightChanged extends ShippingCalculatorEvent {
  const CalcDimensionHeightChanged(this.index, this.value);

  final int index;
  final String value;

  @override
  List<Object?> get props => [index, value];
}

class CalcDimensionPackagesChanged extends ShippingCalculatorEvent {
  const CalcDimensionPackagesChanged(this.index, this.value);

  final int index;
  final String value;

  @override
  List<Object?> get props => [index, value];
}

class CalcDivisorChanged extends ShippingCalculatorEvent {
  const CalcDivisorChanged(this.value);

  final String value;

  @override
  List<Object?> get props => [value];
}

class CalcWeightChanged extends ShippingCalculatorEvent {
  const CalcWeightChanged(this.value);

  final String value;

  @override
  List<Object?> get props => [value];
}

/// "Use this value" in the CBM popup — copies the computed volumetric
/// weight into the main Chargeable Weight field.
class CalcCbmResultApplied extends ShippingCalculatorEvent {
  const CalcCbmResultApplied();
}

class CalcDeclaredValueChanged extends ShippingCalculatorEvent {
  const CalcDeclaredValueChanged(this.value);

  final String value;

  @override
  List<Object?> get props => [value];
}

class CalcSubmitRequested extends ShippingCalculatorEvent {
  const CalcSubmitRequested();
}

class CalcRoundedDisplayToggled extends ShippingCalculatorEvent {
  const CalcRoundedDisplayToggled(this.rounded);

  final bool rounded;

  @override
  List<Object?> get props => [rounded];
}

class CalcVatModeChanged extends ShippingCalculatorEvent {
  const CalcVatModeChanged(this.mode);

  final VatMode mode;

  @override
  List<Object?> get props => [mode];
}

class CalcVatInclusiveToggled extends ShippingCalculatorEvent {
  const CalcVatInclusiveToggled(this.inclusive);

  final bool inclusive;

  @override
  List<Object?> get props => [inclusive];
}

class CalcResultDismissed extends ShippingCalculatorEvent {
  const CalcResultDismissed();
}

/// Fired once the calculating popup finishes (or is skipped) on desktop —
/// lets the docked `FreightBreakdownPanel` show the already-computed
/// result, which up to that point stays hidden behind the popup's blur
/// even though `calcResult` was set the moment Calculate was pressed.
class CalcResultRevealed extends ShippingCalculatorEvent {
  const CalcResultRevealed();
}

class CalcFormReset extends ShippingCalculatorEvent {
  const CalcFormReset();
}
