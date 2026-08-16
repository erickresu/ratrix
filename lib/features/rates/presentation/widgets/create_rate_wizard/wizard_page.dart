import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
// ignore: unnecessary_import
import 'package:intl/intl.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../bloc/rate_wizard_bloc.dart';
import '../../bloc/rates_shell_bloc.dart';
import '../../rates_colors.dart';
import '../back_pill.dart';
import 'remove_route_dialog.dart';
import 'step0_rate_setup.dart';
import 'step1_rate_matrix.dart';
import 'step2_addons.dart';
import 'step3_conditional_addons.dart';
import 'step_rail.dart';

class WizardPage extends StatelessWidget {
  const WizardPage({super.key, required this.isCustom});

  final bool isCustom;

  @override
  Widget build(BuildContext context) {
    final selectedClient = context.read<RatesShellBloc>().state.selectedClient;

    return BlocProvider(
      create: (_) => RateWizardBloc(
        isCustom: isCustom,
        clientId: selectedClient?.id,
        clientName: selectedClient?.name,
      ),
      child: const _WizardView(),
    );
  }
}

class _WizardView extends StatelessWidget {
  const _WizardView();

  @override
  Widget build(BuildContext context) {
    return BlocListener<RateWizardBloc, RateWizardState>(
      listenWhen: (prev, curr) => prev.removeRouteIndex != curr.removeRouteIndex && curr.removeRouteIndex != null,
      listener: (context, state) async {
        final bloc = context.read<RateWizardBloc>();
        final confirmed = await showShadDialog<bool>(context: context, builder: (_) => const RemoveRouteDialog());
        if (!context.mounted) return;
        if (confirmed == true) {
          bloc.add(const RouteRemoveConfirmed());
        } else {
          bloc.add(const RouteRemoveCancelled());
        }
      },
      child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(40, 40, 40, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const _WizardHeader(),
                  const SizedBox(height: 28),
                  const _RateValidityCard(),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Builder(builder: (context) {
                        final step = context.select((RateWizardBloc b) => b.state.step);
                        final bloc = context.read<RateWizardBloc>();
                        return StepRail(currentStep: step, onStepTap: (s) => bloc.add(WizardStepChanged(s)));
                      }),
                      const SizedBox(width: 40),
                      const Expanded(child: _StepContent()),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const _WizardFooter(),
        ],
      ),
    );
  }
}

class _WizardHeader extends StatelessWidget {
  const _WizardHeader();

  @override
  Widget build(BuildContext context) {
    final wizardState = context.watch<RateWizardBloc>().state;
    final shellBloc = context.read<RatesShellBloc>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (wizardState.isCustom) ...[
          BackPill(
            label: 'Back to ${wizardState.clientName ?? 'Client'} Custom Rates',
            onTap: () => shellBloc.add(const ClientRatesBackRequested()),
          ),
          const SizedBox(height: 12),
        ],
        Row(
          children: [
            Text(
              wizardState.isCustom ? 'Create New Custom Rate' : 'New rate',
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700, letterSpacing: -0.2, color: RatesColors.textBody),
            ),
            if (wizardState.isCustom && wizardState.clientName != null) ...[
              const SizedBox(width: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: RatesColors.surfaceMuted, borderRadius: BorderRadius.circular(6)),
                child: Text(wizardState.clientName!, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: RatesColors.textMutedStrong)),
              ),
            ],
          ],
        ),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(color: RatesColors.primaryChipBg, borderRadius: BorderRadius.circular(6)),
          child: Text('${wizardState.freightMode.label.toUpperCase()} FREIGHT', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: RatesColors.primaryDeep, letterSpacing: 0.3)),
        ),
      ],
    );
  }
}

class _RateValidityCard extends StatelessWidget {
  const _RateValidityCard();

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<RateWizardBloc>();
    final state = context.watch<RateWizardBloc>().state;
    if (!state.isCustom) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(bottom: 28),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        decoration: BoxDecoration(
          color: RatesColors.surface,
          border: Border.all(color: RatesColors.border),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Rate Validity', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: RatesColors.textBody)),
            const SizedBox(height: 2),
            const Text('Set the date when this rate becomes invalid for the client', style: TextStyle(fontSize: 13, color: RatesColors.textMuted)),
            const SizedBox(height: 14),
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
                  const SizedBox(height: 8),
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
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                        decoration: BoxDecoration(border: Border.all(color: RatesColors.borderStrong), borderRadius: BorderRadius.circular(8), color: RatesColors.surfaceSubtle),
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
          ],
        ),
      ),
    );
  }
}

class _StepContent extends StatelessWidget {
  const _StepContent();

  @override
  Widget build(BuildContext context) {
    final state = context.watch<RateWizardBloc>().state;

    const stepLabels = ['Rate Setup', 'Rate Matrix', 'Add-ons', 'Conditional Add-ons'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Step ${state.step + 1} of 4', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: RatesColors.primary, letterSpacing: 0.6)),
        const SizedBox(height: 4),
        Text(stepLabels[state.step], style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w700, letterSpacing: -0.2, color: RatesColors.textBody)),
        const SizedBox(height: 28),
        switch (state.step) {
          0 => const Step0RateSetup(),
          1 => const Step1RateMatrix(),
          2 => const Step2Addons(),
          _ => const Step3ConditionalAddons(),
        },
      ],
    );
  }
}

class _WizardFooter extends StatelessWidget {
  const _WizardFooter();

  @override
  Widget build(BuildContext context) {
    final wizardBloc = context.read<RateWizardBloc>();
    final shellBloc = context.read<RatesShellBloc>();
    final step = context.select((RateWizardBloc b) => b.state.step);

    return Container(
      padding: const EdgeInsets.fromLTRB(40, 16, 40, 16),
      decoration: const BoxDecoration(
        color: RatesColors.surface,
        border: Border(top: BorderSide(color: RatesColors.border)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (step > 0)
            ShadButton.outline(onPressed: () => wizardBloc.add(const WizardBackStepRequested()), child: const Text('Back'))
          else
            const SizedBox.shrink(),
          Row(
            children: [
              ShadButton.outline(
                onPressed: () {
                  if (step < 3) {
                    wizardBloc.add(const WizardNextStepRequested());
                  } else {
                    shellBloc.add(const RatesHomeRequested());
                  }
                },
                child: Text(step == 3 ? 'Publish Rate' : 'Next'),
              ),
              const SizedBox(width: 10),
              ShadButton(
                backgroundColor: RatesColors.primary,
                onPressed: () => shellBloc.add(const RatesHomeRequested()),
                child: const Text('Save Changes'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
