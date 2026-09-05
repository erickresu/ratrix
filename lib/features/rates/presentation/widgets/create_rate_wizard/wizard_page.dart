import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../../../../core/di/injection_container.dart';
import '../../../../../core/utils/breakpoints.dart';
import '../../../../../core/widgets/page_padding.dart';
import '../../../data/repositories/rates_repository.dart';
import '../../../domain/entities/rates_enums.dart';
import '../../bloc/rate_wizard_bloc.dart';
import '../../bloc/rates_shell_bloc.dart';
import '../../rates_colors.dart';
import '../back_pill.dart';
import '../status_toast.dart';
import '../tutorial/app_tour.dart';
import '../tutorial/tour_keys.dart';
import '../tutorial/tour_step_card.dart';
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
    final shellState = context.read<RatesShellBloc>().state;
    final selectedClient = shellState.selectedClient;
    final existingRate = shellState.existingRate;

    return BlocProvider(
      create: (_) => RateWizardBloc(
        isCustom: isCustom,
        ratesRepository: getIt<RatesRepository>(),
        clientId: selectedClient?.id,
        clientName: selectedClient?.name,
        existingRate: existingRate,
      ),
      child: const _WizardView(),
    );
  }
}

class _WizardView extends StatelessWidget {
  const _WizardView();

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<RateWizardBloc, RateWizardState>(
          listenWhen: (prev, curr) =>
              prev.removeRouteIndex != curr.removeRouteIndex &&
              curr.removeRouteIndex != null,
          listener: (context, state) async {
            final bloc = context.read<RateWizardBloc>();
            final confirmed = await showShadDialog<bool>(
              context: context,
              builder: (_) => const RemoveRouteDialog(),
            );
            if (!context.mounted) return;
            if (confirmed == true) {
              bloc.add(const RouteRemoveConfirmed());
            } else {
              bloc.add(const RouteRemoveCancelled());
            }
          },
        ),
        BlocListener<RateWizardBloc, RateWizardState>(
          listenWhen: (prev, curr) =>
              prev.submitError != curr.submitError ||
              prev.submitSucceeded != curr.submitSucceeded,
          listener: (context, state) {
            if (state.submitError != null) {
              showStatusToast(
                context,
                title: 'Something went wrong',
                description: state.submitError,
                isError: true,
              );
            } else if (state.submitSucceeded) {
              // The API's success response is just the raw saved rate — no
              // message field at all — so the toast surfaces its real
              // charge_code rather than a made-up generic string.
              final chargeCode = state.savedChargeCode;
              final shellBloc = context.read<RatesShellBloc>();
              final wizardState = context.read<RateWizardBloc>().state;
              // `RatesDataRequested` refreshes the dashboard/Published Rates
              // list, but a custom rate's own client rate list
              // (`selectedClientRates`) is only ever loaded via
              // `ClientRatesRequested` — without also firing it here, saving
              // an edit to a custom rate (e.g. a breakweight tier) would
              // report success but the Custom Client Rates table would keep
              // showing the pre-edit values until some unrelated action
              // happened to refetch it.
              final clientId = wizardState.clientId;
              if (wizardState.isCustom && clientId != null) {
                shellBloc.add(ClientRatesRequested(clientId));
              }
              if (state.lastSubmitStayedOnPage) {
                showStatusToast(
                  context,
                  title: chargeCode != null
                      ? 'Saved $chargeCode'
                      : 'Changes saved',
                );
                // The rate list screens don't live-update — without this,
                // the just-saved changes stay invisible there until some
                // other action happens to trigger a refetch.
                shellBloc.add(const RatesDataRequested());
              } else {
                final isEditing = wizardState.editingRateId != null;
                showStatusToast(
                  context,
                  title: chargeCode == null
                      ? (isEditing ? 'Rate updated' : 'Rate created')
                      : (isEditing
                            ? 'Updated $chargeCode'
                            : 'Created $chargeCode'),
                );
                shellBloc.add(
                  WizardExitRequested(
                    // Land back on the client's own rate list, not the
                    // dashboard — otherwise the rate they just created is
                    // never actually shown to them.
                    fallback: wizardState.isCustom
                        ? RatesView.customClientRates
                        : RatesView.publishedRates,
                  ),
                );
                shellBloc.add(const RatesDataRequested());
              }
            }
          },
        ),
      ],
      child: Column(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                gradient: context.colors.wizardBgGradient,
              ),
              child: Builder(
                builder: (context) {
                  final isMobile = Breakpoints.isMobile(context);
                  return SingleChildScrollView(
                    child: PagePadding(
                      top: 48,
                      bottom: 40,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const _WizardHeader(),
                          const SizedBox(height: 32),
                          isMobile
                              ? const _StepContent()
                              : Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Builder(
                                      builder: (context) {
                                        final step = context.select(
                                          (RateWizardBloc b) => b.state.step,
                                        );
                                        final bloc = context
                                            .read<RateWizardBloc>();
                                        return StepRail(
                                          currentStep: step,
                                          onStepTap: (s) =>
                                              bloc.add(WizardStepChanged(s)),
                                        );
                                      },
                                    ),
                                    const SizedBox(width: 48),
                                    const Expanded(child: _StepContent()),
                                  ],
                                ),
                        ],
                      ),
                    ),
                  );
                },
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
    final isEditing = wizardState.editingRateId != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        BackPill(
          onTap: () => shellBloc.add(
            WizardExitRequested(
              fallback: wizardState.isCustom
                  ? RatesView.customClientRates
                  : RatesView.publishedRates,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Text(
              isEditing
                  ? (wizardState.isCustom ? 'Edit Custom Rate' : 'Edit Rate')
                  : (wizardState.isCustom
                        ? 'Create New Custom Rate'
                        : 'New rate'),
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.2,
                color: context.colors.textBody,
              ),
            ),
            if (wizardState.isCustom && wizardState.clientName != null) ...[
              const SizedBox(width: 10),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: context.colors.surfaceMuted,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  wizardState.clientName!,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: context.colors.textMutedStrong,
                  ),
                ),
              ),
            ],
          ],
        ),
        if (wizardState.freightMode != null) ...[
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: context.colors.primaryChipBg,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              '${wizardState.freightMode!.label.toUpperCase()} FREIGHT',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: context.colors.primaryDeep,
                letterSpacing: 0.3,
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _StepContent extends StatelessWidget {
  const _StepContent();

  static const _stepCopy = [
    (
      title: 'Chapter 1: Rate Setup',
      body:
          'Every rate starts with the basics — freight mode, service mode, '
          'and an expiry date if this deal only holds for a while.',
    ),
    (
      title: 'Chapter 2: Rate Matrix',
      body:
          'Now the money part — which route, and what it costs at each '
          'weight bracket. Add as many routes and brackets as needed.',
    ),
    (
      title: 'Chapter 3: Add-ons',
      body:
          'Real shipments carry more than base freight — fuel surcharge, '
          'insurance, documentation fees. Anything that applies here.',
    ),
    (
      title: 'Chapter 4: Conditional Add-ons',
      body:
          "Last stop — charges that only kick in sometimes, like ODA for a "
          "hard-to-reach destination. Set these up, and a rate's ready to "
          'publish!',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final state = context.watch<RateWizardBloc>().state;

    // The wizard tour drives this step's advancement from outside the
    // wizard's own BlocProvider subtree (see `AppTour`) — hand it a live
    // reference to this bloc on every build while a tour is active, so it
    // can dispatch `TourStepChanged` without needing to be an ancestor.
    AppTour.active?.registerWizardBloc(context.read<RateWizardBloc>());

    const stepLabels = [
      'Rate Setup',
      'Rate Matrix',
      'Add-ons',
      'Conditional Add-ons',
    ];

    final copy = _stepCopy[state.step];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Step ${state.step + 1} of 4',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: context.colors.primary,
            letterSpacing: 0.6,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          stepLabels[state.step],
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.2,
            color: context.colors.textBody,
          ),
        ),
        const SizedBox(height: 32),
        tourShowcase(
          context: context,
          key: TourKeys.wizardStepFor(state.step).first,
          title: copy.title,
          body: copy.body,
          isLast: state.step == 3,
          targetPadding: const EdgeInsets.all(2),
          child: switch (state.step) {
            0 => const Step0RateSetup(),
            1 => const Step1RateMatrix(),
            2 => const Step2Addons(),
            _ => const Step3ConditionalAddons(),
          },
        ),
      ],
    );
  }
}

class _WizardFooter extends StatelessWidget {
  const _WizardFooter();

  @override
  Widget build(BuildContext context) {
    final wizardBloc = context.read<RateWizardBloc>();
    final step = context.select((RateWizardBloc b) => b.state.step);
    final isSubmitting = context.select(
      (RateWizardBloc b) => b.state.isSubmitting,
    );
    final isEditing = context.select(
      (RateWizardBloc b) => b.state.editingRateId != null,
    );
    final canLeaveStep0 = context.select(
      (RateWizardBloc b) => b.state.canLeaveStep0,
    );
    final canLeaveStep1 = context.select(
      (RateWizardBloc b) => b.state.canLeaveStep1,
    );
    final isCustom = context.select((RateWizardBloc b) => b.state.isCustom);
    final isMobile = Breakpoints.isMobile(context);
    final blockedByFreightMode = step == 0 && !canLeaveStep0;
    final blockedByBreakweights = step == 1 && !canLeaveStep1;

    final nextButton = ShadButton(
      backgroundColor: step == 3
          ? context.colors.accent
          : context.colors.primary,
      hoverBackgroundColor: step == 3
          ? context.colors.accentHover
          : context.colors.primaryHover,
      leading: step == 3
          ? (isSubmitting
                ? const SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Icon(CupertinoIcons.paperplane_fill, size: 16))
          : null,
      trailing: step == 3
          ? null
          : const Icon(CupertinoIcons.arrow_right, size: 16),
      onPressed:
          (step == 3 && isSubmitting) ||
              blockedByFreightMode ||
              blockedByBreakweights
          ? null
          : () {
              if (step < 3) {
                wizardBloc.add(const WizardNextStepRequested());
              } else {
                wizardBloc.add(const RateSubmitRequested());
              }
            },
      child: Text(
        step == 3 ? (isSubmitting ? 'Publishing...' : 'Publish Rate') : 'Next',
      ),
    );

    final saveChangesButton = ShadButton.outline(
      leading: isSubmitting
          ? const SizedBox(
              width: 14,
              height: 14,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : const Icon(CupertinoIcons.checkmark_alt, size: 15),
      onPressed: isSubmitting
          ? null
          : () => wizardBloc.add(const RateSubmitRequested(stayOnPage: true)),
      child: Text(isSubmitting ? 'Saving...' : 'Save changes'),
    );

    final trailingButtons = isEditing && step < 3
        ? [saveChangesButton, nextButton]
        : [nextButton];

    // Step 0's "Back" exits the wizard entirely instead of stepping
    // backward (there's no earlier step to go to) — without this, the only
    // way out was the small header pill, and pressing this same-looking
    // footer button read as broken since it visibly did nothing.
    final exitButton = ShadButton.outline(
      leading: const Icon(CupertinoIcons.chevron_left, size: 15),
      onPressed: () => context.read<RatesShellBloc>().add(
        WizardExitRequested(
          fallback: isCustom
              ? RatesView.customClientRates
              : RatesView.publishedRates,
        ),
      ),
      child: const Text('Back'),
    );

    final leading = step > 0
        ? ShadButton.outline(
            leading: const Icon(CupertinoIcons.chevron_left, size: 15),
            onPressed: () => wizardBloc.add(const WizardBackStepRequested()),
            child: const Text('Back'),
          )
        : blockedByFreightMode
        ? Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              exitButton,
              const SizedBox(width: 12),
              Icon(
                CupertinoIcons.info_circle,
                size: 14,
                color: context.colors.textMuted,
              ),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  'Select a freight mode to continue',
                  style: TextStyle(
                    fontSize: 13,
                    color: context.colors.textMuted,
                  ),
                ),
              ),
            ],
          )
        : exitButton;

    return Container(
      decoration: BoxDecoration(
        color: context.colors.surface,
        border: Border(top: BorderSide(color: context.colors.border)),
      ),
      child: PagePadding(
        top: 24,
        bottom: 24,
        child: isMobile
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Primary action (Next/Publish) on top, Save changes below
                  // it — reverse of trailingButtons' desktop left-to-right
                  // order, since the most important action reads first when
                  // stacked.
                  for (final button in trailingButtons.reversed)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: SizedBox(width: double.infinity, child: button),
                    ),
                  // Always shown now — step 0 renders a real exit button
                  // instead of nothing, so there's no longer a case where
                  // `leading` is an empty SizedBox worth skipping.
                  leading,
                ],
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  leading,
                  Row(
                    children: [
                      for (final button in trailingButtons) ...[
                        button,
                        if (button != trailingButtons.last)
                          const SizedBox(width: 12),
                      ],
                    ],
                  ),
                ],
              ),
      ),
    );
  }
}
