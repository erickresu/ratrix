import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../domain/entities/client_rate.dart';
import '../../domain/entities/rates_enums.dart';
import '../bloc/rates_shell_bloc.dart';
import '../rates_colors.dart';
import 'back_pill.dart';

class CustomClientRatesView extends StatelessWidget {
  const CustomClientRatesView({super.key});

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<RatesShellBloc>();
    final state = context.watch<RatesShellBloc>().state;
    final client = state.selectedClient;
    if (client == null) return const SizedBox.shrink();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(40, 40, 40, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              BackPill(label: 'All Clients', onTap: () => bloc.add(const ClientsBackRequested())),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 28),
                decoration: BoxDecoration(color: RatesColors.sidebarPanelBg, borderRadius: BorderRadius.circular(12)),
                child: Row(
                  children: [
                    Container(
                      width: 52,
                      height: 52,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(color: RatesColors.primary.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(12)),
                      child: Text(client.initials, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Color(0xFF6FE0C6))),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(client.name, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: Colors.white)),
                          const SizedBox(height: 2),
                          Text('${client.accountNumber} · ${client.email}', style: TextStyle(fontSize: 13, color: Colors.white.withValues(alpha: 0.55), fontFamily: 'monospace')),
                        ],
                      ),
                    ),
                    ShadButton(
                      backgroundColor: RatesColors.primary,
                      foregroundColor: const Color(0xFF0B1210),
                      leading: const Icon(CupertinoIcons.add, size: 17, color: Color(0xFF0B1210)),
                      onPressed: () => bloc.add(const CreateCustomRateForSelectedClientRequested()),
                      child: const Text('Create New Rate'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  _TabPill(label: 'Active', selected: state.clientRatesTab == RateStatus.active, onTap: () => bloc.add(const ClientRatesTabChanged(RateStatus.active))),
                  const SizedBox(width: 8),
                  _TabPill(label: 'Expired', selected: state.clientRatesTab == RateStatus.expired, onTap: () => bloc.add(const ClientRatesTabChanged(RateStatus.expired))),
                  const Spacer(),
                  SizedBox(
                    width: 320,
                    child: ShadInput(
                      placeholder: const Text('Search by charge code, freight mode...'),
                      onChanged: (v) => bloc.add(ClientRateSearchChanged(v)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(40, 0, 40, 40),
            child: state.filteredClientRates.isEmpty
                ? Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(40),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      border: Border.all(color: RatesColors.borderStrong, style: BorderStyle.solid),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      'No ${state.clientRatesTab.label.toLowerCase()} rates for this client.',
                      style: const TextStyle(fontSize: 14, color: RatesColors.textMuted),
                    ),
                  )
                : Column(
                    children: [
                      for (final rate in state.filteredClientRates) ...[
                        _ClientRateCard(rate: rate),
                        const SizedBox(height: 12),
                      ],
                    ],
                  ),
          ),
        ),
      ],
    );
  }
}

class _TabPill extends StatelessWidget {
  const _TabPill({required this.label, required this.selected, required this.onTap});

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(7),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: selected ? RatesColors.primary : RatesColors.surface,
            border: Border.all(color: selected ? RatesColors.primary : RatesColors.borderStrong),
            borderRadius: BorderRadius.circular(7),
          ),
          child: Text(
            label,
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: selected ? Colors.white : RatesColors.textMutedStrong),
          ),
        ),
      ),
    );
  }
}

class _ClientRateCard extends StatelessWidget {
  const _ClientRateCard({required this.rate});

  final ClientRate rate;

  @override
  Widget build(BuildContext context) {
    final isActive = rate.status == RateStatus.active;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 18),
      decoration: BoxDecoration(
        color: RatesColors.surface,
        border: Border.all(color: RatesColors.border),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          ShadBadge(
            backgroundColor: RatesColors.successBg.withValues(alpha: 0.6),
            foregroundColor: RatesColors.primaryDeep,
            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
            child: Text(rate.freightMode.label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(rate.chargeCode, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, fontFamily: 'monospace', color: RatesColors.textBody)),
                const SizedBox(height: 2),
                Text('${rate.serviceMode.label} · ${rate.routeCount} route(s)', style: const TextStyle(fontSize: 12, color: RatesColors.textMuted)),
              ],
            ),
          ),
          ShadBadge(
            backgroundColor: isActive ? RatesColors.successBg : RatesColors.surfaceMuted,
            foregroundColor: isActive ? RatesColors.successText : RatesColors.textMuted,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            child: Text(rate.expiryLabel, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }
}
