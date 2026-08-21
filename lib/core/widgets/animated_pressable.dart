import 'package:flutter/material.dart';

/// Material + InkWell wrapped with a subtle press-scale (down) and
/// hover-lift (up) animation — the "typical app" tactile feedback for
/// buttons, cards, and nav items. Drop-in replacement for a bare
/// `Material(child: InkWell(onTap: ..., child: ...))`.
class AnimatedPressable extends StatefulWidget {
  const AnimatedPressable({
    super.key,
    required this.child,
    this.onTap,
    this.borderRadius,
    this.color = Colors.transparent,
  });

  final Widget child;
  final VoidCallback? onTap;
  final BorderRadius? borderRadius;
  final Color color;

  @override
  State<AnimatedPressable> createState() => _AnimatedPressableState();
}

class _AnimatedPressableState extends State<AnimatedPressable> {
  bool _pressed = false;
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedScale(
        scale: _pressed ? 0.97 : (_hovered && widget.onTap != null ? 1.015 : 1.0),
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOut,
        child: Material(
          color: widget.color,
          borderRadius: widget.borderRadius,
          child: InkWell(
            borderRadius: widget.borderRadius,
            onTap: widget.onTap,
            onHighlightChanged: (v) => setState(() => _pressed = v),
            child: widget.child,
          ),
        ),
      ),
    );
  }
}
