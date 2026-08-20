part of 'shipping_calculator_bloc.dart';

class ShippingCalculatorState extends Equatable {
  final RateType rateType;
  final FreightMode freightMode;
  final ServiceMode serviceMode;
  final ServiceLevel serviceLevel;

  final List<ClientRate> clientRates;
  final bool ratesLoading;
  final String? selectedChargeCode;

  final String origin;
  final String destination;

  final String length;
  final String width;
  final String height;
  final String divisor;
  final String weight;
  final String declaredValue;
  final CalcChargeBasis chargeBasis;

  final bool resultComputed;
  final String? submitError;

  const ShippingCalculatorState({
    this.rateType = RateType.custom,
    this.freightMode = FreightMode.air,
    this.serviceMode = ServiceMode.doorToDoor,
    this.serviceLevel = ServiceLevel.regular,
    this.clientRates = const [],
    this.ratesLoading = false,
    this.selectedChargeCode,
    this.origin = '',
    this.destination = '',
    this.length = '',
    this.width = '',
    this.height = '',
    this.divisor = '6000',
    this.weight = '',
    this.declaredValue = '',
    this.chargeBasis = CalcChargeBasis.higher,
    this.resultComputed = false,
    this.submitError,
  });

  /// Rate tables (charge codes) available for the currently selected
  /// freight mode + service mode — the calculator only offers a rate table
  /// that was actually saved under this exact combination, so it can't
  /// compute against a rate that doesn't apply to the selected scenario.
  List<ClientRate> get availableRateTables => clientRates
      .where((r) => r.freightMode == freightMode && r.serviceMode == serviceMode)
      .toList();

  ShippingCalculatorState copyWith({
    RateType? rateType,
    FreightMode? freightMode,
    ServiceMode? serviceMode,
    ServiceLevel? serviceLevel,
    List<ClientRate>? clientRates,
    bool? ratesLoading,
    String? selectedChargeCode,
    bool clearRateTable = false,
    String? origin,
    String? destination,
    String? length,
    String? width,
    String? height,
    String? divisor,
    String? weight,
    String? declaredValue,
    CalcChargeBasis? chargeBasis,
    bool? resultComputed,
    String? submitError,
    bool clearSubmitError = false,
  }) {
    return ShippingCalculatorState(
      rateType: rateType ?? this.rateType,
      freightMode: freightMode ?? this.freightMode,
      serviceMode: serviceMode ?? this.serviceMode,
      serviceLevel: serviceLevel ?? this.serviceLevel,
      clientRates: clientRates ?? this.clientRates,
      ratesLoading: ratesLoading ?? this.ratesLoading,
      selectedChargeCode: clearRateTable ? null : (selectedChargeCode ?? this.selectedChargeCode),
      origin: origin ?? this.origin,
      destination: destination ?? this.destination,
      length: length ?? this.length,
      width: width ?? this.width,
      height: height ?? this.height,
      divisor: divisor ?? this.divisor,
      weight: weight ?? this.weight,
      declaredValue: declaredValue ?? this.declaredValue,
      chargeBasis: chargeBasis ?? this.chargeBasis,
      resultComputed: resultComputed ?? this.resultComputed,
      submitError: clearSubmitError ? null : (submitError ?? this.submitError),
    );
  }

  @override
  List<Object?> get props => [
        rateType,
        freightMode,
        serviceMode,
        serviceLevel,
        clientRates,
        ratesLoading,
        selectedChargeCode,
        origin,
        destination,
        length,
        width,
        height,
        divisor,
        weight,
        declaredValue,
        chargeBasis,
        resultComputed,
        submitError,
      ];
}
