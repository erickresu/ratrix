import 'package:flutter/material.dart';

import 'shipping_calculator_form_view.dart';

/// Wide-viewport Shipping Calculator layout: a two-column form — the left
/// column stacks Service/Freight + Routing side by side above Cargo
/// Details, with Submit pinned to its bottom edge; the right column docks
/// the freight breakdown panel (always visible, no need for a result
/// modal) with the "Generate Invoice PDF" action beneath it.
class ShippingCalculatorFormWeb extends StatelessWidget {
  const ShippingCalculatorFormWeb({super.key, required this.parts});

  final ShippingCalculatorFormParts parts;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(64, 48, 64, 56),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          parts.header,
          const SizedBox(height: 24),
          // Force both columns' button rows (Reset/Calculate on the left,
          // Generate Invoice PDF on the right) to sit level with each
          // other — `IntrinsicHeight` + `stretch` gives both columns the
          // taller one's height, and `spaceBetween` pins each column's
          // last child (its button row) to that shared bottom edge instead
          // of trailing wherever its own content happened to end.
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          IntrinsicHeight(
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Expanded(flex: 3, child: parts.serviceFreightCard),
                                const SizedBox(width: 20),
                                Expanded(flex: 2, child: parts.routingCard),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),
                          parts.cargoDetailsCard,
                        ],
                      ),
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // `Expanded` grows the card to fill the same height
                      // as the left column's details cards (both columns
                      // are stretched by the outer `IntrinsicHeight`),
                      // instead of the card sizing to its own content and
                      // leaving a big empty gap before the button.
                      Expanded(child: parts.breakdownPanel),
                      Padding(
                        padding: const EdgeInsets.only(top: 20),
                        child: parts.pdfButtonSlot,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
