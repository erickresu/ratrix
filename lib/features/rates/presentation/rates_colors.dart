import 'package:flutter/material.dart';

/// Design tokens lifted from the Rates Dashboard prototype (oklch values
/// mapped to their nearest Tailwind slate/emerald/violet/red equivalents).
abstract class RatesColors {
  static const primary = Color(0xFF2CC6A6);
  static const primaryHover = Color(0xFF22A88C);
  static const primaryDeep = Color(0xFF1B7A65);
  static const primaryDeeper = Color(0xFF1E6F5C);
  static const primarySoftBg = Color(0xFFE4F9F4);
  static const primaryChipBg = Color(0xFFCFF2EA);
  static const primaryBorder = Color(0xFFA9E8DA);

  static const sidebarBg = Color(0xFF0B1210);
  static const sidebarPanelBg = Color(0xFF16201D);

  static const pageBg = Color(0xFFF8FAFC);
  static const surface = Colors.white;
  static const surfaceSubtle = Color(0xFFF1F5F9);
  static const surfaceMuted = Color(0xFFEDF1F5);
  static const border = Color(0xFFE2E8F0);
  static const borderStrong = Color(0xFFCBD5E1);

  static const textBody = Color(0xFF1E293B);
  static const textMuted = Color(0xFF64748B);
  static const textMutedStrong = Color(0xFF475569);
  static const textFaint = Color(0xFF94A3B8);

  static const success = Color(0xFF059669);
  static const successBg = Color(0xFFD1FAE5);
  static const successText = Color(0xFF047857);

  static const custom = Color(0xFF6D28D9);
  static const customBg = Color(0xFFF5F3FF);

  static const destructive = Color(0xFFDC2626);
  static const destructiveSoft = Color(0xFFFF8A8A);
}
