import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../../../core/utils/breakpoints.dart';
import '../../../../core/widgets/mr_ratrix.dart';
import '../../../../core/widgets/pagination_bar.dart';
import '../../domain/entities/published_rate.dart';
import '../../domain/entities/rates_enums.dart';
import '../bloc/rates_shell_bloc.dart';
import '../rates_colors.dart';
import 'delete_rate_dialog.dart';
import 'published_rates_view_mobile.dart';
import 'published_rates_view_web.dart';
import 'rate_table.dart';
import 'status_toast.dart';

const _kAllValue = '__all__';

/// Pre-built, bloc-wired pieces shared by [PublishedRatesPageWeb] and
/// [PublishedRatesPageMobile] — they differ only in how these are arranged,
/// not in what they are, so [PublishedRatesView] builds each one exactly
/// once and hands the same instances to whichever layout wins.
typedef RateListHeaderParts = ({
  Widget titleColumn,
  Widget createRateButton,
  Widget tabsRow,
  Widget freightFilter,
  Widget serviceFilter,
  Widget searchField,
  Widget sortToggle,
});

class PublishedRatesView extends StatelessWidget {
  const PublishedRatesView({super.key});

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<RatesShellBloc>();
    final state = context.watch<RatesShellBloc>().state;

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
        RateTabPill(
          label: 'Active',
          selected: state.publishedRatesTab == RateStatus.active,
          onTap: () =>
              bloc.add(const PublishedRatesTabChanged(RateStatus.active)),
        ),
        const SizedBox(width: 8),
        RateTabPill(
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

    final sortToggle = RateSortByExpiryToggle(
      active: state.publishedRateSortByExpiry,
      onTap: () => bloc.add(const PublishedRateSortByExpiryToggled()),
    );

    final parts = (
      titleColumn: titleColumn,
      createRateButton: createRateButton,
      tabsRow: tabsRow,
      freightFilter: freightFilter,
      serviceFilter: serviceFilter,
      searchField: searchField,
      sortToggle: sortToggle,
    );

    final body = RateTableFitReporter(
      currentPerPage: state.publishedRatesPerPage,
      onFit: (fit) => bloc.add(PublishedRatesPerPageChanged(fit)),
      builder: (context, availableHeight, fit) =>
        state.publishedRatesLoading
        ? buildFittedRateSkeleton(availableHeight)
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
                  style: TextStyle(fontSize: 14, color: context.colors.textMuted),
                ),
              ],
            ),
          )
        : ResponsiveRateTable<PublishedRate>(
            rates: state.pagedPublishedRates,
            columns: const [
              RateTableColumn(label: 'ROUTE', flex: 3, width: 150),
              RateTableColumn(label: 'MODE', flex: 2, width: 90),
              RateTableColumn(label: 'SERVICE', flex: 2, width: 90),
              RateTableColumn(label: 'STATUS', flex: 3, width: 130),
            ],
            cellBuilders: [
              (context, rate, {required compact}) => Text(
                rate.routeLabel,
                maxLines: compact ? 2 : 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: compact ? 13 : 12,
                  color: context.colors.textMutedStrong,
                ),
              ),
              (context, rate, {required compact}) => Align(
                alignment: Alignment.centerLeft,
                child: rateModeBadge(context, rate.freightMode),
              ),
              (context, rate, {required compact}) => Text(
                rate.serviceMode.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: compact ? 13 : 12,
                  color: context.colors.textMutedStrong,
                ),
              ),
              (context, rate, {required compact}) => Align(
                alignment: Alignment.centerLeft,
                child: rateStatusBadge(
                  context,
                  isActive: rate.status == RateStatus.active,
                  label: rate.expiryLabel,
                ),
              ),
            ],
            chargeCodeOf: (rate) => rate.chargeCode,
            idOf: (rate) => rate.id,
            deletingRateId: state.deletingRateId,
            onEdit: (rate) => bloc.add(EditRateRequested(rate.id)),
            onDelete: (rate) async {
              final confirmed = await showShadDialog<bool>(
                context: context,
                builder: (_) => DeleteRateDialog(chargeCode: rate.chargeCode),
              );
              if (confirmed == true) bloc.add(DeleteRateRequested(rate.id));
            },
          ),
    );

    // Reserved even while loading (just invisible) so the table's measured
    // height doesn't shrink the moment loading finishes and the bar turns
    // visible — that shrink would otherwise overflow the row count already
    // fit against the taller loading-time space.
    final paginationBar = state.publishedRatesLoading || state.filteredPublishedRates.isNotEmpty
        ? Opacity(
            opacity: state.publishedRatesLoading ? 0 : 1,
            child: IgnorePointer(
              ignoring: state.publishedRatesLoading,
              child: PaginationBar(
                page: state.publishedRatePage,
                itemsPerPage: state.publishedRatesPerPage,
                totalItems: state.filteredPublishedRates.length,
                onPageChanged: (p) => bloc.add(PublishedRatePageChanged(p)),
              ),
            ),
          )
        : null;

    return MultiBlocListener(
      listeners: [
        BlocListener<RatesShellBloc, RatesShellState>(
          listenWhen: (prev, curr) =>
              curr.deleteRateError != null &&
              prev.deleteRateError != curr.deleteRateError,
          listener: (context, state) {
            showStatusToast(
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
            showStatusToast(context, title: 'Rate deleted');
            bloc.add(const DeleteRateSuccessDismissed());
          },
        ),
      ],
      child: Breakpoints.isMobile(context)
          ? PublishedRatesPageMobile(
              parts: parts,
              body: body,
              paginationBar: paginationBar,
            )
          : PublishedRatesPageWeb(
              parts: parts,
              body: body,
              paginationBar: paginationBar,
            ),
    );
  }
}
