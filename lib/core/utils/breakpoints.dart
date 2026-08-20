import 'package:flutter/widgets.dart';

/// Screen-width breakpoints shared across the app. A width strictly below
/// [tablet] is mobile; below [desktop] is tablet; [desktop] and above is
/// desktop. Chosen to match common device widths (phones up to ~600,
/// tablets/small windows up to ~1024) rather than any specific design spec.
class Breakpoints {
  const Breakpoints._();

  static const double tablet = 600;
  static const double desktop = 1024;

  static bool isMobile(BuildContext context) => MediaQuery.sizeOf(context).width < tablet;

  static bool isTablet(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    return width >= tablet && width < desktop;
  }

  static bool isDesktop(BuildContext context) => MediaQuery.sizeOf(context).width >= desktop;
}
