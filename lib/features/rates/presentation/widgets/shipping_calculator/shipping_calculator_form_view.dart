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
import 'shipping_calculator_form_view_mobile.dart';
import 'shipping_calculator_form_view_web.dart';

const _fieldHeight = 44.0;

/// Pre-built, bloc-wired pieces shared by [ShippingCalculatorFormWeb] and
/// [ShippingCalculatorFormMobile] — they differ only in how these are
/// arranged, not in what they are.
typedef ShippingCalculatorFormParts = ({
  Widget header,
  Widget serviceFreightCard,
  Widget routingCard,
  Widget cargoDetailsCard,
  Widget submitButton,
  Widget breakdownPanel,
  Widget pdfButtonSlot,
});

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

    final parts = (
      header: header,
      serviceFreightCard: const _ServiceFreightCard(),
      routingCard: const _RoutingCard(),
      cargoDetailsCard: const _CargoDetailsCard(),
      submitButton: _SubmitButton(client: client),
      breakdownPanel: FreightBreakdownPanel(client: client, showButton: false),
      pdfButtonSlot: _GeneratePdfButtonSlot(client: client),
    );

    return Breakpoints.isMobile(context)
        ? ShippingCalculatorFormMobile(parts: parts)
        : ShippingCalculatorFormWeb(parts: parts);
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

    // Header-trailing radio pair instead of its own field row — reclaims
    // the section header's empty right side rather than adding a whole
    // extra row below. Always the same widget shape (Tooltip -> option)
    // regardless of hasExpressRates — conditionally swapping the Tooltip
    // wrapper in/out caused repeated mouse-tracker crashes when that swap
    // landed under the cursor.
    final serviceLevelTrailing = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _ServiceLevelRadioOption(
          label: 'Standard',
          selected: state.serviceLevel == ServiceLevel.regular,
          onTap: () => bloc.add(const CalcServiceLevelChanged(ServiceLevel.regular)),
        ),
        const SizedBox(width: 16),
        Tooltip(
          message: state.hasExpressRates
              ? 'Price this route using the Express rate'
              : 'This rate has no Express pricing set',
          child: _ServiceLevelRadioOption(
            label: 'Express',
            selected: state.serviceLevel == ServiceLevel.express,
            onTap: state.hasExpressRates
                ? () => bloc.add(const CalcServiceLevelChanged(ServiceLevel.express))
                : null,
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
      trailing: serviceLevelTrailing,
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

/// Standard/Express radio option shown in the section header's trailing
/// slot. `onTap == null` renders it disabled — wrap in a [Tooltip] to
/// explain why (e.g. no Express rate set).
class _ServiceLevelRadioOption extends StatelessWidget {
  const _ServiceLevelRadioOption({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final disabled = onTap == null;
    final color = disabled
        ? context.colors.textFaint
        : selected
            ? context.colors.primary
            : context.colors.textMutedStrong;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(6),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 4),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 16,
                height: 16,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: color, width: 1.5),
                ),
                child: selected
                    ? Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(shape: BoxShape.circle, color: color),
                      )
                    : null,
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: color),
              ),
            ],
          ),
        ),
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
class _DimensionField extends StatelessWidget {
  const _DimensionField({
    required this.dimKey,
    required this.initialValue,
    required this.onChanged,
  });

  final String dimKey;
  final String initialValue;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return ShadInput(
      key: ValueKey(dimKey),
      placeholder: const Text('0'),
      initialValue: initialValue,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      onChanged: onChanged,
    );
  }
}

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
                              child: _DimensionField(
                                dimKey: 'calc-dim-l-$i',
                                initialValue: state.dimensions[i].length,
                                onChanged: (v) =>
                                    bloc.add(CalcDimensionLengthChanged(i, v)),
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: _DimensionField(
                                dimKey: 'calc-dim-w-$i',
                                initialValue: state.dimensions[i].width,
                                onChanged: (v) =>
                                    bloc.add(CalcDimensionWidthChanged(i, v)),
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: _DimensionField(
                                dimKey: 'calc-dim-h-$i',
                                initialValue: state.dimensions[i].height,
                                onChanged: (v) =>
                                    bloc.add(CalcDimensionHeightChanged(i, v)),
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
/// `ShippingCalculatorFormWeb`.
class _GeneratePdfButtonSlot extends StatelessWidget {
  const _GeneratePdfButtonSlot({required this.client});

  final Client client;

  @override
  Widget build(BuildContext context) {
    final state = context.watch<ShippingCalculatorBloc>().state;
    final result = state.calcResultRevealed ? state.calcResult : null;
    if (result == null || result.error != null) return const SizedBox.shrink();
    return GeneratePdfButton(state: state, client: client);
  }
}

class _SubmitButton extends StatelessWidget {
  const _SubmitButton({required this.client});

  final Client client;

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<ShippingCalculatorBloc>();
    final state = context.watch<ShippingCalculatorBloc>().state;

    void handleCalculate() {
      if (!state.canSubmit) {
        // Not enough filled in yet — surface the same inline error as
        // before rather than opening a popup with nothing to show.
        bloc.add(const CalcSubmitRequested());
        return;
      }
      showFreightBreakdownDialog(
        context,
        calcBloc: bloc,
        shellBloc: context.read<RatesShellBloc>(),
        client: client,
        keepResultForPanel: !Breakpoints.isMobile(context),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (state.submitError != null) ...[
          Text(state.submitError!, style: TextStyle(fontSize: 13, color: context.colors.destructive)),
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
                onPressed: handleCalculate,
                child: const Text('Calculate Freight Breakdown'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

