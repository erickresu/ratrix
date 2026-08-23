import 'package:flutter/widgets.dart';

/// Stable [GlobalKey]s for the sidebar nav items the onboarding tour
/// spotlights. Declared here (not inline in a build method) because a
/// GlobalKey created during build loses its bound element on every rebuild
/// — `tutorial_coach_mark` needs the same key instance to still be attached
/// once the tour actually shows.
class SidebarTourKeys {
  static final homeNav = GlobalKey();
  static final createRateNav = GlobalKey();
  static final publishedRatesNav = GlobalKey();
  static final customRatesNav = GlobalKey();
  static final shippingCalculatorNav = GlobalKey();
  static final auditTrailNav = GlobalKey();
}
