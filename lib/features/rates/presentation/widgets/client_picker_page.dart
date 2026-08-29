import 'package:flutter/material.dart';

import '../rates_colors.dart';

/// Distinct accent color per business-type category, so the pill reads at
/// a glance instead of requiring the label text — [businessType] is a
/// free-form string from the backend (not a closed enum), so anything
/// outside this known set (including "Others") falls back to the same
/// muted color the label always used before category colors existed.
Color businessTypeColor(BuildContext context, String businessType) {
  return switch (businessType.trim().toLowerCase()) {
    'retailer' => context.colors.primaryDeep,
    'wholesaler' => context.colors.custom,
    'distributor' => context.colors.success,
    'manufacturer' => context.colors.destructive,
    _ => context.colors.textMutedStrong,
  };
}

/// Small icon + label chip used for a client card's business-type and VAT
/// pills, shared by every "pick a client" screen. Only the icon is
/// colored — several differently-colored pills side by side with colored
/// text too reads as noisy, so the label always stays neutral.
class InfoPill extends StatelessWidget {
  const InfoPill({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.label,
    this.bordered = false,
  });

  final IconData icon;
  final Color iconColor;
  final String label;
  final bool bordered;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: context.colors.surfaceSubtle,
        borderRadius: BorderRadius.circular(20),
        border: bordered ? Border.all(color: context.colors.border) : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11, color: iconColor),
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
          padding: const EdgeInsets.fromLTRB(64, 48, 64, 40),
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
          padding: const EdgeInsets.fromLTRB(20, 48, 20, 40),
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
