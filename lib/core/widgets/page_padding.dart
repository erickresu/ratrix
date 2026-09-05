import 'package:flutter/widgets.dart';

import '../utils/breakpoints.dart';

/// Horizontal padding for a desktop content page — left+right together
/// always eat 30% of however much width this widget is given, so the
/// content column is a steady 70% of the available space regardless of
/// window size, instead of a fixed pixel margin. Mobile keeps a small
/// fixed padding since there's no width to spare.
class PagePadding extends StatelessWidget {
  const PagePadding({
    super.key,
    required this.child,
    this.top = 0,
    this.bottom = 0,
  });

  final Widget child;
  final double top;
  final double bottom;

  static const _mobileSide = 24.0;
  static const _desktopSideFraction = 0.15;

  @override
  Widget build(BuildContext context) {
    if (Breakpoints.isMobile(context)) {
      return Padding(
        padding: EdgeInsets.fromLTRB(_mobileSide, top, _mobileSide, bottom),
        child: child,
      );
    }
    return LayoutBuilder(
      builder: (context, constraints) {
        final side = constraints.maxWidth * _desktopSideFraction;
        return Padding(
          padding: EdgeInsets.fromLTRB(side, top, side, bottom),
          child: child,
        );
      },
    );
  }
}
