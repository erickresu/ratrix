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
  final int clientPage;

  final String? selectedClientId;
  final List<ClientRate> selectedClientRates;
  final bool clientRatesLoading;
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
    this.clientPage = 0,
    this.selectedClientId,
    this.selectedClientRates = const [],
    this.clientRatesLoading = false,
    this.clientRateSearch = '',
    this.clientRatesTab = RateStatus.active,
  });

  static const clientsPerPage = 15;

  List<Client> get filteredClients {
    if (clientSearch.isEmpty) return clients;
    final q = clientSearch.toLowerCase();
    return clients.where((c) => c.name.toLowerCase().contains(q)).toList();
  }

  int get clientPageCount => (filteredClients.length / clientsPerPage).ceil().clamp(1, 1 << 30);

  List<Client> get pagedClients {
    final start = clientPage * clientsPerPage;
    if (start >= filteredClients.length) return const [];
    final end = (start + clientsPerPage).clamp(0, filteredClients.length);
    return filteredClients.sublist(start, end);
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
    int? clientPage,
    String? selectedClientId,
    List<ClientRate>? selectedClientRates,
    bool? clientRatesLoading,
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
      clientPage: clientPage ?? this.clientPage,
      selectedClientId: selectedClientId ?? this.selectedClientId,
      selectedClientRates: selectedClientRates ?? this.selectedClientRates,
      clientRatesLoading: clientRatesLoading ?? this.clientRatesLoading,
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
        clientPage,
        selectedClientId,
        selectedClientRates,
        clientRatesLoading,
        clientRateSearch,
        clientRatesTab,
      ];
}
