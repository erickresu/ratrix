import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ratrix/core/widgets/shine_sweep.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import '../../../../core/utils/breakpoints.dart';
import '../../../../core/widgets/mr_ratrix.dart';
import '../../../../core/widgets/pagination_bar.dart';
import '../../domain/entities/client_rate.dart';
import '../../domain/entities/rates_enums.dart';
import '../bloc/rates_shell_bloc.dart';
import '../rates_colors.dart';
import 'back_pill.dart';
import 'custom_client_rates_view_mobile.dart';
import 'custom_client_rates_view_web.dart';
import 'delete_rate_dialog.dart';
import 'rate_table.dart';
import 'status_toast.dart';

const _kAllValue = '__all__';

/// Pre-built, bloc-wired pieces shared by [CustomClientRatesPageWeb] and
/// [CustomClientRatesPageMobile] — they differ only in how these are
/// arranged, not in what they are.
typedef ClientRateHeaderParts = ({
  Widget backPill,
  Widget avatar,
  Widget clientInfo,
  Widget createRateButton,
  Widget tabsRow,
  Widget freightFilter,
  Widget serviceFilter,
  Widget searchField,
  Widget sortToggle,
});

class CustomClientRatesView extends StatelessWidget {
  const CustomClientRatesView({super.key});

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<RatesShellBloc>();
    final state = context.watch<RatesShellBloc>().state;
    final client = state.selectedClient;
    if (client == null) return const SizedBox.shrink();

    final backPill = BackPill(onTap: () => bloc.add(const ClientsBackRequested()));

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
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: context.colors.primary,
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
        RateTabPill(
          label: 'Active',
          selected: state.clientRatesTab == RateStatus.active,
          onTap: () => bloc.add(const ClientRatesTabChanged(RateStatus.active)),
        ),
        const SizedBox(width: 8),
        RateTabPill(
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
        placeholder: const Text('Mode'),
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
        placeholder: const Text('Search by charge code, mode...'),
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
        onChanged: (v) => bloc.add(ClientRateSearchChanged(v)),
      ),
    );

    final sortToggle = RateSortByExpiryToggle(
      active: state.clientRateSortByExpiry,
      onTap: () => bloc.add(const ClientRateSortByExpiryToggled()),
    );

    final parts = (
      backPill: backPill,
      avatar: avatar,
      clientInfo: clientInfo,
      createRateButton: createRateButton,
      tabsRow: tabsRow,
      freightFilter: freightFilter,
      serviceFilter: serviceFilter,
      searchField: searchField,
      sortToggle: sortToggle,
    );

    final body = RateTableFitReporter(
      currentPerPage: state.clientRatesPerPage,
      onFit: (fit) => bloc.add(ClientRatesPerPageChanged(fit)),
      builder: (context, availableHeight, fit) =>
        state.clientRatesLoading
        ? buildFittedRateSkeleton(availableHeight)
        : state.filteredClientRates.isEmpty
        ? SizedBox(
            height: availableHeight,
            child: Container(
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
                    style: TextStyle(fontSize: 14, color: context.colors.textMuted),
                  ),
                ],
              ),
            ),
          )
        : ResponsiveRateTable<ClientRate>(
            rates: state.pagedClientRates,
            chargeCodeFlex: 50,
            actionsFlex: 15,
            columns: const [
              RateTableColumn(label: 'SERVICE', flex: 12, width: 90),
              RateTableColumn(label: 'ROUTES', flex: 12, width: 90),
              RateTableColumn(label: 'CREATED AT', flex: 13, width: 100),
              RateTableColumn(label: 'EXPIRATION', flex: 13, width: 100),
            ],
            cellBuilders: [
              (context, rate, {required compact}) => Text(
                rate.serviceMode.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: compact ? 13 : 12,
                  color: context.colors.textMutedStrong,
                ),
              ),
              (context, rate, {required compact}) => Text(
                '${rate.routeCount} route(s)',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: compact ? 13 : 12,
                  color: context.colors.textMuted,
                ),
              ),
              (context, rate, {required compact}) => Text(
                formatRateDate(rate.createdAt),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: compact ? 13 : 12,
                  color: context.colors.textMuted,
                ),
              ),
              (context, rate, {required compact}) => Text(
                formatRateDate(rate.expiryDate),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: compact ? 13 : 12,
                  color: context.colors.textMutedStrong,
                ),
              ),
            ],
            chargeCodeOf: (rate) => rate.chargeCode,
            idOf: (rate) => rate.id,
            deletingRateId: state.deletingRateId,
            onEdit: (rate) => bloc.add(EditRateRequested(rate.id)),
            onTry: (rate) => bloc.add(
              TryRateInCalculatorRequested(
                clientId: client.id,
                chargeCode: rate.chargeCode,
              ),
            ),
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
    final paginationBar = state.clientRatesLoading || state.filteredClientRates.isNotEmpty
        ? Opacity(
            opacity: state.clientRatesLoading ? 0 : 1,
            child: IgnorePointer(
              ignoring: state.clientRatesLoading,
              child: PaginationBar(
                page: state.clientRatePage,
                itemsPerPage: state.clientRatesPerPage,
                totalItems: state.filteredClientRates.length,
                onPageChanged: (p) => bloc.add(ClientRatePageChanged(p)),
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
          ? CustomClientRatesPageMobile(
              parts: parts,
              body: body,
              paginationBar: paginationBar,
            )
          : CustomClientRatesPageWeb(
              parts: parts,
              body: body,
              paginationBar: paginationBar,
            ),
    );
  }
}

