import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../../../core/utils/breakpoints.dart';
import '../../../../core/widgets/animated_pressable.dart';
import '../../domain/entities/rates_enums.dart';
import '../bloc/rates_shell_bloc.dart';
import '../rates_colors.dart';
import 'rate_import_flow.dart';

enum _ModalStep { chooseMethod, chooseManualType }

class NewRateModal extends StatefulWidget {
  const NewRateModal({super.key});

  @override
  State<NewRateModal> createState() => _NewRateModalState();
}

class _NewRateModalState extends State<NewRateModal> {
  _ModalStep _step = _ModalStep.chooseMethod;
  bool _downloadingTemplate = false;
  bool _importing = false;

  Future<void> _downloadTemplate() async {
    if (_downloadingTemplate) return;
    setState(() => _downloadingTemplate = true);
    await downloadRateImportTemplate(context);
    if (mounted) setState(() => _downloadingTemplate = false);
  }

  Future<void> _import() async {
    if (_importing) return;
    setState(() => _importing = true);
    await runRateImportFlow(context);
    if (!mounted) return;
    setState(() => _importing = false);
    // `runRateImportFlow` only reaches the dispatch below on a real
    // success — a cancelled picker or parse failure returns/toasts inside
    // it instead, so popping unconditionally here would close the dialog
    // on those paths too. There's no return value to branch on, but a
    // successful import always lands `RatesShellBloc.state.view` on
    // `RatesView.create`, which this modal has no business staying open
    // for regardless of how it got there.
    if (context.read<RatesShellBloc>().state.view == RatesView.create) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<RatesShellBloc>();
    final isMobile = Breakpoints.isMobile(context);

    final importCard = _OptionCard(
      title: 'Import from Excel',
      description: 'Fill in a template offline, then bring the routes in at once.',
      icon: CupertinoIcons.doc_on_doc,
      fillHeight: !isMobile,
      onTap: _importing ? null : () => _import(),
      trailing: _importing
          ? const SizedBox(
              width: 14,
              height: 14,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : null,
      footer: TextButton.icon(
        onPressed: _downloadingTemplate ? null : _downloadTemplate,
        icon: _downloadingTemplate
            ? const SizedBox(
                width: 12,
                height: 12,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Icon(CupertinoIcons.arrow_down_doc, size: 13),
        label: const Text('Download template'),
        style: TextButton.styleFrom(
          padding: EdgeInsets.zero,
          minimumSize: const Size(0, 0),
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          foregroundColor: context.colors.primaryDeep,
          textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
        ),
      ),
    );

    final manualCard = _OptionCard(
      title: 'Manual',
      description: 'Build the rate yourself, step by step, in the wizard.',
      icon: CupertinoIcons.slider_horizontal_3,
      fillHeight: !isMobile,
      onTap: () => setState(() => _step = _ModalStep.chooseManualType),
    );

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

    final (title, description, cards) = switch (_step) {
      _ModalStep.chooseMethod => (
          'New rate',
          'Choose how this rate should be set up.',
          [importCard, manualCard],
        ),
      _ModalStep.chooseManualType => (
          'New rate',
          'Choose the kind of rate to build.',
          [publishedCard, customCard],
        ),
    };

    return Center(
      child: ShadDialog(
        radius: BorderRadius.circular(16),
      backgroundColor: context.colors.surface,
      padding: EdgeInsets.all(isMobile ? 24 : 40),
      title: Text(title, style: TextStyle(fontSize: 19, fontWeight: FontWeight.w700, color: context.colors.textBody)),
      description: Padding(
        padding: const EdgeInsets.only(top: 4),
        child: Text(description, style: TextStyle(fontSize: 14, color: context.colors.textMuted)),
      ),
      actions: [
        if (_step == _ModalStep.chooseManualType)
          ShadButton.outline(
            onPressed: () => setState(() => _step = _ModalStep.chooseMethod),
            child: const Text('Back'),
          ),
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
                  for (var i = 0; i < cards.length; i++) ...[
                    if (i != 0) const SizedBox(height: 14),
                    cards[i],
                  ],
                ],
              )
            : IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    for (var i = 0; i < cards.length; i++) ...[
                      if (i != 0) const SizedBox(width: 14),
                      Expanded(child: cards[i]),
                    ],
                  ],
                ),
              ),
      ),
      ),
    );
  }
}

class _OptionCard extends StatelessWidget {
  const _OptionCard({
    required this.title,
    required this.description,
    required this.icon,
    required this.onTap,
    this.trailing,
    this.footer,
    this.fillHeight = false,
  });

  final String title;
  final String description;
  final IconData icon;
  final VoidCallback? onTap;
  final Widget? trailing;

  final Widget? footer;

  /// True when this card sits in a row of same-height cards (desktop,
  /// under `IntrinsicHeight`) — pushes [footer] to the card's bottom via a
  /// `Spacer`, which needs that bounded height to work. False (mobile,
  /// cards stacked with no shared height) uses a fixed gap instead, since
  /// a `Spacer` under unbounded height throws.
  final bool fillHeight;

  @override
  Widget build(BuildContext context) {
    return AnimatedPressable(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap ?? () {},
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: context.colors.border, width: 1.5),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          mainAxisSize: fillHeight ? MainAxisSize.max : MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: 44,
                  height: 44,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(color: context.colors.primaryChipBg, shape: BoxShape.circle),
                  child: Icon(icon, size: 22, color: context.colors.primary),
                ),
                if (trailing != null) trailing!,
              ],
            ),
            const SizedBox(height: 12),
            Text(title, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: context.colors.textBody)),
            const SizedBox(height: 4),
            Text(description, style: TextStyle(fontSize: 13, color: context.colors.textMuted, height: 1.4)),
            // Pushes `footer` (when present) to the bottom of the card so
            // both cards' footers land on the same baseline regardless of
            // how many lines their description wraps to — without this the
            // no-footer card (Manual) was simply shorter than Import's.
            if (fillHeight) const Spacer() else const SizedBox(height: 16),
            if (footer != null) ...[
              const SizedBox(height: 10),
              Divider(height: 1, color: context.colors.border),
              const SizedBox(height: 10),
              footer!,
            ],
          ],
        ),
      ),
    );
  }
}
