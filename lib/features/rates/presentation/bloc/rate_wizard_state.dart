part of 'rate_wizard_bloc.dart';

class RateWizardState extends Equatable {
  final bool isCustom;
  final String? clientId;
  final String? clientName;

  /// The id of the rate being edited, non-null only when the wizard was
  /// opened from an existing `RatrixRate` (edit mode). When set, submit
  /// calls `updateRate` instead of `createRate`.
  final String? editingRateId;

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
  final List<String> phCities;
  final List<String> phProvinces;
  final List<MatrixRow> matrixRows;
  final List<Breakweight> breakweights;
  final int? removeRouteIndex;

  final Map<String, String> addonValues;
  final Map<String, AddonMode> addonModes;

  final ConditionalType? conditionalType;
  final PricingOption conditionalPricingOption;
  final List<MatrixRow> conditionalMatrixRows;
  final List<Breakweight> conditionalBreakweights;

  final bool isSubmitting;
  final String? submitError;
  final bool submitSucceeded;
  final bool lastSubmitStayedOnPage;

  const RateWizardState({
    required this.isCustom,
    this.clientId,
    this.clientName,
    this.editingRateId,
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
    this.phCities = const [],
    this.phProvinces = const [],
    this.matrixRows = const [MatrixRow()],
    this.breakweights = const [Breakweight()],
    this.removeRouteIndex,
    this.addonValues = const {},
    this.addonModes = const {},
    this.conditionalType,
    this.conditionalPricingOption = PricingOption.fixedBreakweight,
    this.conditionalMatrixRows = const [MatrixRow()],
    this.conditionalBreakweights = const [Breakweight()],
    this.isSubmitting = false,
    this.submitError,
    this.submitSucceeded = false,
    this.lastSubmitStayedOnPage = false,
  });

  String get chargeCodePrefix =>
      '${(freightMode?.name ?? '').toUpperCase()}_${serviceMode.abbreviation}';

  String get fullChargeCode {
    if (chargeCodeSuffix.trim().isEmpty) return chargeCodePrefix;
    final suffix = chargeCodeSuffix.trim().toUpperCase().replaceAll(
      RegExp(r'\s+'),
      '_',
    );
    return '${chargeCodePrefix}_$suffix';
  }

  bool get isValid => !isCustom || expiryDate != null;

  /// Freight mode drives charge-code prefix and which addon fields apply
  /// (e.g. sea vs air THC) — later steps don't make sense without it, so
  /// step 0 can't be left until it's picked.
  bool get canLeaveStep0 => freightMode != null;

  /// True when [pricingOption] is one of the 3 "Minimum …" breakweight
  /// variants — just informational here, a reminder that the first
  /// breakweight bracket's rate should be entered as a flat fee for these.
  bool get requiresMinimumCharge => const {
    PricingOption.minimumFixedBreakweight,
    PricingOption.minimumCummulativeBreakweight,
    PricingOption.minimumExcessBreakweight,
  }.contains(pricingOption);

  List<String> get locationSuggestions => switch (locationBasis) {
    LocationBasis.city => phCities,
    LocationBasis.province => phProvinces,
    LocationBasis.code => const [],
  };

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
    List<String>? phCities,
    List<String>? phProvinces,
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
    bool? isSubmitting,
    String? submitError,
    bool clearSubmitError = false,
    bool? submitSucceeded,
    bool clearSubmitSucceeded = false,
    bool? lastSubmitStayedOnPage,
  }) {
    return RateWizardState(
      isCustom: isCustom,
      clientId: clientId,
      clientName: clientName,
      editingRateId: editingRateId,
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
      phCities: phCities ?? this.phCities,
      phProvinces: phProvinces ?? this.phProvinces,
      matrixRows: matrixRows ?? this.matrixRows,
      breakweights: breakweights ?? this.breakweights,
      removeRouteIndex: clearRemoveRouteIndex
          ? null
          : (removeRouteIndex ?? this.removeRouteIndex),
      addonValues: addonValues ?? this.addonValues,
      addonModes: addonModes ?? this.addonModes,
      conditionalType: conditionalType ?? this.conditionalType,
      conditionalPricingOption:
          conditionalPricingOption ?? this.conditionalPricingOption,
      conditionalMatrixRows:
          conditionalMatrixRows ?? this.conditionalMatrixRows,
      conditionalBreakweights:
          conditionalBreakweights ?? this.conditionalBreakweights,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      submitError: clearSubmitError ? null : (submitError ?? this.submitError),
      submitSucceeded: clearSubmitSucceeded
          ? false
          : (submitSucceeded ?? this.submitSucceeded),
      lastSubmitStayedOnPage:
          lastSubmitStayedOnPage ?? this.lastSubmitStayedOnPage,
    );
  }

  @override
  List<Object?> get props => [
    isCustom,
    clientId,
    clientName,
    editingRateId,
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
    phCities,
    phProvinces,
    matrixRows,
    breakweights,
    removeRouteIndex,
    addonValues,
    addonModes,
    conditionalType,
    conditionalPricingOption,
    conditionalMatrixRows,
    conditionalBreakweights,
    isSubmitting,
    submitError,
    submitSucceeded,
    lastSubmitStayedOnPage,
  ];
}
