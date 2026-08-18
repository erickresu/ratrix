import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../../../core/widgets/shine_sweep.dart';
import '../../../../core/widgets/skeleton_box.dart';
import '../../domain/entities/client.dart';
import '../../domain/entities/rates_enums.dart';
import '../bloc/rates_shell_bloc.dart';
import '../rates_colors.dart';

class CustomClientsView extends StatelessWidget {
  const CustomClientsView({super.key});

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<RatesShellBloc>();
    final state = context.watch<RatesShellBloc>().state;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(48, 40, 48, 32),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Custom Rate Clients',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.2,
                        color: context.colors.textBody,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Pick a client to view or set up their negotiated rates',
                      style: TextStyle(
                        fontSize: 14,
                        color: context.colors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                width: 300,
                child: ShadInput(
                  placeholder: const Text('Search clients...'),
                  leading: Padding(
                    padding: const EdgeInsets.only(left: 4),
                    child: Icon(
                      CupertinoIcons.search,
                      size: 16,
                      color: context.colors.textMuted,
                    ),
                  ),
                  onChanged: (v) => bloc.add(ClientSearchChanged(v)),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final columns = (constraints.maxWidth / 320).floor().clamp(
                1,
                100,
              );
              final pageClients = state.pagedClients;
              if (state.isLoading) {
                return SkeletonShimmer(
                  child: GridView.builder(
                    padding: const EdgeInsets.fromLTRB(48, 0, 48, 48),
                    itemCount: columns * 2,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: columns,
                      mainAxisSpacing: 20,
                      crossAxisSpacing: 20,
                      mainAxisExtent: 232,
                    ),
                    itemBuilder: (context, index) => const GridCardSkeleton(),
                  ),
                );
              }
              return GridView.builder(
                padding: const EdgeInsets.fromLTRB(48, 0, 48, 48),
                itemCount: pageClients.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: columns,
                  mainAxisSpacing: 20,
                  crossAxisSpacing: 20,
                  mainAxisExtent: 232,
                ),
                itemBuilder: (context, index) {
                  final client = pageClients[index];
                  return _ClientCard(
                    client: client,
                    rateCount: state.clientRateCounts[client.id] ?? 0,
                    onTap: () => bloc.add(ClientRatesRequested(client.id)),
                  );
                },
              );
            },
          ),
        ),
        if (state.filteredClients.isNotEmpty)
          _ClientsPaginationBar(
            page: state.clientPage,
            pageCount: state.clientPageCount,
            totalClients: state.filteredClients.length,
            onPageChanged: (p) => bloc.add(ClientPageChanged(p)),
          ),
      ],
    );
  }
}

class _ClientsPaginationBar extends StatelessWidget {
  const _ClientsPaginationBar({
    required this.page,
    required this.pageCount,
    required this.totalClients,
    required this.onPageChanged,
  });

  final int page;
  final int pageCount;
  final int totalClients;
  final ValueChanged<int> onPageChanged;

  @override
  Widget build(BuildContext context) {
    final rangeStart = page * RatesShellState.clientsPerPage + 1;
    final rangeEnd = ((page + 1) * RatesShellState.clientsPerPage).clamp(
      0,
      totalClients,
    );

    return Container(
      padding: const EdgeInsets.fromLTRB(40, 12, 40, 20),
      decoration: BoxDecoration(
        color: context.colors.surface,
        border: Border(top: BorderSide(color: context.colors.border)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Showing $rangeStart–$rangeEnd of $totalClients',
            style: TextStyle(fontSize: 13, color: context.colors.textMuted),
          ),
          Row(
            children: [
              _PageButton(
                icon: CupertinoIcons.chevron_left,
                enabled: page > 0,
                onTap: () => onPageChanged(page - 1),
              ),
              const SizedBox(width: 8),
              Text(
                'Page ${page + 1} of $pageCount',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: context.colors.textBody,
                ),
              ),
              const SizedBox(width: 8),
              _PageButton(
                icon: CupertinoIcons.chevron_right,
                enabled: page < pageCount - 1,
                onTap: () => onPageChanged(page + 1),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PageButton extends StatelessWidget {
  const _PageButton({
    required this.icon,
    required this.enabled,
    required this.onTap,
  });

  final IconData icon;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: enabled ? onTap : null,
        child: Container(
          width: 32,
          height: 32,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            border: Border.all(color: context.colors.borderStrong),
            borderRadius: BorderRadius.circular(8),
            color: context.colors.surface,
          ),
          child: Icon(
            icon,
            size: 16,
            color: enabled ? context.colors.textBody : context.colors.textFaint,
          ),
        ),
      ),
    );
  }
}

class _ClientCard extends StatelessWidget {
  const _ClientCard({
    required this.client,
    required this.rateCount,
    required this.onTap,
  });

  final Client client;
  final int rateCount;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isInclusive = client.vatStatus == VatStatus.inclusive;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            color: context.colors.surface,
            border: Border.all(color: context.colors.border),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: context.colors.shadowSoft,
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 20,
                ),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: context.colors.surfaceMuted),
                  ),
                ),
                child: Row(
                  children: [
                    ClipOval(
                      child: ShineSweep(
                        child: Container(
                          width: 44,
                          height: 44,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                context.colors.primary,
                                context.colors.primaryDeep,
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                          ),
                          child: Text(
                            client.initials,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            client.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: context.colors.textBody,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            client.accountNumber,
                            style: TextStyle(
                              fontSize: 12,
                              color: context.colors.primary,
                              fontFamily: 'monospace',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 16,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '✉ ${client.email}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 13,
                          color: context.colors.textMuted,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          ShadBadge(
                            backgroundColor: context.colors.successBg
                                .withValues(alpha: 0.6),
                            foregroundColor: context.colors.primaryDeep,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            child: Text(
                              client.businessType.toUpperCase(),
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.3,
                              ),
                            ),
                          ),
                          ShadBadge(
                            backgroundColor: isInclusive
                                ? context.colors.primarySoftBg
                                : context.colors.surface,
                            foregroundColor: isInclusive
                                ? context.colors.primaryDeep
                                : context.colors.textMutedStrong,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            shape: isInclusive
                                ? null
                                : RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(6),
                                    side: BorderSide(
                                      color: context.colors.borderStrong,
                                    ),
                                  ),
                            child: Text(
                              'VAT ${client.vatStatus.label}',
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
                color: context.colors.surfaceSubtle,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '$rateCount custom rate(s)',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: context.colors.textMutedStrong,
                      ),
                    ),
                    Row(
                      children: [
                        Text(
                          'View rates',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: context.colors.primaryDeep,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(
                          CupertinoIcons.arrow_right,
                          size: 13,
                          color: context.colors.primaryDeep,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
