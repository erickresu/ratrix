import 'package:flutter/material.dart';
import 'package:flutter_advanced_drawer/flutter_advanced_drawer.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../../../core/di/injection_container.dart';
import '../../../clients/data/repositories/clients_repository.dart';
import '../../data/repositories/rates_repository.dart';
import '../../domain/entities/rates_enums.dart';
import '../bloc/rates_shell_bloc.dart';
import '../widgets/audit_trail_view.dart';
import '../widgets/create_rate_wizard/wizard_page.dart';
import '../widgets/custom_client_rates_view.dart';
import '../widgets/custom_clients_view.dart';
import '../widgets/dashboard_view.dart';
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
      child: const _RatesShellView(),
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
          if (context.mounted)
            context.read<RatesShellBloc>().add(const NewRateModalClosed());
        });
      });
    }

    final content = switch (state.view) {
      RatesView.dashboard => const DashboardView(),
      RatesView.customClients => const CustomClientsView(),
      RatesView.customClientRates => const CustomClientRatesView(),
      RatesView.publishedRates => const PublishedRatesView(),
      RatesView.create => WizardPage(
        key: ValueKey('wizard-${state.rateChoice}-${state.selectedClientId}'),
        isCustom: state.rateChoice == RateType.custom,
      ),
      RatesView.shippingCalculatorClients =>
        const ShippingCalculatorClientsView(),
      RatesView.shippingCalculatorForm => ShippingCalculatorFormView(
        key: ValueKey('shipping-calc-${state.selectedCalcClientId}'),
      ),
      RatesView.auditTrail => const AuditTrailView(),
    };

    // Same collapsible `AdvancedDrawer` at every width now (previously
    // desktop skipped it entirely for an always-visible inline `Row`
    // sidebar). `openRatio` is derived from the viewport so the revealed
    // drawer is always ~272px regardless of how wide the window is — a flat
    // ratio works for phones but would blow out to 600px+ on desktop.
    final screenWidth = MediaQuery.sizeOf(context).width;
    final openRatio = (272 / screenWidth).clamp(0.05, 0.95);

    return AdvancedDrawer(
      controller: _drawerController,
      backdropColor: RatesColors.dark.sidebarBg,
      openRatio: openRatio,
      animationDuration: const Duration(milliseconds: 250),
      // Close on nav tap — leaving it open meant the backdrop kept
      // covering the freshly-switched page, making it look like the
      // click did nothing until the drawer was closed separately.
      drawer: SafeArea(
        child: RatesSidebar(onNavigated: _drawerController.hideDrawer),
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
          // When the drawer is collapsed there's otherwise zero brand
          // identity left on screen, just the toggle.
          title: const Text(
            'CERRO RATRIX',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.4,
            ),
          ),
          centerTitle: false,
        ),
        body: content,
      ),
    );
  }
}
