import 'package:flutter/material.dart';

/// Fixed-width content in a horizontal scroll with a visible, always-on,
/// draggable Scrollbar — used to keep data tables usable on mobile instead
/// of squeezing columns until text/badges clip. Give [width] the sum of
/// every column's fixed width (+ gaps) and lay [child] out with matching
/// `SizedBox(width: ...)` columns, same as the rate wizard's matrix table.
class HorizontalScrollTable extends StatefulWidget {
  const HorizontalScrollTable({
    super.key,
    required this.width,
    required this.child,
  });

  final double width;
  final Widget child;

  @override
  State<HorizontalScrollTable> createState() => _HorizontalScrollTableState();
}

class _HorizontalScrollTableState extends State<HorizontalScrollTable> {
  final _controller = ScrollController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scrollbar(
      controller: _controller,
      thumbVisibility: true,
      trackVisibility: true,
      child: SingleChildScrollView(
        controller: _controller,
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.only(bottom: 10),
        child: SizedBox(width: widget.width, child: widget.child),
      ),
    );
  }
}
