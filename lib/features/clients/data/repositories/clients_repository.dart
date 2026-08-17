import '../../domain/entities/client.dart';
import '../datasources/clients_data_source.dart';

class ClientsRepository {
  ClientsRepository(this._dataSource);

  final ClientsDataSource _dataSource;

  Future<List<Client>> fetchClients() async {
    final res = await _dataSource.fetchClients();
    final body = res.data;

    final List<dynamic> rows;
    if (body is Map<String, dynamic> && body['data'] is List) {
      rows = body['data'] as List;
    } else if (body is List) {
      rows = body;
    } else {
      rows = const [];
    }

    return rows
        .whereType<Map<String, dynamic>>()
        .map(Client.fromJson)
        .toList();
  }
}
