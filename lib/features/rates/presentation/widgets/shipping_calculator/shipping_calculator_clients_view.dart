import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../../../../core/widgets/pagination_bar.dart';
import '../../../../../core/widgets/shine_sweep.dart';
import '../../../../../core/widgets/skeleton_box.dart';
import '../../../domain/entities/client.dart';
import '../../../domain/entities/rates_enums.dart';
import '../../bloc/rates_shell_bloc.dart';
import '../../rates_colors.dart';

const _clientGridColumns = 3;
const _clientGridRows = 2;
const _clientGridPadding = EdgeInsets.fromLTRB(48, 0, 48, 28);
const _clientGridDelegate = SliverGridDelegateWithFixedCrossAxisCount(
  crossAxisCount: _clientGridColumns,
  mainAxisSpacing: 20,
  crossAxisSpacing: 20,
  mainAxisExtent: 168,
);

class ShippingCalculatorClientsView extends StatelessWidget {
  const ShippingCalculatorClientsView({super.key});

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
                      'Shipping Calculator',
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700, letterSpacing: -0.2, color: context.colors.textBody),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Select a client to calculate freight rates',
                      style: TextStyle(fontSize: 14, color: context.colors.textMuted),
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
                    child: Icon(CupertinoIcons.search, size: 16, color: context.colors.textMuted),
                  ),
                  onChanged: (v) => bloc.add(ShippingCalculatorClientSearchChanged(v)),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: state.isLoading
              ? SkeletonShimmer(
                  child: GridView.builder(
                    padding: _clientGridPadding,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _clientGridColumns * _clientGridRows,
                    gridDelegate: _clientGridDelegate,
                    itemBuilder: (context, index) => const GridCardSkeleton(),
                  ),
                )
              : GridView.builder(
                  padding: _clientGridPadding,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: state.pagedCalcClients.length,
                  gridDelegate: _clientGridDelegate,
                  itemBuilder: (context, index) {
                    final client = state.pagedCalcClients[index];
                    return _CalcClientCard(
                      client: client,
                      rateCount: state.clientRateCounts[client.id] ?? 0,
                      onTap: () => bloc.add(ShippingCalculatorClientChosen(client.id)),
                    );
                  },
                ),
        ),
        if (state.filteredCalcClients.isNotEmpty)
          PaginationBar(
            page: state.calcClientPage,
            itemsPerPage: RatesShellState.clientsPerPage,
            totalItems: state.filteredCalcClients.length,
            onPageChanged: (p) => bloc.add(ShippingCalculatorClientPageChanged(p)),
          ),
      ],
    );
  }
}

class _CalcClientCard extends StatelessWidget {
  const _CalcClientCard({required this.client, required this.rateCount, required this.onTap});

  final Client client;
  final int rateCount;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isInclusive = client.vatStatus == VatStatus.inclusive;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            color: context.colors.surface,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(color: context.colors.shadowSoft, blurRadius: 28, offset: const Offset(0, 10)),
              BoxShadow(color: context.colors.shadowSoft.withValues(alpha: 0.5), blurRadius: 4, offset: const Offset(0, 1)),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
                              colors: [context.colors.primary, context.colors.primaryDeep],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                          ),
                          child: Text(
                            client.initials,
                            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Colors.white),
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
                            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: context.colors.textBody),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            client.accountNumber,
                            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: context.colors.primaryDeep, fontFamily: 'monospace'),
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
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(color: context.colors.surfaceSubtle, borderRadius: BorderRadius.circular(20)),
                        child: Text(
                          client.businessType.toUpperCase(),
                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: context.colors.textMutedStrong),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: context.colors.surfaceSubtle,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: context.colors.border),
                        ),
                        child: Text(
                          'VAT ${client.vatStatus.label}',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: isInclusive ? context.colors.success : context.colors.textMutedStrong,
                          ),
                        ),
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
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 11),
                    decoration: BoxDecoration(
                      color: context.colors.surfaceSubtle,
                      border: Border(top: BorderSide(color: context.colors.border)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: Text(
                            '$rateCount custom rate${rateCount == 1 ? '' : 's'}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: context.colors.textMutedStrong),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.calculate_outlined, size: 13, color: context.colors.primaryDeep),
                            const SizedBox(width: 4),
                            Text(
                              'Calculate',
                              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: context.colors.primaryDeep),
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
      ),
    );
  }
}
