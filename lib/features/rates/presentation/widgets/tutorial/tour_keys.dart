import 'package:flutter/widgets.dart';

/// Stable [GlobalKey]s for every real widget the app tour spotlights via
/// `showcaseview`. One key per target — declared once at module scope (not
/// rebuilt per `build()`) so the same key instance stays attached to the
/// same target across rebuilds, which `ShowCaseWidget` requires to keep
/// tracking it.
class TourKeys {
  TourKeys._();

  static final homeNav = GlobalKey(debugLabel: 'tour-home-nav');
  static final ratesNavParent = GlobalKey(debugLabel: 'tour-rates-nav-parent');
  static final publishedRatesNav = GlobalKey(
    debugLabel: 'tour-published-rates-nav',
  );
  static final customRatesNav = GlobalKey(debugLabel: 'tour-custom-rates-nav');
  static final calculatorNav = GlobalKey(debugLabel: 'tour-calculator-nav');
  static final auditTrailNav = GlobalKey(debugLabel: 'tour-audit-trail-nav');
  static final tutorialNav = GlobalKey(debugLabel: 'tour-tutorial-nav');

  static final createRateButton = GlobalKey(
    debugLabel: 'tour-create-rate-button',
  );

  /// One key per wizard step's content area — only the current step is
  /// mounted at a time, so only one of these is ever attached, but
  /// `showcaseview` is fine tracking a key that isn't mounted yet as long
  /// as it's not the one currently being shown.
  static final wizardStep0 = GlobalKey(debugLabel: 'tour-wizard-step-0');
  static final wizardStep1 = GlobalKey(debugLabel: 'tour-wizard-step-1');
  static final wizardStep2 = GlobalKey(debugLabel: 'tour-wizard-step-2');
  static final wizardStep3 = GlobalKey(debugLabel: 'tour-wizard-step-3');

  static List<GlobalKey> wizardStepFor(int step) => switch (step) {
    0 => [wizardStep0],
    1 => [wizardStep1],
    2 => [wizardStep2],
    _ => [wizardStep3],
  };

  /// The whole dashboard portion of the tour, in narration order —
  /// `createRateButton` is deliberately LAST: it's the hand-off into the
  /// wizard, so once it completes the dashboard itself gets replaced by
  /// the wizard view. Nothing in this list may come after it — a sequence
  /// that did would have `showcaseview` hunting for a now-unmounted
  /// target once the screen switches, which is what caused the tooltip to
  /// jitter/"bounce" in place instead of advancing.
  static List<GlobalKey> get dashboardSteps => [
    homeNav,
    publishedRatesNav,
    customRatesNav,
    calculatorNav,
    auditTrailNav,
    createRateButton,
  ];
}
