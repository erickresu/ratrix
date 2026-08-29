part of 'rates_shell_bloc.dart';

int _pageCount(int totalItems, int perPage) =>
    (totalItems / perPage).ceil().clamp(1, 1 << 30);

List<T> _paginate<T>(List<T> items, int page, int perPage) {
  final start = page * perPage;
  if (start >= items.length) return const [];
  final end = (start + perPage).clamp(0, items.length);
  return items.sublist(start, end);
}

List<Client> _searchClients(List<Client> clients, String query) {
  final list = query.isEmpty
      ? clients
      : clients
            .where((c) => c.name.toLowerCase().contains(query.toLowerCase()))
            .toList();
  return [...list]
    ..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
}

Client? _findClientById(List<Client> clients, String? id) {
  if (id == null) return null;
  for (final c in clients) {
    if (c.id == id) return c;
  }
  return null;
}

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

  /// The view to return to when the wizard exits (Back or a successful
  /// save), captured from whatever view was active when `EditRateRequested`
  /// fired. Null for a plain "create new rate" flow — those fall back to
  /// `WizardExitRequested.fallback` instead.
  final RatesView? returnView;

  final String calcClientSearch;
  final int calcClientPage;
  final String? selectedCalcClientId;

  final List<PublishedRate> publishedRates;
  final bool publishedRatesLoading;
  final String publishedRateSearch;
  final RateStatus publishedRatesTab;
  final int publishedRatePage;
  final FreightMode? publishedRateFreightFilter;
  final ServiceMode? publishedRateServiceFilter;
  final bool publishedRateSortByExpiry;

  /// Id of the rate currently being deleted, so its row can show a spinner
  /// and disable further taps. Null once the delete settles either way.
  final String? deletingRateId;

  /// Set on a failed delete; a `BlocListener` shows it once (a SnackBar)
  /// then fires `DeleteRateErrorDismissed` to clear it.
  final String? deleteRateError;

  /// Set on a successful delete; a `BlocListener` shows it once (a toast)
  /// then fires `DeleteRateSuccessDismissed` to clear it. Same one-shot
  /// pattern as `deleteRateError`.
  final bool deleteRateSucceeded;

  final List<AuditLog> auditLogs;
  final bool auditLogsLoading;
  final String auditLogSearch;

  /// One of `'create' | 'update' | 'delete'`, or null for "all actions".
  final String? auditLogActionFilter;
  final int auditLogPage;

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
    this.returnView,
    this.calcClientSearch = '',
    this.calcClientPage = 0,
    this.selectedCalcClientId,
    this.publishedRates = const [],
    this.publishedRatesLoading = false,
    this.publishedRateSearch = '',
    this.publishedRatesTab = RateStatus.active,
    this.publishedRatePage = 0,
    this.publishedRateFreightFilter,
    this.publishedRateServiceFilter,
    this.publishedRateSortByExpiry = false,
    this.deletingRateId,
    this.deleteRateError,
    this.deleteRateSucceeded = false,
    this.auditLogs = const [],
    this.auditLogsLoading = false,
    this.auditLogSearch = '',
    this.auditLogActionFilter,
    this.auditLogPage = 0,
  });

  static const clientsPerPage = 9;
  static const clientRatesPerPage = 5;
  static const publishedRatesPerPage = 5;
  static const auditLogsPerPage = 8;

  List<Client> get filteredClients => _searchClients(clients, clientSearch);

  int get clientPageCount =>
      _pageCount(filteredClients.length, clientsPerPage);

  List<Client> get pagedClients =>
      _paginate(filteredClients, clientPage, clientsPerPage);

  Client? get selectedClient => _findClientById(clients, selectedClientId);

  List<Client> get filteredCalcClients =>
      _searchClients(clients, calcClientSearch);

  int get calcClientPageCount =>
      _pageCount(filteredCalcClients.length, clientsPerPage);

  List<Client> get pagedCalcClients =>
      _paginate(filteredCalcClients, calcClientPage, clientsPerPage);

  Client? get selectedCalcClient =>
      _findClientById(clients, selectedCalcClientId);

  List<ClientRate> get filteredClientRates {
    final q = clientRateSearch.toLowerCase();
    return selectedClientRates.where((r) {
      if (r.status != clientRatesTab) return false;
      if (clientRateFreightFilter != null &&
          r.freightMode != clientRateFreightFilter)
        return false;
      if (clientRateServiceFilter != null &&
          r.serviceMode != clientRateServiceFilter)
        return false;
      if (q.isEmpty) return true;
      return r.chargeCode.toLowerCase().contains(q) ||
          r.freightMode.label.toLowerCase().contains(q);
    }).toList()..sort((a, b) {
      if (!clientRateSortByExpiry) return 0;
      final ad = a.expiryDate;
      final bd = b.expiryDate;
      if (ad == null && bd == null) return 0;
      if (ad == null) return 1;
      if (bd == null) return -1;
      return ad.compareTo(bd);
    });
  }

  int get clientRatePageCount =>
      _pageCount(filteredClientRates.length, clientRatesPerPage);

  List<ClientRate> get pagedClientRates =>
      _paginate(filteredClientRates, clientRatePage, clientRatesPerPage);

  List<PublishedRate> get filteredPublishedRates {
    final q = publishedRateSearch.toLowerCase();
    return publishedRates.where((r) {
      if (r.status != publishedRatesTab) return false;
      if (publishedRateFreightFilter != null &&
          r.freightMode != publishedRateFreightFilter)
        return false;
      if (publishedRateServiceFilter != null &&
          r.serviceMode != publishedRateServiceFilter)
        return false;
      if (q.isEmpty) return true;
      return r.chargeCode.toLowerCase().contains(q) ||
          r.freightMode.label.toLowerCase().contains(q) ||
          r.routeLabel.toLowerCase().contains(q);
    }).toList()..sort((a, b) {
      if (!publishedRateSortByExpiry) return 0;
      final ad = a.expiryDate;
      final bd = b.expiryDate;
      if (ad == null && bd == null) return 0;
      if (ad == null) return 1;
      if (bd == null) return -1;
      return ad.compareTo(bd);
    });
  }

  int get publishedRatePageCount =>
      _pageCount(filteredPublishedRates.length, publishedRatesPerPage);

  List<PublishedRate> get pagedPublishedRates => _paginate(
    filteredPublishedRates,
    publishedRatePage,
    publishedRatesPerPage,
  );

  List<AuditLog> get filteredAuditLogs {
    final q = auditLogSearch.toLowerCase();
    return auditLogs.where((l) {
      if (auditLogActionFilter != null && l.action != auditLogActionFilter) {
        return false;
      }
      if (q.isEmpty) return true;
      return (l.tableName?.toLowerCase().contains(q) ?? false) ||
          (l.recordId?.toLowerCase().contains(q) ?? false) ||
          (l.userName?.toLowerCase().contains(q) ?? false);
    }).toList()..sort((a, b) {
      final ad = a.createdAt;
      final bd = b.createdAt;
      if (ad == null && bd == null) return 0;
      if (ad == null) return 1;
      if (bd == null) return -1;
      return bd.compareTo(ad);
    });
  }

  int get auditLogPageCount =>
      _pageCount(filteredAuditLogs.length, auditLogsPerPage);

  List<AuditLog> get pagedAuditLogs =>
      _paginate(filteredAuditLogs, auditLogPage, auditLogsPerPage);

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
    RatesView? returnView,
    bool clearReturnView = false,
    String? calcClientSearch,
    int? calcClientPage,
    String? selectedCalcClientId,
    bool clearSelectedCalcClientId = false,
    List<PublishedRate>? publishedRates,
    bool? publishedRatesLoading,
    String? publishedRateSearch,
    RateStatus? publishedRatesTab,
    int? publishedRatePage,
    FreightMode? publishedRateFreightFilter,
    bool clearPublishedRateFreightFilter = false,
    ServiceMode? publishedRateServiceFilter,
    bool clearPublishedRateServiceFilter = false,
    bool? publishedRateSortByExpiry,
    String? deletingRateId,
    bool clearDeletingRateId = false,
    String? deleteRateError,
    bool clearDeleteRateError = false,
    bool? deleteRateSucceeded,
    List<AuditLog>? auditLogs,
    bool? auditLogsLoading,
    String? auditLogSearch,
    String? auditLogActionFilter,
    bool clearAuditLogActionFilter = false,
    int? auditLogPage,
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
      clientRateFreightFilter: clearClientRateFreightFilter
          ? null
          : (clientRateFreightFilter ?? this.clientRateFreightFilter),
      clientRateServiceFilter: clearClientRateServiceFilter
          ? null
          : (clientRateServiceFilter ?? this.clientRateServiceFilter),
      clientRateSortByExpiry:
          clientRateSortByExpiry ?? this.clientRateSortByExpiry,
      existingRate: clearExistingRate
          ? null
          : (existingRate ?? this.existingRate),
      editRateLoading: editRateLoading ?? this.editRateLoading,
      returnView: clearReturnView ? null : (returnView ?? this.returnView),
      calcClientSearch: calcClientSearch ?? this.calcClientSearch,
      calcClientPage: calcClientPage ?? this.calcClientPage,
      selectedCalcClientId: clearSelectedCalcClientId
          ? null
          : (selectedCalcClientId ?? this.selectedCalcClientId),
      publishedRates: publishedRates ?? this.publishedRates,
      publishedRatesLoading:
          publishedRatesLoading ?? this.publishedRatesLoading,
      publishedRateSearch: publishedRateSearch ?? this.publishedRateSearch,
      publishedRatesTab: publishedRatesTab ?? this.publishedRatesTab,
      publishedRatePage: publishedRatePage ?? this.publishedRatePage,
      publishedRateFreightFilter: clearPublishedRateFreightFilter
          ? null
          : (publishedRateFreightFilter ?? this.publishedRateFreightFilter),
      publishedRateServiceFilter: clearPublishedRateServiceFilter
          ? null
          : (publishedRateServiceFilter ?? this.publishedRateServiceFilter),
      publishedRateSortByExpiry:
          publishedRateSortByExpiry ?? this.publishedRateSortByExpiry,
      deletingRateId: clearDeletingRateId
          ? null
          : (deletingRateId ?? this.deletingRateId),
      deleteRateError: clearDeleteRateError
          ? null
          : (deleteRateError ?? this.deleteRateError),
      deleteRateSucceeded: deleteRateSucceeded ?? this.deleteRateSucceeded,
      auditLogs: auditLogs ?? this.auditLogs,
      auditLogsLoading: auditLogsLoading ?? this.auditLogsLoading,
      auditLogSearch: auditLogSearch ?? this.auditLogSearch,
      auditLogActionFilter: clearAuditLogActionFilter
          ? null
          : (auditLogActionFilter ?? this.auditLogActionFilter),
      auditLogPage: auditLogPage ?? this.auditLogPage,
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
    returnView,
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
    publishedRates,
    publishedRatesLoading,
    publishedRateSearch,
    publishedRatesTab,
    publishedRatePage,
    publishedRateFreightFilter,
    publishedRateServiceFilter,
    publishedRateSortByExpiry,
    deletingRateId,
    deleteRateError,
    deleteRateSucceeded,
    auditLogs,
    auditLogsLoading,
    auditLogSearch,
    auditLogActionFilter,
    auditLogPage,
  ];
}
