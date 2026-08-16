import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/repositories/rates_repository.dart';
import '../../domain/entities/client.dart';
import '../../domain/entities/client_rate.dart';
import '../../domain/entities/rate_stat.dart';
import '../../domain/entities/rates_enums.dart';
import '../../domain/entities/recent_rate.dart';

part 'rates_shell_event.dart';
part 'rates_shell_state.dart';

class RatesShellBloc extends Bloc<RatesShellEvent, RatesShellState> {
  RatesShellBloc(this._repository) : super(const RatesShellState()) {
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
    on<ClientSearchChanged>((event, emit) => emit(state.copyWith(clientSearch: event.query)));
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

  Future<void> _onDataRequested(RatesDataRequested event, Emitter<RatesShellState> emit) async {
    final stats = await _repository.fetchStats();
    final recentRates = await _repository.fetchRecentRates();
    final clients = await _repository.fetchClients();
    final allClientRates = await _repository.fetchAllClientRates();
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

  Future<void> _onClientRatesRequested(ClientRatesRequested event, Emitter<RatesShellState> emit) async {
    final rates = await _repository.fetchClientRates(event.clientId);
    emit(state.copyWith(
      view: RatesView.customClientRates,
      selectedClientId: event.clientId,
      selectedClientRates: rates,
      clientRatesTab: RateStatus.active,
      clientRateSearch: '',
    ));
  }
}
