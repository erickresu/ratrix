import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../../../../core/di/injection_container.dart';
import '../../../../../core/services/ph_locations_service.dart';
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
        phLocationsService: getIt<PhLocationsService>(),
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
            child: Container(
              decoration: BoxDecoration(gradient: context.colors.wizardBgGradient),
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(48, 40, 48, 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const _WizardHeader(),
                    const SizedBox(height: 32),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Builder(builder: (context) {
                          final step = context.select((RateWizardBloc b) => b.state.step);
                          final bloc = context.read<RateWizardBloc>();
                          return StepRail(currentStep: step, onStepTap: (s) => bloc.add(WizardStepChanged(s)));
                        }),
                        const SizedBox(width: 48),
                        const Expanded(child: _StepContent()),
                      ],
                    ),
                  ],
                ),
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
          BackPill(onTap: () => shellBloc.add(const ClientRatesBackRequested())),
          const SizedBox(height: 12),
        ],
        Row(
          children: [
            Text(
              wizardState.isCustom ? 'Create New Custom Rate' : 'New rate',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, letterSpacing: -0.2, color: context.colors.textBody),
            ),
            if (wizardState.isCustom && wizardState.clientName != null) ...[
              const SizedBox(width: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: context.colors.surfaceMuted, borderRadius: BorderRadius.circular(6)),
                child: Text(wizardState.clientName!, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: context.colors.textMutedStrong)),
              ),
            ],
          ],
        ),
        if (wizardState.freightMode != null) ...[
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(color: context.colors.primaryChipBg, borderRadius: BorderRadius.circular(6)),
            child: Text('${wizardState.freightMode!.label.toUpperCase()} FREIGHT', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: context.colors.primaryDeep, letterSpacing: 0.3)),
          ),
        ],
      ],
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
        Text('Step ${state.step + 1} of 4', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: context.colors.primary, letterSpacing: 0.6)),
        const SizedBox(height: 4),
        Text(stepLabels[state.step], style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700, letterSpacing: -0.2, color: context.colors.textBody)),
        const SizedBox(height: 32),
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
      padding: const EdgeInsets.fromLTRB(48, 20, 48, 20),
      decoration: BoxDecoration(
        color: context.colors.surface,
        border: Border(top: BorderSide(color: context.colors.border)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (step > 0)
            ShadButton.outline(
              leading: const Icon(CupertinoIcons.chevron_left, size: 15),
              onPressed: () => wizardBloc.add(const WizardBackStepRequested()),
              child: const Text('Back'),
            )
          else
            const SizedBox.shrink(),
          Row(
            children: [
              ShadButton(
                gradient: step == 3 ? context.colors.accentButtonGradient : context.colors.primaryButtonGradient,
                leading: Icon(step == 3 ? CupertinoIcons.paperplane_fill : null, size: 16),
                trailing: step == 3 ? null : const Icon(CupertinoIcons.arrow_right, size: 16),
                onPressed: () {
                  if (step < 3) {
                    wizardBloc.add(const WizardNextStepRequested());
                  } else {
                    shellBloc.add(const RatesHomeRequested());
                  }
                },
                child: Text(step == 3 ? 'Publish Rate' : 'Next'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
