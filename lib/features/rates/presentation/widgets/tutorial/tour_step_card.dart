import 'package:flutter/material.dart';
import 'package:showcaseview/showcaseview.dart';

import '../../../../../core/widgets/mr_ratrix.dart';
import 'app_tour.dart';
import 'tour_speech.dart';

/// Cerro (`MrRatrix`), inside the same [TourSpeechBubble] card rather than
/// beside it — the custom `container` every tour step's
/// `Showcase.withWidget` renders as its tooltip. Speaks its line via TTS
/// once when it first mounts.
class TourStepCard extends StatefulWidget {
  const TourStepCard({
    super.key,
    required this.title,
    required this.body,
    required this.isLast,
  });

  final String title;
  final String body;
  final bool isLast;

  @override
  State<TourStepCard> createState() => _TourStepCardState();
}

class _TourStepCardState extends State<TourStepCard> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _speak());
  }

  Future<void> _speak() => speakTourLine('${widget.title}. ${widget.body}');

  // `Showcase.withWidget`'s `container` is mounted inside an `OverlayEntry`
  // (showcaseview inserts it via the root `Overlay`), which is a separate
  // element subtree from wherever that widget was *built* — so this
  // widget's own `context` has no `ShowCaseWidget` ancestor to find, and
  // `ShowCaseWidget.of(context)` throws "Please provide ShowCaseView
  // context" the moment Next/Skip is tapped. `AppTour.active` still holds
  // the shell's context (guaranteed under the real `ShowCaseWidget`, see
  // `RatesShellPage`), so route through that instead of this widget's own.
  void _skip() {
    stopTourSpeech();
    // Read `shellContext` before `skip()` — that call clears
    // `AppTour.active`, so grabbing it after would always see `null` and
    // leave the showcase overlay stuck on screen undismissed.
    final tour = AppTour.active;
    final shellContext = tour?.shellContext;
    if (shellContext != null && shellContext.mounted) {
      ShowCaseWidget.of(shellContext).dismiss();
    }
    tour?.skip();
  }

  void _next() {
    final shellContext = AppTour.active?.shellContext;
    if (shellContext != null && shellContext.mounted) {
      ShowCaseWidget.of(shellContext).next();
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final isMobile = screenWidth < 700;

    return TourSpeechBubble(
      width: isMobile ? screenWidth - 64 : 560,
      mascot: MrRatrix(size: isMobile ? 72 : 140),
      scale: isMobile ? 1.0 : 1.25,
      title: widget.title,
      body: widget.body,
      onSpeak: _speak,
      leftLabel: 'Skip tour',
      onLeft: _skip,
      rightLabel: widget.isLast ? 'Got it!' : 'Next',
      onRight: _next,
    );
  }
}

/// Wraps [child] in a `Showcase.withWidget` whose tooltip is a
/// [TourStepCard] — the one building block every tour step (sidebar item,
/// dashboard button, wizard step area) is built from. `Showcase.withWidget`
/// requires a fixed tooltip size, so this sizes it off the current screen
/// width the same way [TourStepCard] lays itself out.
Widget tourShowcase({
  required GlobalKey key,
  required Widget child,
  required String title,
  required String body,
  required bool isLast,
  required BuildContext context,
  EdgeInsets targetPadding = const EdgeInsets.all(6),
}) {
  final screenWidth = MediaQuery.sizeOf(context).width;
  final isMobile = screenWidth < 700;
  final size = isMobile
      ? Size((screenWidth - 32).clamp(200, 500), 260)
      : const Size(620, 280);

  return Showcase.withWidget(
    key: key,
    height: size.height,
    width: size.width,
    targetPadding: targetPadding,
    targetShapeBorder: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(10),
    ),
    // Set directly here, not just on the ancestor `ShowCaseWidget` — this
    // per-`Showcase` value is what `ToolTipWidget` actually reads
    // (`widget.disableMovingAnimation ?? showCaseWidgetState....`), so an
    // explicit `true` here can't be shadowed by anything upstream. Without
    // it, showcaseview's tooltip continuously drifts toward/away from its
    // target on a loop (its built-in "moving animation") — reads as the
    // whole card bouncing up and down.
    disableMovingAnimation: true,
    container: TourStepCard(title: title, body: body, isLast: isLast),
    child: child,
  );
}
