import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../../../../core/utils/breakpoints.dart';
import '../../../domain/entities/breakweight.dart';
import '../../../domain/entities/matrix_row.dart' as domain;
import '../../rates_colors.dart';

/// Two-pane rate matrix: a fixed origin/destination column on the left and a
/// horizontally-scrollable set of breakweight/rate columns on the right.
/// Shared by the main Rate Matrix step and the Conditional Add-ons matrix.
class RateMatrixTable extends StatelessWidget {
  const RateMatrixTable({
    super.key,
    required this.matrixRows,
    required this.breakweights,
    required this.originPlaceholder,
    required this.destinationPlaceholder,
    required this.onOriginChanged,
    required this.onDestinationChanged,
    required this.onCellChanged,
    required this.onBreakweightMinChanged,
    required this.onBreakweightMaxChanged,
    required this.onRemoveBreakweight,
    this.onRemoveRoute,
    this.locationOptions = const [],
  });

  final List<domain.MatrixRow> matrixRows;
  final List<Breakweight> breakweights;
  final String originPlaceholder;
  final String destinationPlaceholder;
  final List<String> locationOptions;
  final void Function(int rowIndex, String value) onOriginChanged;
  final void Function(int rowIndex, String value) onDestinationChanged;
  final void Function(int rowIndex, int breakweightIndex, String value)
  onCellChanged;
  final void Function(int index, String value) onBreakweightMinChanged;
  final void Function(int index, String value) onBreakweightMaxChanged;
  final void Function(int index) onRemoveBreakweight;
  final void Function(int rowIndex)? onRemoveRoute;

  static const _headerHeight = 98.0;
  static const _rowHeight = 64.0;
  static const _bwColWidth = 156.0;
  static const _leftPaneWidth = 560.0;
  static const _leftPaneWidthMobile = 340.0;
  static const _removeColWidth = 40.0;
  static const _compactInputPadding = EdgeInsets.symmetric(
    horizontal: 6,
    vertical: 8,
  );

  @override
  Widget build(BuildContext context) {
    final removeDisabled = matrixRows.length <= 1;
    final bwRemoveDisabled = breakweights.length <= 1;
    final isMobile = Breakpoints.isMobile(context);
    final basePaneWidth = isMobile ? _leftPaneWidthMobile : _leftPaneWidth;
    final leftPaneWidth =
        basePaneWidth + (onRemoveRoute != null ? _removeColWidth : 0);

    final table = Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Fixed origin/destination pane.
        SizedBox(
          width: leftPaneWidth,
          child: Column(
            children: [
              Container(
                height: _headerHeight,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: context.colors.surfaceSubtle,
                  border: Border(
                    bottom: BorderSide(color: context.colors.border),
                    right: BorderSide(color: context.colors.border),
                  ),
                ),
                child: Row(
                  children: [
                    const Expanded(child: _HeaderLabel(label: 'Origin')),
                    const Expanded(child: _HeaderLabel(label: 'Destination')),
                    if (onRemoveRoute != null)
                      const SizedBox(width: _removeColWidth),
                  ],
                ),
              ),
              for (var i = 0; i < matrixRows.length; i++)
                Container(
                  height: _rowHeight,
                  decoration: BoxDecoration(
                    border: Border(
                      top: BorderSide(color: context.colors.surfaceMuted),
                      right: BorderSide(color: context.colors.surfaceMuted),
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: _LocationField(
                            key: ValueKey('origin-$i-$originPlaceholder'),
                            value: matrixRows[i].origin,
                            placeholder: originPlaceholder,
                            options: locationOptions,
                            onChanged: (v) => onOriginChanged(i, v),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: _LocationField(
                            key: ValueKey(
                              'destination-$i-$destinationPlaceholder',
                            ),
                            value: matrixRows[i].destination,
                            placeholder: destinationPlaceholder,
                            options: locationOptions,
                            onChanged: (v) => onDestinationChanged(i, v),
                          ),
                        ),
                      ),
                      if (onRemoveRoute != null)
                        SizedBox(
                          width: _removeColWidth,
                          child: IconButton(
                            onPressed: removeDisabled
                                ? null
                                : () => onRemoveRoute!(i),
                            icon: const Icon(CupertinoIcons.xmark, size: 14),
                            color: removeDisabled
                                ? context.colors.textFaint
                                : context.colors.destructive,
                            splashRadius: 16,
                          ),
                        ),
                    ],
                  ),
                ),
            ],
          ),
        ),
        // Breakweight/rate pane: fills the remaining width evenly when the
        // columns fit, otherwise switches to fixed-width columns with a
        // visible, draggable horizontal scrollbar. On mobile the whole
        // table (this build method's caller) is already wrapped in a
        // single horizontal scroll view, so this pane just renders at its
        // natural fixed width instead of trying to fill/scroll on its own
        // (avoiding an Expanded-with-no-bound-width crash + nested
        // horizontal scrolling).
        buildBreakweightPane(
          context: context,
          isMobile: isMobile,
          bwRemoveDisabled: bwRemoveDisabled,
        ),
      ],
    );

    final decoratedTable = Container(
      decoration: BoxDecoration(
        color: context.colors.surface,
        border: Border.all(color: context.colors.border),
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: context.colors.shadowSoft,
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: table,
    );

    if (!isMobile) return decoratedTable;

    // On mobile, the left pane alone can exceed the viewport width, so the
    // whole table (left pane + right pane) scrolls horizontally as one unit
    // instead of only the right pane scrolling while the left pane is fixed.
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: decoratedTable,
    );
  }

  Widget buildBreakweightPane({
    required BuildContext context,
    required bool isMobile,
    required bool bwRemoveDisabled,
  }) {
    Widget buildContent(double columnWidth) {
      return Column(
        children: [
          Row(
            children: [
              for (var bi = 0; bi < breakweights.length; bi++)
                _BreakweightHeaderCell(
                  index: bi,
                  breakweight: breakweights[bi],
                  width: columnWidth,
                  height: _headerHeight,
                  removeDisabled: bwRemoveDisabled,
                  onMinChanged: (v) => onBreakweightMinChanged(bi, v),
                  onMaxChanged: (v) => onBreakweightMaxChanged(bi, v),
                  onRemove: () => onRemoveBreakweight(bi),
                ),
            ],
          ),
          for (var i = 0; i < matrixRows.length; i++)
            Container(
              height: _rowHeight,
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(color: context.colors.surfaceMuted),
                ),
              ),
              child: Row(
                children: [
                  for (var bi = 0; bi < breakweights.length; bi++)
                    Container(
                      width: columnWidth,
                      alignment: Alignment.center,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        border: Border(
                          left: BorderSide(color: context.colors.surfaceMuted),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            r'$',
                            style: TextStyle(
                              fontSize: 12,
                              color: context.colors.primaryDeep,
                            ),
                          ),
                          const SizedBox(width: 4),
                          SizedBox(
                            width: 68,
                            child: ShadInput(
                              placeholder: const Text('0.00'),
                              initialValue:
                                  i < matrixRows.length &&
                                      bi < matrixRows[i].rates.length
                                  ? matrixRows[i].rates[bi]
                                  : '',
                              textAlign: TextAlign.center,
                              padding: _compactInputPadding,
                              decoration: ShadDecoration(
                                color: context.colors.primarySoftBg,
                                border: ShadBorder.none,
                                focusedBorder: ShadBorder.none,
                              ),
                              onChanged: (v) => onCellChanged(i, bi, v),
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
        ],
      );
    }

    if (isMobile) {
      // The whole table already scrolls horizontally as one unit on mobile
      // (see `build`), so this pane renders at its natural fixed width with
      // no Expanded/LayoutBuilder fill logic and no nested scroll view.
      return buildContent(_bwColWidth);
    }

    return Expanded(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final naturalWidth = breakweights.length * _bwColWidth;
          final fillWidth = naturalWidth <= constraints.maxWidth;
          final columnWidth = fillWidth
              ? constraints.maxWidth / breakweights.length
              : _bwColWidth;
          final content = buildContent(columnWidth);

          if (fillWidth) return content;
          return _HorizontalScrollPane(child: content);
        },
      ),
    );
  }
}

/// Wraps horizontally-overflowing content in a scroll view with a visible,
/// always-on, draggable scrollbar so the overflow is discoverable — a plain
/// [SingleChildScrollView] gives no hint that there's more to see.
class _HorizontalScrollPane extends StatefulWidget {
  const _HorizontalScrollPane({required this.child});

  final Widget child;

  @override
  State<_HorizontalScrollPane> createState() => _HorizontalScrollPaneState();
}

class _HorizontalScrollPaneState extends State<_HorizontalScrollPane> {
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
        child: widget.child,
      ),
    );
  }
}

/// Origin/destination field with a PSGC city or province autocomplete
/// dropdown (falls back to a plain text field when [options] is empty,
/// e.g. when matching by "Internal Code").
///
/// Renders the suggestion list on the root [Overlay], positioned by
/// reading the field's actual on-screen [RenderBox] each time the popup
/// rebuilds — not [RawAutocomplete]'s built-in popup (positions itself
/// with a [Transform] that ended up mismatched with its real hit-test
/// area in this table's nested layout — the list was visible but taps
/// never landed) and not [CompositedTransformFollower]/[LayerLink]
/// (crashed with a null `leaderSize` error the moment a selection
/// triggered a rebuild-then-remove of the overlay entry in the same
/// frame). Plain [RenderBox.localToGlobal] has no such internal link
/// state to desync, so there's nothing left to race.
class _LocationField extends StatefulWidget {
  const _LocationField({
    super.key,
    required this.value,
    required this.placeholder,
    required this.options,
    required this.onChanged,
  });

  final String value;
  final String placeholder;
  final List<String> options;
  final ValueChanged<String> onChanged;

  @override
  State<_LocationField> createState() => _LocationFieldState();
}

class _LocationFieldState extends State<_LocationField> {
  final _fieldKey = GlobalKey();
  late final _controller = TextEditingController(text: widget.value);
  final _focusNode = FocusNode();
  OverlayEntry? _entry;
  List<String> _matches = const [];
  bool _suppressTextListener = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onTextChanged);
    _focusNode.addListener(_onFocusChanged);
  }

  @override
  void didUpdateWidget(covariant _LocationField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != oldWidget.value && widget.value != _controller.text) {
      _suppressTextListener = true;
      _controller.value = TextEditingValue(
        text: widget.value,
        selection: TextSelection.collapsed(offset: widget.value.length),
      );
      _suppressTextListener = false;
    }
  }

  @override
  void dispose() {
    _removeOverlay();
    _controller.removeListener(_onTextChanged);
    _controller.dispose();
    _focusNode.removeListener(_onFocusChanged);
    _focusNode.dispose();
    super.dispose();
  }

  void _onFocusChanged() {
    if (!_focusNode.hasFocus) _removeOverlay();
  }

  void _onTextChanged() {
    if (_suppressTextListener) return;
    final query = _controller.text.trim().toLowerCase();
    final matches = query.isEmpty || widget.options.isEmpty
        ? const <String>[]
        : widget.options.where((o) => o.toLowerCase().contains(query)).toList();
    _matches = matches;
    if (matches.isEmpty) {
      _removeOverlay();
    } else if (_entry == null) {
      _showOverlay();
    } else {
      _entry!.markNeedsBuild();
    }
  }

  void _showOverlay() {
    _entry = OverlayEntry(
      builder: (context) {
        final renderBox =
            _fieldKey.currentContext?.findRenderObject() as RenderBox?;
        if (renderBox == null || !renderBox.attached) {
          return const SizedBox.shrink();
        }
        final position = renderBox.localToGlobal(Offset.zero);
        return Positioned(
          left: position.dx,
          top: position.dy + renderBox.size.height + 4,
          width: renderBox.size.width,
          child: TextFieldTapRegion(
            child: Material(
              elevation: 6,
              borderRadius: BorderRadius.circular(8),
              color: context.colors.surface,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 240),
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  shrinkWrap: true,
                  itemCount: _matches.length,
                  itemBuilder: (context, index) {
                    final option = _matches[index];
                    // Selection runs from the raw `onPointerDown` below, not
                    // from InkWell's onTap/onTapDown — those wait on
                    // gesture-arena resolution (or a ~100ms timeout), and on
                    // web the focused field's hidden native <input> blurs
                    // synchronously on the same mousedown, which tears this
                    // overlay down via `_onFocusChanged` before that
                    // resolution ever happens. A raw pointer listener fires
                    // immediately, unconditionally, ahead of that. InkWell
                    // stays only for the visual splash feedback.
                    return Listener(
                      behavior: HitTestBehavior.opaque,
                      onPointerDown: (_) => _select(option),
                      child: InkWell(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 10,
                          ),
                          child: Text(
                            option,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 13,
                              color: context.colors.textBody,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        );
      },
    );
    Overlay.of(context).insert(_entry!);
  }

  void _removeOverlay() {
    _entry?.remove();
    _entry = null;
  }

  void _select(String option) {
    debugPrint(
      '_LocationField._select: "$option" (placeholder: ${widget.placeholder})',
    );
    // Suppress the text listener for this mutation — otherwise it fires
    // mid-selection and tries to rebuild `_entry` right as `_removeOverlay`
    // below tears it down.
    _suppressTextListener = true;
    _controller.value = TextEditingValue(
      text: option,
      selection: TextSelection.collapsed(offset: option.length),
    );
    _suppressTextListener = false;
    widget.onChanged(option);
    _removeOverlay();
    _focusNode.unfocus();
  }

  @override
  Widget build(BuildContext context) {
    return ShadInput(
      key: _fieldKey,
      controller: _controller,
      focusNode: _focusNode,
      placeholder: Text(widget.placeholder),
      onChanged: widget.onChanged,
    );
  }
}

class _HeaderLabel extends StatelessWidget {
  const _HeaderLabel({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: context.colors.textMuted,
          letterSpacing: 0.4,
        ),
      ),
    );
  }
}

class _BreakweightHeaderCell extends StatelessWidget {
  const _BreakweightHeaderCell({
    required this.index,
    required this.breakweight,
    required this.width,
    required this.height,
    required this.removeDisabled,
    required this.onMinChanged,
    required this.onMaxChanged,
    required this.onRemove,
  });

  final int index;
  final Breakweight breakweight;
  final double width;
  final double height;
  final bool removeDisabled;
  final ValueChanged<String> onMinChanged;
  final ValueChanged<String> onMaxChanged;
  final VoidCallback onRemove;

  static const _compactInputPadding = EdgeInsets.symmetric(
    horizontal: 6,
    vertical: 8,
  );

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
      decoration: BoxDecoration(
        color: context.colors.surfaceSubtle,
        border: Border(
          left: BorderSide(color: context.colors.border),
          bottom: BorderSide(color: context.colors.border),
        ),
      ),
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.only(right: 14),
                child: Text(
                  'Breakweight ${index + 1}',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: context.colors.textMutedStrong,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: ShadInput(
                      placeholder: const Text('Min'),
                      initialValue: breakweight.min,
                      textAlign: TextAlign.center,
                      padding: _compactInputPadding,
                      onChanged: onMinChanged,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Text(
                      '–',
                      style: TextStyle(
                        fontSize: 12,
                        color: context.colors.textMuted,
                      ),
                    ),
                  ),
                  Expanded(
                    child: ShadInput(
                      placeholder: const Text('Max'),
                      initialValue: breakweight.max,
                      textAlign: TextAlign.center,
                      padding: _compactInputPadding,
                      onChanged: onMaxChanged,
                    ),
                  ),
                ],
              ),
            ],
          ),
          Positioned(
            top: -2,
            right: -2,
            child: IconButton(
              onPressed: removeDisabled ? null : onRemove,
              icon: const Icon(CupertinoIcons.xmark, size: 12),
              color: removeDisabled
                  ? context.colors.textFaint
                  : context.colors.destructive,
              splashRadius: 14,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 20, minHeight: 20),
            ),
          ),
        ],
      ),
    );
  }
}
