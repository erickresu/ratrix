import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../rates_colors.dart';

/// Confirms clearing routing/cargo details before switching the selected
/// rate table — origin/destination/weight/dimensions were entered against
/// the old rate's routes and breakweights, and won't necessarily apply.
class ChangeRateTableDialog extends StatelessWidget {
  const ChangeRateTableDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return ShadDialog.alert(
      radius: BorderRadius.circular(16),
      backgroundColor: context.colors.surface,
      padding: const EdgeInsets.all(28),
      title: Text(
        'Change rate table?',
        style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: context.colors.textBody),
      ),
      description: Padding(
        padding: const EdgeInsets.only(top: 8, bottom: 8),
        child: Text(
          'This will clear the origin, destination, weight, and cargo details you entered, and hide the current breakdown.',
          style: TextStyle(fontSize: 14, color: context.colors.textMuted, height: 1.5),
        ),
      ),
      actions: [
        ShadButton.outline(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Cancel'),
        ),
        ShadButton(
          backgroundColor: context.colors.primary,
          onPressed: () => Navigator.of(context).pop(true),
          child: const Text('Yes, switch'),
        ),
      ],
    );
  }
}
