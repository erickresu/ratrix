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
  final int clientRatePage;
  final FreightMode? clientRateFreightFilter;
  final ServiceMode? clientRateServiceFilter;
  final bool clientRateSortByExpiry;

  /// The full rate being edited, set once `EditRateRequested`'s fetch
  /// resolves; `WizardPage` reads this to construct `RateWizardBloc` in
  /// edit mode. Cleared whenever a fresh (create) wizard is opened.
  final RatrixRate? existingRate;
  final bool editRateLoading;

  final String calcClientSearch;
  final int calcClientPage;
  final String? selectedCalcClientId;

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
    this.clientRatePage = 0,
    this.clientRateFreightFilter,
    this.clientRateServiceFilter,
    this.clientRateSortByExpiry = false,
    this.existingRate,
    this.editRateLoading = false,
    this.calcClientSearch = '',
    this.calcClientPage = 0,
    this.selectedCalcClientId,
  });

  static const clientsPerPage = 9;
  static const clientRatesPerPage = 6;

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

  List<Client> get filteredCalcClients {
    if (calcClientSearch.isEmpty) return clients;
    final q = calcClientSearch.toLowerCase();
    return clients.where((c) => c.name.toLowerCase().contains(q)).toList();
  }

  int get calcClientPageCount => (filteredCalcClients.length / clientsPerPage).ceil().clamp(1, 1 << 30);

  List<Client> get pagedCalcClients {
    final start = calcClientPage * clientsPerPage;
    if (start >= filteredCalcClients.length) return const [];
    final end = (start + clientsPerPage).clamp(0, filteredCalcClients.length);
    return filteredCalcClients.sublist(start, end);
  }

  Client? get selectedCalcClient {
    if (selectedCalcClientId == null) return null;
    for (final c in clients) {
      if (c.id == selectedCalcClientId) return c;
    }
    return null;
  }

  List<ClientRate> get filteredClientRates {
    final q = clientRateSearch.toLowerCase();
    return selectedClientRates.where((r) {
      if (r.status != clientRatesTab) return false;
      if (clientRateFreightFilter != null && r.freightMode != clientRateFreightFilter) return false;
      if (clientRateServiceFilter != null && r.serviceMode != clientRateServiceFilter) return false;
      if (q.isEmpty) return true;
      return r.chargeCode.toLowerCase().contains(q) || r.freightMode.label.toLowerCase().contains(q);
    }).toList()
      ..sort((a, b) {
        if (!clientRateSortByExpiry) return 0;
        final ad = a.expiryDate;
        final bd = b.expiryDate;
        if (ad == null && bd == null) return 0;
        if (ad == null) return 1;
        if (bd == null) return -1;
        return ad.compareTo(bd);
      });
  }

  int get clientRatePageCount => (filteredClientRates.length / clientRatesPerPage).ceil().clamp(1, 1 << 30);

  List<ClientRate> get pagedClientRates {
    final start = clientRatePage * clientRatesPerPage;
    if (start >= filteredClientRates.length) return const [];
    final end = (start + clientRatesPerPage).clamp(0, filteredClientRates.length);
    return filteredClientRates.sublist(start, end);
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
    int? clientRatePage,
    FreightMode? clientRateFreightFilter,
    bool clearClientRateFreightFilter = false,
    ServiceMode? clientRateServiceFilter,
    bool clearClientRateServiceFilter = false,
    bool? clientRateSortByExpiry,
    RatrixRate? existingRate,
    bool clearExistingRate = false,
    bool? editRateLoading,
    String? calcClientSearch,
    int? calcClientPage,
    String? selectedCalcClientId,
    bool clearSelectedCalcClientId = false,
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
      clientRatePage: clientRatePage ?? this.clientRatePage,
      clientRateFreightFilter: clearClientRateFreightFilter ? null : (clientRateFreightFilter ?? this.clientRateFreightFilter),
      clientRateServiceFilter: clearClientRateServiceFilter ? null : (clientRateServiceFilter ?? this.clientRateServiceFilter),
      clientRateSortByExpiry: clientRateSortByExpiry ?? this.clientRateSortByExpiry,
      existingRate: clearExistingRate ? null : (existingRate ?? this.existingRate),
      editRateLoading: editRateLoading ?? this.editRateLoading,
      calcClientSearch: calcClientSearch ?? this.calcClientSearch,
      calcClientPage: calcClientPage ?? this.calcClientPage,
      selectedCalcClientId: clearSelectedCalcClientId ? null : (selectedCalcClientId ?? this.selectedCalcClientId),
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
        existingRate,
        editRateLoading,
        clientRatesLoading,
        clientRateSearch,
        clientRatesTab,
        clientRatePage,
        clientRateFreightFilter,
        clientRateServiceFilter,
        clientRateSortByExpiry,
        calcClientSearch,
        calcClientPage,
        selectedCalcClientId,
      ];
}
