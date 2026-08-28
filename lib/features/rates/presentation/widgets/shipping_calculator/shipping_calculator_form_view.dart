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

    final serviceFreightAndRouting = isMobile
        ? const Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _ServiceFreightCard(),
              SizedBox(height: 20),
              _RoutingCard(),
            ],
          )
        : IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(flex: 3, child: _ServiceFreightCard()),
                const SizedBox(width: 20),
                Expanded(flex: 2, child: _RoutingCard()),
              ],
            ),
          );

    final header = Column(
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
      ],
    );

    final formColumn = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        serviceFreightAndRouting,
        const SizedBox(height: 20),
        const _CargoDetailsCard(),
        const SizedBox(height: 20),
        const _SubmitButton(),
      ],
    );

    // Force both columns' button rows (Reset/Calculate on the left,
    // Generate Invoice PDF on the right) to sit level with each other —
    // `IntrinsicHeight` + `stretch` gives both columns the taller one's
    // height, and `spaceBetween` pins each column's last child (its button
    // row) to that shared bottom edge instead of trailing wherever its own
    // content happened to end.
    final desktopLayout = IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    serviceFreightAndRouting,
                    const SizedBox(height: 20),
                    const _CargoDetailsCard(),
                  ],
                ),
                const Padding(padding: EdgeInsets.only(top: 20), child: _SubmitButton()),
              ],
            ),
          ),
          const SizedBox(width: 24),
          SizedBox(
            width: 400,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // `Expanded` grows the card to fill the same height as the
                // left column's details cards (both columns are stretched
                // by the outer `IntrinsicHeight`), instead of the card
                // sizing to its own content and leaving a big empty gap
                // before the button.
                Expanded(child: FreightBreakdownPanel(client: client, showButton: false)),
                Padding(padding: const EdgeInsets.only(top: 20), child: _GeneratePdfButtonSlot(client: client)),
              ],
            ),
          ),
        ],
      ),
    );

    final content = SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(isMobile ? 20 : 64, 48, isMobile ? 20 : 64, 56),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          header,
          const SizedBox(height: 24),
          isMobile ? formColumn : desktopLayout,
        ],
      ),
    );

    // Desktop/tablet shows the result docked as a right-hand panel (always
    // in the layout, no listener needed — it just re-renders off state).
    // Mobile has no room for that side-by-side, so it keeps the modal.
    if (!isMobile) return content;

    return BlocListener<ShippingCalculatorBloc, ShippingCalculatorState>(
      listenWhen: (prev, curr) => prev.calcResult == null && curr.calcResult != null,
      listener: (context, state) {
        final calcBloc = context.read<ShippingCalculatorBloc>();
        showFreightBreakdownDialog(context, calcBloc: calcBloc, shellBloc: shellBloc, client: client);
      },
      child: content,
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

    final firstTier = state.selectedRouteTiers.isEmpty ? null : state.selectedRouteTiers.first;

    final weightField = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _FieldLabel('Chargeable Weight (kg)'),
        ShadInput(
          key: ValueKey('calc-weight-${state.weightAppliedFromCbm}'),
          placeholder: const Text('0.00'),
          initialValue: state.weight,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          onChanged: (v) => bloc.add(CalcWeightChanged(v)),
        ),
      ],
    );

    final hasValuation = state.selectedRate?.addons?.valuation != null && state.selectedRate!.addons!.valuation != 0;

    final declaredValueField = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _FieldLabel('Declared Value (₱)'),
        SizedBox(
          width: double.infinity,
          height: _fieldHeight,
          child: hasValuation
              ? ShadInput(
                  placeholder: const Text('0.00'),
                  initialValue: state.declaredValue,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  onChanged: (v) => bloc.add(CalcDeclaredValueChanged(v)),
                )
              : const _DisabledField(text: 'No valuation on this rate'),
        ),
      ],
    );

    Widget fieldRow2(Widget a, Widget b) {
      if (isMobile) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [a, const SizedBox(height: 20), b],
        );
      }
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: a),
          const SizedBox(width: 20),
          Expanded(child: b),
        ],
      );
    }

    return _SectionCard(
      icon: Icons.inventory_2_outlined,
      title: 'Cargo Details',
      trailing: state.selectedRouteTiers.isEmpty
          ? null
          : _RouteTiersInfoButton(
              origin: state.origin,
              destination: state.destination,
              tiers: state.selectedRouteTiers,
              addons: state.selectedRate?.addons,
            ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          fieldRow2(weightField, declaredValueField),
          const SizedBox(height: 12),
          ShadButton.outline(
            leading: const Icon(CupertinoIcons.cube_box, size: 15),
            onPressed: () => _showCbmDialog(context, bloc),
            child: const Text('Calculate from dimensions (CBM)'),
          ),
          if (state.requiresMinimumCharge) ...[
            const SizedBox(height: 20),
            RichText(
              text: firstTier == null
                  ? TextSpan(
                      style: TextStyle(fontSize: 12, color: context.colors.textMuted),
                      text: 'This rate charges a flat fee for the first breakweight bracket '
                          '(no per-kg multiplication) and per-kg rates beyond it.',
                    )
                  : TextSpan(
                      style: TextStyle(fontSize: 12, color: context.colors.textMuted),
                      children: [
                        const TextSpan(text: 'This rate charges a flat fee of '),
                        TextSpan(
                          text: '₱${firstTier.rate.toStringAsFixed(2)}',
                          style: TextStyle(fontWeight: FontWeight.w700, color: context.colors.primaryDeep),
                        ),
                        const TextSpan(text: ' for the first '),
                        TextSpan(
                          text: '${firstTier.min.toStringAsFixed(0)}–${firstTier.max.toStringAsFixed(0)}kg',
                          style: TextStyle(fontWeight: FontWeight.w700, color: context.colors.primaryDeep),
                        ),
                        const TextSpan(text: ' bracket (no per-kg multiplication) and per-kg rates beyond it.'),
                      ],
                    ),
            ),
          ],
        ],
      ),
    );
  }

  void _showCbmDialog(BuildContext context, ShippingCalculatorBloc bloc) {
    showShadDialog<void>(
      context: context,
      builder: (dialogContext) => BlocProvider.value(
        value: bloc,
        child: const _CbmCalculatorDialog(),
      ),
    );
  }
}

/// Popup CBM/volumetric-weight calculator — dimensions, divisor, and a
/// scratch actual-weight field for comparison. "Use this value" copies
/// whichever of the two is higher into the main Chargeable Weight field.
class _CbmCalculatorDialog extends StatelessWidget {
  const _CbmCalculatorDialog();

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<ShippingCalculatorBloc>();
    final state = context.watch<ShippingCalculatorBloc>().state;

    return ShadDialog(
      radius: BorderRadius.circular(16),
      backgroundColor: context.colors.surface,
      padding: EdgeInsets.zero,
      closeIcon: const SizedBox.shrink(),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 540, maxHeight: 620),
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(CupertinoIcons.cube_box, size: 20, color: context.colors.primaryDeep),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Calculate from Dimensions',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: context.colors.textBody),
                    ),
                  ),
                  Material(
                    color: context.colors.surfaceMuted,
                    shape: const CircleBorder(),
                    child: InkWell(
                      customBorder: const CircleBorder(),
                      onTap: () => Navigator.of(context).pop(),
                      child: Padding(
                        padding: const EdgeInsets.all(8),
                        child: Icon(CupertinoIcons.xmark, size: 15, color: context.colors.textMuted),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Flexible(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const _FieldLabel('Dimensions (cm)'),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              'Length',
                              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: context.colors.textMuted),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Text(
                              'Width',
                              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: context.colors.textMuted),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Text(
                              'Height',
                              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: context.colors.textMuted),
                            ),
                          ),
                          if (state.dimensions.length > 1) const SizedBox(width: 42),
                        ],
                      ),
                      const SizedBox(height: 6),
                      for (var i = 0; i < state.dimensions.length; i++) ...[
                        if (i > 0) const SizedBox(height: 14),
                        Row(
                          children: [
                            Expanded(
                              child: ShadInput(
                                key: ValueKey('calc-dim-l-$i'),
                                placeholder: const Text('0'),
                                initialValue: state.dimensions[i].length,
                                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                onChanged: (v) => bloc.add(CalcDimensionLengthChanged(i, v)),
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: ShadInput(
                                key: ValueKey('calc-dim-w-$i'),
                                placeholder: const Text('0'),
                                initialValue: state.dimensions[i].width,
                                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                onChanged: (v) => bloc.add(CalcDimensionWidthChanged(i, v)),
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: ShadInput(
                                key: ValueKey('calc-dim-h-$i'),
                                placeholder: const Text('0'),
                                initialValue: state.dimensions[i].height,
                                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                onChanged: (v) => bloc.add(CalcDimensionHeightChanged(i, v)),
                              ),
                            ),
                            if (state.dimensions.length > 1) ...[
                              const SizedBox(width: 10),
                              SizedBox(
                                height: _fieldHeight,
                                child: IconButton(
                                  icon: Icon(CupertinoIcons.trash, size: 16, color: context.colors.destructive),
                                  tooltip: 'Remove dimension',
                                  onPressed: () => bloc.add(CalcDimensionRemoved(i)),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                      const SizedBox(height: 14),
                      ShadButton.outline(
                        leading: const Icon(CupertinoIcons.add, size: 14),
                        onPressed: () => bloc.add(const CalcDimensionAdded()),
                        child: const Text('Add dimension'),
                      ),
                      const SizedBox(height: 28),
                      const _FieldLabel('Divisor'),
                      ShadInput(
                        initialValue: state.divisor,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        onChanged: (v) => bloc.add(CalcDivisorChanged(v)),
                      ),
                      const SizedBox(height: 24),
                      const _FieldLabel('Computed Weight (kg)'),
                      SizedBox(
                        width: double.infinity,
                        height: _fieldHeight,
                        child: _DisabledField(
                          text: state.popupVolumetricWeight == null
                              ? 'Enter dimensions and divisor above'
                              : '${state.popupVolumetricWeight!.toStringAsFixed(2)} kg',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 28),
              Align(
                alignment: Alignment.centerRight,
                child: ShadButton(
                  gradient: context.colors.primaryButtonGradient,
                  enabled: state.popupVolumetricWeight != null,
                  onPressed: () {
                    bloc.add(const CalcCbmResultApplied());
                    Navigator.of(context).pop();
                  },
                  child: const Text('Use this value'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Info icon on the Cargo Details header — pops up the selected route's
/// origin/destination and breakweight brackets so the user can check what's
/// actually configured before hitting Calculate, not just after it errors.
class _RouteTiersInfoButton extends StatelessWidget {
  const _RouteTiersInfoButton({required this.origin, required this.destination, required this.tiers, this.addons});

  final String origin;
  final String destination;
  final List<RatrixBreakweight> tiers;
  final RatrixAddons? addons;

  void _showDialog(BuildContext context) => showShadDialog<void>(
        context: context,
        builder: (dialogContext) => ShadDialog(
          radius: BorderRadius.circular(16),
          backgroundColor: dialogContext.colors.surface,
          padding: EdgeInsets.zero,
          closeIcon: const SizedBox.shrink(),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560, maxHeight: 600),
            child: Padding(
              padding: const EdgeInsets.all(28),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(CupertinoIcons.square_stack_3d_up, size: 20, color: dialogContext.colors.primaryDeep),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Rate Details',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: dialogContext.colors.textBody),
                        ),
                      ),
                      Material(
                        color: dialogContext.colors.surfaceMuted,
                        shape: const CircleBorder(),
                        child: InkWell(
                          customBorder: const CircleBorder(),
                          onTap: () => Navigator.of(dialogContext).pop(),
                          child: Padding(
                            padding: const EdgeInsets.all(8),
                            child: Icon(CupertinoIcons.xmark, size: 15, color: dialogContext.colors.textMuted),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Flexible(
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          RouteTiersTable(origin: origin, destination: destination, tiers: tiers),
                          if (addons != null) ...[
                            const SizedBox(height: 28),
                            _AddonsSummary(addons: addons!),
                          ],
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );

  @override
  Widget build(BuildContext context) {
    return Material(
      color: context.colors.primaryChipBg,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: () => _showDialog(context),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: context.colors.primaryBorder),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(CupertinoIcons.info_circle, size: 15, color: context.colors.primaryDeep),
              const SizedBox(width: 6),
              Text(
                'Rate Details',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: context.colors.primaryDeep),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Lists the rate's configured Add-on charges (fuel surcharge, insurance,
/// valuation, etc) inside the Rate Details popup — same labels/percentage
/// vs. flat handling as the freight breakdown's own fee list, just read
/// straight from the rate instead of a computed `CalcResult`. Fields left
/// null/zero on the rate are omitted rather than shown as "₱0.00".
class _AddonsSummary extends StatelessWidget {
  const _AddonsSummary({required this.addons});

  final RatrixAddons addons;

  @override
  Widget build(BuildContext context) {
    String money(num v) => v.toStringAsFixed(2);
    String amountFor(num value, String? type) =>
        type == 'percentage' ? '${money(value)}%' : '₱${money(value)}';

    final rows = <(String, String)>[
      if (addons.fuelSurcharge != null && addons.fuelSurcharge != 0)
        ('Fuel Surcharge', amountFor(addons.fuelSurcharge!, addons.fuelSurchargeType)),
      if (addons.securitySurcharge != null && addons.securitySurcharge != 0)
        ('Security Surcharge', '₱${money(addons.securitySurcharge!)}'),
      if (addons.waybillFee != null && addons.waybillFee != 0)
        ('Waybill Fee', '₱${money(addons.waybillFee!)}'),
      if (addons.bookingHandlingFee != null && addons.bookingHandlingFee != 0)
        ('Booking/Handling Fee', '₱${money(addons.bookingHandlingFee!)}'),
      if (addons.documentationFee != null && addons.documentationFee != 0)
        ('Documentation Fee', '₱${money(addons.documentationFee!)}'),
      if (addons.permitFeesNonVat != null && addons.permitFeesNonVat != 0)
        ('Permit Fee', '₱${money(addons.permitFeesNonVat!)}'),
      if (addons.insurance != null && addons.insurance != 0)
        ('Insurance', '₱${money(addons.insurance!)}'),
      if (addons.valuation != null && addons.valuation != 0)
        ('Valuation', amountFor(addons.valuation!, addons.valuationType)),
      if (addons.deliveryFee != null && addons.deliveryFee != 0)
        ('Delivery Fee', '₱${money(addons.deliveryFee!)}'),
      if (addons.cratingFee != null && addons.cratingFee != 0)
        ('Crating Fee', '₱${money(addons.cratingFee!)}'),
      if (addons.packingFee != null && addons.packingFee != 0)
        ('Packing Fee', '₱${money(addons.packingFee!)}'),
      if (addons.airThc != null && addons.airThc != 0)
        ('Air THC', '₱${money(addons.airThc!)}'),
      if (addons.seaThc != null && addons.seaThc != 0)
        ('Sea THC', '₱${money(addons.seaThc!)}'),
      if (addons.demurrageDetention != null && addons.demurrageDetention != 0)
        ('Demurrage/Detention', '₱${money(addons.demurrageDetention!)}'),
      if (addons.hazardousGoodsHandling != null && addons.hazardousGoodsHandling != 0)
        ('Hazardous Goods Handling', '₱${money(addons.hazardousGoodsHandling!)}'),
      if (addons.othersNonVat != null && addons.othersNonVat != 0)
        ('Other Fees', '₱${money(addons.othersNonVat!)}'),
    ];

    if (rows.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(CupertinoIcons.tag, size: 15, color: context.colors.primaryDeep),
            const SizedBox(width: 6),
            Text(
              'Add-on Charges',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: context.colors.textBody),
            ),
          ],
        ),
        const SizedBox(height: 14),
        for (final row in rows)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(row.$1, style: TextStyle(fontSize: 13, color: context.colors.textMuted)),
                Text(row.$2, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: context.colors.textBody)),
              ],
            ),
          ),
      ],
    );
  }
}

/// Renders `GeneratePdfButton` in its own slot outside `FreightBreakdownPanel`
/// (which is told `showButton: false`) so it can sit in a separate bottom-
/// aligned row alongside the form's Reset/Calculate buttons — see
/// `desktopLayout` in `_CalculatorView`.
class _GeneratePdfButtonSlot extends StatelessWidget {
  const _GeneratePdfButtonSlot({required this.client});

  final Client client;

  @override
  Widget build(BuildContext context) {
    final state = context.watch<ShippingCalculatorBloc>().state;
    final result = state.calcResult;
    if (result == null || result.error != null) return const SizedBox.shrink();
    return GeneratePdfButton(state: state, client: client);
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

