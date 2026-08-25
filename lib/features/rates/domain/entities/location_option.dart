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
  /// `iata`-type rows have an unconfirmed shape (no sample seen yet), so
  /// their extra fields (`code`, `iata`) are read defensively and may be
  /// wrong until verified against a live `type=iata` response.
  static LocationOption fromJson(Map<String, dynamic> json) {
    final province = json['province'] as Map<String, dynamic>?;
    final region = province?['region'] as Map<String, dynamic>?;
    final island = region?['island'] as Map<String, dynamic>?;
    final city = json['city'] as Map<String, dynamic>?;
    final name = (json['name'] ?? json['label'] ?? '').toString();

    return LocationOption(
      id: json['id']?.toString(),
      value: name,
      label: name,
      type: json['type']?.toString(),
      islandId: _asInt(island?['id']),
      regionId: _asInt(region?['id']),
      provinceId: _asInt(province?['id'] ?? json['id']),
      cityId: _asInt(city?['id'] ?? json['id']),
      barangayId: _asInt(json['barangay_id']),
      zipcode: json['zipcode']?.toString(),
      address1: json['address1']?.toString(),
      iata: json['IATA']?.toString() ?? json['iata']?.toString(),
      code: json['code']?.toString(),
      cityName: (city?['name'] ?? (json['type'] == 'city' ? name : null))?.toString(),
      provinceName: province?['name']?.toString(),
      islandName: island?['name']?.toString(),
    );
  }
}
