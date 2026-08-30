import 'package:flutter/material.dart';

import 'published_rates_view.dart';

/// Narrow-viewport Published Rates layout: title/button wrap onto their own
/// line when tight, the tab pills sit on their own row above the filters,
/// and every filter control wraps onto as many lines as it needs.
class PublishedRatesPageMobile extends StatelessWidget {
  const PublishedRatesPageMobile({
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
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 48, 24, 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 16,
                runSpacing: 16,
                children: [parts.titleColumn, parts.createRateButton],
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
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
            child: body,
          ),
        ),
        ?paginationBar,
      ],
    );
  }
}
