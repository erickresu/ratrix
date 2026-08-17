import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
// ignore: unnecessary_import
import 'package:intl/intl.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../../domain/entities/rates_enums.dart';
import '../../bloc/rate_wizard_bloc.dart';
import '../../rates_colors.dart';

const _fieldHeight = 44.0;

class Step0RateSetup extends StatelessWidget {
  const Step0RateSetup({super.key});

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<RateWizardBloc>();
    final state = context.watch<RateWizardBloc>().state;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Freight mode', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: RatesColors.textMutedStrong)),
        const SizedBox(height: 12),
        Row(
          children: [
            for (final mode in FreightMode.values) ...[
              Expanded(child: _FreightModeCard(mode: mode, selected: state.freightMode == mode, onTap: () => bloc.add(FreightModeChanged(mode)))),
              if (mode != FreightMode.values.last) const SizedBox(width: 12),
            ],
          ],
        ),
        const SizedBox(height: 28),
        if (state.isCustom) ...[
          SizedBox(
            width: 260,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text('Expiry Date ', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: RatesColors.textMutedStrong)),
                    const Text('*', style: TextStyle(fontSize: 13, color: RatesColors.destructive)),
                  ],
                ),
                const SizedBox(height: 12),
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(8),
                    onTap: () async {
                      final now = DateTime.now();
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: state.expiryDate ?? now,
                        firstDate: now,
                        lastDate: now.add(const Duration(days: 3650)),
                      );
                      if (picked != null) bloc.add(ExpiryDateChanged(picked));
                    },
                    child: Container(
                      height: _fieldHeight,
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      alignment: Alignment.centerLeft,
                      decoration: BoxDecoration(
                        border: Border.all(color: RatesColors.borderStrong),
                        borderRadius: BorderRadius.circular(8),
                        color: RatesColors.surface,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            state.expiryDate == null ? 'Select date' : DateFormat.yMMMd().format(state.expiryDate!),
                            style: TextStyle(fontSize: 14, color: state.expiryDate == null ? RatesColors.textMuted : RatesColors.textBody),
                          ),
                          const Icon(CupertinoIcons.calendar, size: 15, color: RatesColors.textMuted),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),
        ],
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Service mode', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: RatesColors.textMutedStrong)),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    height: _fieldHeight,
                    child: ShadSelect<ServiceMode>(
                      initialValue: state.serviceMode,
                      selectedOptionBuilder: (context, value) => Text(value.label),
                      onChanged: (value) {
                        if (value != null) bloc.add(ServiceModeChanged(value));
                      },
                      options: [for (final m in ServiceMode.values) ShadOption(value: m, child: Text(m.label))],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 32),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Charge basis', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: RatesColors.textMutedStrong)),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    height: _fieldHeight,
                    child: ShadSelect<ChargeBasis>(
                      initialValue: state.chargeBasis,
                      selectedOptionBuilder: (context, value) => Text(value.label),
                      onChanged: (value) {
                        if (value != null) bloc.add(ChargeBasisChanged(value));
                      },
                      options: [for (final b in ChargeBasis.values) ShadOption(value: b, child: Text(b.label))],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 28),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Pricing option', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: RatesColors.textMutedStrong)),
            const SizedBox(height: 12),
            ShadSelect<PricingOption>(
              initialValue: state.pricingOption,
              selectedOptionBuilder: (context, value) => Text(value.label),
              onChanged: (value) {
                if (value != null) bloc.add(PricingOptionChanged(value));
              },
              options: [for (final p in PricingOption.values) ShadOption(value: p, child: Text(p.label))],
            ),
          ],
        ),
        const SizedBox(height: 28),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text('Charge code name ', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: RatesColors.textMutedStrong)),
                const Text('(optional)', style: TextStyle(fontSize: 13, color: RatesColors.textMuted)),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    color: RatesColors.surfaceMuted,
                    border: Border.all(color: RatesColors.borderStrong),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(state.chargeCodePrefix, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, fontFamily: 'monospace', color: RatesColors.textMutedStrong)),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ShadInput(
                    placeholder: const Text('e.g. PUBLISH RATE'),
                    initialValue: state.chargeCodeSuffix,
                    style: const TextStyle(fontFamily: 'monospace'),
                    onChanged: (v) => bloc.add(ChargeCodeSuffixChanged(v)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}

const _freightModeIcons = {
  FreightMode.air: CupertinoIcons.airplane,
  FreightMode.land: CupertinoIcons.car_fill,
  // cupertino_icons has no ship/boat glyph — Material's is the closest match.
  FreightMode.sea: Icons.directions_boat_filled,
};

class _FreightModeCard extends StatelessWidget {
  const _FreightModeCard({required this.mode, required this.selected, required this.onTap});

  final FreightMode mode;
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
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          decoration: BoxDecoration(
            gradient: selected ? RatesColors.primaryButtonGradient : null,
            color: selected ? null : RatesColors.surfaceSubtle,
            border: Border.all(color: selected ? RatesColors.primary : RatesColors.border, width: selected ? 1.5 : 1),
            borderRadius: BorderRadius.circular(10),
            boxShadow: selected ? const [BoxShadow(color: RatesColors.shadowSoft, blurRadius: 12, offset: Offset(0, 3))] : null,
          ),
          child: Row(
            children: [
              Container(
                width: 56,
                height: 56,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: selected ? Colors.white.withValues(alpha: 0.2) : RatesColors.primaryChipBg,
                  shape: BoxShape.circle,
                ),
                child: Icon(_freightModeIcons[mode], size: 26, color: selected ? Colors.white : RatesColors.primaryDeep),
              ),
              const SizedBox(width: 12),
              Text(mode.label, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: selected ? Colors.white : RatesColors.textMutedStrong)),
              if (selected) ...[
                const Spacer(),
                const Icon(CupertinoIcons.check_mark_circled_solid, size: 16, color: Colors.white),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
