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
  static const surfaceMuted = Color(0x40EDF1F5);
  static const border = Color(0xFFE2E8F0);
  static const borderStrong = Color(0xFFCBD5E1);

  static const textBody = Color(0xFF17241F);
  static const textMuted = Color(0xFF64748B);
  static const textMutedStrong = Color(0xFF475569);
  static const textFaint = Color(0xFF94A3B8);

  static const success = Color(0xFF65A30D);
  static const successBg = Color(0xFFECFCCB);
  static const successText = Color(0xFF3F6212);

  static const custom = Color(0xFF2563EB);
  static const customBg = Color(0xFFEFF4FF);

  static const accent = Color(0xFFD97706);
  static const accentHover = Color(0xFFB45309);
  static const accentSoftBg = Color(0xFFFEF3E2);
  static const accentChipBg = Color(0xFFFCE3BE);

  static const destructive = Color(0xFFDC2626);
  static const destructiveSoft = Color(0xFFFF8A8A);

  static const shadowSoft = Color(0x0F0F172A);
  static const shadowCard = Color(0x140F172A);

  static const wizardBgGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFFF3F8F7), pageBg],
  );

  static const primaryButtonGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primaryHover, primaryDeep],
  );

  static const accentButtonGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [accent, accentHover],
  );
}
