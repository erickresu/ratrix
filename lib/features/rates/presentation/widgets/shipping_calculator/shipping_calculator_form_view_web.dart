import 'package:flutter/material.dart';

import '../../../../../core/widgets/page_padding.dart';
import 'shipping_calculator_form_view.dart';

/// Wide-viewport Shipping Calculator layout: a two-column form — the left
/// column stacks Service/Freight + Routing side by side above Cargo
/// Details, with Submit pinned to its bottom edge; the right column docks
/// the freight breakdown panel (always visible, no need for a result
/// modal) — its own header menu holds "How was it calculated?" and
/// "Generate Invoice PDF", so there's no separate button row here.
class ShippingCalculatorFormWeb extends StatelessWidget {
  const ShippingCalculatorFormWeb({super.key, required this.parts});

  final ShippingCalculatorFormParts parts;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: PagePadding(
        top: 48,
        bottom: 56,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // `IntrinsicHeight` bounds this Row inside the page's
            // `SingleChildScrollView` (otherwise the left column's Column
            // would get unbounded height) — `start` alignment (not
            // `stretch`) keeps each side at its own natural height instead
            // of forcing the breakdown panel to match the left column's,
            // which made it grow uncomfortably tall whenever the form had
            // more fields than the panel needed.
            IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        parts.header,
                        const SizedBox(height: 24),
                        IntrinsicHeight(
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Expanded(
                                flex: 3,
                                child: parts.serviceFreightCard,
                              ),
                              const SizedBox(width: 20),
                              Expanded(flex: 2, child: parts.routingCard),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                        parts.cargoDetailsCard,
                        Padding(
                          padding: const EdgeInsets.only(top: 20),
                          child: parts.submitButton,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 24),
                  SizedBox(
                    width: 400,
                    height: 700,
                    child: parts.breakdownPanel,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
