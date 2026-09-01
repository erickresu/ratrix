import 'package:flutter/material.dart';

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
      padding: const EdgeInsets.fromLTRB(125, 48, 125, 56),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // `parts.header` ("Back"/"Calculate Freight"/subtitle) lives
          // inside the left column below, not above this whole Row — that,
          // plus `IntrinsicHeight` + `stretch` here, is what makes the
          // breakdown box a direct stretched sibling of the left column:
          // its top lands level with "Calculate Freight" itself and its
          // bottom lands level with the Reset/Calculate row, matching the
          // left column's full height exactly rather than a guessed fixed
          // pixel value that drifts whenever that content's height changes.
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
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
                            Expanded(flex: 3, child: parts.serviceFreightCard),
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
                SizedBox(width: 400, child: parts.breakdownPanel),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
