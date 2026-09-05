import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/api/app_logger.dart';
import '../../../clients/data/repositories/clients_repository.dart';
import '../../../clients/domain/entities/client.dart' as clients_api;
import '../../data/repositories/rates_repository.dart';
import '../../domain/entities/audit_log.dart';
import '../../domain/entities/client.dart';
import '../../domain/entities/client_rate.dart';
import '../../domain/entities/expiring_soon_rate.dart';
import '../../domain/entities/published_rate.dart';
import '../../domain/entities/rate_stat.dart';
import '../../domain/entities/rates_enums.dart';
import '../../domain/entities/ratrix_rate.dart';
import '../../domain/entities/recent_rate.dart';

part 'rates_shell_event.dart';
part 'rates_shell_state.dart';

class RatesShellBloc extends Bloc<RatesShellEvent, RatesShellState> {
  RatesShellBloc(this._repository, this._clientsRepository)
    : super(const RatesShellState()) {
    on<RatesDataRequested>(_onDataRequested);
    on<RatesHomeRequested>(
      (event, emit) => emit(state.copyWith(view: RatesView.dashboard)),
    );
    on<RatesMenuToggled>(
      (event, emit) =>
          emit(state.copyWith(ratesMenuOpen: !state.ratesMenuOpen)),
    );
    on<ProfileMenuToggled>(
      (event, emit) =>
          emit(state.copyWith(profileMenuOpen: !state.profileMenuOpen)),
    );
    on<NewRateModalOpened>(
      (event, emit) =>
          emit(state.copyWith(modalOpen: true, clearRateChoice: true)),
    );
    on<NewRateModalClosed>(
      (event, emit) => emit(state.copyWith(modalOpen: false)),
    );
    on<PublishedRateChosen>(
      (event, emit) => emit(
        state.copyWith(
          modalOpen: false,
          rateChoice: RateType.published,
          view: RatesView.create,
          clearExistingRate: true,
          clearReturnView: true,
        ),
      ),
    );
    on<CustomRateChosen>(
      (event, emit) => emit(
        state.copyWith(
          modalOpen: false,
          rateChoice: RateType.custom,
          view: RatesView.customClients,
        ),
      ),
    );
    on<CustomClientsRequested>(
      (event, emit) => emit(state.copyWith(view: RatesView.customClients)),
    );
    on<ClientSearchChanged>(
      (event, emit) =>
          emit(state.copyWith(clientSearch: event.query, clientPage: 0)),
    );
    on<ClientPageChanged>(
      (event, emit) => emit(state.copyWith(clientPage: event.page)),
    );
    on<ClientRatesRequested>(_onClientRatesRequested);
    on<ClientsBackRequested>(
      (event, emit) => emit(state.copyWith(view: RatesView.customClients)),
    );
    on<ClientRateSearchChanged>(
      (event, emit) => emit(
        state.copyWith(clientRateSearch: event.query, clientRatePage: 0),
      ),
    );
    on<ClientRatesTabChanged>(
      (event, emit) =>
          emit(state.copyWith(clientRatesTab: event.tab, clientRatePage: 0)),
    );
    on<ClientRatePageChanged>(
      (event, emit) => emit(state.copyWith(clientRatePage: event.page)),
    );
    on<ClientRatesPerPageChanged>((event, emit) {
      if (event.perPage == state.clientRatesPerPage) return;
      final newPageCount = (state.filteredClientRates.length / event.perPage)
          .ceil()
          .clamp(1, 1 << 30);
      emit(
        state.copyWith(
          clientRatesPerPage: event.perPage,
          clientRatePage: state.clientRatePage.clamp(0, newPageCount - 1),
        ),
      );
    });
    on<ClientRateFreightFilterChanged>(
      (event, emit) => emit(
        state.copyWith(
          clientRateFreightFilter: event.freightMode,
          clearClientRateFreightFilter: event.freightMode == null,
          clientRatePage: 0,
        ),
      ),
    );
    on<ClientRateServiceFilterChanged>(
      (event, emit) => emit(
        state.copyWith(
          clientRateServiceFilter: event.serviceMode,
          clearClientRateServiceFilter: event.serviceMode == null,
          clientRatePage: 0,
        ),
      ),
    );
    on<ClientRateSortByExpiryToggled>(
      (event, emit) => emit(
        state.copyWith(clientRateSortByExpiry: !state.clientRateSortByExpiry),
      ),
    );
    on<CreateCustomRateForSelectedClientRequested>(
      (event, emit) => emit(
        state.copyWith(
          view: RatesView.create,
          rateChoice: RateType.custom,
          clearExistingRate: true,
          clearReturnView: true,
        ),
      ),
    );
    on<EditRateRequested>(_onEditRateRequested);
    on<WizardExitRequested>(
      (event, emit) => emit(
        state.copyWith(
          view: state.returnView ?? event.fallback,
          clearReturnView: true,
        ),
      ),
    );
    on<PublishedRatesRequested>(
      (event, emit) => emit(state.copyWith(view: RatesView.publishedRates)),
    );
    on<CreatePublishedRateRequested>(
      (event, emit) => emit(
        state.copyWith(
          modalOpen: false,
          rateChoice: RateType.published,
          view: RatesView.create,
          clearExistingRate: true,
          clearReturnView: true,
        ),
      ),
    );
    on<PublishedRateSearchChanged>(
      (event, emit) => emit(
        state.copyWith(publishedRateSearch: event.query, publishedRatePage: 0),
      ),
    );
    on<PublishedRatesTabChanged>(
      (event, emit) => emit(
        state.copyWith(publishedRatesTab: event.tab, publishedRatePage: 0),
      ),
    );
    on<PublishedRatePageChanged>(
      (event, emit) => emit(state.copyWith(publishedRatePage: event.page)),
    );
    on<PublishedRatesPerPageChanged>((event, emit) {
      if (event.perPage == state.publishedRatesPerPage) return;
      final newPageCount =
          (state.filteredPublishedRates.length / event.perPage)
              .ceil()
              .clamp(1, 1 << 30);
      emit(
        state.copyWith(
          publishedRatesPerPage: event.perPage,
          publishedRatePage: state.publishedRatePage.clamp(0, newPageCount - 1),
        ),
      );
    });
    on<PublishedRateFreightFilterChanged>(
      (event, emit) => emit(
        state.copyWith(
          publishedRateFreightFilter: event.freightMode,
          clearPublishedRateFreightFilter: event.freightMode == null,
          publishedRatePage: 0,
        ),
      ),
    );
    on<PublishedRateServiceFilterChanged>(
      (event, emit) => emit(
        state.copyWith(
          publishedRateServiceFilter: event.serviceMode,
          clearPublishedRateServiceFilter: event.serviceMode == null,
          publishedRatePage: 0,
        ),
      ),
    );
    on<PublishedRateSortByExpiryToggled>(
      (event, emit) => emit(
        state.copyWith(
          publishedRateSortByExpiry: !state.publishedRateSortByExpiry,
        ),
      ),
    );
    on<ShippingCalculatorRequested>(
      (event, emit) =>
          emit(state.copyWith(view: RatesView.shippingCalculatorClients)),
    );
    on<ShippingCalculatorClientChosen>(
      (event, emit) => emit(
        state.copyWith(
          selectedCalcClientId: event.clientId,
          view: RatesView.shippingCalculatorForm,
        ),
      ),
    );
    on<ShippingCalculatorClientSearchChanged>(
      (event, emit) => emit(
        state.copyWith(calcClientSearch: event.query, calcClientPage: 0),
      ),
    );
    on<ShippingCalculatorClientPageChanged>(
      (event, emit) => emit(state.copyWith(calcClientPage: event.page)),
    );
    on<ShippingCalculatorBackRequested>(
      (event, emit) =>
          emit(state.copyWith(view: RatesView.shippingCalculatorClients)),
    );
    on<DeleteRateRequested>(_onDeleteRateRequested);
    on<DeleteRateErrorDismissed>(
      (event, emit) => emit(state.copyWith(clearDeleteRateError: true)),
    );
    on<DeleteRateSuccessDismissed>(
      (event, emit) => emit(state.copyWith(deleteRateSucceeded: false)),
    );
    on<AuditTrailRequested>(_onAuditTrailRequested);
    on<AuditLogSearchChanged>(
      (event, emit) =>
          emit(state.copyWith(auditLogSearch: event.query, auditLogPage: 0)),
    );
    on<AuditLogActionFilterChanged>(
      (event, emit) => emit(
        state.copyWith(
          auditLogActionFilter: event.action,
          clearAuditLogActionFilter: event.action == null,
          auditLogPage: 0,
        ),
      ),
    );
    on<AuditLogPageChanged>(
      (event, emit) => emit(state.copyWith(auditLogPage: event.page)),
    );
  }

  final RatesRepository _repository;
  final ClientsRepository _clientsRepository;

  Future<void> _onDataRequested(
    RatesDataRequested event,
    Emitter<RatesShellState> emit,
  ) async {
    final clients = await _fetchClients();
    final clientNamesById = {for (final c in clients) c.id: c.name};

    List<RateStat> stats = const [];
    List<RecentRate> recentRates = const [];
    List<ClientRate> allClientRates = const [];
    List<PublishedRate> publishedRates = const [];
    try {
      // Independent requests — fire them all before awaiting any of them,
      // so they run concurrently instead of one after another; total wait
      // time becomes the slowest single call instead of their sum.
      final overviewFuture = _repository.fetchDashboardOverview(
        clientNamesById: clientNamesById,
      );
      final allClientRatesFuture = _repository.fetchAllClientRates();
      final publishedRatesFuture = _repository.fetchAllPublishedRates();

      final overview = await overviewFuture;
      stats = overview.stats;
      recentRates = overview.recentRates;
      allClientRates = await allClientRatesFuture;
      publishedRates = await publishedRatesFuture;
    } catch (e, st) {
      // Leave stats/recentRates/allClientRates/publishedRates at their empty
      // defaults — the dashboard renders an empty state rather than getting
      // stuck on the loading skeleton.
      appLogger.e(
        'Failed to load rates dashboard data',
        error: e,
        stackTrace: st,
      );
    }

    final counts = <String, int>{};
    for (final rate in allClientRates) {
      counts[rate.clientId] = (counts[rate.clientId] ?? 0) + 1;
    }

    final activeCustomRates = allClientRates.where((r) => r.status == RateStatus.active);
    final activePublishedRates = publishedRates.where((r) => r.status == RateStatus.active);
    final freightModeCounts = <FreightMode, int>{};
    for (final r in activeCustomRates) {
      freightModeCounts[r.freightMode] = (freightModeCounts[r.freightMode] ?? 0) + 1;
    }
    for (final r in activePublishedRates) {
      freightModeCounts[r.freightMode] = (freightModeCounts[r.freightMode] ?? 0) + 1;
    }

    // "Soon" = expires within 30 days from now — mirrors fetchStats'
    // 7-day "nearly expired" stat but wider, since this card lists actual
    // rates rather than just a count.
    final now = DateTime.now();
    final cutoff = now.add(const Duration(days: 30));
    bool expiresSoon(DateTime? expiry) =>
        expiry != null && expiry.isAfter(now) && expiry.isBefore(cutoff);
    final expiringSoon = <ExpiringSoonRate>[
      for (final r in activeCustomRates)
        if (expiresSoon(r.expiryDate))
          ExpiringSoonRate(
            client: clientNamesById[r.clientId] ?? r.clientId,
            chargeCode: r.chargeCode,
            daysLeft: r.expiryDate!.difference(now).inDays,
          ),
      for (final r in activePublishedRates)
        if (expiresSoon(r.expiryDate))
          ExpiringSoonRate(
            client: 'All clients',
            chargeCode: r.chargeCode,
            daysLeft: r.expiryDate!.difference(now).inDays,
          ),
    ]..sort((a, b) => a.daysLeft.compareTo(b.daysLeft));

    emit(
      state.copyWith(
        isLoading: false,
        stats: stats,
        recentRates: recentRates,
        freightModeCounts: freightModeCounts,
        activePublishedCount: activePublishedRates.length,
        activeCustomCount: activeCustomRates.length,
        expiringSoonRates: expiringSoon,
        clients: clients,
        clientRateCounts: counts,
        publishedRates: publishedRates,
      ),
    );
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
      vatStatus: vatRaw == 'inclusive'
          ? VatStatus.inclusive
          : VatStatus.exclusive,
      phoneNumber: c.phoneNumber,
      officeAddress: c.officeAddress,
    );
  }

  Future<void> _onClientRatesRequested(
    ClientRatesRequested event,
    Emitter<RatesShellState> emit,
  ) async {
    emit(
      state.copyWith(
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
      ),
    );
    List<ClientRate> rates = const [];
    try {
      rates = await _repository.fetchClientRates(event.clientId);
    } catch (e, st) {
      // Fall through with an empty list — the view shows its own
      // no-results state rather than getting stuck loading.
      appLogger.e(
        'Failed to load rates for client ${event.clientId}',
        error: e,
        stackTrace: st,
      );
    }
    emit(state.copyWith(selectedClientRates: rates, clientRatesLoading: false));
  }

  /// Fetches the full rate for `event.rateId` and opens the wizard in edit
  /// mode once it resolves. On failure, stays on the current view and
  /// leaves `existingRate` unset — there's no dedicated error surface for
  /// this fetch, so failing quietly (rather than navigating into a wizard
  /// with no data) is the safer default.
  Future<void> _onEditRateRequested(
    EditRateRequested event,
    Emitter<RatesShellState> emit,
  ) async {
    // Remember where this edit was opened from (e.g. the shipping
    // calculator's "Edit this rate") so `WizardExitRequested` can return
    // here instead of always falling back to its default destination.
    final returnView = state.view;
    emit(state.copyWith(editRateLoading: true));
    try {
      final rate = await _repository.fetchRateById(event.rateId);
      emit(
        state.copyWith(
          editRateLoading: false,
          existingRate: rate,
          view: RatesView.create,
          rateChoice: rate.isCustom ? RateType.custom : RateType.published,
          returnView: returnView,
        ),
      );
    } catch (e, st) {
      appLogger.e(
        'Failed to load rate ${event.rateId} for edit',
        error: e,
        stackTrace: st,
      );
      emit(state.copyWith(editRateLoading: false));
    }
  }

  /// Hard-deletes `event.rateId` via the API, then strips it out of
  /// whichever local lists hold it (published/custom) so the UI updates
  /// without a full refetch. `recentRates` (dashboard) has no `id` field to
  /// match against, so a deleted rate lingers there until the next
  /// `RatesDataRequested` — acceptable since delete is only exposed from the
  /// Published/Custom rate list screens, not the dashboard.
  Future<void> _onDeleteRateRequested(
    DeleteRateRequested event,
    Emitter<RatesShellState> emit,
  ) async {
    emit(state.copyWith(deletingRateId: event.rateId));
    try {
      await _repository.deleteRate(event.rateId);
      final clientId = state.selectedClientId;
      emit(
        state.copyWith(
          clearDeletingRateId: true,
          deleteRateSucceeded: true,
          publishedRates: state.publishedRates
              .where((r) => r.id != event.rateId)
              .toList(),
          selectedClientRates: state.selectedClientRates
              .where((r) => r.id != event.rateId)
              .toList(),
          clientRateCounts: clientId == null
              ? state.clientRateCounts
              : {
                  ...state.clientRateCounts,
                  clientId: ((state.clientRateCounts[clientId] ?? 1) - 1).clamp(
                    0,
                    1 << 30,
                  ),
                },
        ),
      );
    } catch (e, st) {
      appLogger.e(
        'Failed to delete rate ${event.rateId}',
        error: e,
        stackTrace: st,
      );
      emit(
        state.copyWith(
          clearDeletingRateId: true,
          deleteRateError: 'Failed to delete rate. Please try again.',
        ),
      );
    }
  }

  Future<void> _onAuditTrailRequested(
    AuditTrailRequested event,
    Emitter<RatesShellState> emit,
  ) async {
    emit(state.copyWith(view: RatesView.auditTrail, auditLogsLoading: true));
    List<AuditLog> logs = const [];
    try {
      logs = await _repository.fetchAuditLogs();
    } catch (e, st) {
      appLogger.e('Failed to load audit logs', error: e, stackTrace: st);
    }
    emit(state.copyWith(auditLogs: logs, auditLogsLoading: false));
  }
}
