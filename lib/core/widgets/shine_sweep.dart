import 'package:flutter/material.dart';

/// A bright diagonal sweep that passes across [child] from bottom-left to
/// top-right on a loop, with a pause between passes — drop it inside any
/// decorative shape (a badge, an icon bubble) for a "shiny" premium-card
/// effect. Uses a [ShaderMask] sized to the child's own paint bounds, so it
/// always sweeps edge-to-edge regardless of the child's size. Clip the child
/// yourself (e.g. `ClipOval`/`ClipRRect`) if it needs to stay inside a
/// non-rectangular shape.
class ShineSweep extends StatefulWidget {
  const ShineSweep({
    super.key,
    required this.child,
    this.period = const Duration(milliseconds: 3500),
    this.pause = const Duration(milliseconds: 1500),
    this.color = Colors.white,
    this.opacity = 0.85,
    this.bandWidth = 0.28,
  });

  final Widget child;

  /// How long one sweep pass takes.
  final Duration period;

  /// Rest between sweeps, so the eye actually registers each pass instead of
  /// a constant blur of motion.
  final Duration pause;

  final Color color;
  final double opacity;

  /// Width of the bright band relative to the sweep span (0-1). Smaller = a
  /// tighter, punchier streak.
  final double bandWidth;

  @override
  State<ShineSweep> createState() => _ShineSweepState();
}

class _ShineSweepState extends State<ShineSweep>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  Duration get _cycle => widget.period + widget.pause;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: _cycle)..repeat();
  }

  @override
  void didUpdateWidget(ShineSweep oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.period != widget.period || oldWidget.pause != widget.pause) {
      _controller.duration = _cycle;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final sweepFraction = _cycle.inMicroseconds == 0
        ? 1.0
        : widget.period.inMicroseconds / _cycle.inMicroseconds;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        // Sweep runs during the first `sweepFraction` of the cycle, then
        // holds off-screen for the rest (the pause).
        final raw = (_controller.value / sweepFraction).clamp(0.0, 1.0);
        final band = widget.bandWidth.clamp(0.05, 1.0);

        // Center of the bright band travels from just-off-left to
        // just-off-right so it fully enters and exits the shape.
        final span = 1 + band;
        final center = -band / 2 + raw * span;

        final stops = <double>[
          (center - band).clamp(0.0, 1.0),
          center.clamp(0.0, 1.0),
          (center + band).clamp(0.0, 1.0),
        ];
        // Guard against collapsed/out-of-order stops when the band sits
        // entirely outside [0,1] (start/end of the sweep).
        for (var i = 1; i < stops.length; i++) {
          if (stops[i] < stops[i - 1]) stops[i] = stops[i - 1];
        }

        return ShaderMask(
          blendMode: BlendMode.plus,
          shaderCallback: (bounds) {
            return LinearGradient(
              begin: Alignment.bottomLeft,
              end: Alignment.topRight,
              colors: [
                widget.color.withValues(alpha: 0),
                widget.color.withValues(alpha: widget.opacity),
                widget.color.withValues(alpha: 0),
              ],
              stops: stops,
            ).createShader(bounds);
          },
          child: widget.child,
        );
      },
    );
  }
}
