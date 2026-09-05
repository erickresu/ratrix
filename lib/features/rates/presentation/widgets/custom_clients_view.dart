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
import '../bloc/rates_shell_bloc.dart';
import '../rates_colors.dart';
import 'client_picker_page.dart';

const _clientGridRows = 3;

// Matches `ShippingCalculatorClientsView`'s card sizing — its 3-row grid
// fits within the Expanded region above the pagination bar; this one's
// taller cards (184px + 28px gaps) didn't, and with scrolling disabled on
// desktop the bottom row just clipped behind the pagination bar instead.
SliverGridDelegateWithFixedCrossAxisCount _clientGridDelegate(int crossAxisCount) {
  return SliverGridDelegateWithFixedCrossAxisCount(
    crossAxisCount: crossAxisCount,
    mainAxisSpacing: 20,
    crossAxisSpacing: 20,
    mainAxisExtent: 168,
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

    final searchField = ShadInput(
      placeholder: const Text('Search clients...'),
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

    // `ShippingCalculatorClientsView` (same shared `ClientPickerPageWeb`
    // layout) disables scrolling on desktop since its grid always fits —
    // but "always fits" depends on the user's actual window height, which
    // varies. Staying scrollable everywhere costs nothing when the grid
    // already fits (there's simply nothing to scroll) and avoids clipping
    // the bottom row behind the pagination bar on a shorter window.
    const physics = AlwaysScrollableScrollPhysics();

    final body = Expanded(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final side = isMobile ? 24.0 : constraints.maxWidth * 0.15;
          final gridPadding = EdgeInsets.fromLTRB(side, 0, side, 28);
          return state.isLoading
              ? SkeletonShimmer(
                  child: GridView.builder(
                    padding: gridPadding,
                    physics: physics,
                    itemCount: columns * _clientGridRows,
                    gridDelegate: gridDelegate,
                    itemBuilder: (context, index) => const GridCardSkeleton(),
                  ),
                )
              : GridView.builder(
                  padding: gridPadding,
                  physics: physics,
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
                );
        },
      ),
    );

    final paginationBar = state.filteredClients.isNotEmpty
        ? PaginationBar(
            page: state.clientPage,
            itemsPerPage: RatesShellState.clientsPerPage,
            totalItems: state.filteredClients.length,
            onPageChanged: (p) => bloc.add(ClientPageChanged(p)),
          )
        : null;

    final parts = (titleColumn: titleColumn, searchField: searchField);

    return isMobile
        ? ClientPickerPageMobile(parts: parts, body: body, paginationBar: paginationBar)
        : ClientPickerPageWeb(parts: parts, body: body, paginationBar: paginationBar);
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
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 18, 18, 12),
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
                          Row(
                            children: [
                              Text(
                                client.accountNumber,
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: context.colors.textMuted,
                                  fontFamily: 'monospace',
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                '·',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: context.colors.textFaint,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Flexible(
                                child: Text(
                                  client.email,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: context.colors.textMuted,
                                  ),
                                ),
                              ),
                            ],
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
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          InfoPill(
                            icon: CupertinoIcons.briefcase_fill,
                            label: client.businessType,
                          ),
                          InfoPill(
                            icon: CupertinoIcons.doc_text_fill,
                            label: 'VAT ${client.vatStatus.label}',
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
                              color: context.colors.textFaint,
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
