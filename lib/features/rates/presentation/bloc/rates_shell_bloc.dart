import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/api/app_logger.dart';
import '../../../clients/data/repositories/clients_repository.dart';
import '../../../clients/domain/entities/client.dart' as clients_api;
import '../../data/repositories/rates_repository.dart';
import '../../domain/entities/client.dart';
import '../../domain/entities/client_rate.dart';
import '../../domain/entities/rate_stat.dart';
import '../../domain/entities/rates_enums.dart';
import '../../domain/entities/ratrix_rate.dart';
import '../../domain/entities/recent_rate.dart';

part 'rates_shell_event.dart';
part 'rates_shell_state.dart';

class RatesShellBloc extends Bloc<RatesShellEvent, RatesShellState> {
  RatesShellBloc(this._repository, this._clientsRepository) : super(const RatesShellState()) {
    on<RatesDataRequested>(_onDataRequested);
    on<RatesHomeRequested>((event, emit) => emit(state.copyWith(view: RatesView.dashboard)));
    on<RatesMenuToggled>((event, emit) => emit(state.copyWith(ratesMenuOpen: !state.ratesMenuOpen)));
    on<ProfileMenuToggled>((event, emit) => emit(state.copyWith(profileMenuOpen: !state.profileMenuOpen)));
    on<NewRateModalOpened>((event, emit) => emit(state.copyWith(modalOpen: true, clearRateChoice: true)));
    on<NewRateModalClosed>((event, emit) => emit(state.copyWith(modalOpen: false)));
    on<PublishedRateChosen>(
      (event, emit) => emit(state.copyWith(
        modalOpen: false,
        rateChoice: RateType.published,
        view: RatesView.create,
        clearExistingRate: true,
      )),
    );
    on<CustomRateChosen>(
      (event, emit) => emit(state.copyWith(modalOpen: false, rateChoice: RateType.custom, view: RatesView.customClients)),
    );
    on<CustomClientsRequested>((event, emit) => emit(state.copyWith(view: RatesView.customClients)));
    on<ClientSearchChanged>((event, emit) => emit(state.copyWith(clientSearch: event.query, clientPage: 0)));
    on<ClientPageChanged>((event, emit) => emit(state.copyWith(clientPage: event.page)));
    on<ClientRatesRequested>(_onClientRatesRequested);
    on<ClientsBackRequested>((event, emit) => emit(state.copyWith(view: RatesView.customClients)));
    on<ClientRatesBackRequested>((event, emit) => emit(state.copyWith(view: RatesView.customClientRates)));
    on<ClientRateSearchChanged>((event, emit) => emit(state.copyWith(clientRateSearch: event.query, clientRatePage: 0)));
    on<ClientRatesTabChanged>((event, emit) => emit(state.copyWith(clientRatesTab: event.tab, clientRatePage: 0)));
    on<ClientRatePageChanged>((event, emit) => emit(state.copyWith(clientRatePage: event.page)));
    on<ClientRateFreightFilterChanged>(
      (event, emit) => emit(state.copyWith(
        clientRateFreightFilter: event.freightMode,
        clearClientRateFreightFilter: event.freightMode == null,
        clientRatePage: 0,
      )),
    );
    on<ClientRateServiceFilterChanged>(
      (event, emit) => emit(state.copyWith(
        clientRateServiceFilter: event.serviceMode,
        clearClientRateServiceFilter: event.serviceMode == null,
        clientRatePage: 0,
      )),
    );
    on<ClientRateSortByExpiryToggled>(
      (event, emit) => emit(state.copyWith(clientRateSortByExpiry: !state.clientRateSortByExpiry)),
    );
    on<CreateCustomRateForSelectedClientRequested>(
      (event, emit) => emit(state.copyWith(view: RatesView.create, rateChoice: RateType.custom, clearExistingRate: true)),
    );
    on<EditRateRequested>(_onEditRateRequested);
    on<ShippingCalculatorRequested>(
      (event, emit) => emit(state.copyWith(view: RatesView.shippingCalculatorClients)),
    );
    on<ShippingCalculatorClientChosen>(
      (event, emit) => emit(state.copyWith(
        selectedCalcClientId: event.clientId,
        view: RatesView.shippingCalculatorForm,
      )),
    );
    on<ShippingCalculatorClientSearchChanged>(
      (event, emit) => emit(state.copyWith(calcClientSearch: event.query, calcClientPage: 0)),
    );
    on<ShippingCalculatorClientPageChanged>(
      (event, emit) => emit(state.copyWith(calcClientPage: event.page)),
    );
    on<ShippingCalculatorBackRequested>(
      (event, emit) => emit(state.copyWith(view: RatesView.shippingCalculatorClients)),
    );
  }

  final RatesRepository _repository;
  final ClientsRepository _clientsRepository;

  Future<void> _onDataRequested(RatesDataRequested event, Emitter<RatesShellState> emit) async {
    final clients = await _fetchClients();
    final clientNamesById = {for (final c in clients) c.id: c.name};

    List<RateStat> stats = const [];
    List<RecentRate> recentRates = const [];
    List<ClientRate> allClientRates = const [];
    try {
      stats = await _repository.fetchStats();
      recentRates = await _repository.fetchRecentRates(clientNamesById: clientNamesById);
      allClientRates = await _repository.fetchAllClientRates();
    } catch (e, st) {
      // Leave stats/recentRates/allClientRates at their empty defaults —
      // the dashboard renders an empty state rather than getting stuck
      // on the loading skeleton.
      appLogger.e('Failed to load rates dashboard data', error: e, stackTrace: st);
    }

    final counts = <String, int>{};
    for (final rate in allClientRates) {
      counts[rate.clientId] = (counts[rate.clientId] ?? 0) + 1;
    }
    emit(state.copyWith(
      isLoading: false,
      stats: stats,
      recentRates: recentRates,
      clients: clients,
      clientRateCounts: counts,
    ));
  }

  Future<List<Client>> _fetchClients() async {
    try {
      final apiClients = await _clientsRepository.fetchClients();
      return apiClients.map(_mapClient).toList();
    } catch (e, st) {
      appLogger.e('Failed to load clients', error: e, stackTrace: st);
      return const [];
    }
  }

  Client _mapClient(clients_api.Client c) {
    final vatRaw = c.compliance?.vatStatus?.toLowerCase();
    return Client(
      id: c.id.toString(),
      accountNumber: c.accountNo,
      name: c.name,
      email: c.email ?? '',
      businessType: c.businessType ?? '',
      vatStatus: vatRaw == 'inclusive' ? VatStatus.inclusive : VatStatus.exclusive,
    );
  }

  Future<void> _onClientRatesRequested(ClientRatesRequested event, Emitter<RatesShellState> emit) async {
    emit(state.copyWith(
      view: RatesView.customClientRates,
      selectedClientId: event.clientId,
      selectedClientRates: const [],
      clientRatesLoading: true,
      clientRatesTab: RateStatus.active,
      clientRateSearch: '',
      clientRatePage: 0,
      clearClientRateFreightFilter: true,
      clearClientRateServiceFilter: true,
      clientRateSortByExpiry: false,
    ));
    List<ClientRate> rates = const [];
    try {
      rates = await _repository.fetchClientRates(event.clientId);
    } catch (e, st) {
      // Fall through with an empty list — the view shows its own
      // no-results state rather than getting stuck loading.
      appLogger.e('Failed to load rates for client ${event.clientId}', error: e, stackTrace: st);
    }
    emit(state.copyWith(
      selectedClientRates: rates,
      clientRatesLoading: false,
    ));
  }

  /// Fetches the full rate for `event.rateId` and opens the wizard in edit
  /// mode once it resolves. On failure, stays on the current view and
  /// leaves `existingRate` unset — there's no dedicated error surface for
  /// this fetch, so failing quietly (rather than navigating into a wizard
  /// with no data) is the safer default.
  Future<void> _onEditRateRequested(EditRateRequested event, Emitter<RatesShellState> emit) async {
    emit(state.copyWith(editRateLoading: true));
    try {
      final rate = await _repository.fetchRateById(event.rateId);
      emit(state.copyWith(
        editRateLoading: false,
        existingRate: rate,
        view: RatesView.create,
        rateChoice: rate.isCustom ? RateType.custom : RateType.published,
      ));
    } catch (e, st) {
      appLogger.e('Failed to load rate ${event.rateId} for edit', error: e, stackTrace: st);
      emit(state.copyWith(editRateLoading: false));
    }
  }
}
