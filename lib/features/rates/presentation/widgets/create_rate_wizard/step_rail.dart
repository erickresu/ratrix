import 'package:easy_stepper/easy_stepper.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../rates_colors.dart';

class StepRail extends StatelessWidget {
  const StepRail({
    super.key,
    required this.currentStep,
    required this.onStepTap,
  });

  final int currentStep;
  final ValueChanged<int> onStepTap;

  static const _labels = [
    'Rate Setup',
    'Rate Matrix',
    'Add-ons',
    'Conditional Add-ons',
  ];
  static const _hints = [
    'Mode, service&pricing',
    'Weight breaks',
    'Optional surcharges',
    'Rules-based charges',
  ];
  static const _icons = [
    CupertinoIcons.slider_horizontal_3,
    CupertinoIcons.square_grid_3x2,
    CupertinoIcons.tag,
    CupertinoIcons.wand_stars,
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 260,
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
      decoration: BoxDecoration(
        color: context.colors.surface,
        border: Border.all(color: context.colors.border),
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: context.colors.shadowSoft,
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Theme(
        // easy_stepper wraps each step in a Material InkWell; without this the
        // default (purple) splash/highlight paints a ring over the step circle.
        data: Theme.of(context).copyWith(
          colorScheme: Theme.of(context).colorScheme.copyWith(
            primary: Theme.of(context).colorScheme.secondary,
          ),
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
          hoverColor: Colors.transparent,
          focusColor: Colors.transparent,
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
          lineStyle: LineStyle(
            lineType: LineType.normal,
            lineLength: 44,
            lineThickness: 2,
            unreachedLineColor: context.colors.border,
            activeLineColor: context.colors.border,
            finishedLineColor: context.colors.primary,
            lineSpace: 0,
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
                  color: highlighted
                      ? context.colors.primary
                      : context.colors.textFaint.withValues(alpha: 0.18),
                  shape: BoxShape.circle,
                ),
                child: isDone
                    ? const Icon(
                        CupertinoIcons.checkmark_alt,
                        size: 14,
                        color: Colors.white,
                      )
                    : Icon(
                        _icons[i],
                        size: 14,
                        color: highlighted
                            ? Colors.white
                            : context.colors.textMuted,
                      ),
              ),
              customTitle: Container(
                constraints: const BoxConstraints(maxWidth: 180),
                margin: const EdgeInsets.only(left: 10),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: isActive
                      ? context.colors.primarySoftBg
                      : Colors.transparent,
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
                        fontWeight: isActive
                            ? FontWeight.w700
                            : FontWeight.w500,
                        color: isActive
                            ? context.colors.textBody
                            : context.colors.textMuted,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _hints[i],
                      style: TextStyle(
                        fontSize: 12,
                        color: context.colors.textMuted,
                      ),
                    ),
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
