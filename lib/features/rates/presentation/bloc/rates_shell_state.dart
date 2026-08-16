part of 'rates_shell_bloc.dart';

class RatesShellState extends Equatable {
  final bool isLoading;
  final RatesView view;
  final bool ratesMenuOpen;
  final bool profileMenuOpen;
  final bool modalOpen;
  final RateType? rateChoice;

  final List<RateStat> stats;
  final List<RecentRate> recentRates;

  final List<Client> clients;
  final Map<String, int> clientRateCounts;
  final String clientSearch;

  final String? selectedClientId;
  final List<ClientRate> selectedClientRates;
  final String clientRateSearch;
  final RateStatus clientRatesTab;

  const RatesShellState({
    this.isLoading = true,
    this.view = RatesView.dashboard,
    this.ratesMenuOpen = true,
    this.profileMenuOpen = false,
    this.modalOpen = false,
    this.rateChoice,
    this.stats = const [],
    this.recentRates = const [],
    this.clients = const [],
    this.clientRateCounts = const {},
    this.clientSearch = '',
    this.selectedClientId,
    this.selectedClientRates = const [],
    this.clientRateSearch = '',
    this.clientRatesTab = RateStatus.active,
  });

  List<Client> get filteredClients {
    if (clientSearch.isEmpty) return clients;
    final q = clientSearch.toLowerCase();
    return clients.where((c) => c.name.toLowerCase().contains(q)).toList();
  }

  Client? get selectedClient {
    if (selectedClientId == null) return null;
    for (final c in clients) {
      if (c.id == selectedClientId) return c;
    }
    return null;
  }

  List<ClientRate> get filteredClientRates {
    final q = clientRateSearch.toLowerCase();
    return selectedClientRates.where((r) {
      if (r.status != clientRatesTab) return false;
      if (q.isEmpty) return true;
      return r.chargeCode.toLowerCase().contains(q) || r.freightMode.label.toLowerCase().contains(q);
    }).toList();
  }

  RatesShellState copyWith({
    bool? isLoading,
    RatesView? view,
    bool? ratesMenuOpen,
    bool? profileMenuOpen,
    bool? modalOpen,
    RateType? rateChoice,
    bool clearRateChoice = false,
    List<RateStat>? stats,
    List<RecentRate>? recentRates,
    List<Client>? clients,
    Map<String, int>? clientRateCounts,
    String? clientSearch,
    String? selectedClientId,
    List<ClientRate>? selectedClientRates,
    String? clientRateSearch,
    RateStatus? clientRatesTab,
  }) {
    return RatesShellState(
      isLoading: isLoading ?? this.isLoading,
      view: view ?? this.view,
      ratesMenuOpen: ratesMenuOpen ?? this.ratesMenuOpen,
      profileMenuOpen: profileMenuOpen ?? this.profileMenuOpen,
      modalOpen: modalOpen ?? this.modalOpen,
      rateChoice: clearRateChoice ? null : (rateChoice ?? this.rateChoice),
      stats: stats ?? this.stats,
      recentRates: recentRates ?? this.recentRates,
      clients: clients ?? this.clients,
      clientRateCounts: clientRateCounts ?? this.clientRateCounts,
      clientSearch: clientSearch ?? this.clientSearch,
      selectedClientId: selectedClientId ?? this.selectedClientId,
      selectedClientRates: selectedClientRates ?? this.selectedClientRates,
      clientRateSearch: clientRateSearch ?? this.clientRateSearch,
      clientRatesTab: clientRatesTab ?? this.clientRatesTab,
    );
  }

  @override
  List<Object?> get props => [
        isLoading,
        view,
        ratesMenuOpen,
        profileMenuOpen,
        modalOpen,
        rateChoice,
        stats,
        recentRates,
        clients,
        clientRateCounts,
        clientSearch,
        selectedClientId,
        selectedClientRates,
        clientRateSearch,
        clientRatesTab,
      ];
}
