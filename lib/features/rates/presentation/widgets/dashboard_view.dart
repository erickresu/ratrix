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
import '../../domain/entities/rate_stat.dart';
import '../../domain/entities/rates_enums.dart';
import '../../domain/entities/recent_rate.dart';
import '../bloc/rates_shell_bloc.dart';
import '../rates_colors.dart';
import 'onboarding_tour.dart';
import 'sidebar_tour_keys.dart';

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
          padding: EdgeInsets.fromLTRB(
            isMobile ? 24 : 125,
            64,
            isMobile ? 24 : 125,
            40,
          ),
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
                              onTap: () => showOnboarding(context),
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
              Container(
                key: SidebarTourKeys.createRateNav,
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
            ],
          ),
        ),
        Expanded(
          child: CustomScrollView(
            // Desktop's content (5-row table + stat cards) fits the
            // viewport by design now, so scrolling there is disabled
            // outright rather than just discouraged — mobile keeps normal
            // scroll since its stacked/compact layout can still run taller
            // than the screen.
            physics: isMobile
                ? const AlwaysScrollableScrollPhysics()
                : const NeverScrollableScrollPhysics(),
            slivers: [
              SliverPadding(
                padding: EdgeInsets.fromLTRB(
                  isMobile ? 24 : 125,
                  0,
                  isMobile ? 24 : 125,
                  64,
                ),
                sliver: SliverFillRemaining(
                  hasScrollBody: false,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          for (final stat in state.stats) ...[
                            Expanded(
                              child: _StatCard(stat: stat, compact: isMobile),
                            ),
                            if (stat != state.stats.last)
                              SizedBox(width: isMobile ? 10 : 20),
                          ],
                        ],
                      ),
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
                      Expanded(
                        child: SoftCard(
                          padding: EdgeInsets.zero,
                          borderRadius: 10,
                          blurRadius: 20,
                          shadowOffset: const Offset(0, 8),
                          width: double.infinity,
                          // Capped at 5 so the dashboard's table fits within
                          // the viewport without needing its own scroll —
                          // "recent" only ever needs a glance, not the full
                          // history (that lives in Published/Custom Rates).
                          child: _RecentRatesTable(
                            rates: state.recentRates.take(5).toList(),
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
    final isMobile = Breakpoints.isMobile(context);
    return SkeletonShimmer(
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(
              isMobile ? 24 : 125,
              48,
              isMobile ? 24 : 125,
              40,
            ),
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
              padding: EdgeInsets.fromLTRB(
                isMobile ? 24 : 125,
                0,
                isMobile ? 24 : 125,
                56,
              ),
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
  const _StatCard({required this.stat, this.compact = false});

  final RateStat stat;

  /// Tighter padding/type scale for the 3-across mobile row, where each
  /// card only gets ~1/3 of a phone screen — the desktop sizing (24px
  /// padding, 32px value text) doesn't fit three side by side.
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final isPositive = stat.delta.trim().startsWith('+');
    // Smaller than before on mobile — the icon is decorative, so shrinking
    // it (rather than the label/value/delta text) reclaims width for the
    // numbers that actually matter in a 3-across row.
    final iconSize = compact ? 18.0 : 42.0;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(compact ? 14 : 20),
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
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 4,
            decoration: BoxDecoration(
              gradient: context.colors.primaryButtonGradient,
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(
              compact ? 10 : 24,
              compact ? 10 : 24,
              compact ? 8 : 24,
              compact ? 10 : 24,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        stat.label,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: compact ? 12 : 13,
                          fontWeight: FontWeight.w600,
                          height: 1.15,
                          color: context.colors.textMuted,
                        ),
                      ),
                    ),
                    SizedBox(width: compact ? 6 : 0),
                    Container(
                      width: iconSize,
                      height: iconSize,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(compact ? 8 : 13),
                        boxShadow: [
                          BoxShadow(
                            color: context.colors.primary.withValues(
                              alpha: 0.35,
                            ),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(compact ? 8 : 13),
                        child: ShineSweep(
                          child: Container(
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              gradient: context.colors.primaryButtonGradient,
                            ),
                            child: Icon(
                              _statIcon(stat.label),
                              size: compact ? 12 : 19,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: compact ? 10 : 14),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    stat.value,
                    maxLines: 1,
                    style: TextStyle(
                      fontSize: compact ? 24 : 32,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.4,
                      color: context.colors.textBody,
                    ),
                  ),
                ),
                SizedBox(height: compact ? 6 : 10),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: compact ? 6 : 8,
                      vertical: compact ? 2 : 3,
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
                          size: compact ? 9 : 11,
                          color: isPositive
                              ? context.colors.successText
                              : context.colors.textMuted,
                        ),
                        SizedBox(width: compact ? 2 : 3),
                        ConstrainedBox(
                          constraints: BoxConstraints(
                            maxWidth: compact ? 70 : 110,
                          ),
                          child: Text(
                            stat.delta,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: compact ? 11 : 12,
                              fontWeight: FontWeight.w600,
                              color: isPositive
                                  ? context.colors.successText
                                  : context.colors.textMuted,
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
      ),
    );
  }
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
    final fieldGap = SizedBox(width: compact ? 10 : 16);
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
              Expanded(flex: 14, child: Text('ROUTE', style: headerStyle)),
              fieldGap,
              Expanded(flex: 26, child: Text('CLIENT', style: headerStyle)),
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
                  flex: 14,
                  child: _RouteCell(route: rate.route, compact: compact),
                ),
                fieldGap,
                Expanded(
                  flex: 26,
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
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(color: fg, shape: BoxShape.circle),
          ),
          const SizedBox(width: 5),
          Text(
            status.label,
            style: TextStyle(
              fontSize: compact ? 10 : 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
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
    final fontSize = compact ? 12.0 : 14.0;
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
