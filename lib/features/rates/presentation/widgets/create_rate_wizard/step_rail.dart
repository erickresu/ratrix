import 'package:easy_stepper/easy_stepper.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../rates_colors.dart';

class StepRail extends StatelessWidget {
  const StepRail({super.key, required this.currentStep, required this.onStepTap});

  final int currentStep;
  final ValueChanged<int> onStepTap;

  static const _labels = ['Rate Setup', 'Rate Matrix', 'Add-ons', 'Conditional Add-ons'];
  static const _hints = ['Mode, service & pricing', 'Weight breaks', 'Optional surcharges', 'Rules-based charges'];

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 260,
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
      decoration: BoxDecoration(
        color: RatesColors.surface,
        border: Border.all(color: RatesColors.border),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Theme(
        // easy_stepper wraps each step in a Material InkWell; without this the
        // default (purple) splash/highlight paints a ring over the step circle.
        data: Theme.of(context).copyWith(
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
          hoverColor: Colors.transparent,
          splashFactory: NoSplash.splashFactory,
        ),
        child: EasyStepper(
          activeStep: currentStep,
          direction: Axis.vertical,
          disableScroll: true,
          showLoadingAnimation: false,
          showStepBorder: false,
          internalPadding: 8,
          verticalTitlePlacement: VerticalTitlePlacement.side,
          verticalAlignment: CrossAxisAlignment.start,
          lineStyle: const LineStyle(
            lineType: LineType.normal,
            lineLength: 24,
            lineThickness: 2,
            unreachedLineColor: RatesColors.border,
            activeLineColor: RatesColors.border,
            finishedLineColor: RatesColors.primary,
          ),
          onStepReached: onStepTap,
          steps: List.generate(_labels.length, (i) {
            final isActive = currentStep == i;
            final isDone = currentStep > i;
            final highlighted = isActive || isDone;
            return EasyStep(
              customStep: Container(
                width: 28,
                height: 28,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: highlighted ? RatesColors.primary : RatesColors.surfaceMuted,
                  shape: BoxShape.circle,
                ),
                child: isDone
                    ? const Icon(CupertinoIcons.checkmark_alt, size: 14, color: Colors.white)
                    : Text(
                        '${i + 1}',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: highlighted ? Colors.white : RatesColors.textMuted,
                        ),
                      ),
              ),
              customTitle: Container(
                constraints: const BoxConstraints(maxWidth: 180),
                padding: const EdgeInsets.only(left: 10, top: 3),
                decoration: BoxDecoration(
                  color: isActive ? RatesColors.primarySoftBg : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _labels[i],
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                        color: isActive ? RatesColors.textBody : RatesColors.textMuted,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(_hints[i], style: const TextStyle(fontSize: 12, color: RatesColors.textMuted)),
                  ],
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}
