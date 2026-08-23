import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../rates_colors.dart';

/// Confirms a hard delete before `DeleteRateRequested` fires — mirrors
/// `RemoveRouteDialog`'s pattern (see that file for the wizard's version).
class DeleteRateDialog extends StatelessWidget {
  const DeleteRateDialog({super.key, required this.chargeCode});

  final String chargeCode;

  @override
  Widget build(BuildContext context) {
    return ShadDialog.alert(
      radius: BorderRadius.circular(16),
      backgroundColor: context.colors.surface,
      padding: const EdgeInsets.all(28),
      title: Text(
        'Delete this rate?',
        style: TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.w700,
          color: context.colors.textBody,
        ),
      ),
      description: Padding(
        padding: const EdgeInsets.only(top: 8, bottom: 8),
        child: Text(
          "$chargeCode and all its routes, breakweights, and addons will be permanently deleted. This can't be undone.",
          style: TextStyle(
            fontSize: 14,
            color: context.colors.textMuted,
            height: 1.5,
          ),
        ),
      ),
      actions: [
        ShadButton.outline(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Cancel'),
        ),
        ShadButton.destructive(
          onPressed: () => Navigator.of(context).pop(true),
          child: const Text('Delete'),
        ),
      ],
    );
  }
}
