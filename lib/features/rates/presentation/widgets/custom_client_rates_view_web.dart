import 'package:flutter/material.dart';

import '../../../../core/widgets/page_padding.dart';
import '../rates_colors.dart';
import 'custom_client_rates_view.dart';

/// Wide-viewport Custom Client Rates layout: avatar + client info + create
/// button share one row in the header card, and the tab pills sit inline
/// with the filter controls in a single row.
class CustomClientRatesPageWeb extends StatelessWidget {
  const CustomClientRatesPageWeb({
    super.key,
    required this.parts,
    required this.body,
    this.paginationBar,
  });

  final ClientRateHeaderParts parts;
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
              parts.backPill,
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 28),
                decoration: BoxDecoration(
                  color: context.colors.sidebarBg,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    parts.avatar,
                    const SizedBox(width: 16),
                    Expanded(child: parts.clientInfo),
                    parts.createRateButton,
                  ],
                ),
              ),
              const SizedBox(height: 28),
              Row(
                children: [
                  parts.tabsRow,
                  const Spacer(),
                  parts.freightFilter,
                  const SizedBox(width: 8),
                  parts.serviceFilter,
                  const SizedBox(width: 8),
                  parts.searchField,
                  const SizedBox(width: 8),
                  parts.sortToggle,
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
