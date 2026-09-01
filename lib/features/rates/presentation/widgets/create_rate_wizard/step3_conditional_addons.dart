import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../../../../core/utils/breakpoints.dart';
import '../../../domain/entities/location_option.dart';
import '../../../domain/entities/matrix_row.dart';
import '../../../domain/entities/rates_enums.dart';
import '../../bloc/rate_wizard_bloc.dart';
import '../../rates_colors.dart';
import 'rate_matrix_table.dart';

/// Distinct destinations (ODA) or origins (Pickup Fee) already entered in
/// the main Rate Matrix step, as pickable [LocationOption]s — ODA/Pickup
/// conditions only ever make sense tied to a route this rate actually has,
/// so this reuses that data instead of a fresh geo-search. Only rows where
/// the user picked a real suggestion (not just typed free text) carry a
/// resolved option with a usable id, so free-text-only rows are skipped.
List<LocationOption> _routeLocationChoices(
  List<MatrixRow> matrixRows, {
  required bool destinations,
}) {
  final seen = <String>{};
  final choices = <LocationOption>[];
  for (final row in matrixRows) {
    final option = destinations ? row.destinationOption : row.originOption;
    if (option == null) continue;
    final key = option.id ?? option.label;
    if (!seen.add(key)) continue;
    choices.add(option);
  }
  return choices;
}

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
    final isMobile = Breakpoints.isMobile(context);
    final destinationChoices = _routeLocationChoices(state.matrixRows, destinations: true);
    final originChoices = _routeLocationChoices(state.matrixRows, destinations: false);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Conditional Add-ons',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: context.colors.textBody,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Charges that only apply when specific conditions are met',
          style: TextStyle(fontSize: 13, color: context.colors.textMuted),
        ),
        const SizedBox(height: 28),
        isMobile
            ? Column(
                children: [
                  for (final type in ConditionalType.values) ...[
                    _ConditionCard(
                      type: type,
                      selected: state.conditionalType == type,
                      onTap: () => bloc.add(ConditionalTypeChanged(type)),
                    ),
                    if (type != ConditionalType.values.last)
                      const SizedBox(height: 12),
                  ],
                ],
              )
            : Row(
                children: [
                  for (final type in ConditionalType.values) ...[
                    Expanded(
                      child: _ConditionCard(
                        type: type,
                        selected: state.conditionalType == type,
                        onTap: () => bloc.add(ConditionalTypeChanged(type)),
                      ),
                    ),
                    if (type != ConditionalType.values.last)
                      const SizedBox(width: 12),
                  ],
                ],
              ),
        const SizedBox(height: 28),
        if (state.conditionalType == null)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(40),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: context.colors.surfaceSubtle,
              border: Border.all(color: context.colors.border),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  CupertinoIcons.hand_point_right,
                  size: 22,
                  color: context.colors.textFaint,
                ),
                const SizedBox(height: 10),
                Text(
                  'Select a condition above to configure its pricing.',
                  style: TextStyle(
                    fontSize: 14,
                    color: context.colors.textMuted,
                  ),
                ),
              ],
            ),
          )
        else
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: isMobile ? double.infinity : 340,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Pricing option',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: context.colors.textMutedStrong,
                      ),
                    ),
                    const SizedBox(height: 10),
                    ShadSelect<PricingOption>(
                      initialValue: state.conditionalPricingOption,
                      selectedOptionBuilder: (context, value) =>
                          Text(value.label),
                      onChanged: (value) {
                        if (value != null) {
                          bloc.add(ConditionalPricingOptionChanged(value));
                        }
                      },
                      options: [
                        for (final p in PricingOption.values)
                          ShadOption(value: p, child: Text(p.label)),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              RateMatrixTable(
                matrixRows: state.conditionalMatrixRows,
                breakweights: state.conditionalBreakweights,
                // ODA only ever matches by destination, Pickup Fee only
                // ever matches by origin — matches how
                // custom_addons.oda_config/.pickup_fee_config are keyed on
                // the backend, so there's no point offering the other
                // field here.
                showOrigin: state.conditionalType == ConditionalType.pickup,
                showDestination: state.conditionalType == ConditionalType.oda,
                // Only one location field ever shows here, so the pane
                // doesn't need the main matrix's wider fixed width —
                // 30% of the table's own width, not the usual 50/50 split.
                leftPaneWidthFraction: 0.3,
                // No "match by" dropdown, and no live geo-search either —
                // ODA/Pickup conditions only make sense tied to a route
                // this rate actually has, so the choices are exactly the
                // distinct destinations/origins already entered in the
                // main Rate Matrix step (see `_routeLocationChoices`), not
                // a fresh search against the whole geography database.
                showMatchByFilter: false,
                originSearchType: LocationSearchType.province,
                destinationSearchType: LocationSearchType.province,
                originPlaceholder: 'Select origin from routes above...',
                destinationPlaceholder: 'Select destination from routes above...',
                originSearchResults: originChoices,
                destinationSearchResults: destinationChoices,
                onOriginChanged: (i, v) =>
                    bloc.add(ConditionalOriginChanged(i, v)),
                onDestinationChanged: (i, v) =>
                    bloc.add(ConditionalDestinationChanged(i, v)),
                onOriginSelected: (i, option, text) =>
                    bloc.add(ConditionalOriginSelected(i, option, text)),
                onDestinationSelected: (i, option, text) =>
                    bloc.add(ConditionalDestinationSelected(i, option, text)),
                onCellChanged: (i, bi, v) =>
                    bloc.add(ConditionalCellChanged(i, bi, v)),
                onBreakweightMinChanged: (i, v) =>
                    bloc.add(ConditionalBreakweightMinChanged(i, v)),
                onBreakweightMaxChanged: (i, v) =>
                    bloc.add(ConditionalBreakweightMaxChanged(i, v)),
                onRemoveBreakweight: (i) =>
                    bloc.add(ConditionalBreakweightRemoved(i)),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  GhostButton(
                    label: 'Add route',
                    onTap: () => bloc.add(const ConditionalRouteAdded()),
                  ),
                  const SizedBox(width: 12),
                  GhostButton(
                    label: 'Add breakweight',
                    onTap: () => bloc.add(const ConditionalBreakweightAdded()),
                  ),
                ],
              ),
            ],
          ),
      ],
    );
  }
}


class _ConditionCard extends StatelessWidget {
  const _ConditionCard({
    required this.type,
    required this.selected,
    required this.onTap,
  });

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
            gradient: selected ? context.colors.primaryButtonGradient : null,
            color: selected ? null : context.colors.surfaceSubtle,
            border: Border.all(
              color: selected ? context.colors.primary : context.colors.border,
              width: selected ? 1.5 : 1,
            ),
            borderRadius: BorderRadius.circular(10),
            boxShadow: selected
                ? [
                    BoxShadow(
                      color: context.colors.shadowSoft,
                      blurRadius: 12,
                      offset: const Offset(0, 3),
                    ),
                  ]
                : null,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 56,
                height: 56,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: selected
                      ? Colors.white.withValues(alpha: 0.2)
                      : context.colors.primaryChipBg,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _conditionalTypeIcons[type],
                  size: 26,
                  color: selected ? Colors.white : context.colors.primaryDeep,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      type.label,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: selected
                            ? Colors.white
                            : context.colors.textMutedStrong,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      type.hint,
                      style: TextStyle(
                        fontSize: 12,
                        color: selected
                            ? Colors.white.withValues(alpha: 0.85)
                            : context.colors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
              if (selected)
                const Padding(
                  padding: EdgeInsets.only(left: 8),
                  child: Icon(
                    CupertinoIcons.check_mark_circled_solid,
                    size: 18,
                    color: Colors.white,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}


