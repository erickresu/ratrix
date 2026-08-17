import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../../domain/entities/rates_enums.dart';
import '../../bloc/rate_wizard_bloc.dart';
import '../../rates_colors.dart';
import 'rate_matrix_table.dart';

const _conditionalTypeIcons = {
  ConditionalType.oda: CupertinoIcons.location_slash,
  ConditionalType.pickup: CupertinoIcons.cube_box,
};

class Step3ConditionalAddons extends StatelessWidget {
  const Step3ConditionalAddons({super.key});

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<RateWizardBloc>();
    final state = context.watch<RateWizardBloc>().state;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Conditional Add-ons', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: RatesColors.textBody)),
        const SizedBox(height: 4),
        const Text('Charges that only apply when specific conditions are met', style: TextStyle(fontSize: 13, color: RatesColors.textMuted)),
        const SizedBox(height: 24),
        Row(
          children: [
            for (final type in ConditionalType.values) ...[
              Expanded(child: _ConditionCard(type: type, selected: state.conditionalType == type, onTap: () => bloc.add(ConditionalTypeChanged(type)))),
              if (type != ConditionalType.values.last) const SizedBox(width: 12),
            ],
          ],
        ),
        const SizedBox(height: 24),
        if (state.conditionalType == null)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(40),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: RatesColors.surfaceSubtle,
              border: Border.all(color: RatesColors.border),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Text('Select a condition above to configure its pricing.', style: TextStyle(fontSize: 14, color: RatesColors.textMuted)),
          )
        else
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 340,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Pricing option', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: RatesColors.textMutedStrong)),
                    const SizedBox(height: 10),
                    ShadSelect<PricingOption>(
                      initialValue: state.conditionalPricingOption,
                      selectedOptionBuilder: (context, value) => Text(value.label),
                      onChanged: (value) {
                        if (value != null) bloc.add(ConditionalPricingOptionChanged(value));
                      },
                      options: [for (final p in PricingOption.values) ShadOption(value: p, child: Text(p.label))],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  const Text('Match by:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: RatesColors.textMuted)),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(color: RatesColors.surfaceMuted, borderRadius: BorderRadius.circular(6)),
                    child: Row(
                      children: [
                        for (final basis in LocationBasis.values)
                          _SegButton(label: basis.label, selected: state.locationBasis == basis, onTap: () => bloc.add(LocationBasisChanged(basis))),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              RateMatrixTable(
                matrixRows: state.conditionalMatrixRows,
                breakweights: state.conditionalBreakweights,
                originPlaceholder: 'Search origin ${state.locationBasis.label.toLowerCase()}...',
                destinationPlaceholder: 'Search destination ${state.locationBasis.label.toLowerCase()}...',
                onOriginChanged: (i, v) => bloc.add(ConditionalOriginChanged(i, v)),
                onDestinationChanged: (i, v) => bloc.add(ConditionalDestinationChanged(i, v)),
                onCellChanged: (i, bi, v) => bloc.add(ConditionalCellChanged(i, bi, v)),
                onBreakweightMinChanged: (i, v) => bloc.add(ConditionalBreakweightMinChanged(i, v)),
                onBreakweightMaxChanged: (i, v) => bloc.add(ConditionalBreakweightMaxChanged(i, v)),
                onRemoveBreakweight: (i) => bloc.add(ConditionalBreakweightRemoved(i)),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  _GhostButton(label: '+ Add route', onTap: () => bloc.add(const ConditionalRouteAdded())),
                  const SizedBox(width: 12),
                  _GhostButton(label: '+ Add breakweight', onTap: () => bloc.add(const ConditionalBreakweightAdded())),
                ],
              ),
            ],
          ),
      ],
    );
  }
}

class _ConditionCard extends StatelessWidget {
  const _ConditionCard({required this.type, required this.selected, required this.onTap});

  final ConditionalType type;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: selected ? RatesColors.primaryButtonGradient : null,
            color: selected ? null : RatesColors.surfaceSubtle,
            border: Border.all(color: selected ? RatesColors.primary : RatesColors.border, width: selected ? 1.5 : 1),
            borderRadius: BorderRadius.circular(12),
            boxShadow: selected ? const [BoxShadow(color: RatesColors.shadowSoft, blurRadius: 12, offset: Offset(0, 3))] : null,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 56,
                height: 56,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: selected ? Colors.white.withValues(alpha: 0.2) : RatesColors.primaryChipBg,
                  shape: BoxShape.circle,
                ),
                child: Icon(_conditionalTypeIcons[type], size: 26, color: selected ? Colors.white : RatesColors.primaryDeep),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(type.label, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: selected ? Colors.white : RatesColors.textMutedStrong)),
                    const SizedBox(height: 2),
                    Text(type.hint, style: TextStyle(fontSize: 12, color: selected ? Colors.white.withValues(alpha: 0.85) : RatesColors.textMuted)),
                  ],
                ),
              ),
              if (selected)
                const Padding(
                  padding: EdgeInsets.only(left: 8),
                  child: Icon(CupertinoIcons.check_mark_circled_solid, size: 18, color: Colors.white),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SegButton extends StatelessWidget {
  const _SegButton({required this.label, required this.selected, required this.onTap});

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(5),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: selected ? RatesColors.surface : Colors.transparent,
            borderRadius: BorderRadius.circular(5),
            boxShadow: selected ? [BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 2)] : null,
          ),
          child: Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: selected ? RatesColors.textBody : RatesColors.textMuted)),
        ),
      ),
    );
  }
}

class _GhostButton extends StatelessWidget {
  const _GhostButton({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(border: Border.all(color: RatesColors.borderStrong, width: 1.5), borderRadius: BorderRadius.circular(10)),
          child: Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: RatesColors.textMuted)),
        ),
      ),
    );
  }
}
