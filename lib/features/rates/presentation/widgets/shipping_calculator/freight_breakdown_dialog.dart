import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../../domain/entities/client.dart';
import '../../../domain/entities/ratrix_rate.dart';
import '../../../domain/entities/rates_enums.dart';
import '../../bloc/rates_shell_bloc.dart';
import '../../bloc/shipping_calculator_bloc.dart';
import '../../rates_colors.dart';
import 'invoice_pdf.dart';

/// Shows the freight-breakdown result in a blurred-backdrop dialog, mirroring
/// the wizard's other modal (`NewRateModal`) but with its own barrier since
/// this one needs a real blur behind it instead of a flat scrim.
Future<void> showFreightBreakdownDialog(
  BuildContext context, {
  required ShippingCalculatorBloc calcBloc,
  required RatesShellBloc shellBloc,
  required Client client,
}) async {
  await showShadDialog<void>(
    context: context,
    barrierColor: Colors.transparent,
    // `showShadDialog` pushes onto the root Navigator, outside the
    // RatesShellPage's `BlocProvider<RatesShellBloc>` subtree — re-provide
    // both blocs explicitly rather than relying on ambient lookup (the
    // "Edit this rate" button needs RatesShellBloc to navigate).
    builder: (dialogContext) => MultiBlocProvider(
      providers: [
        BlocProvider.value(value: calcBloc),
        BlocProvider.value(value: shellBloc),
      ],
      child: _BlurredBarrier(child: _FreightBreakdownDialog(client: client)),
    ),
  );
  // Whichever way the dialog closed (X button, barrier tap, back button),
  // clear the result so the next Calculate press is guaranteed to produce a
  // null -> non-null transition and re-show the dialog.
  calcBloc.add(const CalcResultDismissed());
}

class _BlurredBarrier extends StatelessWidget {
  const _BlurredBarrier({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
            child: Container(color: Colors.black.withValues(alpha: 0.45)),
          ),
        ),
        Center(child: child),
      ],
    );
  }
}

class _FreightBreakdownDialog extends StatelessWidget {
  const _FreightBreakdownDialog({required this.client});

  final Client client;

  @override
  Widget build(BuildContext context) {
    final state = context.watch<ShippingCalculatorBloc>().state;
    final result = state.calcResult;
    if (result == null) return const SizedBox.shrink();

    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 480),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 8, right: 4),
            child: Align(
              alignment: Alignment.centerRight,
              child: _CloseButton(onTap: () => Navigator.of(context).pop()),
            ),
          ),
          ShadDialog(
            radius: BorderRadius.circular(16),
            backgroundColor: context.colors.surface,
            padding: EdgeInsets.zero,
            closeIcon: const SizedBox.shrink(),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _DialogHeader(rateType: state.rateType),
                  Flexible(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
                      child: result.error != null
                          ? _ErrorBody(
                              message: result.error!,
                              origin: state.origin,
                              destination: state.destination,
                              tiers: result.routeTiers,
                              onEditRate: state.selectedRate == null
                                  ? null
                                  : () {
                                      final rateId = state.selectedRate!.id;
                                      Navigator.of(context).pop();
                                      context.read<RatesShellBloc>().add(EditRateRequested(rateId));
                                    },
                            )
                          : const _ResultBody(),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (result.error == null) ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ShadButton(
                gradient: context.colors.primaryButtonGradient,
                leading: const Icon(CupertinoIcons.arrow_down_doc, size: 16),
                onPressed: () => generateInvoicePdf(state: state, client: client),
                child: const Text('Generate Invoice PDF'),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _DialogHeader extends StatelessWidget {
  const _DialogHeader({required this.rateType});

  final RateType rateType;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final dateLabel = '${now.month}/${now.day}/${now.year}';

    return Container(
      padding: const EdgeInsets.fromLTRB(24, 18, 24, 18),
      decoration: BoxDecoration(gradient: context.colors.primaryButtonGradient),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Text(
                    '${rateType.label.toUpperCase()} RATE',
                    style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Colors.white, letterSpacing: 0.4),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(CupertinoIcons.arrow_down_circle_fill, size: 16, color: Colors.white),
                    const SizedBox(width: 8),
                    const Flexible(
                      child: Text(
                        'Freight Breakdown',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Text(dateLabel, style: TextStyle(fontSize: 12, color: Colors.white.withValues(alpha: 0.85))),
        ],
      ),
    );
  }
}

class _CloseButton extends StatelessWidget {
  const _CloseButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Container(
          width: 24,
          height: 24,
          alignment: Alignment.center,
          decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), shape: BoxShape.circle),
          child: const Icon(CupertinoIcons.xmark, size: 12, color: Colors.white),
        ),
      ),
    );
  }
}

class _ErrorBody extends StatelessWidget {
  const _ErrorBody({
    required this.message,
    this.origin = '',
    this.destination = '',
    this.tiers = const [],
    this.onEditRate,
  });

  final String message;
  final String origin;
  final String destination;

  /// The resolved route's breakweight brackets, if any — shown as a mini
  /// table so a "no tier covers this weight" error is self-explanatory
  /// without leaving the dialog to go check the rate.
  final List<RatrixBreakweight> tiers;

  /// Jumps straight to editing the selected rate in the wizard — shown for
  /// any calc error, since every one of them boils down to something
  /// missing/misconfigured on that specific rate.
  final VoidCallback? onEditRate;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: context.colors.destructive.withValues(alpha: 0.08),
            border: Border.all(color: context.colors.destructive.withValues(alpha: 0.3)),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(CupertinoIcons.exclamationmark_triangle, size: 16, color: context.colors.destructive),
                  const SizedBox(width: 10),
                  Expanded(child: Text(message, style: TextStyle(fontSize: 13, color: context.colors.destructive))),
                ],
              ),
            ],
          ),
        ),
        if (tiers.isNotEmpty || onEditRate != null) ...[
          const SizedBox(height: 12),
          RouteTiersTable(origin: origin, destination: destination, tiers: tiers, onEdit: onEditRate),
        ],
      ],
    );
  }
}

/// Compact origin/destination + breakweight-bracket table, shown alongside
/// a calc error so the user can see what's actually configured on the route
/// without leaving the dialog.
class RouteTiersTable extends StatelessWidget {
  const RouteTiersTable({super.key, required this.origin, required this.destination, required this.tiers, this.onEdit});

  final String origin;
  final String destination;
  final List<RatrixBreakweight> tiers;

  /// Jumps to editing the rate this route belongs to — shown as a small
  /// pencil icon next to the origin/destination line when set.
  final VoidCallback? onEdit;

  @override
  Widget build(BuildContext context) {
    TextStyle headerStyle(BuildContext context) =>
        TextStyle(fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 0.3, color: context.colors.textMuted);
    TextStyle cellStyle(BuildContext context) =>
        TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: context.colors.textBody);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: context.colors.surfaceSubtle,
        border: Border.all(color: context.colors.border),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(CupertinoIcons.arrow_right_arrow_left, size: 13, color: context.colors.textMuted),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '${origin.isEmpty ? '—' : origin} → ${destination.isEmpty ? '—' : destination}',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: context.colors.textMutedStrong),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (onEdit != null)
                Material(
                  color: context.colors.primary,
                  borderRadius: BorderRadius.circular(8),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(8),
                    onTap: onEdit,
                    child: const Padding(
                      padding: EdgeInsets.all(7),
                      child: Icon(CupertinoIcons.pencil, size: 18, color: Colors.white),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 10),
          if (tiers.isEmpty)
            Text('No breakweight tiers found for this route.', style: cellStyle(context).copyWith(color: context.colors.textMuted))
          else ...[
            Row(
              children: [
                Expanded(flex: 2, child: Text('MIN (KG)', style: headerStyle(context))),
                Expanded(flex: 2, child: Text('MAX (KG)', style: headerStyle(context))),
                Expanded(flex: 3, child: Text('RATE', style: headerStyle(context), textAlign: TextAlign.right)),
              ],
            ),
            const SizedBox(height: 6),
            Divider(height: 1, color: context.colors.border),
            for (final tier in tiers) ...[
              const SizedBox(height: 6),
              Row(
                children: [
                  Expanded(flex: 2, child: Text(tier.min.toStringAsFixed(2), style: cellStyle(context))),
                  Expanded(flex: 2, child: Text(tier.max.toStringAsFixed(2), style: cellStyle(context))),
                  Expanded(
                    flex: 3,
                    child: Text('₱${tier.rate.toStringAsFixed(2)}', style: cellStyle(context), textAlign: TextAlign.right),
                  ),
                ],
              ),
            ],
          ],
        ],
      ),
    );
  }
}

class _ResultBody extends StatelessWidget {
  const _ResultBody();

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<ShippingCalculatorBloc>();
    final state = context.watch<ShippingCalculatorBloc>().state;
    final result = state.calcResult!;

    num displayValue(num v) => state.roundedDisplay ? v.roundToDouble() : v;
    String money(num? v) => v == null ? '—' : displayValue(v).toStringAsFixed(2);

    final grandTotal = displayValue(state.grandTotal);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: _WeightStat(
                label: 'ACT',
                value: '${result.actualWeight?.toStringAsFixed(1) ?? '—'}KG',
              ),
            ),
            Expanded(
              child: _WeightStat(
                label: 'VOL',
                value: '${result.volumetricWeight?.toStringAsFixed(1) ?? '—'}KG',
              ),
            ),
            Expanded(
              child: _WeightStat(
                label: 'CBM',
                value: result.cbm?.toStringAsFixed(4) ?? '—',
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Center(
          child: _ChargeBasisSwitch(
            value: state.chargeBasis,
            onChanged: (basis) => bloc.add(CalcChargeBasisChanged(basis)),
          ),
        ),
        const SizedBox(height: 16),
        Center(
          child: Text(
            'FINAL CHARGEABLE BASIS',
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 0.6, color: context.colors.textMuted),
          ),
        ),
        const SizedBox(height: 8),
        Center(
          child: RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: result.chargeableWeight?.toStringAsFixed(0) ?? '—',
                  style: TextStyle(fontSize: 34, fontWeight: FontWeight.w800, color: context.colors.textBody, height: 1),
                ),
                TextSpan(
                  text: ' kg',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: context.colors.textMuted),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),
        const Divider(height: 1),
        const SizedBox(height: 20),
        Center(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(color: context.colors.successBg, borderRadius: BorderRadius.circular(6)),
            child: Text(
              'GRAND TOTAL PAYABLE',
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 0.4, color: context.colors.successText),
            ),
          ),
        ),
        const SizedBox(height: 10),
        Center(
          child: RichText(
            text: TextSpan(
              children: [
                TextSpan(text: '₱', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: context.colors.primaryDeep)),
                TextSpan(
                  text: grandTotal.toStringAsFixed(2),
                  style: TextStyle(fontSize: 30, fontWeight: FontWeight.w800, color: context.colors.primaryDeep),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        Center(
          child: _SegmentedToggle(
            leftLabel: 'Exact',
            rightLabel: 'Rounded',
            selectedLeft: !state.roundedDisplay,
            onSelect: (left) => bloc.add(CalcRoundedDisplayToggled(!left)),
          ),
        ),
        const SizedBox(height: 24),
        Row(
          children: [
            Container(width: 6, height: 6, decoration: BoxDecoration(color: context.colors.primary, shape: BoxShape.circle)),
            const SizedBox(width: 8),
            Text('CHARGE DETAILS', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, letterSpacing: 0.4, color: context.colors.textMutedStrong)),
          ],
        ),
        const SizedBox(height: 12),
        _ChargeRow(label: 'Base Freight', value: money(result.baseFreight), bold: true),
        if (result.fuelSurcharge != null) _ChargeRow(label: 'Fuel Surcharge', value: money(result.fuelSurcharge)),
        for (final entry in result.flatFees.entries) _ChargeRow(label: entry.key, value: money(entry.value)),
        const SizedBox(height: 12),
        const Divider(height: 1),
        const SizedBox(height: 12),
        _ChargeRow(label: 'Sub-Total', value: '₱${money(result.subTotal)}', bold: true),
        if (state.vatMode == VatMode.standard)
          _ChargeRow(
            label: 'VAT (${(ShippingCalculatorState.vatRate * 100).toStringAsFixed(0)}%)',
            value: '₱${money(state.vatAmount)}',
            valueColor: context.colors.primaryDeep,
            labelColor: context.colors.primaryDeep,
          ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 16,
          runSpacing: 8,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            _VatRadio(
              label: 'VAT Exempt',
              selected: state.vatMode == VatMode.exempt,
              onTap: () => bloc.add(CalcVatModeChanged(state.vatMode == VatMode.exempt ? VatMode.standard : VatMode.exempt)),
            ),
            _VatRadio(
              label: 'VAT Zero Rated',
              selected: state.vatMode == VatMode.zeroRated,
              onTap: () => bloc.add(CalcVatModeChanged(state.vatMode == VatMode.zeroRated ? VatMode.standard : VatMode.zeroRated)),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('VAT Inclusive?', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: context.colors.textMutedStrong)),
                const SizedBox(width: 8),
                _SegmentedToggle(
                  leftLabel: 'Inclusive',
                  rightLabel: 'Exclusive',
                  selectedLeft: state.vatInclusive,
                  onSelect: (left) => bloc.add(CalcVatInclusiveToggled(left)),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}

class _WeightStat extends StatelessWidget {
  const _WeightStat({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          '$label: $value',
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: context.colors.textMutedStrong),
        ),
      ],
    );
  }
}

/// 3-way switch for [CalcChargeBasis], live inside the dialog — picking a
/// basis here recomputes the same result in place (see
/// `ShippingCalculatorBloc`'s `CalcChargeBasisChanged` handler) rather than
/// closing and reopening the dialog.
class _ChargeBasisSwitch extends StatelessWidget {
  const _ChargeBasisSwitch({required this.value, required this.onChanged});

  final CalcChargeBasis value;
  final ValueChanged<CalcChargeBasis> onChanged;

  static const _shortLabels = {
    CalcChargeBasis.actual: 'Actual',
    CalcChargeBasis.volumetric: 'Volumetric',
    CalcChargeBasis.higher: 'Higher',
  };

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(color: context.colors.surfaceMuted, borderRadius: BorderRadius.circular(8)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final basis in CalcChargeBasis.values)
            _SegmentButton(
              label: _shortLabels[basis]!,
              selected: value == basis,
              onTap: () => onChanged(basis),
            ),
        ],
      ),
    );
  }
}

class _SegmentedToggle extends StatelessWidget {
  const _SegmentedToggle({
    required this.leftLabel,
    required this.rightLabel,
    required this.selectedLeft,
    required this.onSelect,
  });

  final String leftLabel;
  final String rightLabel;
  final bool selectedLeft;
  final ValueChanged<bool> onSelect;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(color: context.colors.surfaceMuted, borderRadius: BorderRadius.circular(8)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _SegmentButton(label: leftLabel, selected: selectedLeft, onTap: () => onSelect(true)),
          _SegmentButton(label: rightLabel, selected: !selectedLeft, onTap: () => onSelect(false)),
        ],
      ),
    );
  }
}

class _SegmentButton extends StatelessWidget {
  const _SegmentButton({required this.label, required this.selected, required this.onTap});

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(6),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            color: selected ? context.colors.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: selected ? Colors.white : context.colors.textMutedStrong,
            ),
          ),
        ),
      ),
    );
  }
}

class _VatRadio extends StatelessWidget {
  const _VatRadio({required this.label, required this.selected, required this.onTap});

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(6),
        onTap: onTap,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              selected ? CupertinoIcons.circle_fill : CupertinoIcons.circle,
              size: 14,
              color: selected ? context.colors.primary : context.colors.textFaint,
            ),
            const SizedBox(width: 6),
            Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: context.colors.textMutedStrong)),
          ],
        ),
      ),
    );
  }
}

class _ChargeRow extends StatelessWidget {
  const _ChargeRow({
    required this.label,
    required this.value,
    this.bold = false,
    this.labelColor,
    this.valueColor,
  });

  final String label;
  final String value;
  final bool bold;
  final Color? labelColor;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: bold ? FontWeight.w700 : FontWeight.w500,
              color: labelColor ?? (bold ? context.colors.textBody : context.colors.textMuted),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: bold ? FontWeight.w700 : FontWeight.w600,
              color: valueColor ?? (bold ? context.colors.textBody : context.colors.textMutedStrong),
            ),
          ),
        ],
      ),
    );
  }
}
