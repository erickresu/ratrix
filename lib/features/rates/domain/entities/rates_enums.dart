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
  minimumExcessBreakweight('Minimum Excess Breakweight Pricing');

  const PricingOption(this.label);
  final String label;
}

enum LocationBasis {
  city('City'),
  province('Province'),
  code('Internal Code');

  const LocationBasis(this.label);
  final String label;

  // Internal Code matching isn't implemented yet — hide it from the
  // "Match by" control for now. Remove once it's wired up.
  static const enabledValues = [LocationBasis.city, LocationBasis.province];
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

enum RatesView { dashboard, customClients, customClientRates, create }
