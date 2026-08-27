import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../../../core/utils/breakpoints.dart';
import '../../../../core/widgets/horizontal_scroll_table.dart';
import '../../../../core/widgets/mr_ratrix.dart';
import '../../../../core/widgets/pagination_bar.dart';
import '../../../../core/widgets/skeleton_box.dart';
import '../../domain/entities/published_rate.dart';
import '../../domain/entities/rates_enums.dart';
import '../bloc/rates_shell_bloc.dart';
import '../rates_colors.dart';
import 'delete_rate_dialog.dart';
import 'status_dialog.dart';

const _kAllValue = '__all__';

class PublishedRatesView extends StatelessWidget {
  const PublishedRatesView({super.key});

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<RatesShellBloc>();
    final state = context.watch<RatesShellBloc>().state;
    final isMobile = Breakpoints.isMobile(context);

    final titleColumn = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Published Rates',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.2,
            color: context.colors.textBody,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Standard rates visible to all clients on their route',
          style: TextStyle(fontSize: 14, color: context.colors.textMuted),
        ),
      ],
    );

    final createRateButton = ShadButton(
      backgroundColor: context.colors.primary,
      hoverBackgroundColor: context.colors.primaryHover,
      leading: const Icon(CupertinoIcons.add, size: 17, color: Colors.white),
      onPressed: () => bloc.add(const CreatePublishedRateRequested()),
      child: const Text('Create New Rate'),
    );

    final tabsRow = Row(
      children: [
        _TabPill(
          label: 'Active',
          selected: state.publishedRatesTab == RateStatus.active,
          onTap: () =>
              bloc.add(const PublishedRatesTabChanged(RateStatus.active)),
        ),
        const SizedBox(width: 8),
        _TabPill(
          label: 'Expired',
          selected: state.publishedRatesTab == RateStatus.expired,
          onTap: () =>
              bloc.add(const PublishedRatesTabChanged(RateStatus.expired)),
        ),
      ],
    );

    final freightFilter = SizedBox(
      width: 170,
      child: ShadSelect<String>(
        placeholder: const Text('Freight mode'),
        initialValue: state.publishedRateFreightFilter?.name ?? _kAllValue,
        selectedOptionBuilder: (context, value) => Text(
          value == _kAllValue
              ? 'All modes'
              : FreightMode.values.byName(value).label,
        ),
        onChanged: (value) {
          if (value == null) return;
          bloc.add(
            PublishedRateFreightFilterChanged(
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
        initialValue: state.publishedRateServiceFilter?.name ?? _kAllValue,
        selectedOptionBuilder: (context, value) => Text(
          value == _kAllValue
              ? 'All services'
              : ServiceMode.values.byName(value).label,
        ),
        onChanged: (value) {
          if (value == null) return;
          bloc.add(
            PublishedRateServiceFilterChanged(
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
        placeholder: const Text('Search by charge code, route...'),
        decoration: ShadDecoration(
          border: ShadBorder.all(color: context.colors.borderStrong),
        ),
        leading: Padding(
          padding: const EdgeInsets.only(left: 4),
          child: Icon(
            CupertinoIcons.search,
            size: 16,
            color: context.colors.textMuted,
          ),
        ),
        onChanged: (v) => bloc.add(PublishedRateSearchChanged(v)),
      ),
    );

    final sortToggle = _SortByExpiryToggle(
      active: state.publishedRateSortByExpiry,
      onTap: () => bloc.add(const PublishedRateSortByExpiryToggled()),
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
            showStatusDialog(
              context,
              title: 'Delete failed',
              description: state.deleteRateError,
              isError: true,
            );
            bloc.add(const DeleteRateErrorDismissed());
          },
        ),
        BlocListener<RatesShellBloc, RatesShellState>(
          listenWhen: (prev, curr) =>
              curr.deleteRateSucceeded && !prev.deleteRateSucceeded,
          listener: (context, state) {
            showStatusDialog(context, title: 'Rate deleted');
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
                isMobile
                    ? Wrap(
                        crossAxisAlignment: WrapCrossAlignment.center,
                        spacing: 16,
                        runSpacing: 16,
                        children: [titleColumn, createRateButton],
                      )
                    : Row(
                        children: [
                          Expanded(child: titleColumn),
                          createRateButton,
                        ],
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
              child: state.publishedRatesLoading
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
                  : state.filteredPublishedRates.isEmpty
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
                            'No ${state.publishedRatesTab.label.toLowerCase()} published rates.',
                            style: TextStyle(
                              fontSize: 14,
                              color: context.colors.textMuted,
                            ),
                          ),
                        ],
                      ),
                    )
                  : _PublishedRatesTable(
                      rates: state.pagedPublishedRates,
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
          if (!state.publishedRatesLoading &&
              state.filteredPublishedRates.isNotEmpty)
            PaginationBar(
              page: state.publishedRatePage,
              itemsPerPage: RatesShellState.publishedRatesPerPage,
              totalItems: state.filteredPublishedRates.length,
              onPageChanged: (p) => bloc.add(PublishedRatePageChanged(p)),
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

class _PublishedRatesTable extends StatelessWidget {
  const _PublishedRatesTable({
    required this.rates,
    required this.deletingRateId,
    required this.onEdit,
    required this.onDelete,
  });

  final List<PublishedRate> rates;
  final String? deletingRateId;
  final ValueChanged<PublishedRate> onEdit;
  final ValueChanged<PublishedRate> onDelete;

  static const _headerStyle = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.4,
  );

  // Mobile column widths — CHARGE CODE stays pinned in a fixed left pane,
  // ROUTE/MODE/SERVICE/STATUS/actions scroll horizontally together.
  static const _chargeCodeWidth = 130.0;
  static const _routeWidth = 150.0;
  static const _modeWidth = 90.0;
  static const _serviceWidth = 90.0;
  static const _statusWidth = 130.0;
  static const _actionsWidth = 92.0;
  static const _colGap = 12.0;
  static const _headerHeight = 40.0;
  static const _rowHeight = 64.0;
  // +24 accounts for the scrollable pane's own 12px symmetric padding
  // (left+right) around the header/row content — without it the last
  // column (actions) clips against the pane's right edge.
  static const _scrollableWidth = _routeWidth +
      _modeWidth +
      _serviceWidth +
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
                flex: 3,
                child: Text(
                  'ROUTE',
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
          _PublishedRateRow(
            rate: rate,
            deleting: deletingRateId == rate.id,
            onTap: () => onEdit(rate),
            onDelete: () => onDelete(rate),
          ),
      ],
    );
  }

  Widget _buildMobile(BuildContext context) {
    Widget headerCell(String text, double width) => SizedBox(
          width: width,
          child: Text(
            text,
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
                      headerCell('ROUTE', _routeWidth),
                      const SizedBox(width: _colGap),
                      headerCell('MODE', _modeWidth),
                      const SizedBox(width: _colGap),
                      headerCell('SERVICE', _serviceWidth),
                      const SizedBox(width: _colGap),
                      headerCell('STATUS', _statusWidth),
                      const SizedBox(width: _colGap),
                      SizedBox(width: _actionsWidth),
                    ],
                  ),
                ),
                for (final rate in rates)
                  _PublishedRateRow(
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

class _PublishedRateRow extends StatelessWidget {
  const _PublishedRateRow({
    required this.rate,
    required this.deleting,
    required this.onTap,
    required this.onDelete,
    this.compact = false,
  });

  final PublishedRate rate;
  final bool deleting;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  /// Renders without the CHARGE CODE column (pinned separately in mobile's
  /// fixed left pane) and with fixed-width columns matching
  /// `_PublishedRatesTable._buildMobile`'s header, instead of flex columns.
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
          height: _PublishedRatesTable._rowHeight,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            border: Border(top: BorderSide(color: context.colors.border)),
          ),
          child: Row(
            children: [
              SizedBox(
                width: _PublishedRatesTable._routeWidth,
                child: Text(
                  rate.routeLabel,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 13,
                    color: context.colors.textMutedStrong,
                  ),
                ),
              ),
              const SizedBox(width: _PublishedRatesTable._colGap),
              SizedBox(
                width: _PublishedRatesTable._modeWidth,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: _modeBadge(context),
                ),
              ),
              const SizedBox(width: _PublishedRatesTable._colGap),
              SizedBox(
                width: _PublishedRatesTable._serviceWidth,
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
              const SizedBox(width: _PublishedRatesTable._colGap),
              SizedBox(
                width: _PublishedRatesTable._statusWidth,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: _statusBadge(context, isActive),
                ),
              ),
              const SizedBox(width: _PublishedRatesTable._colGap),
              _actions(context, width: _PublishedRatesTable._actionsWidth),
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
              flex: 3,
              child: Text(
                rate.routeLabel,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 12,
                  color: context.colors.textMutedStrong,
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
