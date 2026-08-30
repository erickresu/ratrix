import 'package:flutter/material.dart';

import '../rates_colors.dart';

/// Small icon + label chip used for a client card's business-type and VAT
/// pills, shared by every "pick a client" screen. Always neutral — no
/// per-category coloring, so several pills side by side stay calm instead
/// of reading as a noisy legend.
class InfoPill extends StatelessWidget {
  const InfoPill({
    super.key,
    required this.icon,
    required this.label,
    this.bordered = false,
  });

  final IconData icon;
  final String label;
  final bool bordered;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: context.colors.surfaceSubtle.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(20),
        border: bordered ? Border.all(color: context.colors.border) : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11, color: context.colors.textMutedStrong),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: context.colors.textMutedStrong,
            ),
          ),
        ],
      ),
    );
  }
}

/// Pre-built title/search pieces shared by every "pick a client" screen
/// (Custom Clients, Shipping Calculator's client picker) — they differ only
/// in the strings/handlers used to build these, not in how the page itself
/// is laid out.
typedef ClientPickerHeaderParts = ({Widget titleColumn, Widget searchField});

/// Wide-viewport client-picker layout: title and search field share one row.
class ClientPickerPageWeb extends StatelessWidget {
  const ClientPickerPageWeb({
    super.key,
    required this.parts,
    required this.body,
    this.paginationBar,
  });

  final ClientPickerHeaderParts parts;
  final Widget body;
  final Widget? paginationBar;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(125, 48, 125, 40),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: parts.titleColumn),
              SizedBox(width: 300, child: parts.searchField),
            ],
          ),
        ),
        body,
        ?paginationBar,
      ],
    );
  }
}

/// Narrow-viewport client-picker layout: title stacks above a full-width
/// search field.
class ClientPickerPageMobile extends StatelessWidget {
  const ClientPickerPageMobile({
    super.key,
    required this.parts,
    required this.body,
    this.paginationBar,
  });

  final ClientPickerHeaderParts parts;
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
              const SizedBox(height: 16),
              SizedBox(width: double.infinity, child: parts.searchField),
            ],
          ),
        ),
        body,
        ?paginationBar,
      ],
    );
  }
}
