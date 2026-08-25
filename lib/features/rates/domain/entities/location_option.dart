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

  static LocationOption fromJson(Map<String, dynamic> json) => LocationOption(
        id: json['id']?.toString(),
        value: (json['value'] ?? '').toString(),
        label: (json['label'] ?? '').toString(),
        type: json['type']?.toString(),
        islandId: _asInt(json['island_id']),
        regionId: _asInt(json['region_id']),
        provinceId: _asInt(json['province_id']),
        cityId: _asInt(json['city_id']),
        barangayId: _asInt(json['barangay_id']),
        zipcode: json['zipcode']?.toString(),
        address1: json['address1']?.toString(),
        iata: json['IATA']?.toString(),
        code: json['code']?.toString(),
        cityName: json['city_name']?.toString(),
        provinceName: json['province_name']?.toString(),
        islandName: json['island_name']?.toString(),
      );
}
