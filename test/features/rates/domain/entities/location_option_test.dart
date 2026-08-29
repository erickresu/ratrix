import 'package:flutter_test/flutter_test.dart';
import 'package:ratrix/features/rates/domain/entities/location_option.dart';

void main() {
  group('LocationOption.fromJson', () {
    test('a city row reads its own id as cityId and the nested chain for the rest', () {
      final option = LocationOption.fromJson({
        'id': 5,
        'name': 'Quezon City',
        'type': 'city',
        'province': {
          'id': 2,
          'name': 'Metro Manila',
          'region': {
            'id': 1,
            'name': 'NCR',
            'island': {'id': 9, 'name': 'Luzon'},
          },
        },
      });

      expect(option.cityId, 5);
      expect(option.provinceId, 2);
      expect(option.regionId, 1);
      expect(option.islandId, 9);
      expect(option.cityName, 'Quezon City');
      expect(option.provinceName, 'Metro Manila');
      expect(option.islandName, 'Luzon');
    });

    // The historical bug: a province row has no nested object for itself
    // (only for its region/island parents), so applying one blanket
    // `?? json['id']` fallback to every field let the province's own id
    // leak into cityId too, since nothing overrode it.
    test('a province row does not leak its own id into cityId', () {
      final option = LocationOption.fromJson({
        'id': 2,
        'name': 'Metro Manila',
        'type': 'province',
      });

      expect(option.provinceId, 2);
      expect(option.cityId, isNull);
      expect(option.provinceName, 'Metro Manila');
    });

    // Islands are never nested under anything else, so an island row has
    // no parent object to read from at all — its own id must fall back
    // directly into islandId rather than being left null.
    test('an island row falls back to its own id for islandId', () {
      final option = LocationOption.fromJson({
        'id': 9,
        'name': 'Luzon',
        'type': 'island',
      });

      expect(option.islandId, 9);
      expect(option.regionId, isNull);
      expect(option.provinceId, isNull);
      expect(option.cityId, isNull);
      expect(option.islandName, 'Luzon');
    });

    test('a region row falls back to its own id for regionId only', () {
      final option = LocationOption.fromJson({
        'id': 1,
        'name': 'NCR',
        'type': 'region',
      });

      expect(option.regionId, 1);
      expect(option.provinceId, isNull);
      expect(option.cityId, isNull);
    });

    test('a barangay row falls back to its own id for barangayId', () {
      final option = LocationOption.fromJson({
        'id': 77,
        'name': 'Barangay Uno',
        'type': 'barangay',
      });

      expect(option.barangayId, 77);
      expect(option.cityId, isNull);
    });

    test('an explicit barangay_id wins over the own-id fallback', () {
      final option = LocationOption.fromJson({
        'id': 77,
        'name': 'Barangay Uno',
        'type': 'barangay',
        'barangay_id': 999,
      });

      expect(option.barangayId, 999);
    });

    test('name falls back to label when name is absent', () {
      final option = LocationOption.fromJson({'id': 1, 'label': 'Cebu', 'type': 'province'});
      expect(option.value, 'Cebu');
      expect(option.label, 'Cebu');
    });
  });
}
