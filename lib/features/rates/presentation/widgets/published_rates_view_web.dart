import 'package:flutter/material.dart';

import '../../../../core/widgets/page_padding.dart';
import 'published_rates_view.dart';

/// Wide-viewport Published Rates layout: title + button share one row,
/// and the tab pills sit inline with the filter controls in a single row.
class PublishedRatesPageWeb extends StatelessWidget {
  const PublishedRatesPageWeb({
    super.key,
    required this.parts,
    required this.body,
    this.paginationBar,
  });

  final RateListHeaderParts parts;
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
              Row(
                children: [
                  Expanded(child: parts.titleColumn),
                  parts.createRateButton,
                ],
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
