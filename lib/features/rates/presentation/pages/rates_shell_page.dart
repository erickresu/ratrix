import 'package:flutter/material.dart';
import 'package:flutter_advanced_drawer/flutter_advanced_drawer.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:showcaseview/showcaseview.dart';

import '../../../../core/api/local_storage_service.dart';
import '../../../../core/di/injection_container.dart';
import '../../../clients/data/repositories/clients_repository.dart';
import '../../data/repositories/rates_repository.dart';
import '../../domain/entities/rates_enums.dart';
import '../bloc/rates_shell_bloc.dart';
import '../bloc/shipping_calculator_bloc.dart';
import '../widgets/audit_trail_view.dart';
import '../widgets/create_rate_wizard/wizard_page.dart';
import '../widgets/custom_client_rates_view.dart';
import '../widgets/custom_clients_view.dart';
import '../widgets/dashboard_view.dart';
import '../widgets/tutorial/app_tour.dart';
import '../widgets/new_rate_modal.dart';
import '../widgets/published_rates_view.dart';
import '../widgets/rates_sidebar.dart';
import '../widgets/shipping_calculator/shipping_calculator_clients_view.dart';
import '../widgets/shipping_calculator/shipping_calculator_form_view.dart';
import '../rates_colors.dart';

class RatesShellPage extends StatelessWidget {
  const RatesShellPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          RatesShellBloc(getIt<RatesRepository>(), getIt<ClientsRepository>())
            ..add(const RatesDataRequested()),
      // Wraps sidebar + dashboard + wizard — the one stable ancestor every
      // `tourShowcase`-wrapped target (across all three) shares, and where
      // `AppTour` drives the whole cross-screen sequence from.
      child: ShowCaseWidget(
        onComplete: (_, key) => AppTour.active?.handleStepComplete(key),
        onFinish: () => AppTour.active?.handleSequenceFinished(),
        // showcaseview nudges its tooltip back and forth on a loop by
        // default (its "moving animation" forwards then reverses forever,
        // meant to draw the eye) — reads as the whole card bouncing
        // continuously. Off, since every step already gets attention from
        // the dim overlay + spotlight cutout.
        disableMovingAnimation: true,
        builder: (_) => const _RatesShellView(),
      ),
    );
  }
}

class _RatesShellView extends StatefulWidget {
  const _RatesShellView();

  @override
  State<_RatesShellView> createState() => _RatesShellViewState();
}

class _RatesShellViewState extends State<_RatesShellView> {
  final _drawerController = AdvancedDrawerController(
    AdvancedDrawerValue.visible(),
  );

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _startTour());
  }

  /// Starts the full walkthrough from the beginning — used both for the
  /// automatic first-visit trigger and the sidebar/dashboard's manual
  /// "replay" entry point. Drives the real dashboard, sidebar, and wizard
  /// screens directly (via `showcaseview`), auto-navigating between them
  /// as the tour progresses — see `AppTour`.
  void _startTour() {
    // TODO: re-enable the seen-check (readOnboardingSeen) once the tour
    // is confirmed solid — always showing for now so it's retestable every
    // login without clearing storage.
    if (!mounted) return;
    final storage = getIt<LocalStorageService>();
    AppTour(
      shellContext: context,
      onFinish: storage.writeOnboardingSeen,
    ).show(context);
  }

  @override
  void dispose() {
    _drawerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<RatesShellBloc>().state;

    if (state.modalOpen) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!context.mounted) return;
        showShadDialog<void>(
          context: context,
          builder: (_) => BlocProvider.value(
            value: context.read<RatesShellBloc>(),
            child: const NewRateModal(),
          ),
        ).then((_) {
          if (context.mounted) {
            context.read<RatesShellBloc>().add(const NewRateModalClosed());
          }
        });
      });
    }

    final content = switch (state.view) {
      RatesView.dashboard => DashboardView(onReplayTour: _startTour),
      RatesView.customClients => const CustomClientsView(),
      RatesView.customClientRates => const CustomClientRatesView(),
      RatesView.publishedRates => const PublishedRatesView(),
      RatesView.create => WizardPage(
        key: ValueKey('wizard-${state.rateChoice}-${state.selectedClientId}'),
        isCustom: state.rateChoice == RateType.custom,
      ),
      RatesView.shippingCalculatorClients =>
        const ShippingCalculatorClientsView(),
      RatesView.shippingCalculatorForm => const ShippingCalculatorFormView(),
      RatesView.auditTrail => const AuditTrailView(),
    };

    // Same collapsible `AdvancedDrawer` at every width now (previously
    // desktop skipped it entirely for an always-visible inline `Row`
    // sidebar). `openRatio` is derived from the viewport so the revealed
    // drawer is always ~272px regardless of how wide the window is — a flat
    // ratio works for phones but would blow out to 600px+ on desktop.
    final screenWidth = MediaQuery.sizeOf(context).width;
    final openRatio = (272 / screenWidth).clamp(0.05, 0.95);

    final shell = AdvancedDrawer(
      controller: _drawerController,
      backdropColor: RatesColors.dark.sidebarBg,
      openRatio: openRatio,
      animationDuration: const Duration(milliseconds: 250),
      // Close on nav tap — leaving it open meant the backdrop kept
      // covering the freshly-switched page, making it look like the
      // click did nothing until the drawer was closed separately.
      drawer: SafeArea(
        child: RatesSidebar(
          onNavigated: _drawerController.hideDrawer,
          onReplayTour: _startTour,
        ),
      ),
      child: Scaffold(
        backgroundColor: context.colors.pageBg,
        appBar: AppBar(
          backgroundColor: RatesColors.dark.sidebarBg,
          foregroundColor: Colors.white,
          // FlexColorScheme's generated `appBarTheme.iconTheme` outranks
          // a local `foregroundColor` (widget.iconTheme ??
          // appBarTheme.iconTheme is resolved before foregroundColor is
          // even considered) — in light mode that computes a dark icon,
          // invisible against this bar's always-dark background. Set
          // iconTheme directly here so it wins over both.
          iconTheme: const IconThemeData(color: Colors.white),
          leading: IconButton(
            onPressed: _drawerController.toggleDrawer,
            icon: ValueListenableBuilder<AdvancedDrawerValue>(
              valueListenable: _drawerController,
              builder: (_, value, _) => AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: Icon(
                  value.visible ? Icons.clear : Icons.menu,
                  key: ValueKey(value.visible),
                ),
              ),
            ),
          ),
        ),
        body: content,
      ),
    );

    // Provided above the `content` switch (not inside
    // `ShippingCalculatorFormView` itself) so it survives navigating away
    // and back — e.g. tapping "Edit this rate" from the calculator jumps to
    // RatesView.create, which fully unmounts `content`'s previous subtree;
    // without this, everything the user typed (route, weight, dimensions,
    // declared value) would reset to blank on return. Keyed on the client
    // id so switching to a *different* calculator client still starts
    // fresh, and skipped entirely once no calculator client is selected.
    final calcClientId = state.selectedCalcClientId;
    if (calcClientId == null) return shell;
    return BlocProvider<ShippingCalculatorBloc>(
      key: ValueKey('calc-bloc-$calcClientId'),
      create: (_) => ShippingCalculatorBloc(
        getIt<RatesRepository>(),
        clientId: calcClientId,
      ),
      child: shell,
    );
  }
}
