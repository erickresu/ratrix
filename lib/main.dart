import 'dart:ui' show PointerDeviceKind;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import 'core/di/injection_container.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_cubit.dart';
import 'features/auth/data/repositories/auth_repository.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/auth/presentation/pages/login_page.dart';
import 'features/rates/presentation/pages/rates_shell_page.dart';
import 'features/rates/presentation/rates_colors.dart';

void main() {
  setupDependencies();
  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => AuthBloc(getIt<AuthRepository>())..add(const AuthSubscriptionRequested())),
        BlocProvider(create: (_) => ThemeCubit()),
      ],
      child: BlocBuilder<ThemeCubit, ThemeMode>(
        builder: (context, mode) {
          final isDark = mode == ThemeMode.dark;
          final colors = isDark ? RatesColors.dark : RatesColors.light;
          return ShadApp.custom(
            theme: ShadThemeData(
              brightness: isDark ? Brightness.dark : Brightness.light,
              colorScheme: ShadColorScheme(
                background: colors.pageBg,
                foreground: colors.textBody,
                card: colors.surface,
                cardForeground: colors.textBody,
                popover: colors.surface,
                popoverForeground: colors.textBody,
                primary: colors.primary,
                primaryForeground: Colors.white,
                secondary: colors.surfaceMuted,
                secondaryForeground: colors.textBody,
                muted: colors.surfaceMuted,
                mutedForeground: colors.textMuted,
                accent: colors.primarySoftBg,
                accentForeground: colors.primaryDeep,
                destructive: colors.destructive,
                destructiveForeground: Colors.white,
                border: colors.border,
                input: colors.borderStrong,
                ring: colors.primary,
                selection: colors.primarySoftBg,
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
                darkTheme: AppTheme.dark,
                themeMode: mode,
                scrollBehavior: AppScrollBehavior(),
                home: const _AuthGate(),
              );
            },
          );
        },
      ),
    );
  }
}

/// Allows mouse click-drag scrolling everywhere (Flutter's default
/// [MaterialScrollBehavior] only enables drag-to-scroll for touch/stylus/
/// trackpad, so on web/desktop a mouse drag silently does nothing).
class AppScrollBehavior extends MaterialScrollBehavior {
  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
        PointerDeviceKind.trackpad,
        PointerDeviceKind.stylus,
      };
}

class _AuthGate extends StatelessWidget {
  const _AuthGate();

  @override
  Widget build(BuildContext context) {
    final status = context.watch<AuthBloc>().state.status;
    return switch (status) {
      AuthStatus.unknown => const _SplashView(),
      AuthStatus.unauthenticated => const LoginPage(),
      AuthStatus.authenticated => const RatesShellPage(),
    };
  }
}

class _SplashView extends StatelessWidget {
  const _SplashView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.pageBg,
      body: Center(
        child: CircularProgressIndicator(color: context.colors.primary),
      ),
    );
  }
}
