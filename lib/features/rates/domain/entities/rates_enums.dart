import 'location_option.dart';

enum FreightMode {
  air('Air'),
  land('Land'),
  sea('Sea');

  const FreightMode(this.label);
  final String label;
}

enum ServiceMode {
  doorToDoor('Door to Door', 'D2D'),
  doorToPort('Door to Port', 'D2P'),
  portToDoor('Port to Door', 'P2D'),
  portToPort('Port to Port', 'P2P');

  const ServiceMode(this.label, this.abbreviation);
  final String label;
  final String abbreviation;
}

enum ChargeBasis {
  kilo('Kilo'),
  cbm('CBM'),
  fullTruckLoad('Full Truck Load'),
  ltlKilo('LTL (Kilo)'),
  ltlCbm('LTL (CBM)'),
  fullContainerLoad('Full Container Load'),
  lclKilo('LCL (Kilo)'),
  lclCbm('LCL (CBM)');

  const ChargeBasis(this.label);
  final String label;
}

enum PricingOption {
  fixedBreakweight('Fixed Breakweight Pricing'),
  minimumFixedBreakweight('Minimum Fixed Breakweight Pricing'),
  flatBreakweight('Flat Breakweight Pricing'),
  cummulativeBreakweight('Cummulative Breakweight Pricing'),
  minimumCummulativeBreakweight('Minimum Cummulative Breakweight Pricing'),
  excessBreakweight('Excess Breakweight Pricing'),
  minimumExcessBreakweight('Minimum Excess Breakweight Pricing'),
  // Full Container Load-only (Sea) options — see RatesFkIds.chargeOptionIds.
  routeBased('Route-Based Pricing'),
  timeBased('Time-Based Pricing');

  const PricingOption(this.label);
  final String label;
}

enum LocationSearchType {
  island('Island', 'island'),
  cityProvince('City, Province', 'city'),
  province('Province', 'province'),
  internalCode('Internal Code', 'iata'),
  iataCode('IATA Code', 'iata'),
  seaPortCode('Sea Port Code', 'iata');

  const LocationSearchType(this.label, this.apiType);

  final String label;

  /// `type` query param sent to `GET api/locations/search`. Internal Code,
  /// IATA Code, and Sea Port Code all send the identical `type=iata`
  /// request — the backend returns one result set for that type, and these
  /// three options only differ in which field of each result gets shown
  /// (see [formatOption]). IATA Code and Sea Port Code are the literal same
  /// case with zero distinction between them anywhere.
  final String apiType;

  String formatOption(LocationOption option) => switch (this) {
        LocationSearchType.iataCode ||
        LocationSearchType.seaPortCode =>
          option.iata ?? option.label,
        LocationSearchType.internalCode =>
          '${option.code ?? ''} — (${option.cityName ?? ''}, ${option.provinceName ?? ''})',
        LocationSearchType.island ||
        LocationSearchType.cityProvince ||
        LocationSearchType.province =>
          option.label,
      };
}

enum AddonMode { exact, percentage }

enum ConditionalType {
  oda('ODA', 'Out of delivery area'),
  pickup('Pickup Fee', 'Non-standard pickup location');

  const ConditionalType(this.label, this.hint);
  final String label;
  final String hint;
}

enum RateType {
  published('Published'),
  custom('Custom');

  const RateType(this.label);
  final String label;
}

enum RateStatus {
  active('Active'),
  expired('Expired');

  const RateStatus(this.label);
  final String label;
}

enum VatStatus {
  inclusive('Inclusive'),
  exclusive('Exclusive');

  const VatStatus(this.label);
  final String label;
}

enum RatesView {
  dashboard,
  customClients,
  customClientRates,
  publishedRates,
  create,
  shippingCalculatorClients,
  shippingCalculatorForm,
  auditTrail,
}

enum ServiceLevel {
  regular('Regular'),
  express('Express');

  const ServiceLevel(this.label);
  final String label;
}

