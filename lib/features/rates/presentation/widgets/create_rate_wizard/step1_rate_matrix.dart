import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(color: RatesColors.primarySoftBg, borderRadius: BorderRadius.circular(14)),
          child: Row(
            children: [
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Bulk operations', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: RatesColors.textBody)),
                    SizedBox(height: 2),
                    Text('Download a template, or bulk import/export rate data', style: TextStyle(fontSize: 12, color: RatesColors.textMuted)),
                  ],
                ),
              ),
              _MiniButton(label: 'Download template', icon: CupertinoIcons.doc_text),
              const SizedBox(width: 8),
              _MiniButton(label: 'Import Excel', icon: CupertinoIcons.arrow_up_doc),
              const SizedBox(width: 8),
              _MiniButton(label: 'Export Excel', icon: CupertinoIcons.arrow_down_doc),
            ],
          ),
        ),
        const SizedBox(height: 28),
        Row(
          children: [
            _MatrixTab(label: 'Standard rates', selected: state.matrixTab == 'standard', onTap: () => bloc.add(const MatrixTabChanged('standard'))),
            const SizedBox(width: 24),
            _MatrixTab(label: 'Express rates', selected: state.matrixTab == 'express', onTap: () => bloc.add(const MatrixTabChanged('express'))),
          ],
        ),
        const Divider(height: 25, color: RatesColors.border),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('${state.matrixTab == 'standard' ? 'Standard' : 'Express'} rate markup', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: RatesColors.textBody)),
                  const SizedBox(height: 2),
                  const Text('Apply a percentage markup to all current rates. You can still edit individual rows after.', style: TextStyle(fontSize: 13, color: RatesColors.textMuted)),
                ],
              ),
            ),
            const SizedBox(width: 24),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(border: Border.all(color: RatesColors.borderStrong), borderRadius: BorderRadius.circular(10), color: RatesColors.surfaceSubtle),
              child: Row(
                children: [
                  SizedBox(
                    width: 60,
                    child: ShadInput(
                      placeholder: const Text('0.0'),
                      initialValue: state.markup,
                      textAlign: TextAlign.right,
                      decoration: const ShadDecoration(border: ShadBorder.none, focusedBorder: ShadBorder.none),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      onChanged: (v) => bloc.add(MarkupChanged(v)),
                    ),
                  ),
                  const Text('%', style: TextStyle(fontSize: 14, color: RatesColors.textMuted)),
                ],
              ),
            ),
            const SizedBox(width: 8),
            ShadButton(backgroundColor: RatesColors.primary, onPressed: () {}, child: const Text('Apply markup')),
          ],
        ),
        const SizedBox(height: 20),
        // "Match by" toggle hidden for the meantime (only City/Province are
        // wired up; defaults to LocationBasis.city). Re-enable when needed:
        // Row(
        //   children: [
        //     const Text('Match by:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: RatesColors.textMuted)),
        //     const SizedBox(width: 8),
        //     Container(
        //       padding: const EdgeInsets.all(2),
        //       decoration: BoxDecoration(color: RatesColors.surfaceMuted, borderRadius: BorderRadius.circular(6)),
        //       child: Row(
        //         children: [
        //           for (final basis in LocationBasis.enabledValues)
        //             _SegButton(label: basis.label, selected: state.locationBasis == basis, onTap: () => bloc.add(LocationBasisChanged(basis))),
        //         ],
        //       ),
        //     ),
        //   ],
        // ),
        // const SizedBox(height: 16),
        RateMatrixTable(
          matrixRows: state.matrixRows,
          breakweights: state.breakweights,
          originPlaceholder: 'Search origin ${state.locationBasis.label.toLowerCase()}...',
          destinationPlaceholder: 'Search destination ${state.locationBasis.label.toLowerCase()}...',
          locationOptions: state.locationSuggestions,
          onOriginChanged: (i, v) => bloc.add(OriginChanged(i, v)),
          onDestinationChanged: (i, v) => bloc.add(DestinationChanged(i, v)),
          onCellChanged: (i, bi, v) => bloc.add(CellChanged(i, bi, v)),
          onBreakweightMinChanged: (i, v) => bloc.add(BreakweightMinChanged(i, v)),
          onBreakweightMaxChanged: (i, v) => bloc.add(BreakweightMaxChanged(i, v)),
          onRemoveBreakweight: (i) => bloc.add(BreakweightRemoved(i)),
          onRemoveRoute: (i) => bloc.add(RouteRemoveRequested(i)),
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            _GhostButton(label: 'Add route', onTap: () => bloc.add(const RouteAdded())),
            const SizedBox(width: 12),
            _GhostButton(label: 'Add breakweight', onTap: () => bloc.add(const BreakweightAdded())),
          ],
        ),
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
      backgroundColor: RatesColors.primaryChipBg,
      hoverBackgroundColor: RatesColors.primaryBorder,
      foregroundColor: RatesColors.primaryDeep,
      leading: Icon(icon, size: 15, color: RatesColors.primaryDeep),
      onPressed: () {},
      child: Text(label),
    );
  }
}

class _MatrixTab extends StatelessWidget {
  const _MatrixTab({required this.label, required this.selected, required this.onTap});

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
          decoration: BoxDecoration(border: Border(bottom: BorderSide(color: selected ? RatesColors.primary : Colors.transparent, width: 2))),
          child: Text(label, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: selected ? RatesColors.textBody : RatesColors.textMuted)),
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
        borderRadius: BorderRadius.circular(10),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(border: Border.all(color: RatesColors.borderStrong, width: 1.5, style: BorderStyle.solid), borderRadius: BorderRadius.circular(10)),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(CupertinoIcons.add, size: 14, color: RatesColors.textMuted),
              const SizedBox(width: 6),
              Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: RatesColors.textMuted)),
            ],
          ),
        ),
      ),
    );
  }
}
