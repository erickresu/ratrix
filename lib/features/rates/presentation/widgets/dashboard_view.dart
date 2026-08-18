import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../../../core/widgets/skeleton_box.dart';
import '../../../../core/widgets/soft_card.dart';
import '../../domain/entities/rate_stat.dart';
import '../../domain/entities/rates_enums.dart';
import '../../domain/entities/recent_rate.dart';
import '../bloc/rates_shell_bloc.dart';
import '../rates_colors.dart';

class DashboardView extends StatelessWidget {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<RatesShellBloc>().state;

    if (state.isLoading) {
      return const _DashboardSkeleton();
    }

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
                    Text('Dashboard', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700, letterSpacing: -0.2, color: context.colors.textBody)),
                    const SizedBox(height: 4),
                    Text('Overview of your active rates and clients', style: TextStyle(fontSize: 14, color: context.colors.textMuted)),
                  ],
                ),
              ),
              ShadButton(
                backgroundColor: context.colors.primary,
                hoverBackgroundColor: context.colors.primaryHover,
                leading: const Icon(CupertinoIcons.add, size: 17, color: Colors.white),
                onPressed: () => context.read<RatesShellBloc>().add(const NewRateModalOpened()),
                child: const Text('Create new rate'),
              ),
            ],
          ),
        ),
        Expanded(
          child: CustomScrollView(
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(48, 0, 48, 48),
                sliver: SliverFillRemaining(
                  hasScrollBody: false,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          for (final stat in state.stats) ...[
                            Expanded(child: _StatCard(stat: stat)),
                            if (stat != state.stats.last) const SizedBox(width: 20),
                          ],
                        ],
                      ),
                      const SizedBox(height: 40),
                      Expanded(
                        child: SoftCard(
                          padding: EdgeInsets.zero,
                          borderRadius: 10,
                          blurRadius: 2,
                          width: double.infinity,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 22),
                                child: Text('Recent rates', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: context.colors.textBody)),
                              ),
                              Divider(height: 1, color: context.colors.border),
                              _RecentRatesTable(rates: state.recentRates),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _DashboardSkeleton extends StatelessWidget {
  const _DashboardSkeleton();

  @override
  Widget build(BuildContext context) {
    return SkeletonShimmer(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(48, 40, 48, 32),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SkeletonBox(width: 160, height: 26),
                      SizedBox(height: 10),
                      SkeletonBox(width: 260, height: 15),
                    ],
                  ),
                ),
                const SkeletonBox(width: 150, height: 40, borderRadius: 8),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(48, 0, 48, 48),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      for (var i = 0; i < 3; i++) ...[
                        const Expanded(child: StatCardSkeleton()),
                        if (i != 2) const SizedBox(width: 20),
                      ],
                    ],
                  ),
                  const SizedBox(height: 40),
                  Container(
                    decoration: BoxDecoration(
                      color: context.colors.surface,
                      border: Border.all(color: context.colors.border),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 24, vertical: 22),
                          child: SkeletonBox(width: 120, height: 16),
                        ),
                        Divider(height: 1, color: context.colors.border),
                        for (var i = 0; i < 6; i++) ...[
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 24, vertical: 18),
                            child: TableRowSkeleton(),
                          ),
                          if (i != 5) Divider(height: 1, color: context.colors.border),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.stat});

  final RateStat stat;

  @override
  Widget build(BuildContext context) {
    return SoftCard(
      padding: const EdgeInsets.all(24),
      borderRadius: 10,
      blurRadius: 2,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(stat.label, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: context.colors.textMuted)),
          const SizedBox(height: 10),
          Text(stat.value, style: TextStyle(fontSize: 32, fontWeight: FontWeight.w700, letterSpacing: -0.4, color: context.colors.textBody)),
          const SizedBox(height: 8),
          Text(stat.delta, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: context.colors.success)),
        ],
      ),
    );
  }
}

class _RecentRatesTable extends StatelessWidget {
  const _RecentRatesTable({required this.rates});

  final List<RecentRate> rates;

  @override
  Widget build(BuildContext context) {
    final headerStyle = TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: context.colors.textMuted, letterSpacing: 0.4);

    return Table(
      columnWidths: const {
        0: FlexColumnWidth(2.2),
        1: FlexColumnWidth(1.6),
        2: FlexColumnWidth(1.2),
        3: FlexColumnWidth(1.2),
        4: FlexColumnWidth(1.2),
      },
      children: [
        TableRow(
          decoration: BoxDecoration(color: context.colors.surfaceSubtle),
          children: [
            _Cell(padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14), child: Text('ROUTE', style: headerStyle)),
            _Cell(padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14), child: Text('CLIENT', style: headerStyle)),
            _Cell(padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14), child: Text('TYPE', style: headerStyle)),
            _Cell(padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14), alignment: Alignment.centerRight, child: Text('RATE', style: headerStyle)),
            _Cell(padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14), child: Text('STATUS', style: headerStyle)),
          ],
        ),
        for (final rate in rates)
          TableRow(
            decoration: BoxDecoration(border: Border(top: BorderSide(color: context.colors.border))),
            children: [
              _Cell(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
                child: Text(rate.route, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: context.colors.textBody)),
              ),
              _Cell(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
                child: Text(rate.client, style: TextStyle(fontSize: 14, color: context.colors.textMutedStrong)),
              ),
              _Cell(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
                child: _typeBadge(context, rate.type),
              ),
              _Cell(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
                alignment: Alignment.centerRight,
                child: Text(rate.price, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: context.colors.textBody)),
              ),
              _Cell(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
                child: _statusBadge(context, rate.status),
              ),
            ],
          ),
      ],
    );
  }

  Widget _typeBadge(BuildContext context, RateType type) {
    final isPublished = type == RateType.published;
    return ShadBadge(
      backgroundColor: isPublished ? context.colors.primaryChipBg : context.colors.customBg,
      foregroundColor: isPublished ? context.colors.primaryDeep : context.colors.custom,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      child: Text(type.label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
    );
  }

  Widget _statusBadge(BuildContext context, RateStatus status) {
    final isActive = status == RateStatus.active;
    return ShadBadge(
      backgroundColor: isActive ? context.colors.successBg : context.colors.surfaceMuted,
      foregroundColor: isActive ? context.colors.successText : context.colors.textMuted,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      child: Text(status.label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
    );
  }
}

class _Cell extends StatelessWidget {
  const _Cell({required this.child, required this.padding, this.alignment = Alignment.centerLeft});

  final Widget child;
  final EdgeInsets padding;
  final Alignment alignment;

  @override
  Widget build(BuildContext context) {
    return TableCell(
      verticalAlignment: TableCellVerticalAlignment.middle,
      child: Padding(
        padding: padding,
        child: Align(alignment: alignment, child: child),
      ),
    );
  }
}
