import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class StatusPill extends StatelessWidget {
  final String label;
  final Color color;
  final EdgeInsetsGeometry padding;
  final double backgroundAlpha;
  final FontWeight fontWeight;
  final double fontSize;

  const StatusPill({
    super.key,
    required this.label,
    required this.color,
    this.padding = const EdgeInsets.symmetric(
      horizontal: AppSpacing.md,
      vertical: AppSpacing.sm,
    ),
    this.backgroundAlpha = 0.12,
    this.fontWeight = FontWeight.w600,
    this.fontSize = 12,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: color.withValues(alpha: backgroundAlpha),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(color: color, fontWeight: fontWeight, fontSize: fontSize),
      ),
    );
  }
}
