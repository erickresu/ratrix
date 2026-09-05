import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../../../core/utils/breakpoints.dart';
import '../../../../core/widgets/horizontal_scroll_table.dart';
import '../../../../core/widgets/mr_ratrix.dart';
import '../../../../core/widgets/pagination_bar.dart';
import '../../domain/entities/audit_log.dart';
import '../bloc/rates_shell_bloc.dart';
import '../rates_colors.dart';
import 'audit_trail_view_mobile.dart';
import 'audit_trail_view_web.dart';
import 'rate_table.dart';

const _kAllValue = '__all__';

/// Pre-built, bloc-wired pieces shared by [AuditTrailPageWeb] and
/// [AuditTrailPageMobile] — they differ only in arrangement.
typedef AuditTrailHeaderParts = ({
  Widget titleColumn,
  Widget actionFilter,
  Widget searchField,
});

class AuditTrailView extends StatelessWidget {
  const AuditTrailView({super.key});

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<RatesShellBloc>();
    final state = context.watch<RatesShellBloc>().state;

    final titleColumn = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Audit Trail',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.2,
            color: context.colors.textBody,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Recent create, update, and delete activity across rates',
          style: TextStyle(fontSize: 14, color: context.colors.textMuted),
        ),
      ],
    );

    final actionFilter = SizedBox(
      width: 170,
      child: ShadSelect<String>(
        placeholder: const Text('Action'),
        initialValue: state.auditLogActionFilter ?? _kAllValue,
        selectedOptionBuilder: (context, value) =>
            Text(value == _kAllValue ? 'All actions' : _actionLabel(value)),
        onChanged: (value) {
          if (value == null) return;
          bloc.add(
            AuditLogActionFilterChanged(value == _kAllValue ? null : value),
          );
        },
        options: const [
          ShadOption(value: _kAllValue, child: Text('All actions')),
          ShadOption(value: 'create', child: Text('Created')),
          ShadOption(value: 'update', child: Text('Updated')),
          ShadOption(value: 'delete', child: Text('Deleted')),
        ],
      ),
    );

    final searchField = SizedBox(
      width: 260,
      child: ShadInput(
        placeholder: const Text('Search by table, record, user...'),
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
        onChanged: (v) => bloc.add(AuditLogSearchChanged(v)),
      ),
    );

    final parts = (
      titleColumn: titleColumn,
      actionFilter: actionFilter,
      searchField: searchField,
    );

    final body = RateTableFitReporter(
      currentPerPage: state.auditLogsPerPage,
      onFit: (fit) => bloc.add(AuditLogsPerPageChanged(fit)),
      rowHeight: _kAuditRowHeight,
      builder: (context, availableHeight, fit) => state.auditLogsLoading
          ? buildFittedRateSkeleton(availableHeight)
          : state.filteredAuditLogs.isEmpty
          ? Container(
              width: double.infinity,
              padding: const EdgeInsets.all(40),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                border: Border.all(
                  color: context.colors.borderStrong,
                  style: BorderStyle.solid,
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const MrRatrix(size: 96),
                  const SizedBox(height: 4),
                  Text(
                    'No audit activity found.',
                    style: TextStyle(fontSize: 14, color: context.colors.textMuted),
                  ),
                ],
              ),
            )
          : _AuditLogTable(logs: state.pagedAuditLogs),
    );

    // Reserved even while loading (just invisible) so the table's measured
    // height doesn't shrink the moment loading finishes and the bar turns
    // visible — see the identical fix on the rate-table pages.
    final paginationBar = state.auditLogsLoading || state.filteredAuditLogs.isNotEmpty
        ? Opacity(
            opacity: state.auditLogsLoading ? 0 : 1,
            child: IgnorePointer(
              ignoring: state.auditLogsLoading,
              child: PaginationBar(
                page: state.auditLogPage,
                itemsPerPage: state.auditLogsPerPage,
                totalItems: state.filteredAuditLogs.length,
                onPageChanged: (p) => bloc.add(AuditLogPageChanged(p)),
              ),
            ),
          )
        : null;

    return Breakpoints.isMobile(context)
        ? AuditTrailPageMobile(parts: parts, body: body, paginationBar: paginationBar)
        : AuditTrailPageWeb(parts: parts, body: body, paginationBar: paginationBar);
  }
}

String _actionLabel(String action) => switch (action) {
  'create' => 'Created',
  'update' => 'Updated',
  'delete' => 'Deleted',
  _ => action,
};

class _AuditLogTable extends StatelessWidget {
  const _AuditLogTable({required this.logs});

  final List<AuditLog> logs;

  static const _headerStyle = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.4,
  );

  // Header row is always the fixed navy `sidebarBg`, regardless of app
  // theme (same treatment as the sidebar itself) — so its text needs a
  // fixed light color rather than a theme-aware muted token.
  static final _headerTextColor = Colors.white.withValues(alpha: 0.75);

  // Mobile column widths — TIME stays pinned in a fixed left pane,
  // ACTION/RECORD ID/USER scroll horizontally together.
  static const _timeWidth = 140.0;
  static const _actionWidth = 90.0;
  static const _recordIdWidth = 160.0;
  static const _userWidth = 110.0;
  static const _colGap = 12.0;
  static const _headerHeight = 40.0;
  // +24 accounts for the scrollable pane's own 12px symmetric padding
  // (left+right) — without it the last column clips against the pane's
  // right edge.
  static const _scrollableWidth =
      _actionWidth + _recordIdWidth + _userWidth + _colGap * 2 + 24;

  @override
  Widget build(BuildContext context) {
    final isMobile = Breakpoints.isMobile(context);

    // Align (loose constraints) so the table hugs header + row content
    // instead of stretching to fill whatever height its parent gives it —
    // see the identical fix on `ResponsiveRateTable`.
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
                  'TIME',
                  style: _headerStyle.copyWith(color: _headerTextColor),
                ),
              ),
              Expanded(
                flex: 2,
                child: Text(
                  'ACTION',
                  style: _headerStyle.copyWith(color: _headerTextColor),
                ),
              ),
              Expanded(
                flex: 4,
                child: Text(
                  'RECORD ID',
                  style: _headerStyle.copyWith(color: _headerTextColor),
                ),
              ),
              Expanded(
                flex: 2,
                child: Text(
                  'USER',
                  style: _headerStyle.copyWith(color: _headerTextColor),
                ),
              ),
            ],
          ),
        ),
        for (final log in logs) _AuditLogRow(log: log),
      ],
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
          width: _timeWidth,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                height: _headerHeight,
                alignment: Alignment.centerLeft,
                padding: const EdgeInsets.only(left: 20),
                color: context.colors.sidebarBg,
                child: Text(
                  'TIME',
                  style: _headerStyle.copyWith(color: _headerTextColor),
                ),
              ),
              for (final log in logs) _AuditLogTimeCell(log: log),
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
                  height: _headerHeight,
                  alignment: Alignment.centerLeft,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  color: context.colors.sidebarBg,
                  child: Row(
                    children: [
                      headerCell('ACTION', _actionWidth),
                      const SizedBox(width: _colGap),
                      headerCell('RECORD ID', _recordIdWidth),
                      const SizedBox(width: _colGap),
                      headerCell('USER', _userWidth),
                    ],
                  ),
                ),
                for (final log in logs)
                  _AuditLogScrollableRow(
                    log: log,
                    actionWidth: _actionWidth,
                    recordIdWidth: _recordIdWidth,
                    userWidth: _userWidth,
                    colGap: _colGap,
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _AuditLogRow extends StatelessWidget {
  const _AuditLogRow({required this.log});

  final AuditLog log;

  Color _actionColor(BuildContext context) => switch (log.action) {
    'create' => context.colors.successText,
    'delete' => context.colors.destructive,
    _ => context.colors.primaryDeep,
  };

  Color _actionBg(BuildContext context) => switch (log.action) {
    'create' => context.colors.successBg,
    'delete' => context.colors.destructive.withValues(alpha: 0.1),
    _ => context.colors.primaryChipBg,
  };

  @override
  Widget build(BuildContext context) {
    final time = log.createdAt;

    return Container(
      height: _kAuditRowHeight,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: context.colors.border)),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(
              time == null ? '—' : _formatTimestamp(time),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 12,
                color: context.colors.textMutedStrong,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Align(
              alignment: Alignment.centerLeft,
              child: ShadBadge(
                backgroundColor: _actionBg(context),
                hoverBackgroundColor: _actionBg(context),
                foregroundColor: _actionColor(context),
                padding: const EdgeInsets.symmetric(
                  horizontal: 9,
                  vertical: 3,
                ),
                child: Text(
                  log.actionLabel,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            flex: 4,
            child: Text(
              log.recordId ?? '—',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 12,
                fontFamily: 'monospace',
                color: context.colors.textMuted,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              log.userName ?? '—',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 12,
                color: context.colors.textMutedStrong,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

const _kAuditRowHeight = 52.0;

/// Mobile's pinned-left-pane TIME column for one audit row — paired with
/// [_AuditLogScrollableRow] for the same [log], both fixed to
/// [_kAuditRowHeight] so the two panes stay visually aligned while the
/// right pane scrolls independently.
class _AuditLogTimeCell extends StatelessWidget {
  const _AuditLogTimeCell({required this.log});

  final AuditLog log;

  @override
  Widget build(BuildContext context) {
    final time = log.createdAt;
    return Container(
      height: _kAuditRowHeight,
      alignment: Alignment.centerLeft,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: context.colors.border)),
      ),
      child: Text(
        time == null ? '—' : _formatTimestamp(time),
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(fontSize: 13, color: context.colors.textMutedStrong),
      ),
    );
  }
}

/// Mobile's scrollable-right-pane ACTION/RECORD ID/USER columns for one
/// audit row — see [_AuditLogTimeCell].
class _AuditLogScrollableRow extends StatelessWidget {
  const _AuditLogScrollableRow({
    required this.log,
    required this.actionWidth,
    required this.recordIdWidth,
    required this.userWidth,
    required this.colGap,
  });

  final AuditLog log;
  final double actionWidth;
  final double recordIdWidth;
  final double userWidth;
  final double colGap;

  Color _actionColor(BuildContext context) => switch (log.action) {
        'create' => context.colors.successText,
        'delete' => context.colors.destructive,
        _ => context.colors.primaryDeep,
      };

  Color _actionBg(BuildContext context) => switch (log.action) {
        'create' => context.colors.successBg,
        'delete' => context.colors.destructive.withValues(alpha: 0.1),
        _ => context.colors.primaryChipBg,
      };

  @override
  Widget build(BuildContext context) {
    return Container(
      height: _kAuditRowHeight,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: context.colors.border)),
      ),
      child: Row(
        children: [
          SizedBox(
            width: actionWidth,
            child: Align(
              alignment: Alignment.centerLeft,
              child: ShadBadge(
                backgroundColor: _actionBg(context),
                hoverBackgroundColor: _actionBg(context),
                foregroundColor: _actionColor(context),
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
                child: Text(
                  log.actionLabel,
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
                ),
              ),
            ),
          ),
          SizedBox(width: colGap),
          SizedBox(
            width: recordIdWidth,
            child: Text(
              log.recordId ?? '—',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 12,
                fontFamily: 'monospace',
                color: context.colors.textMuted,
              ),
            ),
          ),
          SizedBox(width: colGap),
          SizedBox(
            width: userWidth,
            child: Text(
              log.userName ?? '—',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 13, color: context.colors.textMutedStrong),
            ),
          ),
        ],
      ),
    );
  }
}

String _formatTimestamp(DateTime dt) {
  final local = dt.toLocal();
  String two(int n) => n.toString().padLeft(2, '0');
  return '${local.year}-${two(local.month)}-${two(local.day)} '
      '${two(local.hour)}:${two(local.minute)}';
}
