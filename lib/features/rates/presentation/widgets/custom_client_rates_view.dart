import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ratrix/core/widgets/shine_sweep.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import '../../../../core/utils/breakpoints.dart';
import '../../../../core/widgets/pagination_bar.dart';
import '../../../../core/widgets/skeleton_box.dart';
import '../../domain/entities/client_rate.dart';
import '../../domain/entities/rates_enums.dart';
import '../bloc/rates_shell_bloc.dart';
import '../rates_colors.dart';
import 'back_pill.dart';

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
      leading: const Icon(
        CupertinoIcons.add,
        size: 17,
        color: Colors.white,
      ),
      onPressed: () => bloc.add(
        const CreateCustomRateForSelectedClientRequested(),
      ),
      child: const Text('Create New Rate'),
    );

    final tabsRow = Row(
      children: [
        _TabPill(
          label: 'Active',
          selected: state.clientRatesTab == RateStatus.active,
          onTap: () => bloc.add(
            const ClientRatesTabChanged(RateStatus.active),
          ),
        ),
        const SizedBox(width: 8),
        _TabPill(
          label: 'Expired',
          selected: state.clientRatesTab == RateStatus.expired,
          onTap: () => bloc.add(
            const ClientRatesTabChanged(RateStatus.expired),
          ),
        ),
      ],
    );

    final freightFilter = SizedBox(
      width: 170,
      child: ShadSelect<String>(
        placeholder: const Text('Freight mode'),
        initialValue: state.clientRateFreightFilter?.name ?? _kAllValue,
        selectedOptionBuilder: (context, value) =>
            Text(value == _kAllValue ? 'All modes' : FreightMode.values.byName(value).label),
        onChanged: (value) {
          if (value == null) return;
          bloc.add(ClientRateFreightFilterChanged(value == _kAllValue ? null : FreightMode.values.byName(value)));
        },
        options: [
          const ShadOption(value: _kAllValue, child: Text('All modes')),
          for (final m in FreightMode.values) ShadOption(value: m.name, child: Text(m.label)),
        ],
      ),
    );

    final serviceFilter = SizedBox(
      width: 170,
      child: ShadSelect<String>(
        placeholder: const Text('Service mode'),
        initialValue: state.clientRateServiceFilter?.name ?? _kAllValue,
        selectedOptionBuilder: (context, value) =>
            Text(value == _kAllValue ? 'All services' : ServiceMode.values.byName(value).label),
        onChanged: (value) {
          if (value == null) return;
          bloc.add(ClientRateServiceFilterChanged(value == _kAllValue ? null : ServiceMode.values.byName(value)));
        },
        options: [
          const ShadOption(value: _kAllValue, child: Text('All services')),
          for (final m in ServiceMode.values) ShadOption(value: m.name, child: Text(m.label)),
        ],
      ),
    );

    final searchField = SizedBox(
      width: 260,
      child: ShadInput(
        placeholder: const Text(
          'Search by charge code, freight mode...',
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

    return Column(
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(isMobile ? 20 : 64, 48, isMobile ? 20 : 64, 40),
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
              if (isMobile) ...[
                tabsRow,
                const SizedBox(height: 16),
              ],
              filtersControlsRow,
            ],
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(isMobile ? 20 : 64, 0, isMobile ? 20 : 64, 56),
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
                        Icon(
                          CupertinoIcons.tray,
                          size: 26,
                          color: context.colors.textFaint,
                        ),
                        const SizedBox(height: 12),
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
                : Column(
                    children: [
                      for (final rate in state.pagedClientRates) ...[
                        _ClientRateCard(
                          rate: rate,
                          onTap: () => bloc.add(EditRateRequested(rate.id)),
                        ),
                        const SizedBox(height: 16),
                      ],
                    ],
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
                color: active ? context.colors.primary : context.colors.borderStrong,
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

class _ClientRateCard extends StatelessWidget {
  const _ClientRateCard({required this.rate, required this.onTap});

  final ClientRate rate;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isActive = rate.status == RateStatus.active;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
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
          child: Row(
            children: [
              ShadBadge(
                backgroundColor: context.colors.successBg.withValues(alpha: 0.6),
                foregroundColor: context.colors.primaryDeep,
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
                child: Text(
                  rate.freightMode.label,
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      rate.chargeCode,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        fontFamily: 'monospace',
                        color: context.colors.textBody,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${rate.serviceMode.label} · ${rate.routeCount} route(s)',
                      style: TextStyle(
                        fontSize: 12,
                        color: context.colors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
              ShadBadge(
                backgroundColor: isActive
                    ? context.colors.successBg
                    : context.colors.surfaceMuted,
                foregroundColor: isActive
                    ? context.colors.successText
                    : context.colors.textMuted,
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                child: Text(
                  rate.expiryLabel,
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
