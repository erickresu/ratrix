import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';

import '../../../../core/widgets/mr_ratrix.dart';
import '../rates_colors.dart';
import 'sidebar_tour_keys.dart';

final _tts = FlutterTts()
  ..setPitch(0.8)
  ..setSpeechRate(0.67)
  // The very first utterance in a browser session gets its opening word(s)
  // eaten while the engine cold-starts — no amount of delay before the
  // real line helps, since there's nothing prior to warm it up. Fire a
  // silent throwaway line immediately so the actual first line, whenever
  // it comes, isn't the one paying that cost.
  ..speak(' ');

String? _lastSpokenText;
DateTime? _lastSpokenAt;

/// TTS engines misread these brand names — swap in phonetic respellings for
/// speech only (never shown to the reader): "Ratrix" comes out "ra-trix"
/// instead of "ray-trix", and "Cerro" comes out wrong instead of "sero".
///
/// Also debounces: `tutorial_coach_mark`'s own entrance/pulse animations
/// can remount the step content (retriggering `initState`) faster than the
/// speech finishes, which sounded like the line looping. Drop a repeat of
/// the same line within 800ms rather than restarting it.
Future<void> _speak(String text) async {
  var spoken = text.replaceAll(
    RegExp('Ratrix', caseSensitive: false),
    'Raytrix',
  );
  spoken = spoken.replaceAll(RegExp('Cerro', caseSensitive: false), 'Sero');

  final now = DateTime.now();
  if (spoken == _lastSpokenText &&
      _lastSpokenAt != null &&
      now.difference(_lastSpokenAt!) < const Duration(milliseconds: 800)) {
    return;
  }
  _lastSpokenText = spoken;
  _lastSpokenAt = now;

  await _tts.stop();
  // A speak() fired immediately after stop() can clip the opening word(s)
  // while the engine is still cancelling the previous utterance — give it
  // a beat to settle first.
  await Future.delayed(const Duration(milliseconds: 150));
  await _tts.speak(spoken);
}

class _Step {
  const _Step(this.title, this.body, this.key, this.align);

  final String title;
  final String body;
  final GlobalKey key;
  final ContentAlign align;
}

final _kSteps = [
  _Step(
    'Your Dashboard',
    'This is your dashboard — a quick look at active rates, clients, and '
        "what's changed recently.",
    SidebarTourKeys.homeNav,
    ContentAlign.right,
  ),
  _Step(
    'Create a Rate',
    'Start here to publish a new rate, or set one up for a specific client.',
    SidebarTourKeys.createRateNav,
    ContentAlign.bottom,
  ),
  _Step(
    'Publish Rates',
    'Standard rates visible to every client on their route.',
    SidebarTourKeys.publishedRatesNav,
    ContentAlign.right,
  ),
  _Step(
    'Custom Rates',
    'Rates negotiated for one specific client instead of everyone.',
    SidebarTourKeys.customRatesNav,
    ContentAlign.right,
  ),
  _Step(
    'Shipping Calculator',
    'Quote a shipment instantly using whatever rates are already on file — '
        'no manual math.',
    SidebarTourKeys.shippingCalculatorNav,
    ContentAlign.right,
  ),
  _Step(
    'Audit Trail',
    'Every create, update, and delete gets logged here, so you can always '
        'check what changed.',
    SidebarTourKeys.auditTrailNav,
    ContentAlign.right,
  ),
];

/// Runs the full intro + coach-mark tour from the start — used both for the
/// automatic first-visit trigger and a manual "replay" entry point (e.g. an
/// info button on the dashboard). [onFinish] fires once the whole flow
/// closes, however the user got there (finished, skipped the intro, or
/// skipped the tour).
Future<void> showOnboarding(
  BuildContext context, {
  VoidCallback? onFinish,
}) async {
  final continueTour = await showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (_) => const OnboardingIntro(),
  );
  if (!context.mounted) return;
  if (continueTour == true) {
    OnboardingTour(onFinish: onFinish ?? () {}).show(context);
  } else {
    onFinish?.call();
  }
}

/// First-visit welcome tour — spotlights the real nav/action buttons (see
/// [SidebarTourKeys]) via `tutorial_coach_mark`, with Cerro narrating
/// each one in a speech bubble (readable, and playable aloud via TTS).
/// Callers should mark it seen via `LocalStorageService.writeOnboardingSeen`
/// from [onFinish]. Prefer [showOnboarding] over calling this directly.
class OnboardingTour {
  const OnboardingTour({required this.onFinish});

  final VoidCallback onFinish;

  void show(BuildContext context) {
    // The drawer's nav items run edge-to-edge on phones, so a right-aligned
    // bubble has nowhere to go and shoots off-screen — force bottom on
    // mobile regardless of what each step normally prefers on desktop.
    final isMobile = MediaQuery.sizeOf(context).width < 600;
    final targets = [
      for (final step in _kSteps)
        TargetFocus(
          identify: step.title,
          keyTarget: step.key,
          shape: ShapeLightFocus.RRect,
          radius: 10,
          contents: [
            TargetContent(
              align: isMobile ? ContentAlign.bottom : step.align,
              builder: (context, controller) => _TourContent(
                step: step,
                isLast: step == _kSteps.last,
                onNext: controller.next,
                onSkip: controller.skip,
              ),
            ),
          ],
        ),
    ];

    TutorialCoachMark(
      targets: targets,
      colorShadow: Colors.black,
      opacityShadow: 0.75,
      paddingFocus: 8,
      hideSkip: true,
      // Default pulse is 500ms — reads as a rapid flicker. Slow it down to
      // a calmer breathing glow.
      pulseAnimationDuration: const Duration(milliseconds: 3000),
      onFinish: () {
        _tts.stop();
        onFinish();
      },
      onSkip: () {
        _tts.stop();
        onFinish();
        return true;
      },
    ).show(context: context);
  }
}

/// White speech-bubble card used by both the coach-mark tour steps
/// ([_TourContentState]) and the standalone [OnboardingIntro] scene: a
/// title + tap-to-replay speaker icon, "Cerro: " narration body, and a
/// Skip/primary button pair.
class _SpeechBubble extends StatelessWidget {
  const _SpeechBubble({
    this.width,
    this.padding = const EdgeInsets.all(26),
    required this.title,
    required this.body,
    required this.onSpeak,
    required this.leftLabel,
    required this.onLeft,
    required this.rightLabel,
    required this.onRight,
  });

  final double? width;
  final EdgeInsets padding;
  final String title;
  final String body;
  final VoidCallback onSpeak;
  final String leftLabel;
  final VoidCallback onLeft;
  final String rightLabel;
  final VoidCallback onRight;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      padding: padding,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.25),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF17241F),
                  ),
                ),
              ),
              Material(
                color: RatesColors.dark.primarySoftBg,
                shape: const CircleBorder(),
                child: InkWell(
                  customBorder: const CircleBorder(),
                  onTap: onSpeak,
                  child: Padding(
                    padding: const EdgeInsets.all(7),
                    child: Icon(
                      Icons.volume_up_rounded,
                      size: 18,
                      color: RatesColors.dark.primaryDeep,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text.rich(
            TextSpan(
              style: const TextStyle(
                fontSize: 15,
                height: 1.5,
                color: Color(0xFF5B6B82),
              ),
              children: [
                const TextSpan(
                  text: 'Cerro: ',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF17241F),
                  ),
                ),
                TextSpan(text: body),
              ],
            ),
          ),
          const SizedBox(height: 22),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton(
                onPressed: onLeft,
                style: TextButton.styleFrom(
                  foregroundColor: RatesColors.dark.primary,
                ),
                child: Text(leftLabel),
              ),
              ElevatedButton(
                onPressed: onRight,
                style: ElevatedButton.styleFrom(
                  backgroundColor: RatesColors.dark.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(rightLabel),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TourContent extends StatefulWidget {
  const _TourContent({
    required this.step,
    required this.isLast,
    required this.onNext,
    required this.onSkip,
  });

  final _Step step;
  final bool isLast;
  final VoidCallback onNext;
  final VoidCallback onSkip;

  @override
  State<_TourContent> createState() => _TourContentState();
}

class _TourContentState extends State<_TourContent> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _speakStep());
  }

  @override
  void didUpdateWidget(covariant _TourContent oldWidget) {
    super.didUpdateWidget(oldWidget);
    // tutorial_coach_mark may reuse this State across steps instead of
    // remounting it, so initState alone only ever fires for the first
    // step — catch later step changes here too.
    if (!identical(oldWidget.step, widget.step)) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _speakStep());
    }
  }

  Future<void> _speakStep() =>
      _speak('${widget.step.title}. ${widget.step.body}');

  Widget _buildBubble(BuildContext context, {required bool isMobile}) {
    return _SpeechBubble(
      width: isMobile ? double.infinity : 300,
      padding: EdgeInsets.all(isMobile ? 20 : 26),
      title: widget.step.title,
      body: widget.step.body,
      onSpeak: _speakStep,
      leftLabel: 'Skip',
      onLeft: widget.onSkip,
      rightLabel: widget.isLast ? 'Got it' : 'Next',
      onRight: widget.onNext,
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final isMobile = screenWidth < 600;

    if (isMobile) {
      // Bottom-aligned content on mobile spans the full screen width with
      // no horizontal centering of its own — center this column within it.
      return Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: screenWidth - 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              MrRatrix(size: (screenWidth * 0.4).clamp(120, 180)),
              const SizedBox(height: 12),
              _buildBubble(context, isMobile: true),
            ],
          ),
        ),
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const MrRatrix(size: 280),
        const SizedBox(width: 24),
        Flexible(
          child: Padding(
            padding: const EdgeInsets.only(top: 36),
            child: _buildBubble(context, isMobile: false),
          ),
        ),
      ],
    );
  }
}

const _kIntroTitle = 'Welcome to Ratrix!';
const _kIntroBody =
    "Hi, I'm your friendly neighborhood rates robot! I'm here to help you "
    'find your way around.';

/// Standalone opening beat, shown before [OnboardingTour] — Cerro
/// introduces himself center-stage (no sidebar target yet), then the
/// caller starts the coach-mark tour once this closes with `true`.
class OnboardingIntro extends StatefulWidget {
  const OnboardingIntro({super.key});

  @override
  State<OnboardingIntro> createState() => _OnboardingIntroState();
}

class _OnboardingIntroState extends State<OnboardingIntro> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _speakIntro());
  }

  Future<void> _speakIntro() => _speak('$_kIntroTitle $_kIntroBody');

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.zero,
      child: Stack(
        children: [
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
              child: Container(color: Colors.black.withValues(alpha: 0.45)),
            ),
          ),
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Builder(builder: (context) {
                final screenWidth = MediaQuery.sizeOf(context).width;
                final isMobile = screenWidth < 600;
                final bubbleWidth = isMobile ? screenWidth - 48 : 340.0;
                return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  MrRatrix(size: isMobile ? (screenWidth * 0.45).clamp(140, 220) : 260),
                  const SizedBox(
                    width: 26,
                    height: 12,
                    child: CustomPaint(painter: _UpTailPainter()),
                  ),
                  _SpeechBubble(
                    width: bubbleWidth,
                    title: _kIntroTitle,
                    body: _kIntroBody,
                    onSpeak: _speakIntro,
                    leftLabel: 'Skip tour',
                    onLeft: () => Navigator.of(context).pop(false),
                    rightLabel: "Let's go",
                    onRight: () => Navigator.of(context).pop(true),
                  ),
                ],
              );
              }),
            ),
          ),
        ],
      ),
    );
  }
}

/// Small triangle pointing up, out of the bubble's top edge toward
/// Cerro, for the centered [OnboardingIntro] scene.
class _UpTailPainter extends CustomPainter {
  const _UpTailPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white;
    final path = Path()
      ..moveTo(size.width / 2, 0)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _UpTailPainter oldDelegate) => false;
}
