import 'package:flutter/material.dart';

import '../../../../core/widgets/page_padding.dart';
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
        PagePadding(
          top: 48,
          bottom: 40,
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
          child: PagePadding(bottom: 24, child: body),
        ),
        ?paginationBar,
      ],
    );
  }
}
