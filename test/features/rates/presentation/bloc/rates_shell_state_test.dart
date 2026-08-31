import 'package:flutter_test/flutter_test.dart';
import 'package:ratrix/features/rates/domain/entities/audit_log.dart';
import 'package:ratrix/features/rates/domain/entities/client.dart';
import 'package:ratrix/features/rates/domain/entities/client_rate.dart';
import 'package:ratrix/features/rates/domain/entities/published_rate.dart';
import 'package:ratrix/features/rates/domain/entities/rates_enums.dart';
import 'package:ratrix/features/rates/presentation/bloc/rates_shell_bloc.dart';

Client _client(String id, String name) => Client(
      id: id,
      accountNumber: 'ACC-$id',
      name: name,
      email: '$name@example.com',
      businessType: 'Retail',
      vatStatus: VatStatus.exclusive,
    );

ClientRate _clientRate({
  required String id,
  String chargeCode = 'CC-1',
  FreightMode freightMode = FreightMode.air,
  ServiceMode serviceMode = ServiceMode.doorToDoor,
  RateStatus status = RateStatus.active,
  DateTime? expiryDate,
}) =>
    ClientRate(
      id: id,
      clientId: 'c1',
      chargeCode: chargeCode,
      freightMode: freightMode,
      serviceMode: serviceMode,
      routeCount: 1,
      status: status,
      expiryLabel: status == RateStatus.active ? 'Active' : 'Expired',
      expiryDate: expiryDate,
    );

PublishedRate _publishedRate({
  required String id,
  String chargeCode = 'CC-1',
  String routeLabel = 'Manila → Cebu',
  FreightMode freightMode = FreightMode.air,
  ServiceMode serviceMode = ServiceMode.doorToDoor,
  RateStatus status = RateStatus.active,
  DateTime? expiryDate,
}) =>
    PublishedRate(
      id: id,
      chargeCode: chargeCode,
      freightMode: freightMode,
      serviceMode: serviceMode,
      routeLabel: routeLabel,
      routeCount: 1,
      status: status,
      expiryLabel: status == RateStatus.active ? 'Active' : 'Expired',
      expiryDate: expiryDate,
    );

AuditLog _auditLog({
  required String id,
  String? action,
  String? tableName,
  String? recordId,
  String? userName,
  DateTime? createdAt,
}) =>
    AuditLog(
      id: id,
      action: action,
      tableName: tableName,
      recordId: recordId,
      userName: userName,
      createdAt: createdAt,
    );

void main() {
  group('client search + pagination', () {
    test('filteredClients is case-insensitive and sorted by name', () {
      final state = RatesShellState(
        clients: [_client('1', 'zeta corp'), _client('2', 'Alpha Inc'), _client('3', 'beta LLC')],
        clientSearch: '',
      );
      expect(state.filteredClients.map((c) => c.id), ['2', '3', '1']);
    });

    test('filteredClients matches a substring anywhere in the name', () {
      final state = RatesShellState(
        clients: [_client('1', 'Zeta Corp'), _client('2', 'Alpha Inc')],
        clientSearch: 'ORP',
      );
      expect(state.filteredClients.map((c) => c.id), ['1']);
    });

    test('pagedClients slices by page, with an empty tail page returning nothing', () {
      final clients = [for (var i = 0; i < 20; i++) _client('$i', 'Client $i')];
      final state = RatesShellState(clients: clients);

      expect(state.pagedClients.length, RatesShellState.clientsPerPage);
      expect(
        state.copyWith(clientPage: 1).pagedClients.length,
        RatesShellState.clientsPerPage,
      );
      // 20 clients / 9 per page = 3 pages (9, 9, 2) — page 3 is past the end.
      expect(state.copyWith(clientPage: 3).pagedClients, isEmpty);
    });

    test('clientPageCount is at least 1 even with zero clients', () {
      const state = RatesShellState(clients: []);
      expect(state.clientPageCount, 1);
    });

    test('selectedClient resolves by id, or null when unmatched/unset', () {
      final state = RatesShellState(
        clients: [_client('1', 'Zeta Corp')],
        selectedClientId: '1',
      );
      expect(state.selectedClient?.name, 'Zeta Corp');
      expect(state.copyWith(selectedClientId: 'missing').selectedClient, isNull);
    });
  });

  group('client rates filtering', () {
    test('filters by the active/expired tab', () {
      final rates = [
        _clientRate(id: '1', status: RateStatus.active),
        _clientRate(id: '2', status: RateStatus.expired),
      ];
      final state = RatesShellState(selectedClientRates: rates, clientRatesTab: RateStatus.active);
      expect(state.filteredClientRates.map((r) => r.id), ['1']);
    });

    test('filters by freight and service mode', () {
      final rates = [
        _clientRate(id: '1', freightMode: FreightMode.air, serviceMode: ServiceMode.doorToDoor),
        _clientRate(id: '2', freightMode: FreightMode.sea, serviceMode: ServiceMode.doorToDoor),
      ];
      final state = RatesShellState(
        selectedClientRates: rates,
        clientRateFreightFilter: FreightMode.sea,
      );
      expect(state.filteredClientRates.map((r) => r.id), ['2']);
    });

    test('search matches charge code or freight mode label', () {
      final rates = [
        _clientRate(id: '1', chargeCode: 'AIR-100'),
        _clientRate(id: '2', chargeCode: 'SEA-200'),
      ];
      final state = RatesShellState(selectedClientRates: rates, clientRateSearch: 'air-100');
      expect(state.filteredClientRates.map((r) => r.id), ['1']);
    });

    test('sortByExpiry orders ascending with null expiry last', () {
      final rates = [
        _clientRate(id: 'no-expiry'),
        _clientRate(id: 'later', expiryDate: DateTime(2026, 6, 1)),
        _clientRate(id: 'sooner', expiryDate: DateTime(2026, 3, 1)),
      ];
      final state = RatesShellState(
        selectedClientRates: rates,
        clientRateSortByExpiry: true,
      );
      expect(state.filteredClientRates.map((r) => r.id), ['sooner', 'later', 'no-expiry']);
    });

    test('pagedClientRates and clientRatePageCount paginate the filtered list', () {
      final rates = [for (var i = 0; i < 12; i++) _clientRate(id: '$i')];
      final state = RatesShellState(selectedClientRates: rates);
      expect(state.clientRatePageCount, 2); // 12 / 7 per page, rounded up
      expect(state.pagedClientRates.length, state.clientRatesPerPage);
      expect(state.copyWith(clientRatePage: 1).pagedClientRates.length, 5);
    });
  });

  group('published rates filtering', () {
    test('search also matches the route label', () {
      final rates = [
        _publishedRate(id: '1', routeLabel: 'Manila → Cebu'),
        _publishedRate(id: '2', routeLabel: 'Davao → Iloilo'),
      ];
      final state = RatesShellState(publishedRates: rates, publishedRateSearch: 'davao');
      expect(state.filteredPublishedRates.map((r) => r.id), ['2']);
    });

    test('filters by the active/expired tab independently of client rates', () {
      final rates = [
        _publishedRate(id: '1', status: RateStatus.active),
        _publishedRate(id: '2', status: RateStatus.expired),
      ];
      final state = RatesShellState(publishedRates: rates, publishedRatesTab: RateStatus.expired);
      expect(state.filteredPublishedRates.map((r) => r.id), ['2']);
    });
  });

  group('audit log filtering', () {
    test('filters by action', () {
      final logs = [
        _auditLog(id: '1', action: 'create'),
        _auditLog(id: '2', action: 'delete'),
      ];
      final state = RatesShellState(auditLogs: logs, auditLogActionFilter: 'delete');
      expect(state.filteredAuditLogs.map((l) => l.id), ['2']);
    });

    test('search matches table name, record id, or user name', () {
      final logs = [
        _auditLog(id: '1', tableName: 'ratrix_rates', recordId: 'R1', userName: 'Alice'),
        _auditLog(id: '2', tableName: 'clients', recordId: 'R2', userName: 'Bob'),
      ];
      final state = RatesShellState(auditLogs: logs, auditLogSearch: 'alice');
      expect(state.filteredAuditLogs.map((l) => l.id), ['1']);
    });

    test('sorts newest first, with logs missing a timestamp last', () {
      final logs = [
        _auditLog(id: 'no-time'),
        _auditLog(id: 'older', createdAt: DateTime(2026, 1, 1)),
        _auditLog(id: 'newer', createdAt: DateTime(2026, 6, 1)),
      ];
      final state = RatesShellState(auditLogs: logs);
      expect(state.filteredAuditLogs.map((l) => l.id), ['newer', 'older', 'no-time']);
    });

    test('auditLogPageCount rounds up and clamps to at least 1', () {
      expect(const RatesShellState(auditLogs: []).auditLogPageCount, 1);
      final logs = [for (var i = 0; i < 9; i++) _auditLog(id: '$i')];
      // 9 / 8 per page = 2 pages.
      expect(RatesShellState(auditLogs: logs).auditLogPageCount, 2);
    });
  });
}
