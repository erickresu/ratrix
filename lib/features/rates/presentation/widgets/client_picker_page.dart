import 'package:flutter/material.dart';

import '../../../../core/widgets/page_padding.dart';
import '../rates_colors.dart';

/// Small icon + label chip used for a client card's business-type and VAT
/// pills, shared by every "pick a client" screen. Outline-only (no fill) —
/// several filled pills side by side on the same card read as a wall of
/// gray boxes, so the border alone is enough to read as a chip.
class InfoPill extends StatelessWidget {
  const InfoPill({super.key, required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: context.colors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11, color: context.colors.textMuted),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
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
        PagePadding(
          top: 48,
          bottom: 40,
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
