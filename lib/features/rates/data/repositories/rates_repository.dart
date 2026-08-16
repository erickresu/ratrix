import '../../domain/entities/client.dart';
import '../../domain/entities/client_rate.dart';
import '../../domain/entities/rate_stat.dart';
import '../../domain/entities/recent_rate.dart';
import '../datasources/rates_local_data_source.dart';

class RatesRepository {
  RatesRepository(this._dataSource);

  final RatesLocalDataSource _dataSource;

  Future<List<RateStat>> fetchStats() async => _dataSource.fetchStats();

  Future<List<RecentRate>> fetchRecentRates() async => _dataSource.fetchRecentRates();

  Future<List<Client>> fetchClients() async => _dataSource.fetchClients();

  Future<List<ClientRate>> fetchClientRates(String clientId) async =>
      _dataSource.fetchClientRates().where((r) => r.clientId == clientId).toList();

  Future<List<ClientRate>> fetchAllClientRates() async => _dataSource.fetchClientRates();

  List<String> get locationOptions => _dataSource.fetchLocationOptions();
}
