import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
// ignore: unnecessary_import
import 'package:intl/intl.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../../../../core/utils/breakpoints.dart';
import '../../../domain/entities/rates_enums.dart';
import '../../../domain/entities/rates_fk_ids.dart';
import '../../bloc/rate_wizard_bloc.dart';
import '../../rates_colors.dart';

const _fieldHeight = 44.0;

/// Charge code names are always uppercase — forces it as the user types
/// rather than only at submit time, so the field shows what will actually
/// be sent.
class _UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    return newValue.copyWith(text: newValue.text.toUpperCase());
  }
}

class Step0RateSetup extends StatelessWidget {
  const Step0RateSetup({super.key});

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<RateWizardBloc>();
    final state = context.watch<RateWizardBloc>().state;
    final isMobile = Breakpoints.isMobile(context);

    final serviceModeOptions = state.freightMode == null
        ? ServiceMode.values
        : RatesFkIds.serviceModeOptionsByFreightMode[state.freightMode]!;
    final chargeBasisOptions = state.freightMode == null
        ? ChargeBasis.values
        : RatesFkIds.chargeBasisOptionsByFreightMode[state.freightMode]!;
    final pricingOptions =
        RatesFkIds.pricingOptionsByChargeBasis[state.chargeBasis] ?? PricingOption.values;
    final pricingOptionUnavailable = pricingOptions.isEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Freight mode',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: context.colors.textMutedStrong,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            for (final mode in FreightMode.values) ...[
              Expanded(
                child: _FreightModeCard(
                  mode: mode,
                  selected: state.freightMode == mode,
                  compact: isMobile,
                  onTap: () => bloc.add(FreightModeChanged(mode)),
                ),
              ),
              if (mode != FreightMode.values.last)
                SizedBox(width: isMobile ? 8 : 12),
            ],
          ],
        ),
        if (state.freightMode != null) ...[
          const SizedBox(height: 28),
          Builder(
            builder: (context) {
              final expiryDateField = Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        'Expiry Date ',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: context.colors.textMutedStrong,
                        ),
                      ),
                      Text(
                        '*',
                        style: TextStyle(
                          fontSize: 13,
                          color: context.colors.destructive,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Builder(
                    builder: (context) {
                      final today = DateTime.now();
                      final startOfToday = DateTime(
                        today.year,
                        today.month,
                        today.day,
                      );
                      final maxDate = startOfToday.add(
                        const Duration(days: 3650),
                      );
                      return ShadDatePicker(
                        selected: state.expiryDate,
                        formatDate: DateFormat.yMMMd().format,
                        placeholder: Text(
                          'Select date',
                          style: TextStyle(
                            fontSize: 14,
                            color: context.colors.textMuted,
                          ),
                        ),
                        trailing: Icon(
                          CupertinoIcons.calendar,
                          size: 15,
                          color: context.colors.textMuted,
                        ),
                        width: double.infinity,
                        height: _fieldHeight,
                        buttonPadding: const EdgeInsets.symmetric(
                          horizontal: 14,
                        ),
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        foregroundColor: context.colors.textBody,
                        hoverForegroundColor: context.colors.textBody,
                        pressedForegroundColor: context.colors.textBody,
                        captionLayout: ShadCalendarCaptionLayout.dropdown,
                        fromMonth: DateTime(
                          startOfToday.year,
                          startOfToday.month,
                        ),
                        toMonth: DateTime(maxDate.year, maxDate.month),
                        selectableDayPredicate: (day) =>
                            !day.isBefore(startOfToday) &&
                            !day.isAfter(maxDate),
                        onChanged: (picked) {
                          if (picked != null)
                            bloc.add(ExpiryDateChanged(picked));
                        },
                      );
                    },
                  ),
                ],
              );

              final chargeCodeNameField = Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        'Charge code name ',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: context.colors.textMutedStrong,
                        ),
                      ),
                      Text(
                        '(optional)',
                        style: TextStyle(
                          fontSize: 13,
                          color: context.colors.textMuted,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: _fieldHeight,
                    child: ShadInput(
                      key: ValueKey(
                        'charge-code-suffix-${state.chargeCodePrefix}',
                      ),
                      placeholder: const Text('e.g. PUBLISH RATE'),
                      initialValue: state.chargeCodeSuffix,
                      style: const TextStyle(fontFamily: 'monospace'),
                      inputFormatters: [_UpperCaseTextFormatter()],
                      textCapitalization: TextCapitalization.characters,
                      leading: Padding(
                        padding: const EdgeInsets.only(left: 2),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '${state.chargeCodePrefix}_',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                fontFamily: 'monospace',
                                color: context.colors.textMutedStrong,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              width: 1,
                              height: 16,
                              color: context.colors.borderStrong,
                            ),
                          ],
                        ),
                      ),
                      onChanged: (v) => bloc.add(ChargeCodeSuffixChanged(v)),
                    ),
                  ),
                ],
              );

              if (!state.isCustom) return chargeCodeNameField;

              if (isMobile) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    expiryDateField,
                    const SizedBox(height: 20),
                    chargeCodeNameField,
                  ],
                );
              }

              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: expiryDateField),
                  const SizedBox(width: 32),
                  Expanded(child: chargeCodeNameField),
                ],
              );
            },
          ),
          const SizedBox(height: 28),
          Builder(
            builder: (context) {
              final serviceModeField = Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Service mode',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: context.colors.textMutedStrong,
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    height: _fieldHeight,
                    child: ShadSelect<ServiceMode>(
                      key: ValueKey('service-mode-${state.freightMode}'),
                      initialValue: state.serviceMode,
                      selectedOptionBuilder: (context, value) =>
                          Text(value.label),
                      onChanged: (value) {
                        if (value != null) bloc.add(ServiceModeChanged(value));
                      },
                      options: [
                        for (final m in serviceModeOptions)
                          ShadOption(value: m, child: Text(m.label)),
                      ],
                    ),
                  ),
                ],
              );

              final chargeBasisField = Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Charge basis',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: context.colors.textMutedStrong,
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    height: _fieldHeight,
                    child: ShadSelect<ChargeBasis>(
                      key: ValueKey('charge-basis-${state.freightMode}'),
                      initialValue: state.chargeBasis,
                      selectedOptionBuilder: (context, value) =>
                          Text(value.label),
                      onChanged: (value) {
                        // Full Truck Load's valid pricing options aren't
                        // confirmed yet (see RatesFkIds.pricingOptionsByChargeBasis)
                        // — block picking it here too, not just disabling the
                        // Pricing Option field below, so it can't be selected
                        // at all.
                        if (value != null &&
                            !RatesFkIds.chargeBasisNotYetImplemented.contains(value)) {
                          bloc.add(ChargeBasisChanged(value));
                        }
                      },
                      options: [
                        // Sort not-yet-implemented options (e.g. Full Truck
                        // Load) to the end, greyed out, instead of mixed in
                        // with the ones that actually work.
                        for (final b in [...chargeBasisOptions]..sort(
                            (a, b) => (RatesFkIds.chargeBasisNotYetImplemented.contains(a) ? 1 : 0)
                                .compareTo(RatesFkIds.chargeBasisNotYetImplemented.contains(b) ? 1 : 0),
                          ))
                          IgnorePointer(
                            // `ShadOption` has no built-in disabled state —
                            // its internal tap handler calls
                            // `inheritedSelect.select(...)` directly, ahead
                            // of this widget's `onChanged`, so blocking the
                            // value there isn't enough: the option still
                            // visually highlights as picked. IgnorePointer
                            // stops the tap from ever reaching that internal
                            // handler in the first place.
                            ignoring: RatesFkIds.chargeBasisNotYetImplemented.contains(b),
                            child: ShadOption(
                              value: b,
                              child: RatesFkIds.chargeBasisNotYetImplemented.contains(b)
                                  ? Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(b.label, style: TextStyle(color: context.colors.textFaint)),
                                        const SizedBox(width: 6),
                                        Text(
                                          '(coming soon)',
                                          style: TextStyle(fontSize: 11, color: context.colors.textFaint),
                                        ),
                                      ],
                                    )
                                  : Text(b.label),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              );

              if (isMobile) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    serviceModeField,
                    const SizedBox(height: 20),
                    chargeBasisField,
                  ],
                );
              }

              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: serviceModeField),
                  const SizedBox(width: 32),
                  Expanded(child: chargeBasisField),
                ],
              );
            },
          ),
          const SizedBox(height: 28),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Pricing option',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: context.colors.textMutedStrong,
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      height: _fieldHeight,
                      child: ShadSelect<PricingOption>(
                        key: ValueKey('pricing-option-${state.chargeBasis}'),
                        enabled: !pricingOptionUnavailable,
                        initialValue: state.pricingOption,
                        selectedOptionBuilder: (context, value) =>
                            Text(value.label),
                        onChanged: (value) {
                          if (value != null)
                            bloc.add(PricingOptionChanged(value));
                        },
                        options: [
                          for (final p in pricingOptions)
                            ShadOption(value: p, child: Text(p.label)),
                        ],
                      ),
                    ),
                    if (pricingOptionUnavailable) ...[
                      const SizedBox(height: 6),
                      Text(
                        'Not available yet for ${state.chargeBasis.label}.',
                        style: TextStyle(
                          fontSize: 12,
                          color: context.colors.destructive,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (!isMobile) ...[
                const SizedBox(width: 32),
                const Expanded(child: SizedBox.shrink()),
              ],
            ],
          ),
        ],
      ],
    );
  }
}

const _freightModeIcons = {
  FreightMode.air: CupertinoIcons.airplane,
  FreightMode.land: CupertinoIcons.car_fill,
  // cupertino_icons has no ship/boat glyph — Material's is the closest match.
  FreightMode.sea: Icons.directions_boat_filled,
};

class _FreightModeCard extends StatelessWidget {
  const _FreightModeCard({
    required this.mode,
    required this.selected,
    required this.onTap,
    this.compact = false,
  });

  final FreightMode mode;
  final bool selected;
  final bool compact;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final iconSize = compact ? 40.0 : 56.0;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: compact ? 10 : 16,
            vertical: compact ? 10 : 16,
          ),
          decoration: BoxDecoration(
            gradient: selected ? context.colors.primaryButtonGradient : null,
            color: selected ? null : context.colors.surfaceSubtle,
            border: Border.all(
              color: selected ? context.colors.primary : context.colors.border,
              width: selected ? 1.5 : 1,
            ),
            borderRadius: BorderRadius.circular(10),
            boxShadow: selected
                ? [
                    BoxShadow(
                      color: context.colors.shadowSoft,
                      blurRadius: 12,
                      offset: const Offset(0, 3),
                    ),
                  ]
                : null,
          ),
          child: compact
              ? Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: iconSize,
                      height: iconSize,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: selected
                            ? Colors.white.withValues(alpha: 0.2)
                            : context.colors.primaryChipBg,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        _freightModeIcons[mode],
                        size: 18,
                        color: selected
                            ? Colors.white
                            : context.colors.primaryDeep,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      mode.label,
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: selected
                            ? Colors.white
                            : context.colors.textMutedStrong,
                      ),
                    ),
                  ],
                )
              : Row(
                  children: [
                    Container(
                      width: iconSize,
                      height: iconSize,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: selected
                            ? Colors.white.withValues(alpha: 0.2)
                            : context.colors.primaryChipBg,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        _freightModeIcons[mode],
                        size: 26,
                        color: selected
                            ? Colors.white
                            : context.colors.primaryDeep,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      mode.label,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: selected
                            ? Colors.white
                            : context.colors.textMutedStrong,
                      ),
                    ),
                    if (selected) ...[
                      const Spacer(),
                      const Icon(
                        CupertinoIcons.check_mark_circled_solid,
                        size: 16,
                        color: Colors.white,
                      ),
                    ],
                  ],
                ),
        ),
      ),
    );
  }
}
