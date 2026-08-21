import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../../../core/utils/breakpoints.dart';
import '../../../../core/widgets/animated_pressable.dart';
import '../../../../core/widgets/pagination_bar.dart';
import '../../../../core/widgets/shine_sweep.dart';
import '../../../../core/widgets/skeleton_box.dart';
import '../../domain/entities/client.dart';
import '../../domain/entities/rates_enums.dart';
import '../bloc/rates_shell_bloc.dart';
import '../rates_colors.dart';

const _clientGridRows = 3;
const _clientGridPadding = EdgeInsets.fromLTRB(64, 0, 64, 28);
const _clientGridPaddingMobile = EdgeInsets.fromLTRB(20, 0, 20, 28);

SliverGridDelegateWithFixedCrossAxisCount _clientGridDelegate(int crossAxisCount) {
  return SliverGridDelegateWithFixedCrossAxisCount(
    crossAxisCount: crossAxisCount,
    mainAxisSpacing: 28,
    crossAxisSpacing: 28,
    mainAxisExtent: 184,
  );
}

int _clientGridColumnCount(BuildContext context) {
  if (Breakpoints.isMobile(context)) return 1;
  if (Breakpoints.isDesktop(context)) return 3;
  return 2;
}

class CustomClientsView extends StatelessWidget {
  const CustomClientsView({super.key});

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<RatesShellBloc>();
    final state = context.watch<RatesShellBloc>().state;
    final isMobile = Breakpoints.isMobile(context);
    final columns = _clientGridColumnCount(context);
    final gridDelegate = _clientGridDelegate(columns);
    final gridPadding = isMobile ? _clientGridPaddingMobile : _clientGridPadding;

    final searchField = ShadInput(
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
    );

    final titleColumn = Column(
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
    );

    return Column(
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(isMobile ? 20 : 64, 48, isMobile ? 20 : 64, 40),
          child: isMobile
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    titleColumn,
                    const SizedBox(height: 16),
                    SizedBox(width: double.infinity, child: searchField),
                  ],
                )
              : Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: titleColumn),
                    SizedBox(width: 300, child: searchField),
                  ],
                ),
        ),
        Expanded(
          child: state.isLoading
              ? SkeletonShimmer(
                  child: GridView.builder(
                    padding: gridPadding,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: columns * _clientGridRows,
                    gridDelegate: gridDelegate,
                    itemBuilder: (context, index) => const GridCardSkeleton(),
                  ),
                )
              : GridView.builder(
                  padding: gridPadding,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: state.pagedClients.length,
                  gridDelegate: gridDelegate,
                  itemBuilder: (context, index) {
                    final client = state.pagedClients[index];
                    return _ClientCard(
                      client: client,
                      rateCount: state.clientRateCounts[client.id] ?? 0,
                      onTap: () => bloc.add(ClientRatesRequested(client.id)),
                    );
                  },
                ),
        ),
        if (state.filteredClients.isNotEmpty)
          PaginationBar(
            page: state.clientPage,
            itemsPerPage: RatesShellState.clientsPerPage,
            totalItems: state.filteredClients.length,
            onPageChanged: (p) => bloc.add(ClientPageChanged(p)),
          ),
      ],
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

    return AnimatedPressable(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: context.colors.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: context.colors.shadowSoft,
              blurRadius: 28,
              offset: const Offset(0, 10),
            ),
            BoxShadow(
              color: context.colors.shadowSoft.withValues(alpha: 0.5),
              blurRadius: 4,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Accent stripe — quick-glance identity marker.
              Container(
                height: 4,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      context.colors.primary,
                      context.colors.primaryDeep,
                    ],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 16, 18, 12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipOval(
                      child: ShineSweep(
                        child: Container(
                          width: 42,
                          height: 42,
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
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 7,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: context.colors.surfaceSubtle,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              client.accountNumber,
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: context.colors.textMutedStrong,
                                fontFamily: 'monospace',
                              ),
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
                  padding: const EdgeInsets.fromLTRB(18, 0, 18, 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            CupertinoIcons.mail_solid,
                            size: 12,
                            color: context.colors.textFaint,
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              client.email,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 12,
                                color: context.colors.textMuted,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              color: context.colors.surfaceSubtle,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  CupertinoIcons.briefcase_fill,
                                  size: 11,
                                  color: context.colors.textMutedStrong,
                                ),
                                const SizedBox(width: 5),
                                Text(
                                  client.businessType,
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: context.colors.textMutedStrong,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              color: context.colors.surfaceSubtle,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  CupertinoIcons.doc_text_fill,
                                  size: 11,
                                  color: isInclusive
                                      ? context.colors.success
                                      : context.colors.textMutedStrong,
                                ),
                                const SizedBox(width: 5),
                                Text(
                                  'VAT ${client.vatStatus.label}',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: isInclusive
                                        ? context.colors.success
                                        : context.colors.textMutedStrong,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: onTap,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 11,
                    ),
                    decoration: BoxDecoration(
                      color: context.colors.surfaceSubtle,
                      border: Border(
                        top: BorderSide(color: context.colors.border),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(
                              CupertinoIcons.tag_fill,
                              size: 12,
                              color: context.colors.textMuted,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              '$rateCount custom rate${rateCount == 1 ? '' : 's'}',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: context.colors.textMutedStrong,
                              ),
                            ),
                          ],
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
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
                ),
              ),
            ],
          ),
        ),
    );
  }
}
