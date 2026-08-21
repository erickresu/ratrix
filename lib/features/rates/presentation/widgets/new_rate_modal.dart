import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../../../core/utils/breakpoints.dart';
import '../../../../core/widgets/animated_pressable.dart';
import '../bloc/rates_shell_bloc.dart';
import '../rates_colors.dart';

class NewRateModal extends StatelessWidget {
  const NewRateModal({super.key});

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<RatesShellBloc>();
    final isMobile = Breakpoints.isMobile(context);

    final publishedCard = _OptionCard(
      title: 'Published rate',
      description: 'Standard rate visible to all clients on this route.',
      icon: CupertinoIcons.globe,
      onTap: () {
        Navigator.of(context).pop();
        bloc.add(const PublishedRateChosen());
      },
    );

    final customCard = _OptionCard(
      title: 'Custom rate',
      description: 'Negotiated rate assigned to one specific client.',
      icon: CupertinoIcons.person_crop_circle,
      onTap: () {
        Navigator.of(context).pop();
        bloc.add(const CustomRateChosen());
      },
    );

    return ShadDialog(
      radius: BorderRadius.circular(16),
      backgroundColor: context.colors.surface,
      padding: EdgeInsets.all(isMobile ? 24 : 40),
      title: Text('New rate', style: TextStyle(fontSize: 19, fontWeight: FontWeight.w700, color: context.colors.textBody)),
      description: Padding(
        padding: const EdgeInsets.only(top: 4),
        child: Text('Choose how this rate should be set up.', style: TextStyle(fontSize: 14, color: context.colors.textMuted)),
      ),
      actions: [
        ShadButton.outline(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
      ],
      child: Padding(
        padding: const EdgeInsets.only(top: 20, bottom: 8),
        child: isMobile
            ? Column(
                children: [
                  publishedCard,
                  const SizedBox(height: 14),
                  customCard,
                ],
              )
            : Row(
                children: [
                  Expanded(child: publishedCard),
                  const SizedBox(width: 14),
                  Expanded(child: customCard),
                ],
              ),
      ),
    );
  }
}

class _OptionCard extends StatelessWidget {
  const _OptionCard({required this.title, required this.description, required this.icon, required this.onTap});

  final String title;
  final String description;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AnimatedPressable(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: context.colors.border, width: 1.5),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 44,
              height: 44,
              alignment: Alignment.center,
              decoration: BoxDecoration(color: context.colors.primaryChipBg, shape: BoxShape.circle),
              child: Icon(icon, size: 22, color: context.colors.primary),
            ),
            const SizedBox(height: 12),
            Text(title, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: context.colors.textBody)),
            const SizedBox(height: 4),
            Text(description, style: TextStyle(fontSize: 13, color: context.colors.textMuted, height: 1.4)),
          ],
        ),
      ),
    );
  }
}
