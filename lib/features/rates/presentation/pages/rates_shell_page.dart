import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../../../core/di/injection_container.dart';
import '../../../../core/utils/breakpoints.dart';
import '../../../clients/data/repositories/clients_repository.dart';
import '../../data/repositories/rates_repository.dart';
import '../../domain/entities/rates_enums.dart';
import '../bloc/rates_shell_bloc.dart';
import '../widgets/create_rate_wizard/wizard_page.dart';
import '../widgets/custom_client_rates_view.dart';
import '../widgets/custom_clients_view.dart';
import '../widgets/dashboard_view.dart';
import '../widgets/new_rate_modal.dart';
import '../widgets/rates_sidebar.dart';
import '../widgets/shipping_calculator/shipping_calculator_clients_view.dart';
import '../widgets/shipping_calculator/shipping_calculator_form_view.dart';
import '../rates_colors.dart';

class RatesShellPage extends StatelessWidget {
  const RatesShellPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => RatesShellBloc(getIt<RatesRepository>(), getIt<ClientsRepository>())..add(const RatesDataRequested()),
      child: const _RatesShellView(),
    );
  }
}

class _RatesShellView extends StatelessWidget {
  const _RatesShellView();

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
          if (context.mounted) context.read<RatesShellBloc>().add(const NewRateModalClosed());
        });
      });
    }

    final isMobile = Breakpoints.isMobile(context);
    final content = switch (state.view) {
      RatesView.dashboard => const DashboardView(),
      RatesView.customClients => const CustomClientsView(),
      RatesView.customClientRates => const CustomClientRatesView(),
      RatesView.create => WizardPage(
          key: ValueKey('wizard-${state.rateChoice}-${state.selectedClientId}'),
          isCustom: state.rateChoice == RateType.custom,
        ),
      RatesView.shippingCalculatorClients => const ShippingCalculatorClientsView(),
      RatesView.shippingCalculatorForm => ShippingCalculatorFormView(
          key: ValueKey('shipping-calc-${state.selectedCalcClientId}'),
        ),
    };

    if (isMobile) {
      return Scaffold(
        backgroundColor: context.colors.pageBg,
        drawer: const Drawer(width: 272, child: RatesSidebar()),
        appBar: AppBar(
          backgroundColor: RatesColors.dark.sidebarBg,
          foregroundColor: Colors.white,
          title: const Text('CERRO RATRIX', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
        ),
        body: content,
      );
    }

    return Scaffold(
      backgroundColor: context.colors.pageBg,
      body: Row(
        children: [
          const RatesSidebar(),
          Expanded(child: content),
        ],
      ),
    );
  }
}
