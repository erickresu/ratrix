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
  const CalcRateTableChanged(this.chargeCode);

  final String chargeCode;

  @override
  List<Object?> get props => [chargeCode];
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

class CalcLengthChanged extends ShippingCalculatorEvent {
  const CalcLengthChanged(this.value);

  final String value;

  @override
  List<Object?> get props => [value];
}

class CalcWidthChanged extends ShippingCalculatorEvent {
  const CalcWidthChanged(this.value);

  final String value;

  @override
  List<Object?> get props => [value];
}

class CalcHeightChanged extends ShippingCalculatorEvent {
  const CalcHeightChanged(this.value);

  final String value;

  @override
  List<Object?> get props => [value];
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

class CalcDeclaredValueChanged extends ShippingCalculatorEvent {
  const CalcDeclaredValueChanged(this.value);

  final String value;

  @override
  List<Object?> get props => [value];
}

class CalcChargeBasisChanged extends ShippingCalculatorEvent {
  const CalcChargeBasisChanged(this.basis);

  final CalcChargeBasis basis;

  @override
  List<Object?> get props => [basis];
}

class CalcSubmitRequested extends ShippingCalculatorEvent {
  const CalcSubmitRequested();
}
