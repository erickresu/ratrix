import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../rates_colors.dart';

/// Confirms clearing a location field's current text/selection before
/// switching its "match by" filter type (Island/City/Province/etc) — the
/// old value was resolved under the old filter and won't make sense under
/// the new one.
class ChangeMatchByDialog extends StatelessWidget {
  const ChangeMatchByDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return ShadDialog.alert(
      radius: BorderRadius.circular(16),
      backgroundColor: context.colors.surface,
      padding: const EdgeInsets.all(28),
      title: Text(
        'Change search filter?',
        style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: context.colors.textBody),
      ),
      description: Padding(
        padding: const EdgeInsets.only(top: 8, bottom: 8),
        child: Text(
          'This will clear the current value in this field so you can search again under the new filter.',
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
          child: const Text('Yes, clear it'),
        ),
      ],
    );
  }
}
