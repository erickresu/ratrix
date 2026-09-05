import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import '../../../../../core/utils/breakpoints.dart';
import '../../../domain/entities/rates_enums.dart';
import '../../bloc/rate_wizard_bloc.dart';
import '../../rates_colors.dart';
import 'rate_matrix_table.dart';

class Step1RateMatrix extends StatelessWidget {
  const Step1RateMatrix({super.key});

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<RateWizardBloc>();
    final state = context.watch<RateWizardBloc>().state;
    final isMobile = Breakpoints.isMobile(context);

    /*
    final bulkOpsText = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Bulk operations',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: context.colors.textBody,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          'Download a template, or bulk import/export rate data',
          style: TextStyle(
            fontSize: 12,
            color: context.colors.textMuted,
          ),
        ),
      ],
    );

    final bulkOpsButtons = [
      _MiniButton(
        label: 'Download template',
        icon: CupertinoIcons.doc_text,
      ),
      _MiniButton(
        label: 'Import Excel',
        icon: CupertinoIcons.arrow_up_doc,
      ),
      _MiniButton(
        label: 'Export Excel',
        icon: CupertinoIcons.arrow_down_doc,
      ),
    ];
    */

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        /*
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: context.colors.primarySoftBg,
            borderRadius: BorderRadius.circular(14),
          ),
          child: isMobile
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    bulkOpsText,
                    const SizedBox(height: 12),
                    Wrap(spacing: 8, runSpacing: 8, children: bulkOpsButtons),
                  ],
                )
              : Row(
                  children: [
                    Expanded(child: bulkOpsText),
                    for (final button in bulkOpsButtons) ...[
                      button,
                      if (button != bulkOpsButtons.last) const SizedBox(width: 8),
                    ],
                  ],
                ),
        ),
        const SizedBox(height: 28),
        */
        Row(
          children: [
            _MatrixTab(
              label: 'Standard rates',
              selected: state.serviceLevel == ServiceLevel.regular,
              onTap: () =>
                  bloc.add(const ServiceLevelChanged(ServiceLevel.regular)),
            ),
            const SizedBox(width: 24),
            _MatrixTab(
              label: 'Express rates',
              selected: state.serviceLevel == ServiceLevel.express,
              onTap: () =>
                  bloc.add(const ServiceLevelChanged(ServiceLevel.express)),
            ),
          ],
        ),
        // Express rate markup — disabled for now.
        /*
        Divider(height: 25, color: context.colors.border),
        Builder(builder: (context) {
          final markupDescription = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Express rate markup',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: context.colors.textBody,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'Apply a percentage markup to all current rates. You can still edit individual rows after.',
                style: TextStyle(
                  fontSize: 13,
                  color: context.colors.textMuted,
                ),
              ),
            ],
          );

          final markupControls = Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  border: Border.all(color: context.colors.borderStrong),
                  borderRadius: BorderRadius.circular(10),
                  color: context.colors.surfaceSubtle,
                ),
                child: Row(
                  children: [
                    SizedBox(
                      width: 60,
                      child: ShadInput(
                        placeholder: const Text('0.0'),
                        initialValue: state.markup,
                        textAlign: TextAlign.right,
                        decoration: const ShadDecoration(
                          border: ShadBorder.none,
                          focusedBorder: ShadBorder.none,
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        onChanged: (v) => bloc.add(MarkupChanged(v)),
                      ),
                    ),
                    Text(
                      '%',
                      style: TextStyle(
                        fontSize: 14,
                        color: context.colors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              ShadButton(
                backgroundColor: context.colors.primary,
                onPressed: () => bloc.add(const MarkupApplied()),
                child: const Text('Apply markup'),
              ),
            ],
          );

          if (isMobile) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                markupDescription,
                const SizedBox(height: 12),
                markupControls,
              ],
            );
          }

          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: markupDescription),
              const SizedBox(width: 24),
              markupControls,
            ],
          );
        }),
        */
        const SizedBox(height: 16),
        RateMatrixTable(
          matrixRows: state.matrixRows,
          breakweights: state.breakweights,
          originPlaceholder: 'Search origin...',
          destinationPlaceholder: 'Search destination...',
          originSearchResults: state.originSearchResults,
          destinationSearchResults: state.destinationSearchResults,
          originSearchLoading: state.originSearchLoading,
          destinationSearchLoading: state.destinationSearchLoading,
          originSearchType: state.originSearchType,
          destinationSearchType: state.destinationSearchType,
          onOriginChanged: (i, v) => bloc.add(OriginChanged(i, v)),
          onDestinationChanged: (i, v) => bloc.add(DestinationChanged(i, v)),
          onOriginQueryChanged: (q) =>
              bloc.add(LocationSearchQueryChanged(LocationField.origin, q)),
          onDestinationQueryChanged: (q) => bloc.add(
            LocationSearchQueryChanged(LocationField.destination, q),
          ),
          onOriginSelected: (i, option, text) =>
              bloc.add(OriginLocationSelected(i, option, text)),
          onDestinationSelected: (i, option, text) =>
              bloc.add(DestinationLocationSelected(i, option, text)),
          onOriginSearchTypeChanged: (t) =>
              bloc.add(LocationSearchTypeChanged(LocationField.origin, t)),
          onDestinationSearchTypeChanged: (t) =>
              bloc.add(LocationSearchTypeChanged(LocationField.destination, t)),
          onCellChanged: (i, bi, v) => bloc.add(
            CellChanged(
              i,
              bi,
              v,
              isExpress: state.serviceLevel == ServiceLevel.express,
            ),
          ),
          onBreakweightMinChanged: (i, v) =>
              bloc.add(BreakweightMinChanged(i, v)),
          onBreakweightMaxChanged: (i, v) =>
              bloc.add(BreakweightMaxChanged(i, v)),
          onRemoveBreakweight: (i) => bloc.add(BreakweightRemoved(i)),
          onRemoveRoute: (i) => bloc.add(RouteRemoveRequested(i)),
          isExcessPricing: state.isExcessPricing,
          useExpressRates: state.serviceLevel == ServiceLevel.express,
          leftPaneWidthFraction: 0.4,
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            GhostButton(
              label: 'Add route',
              onTap: () => bloc.add(const RouteAdded()),
            ),
            // Excess/Minimum Excess is locked to a base bracket + one
            // uncapped Excess tier — no arbitrary 3rd+ tier to add.
            if (!state.isExcessPricing) ...[
              const SizedBox(width: 12),
              GhostButton(
                label: 'Add breakweight',
                onTap: () => bloc.add(const BreakweightAdded()),
              ),
            ],
          ],
        ),
        if (state.requiresMinimumCharge) ...[
          const SizedBox(height: 12),
          Text(
            'For ${state.pricingOption.label}, enter the first breakweight bracket\'s rate above as a '
            'flat peso amount, not per-kg — it\'s charged as-is whenever the shipment falls within that bracket.',
            style: TextStyle(fontSize: 12, color: context.colors.textMuted),
          ),
        ],
      ],
    );
  }
}

class _MiniButton extends StatelessWidget {
  const _MiniButton({required this.label, required this.icon});

  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return ShadButton(
      backgroundColor: context.colors.primaryChipBg,
      hoverBackgroundColor: context.colors.primaryBorder,
      foregroundColor: context.colors.primaryDeep,
      leading: Icon(icon, size: 15, color: context.colors.primaryDeep),
      onPressed: () {},
      child: Text(label),
    );
  }
}

class _MatrixTab extends StatelessWidget {
  const _MatrixTab({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: selected ? context.colors.primary : Colors.transparent,
                width: 2,
              ),
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: selected
                  ? context.colors.textBody
                  : context.colors.textMuted,
            ),
          ),
        ),
      ),
    );
  }
}
