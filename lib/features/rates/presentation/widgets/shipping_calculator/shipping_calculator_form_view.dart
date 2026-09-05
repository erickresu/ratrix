import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../../../../core/utils/breakpoints.dart';
import '../../../../../core/utils/money_formatting.dart';
import '../../../domain/entities/client.dart';
import '../../../domain/entities/client_rate.dart';
import '../../../domain/entities/conditional_addon_config.dart';
import '../../../domain/entities/ratrix_rate.dart';
import '../../../domain/entities/rates_enums.dart';
import '../../bloc/rates_shell_bloc.dart';
import '../../bloc/shipping_calculator_bloc.dart';
import '../../rates_colors.dart';
import '../back_pill.dart';
import 'change_rate_table_dialog.dart';
import 'freight_breakdown_dialog.dart';
import 'shipping_calculator_form_view_mobile.dart';
import 'shipping_calculator_form_view_web.dart';

const _fieldHeight = 44.0;

/// Pre-built, bloc-wired pieces shared by [ShippingCalculatorFormWeb] and
/// [ShippingCalculatorFormMobile] — they differ only in how these are
/// arranged, not in what they are.
typedef ShippingCalculatorFormParts = ({
  Widget backPill,
  Widget titleBlock,
  Widget serviceFreightCard,
  Widget routingCard,
  Widget cargoDetailsCard,
  Widget submitButton,
  Widget breakdownPanel,
});

class ShippingCalculatorFormView extends StatelessWidget {
  const ShippingCalculatorFormView({super.key});

  @override
  Widget build(BuildContext context) {
    final shellState = context.read<RatesShellBloc>().state;
    final client = shellState.selectedCalcClient;
    if (client == null) return const SizedBox.shrink();

    // ShippingCalculatorBloc is now provided by RatesShellPage, above the
    // view switch — not created here — so its state (route, weight,
    // dimensions, declared value, calc result) survives navigating away
    // (e.g. "Edit this rate") and back, instead of resetting every time
    // this widget remounts.
    return _CalculatorView(client: client);
  }
}

class _CalculatorView extends StatelessWidget {
  const _CalculatorView({required this.client});

  final Client client;

  @override
  Widget build(BuildContext context) {
    final shellBloc = context.read<RatesShellBloc>();

    final backPill = BackPill(onTap: () => shellBloc.add(const ShippingCalculatorBackRequested()));

    final titleBlock = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
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
      backPill: backPill,
      titleBlock: titleBlock,
      serviceFreightCard: const _ServiceFreightCard(),
      routingCard: const _RoutingCard(),
      cargoDetailsCard: const _CargoDetailsCard(),
      submitButton: _SubmitButton(client: client),
      breakdownPanel: FreightBreakdownPanel(client: client),
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

bool _hasRoutingOrCargoData(ShippingCalculatorState state) {
  if (state.origin.trim().isNotEmpty) return true;
  if (state.destination.trim().isNotEmpty) return true;
  if (state.weight.trim().isNotEmpty) return true;
  if (state.declaredValue.trim().isNotEmpty) return true;
  for (final d in state.dimensions) {
    if (d.length.trim().isNotEmpty || d.width.trim().isNotEmpty || d.height.trim().isNotEmpty) return true;
  }
  return false;
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
                  onChanged: (value) async {
                    if (value == null) return;
                    ClientRate? picked;
                    for (final rate in rateTables) {
                      if (rate.chargeCode == value) {
                        picked = rate;
                        break;
                      }
                    }
                    if (picked == null) return;
                    if (_hasRoutingOrCargoData(state)) {
                      final confirmed = await showShadDialog<bool>(
                        context: context,
                        builder: (_) => const ChangeRateTableDialog(),
                      );
                      if (confirmed != true) return;
                    }
                    bloc.add(CalcRateTableChanged(picked));
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
              serviceLevel: state.serviceLevel,
              addons: state.selectedRate?.addons,
              rateId: state.selectedRate?.id,
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
                          text: '₱${formatMoney(firstTier.rate)}',
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

  /// This one piece's own volumetric weight, or `—` until its length/width/
  /// height and the shared divisor are all filled in with valid numbers.
  String _rowWeightLabel(ShippingCalculatorState state, int i) {
    final divisor = num.tryParse(state.divisor.trim());
    final d = state.dimensions[i];
    final length = num.tryParse(d.length.trim());
    final width = num.tryParse(d.width.trim());
    final height = num.tryParse(d.height.trim());
    if (divisor == null || divisor <= 0 || length == null || width == null || height == null) {
      return '—';
    }
    final packages = num.tryParse(d.packages.trim()) ?? 1;
    final unit = state.freightMode == FreightMode.sea ? 'CBM' : 'kg';
    return '${((length * width * height) / divisor * packages).toStringAsFixed(2)} $unit';
  }

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
        constraints: const BoxConstraints(maxWidth: 760, maxHeight: 680),
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      gradient: context.colors.primaryButtonGradient,
                      borderRadius: BorderRadius.circular(11),
                    ),
                    child: const Icon(CupertinoIcons.cube_box_fill, size: 18, color: Colors.white),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Calculate from Dimensions',
                          style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: context.colors.textBody),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Per-piece weight, summed into one chargeable total',
                          style: TextStyle(fontSize: 12, color: context.colors.textMuted),
                        ),
                      ],
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
              const SizedBox(height: 18),
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
                          const SizedBox(width: 14),
                          SizedBox(
                            width: 60,
                            child: Text(
                              'Quantity',
                              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: context.colors.textMuted),
                            ),
                          ),
                          const SizedBox(width: 10),
                          SizedBox(
                            width: 96,
                            child: Align(
                              alignment: Alignment.centerRight,
                              child: Text(
                                'Weight',
                                style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: context.colors.textMuted),
                              ),
                            ),
                          ),
                          if (state.dimensions.length > 1) const SizedBox(width: 36),
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
                            const SizedBox(width: 14),
                            SizedBox(
                              width: 60,
                              child: _DimensionField(
                                dimKey: 'calc-dim-p-$i',
                                initialValue: state.dimensions[i].packages,
                                onChanged: (v) => bloc.add(
                                  CalcDimensionPackagesChanged(i, v),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            SizedBox(
                              width: 96,
                              height: _fieldHeight,
                              child: Align(
                                alignment: Alignment.centerRight,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                                  decoration: BoxDecoration(
                                    color: context.colors.primaryChipBg,
                                    borderRadius: BorderRadius.circular(7),
                                  ),
                                  child: Text(
                                    _rowWeightLabel(state, i),
                                    textAlign: TextAlign.right,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 11.5,
                                      fontWeight: FontWeight.w700,
                                      color: context.colors.primaryDeep,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            if (state.dimensions.length > 1) ...[
                              const SizedBox(width: 4),
                              SizedBox(
                                width: 32,
                                height: _fieldHeight,
                                child: IconButton(
                                  icon: Icon(CupertinoIcons.trash, size: 16, color: context.colors.destructive),
                                  tooltip: 'Remove dimension',
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(),
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
                        // `initialValue` only seeds the controller once and
                        // won't pick up state.divisor's freight-mode-driven
                        // default (6000 air/land, 1,000,000 sea) on its own.
                        // Keying on freightMode (not divisor itself — that
                        // would reset the field, and the cursor, on every
                        // keystroke) forces a fresh seed only when the mode
                        // actually changes, while still leaving the value
                        // fully editable by hand afterward.
                        key: ValueKey('calc-divisor-${state.freightMode}'),
                        initialValue: state.divisor,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        onChanged: (v) => bloc.add(CalcDivisorChanged(v)),
                      ),
                      const SizedBox(height: 24),
                      if (state.popupVolumetricWeight != null)
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          decoration: BoxDecoration(
                            color: context.colors.sidebarBg.withValues(alpha: 0.85),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              Text(
                                'COMPUTED WEIGHT',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.5,
                                  color: Colors.white.withValues(alpha: 0.85),
                                ),
                              ),
                              const Spacer(),
                              Text(
                                '${state.popupVolumetricWeight!.toStringAsFixed(2)} ${state.freightMode == FreightMode.sea ? 'CBM' : 'kg'}',
                                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Colors.white),
                              ),
                            ],
                          ),
                        )
                      else ...[
                        _FieldLabel(
                          state.freightMode == FreightMode.sea
                              ? 'Computed Weight (CBM)'
                              : 'Computed Weight (kg)',
                        ),
                        SizedBox(
                          width: double.infinity,
                          height: _fieldHeight,
                          child: const _DisabledField(text: 'Enter dimensions and divisor above'),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 28),
              Align(
                alignment: Alignment.centerRight,
                child: ShadButton(
                  backgroundColor: context.colors.primary,
                  hoverBackgroundColor: context.colors.primaryHover,
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
  const _RouteTiersInfoButton({
    required this.origin,
    required this.destination,
    required this.tiers,
    required this.serviceLevel,
    this.addons,
    this.rateId,
  });

  final String origin;
  final String destination;
  final List<RatrixBreakweight> tiers;
  final ServiceLevel serviceLevel;
  final RatrixAddons? addons;

  /// The rate this popup describes — lets the "edit" pencil icon on
  /// [RouteTiersTable] jump straight into the wizard for it. Null (no
  /// pencil shown) only if the rate somehow loaded without an id.
  final String? rateId;

  void _showDialog(BuildContext context) {
    // Captured here, before the dialog opens — `showShadDialog` pushes
    // onto the root Navigator, outside this widget's `RatesShellBloc`
    // scope, so the dialog can't `context.read` it directly (same reason
    // `freight_breakdown_dialog.dart`'s "Edit this rate" button re-provides
    // it via `BlocProvider.value` below).
    final shellBloc = context.read<RatesShellBloc>();
    showShadDialog<void>(
        context: context,
        builder: (dialogContext) => BlocProvider.value(
          value: shellBloc,
          child: ShadDialog(
          radius: BorderRadius.circular(16),
          backgroundColor: dialogContext.colors.surface,
          padding: EdgeInsets.zero,
          closeIcon: const SizedBox.shrink(),
          // ShadDialog's own default constraints cap maxWidth at 512
          // regardless of a child ConstrainedBox — override here instead.
          constraints: const BoxConstraints(maxWidth: 720, maxHeight: 600),
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
                      Text(
                        'Rate Details',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: dialogContext.colors.textBody),
                      ),
                      const SizedBox(width: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: serviceLevel == ServiceLevel.express
                              ? dialogContext.colors.accentChipBg
                              : dialogContext.colors.primaryChipBg,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          serviceLevel.label,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: serviceLevel == ServiceLevel.express
                                ? dialogContext.colors.accent
                                : dialogContext.colors.primaryDeep,
                          ),
                        ),
                      ),
                      const Spacer(),
                      if (rateId != null) ...[
                        Material(
                          color: dialogContext.colors.primary,
                          shape: const CircleBorder(),
                          child: InkWell(
                            customBorder: const CircleBorder(),
                            onTap: () {
                              Navigator.of(dialogContext).pop();
                              shellBloc.add(EditRateRequested(rateId!));
                            },
                            child: const Padding(
                              padding: EdgeInsets.all(8),
                              child: Icon(CupertinoIcons.pencil, size: 15, color: Colors.white),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                      ],
                      Material(
                        color: dialogContext.colors.destructive,
                        shape: const CircleBorder(),
                        child: InkWell(
                          customBorder: const CircleBorder(),
                          onTap: () => Navigator.of(dialogContext).pop(),
                          child: const Padding(
                            padding: EdgeInsets.all(8),
                            child: Icon(CupertinoIcons.xmark, size: 15, color: Colors.white),
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
  }

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
    String amountFor(num value, String? type) =>
        type == 'percentage' ? '${value.toStringAsFixed(2)}%' : '₱${formatMoney(value)}';

    final rows = <(String, String)>[
      if (addons.fuelSurcharge != null && addons.fuelSurcharge != 0)
        ('Fuel Surcharge', amountFor(addons.fuelSurcharge!, addons.fuelSurchargeType)),
      if (addons.securitySurcharge != null && addons.securitySurcharge != 0)
        ('Security Surcharge', '₱${formatMoney(addons.securitySurcharge!)}'),
      if (addons.waybillFee != null && addons.waybillFee != 0)
        ('Waybill Fee', '₱${formatMoney(addons.waybillFee!)}'),
      if (addons.bookingHandlingFee != null && addons.bookingHandlingFee != 0)
        ('Booking/Handling Fee', '₱${formatMoney(addons.bookingHandlingFee!)}'),
      if (addons.documentationFee != null && addons.documentationFee != 0)
        ('Documentation Fee', '₱${formatMoney(addons.documentationFee!)}'),
      if (addons.permitFeesNonVat != null && addons.permitFeesNonVat != 0)
        ('Permit Fee', '₱${formatMoney(addons.permitFeesNonVat!)}'),
      if (addons.insurance != null && addons.insurance != 0)
        ('Insurance', '₱${formatMoney(addons.insurance!)}'),
      if (addons.valuation != null && addons.valuation != 0)
        ('Valuation', amountFor(addons.valuation!, addons.valuationType)),
      if (addons.deliveryFee != null && addons.deliveryFee != 0)
        ('Delivery Fee', '₱${formatMoney(addons.deliveryFee!)}'),
      if (addons.cratingFee != null && addons.cratingFee != 0)
        ('Crating Fee', '₱${formatMoney(addons.cratingFee!)}'),
      if (addons.packingFee != null && addons.packingFee != 0)
        ('Packing Fee', '₱${formatMoney(addons.packingFee!)}'),
      if (addons.airThc != null && addons.airThc != 0)
        ('Air THC', '₱${formatMoney(addons.airThc!)}'),
      if (addons.seaThc != null && addons.seaThc != 0)
        ('Sea THC', '₱${formatMoney(addons.seaThc!)}'),
      if (addons.demurrageDetention != null && addons.demurrageDetention != 0)
        ('Demurrage/Detention', '₱${formatMoney(addons.demurrageDetention!)}'),
      if (addons.arrastre != null && addons.arrastre != 0)
        ('Arrastre Charge', '₱${formatMoney(addons.arrastre!)}'),
      if (addons.hazardousGoodsHandling != null && addons.hazardousGoodsHandling != 0)
        ('Hazardous Goods Handling', '₱${formatMoney(addons.hazardousGoodsHandling!)}'),
      if (addons.othersNonVat != null && addons.othersNonVat != 0)
        ('Other Fees', '₱${formatMoney(addons.othersNonVat!)}'),
      // Plain-decimal ODA/Pickup Fee only — the bracket-config form
      // (per-destination/origin breakweight tiers) is shown separately
      // below, since it doesn't fit a single (label, amount) row.
      if (addons.oda != null && addons.oda != 0)
        ('ODA', '₱${formatMoney(addons.oda!)}'),
      if (addons.pickupFee != null && addons.pickupFee != 0)
        ('Pickup Fee', '₱${formatMoney(addons.pickupFee!)}'),
    ];

    if (rows.isEmpty &&
        addons.odaConfig == null &&
        addons.pickupFeeConfig == null) {
      return const SizedBox.shrink();
    }

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
        if (addons.odaConfig != null) ...[
          const SizedBox(height: 10),
          _ConditionalAddonSummary(
            label: 'ODA',
            config: addons.odaConfig!,
            matchesDestination: true,
          ),
        ],
        if (addons.pickupFeeConfig != null) ...[
          const SizedBox(height: 10),
          _ConditionalAddonSummary(
            label: 'Pickup Fee',
            config: addons.pickupFeeConfig!,
            matchesDestination: false,
          ),
        ],
      ],
    );
  }
}

/// Renders one ODA/Pickup Fee bracket-config (`custom_addons.oda_config`/
/// `.pickup_fee_config`) as its own compact block — one sub-row per
/// configured destination/origin, each listing its breakweight tiers, since
/// this doesn't reduce to a single flat amount like the rest of
/// [_AddonsSummary]'s rows.
class _ConditionalAddonSummary extends StatelessWidget {
  const _ConditionalAddonSummary({
    required this.label,
    required this.config,
    required this.matchesDestination,
  });

  final String label;
  final ConditionalAddonConfig config;

  /// ODA entries key off destination, Pickup Fee off origin — decides which
  /// side of [RouteTiersTable]'s "origin → destination" line the location
  /// label lands on.
  final bool matchesDestination;

  @override
  Widget build(BuildContext context) {
    if (config.routes.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(CupertinoIcons.location_solid, size: 13, color: context.colors.primaryDeep),
            const SizedBox(width: 6),
            Text(
              '$label (by location)',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: context.colors.textBody),
            ),
          ],
        ),
        const SizedBox(height: 10),
        for (var i = 0; i < config.routes.length; i++) ...[
          if (i > 0) const SizedBox(height: 12),
          RouteTiersTable(
            origin: matchesDestination ? '' : (config.routes[i].locationLabel ?? ''),
            destination: matchesDestination ? (config.routes[i].locationLabel ?? '') : '',
            tiers: config.routes[i].breakweights,
          ),
        ],
      ],
    );
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
                backgroundColor: context.colors.primary,
                hoverBackgroundColor: context.colors.primaryHover,
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

