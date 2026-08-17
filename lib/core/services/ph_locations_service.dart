import 'package:ph_address_dropdowns/ph_address_dropdowns.dart';

/// Flattens the region-scoped PSGC data from `ph_address_dropdowns` into two
/// simple, nationwide name lists suitable for a free-text city/province
/// autocomplete (the picker widget itself assumes a region-first cascade,
/// which doesn't fit a single "search origin city" field).
class PhLocationsService {
  final _repository = PhLocationRepository();

  List<String>? _cities;
  List<String>? _provinces;

  List<String> get cities => _cities ?? const [];
  List<String> get provinces => _provinces ?? const [];
  bool get isLoaded => _cities != null && _provinces != null;

  Future<void> ensureLoaded() async {
    if (isLoaded) return;

    final regions = await _repository.getRegions();
    final provinceLists = await Future.wait(regions.map((r) => _repository.getProvinces(r.regCode)));
    final allProvinces = provinceLists.expand((list) => list).toList();

    final cityFutures = <Future<List<CityMun>>>[
      for (final p in allProvinces) _repository.getCityMuns(regCode: p.regCode, provCode: p.provCode),
      // Regions without provinces (e.g. NCR) list their cities directly under the region.
      for (final r in regions)
        if (!allProvinces.any((p) => p.regCode == r.regCode)) _repository.getCityMuns(regCode: r.regCode),
    ];
    final cityLists = await Future.wait(cityFutures);

    _provinces = allProvinces.map((p) => p.provName).toSet().toList()..sort();
    _cities = cityLists.expand((list) => list).map((c) => c.munCityName).toSet().toList()..sort();
  }
}
