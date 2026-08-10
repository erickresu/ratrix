import '../datasources/_template_data_source.dart';

class TemplateRepository {
  TemplateRepository(this._dataSource);

  final TemplateDataSource _dataSource;

  Future<List<Map<String, dynamic>>> fetchAll() async {
    final res = await _dataSource.fetchAll();
    final data = res.data;
    if (data is List) return data.cast<Map<String, dynamic>>();
    return [];
  }
}
