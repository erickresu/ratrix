import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

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
      return const Padding(
        padding: EdgeInsets.all(40),
        child: Align(alignment: Alignment.topLeft, child: CircularProgressIndicator()),
      );
    }

    return Column(
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
                    Text('Dashboard', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700, letterSpacing: -0.2, color: RatesColors.textBody)),
                    SizedBox(height: 4),
                    Text('Overview of your active rates and clients', style: TextStyle(fontSize: 14, color: RatesColors.textMuted)),
                  ],
                ),
              ),
              ShadButton(
                backgroundColor: RatesColors.primary,
                hoverBackgroundColor: RatesColors.primaryHover,
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
                              const Padding(
                                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 22),
                                child: Text('Recent rates', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: RatesColors.textBody)),
                              ),
                              const Divider(height: 1, color: RatesColors.border),
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
          Text(stat.label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: RatesColors.textMuted)),
          const SizedBox(height: 10),
          Text(stat.value, style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w700, letterSpacing: -0.4, color: RatesColors.textBody)),
          const SizedBox(height: 8),
          Text(stat.delta, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: RatesColors.success)),
        ],
      ),
    );
  }
}

class _RecentRatesTable extends StatelessWidget {
  const _RecentRatesTable({required this.rates});

  final List<RecentRate> rates;

  static const _headerStyle = TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: RatesColors.textMuted, letterSpacing: 0.4);

  @override
  Widget build(BuildContext context) {
    return Table(
      columnWidths: const {
        0: FlexColumnWidth(2.2),
        1: FlexColumnWidth(1.6),
        2: FlexColumnWidth(1.2),
        3: FlexColumnWidth(1.2),
        4: FlexColumnWidth(1.2),
      },
      children: [
        const TableRow(
          decoration: BoxDecoration(color: RatesColors.surfaceSubtle),
          children: [
            _Cell(padding: EdgeInsets.symmetric(horizontal: 24, vertical: 14), child: Text('ROUTE', style: _headerStyle)),
            _Cell(padding: EdgeInsets.symmetric(horizontal: 24, vertical: 14), child: Text('CLIENT', style: _headerStyle)),
            _Cell(padding: EdgeInsets.symmetric(horizontal: 24, vertical: 14), child: Text('TYPE', style: _headerStyle)),
            _Cell(padding: EdgeInsets.symmetric(horizontal: 24, vertical: 14), alignment: Alignment.centerRight, child: Text('RATE', style: _headerStyle)),
            _Cell(padding: EdgeInsets.symmetric(horizontal: 24, vertical: 14), child: Text('STATUS', style: _headerStyle)),
          ],
        ),
        for (final rate in rates)
          TableRow(
            decoration: const BoxDecoration(border: Border(top: BorderSide(color: RatesColors.border))),
            children: [
              _Cell(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
                child: Text(rate.route, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: RatesColors.textBody)),
              ),
              _Cell(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
                child: Text(rate.client, style: const TextStyle(fontSize: 14, color: RatesColors.textMutedStrong)),
              ),
              _Cell(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
                child: _typeBadge(rate.type),
              ),
              _Cell(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
                alignment: Alignment.centerRight,
                child: Text(rate.price, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: RatesColors.textBody)),
              ),
              _Cell(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
                child: _statusBadge(rate.status),
              ),
            ],
          ),
      ],
    );
  }

  Widget _typeBadge(RateType type) {
    final isPublished = type == RateType.published;
    return ShadBadge(
      backgroundColor: isPublished ? RatesColors.primaryChipBg : RatesColors.customBg,
      foregroundColor: isPublished ? RatesColors.primaryDeep : RatesColors.custom,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      child: Text(type.label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
    );
  }

  Widget _statusBadge(RateStatus status) {
    final isActive = status == RateStatus.active;
    return ShadBadge(
      backgroundColor: isActive ? RatesColors.successBg : RatesColors.surfaceMuted,
      foregroundColor: isActive ? RatesColors.successText : RatesColors.textMuted,
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
