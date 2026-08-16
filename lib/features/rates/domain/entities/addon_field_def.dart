class AddonFieldDef {
  const AddonFieldDef({
    required this.key,
    required this.label,
    this.hasToggle = false,
  });

  final String key;
  final String label;
  final bool hasToggle;
}

class AddonGroupDef {
  const AddonGroupDef({required this.title, required this.fields});

  final String title;
  final List<AddonFieldDef> fields;
}

const addonGroupDefs = <AddonGroupDef>[
  AddonGroupDef(
    title: 'Transport & Base Charges',
    fields: [
      AddonFieldDef(key: 'fuel', label: 'Fuel Surcharge (FSC/BAF)', hasToggle: true),
      AddonFieldDef(key: 'security', label: 'Security Surcharge'),
    ],
  ),
  AddonGroupDef(
    title: 'Documentation & Administrative Charges',
    fields: [
      AddonFieldDef(key: 'booking', label: 'Booking/Handling Fee'),
      AddonFieldDef(key: 'documentation', label: 'Documentation Fee'),
      AddonFieldDef(key: 'permit', label: 'Permit Fee'),
      AddonFieldDef(key: 'insurance', label: 'Insurance (Cargo)'),
      AddonFieldDef(key: 'valuation', label: 'Valuation', hasToggle: true),
      AddonFieldDef(key: 'waybill', label: 'Waybill Fee'),
    ],
  ),
  AddonGroupDef(
    title: 'Pickup & Delivery-Related Charges',
    fields: [AddonFieldDef(key: 'delivery', label: 'Delivery Fee')],
  ),
  AddonGroupDef(
    title: 'Packing & Protection Charges',
    fields: [
      AddonFieldDef(key: 'crating', label: 'Crating Fee'),
      AddonFieldDef(key: 'packing', label: 'Packing Fee'),
    ],
  ),
  AddonGroupDef(
    title: 'Terminal, Port & Infrastructure Charges',
    fields: [
      AddonFieldDef(key: 'thc', label: 'Air Terminal Handling Fee (THC)'),
      AddonFieldDef(key: 'demurrage', label: 'Demurrage/Detention Fee'),
    ],
  ),
  AddonGroupDef(
    title: 'Additional Fees',
    fields: [
      AddonFieldDef(key: 'hazardous', label: 'Hazardous Goods Handling Fee'),
      AddonFieldDef(key: 'othersNonVat', label: 'Others Non-VAT'),
    ],
  ),
];
