part of 'rate_wizard_bloc.dart';

class RateWizardState extends Equatable {
  final bool isCustom;
  final String? clientId;
  final String? clientName;

  final int step;
  final FreightMode? freightMode;
  final ServiceMode serviceMode;
  final ChargeBasis chargeBasis;
  final PricingOption pricingOption;
  final String chargeCodeSuffix;
  final DateTime? expiryDate;

  final String matrixTab;
  final String markup;
  final LocationBasis locationBasis;
  final List<MatrixRow> matrixRows;
  final List<Breakweight> breakweights;
  final int? removeRouteIndex;

  final Map<String, String> addonValues;
  final Map<String, AddonMode> addonModes;

  final ConditionalType? conditionalType;
  final PricingOption conditionalPricingOption;
  final List<MatrixRow> conditionalMatrixRows;
  final List<Breakweight> conditionalBreakweights;

  const RateWizardState({
    required this.isCustom,
    this.clientId,
    this.clientName,
    this.step = 0,
    this.freightMode,
    this.serviceMode = ServiceMode.doorToDoor,
    this.chargeBasis = ChargeBasis.kilo,
    this.pricingOption = PricingOption.fixedBreakweight,
    this.chargeCodeSuffix = '',
    this.expiryDate,
    this.matrixTab = 'standard',
    this.markup = '',
    this.locationBasis = LocationBasis.city,
    this.matrixRows = const [MatrixRow()],
    this.breakweights = const [Breakweight()],
    this.removeRouteIndex,
    this.addonValues = const {},
    this.addonModes = const {},
    this.conditionalType,
    this.conditionalPricingOption = PricingOption.fixedBreakweight,
    this.conditionalMatrixRows = const [MatrixRow()],
    this.conditionalBreakweights = const [Breakweight()],
  });

  String get chargeCodePrefix => '${(freightMode?.name ?? '').toUpperCase()}_${serviceMode.abbreviation}';

  String get fullChargeCode {
    if (chargeCodeSuffix.trim().isEmpty) return chargeCodePrefix;
    final suffix = chargeCodeSuffix.trim().toUpperCase().replaceAll(RegExp(r'\s+'), '_');
    return '${chargeCodePrefix}_$suffix';
  }

  bool get isValid => !isCustom || expiryDate != null;

  RateWizardState copyWith({
    int? step,
    FreightMode? freightMode,
    ServiceMode? serviceMode,
    ChargeBasis? chargeBasis,
    PricingOption? pricingOption,
    String? chargeCodeSuffix,
    DateTime? expiryDate,
    String? matrixTab,
    String? markup,
    LocationBasis? locationBasis,
    List<MatrixRow>? matrixRows,
    List<Breakweight>? breakweights,
    int? removeRouteIndex,
    bool clearRemoveRouteIndex = false,
    Map<String, String>? addonValues,
    Map<String, AddonMode>? addonModes,
    ConditionalType? conditionalType,
    PricingOption? conditionalPricingOption,
    List<MatrixRow>? conditionalMatrixRows,
    List<Breakweight>? conditionalBreakweights,
  }) {
    return RateWizardState(
      isCustom: isCustom,
      clientId: clientId,
      clientName: clientName,
      step: step ?? this.step,
      freightMode: freightMode ?? this.freightMode,
      serviceMode: serviceMode ?? this.serviceMode,
      chargeBasis: chargeBasis ?? this.chargeBasis,
      pricingOption: pricingOption ?? this.pricingOption,
      chargeCodeSuffix: chargeCodeSuffix ?? this.chargeCodeSuffix,
      expiryDate: expiryDate ?? this.expiryDate,
      matrixTab: matrixTab ?? this.matrixTab,
      markup: markup ?? this.markup,
      locationBasis: locationBasis ?? this.locationBasis,
      matrixRows: matrixRows ?? this.matrixRows,
      breakweights: breakweights ?? this.breakweights,
      removeRouteIndex: clearRemoveRouteIndex ? null : (removeRouteIndex ?? this.removeRouteIndex),
      addonValues: addonValues ?? this.addonValues,
      addonModes: addonModes ?? this.addonModes,
      conditionalType: conditionalType ?? this.conditionalType,
      conditionalPricingOption: conditionalPricingOption ?? this.conditionalPricingOption,
      conditionalMatrixRows: conditionalMatrixRows ?? this.conditionalMatrixRows,
      conditionalBreakweights: conditionalBreakweights ?? this.conditionalBreakweights,
    );
  }

  @override
  List<Object?> get props => [
        isCustom,
        clientId,
        clientName,
        step,
        freightMode,
        serviceMode,
        chargeBasis,
        pricingOption,
        chargeCodeSuffix,
        expiryDate,
        matrixTab,
        markup,
        locationBasis,
        matrixRows,
        breakweights,
        removeRouteIndex,
        addonValues,
        addonModes,
        conditionalType,
        conditionalPricingOption,
        conditionalMatrixRows,
        conditionalBreakweights,
      ];
}
