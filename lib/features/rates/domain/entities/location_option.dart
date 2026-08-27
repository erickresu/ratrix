import 'package:freezed_annotation/freezed_annotation.dart';

part 'location_option.freezed.dart';

int? _asInt(dynamic value) {
  if (value == null) return null;
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value.toString());
}

@freezed
abstract class LocationOption with _$LocationOption {
  const factory LocationOption({
    String? id,
    required String value,
    required String label,
    String? type, // island | region | province | barangay | city | iata
    int? islandId,
    int? regionId,
    int? provinceId,
    int? cityId,
    int? barangayId,
    String? zipcode,
    String? address1,
    String? iata,
    String? code,
    String? cityName,
    String? provinceName,
    String? islandName,
  }) = _LocationOption;

  const LocationOption._();

  /// Matches the real `GET api/locations/search` row shape, which nests
  /// parent geography inline rather than sending flat `*_id`/`*_name`
  /// fields — a city row looks like
  /// `{id, name, province: {id, name, region: {id, name, island: {id, name}}}, type}`.
  /// A province/island row IS its own geography level — it has no nested
  /// object for itself, only for its parents — so which field gets the
  /// row's own `id` depends entirely on `type`. Applying one fallback
  /// (`?? json['id']`) to every field regardless of type was the bug: a
  /// province row would leak its own id into `cityId` too (no city nested
  /// under a province row to override it), and an island row's `islandId`
  /// had no fallback at all since islands are never nested under anything.
  ///
  /// `iata`-type rows have an unconfirmed shape (no sample seen yet), so
  /// `barangayId` falling back to the row's own id is a best-effort guess
  /// (matches the backend's tier-1 address match, which reads
  /// `address.barangay.IATA`) — may be wrong until verified against a live
  /// `type=iata` response.
  static LocationOption fromJson(Map<String, dynamic> json) {
    final province = json['province'] as Map<String, dynamic>?;
    final region = province?['region'] as Map<String, dynamic>?;
    final island = region?['island'] as Map<String, dynamic>?;
    final city = json['city'] as Map<String, dynamic>?;
    final name = (json['name'] ?? json['label'] ?? '').toString();
    final type = json['type']?.toString();
    final ownId = _asInt(json['id']);

    return LocationOption(
      id: json['id']?.toString(),
      value: name,
      label: name,
      type: type,
      islandId: _asInt(island?['id']) ?? (type == 'island' ? ownId : null),
      regionId: _asInt(region?['id']) ?? (type == 'region' ? ownId : null),
      provinceId: _asInt(province?['id']) ?? (type == 'province' ? ownId : null),
      cityId: _asInt(city?['id']) ?? (type == 'city' ? ownId : null),
      barangayId: _asInt(json['barangay_id']) ?? (type == 'barangay' || type == 'iata' ? ownId : null),
      zipcode: json['zipcode']?.toString(),
      address1: json['address1']?.toString(),
      iata: json['IATA']?.toString() ?? json['iata']?.toString(),
      code: json['code']?.toString(),
      cityName: (city?['name'] ?? (type == 'city' ? name : null))?.toString(),
      provinceName: province?['name']?.toString() ?? (type == 'province' ? name : null),
      islandName: island?['name']?.toString() ?? (type == 'island' ? name : null),
    );
  }
}
