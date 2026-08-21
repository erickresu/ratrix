import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../../../../core/di/injection_container.dart';
import '../../../../../core/utils/breakpoints.dart';
import '../../../data/repositories/rates_repository.dart';
import '../../../domain/entities/client.dart';
import '../../../domain/entities/ratrix_rate.dart';
import '../../../domain/entities/rates_enums.dart';
import '../../bloc/rates_shell_bloc.dart';
import '../../bloc/shipping_calculator_bloc.dart';
import '../../rates_colors.dart';
import '../back_pill.dart';
import 'freight_breakdown_dialog.dart';

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
      child: _CalculatorView(client: client),
    );
  }
}

class _CalculatorView extends StatelessWidget {
  const _CalculatorView({required this.client});

  final Client client;

  @override
  Widget build(BuildContext context) {
    final shellBloc = context.read<RatesShellBloc>();
    final isMobile = Breakpoints.isMobile(context);

    final routingAndCargo = isMobile
        ? const Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _RoutingCard(),
              SizedBox(height: 20),
              _CargoDetailsCard(),
            ],
          )
        : IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(child: _RoutingCard()),
                const SizedBox(width: 20),
                Expanded(child: _CargoDetailsCard()),
              ],
            ),
          );

    return BlocListener<ShippingCalculatorBloc, ShippingCalculatorState>(
      // Only when a result newly appears — not on every recompute (e.g. the
      // charge-basis switch inside the already-open dialog), which must
      // update the same dialog in place rather than opening a new one.
      listenWhen: (prev, curr) => prev.calcResult == null && curr.calcResult != null,
      listener: (context, state) {
        final calcBloc = context.read<ShippingCalculatorBloc>();
        final shellBloc = context.read<RatesShellBloc>();
        showFreightBreakdownDialog(context, calcBloc: calcBloc, shellBloc: shellBloc, client: client);
      },
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(isMobile ? 20 : 64, 48, isMobile ? 20 : 64, 56),
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
                      client.name,
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
            routingAndCargo,
            const SizedBox(height: 20),
            const _SubmitButton(),
          ],
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.icon, required this.title, required this.child, this.trailing});

  final IconData icon;
  final String title;
  final Widget child;
  final Widget? trailing;

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
              Expanded(
                child: Text(title, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: context.colors.textBody)),
              ),
              ?trailing,
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
    final isMobile = Breakpoints.isMobile(context);

    final rateCategoryField = Column(
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
    );

    final freightModeField = Column(
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
    );

    final serviceModeField = Column(
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
    );

    final rateTableField = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _FieldLabel('Rate Table'),
        SizedBox(
          width: double.infinity,
          height: _fieldHeight,
          child: rateTables.isEmpty
              ? _DisabledField(text: state.ratesLoading ? 'Loading rate tables...' : 'No matching rate table')
              : ShadSelect<String>(
                  key: ValueKey('calc-rate-table-${state.freightMode}-${state.serviceMode}'),
                  placeholder: const Text('Select a rate table'),
                  initialValue: state.selectedChargeCode,
                  selectedOptionBuilder: (context, value) => Text(value, style: const TextStyle(fontFamily: 'monospace')),
                  onChanged: (value) {
                    if (value == null) return;
                    for (final rate in rateTables) {
                      if (rate.chargeCode == value) {
                        bloc.add(CalcRateTableChanged(rate));
                        break;
                      }
                    }
                  },
                  options: [
                    for (final r in rateTables)
                      ShadOption(value: r.chargeCode, child: Text(r.chargeCode, style: const TextStyle(fontFamily: 'monospace'))),
                  ],
                ),
        ),
      ],
    );

    final serviceLevelField = Column(
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
    );

    Widget fieldRow(Widget left, Widget right) {
      if (isMobile) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [left, const SizedBox(height: 20), right],
        );
      }
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: left),
          const SizedBox(width: 24),
          Expanded(child: right),
        ],
      );
    }

    return _SectionCard(
      icon: Icons.local_shipping_outlined,
      title: 'Service & Freight Details',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          fieldRow(rateCategoryField, freightModeField),
          const SizedBox(height: 20),
          fieldRow(serviceModeField, rateTableField),
          const SizedBox(height: 20),
          isMobile ? serviceLevelField : fieldRow(serviceLevelField, const SizedBox.shrink()),
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

    final hasRateTable = state.selectedRateId != null;
    final origins = state.availableOrigins;
    final destinations = state.availableDestinations;

    return _SectionCard(
      icon: CupertinoIcons.location_solid,
      title: 'Routing',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _FieldLabel('Origin'),
          SizedBox(
            width: double.infinity,
            height: _fieldHeight,
            child: !hasRateTable || origins.isEmpty
                ? _DisabledField(
                    text: !hasRateTable
                        ? 'Select a rate table first'
                        : state.routesLoading
                            ? 'Loading routes...'
                            : 'No routes on this rate',
                  )
                : ShadSelect<String>(
                    key: ValueKey('calc-origin-${state.selectedRateId}'),
                    placeholder: const Text('Select origin'),
                    initialValue: state.origin.isEmpty ? null : state.origin,
                    selectedOptionBuilder: (context, value) => Text(value),
                    onChanged: (value) {
                      if (value != null) bloc.add(CalcOriginChanged(value));
                    },
                    options: [for (final o in origins) ShadOption(value: o, child: Text(o))],
                  ),
          ),
          const SizedBox(height: 20),
          const _FieldLabel('Destination'),
          SizedBox(
            width: double.infinity,
            height: _fieldHeight,
            child: state.origin.isEmpty || destinations.isEmpty
                ? _DisabledField(text: state.origin.isEmpty ? 'Select an origin first' : 'No destinations for this origin')
                : ShadSelect<String>(
                    key: ValueKey('calc-destination-${state.selectedRateId}-${state.origin}'),
                    placeholder: const Text('Select destination'),
                    initialValue: state.destination.isEmpty ? null : state.destination,
                    selectedOptionBuilder: (context, value) => Text(value),
                    onChanged: (value) {
                      if (value != null) bloc.add(CalcDestinationChanged(value));
                    },
                    options: [for (final d in destinations) ShadOption(value: d, child: Text(d))],
                  ),
          ),
        ],
      ),
    );
  }
}

class _DisabledField extends StatelessWidget {
  const _DisabledField({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      alignment: Alignment.centerLeft,
      decoration: BoxDecoration(
        border: Border.all(color: context.colors.borderStrong),
        borderRadius: BorderRadius.circular(8),
        color: context.colors.surfaceMuted,
      ),
      child: Text(
        text,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(fontSize: 13, color: context.colors.textMuted),
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
    final isMobile = Breakpoints.isMobile(context);

    final divisorField = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _FieldLabel('Divisor'),
        ShadInput(
          initialValue: state.divisor,
          keyboardType: TextInputType.number,
          onChanged: (v) => bloc.add(CalcDivisorChanged(v)),
        ),
      ],
    );

    final weightField = Column(
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
    );

    final declaredValueField = Column(
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
    );

    Widget fieldRow3(Widget a, Widget b, Widget c) {
      if (isMobile) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [a, const SizedBox(height: 20), b, const SizedBox(height: 20), c],
        );
      }
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: a),
          const SizedBox(width: 20),
          Expanded(child: b),
          const SizedBox(width: 20),
          Expanded(child: c),
        ],
      );
    }

    // Live actual-vs-volumetric comparison so the user can see which basis
    // will bite before they even submit — independent of `chargeBasis`
    // itself (that's now picked inside the result popup).
    final length = num.tryParse(state.length.trim()) ?? 0;
    final width = num.tryParse(state.width.trim()) ?? 0;
    final height = num.tryParse(state.height.trim()) ?? 0;
    final divisorValue = num.tryParse(state.divisor.trim());
    final actualWeight = num.tryParse(state.weight.trim());
    final volumetricWeight = (divisorValue != null && divisorValue > 0) ? (length * width * height) / divisorValue : null;

    return _SectionCard(
      icon: Icons.inventory_2_outlined,
      title: 'Cargo Details',
      trailing: state.selectedRouteTiers.isEmpty
          ? null
          : _RouteTiersInfoButton(
              origin: state.origin,
              destination: state.destination,
              tiers: state.selectedRouteTiers,
            ),
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
          fieldRow3(divisorField, weightField, declaredValueField),
          if (actualWeight != null && volumetricWeight != null) ...[
            const SizedBox(height: 12),
            _HigherWeightIndicator(actualWeight: actualWeight, volumetricWeight: volumetricWeight),
          ],
          if (state.requiresMinimumCharge) ...[
            const SizedBox(height: 20),
            Text(
              'This rate charges a flat fee for the first breakweight bracket '
              '(no per-kg multiplication) and per-kg rates beyond it.',
              style: TextStyle(fontSize: 12, color: context.colors.textMuted),
            ),
          ],
        ],
      ),
    );
  }
}

/// Live actual-vs-volumetric comparison, shown outside the freight-breakdown
/// popup (right under the fields it depends on) so the user can see which
/// basis will bite before they even submit.
class _HigherWeightIndicator extends StatelessWidget {
  const _HigherWeightIndicator({required this.actualWeight, required this.volumetricWeight});

  final num actualWeight;
  final num volumetricWeight;

  @override
  Widget build(BuildContext context) {
    final volHigher = volumetricWeight > actualWeight;
    final label = volHigher
        ? 'Volumetric weight is higher (${volumetricWeight.toStringAsFixed(1)}kg vs ${actualWeight.toStringAsFixed(1)}kg actual)'
        : 'Actual weight is higher (${actualWeight.toStringAsFixed(1)}kg vs ${volumetricWeight.toStringAsFixed(1)}kg volumetric)';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: context.colors.primarySoftBg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(CupertinoIcons.arrow_up_right, size: 13, color: context.colors.primaryDeep),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              label,
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: context.colors.primaryDeep),
            ),
          ),
        ],
      ),
    );
  }
}

/// Info icon on the Cargo Details header — pops up the selected route's
/// origin/destination and breakweight brackets so the user can check what's
/// actually configured before hitting Calculate, not just after it errors.
class _RouteTiersInfoButton extends StatelessWidget {
  const _RouteTiersInfoButton({required this.origin, required this.destination, required this.tiers});

  final String origin;
  final String destination;
  final List<RatrixBreakweight> tiers;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: () => showShadDialog<void>(
        context: context,
        builder: (dialogContext) => ShadDialog(
          radius: BorderRadius.circular(16),
          backgroundColor: dialogContext.colors.surface,
          title: const Text('Route Breakweights'),
          child: Padding(
            padding: const EdgeInsets.only(top: 12),
            child: RouteTiersTable(origin: origin, destination: destination, tiers: tiers),
          ),
        ),
      ),
      icon: Icon(CupertinoIcons.info_circle, size: 18, color: context.colors.textMuted),
      tooltip: 'View breakweight brackets for this route',
      visualDensity: VisualDensity.compact,
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
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
        Align(
          alignment: Alignment.centerRight,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              ShadButton.outline(
                leading: const Icon(CupertinoIcons.refresh, size: 15),
                onPressed: () => bloc.add(const CalcFormReset()),
                child: const Text('Reset All'),
              ),
              const SizedBox(width: 12),
              ShadButton(
                gradient: context.colors.primaryButtonGradient,
                leading: const Icon(Icons.calculate_outlined, size: 17),
                onPressed: () => bloc.add(const CalcSubmitRequested()),
                child: const Text('Calculate Freight Breakdown'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

