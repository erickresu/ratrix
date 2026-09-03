import 'package:flutter/material.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';

import '../../../../../core/widgets/mr_ratrix.dart';
import '../../bloc/rate_wizard_bloc.dart';
import '../onboarding_tour.dart';
import 'wizard_tour_keys.dart';

class _TourStep {
  const _TourStep(this.title, this.body);

  final String title;
  final String body;
}

/// Story-mode continuation of the dashboard's `OnboardingTour` — same Cerro
/// character, same speech-bubble/TTS mechanics — but walking a first-time
/// user through building one actual custom rate, step by step, auto-
/// advancing the wizard itself (`TourStepChanged`) rather than just
/// spotlighting static nav items.
const _kTourSteps = [
  _TourStep(
    'Back again!',
    "Remember me from the dashboard tour? Let's put what you saw there "
        'into practice — I\'ll walk you through building one real custom '
        'rate for this client, start to finish.',
  ),
  _TourStep(
    'Chapter 1: Rate Setup',
    'Every rate starts with the basics — freight mode, service mode, and '
        'an expiry date if this deal only holds for a while. This is the '
        "foundation everything else builds on.",
  ),
  _TourStep(
    'Chapter 2: Rate Matrix',
    "Now the money part — which route, and what it costs at each weight "
        'bracket. Add as many routes and brackets as this client needs.',
  ),
  _TourStep(
    'Chapter 3: Add-ons',
    'Real shipments carry more than base freight — fuel surcharge, '
        'insurance, documentation fees. Anything that applies here.',
  ),
  _TourStep(
    'Chapter 4: Conditional Add-ons',
    "Last stop — charges that only kick in sometimes, like ODA for a "
        'hard-to-reach destination or a fee for a non-standard pickup. '
        "Set these up, and your rate's ready to publish!",
  ),
];

/// Runs the 5-beat story tour (intro + one chapter per wizard step),
/// auto-navigating the wizard to match via [TourStepChanged]. [onFinish]
/// fires once the whole thing closes, however it ends — callers should
/// mark it seen via `LocalStorageService.writeCustomRateTourSeen`.
class CustomRateTour {
  const CustomRateTour({required this.bloc, required this.onFinish});

  final RateWizardBloc bloc;
  final VoidCallback onFinish;

  void show(BuildContext context) {
    _showChapter(context, 0);
  }

  void _showChapter(BuildContext context, int index) {
    final isIntro = index == 0;

    if (isIntro) {
      final step = _kTourSteps[index];
      // No wizard element to spotlight yet — same centered, no-target
      // scene as the dashboard tour's own opening beat.
      showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) => _StoryScene(
          step: step,
          isLast: false,
          centered: true,
          onSkip: () {
            stopTourSpeech();
            Navigator.of(dialogContext).pop();
            onFinish();
          },
          onNext: () {
            Navigator.of(dialogContext).pop();
            _showChapter(context, index + 1);
          },
        ),
      );
      return;
    }

    // Chapter N (index 1..4) narrates wizard step N-1 — jump the wizard
    // there first. `emit` doesn't rebuild synchronously, so the target
    // key's `RenderBox` (queried when `TutorialCoachMark.show` runs)
    // would still be the *previous* step's until a frame passes — without
    // this gap the wizard content silently never advances even though the
    // coach mark's own chapters keep progressing.
    bloc.add(TourStepChanged(index - 1));
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (context.mounted) _displayChapter(context, index);
    });
  }

  void _displayChapter(BuildContext context, int index) {
    final step = _kTourSteps[index];
    final isLast = index == _kTourSteps.length - 1;

    // The narration bubble is a plain `OverlayEntry` I position myself
    // (fixed to the left side, vertically centered) instead of
    // `TargetContent.builder` — that content gets whatever size
    // `tutorial_coach_mark` decides to give it based on the target rect,
    // which on a target this large (the whole step's content) sometimes
    // collapsed to nothing and the bubble just didn't render at all.
    // `TutorialCoachMark` here only draws the backdrop + spotlight cutout;
    // `contents` stays empty on purpose.
    OverlayEntry? bubbleEntry;

    void removeBubble() {
      bubbleEntry?.remove();
      bubbleEntry = null;
    }

    void advance() {
      removeBubble();
      if (isLast) {
        stopTourSpeech();
        onFinish();
      } else {
        _showChapter(context, index + 1);
      }
    }

    void skip() {
      stopTourSpeech();
      removeBubble();
      onFinish();
    }

    TutorialCoachMark(
      targets: [
        TargetFocus(
          identify: step.title,
          keyTarget: WizardTourKeys.forStep(index - 1),
          shape: ShapeLightFocus.RRect,
          radius: 10,
          contents: const [],
        ),
      ],
      colorShadow: Colors.black,
      opacityShadow: 0.75,
      paddingFocus: 8,
      hideSkip: true,
      pulseAnimationDuration: const Duration(milliseconds: 3000),
      onClickTarget: (_) {},
      onSkip: () {
        skip();
        return true;
      },
    ).show(context: context);

    // Deferred a frame past `.show()` above — `TutorialCoachMark` inserts
    // its own scrim/spotlight entries on this same call, and whichever
    // OverlayEntry lands second stacks on top. Inserting synchronously
    // right here raced it and sometimes lost, leaving Cerro dimmed under
    // the black scrim instead of above it.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!context.mounted) return;
      bubbleEntry = OverlayEntry(
        builder: (overlayContext) => Positioned(
          left: 24,
          top: 0,
          bottom: 0,
          // A raw `OverlayEntry` has no `Material`/`DefaultTextStyle`
          // ancestor of its own — without one, `Text` falls back to
          // Flutter's "missing text style" debug look (bold, underlined,
          // that's the stray yellow line). `Material` supplies both.
          child: Material(
            type: MaterialType.transparency,
            child: Align(
              alignment: Alignment.centerLeft,
              child: _StoryScene(
                step: step,
                isLast: isLast,
                onSkip: skip,
                onNext: advance,
              ),
            ),
          ),
        ),
      );
      Overlay.of(context).insert(bubbleEntry!);
    });
  }
}

/// Cerro + speech bubble, shared layout between the intro dialog and every
/// chapter's coach-mark content — same visual language as
/// `OnboardingTour`'s `_TourContent`/`OnboardingIntro`.
class _StoryScene extends StatefulWidget {
  const _StoryScene({
    required this.step,
    required this.isLast,
    required this.onNext,
    required this.onSkip,
    this.centered = false,
  });

  final _TourStep step;
  final bool isLast;
  final VoidCallback onNext;
  final VoidCallback onSkip;

  /// True only for the no-target intro dialog, which needs to center
  /// itself on the whole screen. Chapters targeting a spotlighted wizard
  /// step must NOT self-center — `tutorial_coach_mark` already positions
  /// them relative to the target's own rect (see each `TargetContent`'s
  /// `align`); wrapping in `Center` here overrode that and could push the
  /// bubble off-screen against a tall target.
  final bool centered;

  @override
  State<_StoryScene> createState() => _StoryStepState();
}

class _StoryStepState extends State<_StoryScene> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _speakStep());
  }

  @override
  void didUpdateWidget(covariant _StoryScene oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.step.title != widget.step.title) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _speakStep());
    }
  }

  Future<void> _speakStep() =>
      speakTourLine('${widget.step.title}. ${widget.step.body}');

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final isMobile = screenWidth < 600;
    final bubble = TourSpeechBubble(
      width: isMobile ? screenWidth - 48 : 320,
      title: widget.step.title,
      body: widget.step.body,
      onSpeak: _speakStep,
      leftLabel: 'Skip tour',
      onLeft: widget.onSkip,
      rightLabel: widget.isLast ? 'Publish it!' : 'Next',
      onRight: widget.onNext,
    );

    final ratrixSize = widget.centered ? 220.0 : 140.0;

    if (isMobile) {
      final content = ConstrainedBox(
        constraints: BoxConstraints(maxWidth: screenWidth - 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            MrRatrix(size: (screenWidth * 0.35).clamp(100, ratrixSize)),
            const SizedBox(height: 12),
            bubble,
          ],
        ),
      );
      return widget.centered ? Center(child: content) : content;
    }

    final content = Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        MrRatrix(size: ratrixSize),
        const SizedBox(width: 20),
        bubble,
      ],
    );
    // Chapters are positioned by the caller's own `OverlayEntry`
    // (pinned left, vertically centered) — this widget just returns its
    // natural-size content, no self-positioning.
    return widget.centered ? Center(child: content) : content;
  }
}
