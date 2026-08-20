import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../../../../core/di/injection_container.dart';
import '../../../data/repositories/rates_repository.dart';
import '../../../domain/entities/rates_enums.dart';
import '../../bloc/rates_shell_bloc.dart';
import '../../bloc/shipping_calculator_bloc.dart';
import '../../rates_colors.dart';
import '../back_pill.dart';

const _fieldHeight = 44.0;

class ShippingCalculatorFormView extends StatelessWidget {
  const ShippingCalculatorFormView({super.key});

  @override
  Widget build(BuildContext context) {
    final shellState = context.read<RatesShellBloc>().state;
    final client = shellState.selectedCalcClient;
    if (client == null) return const SizedBox.shrink();

    return BlocProvider(
      create: (_) => ShippingCalculatorBloc(getIt<RatesRepository>(), clientId: client.id),
      child: _CalculatorView(clientName: client.name),
    );
  }
}

class _CalculatorView extends StatelessWidget {
  const _CalculatorView({required this.clientName});

  final String clientName;

  @override
  Widget build(BuildContext context) {
    final shellBloc = context.read<RatesShellBloc>();

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(48, 40, 48, 48),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          BackPill(onTap: () => shellBloc.add(const ShippingCalculatorBackRequested())),
          const SizedBox(height: 24),
          Row(
            children: [
              Text(
                'Calculate Freight',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, letterSpacing: -0.2, color: context.colors.textBody),
              ),
              const SizedBox(width: 10),
              Flexible(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(color: context.colors.surfaceMuted, borderRadius: BorderRadius.circular(6)),
                  child: Text(
                    clientName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: context.colors.textMutedStrong),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Enter cargo and routing details to compute the freight breakdown.',
            style: TextStyle(fontSize: 14, color: context.colors.textMuted),
          ),
          const SizedBox(height: 24),
          const _ServiceFreightCard(),
          const SizedBox(height: 20),
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(child: _RoutingCard()),
                const SizedBox(width: 20),
                Expanded(child: _CargoDetailsCard()),
              ],
            ),
          ),
          const SizedBox(height: 20),
          const _SubmitButton(),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.icon, required this.title, required this.child});

  final IconData icon;
  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: context.colors.surface,
        border: Border.all(color: context.colors.border),
        borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: context.colors.shadowSoft, blurRadius: 16, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: context.colors.primaryDeep),
              const SizedBox(width: 8),
              Text(title, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: context.colors.textBody)),
            ],
          ),
          const SizedBox(height: 20),
          child,
        ],
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(label, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: context.colors.textMutedStrong)),
    );
  }
}

class _ServiceFreightCard extends StatelessWidget {
  const _ServiceFreightCard();

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<ShippingCalculatorBloc>();
    final state = context.watch<ShippingCalculatorBloc>().state;
    final rateTables = state.availableRateTables;

    return _SectionCard(
      icon: Icons.local_shipping_outlined,
      title: 'Service & Freight Details',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const _FieldLabel('Rate Category'),
                    SizedBox(
                      width: double.infinity,
                      height: _fieldHeight,
                      child: ShadSelect<RateType>(
                        initialValue: state.rateType,
                        selectedOptionBuilder: (context, value) => Text('${value.label} Rates'),
                        onChanged: (value) {
                          if (value != null) bloc.add(CalcRateCategoryChanged(value));
                        },
                        options: [for (final t in RateType.values) ShadOption(value: t, child: Text('${t.label} Rates'))],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 24),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const _FieldLabel('Freight Mode'),
                    SizedBox(
                      width: double.infinity,
                      height: _fieldHeight,
                      child: ShadSelect<FreightMode>(
                        initialValue: state.freightMode,
                        selectedOptionBuilder: (context, value) => Text(value.label),
                        onChanged: (value) {
                          if (value != null) bloc.add(CalcFreightModeChanged(value));
                        },
                        options: [for (final m in FreightMode.values) ShadOption(value: m, child: Text(m.label))],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const _FieldLabel('Service Mode'),
                    SizedBox(
                      width: double.infinity,
                      height: _fieldHeight,
                      child: ShadSelect<ServiceMode>(
                        key: ValueKey('calc-service-mode-${state.freightMode}'),
                        initialValue: state.serviceMode,
                        selectedOptionBuilder: (context, value) => Text(value.label),
                        onChanged: (value) {
                          if (value != null) bloc.add(CalcServiceModeChanged(value));
                        },
                        options: [for (final m in ServiceMode.values) ShadOption(value: m, child: Text(m.label))],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 24),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const _FieldLabel('Rate Table'),
                    SizedBox(
                      width: double.infinity,
                      height: _fieldHeight,
                      child: rateTables.isEmpty
                          ? Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14),
                              alignment: Alignment.centerLeft,
                              decoration: BoxDecoration(
                                border: Border.all(color: context.colors.borderStrong),
                                borderRadius: BorderRadius.circular(8),
                                color: context.colors.surfaceMuted,
                              ),
                              child: Text(
                                state.ratesLoading ? 'Loading rate tables...' : 'No matching rate table',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(fontSize: 13, color: context.colors.textMuted),
                              ),
                            )
                          : ShadSelect<String>(
                              key: ValueKey('calc-rate-table-${state.freightMode}-${state.serviceMode}'),
                              placeholder: const Text('Select a rate table'),
                              initialValue: state.selectedChargeCode,
                              selectedOptionBuilder: (context, value) => Text(value, style: const TextStyle(fontFamily: 'monospace')),
                              onChanged: (value) {
                                if (value != null) bloc.add(CalcRateTableChanged(value));
                              },
                              options: [
                                for (final r in rateTables)
                                  ShadOption(value: r.chargeCode, child: Text(r.chargeCode, style: const TextStyle(fontFamily: 'monospace'))),
                              ],
                            ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const _FieldLabel('Service Level'),
                    SizedBox(
                      width: double.infinity,
                      height: _fieldHeight,
                      child: ShadSelect<ServiceLevel>(
                        initialValue: state.serviceLevel,
                        selectedOptionBuilder: (context, value) => Text(value.label),
                        onChanged: (value) {
                          if (value != null) bloc.add(CalcServiceLevelChanged(value));
                        },
                        options: [for (final l in ServiceLevel.values) ShadOption(value: l, child: Text(l.label))],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 24),
              const Expanded(child: SizedBox.shrink()),
            ],
          ),
        ],
      ),
    );
  }
}

class _RoutingCard extends StatelessWidget {
  const _RoutingCard();

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<ShippingCalculatorBloc>();
    final state = context.watch<ShippingCalculatorBloc>().state;

    return _SectionCard(
      icon: CupertinoIcons.location_solid,
      title: 'Routing',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _FieldLabel('Origin'),
          ShadInput(
            placeholder: const Text('Search origin...'),
            initialValue: state.origin,
            onChanged: (v) => bloc.add(CalcOriginChanged(v)),
          ),
          const SizedBox(height: 20),
          const _FieldLabel('Destination'),
          ShadInput(
            placeholder: const Text('Search destination...'),
            initialValue: state.destination,
            onChanged: (v) => bloc.add(CalcDestinationChanged(v)),
          ),
        ],
      ),
    );
  }
}

class _CargoDetailsCard extends StatelessWidget {
  const _CargoDetailsCard();

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<ShippingCalculatorBloc>();
    final state = context.watch<ShippingCalculatorBloc>().state;

    return _SectionCard(
      icon: Icons.inventory_2_outlined,
      title: 'Cargo Details',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _FieldLabel('Dimensions (L x W x H cm)'),
          Row(
            children: [
              Expanded(
                child: ShadInput(
                  placeholder: const Text('L'),
                  initialValue: state.length,
                  keyboardType: TextInputType.number,
                  onChanged: (v) => bloc.add(CalcLengthChanged(v)),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ShadInput(
                  placeholder: const Text('W'),
                  initialValue: state.width,
                  keyboardType: TextInputType.number,
                  onChanged: (v) => bloc.add(CalcWidthChanged(v)),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ShadInput(
                  placeholder: const Text('H'),
                  initialValue: state.height,
                  keyboardType: TextInputType.number,
                  onChanged: (v) => bloc.add(CalcHeightChanged(v)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const _FieldLabel('Divisor'),
                    ShadInput(
                      initialValue: state.divisor,
                      keyboardType: TextInputType.number,
                      onChanged: (v) => bloc.add(CalcDivisorChanged(v)),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const _FieldLabel('Weight (kg)'),
                    ShadInput(
                      placeholder: const Text('0.00'),
                      initialValue: state.weight,
                      keyboardType: TextInputType.number,
                      onChanged: (v) => bloc.add(CalcWeightChanged(v)),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const _FieldLabel('Declared Value (₱)'),
                    ShadInput(
                      placeholder: const Text('0.00'),
                      initialValue: state.declaredValue,
                      keyboardType: TextInputType.number,
                      onChanged: (v) => bloc.add(CalcDeclaredValueChanged(v)),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const _FieldLabel('Charge Basis'),
                    SizedBox(
                      width: double.infinity,
                      height: _fieldHeight,
                      child: ShadSelect<CalcChargeBasis>(
                        initialValue: state.chargeBasis,
                        selectedOptionBuilder: (context, value) => Text(value.label),
                        onChanged: (value) {
                          if (value != null) bloc.add(CalcChargeBasisChanged(value));
                        },
                        options: [for (final b in CalcChargeBasis.values) ShadOption(value: b, child: Text(b.label))],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SubmitButton extends StatelessWidget {
  const _SubmitButton();

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<ShippingCalculatorBloc>();
    final submitError = context.select((ShippingCalculatorBloc b) => b.state.submitError);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (submitError != null) ...[
          Text(submitError, style: TextStyle(fontSize: 13, color: context.colors.destructive)),
          const SizedBox(height: 12),
        ],
        SizedBox(
          width: double.infinity,
          child: ShadButton(
            gradient: context.colors.primaryButtonGradient,
            leading: const Icon(Icons.calculate_outlined, size: 17),
            onPressed: () => bloc.add(const CalcSubmitRequested()),
            child: const Text('Calculate Freight Breakdown'),
          ),
        ),
      ],
    );
  }
}
