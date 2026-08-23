import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../../../core/utils/breakpoints.dart';
import '../../../../core/widgets/mr_ratrix.dart';
import '../../../../core/widgets/pagination_bar.dart';
import '../../../../core/widgets/skeleton_box.dart';
import '../../domain/entities/audit_log.dart';
import '../bloc/rates_shell_bloc.dart';
import '../rates_colors.dart';

const _kAllValue = '__all__';

class AuditTrailView extends StatelessWidget {
  const AuditTrailView({super.key});

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<RatesShellBloc>();
    final state = context.watch<RatesShellBloc>().state;
    final isMobile = Breakpoints.isMobile(context);

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

    final filtersControlsRow = isMobile
        ? Wrap(spacing: 8, runSpacing: 8, children: [actionFilter, searchField])
        : Row(children: [actionFilter, const SizedBox(width: 8), searchField]);

    return Column(
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(
            isMobile ? 20 : 64,
            48,
            isMobile ? 20 : 64,
            40,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              titleColumn,
              const SizedBox(height: 28),
              filtersControlsRow,
            ],
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(
              isMobile ? 20 : 64,
              0,
              isMobile ? 20 : 64,
              24,
            ),
            child: state.auditLogsLoading
                ? const SkeletonShimmer(
                    child: Column(
                      children: [
                        ListRowCardSkeleton(),
                        SizedBox(height: 16),
                        ListRowCardSkeleton(),
                        SizedBox(height: 16),
                        ListRowCardSkeleton(),
                      ],
                    ),
                  )
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
                          style: TextStyle(
                            fontSize: 14,
                            color: context.colors.textMuted,
                          ),
                        ),
                      ],
                    ),
                  )
                : _AuditLogTable(logs: state.pagedAuditLogs),
          ),
        ),
        if (!state.auditLogsLoading && state.filteredAuditLogs.isNotEmpty)
          PaginationBar(
            page: state.auditLogPage,
            itemsPerPage: RatesShellState.auditLogsPerPage,
            totalItems: state.filteredAuditLogs.length,
            onPageChanged: (p) => bloc.add(AuditLogPageChanged(p)),
          ),
      ],
    );
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

  @override
  Widget build(BuildContext context) {
    return Container(
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            color: context.colors.surfaceSubtle,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Row(
              children: [
                Expanded(
                  flex: 3,
                  child: Text(
                    'TIME',
                    style: _headerStyle.copyWith(
                      color: context.colors.textMuted,
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    'ACTION',
                    style: _headerStyle.copyWith(
                      color: context.colors.textMuted,
                    ),
                  ),
                ),
                Expanded(
                  flex: 4,
                  child: Text(
                    'RECORD ID',
                    style: _headerStyle.copyWith(
                      color: context.colors.textMuted,
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    'USER',
                    style: _headerStyle.copyWith(
                      color: context.colors.textMuted,
                    ),
                  ),
                ),
              ],
            ),
          ),
          for (final log in logs) _AuditLogRow(log: log),
        ],
      ),
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

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => showShadDialog<void>(
          context: context,
          builder: (_) => _AuditLogDetailDialog(log: log),
        ),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 11),
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
                    fontSize: 13,
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
                    fontSize: 13,
                    color: context.colors.textMutedStrong,
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

String _formatTimestamp(DateTime dt) {
  final local = dt.toLocal();
  String two(int n) => n.toString().padLeft(2, '0');
  return '${local.year}-${two(local.month)}-${two(local.day)} '
      '${two(local.hour)}:${two(local.minute)}';
}

/// Dumps the raw log entry rather than only the typed [AuditLog] fields —
/// the exact response shape isn't documented, so this stays useful even
/// where the typed parsing above guessed a key name wrong.
class _AuditLogDetailDialog extends StatelessWidget {
  const _AuditLogDetailDialog({required this.log});

  final AuditLog log;

  @override
  Widget build(BuildContext context) {
    const encoder = JsonEncoder.withIndent('  ');
    final pretty = encoder.convert(log.raw);

    return ShadDialog(
      title: const Text('Audit Log Entry'),
      description: Text(
        log.tableName ?? log.id,
        style: TextStyle(color: context.colors.textMuted),
      ),
      actions: [
        ShadButton.outline(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
      ],
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxHeight: 360, maxWidth: 480),
        child: SingleChildScrollView(
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: context.colors.surfaceSubtle,
              borderRadius: BorderRadius.circular(8),
            ),
            child: SelectableText(
              pretty,
              style: const TextStyle(fontSize: 12, fontFamily: 'monospace'),
            ),
          ),
        ),
      ),
    );
  }
}
