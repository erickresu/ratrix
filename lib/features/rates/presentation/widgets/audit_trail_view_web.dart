import 'package:flutter/material.dart';

import 'audit_trail_view.dart';

/// Wide-viewport Audit Trail layout: action filter and search field share
/// one row.
class AuditTrailPageWeb extends StatelessWidget {
  const AuditTrailPageWeb({
    super.key,
    required this.parts,
    required this.body,
    this.paginationBar,
  });

  final AuditTrailHeaderParts parts;
  final Widget body;
  final Widget? paginationBar;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(64, 48, 64, 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              parts.titleColumn,
              const SizedBox(height: 28),
              Row(
                children: [
                  parts.actionFilter,
                  const SizedBox(width: 8),
                  parts.searchField,
                ],
              ),
            ],
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(64, 0, 64, 24),
            child: body,
          ),
        ),
        ?paginationBar,
      ],
    );
  }
}
