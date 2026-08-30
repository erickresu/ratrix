import 'package:freezed_annotation/freezed_annotation.dart';

part 'addon_field_def.freezed.dart';

@freezed
abstract class AddonFieldDef with _$AddonFieldDef {
  const factory AddonFieldDef({
    required String key,
    required String label,
    @Default(false) bool hasToggle,
  }) = _AddonFieldDef;
}

@freezed
abstract class AddonGroupDef with _$AddonGroupDef {
  const factory AddonGroupDef({required String title, required List<AddonFieldDef> fields}) = _AddonGroupDef;
}

const addonGroupDefs = <AddonGroupDef>[
  AddonGroupDef(
    title: 'Transport & Delivery Charges',
    fields: [
      AddonFieldDef(key: 'fuel', label: 'Fuel Surcharge (FSC/BAF)', hasToggle: true),
      AddonFieldDef(key: 'security', label: 'Security Surcharge'),
      AddonFieldDef(key: 'delivery', label: 'Delivery Fee'),
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
    title: 'Packing & Protection Charges',
    fields: [
      AddonFieldDef(key: 'crating', label: 'Crating Fee'),
      AddonFieldDef(key: 'packing', label: 'Packing Fee'),
      AddonFieldDef(key: 'hazardous', label: 'Hazardous Goods Handling Fee'),
    ],
  ),
  AddonGroupDef(
    title: 'Terminal, Port & Other Charges',
    fields: [
      AddonFieldDef(key: 'thc', label: 'Air Terminal Handling Fee (THC)'),
      AddonFieldDef(key: 'demurrage', label: 'Demurrage/Detention Fee'),
      AddonFieldDef(key: 'arrastre', label: 'Arrastre Charge'),
      AddonFieldDef(key: 'othersNonVat', label: 'Others Non-VAT'),
    ],
  ),
];
