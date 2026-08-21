import 'package:flutter/material.dart';

/// Design tokens for the rates UI, exposed as a [ThemeExtension] so every
/// widget can read `context.colors.foo` and get the right palette for the
/// active brightness. Access via the `colors` extension on [BuildContext]
/// below — do not read [RatesColors] fields as static constants.
class RatesColors extends ThemeExtension<RatesColors> {
  const RatesColors({
    required this.primary,
    required this.primaryHover,
    required this.primaryDeep,
    required this.primaryDeeper,
    required this.primarySoftBg,
    required this.primaryChipBg,
    required this.primaryBorder,
    required this.sidebarBg,
    required this.sidebarPanelBg,
    required this.pageBg,
    required this.surface,
    required this.surfaceSubtle,
    required this.surfaceMuted,
    required this.border,
    required this.borderStrong,
    required this.textBody,
    required this.textMuted,
    required this.textMutedStrong,
    required this.textFaint,
    required this.success,
    required this.successBg,
    required this.successText,
    required this.custom,
    required this.customBg,
    required this.accent,
    required this.accentHover,
    required this.accentSoftBg,
    required this.accentChipBg,
    required this.destructive,
    required this.destructiveSoft,
    required this.shadowSoft,
    required this.shadowCard,
    required this.wizardBgGradient,
    required this.primaryButtonGradient,
    required this.accentButtonGradient,
  });

  final Color primary;
  final Color primaryHover;
  final Color primaryDeep;
  final Color primaryDeeper;
  final Color primarySoftBg;
  final Color primaryChipBg;
  final Color primaryBorder;

  final Color sidebarBg;
  final Color sidebarPanelBg;

  final Color pageBg;
  final Color surface;
  final Color surfaceSubtle;
  final Color surfaceMuted;
  final Color border;
  final Color borderStrong;

  final Color textBody;
  final Color textMuted;
  final Color textMutedStrong;
  final Color textFaint;

  final Color success;
  final Color successBg;
  final Color successText;

  final Color custom;
  final Color customBg;

  final Color accent;
  final Color accentHover;
  final Color accentSoftBg;
  final Color accentChipBg;

  final Color destructive;
  final Color destructiveSoft;

  final Color shadowSoft;
  final Color shadowCard;

  final Gradient wizardBgGradient;
  final Gradient primaryButtonGradient;
  final Gradient accentButtonGradient;

  static const light = RatesColors(
    primary: Color(0xFF0FA98A),
    primaryHover: Color(0xFF0C8F74),
    primaryDeep: Color(0xFF166553),
    primaryDeeper: Color(0xFF14574A),
    primarySoftBg: Color(0xFFE0F7F1),
    primaryChipBg: Color(0xFFBEEFE3),
    primaryBorder: Color(0xFF8FE0CC),
    sidebarBg: Color(0xFF0B1210),
    sidebarPanelBg: Color(0xFF16201D),
    pageBg: Color(0xFFF1F5F9),
    surface: Colors.white,
    surfaceSubtle: Color(0xFFE3E9EF),
    surfaceMuted: Color(0x40EDF1F5),
    border: Color(0xFFD8E0E9),
    borderStrong: Color(0xFFB9C5D3),
    textBody: Color(0xFF17241F),
    textMuted: Color(0xFF5B6B82),
    textMutedStrong: Color(0xFF3D4C61),
    textFaint: Color(0xFF94A3B8),
    success: Color(0xFF16A34A),
    successBg: Color(0xFFDCFCE7),
    successText: Color(0xFF166534),
    custom: Color(0xFFC2660A),
    customBg: Color(0xFFFEEBD1),
    accent: Color(0xFFC2660A),
    accentHover: Color(0xFFB45309),
    accentSoftBg: Color(0xFFFEEBD1),
    accentChipBg: Color(0xFFFAD49B),
    destructive: Color(0xFFDC2626),
    destructiveSoft: Color(0xFFFF8A8A),
    shadowSoft: Color(0x1A0F172A),
    shadowCard: Color(0x220F172A),
    wizardBgGradient: LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [Color(0xFFF3F8F7), Color(0xFFF8FAFC)],
    ),
    primaryButtonGradient: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Color(0xFF22A88C), Color(0xFF1B7A65)],
    ),
    accentButtonGradient: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Color(0xFFD97706), Color(0xFFB45309)],
    ),
  );

  static const dark = RatesColors(
    primary: Color(0xFF34D9B6),
    primaryHover: Color(0xFF2BC0A0),
    primaryDeep: Color(0xFF7FEBD3),
    primaryDeeper: Color(0xFFA6F1E0),
    primarySoftBg: Color(0xFF10322B),
    primaryChipBg: Color(0xFF12392F),
    primaryBorder: Color(0xFF1E5348),

    sidebarBg: Color(0xFF07100D),
    sidebarPanelBg: Color(0xFF101B17),

    pageBg: Color(0xFF0D1412),
    surface: Color(0xFF141E1B),
    surfaceSubtle: Color(0xFF182521),
    surfaceMuted: Color(0x401C2A25),
    border: Color(0xFF243530),
    borderStrong: Color(0xFF33463F),

    textBody: Color(0xFFEAF2EF),
    textMuted: Color(0xFF8DA39C),
    textMutedStrong: Color(0xFFB2C4BE),
    textFaint: Color(0xFF62766F),

    success: Color(0xFFA3D93B),
    successBg: Color(0xFF243312),
    successText: Color(0xFFC4EA6E),

    custom: Color(0xFF5B8DEF),
    customBg: Color(0xFF16233F),

    accent: Color(0xFFF0A63C),
    accentHover: Color(0xFFF3B85E),
    accentSoftBg: Color(0xFF3A2A11),
    accentChipBg: Color(0xFF44300F),

    destructive: Color(0xFFEF5350),
    destructiveSoft: Color(0xFFFF8A8A),

    shadowSoft: Color(0x33000000),
    shadowCard: Color(0x40000000),

    wizardBgGradient: LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [Color(0xFF101B17), Color(0xFF0D1412)],
    ),
    primaryButtonGradient: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Color(0xFF2BC0A0), Color(0xFF1E8E76)],
    ),
    accentButtonGradient: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Color(0xFFF0A63C), Color(0xFFCF8321)],
    ),
  );

  @override
  RatesColors copyWith({
    Color? primary,
    Color? primaryHover,
    Color? primaryDeep,
    Color? primaryDeeper,
    Color? primarySoftBg,
    Color? primaryChipBg,
    Color? primaryBorder,
    Color? sidebarBg,
    Color? sidebarPanelBg,
    Color? pageBg,
    Color? surface,
    Color? surfaceSubtle,
    Color? surfaceMuted,
    Color? border,
    Color? borderStrong,
    Color? textBody,
    Color? textMuted,
    Color? textMutedStrong,
    Color? textFaint,
    Color? success,
    Color? successBg,
    Color? successText,
    Color? custom,
    Color? customBg,
    Color? accent,
    Color? accentHover,
    Color? accentSoftBg,
    Color? accentChipBg,
    Color? destructive,
    Color? destructiveSoft,
    Color? shadowSoft,
    Color? shadowCard,
    Gradient? wizardBgGradient,
    Gradient? primaryButtonGradient,
    Gradient? accentButtonGradient,
  }) {
    return RatesColors(
      primary: primary ?? this.primary,
      primaryHover: primaryHover ?? this.primaryHover,
      primaryDeep: primaryDeep ?? this.primaryDeep,
      primaryDeeper: primaryDeeper ?? this.primaryDeeper,
      primarySoftBg: primarySoftBg ?? this.primarySoftBg,
      primaryChipBg: primaryChipBg ?? this.primaryChipBg,
      primaryBorder: primaryBorder ?? this.primaryBorder,
      sidebarBg: sidebarBg ?? this.sidebarBg,
      sidebarPanelBg: sidebarPanelBg ?? this.sidebarPanelBg,
      pageBg: pageBg ?? this.pageBg,
      surface: surface ?? this.surface,
      surfaceSubtle: surfaceSubtle ?? this.surfaceSubtle,
      surfaceMuted: surfaceMuted ?? this.surfaceMuted,
      border: border ?? this.border,
      borderStrong: borderStrong ?? this.borderStrong,
      textBody: textBody ?? this.textBody,
      textMuted: textMuted ?? this.textMuted,
      textMutedStrong: textMutedStrong ?? this.textMutedStrong,
      textFaint: textFaint ?? this.textFaint,
      success: success ?? this.success,
      successBg: successBg ?? this.successBg,
      successText: successText ?? this.successText,
      custom: custom ?? this.custom,
      customBg: customBg ?? this.customBg,
      accent: accent ?? this.accent,
      accentHover: accentHover ?? this.accentHover,
      accentSoftBg: accentSoftBg ?? this.accentSoftBg,
      accentChipBg: accentChipBg ?? this.accentChipBg,
      destructive: destructive ?? this.destructive,
      destructiveSoft: destructiveSoft ?? this.destructiveSoft,
      shadowSoft: shadowSoft ?? this.shadowSoft,
      shadowCard: shadowCard ?? this.shadowCard,
      wizardBgGradient: wizardBgGradient ?? this.wizardBgGradient,
      primaryButtonGradient: primaryButtonGradient ?? this.primaryButtonGradient,
      accentButtonGradient: accentButtonGradient ?? this.accentButtonGradient,
    );
  }

  @override
  RatesColors lerp(ThemeExtension<RatesColors>? other, double t) {
    if (other is! RatesColors) return this;
    return RatesColors(
      primary: Color.lerp(primary, other.primary, t)!,
      primaryHover: Color.lerp(primaryHover, other.primaryHover, t)!,
      primaryDeep: Color.lerp(primaryDeep, other.primaryDeep, t)!,
      primaryDeeper: Color.lerp(primaryDeeper, other.primaryDeeper, t)!,
      primarySoftBg: Color.lerp(primarySoftBg, other.primarySoftBg, t)!,
      primaryChipBg: Color.lerp(primaryChipBg, other.primaryChipBg, t)!,
      primaryBorder: Color.lerp(primaryBorder, other.primaryBorder, t)!,
      sidebarBg: Color.lerp(sidebarBg, other.sidebarBg, t)!,
      sidebarPanelBg: Color.lerp(sidebarPanelBg, other.sidebarPanelBg, t)!,
      pageBg: Color.lerp(pageBg, other.pageBg, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      surfaceSubtle: Color.lerp(surfaceSubtle, other.surfaceSubtle, t)!,
      surfaceMuted: Color.lerp(surfaceMuted, other.surfaceMuted, t)!,
      border: Color.lerp(border, other.border, t)!,
      borderStrong: Color.lerp(borderStrong, other.borderStrong, t)!,
      textBody: Color.lerp(textBody, other.textBody, t)!,
      textMuted: Color.lerp(textMuted, other.textMuted, t)!,
      textMutedStrong: Color.lerp(textMutedStrong, other.textMutedStrong, t)!,
      textFaint: Color.lerp(textFaint, other.textFaint, t)!,
      success: Color.lerp(success, other.success, t)!,
      successBg: Color.lerp(successBg, other.successBg, t)!,
      successText: Color.lerp(successText, other.successText, t)!,
      custom: Color.lerp(custom, other.custom, t)!,
      customBg: Color.lerp(customBg, other.customBg, t)!,
      accent: Color.lerp(accent, other.accent, t)!,
      accentHover: Color.lerp(accentHover, other.accentHover, t)!,
      accentSoftBg: Color.lerp(accentSoftBg, other.accentSoftBg, t)!,
      accentChipBg: Color.lerp(accentChipBg, other.accentChipBg, t)!,
      destructive: Color.lerp(destructive, other.destructive, t)!,
      destructiveSoft: Color.lerp(destructiveSoft, other.destructiveSoft, t)!,
      shadowSoft: Color.lerp(shadowSoft, other.shadowSoft, t)!,
      shadowCard: Color.lerp(shadowCard, other.shadowCard, t)!,
      wizardBgGradient: t < 0.5 ? wizardBgGradient : other.wizardBgGradient,
      primaryButtonGradient: t < 0.5 ? primaryButtonGradient : other.primaryButtonGradient,
      accentButtonGradient: t < 0.5 ? accentButtonGradient : other.accentButtonGradient,
    );
  }
}

extension RatesColorsContext on BuildContext {
  RatesColors get colors => Theme.of(this).extension<RatesColors>() ?? RatesColors.light;
}
