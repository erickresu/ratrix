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

  static const light = RatesColors(
    // Muted brass/bronze instead of a bright saturated gold — same warm
    // hue family, lower saturation and a touch darker so it doesn't read
    // as "loud" against white surfaces.
    primary: Color(0xFFB8934A),
    primaryHover: Color(0xFFA07F3D),
    primaryDeep: Color(0xFF6B5228),
    primaryDeeper: Color(0xFF4F3D1E),
    primarySoftBg: Color(0xFFF5EFE0),
    primaryChipBg: Color(0xFFE8DCC0),
    primaryBorder: Color(0xFFC9B587),
    sidebarBg: Color(0xFF0F1B2E),
    sidebarPanelBg: Color(0xFF1A2C47),
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
    custom: Color(0xFF6D4FD1),
    customBg: Color(0xFFEDE9FC),
    accent: Color(0xFF6D4FD1),
    accentHover: Color(0xFF5B3FC0),
    accentSoftBg: Color(0xFFEDE9FC),
    accentChipBg: Color(0xFFD9D0F9),
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
      colors: [Color(0xFFC4A05C), Color(0xFFA07F3D)],
    ),
  );

  static const dark = RatesColors(
    // Dark mode's gold was the brightest offender (a vivid, near-neon
    // yellow against near-black surfaces) — muted to the same brass
    // family as light mode, just lightened enough to stay legible on
    // dark backgrounds.
    primary: Color(0xFFC9A55C),
    primaryHover: Color(0xFFB8924A),
    primaryDeep: Color(0xFFD9BC85),
    primaryDeeper: Color(0xFFE6D3AC),
    primarySoftBg: Color(0xFF2E2818),
    primaryChipBg: Color(0xFF3A3018),
    primaryBorder: Color(0xFF4A3E22),

    sidebarBg: Color(0xFF0F1B2E),
    sidebarPanelBg: Color(0xFF1A2C47),

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

    success: Color(0xFF4ADE80),
    successBg: Color(0xFF14291C),
    successText: Color(0xFF86EFAC),

    custom: Color(0xFF9B8AFB),
    customBg: Color(0xFF2A2347),

    accent: Color(0xFF9B8AFB),
    accentHover: Color(0xFFAC9DFC),
    accentSoftBg: Color(0xFF2A2347),
    accentChipBg: Color(0xFF362C58),

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
      colors: [Color(0xFFB8924A), Color(0xFF97753A)],
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
    );
  }
}

extension RatesColorsContext on BuildContext {
  RatesColors get colors => Theme.of(this).extension<RatesColors>() ?? RatesColors.light;
}
