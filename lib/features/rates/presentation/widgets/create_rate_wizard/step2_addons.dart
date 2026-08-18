import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../../domain/entities/addon_field_def.dart';
import '../../../domain/entities/rates_enums.dart';
import '../../bloc/rate_wizard_bloc.dart';
import '../../rates_colors.dart';

class Step2Addons extends StatelessWidget {
  const Step2Addons({super.key});

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<RateWizardBloc>();
    final state = context.watch<RateWizardBloc>().state;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Add-on Charges', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: context.colors.textBody)),
        const SizedBox(height: 4),
        Text(
          state.freightMode == null
              ? 'Configure additional charges'
              : 'Configure additional charges for ${state.freightMode!.label} freight',
          style: TextStyle(fontSize: 13, color: context.colors.textMuted),
        ),
        const SizedBox(height: 24),
        for (final group in addonGroupDefs) ...[
          _AddonGroupCard(group: group, bloc: bloc, state: state),
          const SizedBox(height: 24),
        ],
      ],
    );
  }
}

class _AddonGroupCard extends StatelessWidget {
  const _AddonGroupCard({required this.group, required this.bloc, required this.state});

  final AddonGroupDef group;
  final RateWizardBloc bloc;
  final RateWizardState state;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: context.colors.surface,
        border: Border.all(color: context.colors.border),
        borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: context.colors.shadowSoft, blurRadius: 16, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(group.title, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: context.colors.textBody)),
          const SizedBox(height: 20),
          LayoutBuilder(
            builder: (context, constraints) {
              const spacing = 28.0;
              const minFieldWidth = 260.0;
              final columns = ((constraints.maxWidth + spacing) / (minFieldWidth + spacing))
                  .floor()
                  .clamp(1, group.fields.length);
              final rows = <List<AddonFieldDef>>[];
              for (var i = 0; i < group.fields.length; i += columns) {
                rows.add(group.fields.skip(i).take(columns).toList());
              }
              return Column(
                children: [
                  for (final row in rows) ...[
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        for (final field in row) ...[
                          Expanded(child: _AddonField(field: field, bloc: bloc, state: state)),
                          if (field != row.last) const SizedBox(width: spacing),
                        ],
                        // Pad out a short trailing row so fields stay a consistent width.
                        for (var i = row.length; i < columns; i++) ...[
                          const SizedBox(width: spacing),
                          const Expanded(child: SizedBox.shrink()),
                        ],
                      ],
                    ),
                    if (row != rows.last) const SizedBox(height: 36),
                  ],
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _AddonField extends StatelessWidget {
  const _AddonField({required this.field, required this.bloc, required this.state});

  final AddonFieldDef field;
  final RateWizardBloc bloc;
  final RateWizardState state;

  @override
  Widget build(BuildContext context) {
    final mode = state.addonModes[field.key] ?? AddonMode.exact;
    final isPercentage = mode == AddonMode.percentage;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(child: Text(field.label, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: context.colors.textMutedStrong))),
            if (field.hasToggle)
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _ModeDot(label: 'Exact', selected: !isPercentage, onTap: () => bloc.add(AddonModeChanged(field.key, AddonMode.exact))),
                  const SizedBox(width: 10),
                  _ModeDot(label: 'Percentage', selected: isPercentage, onTap: () => bloc.add(AddonModeChanged(field.key, AddonMode.percentage))),
                ],
              ),
          ],
        ),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(border: Border.all(color: context.colors.borderStrong), borderRadius: BorderRadius.circular(10), color: context.colors.surfaceSubtle),
          child: Row(
            children: [
              Text(isPercentage ? '%' : '₱', style: TextStyle(fontSize: 13, color: context.colors.textMuted)),
              const SizedBox(width: 6),
              Expanded(
                child: ShadInput(
                  placeholder: const Text('0.00'),
                  initialValue: state.addonValues[field.key] ?? '',
                  textAlign: TextAlign.right,
                  decoration: const ShadDecoration(border: ShadBorder.none, focusedBorder: ShadBorder.none),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  onChanged: (v) => bloc.add(AddonValueChanged(field.key, v)),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ModeDot extends StatelessWidget {
  const _ModeDot({required this.label, required this.selected, required this.onTap});

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: selected ? context.colors.primary : context.colors.borderStrong, width: 2),
                color: selected ? context.colors.primary : Colors.transparent,
              ),
            ),
            const SizedBox(width: 4),
            Text(label, style: TextStyle(fontSize: 12, color: context.colors.textMutedStrong)),
          ],
        ),
      ),
    );
  }
}
