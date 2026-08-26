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

  /// Origin and Destination each have their own independent search-type
  /// filter (e.g. Origin by City, Destination by IATA Code) and their own
  /// result/loading state, since both fields can now search simultaneously
  /// with different types rather than sharing one "whichever field has
  /// focus" result set.
  final LocationSearchType originSearchType;
  final LocationSearchType destinationSearchType;
  final List<LocationOption> originSearchResults;
  final List<LocationOption> destinationSearchResults;
  final bool originSearchLoading;
  final bool destinationSearchLoading;
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

  /// The `charge_code` of the rate as returned by the API on a successful
  /// create/update — the API's success response has no message field at
  /// all, so this is used to make the "saved" toast specific to the real
  /// object the backend actually returned, rather than a generic string.
  final String? savedChargeCode;

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
    this.originSearchType = LocationSearchType.island,
    this.destinationSearchType = LocationSearchType.island,
    this.originSearchResults = const [],
    this.destinationSearchResults = const [],
    this.originSearchLoading = false,
    this.destinationSearchLoading = false,
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
    this.savedChargeCode,
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
    LocationSearchType? originSearchType,
    LocationSearchType? destinationSearchType,
    List<LocationOption>? originSearchResults,
    List<LocationOption>? destinationSearchResults,
    bool? originSearchLoading,
    bool? destinationSearchLoading,
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
    String? savedChargeCode,
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
      originSearchType: originSearchType ?? this.originSearchType,
      destinationSearchType: destinationSearchType ?? this.destinationSearchType,
      originSearchResults: originSearchResults ?? this.originSearchResults,
      destinationSearchResults: destinationSearchResults ?? this.destinationSearchResults,
      originSearchLoading: originSearchLoading ?? this.originSearchLoading,
      destinationSearchLoading: destinationSearchLoading ?? this.destinationSearchLoading,
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
      savedChargeCode: savedChargeCode ?? this.savedChargeCode,
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
    originSearchType,
    destinationSearchType,
    originSearchResults,
    destinationSearchResults,
    originSearchLoading,
    destinationSearchLoading,
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
    savedChargeCode,
  ];
}
