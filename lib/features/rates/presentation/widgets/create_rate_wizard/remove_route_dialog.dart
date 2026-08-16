import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../rates_colors.dart';

class RemoveRouteDialog extends StatelessWidget {
  const RemoveRouteDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return ShadDialog.alert(
      radius: BorderRadius.circular(16),
      backgroundColor: RatesColors.surface,
      padding: const EdgeInsets.all(28),
      title: const Text('Remove this route?', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: RatesColors.textBody)),
      description: const Padding(
        padding: EdgeInsets.only(top: 8, bottom: 8),
        child: Text(
          "This will delete the route and its breakweight and rate values. This can't be undone.",
          style: TextStyle(fontSize: 14, color: RatesColors.textMuted, height: 1.5),
        ),
      ),
      actions: [
        ShadButton.outline(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Cancel'),
        ),
        ShadButton.destructive(
          onPressed: () => Navigator.of(context).pop(true),
          child: const Text('Remove'),
        ),
      ],
    );
  }
}
