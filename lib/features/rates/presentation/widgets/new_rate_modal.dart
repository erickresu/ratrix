import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../bloc/rates_shell_bloc.dart';
import '../rates_colors.dart';

class NewRateModal extends StatelessWidget {
  const NewRateModal({super.key});

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<RatesShellBloc>();

    return ShadDialog(
      radius: BorderRadius.circular(16),
      backgroundColor: RatesColors.surface,
      padding: const EdgeInsets.all(32),
      title: const Text('New rate', style: TextStyle(fontSize: 19, fontWeight: FontWeight.w700, color: RatesColors.textBody)),
      description: const Padding(
        padding: EdgeInsets.only(top: 4),
        child: Text('Choose how this rate should be set up.', style: TextStyle(fontSize: 14, color: RatesColors.textMuted)),
      ),
      actions: [
        ShadButton.outline(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
      ],
      child: Padding(
        padding: const EdgeInsets.only(top: 20, bottom: 8),
        child: Row(
          children: [
            Expanded(
              child: _OptionCard(
                title: 'Published rate',
                description: 'Standard rate visible to all clients on this route.',
                icon: CupertinoIcons.square,
                onTap: () {
                  Navigator.of(context).pop();
                  bloc.add(const PublishedRateChosen());
                },
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: _OptionCard(
                title: 'Custom rate',
                description: 'Negotiated rate assigned to one specific client.',
                icon: CupertinoIcons.circle_fill,
                onTap: () {
                  Navigator.of(context).pop();
                  bloc.add(const CustomRateChosen());
                },
              ),
            ),
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
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            border: Border.all(color: RatesColors.border, width: 1.5),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 36,
                height: 36,
                alignment: Alignment.center,
                decoration: BoxDecoration(color: RatesColors.primaryChipBg, borderRadius: BorderRadius.circular(8)),
                child: Icon(icon, size: 14, color: RatesColors.primary),
              ),
              const SizedBox(height: 14),
              Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: RatesColors.textBody)),
              const SizedBox(height: 6),
              Text(description, style: const TextStyle(fontSize: 13, color: RatesColors.textMuted, height: 1.4)),
            ],
          ),
        ),
      ),
    );
  }
}
