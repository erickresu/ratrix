import 'package:flutter/material.dart';

import 'audit_trail_view.dart';

/// Narrow-viewport Audit Trail layout: action filter and search field wrap
/// onto as many lines as they need.
class AuditTrailPageMobile extends StatelessWidget {
  const AuditTrailPageMobile({
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
          padding: const EdgeInsets.fromLTRB(24, 48, 24, 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              parts.titleColumn,
              const SizedBox(height: 28),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [parts.actionFilter, parts.searchField],
              ),
            ],
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
            child: body,
          ),
        ),
        ?paginationBar,
      ],
    );
  }
}
