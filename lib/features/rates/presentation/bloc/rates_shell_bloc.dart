import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../clients/data/repositories/clients_repository.dart';
import '../../../clients/domain/entities/client.dart' as clients_api;
import '../../data/repositories/rates_repository.dart';
import '../../domain/entities/client.dart';
import '../../domain/entities/client_rate.dart';
import '../../domain/entities/rate_stat.dart';
import '../../domain/entities/rates_enums.dart';
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
      (event, emit) => emit(state.copyWith(modalOpen: false, rateChoice: RateType.published, view: RatesView.create)),
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
    on<ClientRateSearchChanged>((event, emit) => emit(state.copyWith(clientRateSearch: event.query)));
    on<ClientRatesTabChanged>((event, emit) => emit(state.copyWith(clientRatesTab: event.tab)));
    on<CreateCustomRateForSelectedClientRequested>(
      (event, emit) => emit(state.copyWith(view: RatesView.create, rateChoice: RateType.custom)),
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
    } catch (_) {
      // Leave stats/recentRates/allClientRates at their empty defaults —
      // the dashboard renders an empty state rather than getting stuck
      // on the loading skeleton.
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
    } catch (_) {
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
    ));
    List<ClientRate> rates = const [];
    try {
      rates = await _repository.fetchClientRates(event.clientId);
    } catch (_) {
      // Fall through with an empty list — the view shows its own
      // no-results state rather than getting stuck loading.
    }
    emit(state.copyWith(
      selectedClientRates: rates,
      clientRatesLoading: false,
    ));
  }
}
