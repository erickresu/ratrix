import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../../../core/utils/breakpoints.dart';
import '../../../../core/widgets/horizontal_scroll_table.dart';
import '../../../../core/widgets/mr_ratrix.dart';
import '../../../../core/widgets/shine_sweep.dart';
import '../../../../core/widgets/skeleton_box.dart';
import '../../../../core/widgets/soft_card.dart';
import '../../domain/entities/expiring_soon_rate.dart';
import '../../domain/entities/rate_stat.dart';
import '../../domain/entities/rates_enums.dart';
import '../../domain/entities/recent_rate.dart';
import '../bloc/rates_shell_bloc.dart';
import '../rates_colors.dart';
import 'tutorial/tour_keys.dart';
import 'tutorial/tour_step_card.dart';

class DashboardView extends StatelessWidget {
  const DashboardView({super.key, required this.onReplayTour});

  final VoidCallback onReplayTour;

  @override
  Widget build(BuildContext context) {
    final state = context.watch<RatesShellBloc>().state;
    final isMobile = Breakpoints.isMobile(context);

    if (state.isLoading) {
      return const _DashboardSkeleton();
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        // Left+right whitespace is 30% of the available width, so the
        // content column stays a steady 70% regardless of window size.
        final side = isMobile ? 24.0 : constraints.maxWidth * 0.15;
        return _DashboardBody(
          state: state,
          isMobile: isMobile,
          side: side,
          onReplayTour: onReplayTour,
        );
      },
    );
  }
}

class _DashboardBody extends StatelessWidget {
  const _DashboardBody({
    required this.state,
    required this.isMobile,
    required this.side,
    required this.onReplayTour,
  });

  final RatesShellState state;
  final bool isMobile;
  final double side;
  final VoidCallback onReplayTour;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(side, 64, side, 40),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
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
                        const SizedBox(width: 8),
                        Tooltip(
                          message: 'Replay the welcome tour',
                          child: Material(
                            color: Colors.transparent,
                            shape: const CircleBorder(),
                            child: InkWell(
                              customBorder: const CircleBorder(),
                              onTap: onReplayTour,
                              child: Padding(
                                padding: const EdgeInsets.all(4),
                                child: Icon(
                                  CupertinoIcons.info_circle,
                                  size: 18,
                                  color: context.colors.textMuted,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
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
              tourShowcase(
                context: context,
                key: TourKeys.createRateButton,
                title: "Now Let's Create a Rate",
                body:
                    "You've seen the essentials — now let's put it into "
                    "practice. Tap Next and I'll walk you through building "
                    'one, live.',
                isLast: false,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: context.colors.primary.withValues(alpha: 0.35),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: ShineSweep(
                      opacity: 0.35,
                      bandWidth: 0.16,
                      child: ShadButton(
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
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverPadding(
                padding: EdgeInsets.fromLTRB(side, 0, side, 64),
                sliver: SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (!isMobile)
                        IntrinsicHeight(
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Expanded(
                                flex: 3,
                                child: _FreightModeCard(state: state),
                              ),
                              const SizedBox(width: 20),
                              Expanded(
                                flex: 2,
                                child: Column(
                                  children: [
                                    _LeadingClientsCard(state: state),
                                    const SizedBox(height: 20),
                                    Expanded(
                                      child: _ExpiringSoonCard(state: state),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        )
                      else ...[
                        _FreightModeCard(state: state),
                        const SizedBox(height: 20),
                        _LeadingClientsCard(state: state),
                        const SizedBox(height: 20),
                        _ExpiringSoonCard(state: state),
                      ],
                      const SizedBox(height: 40),
                      Row(
                        children: [
                          Text(
                            'Recent rates',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              letterSpacing: -0.2,
                              color: context.colors.textBody,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 9,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: context.colors.primaryChipBg,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              '${state.recentRates.length}',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: context.colors.primaryDeep,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      SoftCard(
                        padding: EdgeInsets.zero,
                        borderRadius: 10,
                        blurRadius: 20,
                        shadowOffset: const Offset(0, 8),
                        width: double.infinity,
                        // Capped at 5 — "recent" only ever needs a glance,
                        // not the full history (that lives in
                        // Published/Custom Rates).
                        child: _RecentRatesTable(
                          rates: state.recentRates.take(5).toList(),
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
    return LayoutBuilder(
      builder: (context, constraints) {
        final side = isMobile ? 24.0 : constraints.maxWidth * 0.15;
        return SkeletonShimmer(
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.fromLTRB(side, 48, side, 40),
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
                  padding: EdgeInsets.fromLTRB(side, 0, side, 56),
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
                                Divider(
                                  height: 1,
                                  color: context.colors.border,
                                ),
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
      },
    );
  }
}

RateStat? _statByLabel(List<RateStat> stats, String label) {
  for (final s in stats) {
    if (s.label == label) return s;
  }
  return null;
}

class _RecentRatesTable extends StatelessWidget {
  const _RecentRatesTable({required this.rates});

  final List<RecentRate> rates;

  @override
  Widget build(BuildContext context) {
    final compact = Breakpoints.isMobile(context);
    // Header row is always the fixed navy `sidebarBg`, regardless of app
    // theme (same treatment as the sidebar itself) — so its text needs a
    // fixed light color rather than a theme-aware muted token.
    final headerStyle = TextStyle(
      fontSize: compact ? 10 : 12,
      fontWeight: FontWeight.w600,
      color: Colors.white.withValues(alpha: 0.75),
      letterSpacing: 0.4,
    );

    if (rates.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const MrRatrix(size: 96),
              const SizedBox(height: 8),
              Text(
                'No recent rates yet.',
                style: TextStyle(fontSize: 14, color: context.colors.textMuted),
              ),
            ],
          ),
        ),
      );
    }

    final bodyFontSize = 12.0;
    final rowPadding = EdgeInsets.symmetric(
      horizontal: compact ? 18 : 24,
      vertical: 18,
    );
    final fieldGap = SizedBox(width: compact ? 6 : 10);
    // Wider than the standard gap — ROUTE text runs close to full width
    // and read cramped against CLIENT right after it.
    final routeClientGap = SizedBox(width: compact ? 40 : 90);
    // Client names run long ("Magna Prime Chemical Technologies
    // Incorporated") and fill most of their column, leaving the standard
    // gap looking cramped against the TYPE badge right after it.
    final clientTypeGap = SizedBox(width: compact ? 16 : 32);

    final table = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          color: context.colors.sidebarBg,
          padding: EdgeInsets.symmetric(
            horizontal: compact ? 18 : 24,
            vertical: compact ? 13 : 14,
          ),
          child: Row(
            children: [
              Expanded(flex: 35, child: Text('ROUTE', style: headerStyle)),
              routeClientGap,
              Expanded(flex: 35, child: Text('CLIENT', style: headerStyle)),
              clientTypeGap,
              Expanded(flex: 10, child: Text('TYPE', style: headerStyle)),
              fieldGap,
              Expanded(
                flex: 10,
                child: Text(
                  'RATE',
                  textAlign: TextAlign.right,
                  style: headerStyle,
                ),
              ),
              fieldGap,
              Expanded(
                flex: 10,
                child: Text(
                  'STATUS',
                  textAlign: TextAlign.right,
                  style: headerStyle,
                ),
              ),
            ],
          ),
        ),
        for (final rate in rates)
          Container(
            padding: rowPadding,
            decoration: BoxDecoration(
              color: context.colors.surface,
              border: Border(top: BorderSide(color: context.colors.border)),
            ),
            child: Row(
              children: [
                Expanded(
                  flex: 35,
                  child: _RouteCell(route: rate.route, compact: compact),
                ),
                routeClientGap,
                Expanded(
                  flex: 35,
                  child: rate.client == '—'
                      ? Text(
                          'All clients',
                          style: TextStyle(
                            fontSize: bodyFontSize,
                            fontStyle: FontStyle.italic,
                            color: context.colors.textFaint,
                          ),
                        )
                      : Text(
                          rate.client,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: bodyFontSize,
                            color: context.colors.textMutedStrong,
                          ),
                        ),
                ),
                clientTypeGap,
                Expanded(
                  flex: 10,
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: _typeBadge(context, rate.type, compact),
                  ),
                ),
                fieldGap,
                Expanded(
                  flex: 10,
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      rate.price,
                      style: TextStyle(
                        fontSize: bodyFontSize,
                        fontWeight: FontWeight.w600,
                        color: context.colors.textBody,
                      ),
                    ),
                  ),
                ),
                fieldGap,
                Expanded(
                  flex: 10,
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: _statusBadge(context, rate.status, compact),
                  ),
                ),
              ],
            ),
          ),
      ],
    );

    if (!Breakpoints.isMobile(context)) return table;

    // On mobile, CLIENT is the one column worth always seeing — pin it in
    // a fixed left pane (same fixed-pane + scrollable-pane split the rate
    // wizard's matrix table uses) and let Route/Type/Rate/Status scroll
    // horizontally together on the right, with a visible Scrollbar hinting
    // there's more.
    const clientWidth = 120.0;
    const headerHeight = 40.0;
    const rowHeight = 60.0;
    const routeWidth = 150.0;
    const typeWidth = 90.0;
    const rateWidth = 80.0;
    const statusWidth = 100.0;
    const colGap = 12.0;
    // +24 accounts for the scrollable pane's own 12px symmetric padding
    // (left+right) — without it the last column clips against the pane's
    // right edge.
    const scrollableWidth =
        routeWidth + typeWidth + rateWidth + statusWidth + colGap * 3 + 24;

    Widget headerCell(
      String text,
      double width, {
      TextAlign align = TextAlign.left,
    }) => SizedBox(
      width: width,
      child: Text(text, textAlign: align, style: headerStyle),
    );

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: clientWidth,
          child: Column(
            children: [
              Container(
                height: headerHeight,
                alignment: Alignment.centerLeft,
                padding: const EdgeInsets.only(left: 18),
                color: context.colors.sidebarBg,
                child: Text('CLIENT', style: headerStyle),
              ),
              for (final rate in rates)
                Container(
                  height: rowHeight,
                  alignment: Alignment.centerLeft,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: context.colors.surface,
                    border: Border(
                      top: BorderSide(color: context.colors.border),
                    ),
                  ),
                  child: rate.client == '—'
                      ? Text(
                          'All clients',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: bodyFontSize,
                            fontStyle: FontStyle.italic,
                            color: context.colors.textFaint,
                          ),
                        )
                      : Text(
                          rate.client,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: bodyFontSize,
                            color: context.colors.textMutedStrong,
                          ),
                        ),
                ),
            ],
          ),
        ),
        Expanded(
          child: HorizontalScrollTable(
            width: scrollableWidth,
            child: Column(
              children: [
                Container(
                  height: headerHeight,
                  alignment: Alignment.centerLeft,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  color: context.colors.sidebarBg,
                  child: Row(
                    children: [
                      headerCell('ROUTE', routeWidth),
                      const SizedBox(width: colGap),
                      headerCell('TYPE', typeWidth),
                      const SizedBox(width: colGap),
                      headerCell('RATE', rateWidth, align: TextAlign.right),
                      const SizedBox(width: colGap),
                      headerCell('STATUS', statusWidth, align: TextAlign.right),
                    ],
                  ),
                ),
                for (final rate in rates)
                  Container(
                    height: rowHeight,
                    alignment: Alignment.centerLeft,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: context.colors.surface,
                      border: Border(
                        top: BorderSide(color: context.colors.border),
                      ),
                    ),
                    child: Row(
                      children: [
                        SizedBox(
                          width: routeWidth,
                          child: _RouteCell(route: rate.route, compact: true),
                        ),
                        const SizedBox(width: colGap),
                        SizedBox(
                          width: typeWidth,
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: _typeBadge(context, rate.type, true),
                          ),
                        ),
                        const SizedBox(width: colGap),
                        SizedBox(
                          width: rateWidth,
                          child: Align(
                            alignment: Alignment.centerRight,
                            child: Text(
                              rate.price,
                              style: TextStyle(
                                fontSize: bodyFontSize,
                                fontWeight: FontWeight.w600,
                                color: context.colors.textBody,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: colGap),
                        SizedBox(
                          width: statusWidth,
                          child: Align(
                            alignment: Alignment.centerRight,
                            child: _statusBadge(context, rate.status, true),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _typeBadge(BuildContext context, RateType type, bool compact) {
    final isPublished = type == RateType.published;
    // Neutral secondary background for both variants — distinguished by
    // text color only, instead of a saturated gold/purple chip.
    final bg = context.colors.surfaceMuted;
    return ShadBadge(
      backgroundColor: bg,
      // These badges aren't interactive (no onPressed), so pin the hover
      // color to match — ShadBadge tracks hover and swaps to a theme
      // default hoverBackgroundColor regardless, making a static badge look
      // clickable/react to mouseover for no reason.
      hoverBackgroundColor: bg,
      foregroundColor: isPublished
          ? context.colors.primaryDeep
          : context.colors.custom,
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 8 : 10,
        vertical: compact ? 3 : 4,
      ),
      child: Text(
        type.label,
        style: TextStyle(
          fontSize: compact ? 10 : 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _statusBadge(BuildContext context, RateStatus status, bool compact) {
    final isActive = status == RateStatus.active;
    final fg = isActive ? context.colors.successText : context.colors.textMuted;
    final bg = isActive
        ? context.colors.successBg
        : context.colors.surfaceMuted;
    return ShadBadge(
      backgroundColor: bg,
      hoverBackgroundColor: bg,
      foregroundColor: fg,
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 8 : 10,
        vertical: compact ? 3 : 4,
      ),
      child: Text(
        status.label,
        style: TextStyle(
          fontSize: compact ? 10 : 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _RouteCell extends StatelessWidget {
  const _RouteCell({required this.route, this.compact = false});

  final String route;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    // Same size as every other cell in the row (CLIENT, TYPE, RATE,
    // STATUS all use 12) — this used to run bigger on desktop for no
    // reason, reading oversized next to the rest of the row.
    const fontSize = 12.0;
    final parts = route.split('→').map((p) => p.trim()).toList();
    if (parts.length != 2) {
      return Text(
        route,
        style: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.w500,
          color: context.colors.textBody,
        ),
      );
    }
    final textStyle = TextStyle(
      fontSize: fontSize,
      fontWeight: FontWeight.w500,
      color: context.colors.textBody,
    );
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Flexible(
          child: Text(
            parts[0],
            overflow: TextOverflow.ellipsis,
            style: textStyle,
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: compact ? 5 : 8),
          child: Icon(
            CupertinoIcons.arrow_right,
            size: compact ? 11 : 13,
            color: context.colors.textFaint,
          ),
        ),
        Flexible(
          child: Text(
            parts[1],
            overflow: TextOverflow.ellipsis,
            style: textStyle,
          ),
        ),
      ],
    );
  }
}

/// Shared white-surface card shell for the freight-mode/leading-clients/
/// expiring-soon dashboard cards — same treatment as `_StatCard`.
class _DashboardCard extends StatelessWidget {
  const _DashboardCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: context.colors.shadowCard,
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
          BoxShadow(
            color: context.colors.shadowSoft,
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: child,
    );
  }
}

Widget _cardTitle(
  BuildContext context,
  String title, {
  String? subtitle,
  Widget? trailing,
}) => Column(
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [
    Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: context.colors.textBody,
          ),
        ),
        if (trailing != null) trailing,
      ],
    ),
    if (subtitle != null) ...[
      const SizedBox(height: 2),
      Text(
        subtitle,
        style: TextStyle(fontSize: 13, color: context.colors.textMuted),
      ),
    ],
  ],
);

// Fixed display order + color per freight mode — a chart legend reads
// better in a stable order than however the API happens to list rates.
const _freightModeOrder = [FreightMode.air, FreightMode.sea, FreightMode.land];

Color _freightModeColor(BuildContext context, FreightMode mode) =>
    switch (mode) {
      FreightMode.air => const Color(0xFF3B82F6),
      FreightMode.sea => context.colors.sidebarBg,
      FreightMode.land => context.colors.success,
    };

class _FreightModeCard extends StatelessWidget {
  const _FreightModeCard({required this.state});

  final RatesShellState state;

  @override
  Widget build(BuildContext context) {
    final counts = state.freightModeCounts;
    final total = counts.values.fold(0, (a, b) => a + b);
    final activeRatesDelta =
        _statByLabel(state.stats, 'Active rates')?.delta ?? '';

    return _DashboardCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _cardTitle(
            context,
            'Rates by freight mode',
            subtitle: 'Across all active rate cards',
            trailing: activeRatesDelta.isEmpty
                ? null
                : Text(
                    activeRatesDelta,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: context.colors.successText,
                    ),
                  ),
          ),
          const SizedBox(height: 20),
          if (total == 0)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Text(
                'No active rates yet.',
                style: TextStyle(fontSize: 13, color: context.colors.textMuted),
              ),
            )
          else
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  width: 160,
                  height: 160,
                  child: CustomPaint(
                    painter: _DonutPainter(
                      segments: [
                        for (final m in _freightModeOrder)
                          if ((counts[m] ?? 0) > 0)
                            (counts[m]!, _freightModeColor(context, m)),
                      ],
                      total: total,
                    ),
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '$total',
                            style: TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.w800,
                              color: context.colors.textBody,
                            ),
                          ),
                          Text(
                            'total rates',
                            style: TextStyle(
                              fontSize: 11,
                              color: context.colors.textMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 32),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      for (final m in _freightModeOrder) ...[
                        _FreightModeLegendRow(
                          mode: m,
                          count: counts[m] ?? 0,
                          total: total,
                          color: _freightModeColor(context, m),
                        ),
                        if (m != _freightModeOrder.last) ...[
                          const SizedBox(height: 10),
                          _DashedDivider(color: context.colors.border),
                          const SizedBox(height: 10),
                        ],
                      ],
                    ],
                  ),
                ),
              ],
            ),
          const SizedBox(height: 24),
          Divider(height: 1, color: context.colors.border),
          const SizedBox(height: 20),
          _PublishedVsCustomBar(state: state),
        ],
      ),
    );
  }
}

class _DonutPainter extends CustomPainter {
  _DonutPainter({required this.segments, required this.total});

  final List<(int, Color)> segments;
  final int total;

  static const _strokeWidth = 26.0;

  @override
  void paint(Canvas canvas, Size size) {
    if (total == 0) return;
    final rect = (Offset.zero & size).deflate(_strokeWidth / 2);
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = _strokeWidth;
    var startAngle = -pi / 2;
    for (final (count, color) in segments) {
      final sweep = 2 * pi * count / total;
      paint.color = color;
      canvas.drawArc(rect, startAngle, sweep, false, paint);
      startAngle += sweep;
    }
  }

  @override
  bool shouldRepaint(covariant _DonutPainter oldDelegate) =>
      oldDelegate.segments != segments || oldDelegate.total != total;
}

/// Thin dashed rule separating each freight-mode legend row.
class _DashedDivider extends StatelessWidget {
  const _DashedDivider({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 1,
      width: double.infinity,
      child: CustomPaint(painter: _DashedLinePainter(color: color)),
    );
  }
}

class _DashedLinePainter extends CustomPainter {
  _DashedLinePainter({required this.color});

  final Color color;

  static const _dashWidth = 5.0;
  static const _dashGap = 4.0;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1;
    var x = 0.0;
    while (x < size.width) {
      canvas.drawLine(Offset(x, 0), Offset(x + _dashWidth, 0), paint);
      x += _dashWidth + _dashGap;
    }
  }

  @override
  bool shouldRepaint(covariant _DashedLinePainter oldDelegate) =>
      oldDelegate.color != color;
}

class _FreightModeLegendRow extends StatelessWidget {
  const _FreightModeLegendRow({
    required this.mode,
    required this.count,
    required this.total,
    required this.color,
  });

  final FreightMode mode;
  final int count;
  final int total;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final pct = total == 0 ? 0 : (count / total * 100).round();
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            '${mode.label} freight',
            style: TextStyle(fontSize: 13, color: context.colors.textBody),
          ),
        ),
        Text(
          '$count · $pct%',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: context.colors.textMutedStrong,
          ),
        ),
      ],
    );
  }
}

class _PublishedVsCustomBar extends StatelessWidget {
  const _PublishedVsCustomBar({required this.state});

  final RatesShellState state;

  @override
  Widget build(BuildContext context) {
    final published = state.activePublishedCount;
    final custom = state.activeCustomCount;
    final total = published + custom;
    final publishedPct = total == 0 ? 0 : (published / total * 100).round();
    final customPct = total == 0 ? 0 : 100 - publishedPct;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Published vs custom',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: context.colors.textBody,
              ),
            ),
            Text(
              '$publishedPct% / $customPct%',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: context.colors.textBody,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: SizedBox(
            height: 8,
            child: total == 0
                ? Container(color: context.colors.surfaceMuted)
                : Row(
                    children: [
                      Expanded(
                        flex: published,
                        child: Container(color: context.colors.primary),
                      ),
                      Expanded(
                        flex: custom,
                        child: Container(color: context.colors.custom),
                      ),
                    ],
                  ),
          ),
        ),
      ],
    );
  }
}

class _LeadingClientsCard extends StatelessWidget {
  const _LeadingClientsCard({required this.state});

  final RatesShellState state;

  @override
  Widget build(BuildContext context) {
    final entries =
        state.clientRateCounts.entries.where((e) => e.value > 0).toList()
          ..sort((a, b) => b.value.compareTo(a.value));
    final top = entries.take(3).toList();
    final namesById = {for (final c in state.clients) c.id: c.name};
    final clientsTotal = _statByLabel(state.stats, 'Clients')?.value;

    return _DashboardCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _cardTitle(
            context,
            'Leading clients',
            trailing: clientsTotal == null
                ? null
                : Text(
                    '$clientsTotal total',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: context.colors.textMutedStrong,
                    ),
                  ),
          ),
          const SizedBox(height: 18),
          if (top.isEmpty)
            Text(
              'No custom rates yet.',
              style: TextStyle(fontSize: 13, color: context.colors.textMuted),
            )
          else
            for (var i = 0; i < top.length; i++) ...[
              _LeadingClientRow(
                rank: i + 1,
                name: namesById[top[i].key] ?? top[i].key,
                count: top[i].value,
              ),
              if (i != top.length - 1) const SizedBox(height: 16),
            ],
        ],
      ),
    );
  }
}

class _LeadingClientRow extends StatelessWidget {
  const _LeadingClientRow({
    required this.rank,
    required this.name,
    required this.count,
  });

  final int rank;
  final String name;
  final int count;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 26,
          height: 26,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: context.colors.primaryChipBg,
            shape: BoxShape.circle,
          ),
          child: Text(
            '$rank',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: context.colors.primaryDeep,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
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
                '$count custom rate${count == 1 ? '' : 's'}',
                style: TextStyle(fontSize: 12, color: context.colors.textMuted),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ExpiringSoonCard extends StatelessWidget {
  const _ExpiringSoonCard({required this.state});

  final RatesShellState state;

  @override
  Widget build(BuildContext context) {
    final rates = state.expiringSoonRates.take(3).toList();

    return _DashboardCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _cardTitle(context, 'Expiring soon'),
              if (state.expiringSoonRates.isNotEmpty) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: context.colors.destructive.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${state.expiringSoonRates.length}',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: context.colors.destructive,
                    ),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 18),
          if (rates.isEmpty)
            Text(
              'No rates expiring soon.',
              style: TextStyle(fontSize: 13, color: context.colors.textMuted),
            )
          else
            for (var i = 0; i < rates.length; i++) ...[
              _ExpiringSoonRow(rate: rates[i]),
              if (i != rates.length - 1) ...[
                const SizedBox(height: 12),
                Divider(height: 1, color: context.colors.border),
                const SizedBox(height: 12),
              ],
            ],
        ],
      ),
    );
  }
}

class _ExpiringSoonRow extends StatelessWidget {
  const _ExpiringSoonRow({required this.rate});

  final ExpiringSoonRate rate;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                rate.client,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: context.colors.textBody,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                rate.chargeCode,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 11,
                  fontFamily: 'monospace',
                  color: context.colors.textMuted,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: context.colors.destructive.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            '${rate.daysLeft}d',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: context.colors.destructive,
            ),
          ),
        ),
      ],
    );
  }
}
