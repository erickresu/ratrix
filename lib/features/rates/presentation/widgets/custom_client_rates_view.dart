import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ratrix/core/widgets/shine_sweep.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import '../../../../core/utils/breakpoints.dart';
import '../../../../core/widgets/horizontal_scroll_table.dart';
import '../../../../core/widgets/mr_ratrix.dart';
import '../../../../core/widgets/pagination_bar.dart';
import '../../../../core/widgets/skeleton_box.dart';
import '../../domain/entities/client_rate.dart';
import '../../domain/entities/rates_enums.dart';
import '../bloc/rates_shell_bloc.dart';
import '../rates_colors.dart';
import 'back_pill.dart';
import 'delete_rate_dialog.dart';

const _kAllValue = '__all__';

class CustomClientRatesView extends StatelessWidget {
  const CustomClientRatesView({super.key});

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<RatesShellBloc>();
    final state = context.watch<RatesShellBloc>().state;
    final client = state.selectedClient;
    if (client == null) return const SizedBox.shrink();
    final isMobile = Breakpoints.isMobile(context);

    final avatar = ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: ShineSweep(
        child: Container(
          width: 52,
          height: 52,
          alignment: Alignment.center,
          color: context.colors.primary.withValues(alpha: 0.2),
          child: Text(
            client.initials,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Color(0xFF6FE0C6),
            ),
          ),
        ),
      ),
    );

    final clientInfo = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          client.name,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          '${client.accountNumber} · ${client.email}',
          style: TextStyle(
            fontSize: 13,
            color: Colors.white.withValues(alpha: 0.55),
            fontFamily: 'monospace',
          ),
        ),
      ],
    );

    final createRateButton = ShadButton(
      backgroundColor: context.colors.primary,
      hoverBackgroundColor: context.colors.primaryHover,
      leading: const Icon(CupertinoIcons.add, size: 17, color: Colors.white),
      onPressed: () =>
          bloc.add(const CreateCustomRateForSelectedClientRequested()),
      child: const Text('Create New Rate'),
    );

    final tabsRow = Row(
      children: [
        _TabPill(
          label: 'Active',
          selected: state.clientRatesTab == RateStatus.active,
          onTap: () => bloc.add(const ClientRatesTabChanged(RateStatus.active)),
        ),
        const SizedBox(width: 8),
        _TabPill(
          label: 'Expired',
          selected: state.clientRatesTab == RateStatus.expired,
          onTap: () =>
              bloc.add(const ClientRatesTabChanged(RateStatus.expired)),
        ),
      ],
    );

    final freightFilter = SizedBox(
      width: 170,
      child: ShadSelect<String>(
        placeholder: const Text('Freight mode'),
        initialValue: state.clientRateFreightFilter?.name ?? _kAllValue,
        selectedOptionBuilder: (context, value) => Text(
          value == _kAllValue
              ? 'All modes'
              : FreightMode.values.byName(value).label,
        ),
        onChanged: (value) {
          if (value == null) return;
          bloc.add(
            ClientRateFreightFilterChanged(
              value == _kAllValue ? null : FreightMode.values.byName(value),
            ),
          );
        },
        options: [
          const ShadOption(value: _kAllValue, child: Text('All modes')),
          for (final m in FreightMode.values)
            ShadOption(value: m.name, child: Text(m.label)),
        ],
      ),
    );

    final serviceFilter = SizedBox(
      width: 170,
      child: ShadSelect<String>(
        placeholder: const Text('Service mode'),
        initialValue: state.clientRateServiceFilter?.name ?? _kAllValue,
        selectedOptionBuilder: (context, value) => Text(
          value == _kAllValue
              ? 'All services'
              : ServiceMode.values.byName(value).label,
        ),
        onChanged: (value) {
          if (value == null) return;
          bloc.add(
            ClientRateServiceFilterChanged(
              value == _kAllValue ? null : ServiceMode.values.byName(value),
            ),
          );
        },
        options: [
          const ShadOption(value: _kAllValue, child: Text('All services')),
          for (final m in ServiceMode.values)
            ShadOption(value: m.name, child: Text(m.label)),
        ],
      ),
    );

    final searchField = SizedBox(
      width: 260,
      child: ShadInput(
        placeholder: const Text('Search by charge code, freight mode...'),
        leading: Padding(
          padding: const EdgeInsets.only(left: 4),
          child: Icon(
            CupertinoIcons.search,
            size: 16,
            color: context.colors.textMuted,
          ),
        ),
        onChanged: (v) => bloc.add(ClientRateSearchChanged(v)),
      ),
    );

    final sortToggle = _SortByExpiryToggle(
      active: state.clientRateSortByExpiry,
      onTap: () => bloc.add(const ClientRateSortByExpiryToggled()),
    );

    final filtersControlsRow = isMobile
        ? Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [freightFilter, serviceFilter, searchField, sortToggle],
          )
        : Row(
            children: [
              tabsRow,
              const Spacer(),
              freightFilter,
              const SizedBox(width: 8),
              serviceFilter,
              const SizedBox(width: 8),
              searchField,
              const SizedBox(width: 8),
              sortToggle,
            ],
          );

    return MultiBlocListener(
      listeners: [
        BlocListener<RatesShellBloc, RatesShellState>(
          listenWhen: (prev, curr) =>
              curr.deleteRateError != null &&
              prev.deleteRateError != curr.deleteRateError,
          listener: (context, state) {
            ShadToaster.of(context).show(
              ShadToast.destructive(
                alignment: Alignment.bottomRight,
                title: const Text('Delete failed'),
                description: Text(state.deleteRateError!),
              ),
            );
            bloc.add(const DeleteRateErrorDismissed());
          },
        ),
        BlocListener<RatesShellBloc, RatesShellState>(
          listenWhen: (prev, curr) =>
              curr.deleteRateSucceeded && !prev.deleteRateSucceeded,
          listener: (context, state) {
            ShadToaster.of(context).show(
              const ShadToast(
                alignment: Alignment.bottomRight,
                title: Text('Rate deleted'),
              ),
            );
            bloc.add(const DeleteRateSuccessDismissed());
          },
        ),
      ],
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(
              isMobile ? 20 : 64,
              48,
              isMobile ? 20 : 64,
              40,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                BackPill(onTap: () => bloc.add(const ClientsBackRequested())),
                const SizedBox(height: 24),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: isMobile ? 16 : 32,
                    vertical: isMobile ? 20 : 28,
                  ),
                  decoration: BoxDecoration(
                    color: context.colors.sidebarPanelBg,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: isMobile
                      ? Wrap(
                          crossAxisAlignment: WrapCrossAlignment.center,
                          spacing: 16,
                          runSpacing: 16,
                          children: [
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                avatar,
                                const SizedBox(width: 16),
                                Flexible(child: clientInfo),
                              ],
                            ),
                            createRateButton,
                          ],
                        )
                      : Row(
                          children: [
                            avatar,
                            const SizedBox(width: 16),
                            Expanded(child: clientInfo),
                            createRateButton,
                          ],
                        ),
                ),
                const SizedBox(height: 28),
                if (isMobile) ...[tabsRow, const SizedBox(height: 16)],
                filtersControlsRow,
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(
                isMobile ? 20 : 64,
                0,
                isMobile ? 20 : 64,
                24,
              ),
              child: state.clientRatesLoading
                  ? const SkeletonShimmer(
                      child: Column(
                        children: [
                          ListRowCardSkeleton(),
                          SizedBox(height: 16),
                          ListRowCardSkeleton(),
                          SizedBox(height: 16),
                          ListRowCardSkeleton(),
                        ],
                      ),
                    )
                  : state.filteredClientRates.isEmpty
                  ? Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(40),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: context.colors.borderStrong,
                          style: BorderStyle.solid,
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const MrRatrix(size: 96),
                          const SizedBox(height: 4),
                          Text(
                            'No ${state.clientRatesTab.label.toLowerCase()} rates for this client.',
                            style: TextStyle(
                              fontSize: 14,
                              color: context.colors.textMuted,
                            ),
                          ),
                        ],
                      ),
                    )
                  : _ClientRatesTable(
                      rates: state.pagedClientRates,
                      deletingRateId: state.deletingRateId,
                      onEdit: (rate) => bloc.add(EditRateRequested(rate.id)),
                      onDelete: (rate) async {
                        final confirmed = await showShadDialog<bool>(
                          context: context,
                          builder: (_) =>
                              DeleteRateDialog(chargeCode: rate.chargeCode),
                        );
                        if (confirmed == true)
                          bloc.add(DeleteRateRequested(rate.id));
                      },
                    ),
            ),
          ),
          if (!state.clientRatesLoading && state.filteredClientRates.isNotEmpty)
            PaginationBar(
              page: state.clientRatePage,
              itemsPerPage: RatesShellState.clientRatesPerPage,
              totalItems: state.filteredClientRates.length,
              onPageChanged: (p) => bloc.add(ClientRatePageChanged(p)),
            ),
        ],
      ),
    );
  }
}

class _TabPill extends StatelessWidget {
  const _TabPill({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(7),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: selected ? context.colors.primary : context.colors.surface,
            border: Border.all(
              color: selected
                  ? context.colors.primary
                  : context.colors.borderStrong,
            ),
            borderRadius: BorderRadius.circular(7),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: selected ? Colors.white : context.colors.textMutedStrong,
            ),
          ),
        ),
      ),
    );
  }
}

class _SortByExpiryToggle extends StatelessWidget {
  const _SortByExpiryToggle({required this.active, required this.onTap});

  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: 'Sort by soonest to expire',
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(7),
          onTap: onTap,
          child: Container(
            width: 40,
            height: 40,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: active ? context.colors.primary : context.colors.surface,
              border: Border.all(
                color: active
                    ? context.colors.primary
                    : context.colors.borderStrong,
              ),
              borderRadius: BorderRadius.circular(7),
            ),
            child: Icon(
              CupertinoIcons.sort_down,
              size: 16,
              color: active ? Colors.white : context.colors.textMutedStrong,
            ),
          ),
        ),
      ),
    );
  }
}

class _ClientRatesTable extends StatelessWidget {
  const _ClientRatesTable({
    required this.rates,
    required this.deletingRateId,
    required this.onEdit,
    required this.onDelete,
  });

  final List<ClientRate> rates;
  final String? deletingRateId;
  final ValueChanged<ClientRate> onEdit;
  final ValueChanged<ClientRate> onDelete;

  static const _headerStyle = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.4,
  );

  // Mobile column widths — CHARGE CODE stays pinned in a fixed left pane,
  // MODE/SERVICE/ROUTES/STATUS/actions scroll horizontally together, same
  // split the dashboard's recent-rates table and the rate wizard's matrix
  // table use.
  static const _chargeCodeWidth = 130.0;
  static const _modeWidth = 90.0;
  static const _serviceWidth = 90.0;
  static const _routesWidth = 90.0;
  static const _statusWidth = 130.0;
  static const _actionsWidth = 92.0;
  static const _colGap = 12.0;
  static const _headerHeight = 40.0;
  static const _rowHeight = 64.0;
  // +24 accounts for the scrollable pane's own 12px symmetric padding
  // (left+right) around the header/row content — without it the last
  // column (actions) clips against the pane's right edge.
  static const _scrollableWidth = _modeWidth +
      _serviceWidth +
      _routesWidth +
      _statusWidth +
      _actionsWidth +
      _colGap * 4 +
      24;

  @override
  Widget build(BuildContext context) {
    final isMobile = Breakpoints.isMobile(context);

    return Container(
      decoration: BoxDecoration(
        color: context.colors.surface,
        border: Border.all(color: context.colors.border),
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: context.colors.shadowSoft,
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: isMobile ? _buildMobile(context) : _buildDesktop(context),
    );
  }

  Widget _buildDesktop(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          color: context.colors.surfaceSubtle,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          child: Row(
            children: [
              Expanded(
                flex: 3,
                child: Text(
                  'CHARGE CODE',
                  style: _headerStyle.copyWith(color: context.colors.textMuted),
                ),
              ),
              Expanded(
                flex: 2,
                child: Text(
                  'MODE',
                  style: _headerStyle.copyWith(color: context.colors.textMuted),
                ),
              ),
              Expanded(
                flex: 2,
                child: Text(
                  'SERVICE',
                  style: _headerStyle.copyWith(color: context.colors.textMuted),
                ),
              ),
              Expanded(
                flex: 2,
                child: Text(
                  'ROUTES',
                  style: _headerStyle.copyWith(color: context.colors.textMuted),
                ),
              ),
              Expanded(
                flex: 3,
                child: Text(
                  'STATUS',
                  style: _headerStyle.copyWith(color: context.colors.textMuted),
                ),
              ),
              const SizedBox(width: 80),
            ],
          ),
        ),
        for (final rate in rates)
          _ClientRateRow(
            rate: rate,
            deleting: deletingRateId == rate.id,
            onTap: () => onEdit(rate),
            onDelete: () => onDelete(rate),
          ),
      ],
    );
  }

  Widget _buildMobile(BuildContext context) {
    Widget headerCell(String text, double width, {TextAlign align = TextAlign.left}) =>
        SizedBox(
          width: width,
          child: Text(
            text,
            textAlign: align,
            style: _headerStyle.copyWith(color: context.colors.textMuted),
          ),
        );

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: _chargeCodeWidth,
          child: Column(
            children: [
              Container(
                height: _headerHeight,
                alignment: Alignment.centerLeft,
                padding: const EdgeInsets.only(left: 20),
                color: context.colors.surfaceSubtle,
                child: Text(
                  'CHARGE CODE',
                  style: _headerStyle.copyWith(color: context.colors.textMuted),
                ),
              ),
              for (final rate in rates)
                Container(
                  height: _rowHeight,
                  alignment: Alignment.centerLeft,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  decoration: BoxDecoration(
                    border: Border(top: BorderSide(color: context.colors.border)),
                  ),
                  child: Text(
                    rate.chargeCode,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      fontFamily: 'monospace',
                      color: context.colors.textBody,
                    ),
                  ),
                ),
            ],
          ),
        ),
        Expanded(
          child: HorizontalScrollTable(
            width: _scrollableWidth,
            child: Column(
              children: [
                Container(
                  height: _headerHeight,
                  alignment: Alignment.centerLeft,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  color: context.colors.surfaceSubtle,
                  child: Row(
                    children: [
                      headerCell('MODE', _modeWidth),
                      const SizedBox(width: _colGap),
                      headerCell('SERVICE', _serviceWidth),
                      const SizedBox(width: _colGap),
                      headerCell('ROUTES', _routesWidth),
                      const SizedBox(width: _colGap),
                      headerCell('STATUS', _statusWidth),
                      const SizedBox(width: _colGap),
                      SizedBox(width: _actionsWidth),
                    ],
                  ),
                ),
                for (final rate in rates)
                  _ClientRateRow(
                    rate: rate,
                    deleting: deletingRateId == rate.id,
                    onTap: () => onEdit(rate),
                    onDelete: () => onDelete(rate),
                    compact: true,
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _ClientRateRow extends StatelessWidget {
  const _ClientRateRow({
    required this.rate,
    required this.deleting,
    required this.onTap,
    required this.onDelete,
    this.compact = false,
  });

  final ClientRate rate;
  final bool deleting;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  /// Renders without the CHARGE CODE column (pinned separately in mobile's
  /// fixed left pane) and with fixed-width columns matching
  /// `_ClientRatesTable._buildMobile`'s header, instead of flex columns.
  final bool compact;

  Widget _modeBadge(BuildContext context) => ShadBadge(
        backgroundColor: context.colors.successBg.withValues(alpha: 0.6),
        hoverBackgroundColor: context.colors.successBg.withValues(alpha: 0.6),
        foregroundColor: context.colors.primaryDeep,
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
        child: Text(
          rate.freightMode.label,
          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
        ),
      );

  Widget _statusBadge(BuildContext context, bool isActive) => ShadBadge(
        backgroundColor:
            isActive ? context.colors.successBg : context.colors.surfaceMuted,
        hoverBackgroundColor:
            isActive ? context.colors.successBg : context.colors.surfaceMuted,
        foregroundColor:
            isActive ? context.colors.successText : context.colors.textMuted,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        child: Text(
          rate.expiryLabel,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
        ),
      );

  Widget _actions(BuildContext context, {required double width}) => SizedBox(
        width: width,
        child: deleting
            ? const Center(
                child: SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  _RowActionButton(
                    icon: CupertinoIcons.pencil,
                    background: context.colors.primaryChipBg,
                    foreground: context.colors.primaryDeep,
                    onTap: onTap,
                  ),
                  const SizedBox(width: 6),
                  _RowActionButton(
                    icon: CupertinoIcons.trash,
                    background:
                        context.colors.destructive.withValues(alpha: 0.1),
                    foreground: context.colors.destructive,
                    onTap: onDelete,
                  ),
                ],
              ),
      );

  @override
  Widget build(BuildContext context) {
    final isActive = rate.status == RateStatus.active;

    if (compact) {
      return Opacity(
        opacity: deleting ? 0.5 : 1,
        child: Container(
          height: _ClientRatesTable._rowHeight,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            border: Border(top: BorderSide(color: context.colors.border)),
          ),
          child: Row(
            children: [
              SizedBox(
                width: _ClientRatesTable._modeWidth,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: _modeBadge(context),
                ),
              ),
              const SizedBox(width: _ClientRatesTable._colGap),
              SizedBox(
                width: _ClientRatesTable._serviceWidth,
                child: Text(
                  rate.serviceMode.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 13,
                    color: context.colors.textMutedStrong,
                  ),
                ),
              ),
              const SizedBox(width: _ClientRatesTable._colGap),
              SizedBox(
                width: _ClientRatesTable._routesWidth,
                child: Text(
                  '${rate.routeCount} route(s)',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style:
                      TextStyle(fontSize: 13, color: context.colors.textMuted),
                ),
              ),
              const SizedBox(width: _ClientRatesTable._colGap),
              SizedBox(
                width: _ClientRatesTable._statusWidth,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: _statusBadge(context, isActive),
                ),
              ),
              const SizedBox(width: _ClientRatesTable._colGap),
              _actions(context, width: _ClientRatesTable._actionsWidth),
            ],
          ),
        ),
      );
    }

    return Opacity(
      opacity: deleting ? 0.5 : 1,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        decoration: BoxDecoration(
          border: Border(top: BorderSide(color: context.colors.border)),
        ),
        child: Row(
          children: [
            Expanded(
              flex: 3,
              child: Text(
                rate.chargeCode,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'monospace',
                  color: context.colors.textBody,
                ),
              ),
            ),
            Expanded(
              flex: 2,
              child: Align(
                alignment: Alignment.centerLeft,
                child: _modeBadge(context),
              ),
            ),
            Expanded(
              flex: 2,
              child: Text(
                rate.serviceMode.label,
                style: TextStyle(
                  fontSize: 12,
                  color: context.colors.textMutedStrong,
                ),
              ),
            ),
            Expanded(
              flex: 2,
              child: Text(
                '${rate.routeCount} route(s)',
                style: TextStyle(fontSize: 12, color: context.colors.textMuted),
              ),
            ),
            Expanded(
              flex: 3,
              child: Align(
                alignment: Alignment.centerLeft,
                child: _statusBadge(context, isActive),
              ),
            ),
            _actions(context, width: 80),
          ],
        ),
      ),
    );
  }
}

class _RowActionButton extends StatelessWidget {
  const _RowActionButton({
    required this.icon,
    required this.background,
    required this.foreground,
    required this.onTap,
  });

  final IconData icon;
  final Color background;
  final Color foreground;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: background,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(7),
          child: Icon(icon, size: 15, color: foreground),
        ),
      ),
    );
  }
}
