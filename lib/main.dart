import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import 'core/di/injection_container.dart';
import 'core/theme/app_theme.dart';
import 'features/rates/presentation/pages/rates_shell_page.dart';
import 'features/rates/presentation/rates_colors.dart';

void main() {
  setupDependencies();
  runApp(const App());
}

// TODO: auth is bypassed for now (RatesShellPage is the home route directly).
// Re-wire behind AuthBloc/LoginPage once the rates UI is signed off.
class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return ShadApp.custom(
      theme: ShadThemeData(
        brightness: Brightness.light,
        colorScheme: const ShadColorScheme(
          background: RatesColors.pageBg,
          foreground: RatesColors.textBody,
          card: RatesColors.surface,
          cardForeground: RatesColors.textBody,
          popover: RatesColors.surface,
          popoverForeground: RatesColors.textBody,
          primary: RatesColors.primary,
          primaryForeground: Colors.white,
          secondary: RatesColors.surfaceMuted,
          secondaryForeground: RatesColors.textBody,
          muted: RatesColors.surfaceMuted,
          mutedForeground: RatesColors.textMuted,
          accent: RatesColors.primarySoftBg,
          accentForeground: RatesColors.primaryDeep,
          destructive: RatesColors.destructive,
          destructiveForeground: Colors.white,
          border: RatesColors.border,
          input: RatesColors.borderStrong,
          ring: RatesColors.primary,
          selection: RatesColors.primarySoftBg,
        ),
        radius: BorderRadius.circular(8),
        disableSecondaryBorder: true,
        inputTheme: const ShadInputTheme(
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        ),
        selectTheme: const ShadSelectTheme(
          padding: EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        ),
      ),
      appBuilder: (context) {
        return MaterialApp(
          title: 'Ratrix',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light,
          home: const RatesShellPage(),
        );
      },
    );
  }
}
