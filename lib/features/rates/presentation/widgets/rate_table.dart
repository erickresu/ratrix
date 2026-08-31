import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../../../core/utils/breakpoints.dart';
import '../../../../core/widgets/horizontal_scroll_table.dart';
import '../../../../core/widgets/skeleton_box.dart';
import '../../domain/entities/rates_enums.dart';
import '../rates_colors.dart';

/// Active/Expired-style pill tab, shared by every rate list's tab row.
class RateTabPill extends StatelessWidget {
  const RateTabPill({
    super.key,
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

/// "Sort by soonest to expire" toggle button, shared by every rate list.
class RateSortByExpiryToggle extends StatelessWidget {
  const RateSortByExpiryToggle({
    super.key,
    required this.active,
    required this.onTap,
  });

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
                color: active
                    ? context.colors.primary
                    : context.colors.borderStrong,
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

/// Freight-mode badge used in every rate table's MODE column.
Widget rateModeBadge(BuildContext context, FreightMode mode) => ShadBadge(
  backgroundColor: context.colors.successBg.withValues(alpha: 0.6),
  hoverBackgroundColor: context.colors.successBg.withValues(alpha: 0.6),
  foregroundColor: context.colors.primaryDeep,
  padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
  child: Text(
    mode.label,
    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
  ),
);

/// Active/expired status badge used in every rate table's STATUS column.
Widget rateStatusBadge(
  BuildContext context, {
  required bool isActive,
  required String label,
}) => ShadBadge(
  backgroundColor: isActive
      ? context.colors.successBg
      : context.colors.surfaceMuted,
  hoverBackgroundColor: isActive
      ? context.colors.successBg
      : context.colors.surfaceMuted,
  foregroundColor: isActive
      ? context.colors.successText
      : context.colors.textMuted,
  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
  child: Text(
    label,
    maxLines: 1,
    overflow: TextOverflow.ellipsis,
    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
  ),
);

/// Measures the height it's given and reports how many [ResponsiveRateTable]
/// rows actually fit, so a caller's page size can track the viewport
/// instead of a fixed number. Fires [onFit] after the frame (never during
/// build) only when the fitting count changes. [builder] gets the raw
/// available height too, so a loading skeleton (whose row height differs
/// from the real table's) can size itself to fit without overflowing.
class RateTableFitReporter extends StatefulWidget {
  const RateTableFitReporter({
    super.key,
    required this.currentPerPage,
    required this.onFit,
    required this.builder,
  });

  final int currentPerPage;
  final ValueChanged<int> onFit;
  final Widget Function(BuildContext context, double availableHeight, int fit) builder;

  @override
  State<RateTableFitReporter> createState() => _RateTableFitReporterState();
}

class _RateTableFitReporterState extends State<RateTableFitReporter> {
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final available = constraints.maxHeight - ResponsiveRateTable.headerHeight;
        final fit = (available / ResponsiveRateTable.rowHeight).floor().clamp(1, 50);
        if (fit != widget.currentPerPage) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) widget.onFit(fit);
          });
        }
        return widget.builder(context, constraints.maxHeight, fit);
      },
    );
  }
}

/// Loading placeholder for a [ResponsiveRateTable] — same card markup as
/// before, but the row count is derived from [availableHeight] so it never
/// overflows the space the real table would also be measured against.
Widget buildFittedRateSkeleton(double availableHeight) {
  const cardHeight = 76.0;
  const gap = 16.0;
  final count = ((availableHeight + gap) / (cardHeight + gap))
      .floor()
      .clamp(1, 20);
  return SkeletonShimmer(
    child: Column(
      children: [
        for (var i = 0; i < count; i++) ...[
          if (i != 0) const SizedBox(height: gap),
          const ListRowCardSkeleton(),
        ],
      ],
    ),
  );
}

class _RowActionButton extends StatelessWidget {
  const _RowActionButton({
    required this.icon,
    required this.background,
    required this.foreground,
    required this.onTap,
  });

  final IconData icon;
  final Color background;
  final Color foreground;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: background,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(7),
          child: Icon(icon, size: 15, color: foreground),
        ),
      ),
    );
  }
}

/// One column between the fixed CHARGE CODE and actions columns of a
/// [ResponsiveRateTable] — [flex] sizes it on desktop, [width] on mobile
/// (where every column becomes fixed-width inside a horizontal scroll).
class RateTableColumn {
  const RateTableColumn({
    required this.label,
    required this.flex,
    required this.width,
  });

  final String label;
  final int flex;
  final double width;
}

/// Builds one column's cell content for a given row. [compact] is true in
/// the mobile fixed-width layout (slightly larger font, matching the
/// original per-table row widgets), false in the desktop flex layout.
typedef RateCellBuilder<T> =
    Widget Function(BuildContext context, T rate, {required bool compact});

/// Shared shape for the rate list tables (Published Rates, Custom Client
/// Rates): a fixed CHARGE CODE column, a caller-defined set of middle
/// columns, and a fixed actions column, with a responsive split — desktop
/// renders flex columns in one row; mobile pins CHARGE CODE in its own
/// left pane and scrolls the rest horizontally together (same split the
/// dashboard's recent-rates table and the rate wizard's matrix table use).
class ResponsiveRateTable<T> extends StatelessWidget {
  const ResponsiveRateTable({
    super.key,
    required this.rates,
    required this.columns,
    required this.cellBuilders,
    required this.chargeCodeOf,
    required this.idOf,
    required this.deletingRateId,
    required this.onEdit,
    required this.onDelete,
  }) : assert(columns.length == cellBuilders.length);

  final List<T> rates;
  final List<RateTableColumn> columns;
  final List<RateCellBuilder<T>> cellBuilders;
  final String Function(T rate) chargeCodeOf;
  final String Function(T rate) idOf;
  final String? deletingRateId;
  final ValueChanged<T> onEdit;
  final ValueChanged<T> onDelete;

  static const _headerStyle = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.4,
  );

  // Header row is always the fixed navy `sidebarBg`, regardless of app
  // theme (same treatment as the sidebar itself) — so its text needs a
  // fixed light color rather than a theme-aware muted token.
  static final _headerTextColor = Colors.white.withValues(alpha: 0.75);

  static const _chargeCodeWidth = 130.0;
  static const _actionsWidth = 92.0;
  static const _colGap = 12.0;
  static const headerHeight = 40.0;
  static const rowHeight = 64.0;

  // +24 accounts for the scrollable pane's own 12px symmetric padding
  // (left+right) around the header/row content — without it the last
  // column (actions) clips against the pane's right edge.
  double get _scrollableWidth =>
      columns.fold<double>(0, (sum, c) => sum + c.width) +
      _colGap * columns.length +
      24;

  @override
  Widget build(BuildContext context) {
    final isMobile = Breakpoints.isMobile(context);

    // Align (loose constraints) so the table hugs header + row content
    // instead of stretching to fill whatever height its parent gives it
    // (which left blank space below the last row inside the border).
    return Align(
      alignment: Alignment.topCenter,
      child: Container(
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
        clipBehavior: Clip.antiAlias,
        child: isMobile ? _buildMobile(context) : _buildDesktop(context),
      ),
    );
  }

  Widget _buildDesktop(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          color: context.colors.sidebarBg,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          child: Row(
            children: [
              Expanded(
                flex: 3,
                child: Text(
                  'CHARGE CODE',
                  style: _headerStyle.copyWith(color: _headerTextColor),
                ),
              ),
              for (final column in columns)
                Expanded(
                  flex: column.flex,
                  child: Text(
                    column.label,
                    style: _headerStyle.copyWith(color: _headerTextColor),
                  ),
                ),
              const SizedBox(width: 80),
            ],
          ),
        ),
        for (final rate in rates) _buildDesktopRow(context, rate),
      ],
    );
  }

  Widget _buildDesktopRow(BuildContext context, T rate) {
    final deleting = deletingRateId == idOf(rate);
    return Opacity(
      opacity: deleting ? 0.5 : 1,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        decoration: BoxDecoration(
          border: Border(top: BorderSide(color: context.colors.border)),
        ),
        child: Row(
          children: [
            Expanded(
              flex: 3,
              child: Text(
                chargeCodeOf(rate),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'monospace',
                  color: context.colors.textBody,
                ),
              ),
            ),
            for (var i = 0; i < columns.length; i++)
              Expanded(
                flex: columns[i].flex,
                child: cellBuilders[i](context, rate, compact: false),
              ),
            _actions(context, width: 80, rate: rate, deleting: deleting),
          ],
        ),
      ),
    );
  }

  Widget _buildMobile(BuildContext context) {
    Widget headerCell(String text, double width) => SizedBox(
      width: width,
      child: Text(
        text,
        style: _headerStyle.copyWith(color: _headerTextColor),
      ),
    );

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: _chargeCodeWidth,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                height: headerHeight,
                alignment: Alignment.centerLeft,
                padding: const EdgeInsets.only(left: 20),
                color: context.colors.sidebarBg,
                child: Text(
                  'CHARGE CODE',
                  style: _headerStyle.copyWith(color: _headerTextColor),
                ),
              ),
              for (final rate in rates)
                Container(
                  height: rowHeight,
                  alignment: Alignment.centerLeft,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    border: Border(
                      top: BorderSide(color: context.colors.border),
                    ),
                  ),
                  child: Text(
                    chargeCodeOf(rate),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      fontFamily: 'monospace',
                      color: context.colors.textBody,
                    ),
                  ),
                ),
            ],
          ),
        ),
        Expanded(
          child: HorizontalScrollTable(
            width: _scrollableWidth,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  height: headerHeight,
                  alignment: Alignment.centerLeft,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  color: context.colors.sidebarBg,
                  child: Row(
                    children: [
                      for (final column in columns) ...[
                        headerCell(column.label, column.width),
                        const SizedBox(width: _colGap),
                      ],
                      const SizedBox(width: _actionsWidth),
                    ],
                  ),
                ),
                for (final rate in rates) _buildMobileRow(context, rate),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMobileRow(BuildContext context, T rate) {
    final deleting = deletingRateId == idOf(rate);
    return Opacity(
      opacity: deleting ? 0.5 : 1,
      child: Container(
        height: rowHeight,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          border: Border(top: BorderSide(color: context.colors.border)),
        ),
        child: Row(
          children: [
            for (var i = 0; i < columns.length; i++) ...[
              SizedBox(
                width: columns[i].width,
                child: cellBuilders[i](context, rate, compact: true),
              ),
              const SizedBox(width: _colGap),
            ],
            _actions(
              context,
              width: _actionsWidth,
              rate: rate,
              deleting: deleting,
            ),
          ],
        ),
      ),
    );
  }

  Widget _actions(
    BuildContext context, {
    required double width,
    required T rate,
    required bool deleting,
  }) => SizedBox(
    width: width,
    child: deleting
        ? const Center(
            child: SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          )
        : Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              _RowActionButton(
                icon: CupertinoIcons.pencil,
                background: context.colors.primaryChipBg,
                foreground: context.colors.primaryDeep,
                onTap: () => onEdit(rate),
              ),
              const SizedBox(width: 6),
              _RowActionButton(
                icon: CupertinoIcons.trash,
                background: context.colors.destructive.withValues(alpha: 0.1),
                foreground: context.colors.destructive,
                onTap: () => onDelete(rate),
              ),
            ],
          ),
  );
}
