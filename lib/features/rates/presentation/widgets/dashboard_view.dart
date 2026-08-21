import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../../../core/utils/breakpoints.dart';
import '../../../../core/widgets/shine_sweep.dart';
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
    final isMobile = Breakpoints.isMobile(context);

    if (state.isLoading) {
      return const _DashboardSkeleton();
    }

    return Column(
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(isMobile ? 20 : 64, 48, isMobile ? 20 : 64, 40),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Dashboard',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.2,
                        color: context.colors.textBody,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Overview of your active rates and clients',
                      style: TextStyle(
                        fontSize: 14,
                        color: context.colors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
              ShadButton(
                backgroundColor: context.colors.primary,
                hoverBackgroundColor: context.colors.primaryHover,
                leading: const Icon(
                  CupertinoIcons.add,
                  size: 17,
                  color: Colors.white,
                ),
                onPressed: () => context.read<RatesShellBloc>().add(
                  const NewRateModalOpened(),
                ),
                child: const Text('Create new rate'),
              ),
            ],
          ),
        ),
        Expanded(
          child: CustomScrollView(
            slivers: [
              SliverPadding(
                padding: EdgeInsets.fromLTRB(isMobile ? 20 : 64, 0, isMobile ? 20 : 64, 56),
                sliver: SliverFillRemaining(
                  hasScrollBody: false,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      isMobile
                          ? Wrap(
                              spacing: 20,
                              runSpacing: 20,
                              children: [
                                for (final stat in state.stats)
                                  SizedBox(
                                    width: (MediaQuery.sizeOf(context).width - 16 * 2 - 20) / 2,
                                    child: _StatCard(stat: stat),
                                  ),
                              ],
                            )
                          : Row(
                              children: [
                                for (final stat in state.stats) ...[
                                  Expanded(child: _StatCard(stat: stat)),
                                  if (stat != state.stats.last)
                                    const SizedBox(width: 20),
                                ],
                              ],
                            ),
                      const SizedBox(height: 40),
                      Text(
                        'Recent rates',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.2,
                          color: context.colors.textBody,
                        ),
                      ),
                      const SizedBox(height: 14),
                      Expanded(
                        child: SoftCard(
                          padding: EdgeInsets.zero,
                          borderRadius: 10,
                          blurRadius: 20,
                          shadowOffset: const Offset(0, 8),
                          width: double.infinity,
                          child: _RecentRatesTable(rates: state.recentRates),
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
    final isMobile = Breakpoints.isMobile(context);
    return SkeletonShimmer(
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(isMobile ? 20 : 64, 48, isMobile ? 20 : 64, 40),
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
              padding: EdgeInsets.fromLTRB(isMobile ? 20 : 64, 0, isMobile ? 20 : 64, 56),
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
                          padding: EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 22,
                          ),
                          child: SkeletonBox(width: 120, height: 16),
                        ),
                        Divider(height: 1, color: context.colors.border),
                        for (var i = 0; i < 6; i++) ...[
                          const Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 18,
                            ),
                            child: TableRowSkeleton(),
                          ),
                          if (i != 5)
                            Divider(height: 1, color: context.colors.border),
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

IconData _statIcon(String label) {
  final l = label.toLowerCase();
  if (l.contains('active')) return CupertinoIcons.bolt_fill;
  if (l.contains('rate')) return CupertinoIcons.tag_fill;
  if (l.contains('client')) return CupertinoIcons.person_2_fill;
  if (l.contains('route')) return CupertinoIcons.location_solid;
  return CupertinoIcons.chart_bar_alt_fill;
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.stat});

  final RateStat stat;

  @override
  Widget build(BuildContext context) {
    final isPositive = stat.delta.trim().startsWith('+');

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: context.colors.surface,
        border: Border.all(color: context.colors.border),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: context.colors.shadowSoft,
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          Positioned(
            top: 0,
            bottom: 0,
            right: -50,
            child: Center(
              child: ClipOval(
                child: ShineSweep(
                  child: Container(
                    width: 160,
                    height: 160,
                    alignment: Alignment.center,
                    color: context.colors.primary.withValues(alpha: 0.14),
                    child: Icon(
                      _statIcon(stat.label),
                      size: 60,
                      color: context.colors.primary.withValues(alpha: 0.45),
                    ),
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  stat.label,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: context.colors.textMuted,
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  stat.value,
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.4,
                    color: context.colors.textBody,
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: isPositive
                        ? context.colors.successBg
                        : context.colors.surfaceSubtle,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isPositive
                            ? CupertinoIcons.arrow_up_right
                            : CupertinoIcons.arrow_down_right,
                        size: 11,
                        color: isPositive
                            ? context.colors.successText
                            : context.colors.textMuted,
                      ),
                      const SizedBox(width: 3),
                      Text(
                        stat.delta,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: isPositive
                              ? context.colors.successText
                              : context.colors.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RecentRatesTable extends StatelessWidget {
  const _RecentRatesTable({required this.rates});

  final List<RecentRate> rates;

  static const _tableMinWidth = 640.0;

  @override
  Widget build(BuildContext context) {
    final headerStyle = TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w600,
      color: context.colors.textMuted,
      letterSpacing: 0.4,
    );

    if (rates.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
        child: Center(
          child: Text(
            'No recent rates yet.',
            style: TextStyle(fontSize: 14, color: context.colors.textMuted),
          ),
        ),
      );
    }

    final table = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          color: context.colors.surfaceSubtle,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          child: Row(
            children: [
              Expanded(flex: 24, child: Text('ROUTE', style: headerStyle)),
              Expanded(flex: 16, child: Text('CLIENT', style: headerStyle)),
              Expanded(flex: 10, child: Text('TYPE', style: headerStyle)),
              Expanded(flex: 10, child: Text('RATE', textAlign: TextAlign.right, style: headerStyle)),
              Expanded(flex: 10, child: Text('STATUS', textAlign: TextAlign.right, style: headerStyle)),
            ],
          ),
        ),
        for (final rate in rates)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
            decoration: BoxDecoration(
              color: context.colors.surface,
              border: Border(top: BorderSide(color: context.colors.border)),
            ),
            child: Row(
              children: [
                Expanded(flex: 24, child: _RouteCell(route: rate.route)),
                Expanded(
                  flex: 16,
                  child: rate.client == '—'
                      ? Text('All clients', style: TextStyle(fontSize: 14, fontStyle: FontStyle.italic, color: context.colors.textFaint))
                      : Text(rate.client, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 14, color: context.colors.textMutedStrong)),
                ),
                Expanded(flex: 10, child: _typeBadge(context, rate.type)),
                Expanded(
                  flex: 10,
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: Text(rate.price, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: context.colors.textBody)),
                  ),
                ),
                Expanded(flex: 10, child: Align(alignment: Alignment.centerRight, child: _statusBadge(context, rate.status))),
              ],
            ),
          ),
      ],
    );

    if (!Breakpoints.isMobile(context)) return table;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SizedBox(width: _tableMinWidth, child: table),
    );
  }

  Widget _typeBadge(BuildContext context, RateType type) {
    final isPublished = type == RateType.published;
    return ShadBadge(
      backgroundColor: isPublished
          ? context.colors.primaryChipBg
          : context.colors.customBg,
      foregroundColor: isPublished
          ? context.colors.primaryDeep
          : context.colors.custom,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      child: Text(
        type.label,
        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
      ),
    );
  }

  Widget _statusBadge(BuildContext context, RateStatus status) {
    final isActive = status == RateStatus.active;
    return ShadBadge(
      backgroundColor: isActive
          ? context.colors.successBg
          : context.colors.surfaceMuted,
      foregroundColor: isActive
          ? context.colors.successText
          : context.colors.textMuted,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      child: Text(
        status.label,
        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
      ),
    );
  }
}

class _RouteCell extends StatelessWidget {
  const _RouteCell({required this.route});

  final String route;

  @override
  Widget build(BuildContext context) {
    final parts = route.split('→').map((p) => p.trim()).toList();
    if (parts.length != 2) {
      return Text(
        route,
        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: context.colors.textBody),
      );
    }
    final textStyle = TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: context.colors.textBody);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Flexible(child: Text(parts[0], overflow: TextOverflow.ellipsis, style: textStyle)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Icon(CupertinoIcons.arrow_right, size: 13, color: context.colors.textFaint),
        ),
        Flexible(child: Text(parts[1], overflow: TextOverflow.ellipsis, style: textStyle)),
      ],
    );
  }
}
