import 'package:flutter/material.dart';

import 'shipping_calculator_form_view.dart';

/// Narrow-viewport Shipping Calculator layout: everything stacks in one
/// column — Service/Freight, Routing, Cargo Details, then Submit. No room
/// for a docked breakdown panel, so the result is shown via a modal
/// instead (triggered by the dispatcher's [BlocListener]).
class ShippingCalculatorFormMobile extends StatelessWidget {
  const ShippingCalculatorFormMobile({super.key, required this.parts});

  final ShippingCalculatorFormParts parts;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 48, 20, 56),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          parts.header,
          const SizedBox(height: 24),
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              parts.serviceFreightCard,
              const SizedBox(height: 20),
              parts.routingCard,
            ],
          ),
          const SizedBox(height: 20),
          parts.cargoDetailsCard,
          const SizedBox(height: 20),
          parts.submitButton,
        ],
      ),
    );
  }
}
