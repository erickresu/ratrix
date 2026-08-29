import 'package:flutter/material.dart';

import '../rates_colors.dart';
import 'custom_client_rates_view.dart';

/// Narrow-viewport Custom Client Rates layout: the header card wraps
/// avatar+info onto its own row above the create button, tab pills sit on
/// their own row, and every filter control wraps onto as many lines as it
/// needs.
class CustomClientRatesPageMobile extends StatelessWidget {
  const CustomClientRatesPageMobile({
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
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 48, 20, 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              parts.backPill,
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                decoration: BoxDecoration(
                  color: context.colors.sidebarPanelBg,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 16,
                  runSpacing: 16,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        parts.avatar,
                        const SizedBox(width: 16),
                        Flexible(child: parts.clientInfo),
                      ],
                    ),
                    parts.createRateButton,
                  ],
                ),
              ),
              const SizedBox(height: 28),
              parts.tabsRow,
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  parts.freightFilter,
                  parts.serviceFilter,
                  parts.searchField,
                  parts.sortToggle,
                ],
              ),
            ],
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
            child: body,
          ),
        ),
        ?paginationBar,
      ],
    );
  }
}
