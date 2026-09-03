import 'package:flutter/widgets.dart';

/// Stable [GlobalKey]s for each wizard step's title, spotlighted by
/// `CustomRateTour`. Declared here (not inline in a build method) for the
/// same reason as `SidebarTourKeys` — a GlobalKey made during build loses
/// its bound element on rebuild, and `tutorial_coach_mark` needs the same
/// instance still attached when the tour actually shows.
class WizardTourKeys {
  static final step0Title = GlobalKey();
  static final step1Title = GlobalKey();
  static final step2Title = GlobalKey();
  static final step3Title = GlobalKey();

  static GlobalKey forStep(int step) => switch (step) {
    0 => step0Title,
    1 => step1Title,
    2 => step2Title,
    _ => step3Title,
  };
}
