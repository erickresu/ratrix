import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:ratrix/features/clients/data/repositories/clients_repository.dart';
import 'package:ratrix/features/rates/data/repositories/rates_repository.dart';
import 'package:ratrix/features/rates/domain/entities/client_rate.dart';
import 'package:ratrix/features/rates/domain/entities/published_rate.dart';
import 'package:ratrix/features/rates/domain/entities/rate_stat.dart';
import 'package:ratrix/features/rates/domain/entities/ratrix_rate.dart';
import 'package:ratrix/features/rates/domain/entities/rates_enums.dart';
import 'package:ratrix/features/rates/domain/entities/recent_rate.dart';
import 'package:ratrix/features/rates/presentation/bloc/rates_shell_bloc.dart';

class MockRatesRepository extends Mock implements RatesRepository {}

class MockClientsRepository extends Mock implements ClientsRepository {}

ClientRate _clientRate(String id, {String clientId = 'c1'}) => ClientRate(
      id: id,
      clientId: clientId,
      chargeCode: 'CC-$id',
      freightMode: FreightMode.air,
      serviceMode: ServiceMode.doorToDoor,
      routeCount: 1,
      status: RateStatus.active,
      expiryLabel: 'Active',
    );

PublishedRate _publishedRate(String id) => PublishedRate(
      id: id,
      chargeCode: 'CC-$id',
      freightMode: FreightMode.air,
      serviceMode: ServiceMode.doorToDoor,
      routeLabel: 'Manila → Cebu',
      routeCount: 1,
      status: RateStatus.active,
      expiryLabel: 'Active',
    );

RatrixRate _fullRate(String id, {required bool isCustom}) => RatrixRate(
      id: id,
      chargeCode: 'CC-$id',
      rateType: isCustom ? 'custom' : 'publish',
    );

Future<void> _flush() => Future<void>.delayed(Duration.zero);

void main() {
  late MockRatesRepository repository;
  late MockClientsRepository clientsRepository;
  late RatesShellBloc bloc;

  setUp(() {
    repository = MockRatesRepository();
    clientsRepository = MockClientsRepository();
    when(() => clientsRepository.fetchClients()).thenAnswer((_) async => const []);
    bloc = RatesShellBloc(repository, clientsRepository);
  });

  tearDown(() => bloc.close());

  group('DeleteRateRequested', () {
    test('on success, strips the rate from both lists and decrements the client count', () async {
      bloc.emit(
        bloc.state.copyWith(
          publishedRates: [_publishedRate('1'), _publishedRate('2')],
          selectedClientId: 'c1',
          selectedClientRates: [_clientRate('1'), _clientRate('2')],
          clientRateCounts: const {'c1': 2},
        ),
      );
      when(() => repository.deleteRate('1')).thenAnswer((_) async {});

      bloc.add(const DeleteRateRequested('1'));
      await _flush();

      expect(bloc.state.publishedRates.map((r) => r.id), ['2']);
      expect(bloc.state.selectedClientRates.map((r) => r.id), ['2']);
      expect(bloc.state.clientRateCounts['c1'], 1);
      expect(bloc.state.deleteRateSucceeded, isTrue);
      expect(bloc.state.deletingRateId, isNull);
    });

    test('never lets the client count go negative', () async {
      bloc.emit(
        bloc.state.copyWith(
          selectedClientId: 'c1',
          selectedClientRates: [_clientRate('1')],
          clientRateCounts: const {'c1': 0},
        ),
      );
      when(() => repository.deleteRate('1')).thenAnswer((_) async {});

      bloc.add(const DeleteRateRequested('1'));
      await _flush();

      expect(bloc.state.clientRateCounts['c1'], 0);
    });

    test('leaves clientRateCounts untouched when no client is selected', () async {
      bloc.emit(
        bloc.state.copyWith(
          publishedRates: [_publishedRate('1')],
          clientRateCounts: const {'other': 5},
        ),
      );
      when(() => repository.deleteRate('1')).thenAnswer((_) async {});

      bloc.add(const DeleteRateRequested('1'));
      await _flush();

      expect(bloc.state.clientRateCounts, {'other': 5});
    });

    test('on failure, surfaces an error and leaves the lists untouched', () async {
      bloc.emit(bloc.state.copyWith(publishedRates: [_publishedRate('1')]));
      when(() => repository.deleteRate('1')).thenThrow(Exception('boom'));

      bloc.add(const DeleteRateRequested('1'));
      await _flush();

      expect(bloc.state.publishedRates.map((r) => r.id), ['1']);
      expect(bloc.state.deleteRateError, isNotNull);
      expect(bloc.state.deletingRateId, isNull);
    });
  });

  group('EditRateRequested', () {
    test('opens the wizard in custom mode for a custom rate', () async {
      when(() => repository.fetchRateById('r1')).thenAnswer((_) async => _fullRate('r1', isCustom: true));

      bloc.add(const EditRateRequested('r1'));
      await _flush();

      expect(bloc.state.existingRate?.id, 'r1');
      expect(bloc.state.rateChoice, RateType.custom);
      expect(bloc.state.view, RatesView.create);
      expect(bloc.state.editRateLoading, isFalse);
    });

    test('opens the wizard in published mode for a non-custom rate', () async {
      when(() => repository.fetchRateById('r2')).thenAnswer((_) async => _fullRate('r2', isCustom: false));

      bloc.add(const EditRateRequested('r2'));
      await _flush();

      expect(bloc.state.rateChoice, RateType.published);
    });

    test('remembers the view it was opened from as returnView', () async {
      bloc.emit(bloc.state.copyWith(view: RatesView.publishedRates));
      when(() => repository.fetchRateById('r1')).thenAnswer((_) async => _fullRate('r1', isCustom: false));

      bloc.add(const EditRateRequested('r1'));
      await _flush();

      expect(bloc.state.returnView, RatesView.publishedRates);
    });

    test('on failure, stays put with existingRate unset', () async {
      when(() => repository.fetchRateById('r1')).thenThrow(Exception('boom'));

      bloc.add(const EditRateRequested('r1'));
      await _flush();

      expect(bloc.state.existingRate, isNull);
      expect(bloc.state.editRateLoading, isFalse);
    });
  });

  group('ClientRatesRequested', () {
    test('resets stale filters/tab/search/page from a previous client before loading', () async {
      bloc.emit(
        bloc.state.copyWith(
          clientRatesTab: RateStatus.expired,
          clientRateSearch: 'stale query',
          clientRatePage: 3,
          clientRateFreightFilter: FreightMode.sea,
          clientRateServiceFilter: ServiceMode.portToPort,
          clientRateSortByExpiry: true,
        ),
      );
      when(() => repository.fetchClientRates('c2')).thenAnswer((_) async => [_clientRate('1', clientId: 'c2')]);

      bloc.add(const ClientRatesRequested('c2'));
      await _flush();

      expect(bloc.state.selectedClientId, 'c2');
      expect(bloc.state.clientRatesTab, RateStatus.active);
      expect(bloc.state.clientRateSearch, '');
      expect(bloc.state.clientRatePage, 0);
      expect(bloc.state.clientRateFreightFilter, isNull);
      expect(bloc.state.clientRateServiceFilter, isNull);
      expect(bloc.state.clientRateSortByExpiry, isFalse);
      expect(bloc.state.selectedClientRates.map((r) => r.id), ['1']);
    });
  });

  group('RatesDataRequested', () {
    test('tallies clientRateCounts per client from the fetched custom rates', () async {
      when(
        () => repository.fetchDashboardOverview(
          clientNamesById: any(named: 'clientNamesById'),
        ),
      ).thenAnswer(
        (_) async => (stats: const <RateStat>[], recentRates: const <RecentRate>[]),
      );
      when(() => repository.fetchAllClientRates()).thenAnswer(
        (_) async => [
          _clientRate('1', clientId: 'c1'),
          _clientRate('2', clientId: 'c1'),
          _clientRate('3', clientId: 'c2'),
        ],
      );
      when(() => repository.fetchAllPublishedRates()).thenAnswer((_) async => const <PublishedRate>[]);

      bloc.add(const RatesDataRequested());
      await _flush();

      expect(bloc.state.clientRateCounts, {'c1': 2, 'c2': 1});
      expect(bloc.state.isLoading, isFalse);
    });
  });
}
