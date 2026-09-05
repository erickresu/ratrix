import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';

import '../../rates_colors.dart';

/// True while a tour line is actually being read aloud — drives the
/// speaker icon's talking animation.
final ValueNotifier<bool> isTourSpeaking = ValueNotifier(false);

final _tts = FlutterTts()
  ..setPitch(0.8)
  ..setSpeechRate(0.72)
  ..setStartHandler(() => isTourSpeaking.value = true)
  ..setCompletionHandler(() => isTourSpeaking.value = false)
  ..setCancelHandler(() => isTourSpeaking.value = false)
  ..setErrorHandler((msg) => isTourSpeaking.value = false)
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
/// Also debounces: rapid rebuilds of the speaking widget can retrigger
/// faster than the speech finishes, which sounded like the line looping.
/// Drop a repeat of the same line within 800ms rather than restarting it.
Future<void> speakTourLine(String text) async {
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
  await Future.delayed(const Duration(milliseconds: 150));
  await _tts.speak(spoken);
}

void stopTourSpeech() {
  _tts.stop();
  isTourSpeaking.value = false;
}

/// White speech-bubble card: an optional [mascot] beside the title + tap-
/// to-replay speaker icon, "Cerro: " narration body, and a Skip/primary
/// button pair. Shared between every tour step's `Showcase.withWidget`
/// container.
class TourSpeechBubble extends StatelessWidget {
  const TourSpeechBubble({
    super.key,
    this.width,
    this.padding = const EdgeInsets.all(22),
    this.mascot,
    this.scale = 1.0,
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

  /// Mr. Ratrix, rendered inside this same card rather than beside it —
  /// omit to fall back to a text-only header (e.g. narrower mobile steps).
  final Widget? mascot;

  /// Scales text, icon, and button sizing — e.g. a larger card on wide
  /// desktop/web viewports, where the base sizing reads small against the
  /// spotlighted real UI it's sitting next to.
  final double scale;
  final String title;
  final String body;
  final VoidCallback onSpeak;
  final String leftLabel;
  final VoidCallback onLeft;
  final String rightLabel;
  final VoidCallback onRight;

  @override
  Widget build(BuildContext context) {
    final content = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 18 * scale,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF17241F),
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
                  padding: EdgeInsets.all(7 * scale),
                  child: _SpeakerIcon(
                    size: 17 * scale,
                    color: RatesColors.dark.primaryDeep,
                  ),
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 8 * scale),
        Text.rich(
          TextSpan(
            style: TextStyle(
              fontSize: 14 * scale,
              height: 1.5,
              color: const Color(0xFF5B6B82),
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
        SizedBox(height: 18 * scale),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            TextButton(
              onPressed: onLeft,
              style: TextButton.styleFrom(
                foregroundColor: RatesColors.dark.primary,
                textStyle: TextStyle(fontSize: 14 * scale),
              ),
              child: Text(leftLabel),
            ),
            ElevatedButton(
              onPressed: onRight,
              style: ElevatedButton.styleFrom(
                backgroundColor: RatesColors.dark.primary,
                foregroundColor: Colors.white,
                textStyle: TextStyle(fontSize: 14 * scale),
                padding: EdgeInsets.symmetric(
                  horizontal: 22 * scale,
                  vertical: 11 * scale,
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
    );

    return Container(
      width: width,
      padding: padding * scale,
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
      // Mascot as its own leading column (not squeezed into the title
      // row) so it can render at a size where the Lottie animation is
      // actually legible, while still living inside this same card.
      child: mascot == null
          ? content
          : IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(child: mascot!),
                  const SizedBox(width: 14),
                  Expanded(child: content),
                ],
              ),
            ),
    );
  }
}

/// Static speaker icon that cycles through volume levels like a talking
/// meter while [isTourSpeaking] is true, idle otherwise.
class _SpeakerIcon extends StatefulWidget {
  const _SpeakerIcon({required this.size, required this.color});

  final double size;
  final Color color;

  @override
  State<_SpeakerIcon> createState() => _SpeakerIconState();
}

class _SpeakerIconState extends State<_SpeakerIcon>
    with SingleTickerProviderStateMixin {
  late final _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 600),
  );

  static const _frames = [
    Icons.volume_mute_rounded,
    Icons.volume_down_rounded,
    Icons.volume_up_rounded,
  ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: isTourSpeaking,
      builder: (context, speaking, _) {
        if (speaking) {
          _controller.repeat();
        } else {
          _controller.stop();
        }
        return AnimatedBuilder(
          animation: _controller,
          builder: (context, _) {
            final icon = speaking
                ? _frames[(_controller.value * _frames.length).floor() % _frames.length]
                : Icons.volume_up_rounded;
            return Icon(icon, size: widget.size, color: widget.color);
          },
        );
      },
    );
  }
}
