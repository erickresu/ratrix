import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../../../../core/utils/breakpoints.dart';
import '../../../domain/entities/breakweight.dart';
import '../../../domain/entities/location_option.dart';
import '../../../domain/entities/matrix_row.dart' as domain;
import '../../../domain/entities/rates_enums.dart';
import '../../rates_colors.dart';
import 'change_match_by_dialog.dart';

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
    this.originSearchResults = const [],
    this.destinationSearchResults = const [],
    this.originSearchLoading = false,
    this.destinationSearchLoading = false,
    this.originSearchType = LocationSearchType.island,
    this.destinationSearchType = LocationSearchType.island,
    this.onOriginQueryChanged,
    this.onDestinationQueryChanged,
    this.onOriginSelected,
    this.onDestinationSelected,
    this.onOriginSearchTypeChanged,
    this.onDestinationSearchTypeChanged,
  });

  final List<domain.MatrixRow> matrixRows;
  final List<Breakweight> breakweights;
  final String originPlaceholder;
  final String destinationPlaceholder;

  /// Origin and Destination each search independently with their own type
  /// filter, results, and loading state — both fields can search
  /// simultaneously with different types.
  final List<LocationOption> originSearchResults;
  final List<LocationOption> destinationSearchResults;
  final bool originSearchLoading;
  final bool destinationSearchLoading;
  final LocationSearchType originSearchType;
  final LocationSearchType destinationSearchType;
  final void Function(int rowIndex, String value) onOriginChanged;
  final void Function(int rowIndex, String value) onDestinationChanged;

  /// Fired on every keystroke in the Origin/Destination field respectively —
  /// triggers each field's own debounced server search. Null falls back to
  /// no live search (the field still accepts free text via
  /// [onOriginChanged]/[onDestinationChanged]).
  final ValueChanged<String>? onOriginQueryChanged;
  final ValueChanged<String>? onDestinationQueryChanged;
  final void Function(int rowIndex, LocationOption option, String displayText)? onOriginSelected;
  final void Function(int rowIndex, LocationOption option, String displayText)? onDestinationSelected;

  /// Changes to each column's "match by" filter type, shown inline in that
  /// column's header. Null hides the dropdown for that column.
  final ValueChanged<LocationSearchType>? onOriginSearchTypeChanged;
  final ValueChanged<LocationSearchType>? onDestinationSearchTypeChanged;
  final void Function(int rowIndex, int breakweightIndex, String value)
  onCellChanged;
  final void Function(int index, String value) onBreakweightMinChanged;
  final void Function(int index, String value) onBreakweightMaxChanged;
  final void Function(int index) onRemoveBreakweight;
  final void Function(int rowIndex)? onRemoveRoute;

  static const _headerHeight = 104.0;
  static const _rowHeight = 64.0;
  static const _bwColWidth = 156.0;
  static const _leftPaneWidth = 560.0;
  // Widened from 340 so each Origin/Destination field has enough room for
  // the inline leading "match by" label (30% of field width) plus a usable
  // text-entry area on mobile — the whole table already scrolls
  // horizontally as one unit on mobile, so a wider pane is safe.
  static const _leftPaneWidthMobile = 460.0;
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
                          padding: const EdgeInsets.fromLTRB(16, 0, 4, 0),
                          child: _LocationField(
                            key: ValueKey('origin-$i-$originPlaceholder'),
                            value: matrixRows[i].origin,
                            placeholder: originPlaceholder,
                            options: originSearchResults,
                            loading: originSearchLoading,
                            formatOption: originSearchType.formatOption,
                            matchByType: originSearchType,
                            onMatchByChanged: onOriginSearchTypeChanged,
                            onChanged: (v) => onOriginChanged(i, v),
                            onQueryChanged: onOriginQueryChanged,
                            onOptionSelected: onOriginSelected == null
                                ? null
                                : (option, text) => onOriginSelected!(i, option, text),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(4, 0, 16, 0),
                          child: _LocationField(
                            key: ValueKey(
                              'destination-$i-$destinationPlaceholder',
                            ),
                            value: matrixRows[i].destination,
                            placeholder: destinationPlaceholder,
                            options: destinationSearchResults,
                            loading: destinationSearchLoading,
                            formatOption: destinationSearchType.formatOption,
                            matchByType: destinationSearchType,
                            onMatchByChanged: onDestinationSearchTypeChanged,
                            onChanged: (v) => onDestinationChanged(i, v),
                            onQueryChanged: onDestinationQueryChanged,
                            onOptionSelected: onDestinationSelected == null
                                ? null
                                : (option, text) => onDestinationSelected!(i, option, text),
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
    required this.formatOption,
    required this.onChanged,
    this.loading = false,
    this.onQueryChanged,
    this.onOptionSelected,
    this.matchByType,
    this.onMatchByChanged,
  });

  final String value;
  final String placeholder;

  /// Server-filtered search results — not re-filtered client-side, this
  /// list IS what's shown.
  final List<LocationOption> options;
  final bool loading;
  final String Function(LocationOption) formatOption;
  final ValueChanged<String> onChanged;

  /// Fires on every keystroke to trigger the debounced server search.
  final ValueChanged<String>? onQueryChanged;

  /// Fires when a suggestion is picked, carrying the full option so the
  /// caller can resolve a typed id — `onChanged` still also fires with the
  /// formatted display text so the plain text-sync path keeps working.
  final void Function(LocationOption option, String displayText)? onOptionSelected;

  /// This field's current "match by" filter type, and the callback to
  /// change it — shown docked inside the field as a leading widget.
  final LocationSearchType? matchByType;
  final ValueChanged<LocationSearchType>? onMatchByChanged;

  @override
  State<_LocationField> createState() => _LocationFieldState();
}

class _LocationFieldState extends State<_LocationField> {
  final _fieldKey = GlobalKey();
  late final _controller = TextEditingController(text: widget.value);
  final _focusNode = FocusNode();
  OverlayEntry? _entry;
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
    // Results/loading state arrives from the parent (server-driven, not
    // filtered locally) — rebuild the overlay whenever either changes so a
    // focused field shows fresh results/spinner state without needing a
    // keystroke to trigger it. Deferred to a post-frame callback: this
    // widget's own rebuild can itself be triggered by an ancestor rebuild
    // (e.g. another sibling field's "match by" selection changing bloc
    // state), in which case `didUpdateWidget` runs mid-build — inserting or
    // marking-dirty an `OverlayEntry` synchronously in that window throws
    // ("setState() called during build").
    if (_focusNode.hasFocus &&
        (widget.options != oldWidget.options || widget.loading != oldWidget.loading)) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        if (widget.options.isNotEmpty || widget.loading) {
          if (_entry == null) {
            _showOverlay();
          } else {
            _entry!.markNeedsBuild();
          }
        } else {
          _removeOverlay();
        }
      });
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
    if (!_focusNode.hasFocus) {
      _removeOverlay();
      return;
    }
    // Gaining focus re-requests results for the current text — even when
    // empty, so an empty focused field shows all options for the current
    // "match by" type rather than requiring a keystroke first — rather
    // than trusting whatever the shared search state currently holds (it
    // may reflect a different field's last query).
    widget.onQueryChanged?.call(_controller.text.trim());
    if (_entry == null) _showOverlay();
  }

  void _onTextChanged() {
    if (_suppressTextListener) return;
    final query = _controller.text.trim();
    widget.onQueryChanged?.call(query);
    if (_entry == null) {
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
                child: widget.loading
                    ? const Padding(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        child: Center(
                          child: SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        shrinkWrap: true,
                        itemCount: widget.options.length,
                        itemBuilder: (context, index) {
                          final option = widget.options[index];
                          final display = widget.formatOption(option);
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
                            onPointerDown: (_) => _select(option, display),
                            child: InkWell(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 10,
                                ),
                                child: Text(
                                  display,
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

  void _select(LocationOption option, String display) {
    // Suppress the text listener for this mutation — otherwise it fires
    // mid-selection and tries to rebuild `_entry` right as `_removeOverlay`
    // below tears it down.
    _suppressTextListener = true;
    _controller.value = TextEditingValue(
      text: display,
      selection: TextSelection.collapsed(offset: display.length),
    );
    _suppressTextListener = false;
    widget.onChanged(display);
    widget.onOptionSelected?.call(option, display);
    _removeOverlay();
    _focusNode.unfocus();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return ShadInput(
          key: _fieldKey,
          controller: _controller,
          focusNode: _focusNode,
          placeholder: Text(widget.placeholder),
          leading: widget.matchByType == null
              ? null
              : SizedBox(
                  width: constraints.maxWidth * 0.3,
                  child: _MatchByLeading(
                    value: widget.matchByType!,
                    onChanged: (type) async {
                      // The current value was resolved under the old
                      // filter and won't make sense under the new one —
                      // confirm before clearing it, but only for this
                      // field; the filter itself still applies to the
                      // whole column going forward.
                      if (_controller.text.trim().isNotEmpty) {
                        final confirmed = await showShadDialog<bool>(
                          context: context,
                          builder: (_) => const ChangeMatchByDialog(),
                        );
                        if (confirmed != true) return;
                        if (!context.mounted) return;
                        // Mirrors typing an empty string — the bloc's
                        // OriginChanged/DestinationChanged handlers already
                        // clear the row's resolved id whenever the text no
                        // longer matches what it was resolved for. Suppress
                        // the text listener during the clear — it would
                        // otherwise fire a redundant query under the OLD
                        // filter type, right before the explicit re-query
                        // below fires again under the new one.
                        _suppressTextListener = true;
                        _controller.clear();
                        _suppressTextListener = false;
                        widget.onChanged('');
                        _removeOverlay();
                      }
                      widget.onMatchByChanged?.call(type);
                      // Re-request under the new type so a focused field
                      // (typed or empty) refreshes its menu immediately
                      // instead of waiting for another keystroke.
                      widget.onQueryChanged?.call(_controller.text.trim());
                    },
                  ),
                ),
          trailing: Icon(CupertinoIcons.chevron_down, size: 14, color: context.colors.textMuted),
          onChanged: widget.onChanged,
        );
      },
    );
  }
}

/// Compact "match by" label docked at a search field's leading edge — shows
/// this field's current filter type (e.g. "City") and opens the same
/// 6-option menu as a plain [ShadSelect] on tap, styled to read as an
/// inline label rather than a boxed dropdown.
class _MatchByLeading extends StatelessWidget {
  const _MatchByLeading({required this.value, required this.onChanged});

  final LocationSearchType value;
  final ValueChanged<LocationSearchType>? onChanged;

  static const _shortLabels = {
    LocationSearchType.island: 'Island',
    LocationSearchType.cityProvince: 'City',
    LocationSearchType.province: 'Province',
    LocationSearchType.internalCode: 'Code',
    LocationSearchType.iataCode: 'IATA',
    LocationSearchType.seaPortCode: 'Sea Port',
  };

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 22,
      child: ShadSelect<LocationSearchType>(
        initialValue: value,
        decoration: const ShadDecoration(
          border: ShadBorder.none,
          focusedBorder: ShadBorder.none,
          secondaryBorder: ShadBorder.none,
          secondaryFocusedBorder: ShadBorder.none,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 6),
        selectedOptionBuilder: (context, v) => Text(
          _shortLabels[v] ?? v.label,
          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: context.colors.primaryDeep),
          overflow: TextOverflow.ellipsis,
          maxLines: 1,
        ),
        onChanged: (v) {
          if (v != null) onChanged?.call(v);
        },
        options: [
          for (final t in LocationSearchType.values)
            ShadOption(value: t, child: Text(t.label)),
        ],
      ),
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

  /// Min is locked/derived, so the only way to get an invalid tier is
  /// typing a max at or below that same tier's own min — an empty max
  /// isn't an error, it's just not filled in yet.
  bool get _hasError {
    if (breakweight.max.isEmpty) return false;
    final min = num.tryParse(breakweight.min);
    final max = num.tryParse(breakweight.max);
    if (min == null || max == null) return false;
    return max <= min;
  }

  @override
  Widget build(BuildContext context) {
    final hasError = _hasError;
    return Container(
      width: width,
      height: height,
      padding: const EdgeInsets.fromLTRB(8, 6, 6, 6),
      decoration: BoxDecoration(
        color: context.colors.surfaceSubtle,
        border: Border(
          left: BorderSide(color: context.colors.border),
          bottom: BorderSide(color: context.colors.border),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Breakweight ${index + 1}',
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                  style: TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.2,
                    color: context.colors.textMutedStrong,
                  ),
                ),
              ),
              SizedBox(
                width: 18,
                height: 18,
                child: IconButton(
                  onPressed: removeDisabled ? null : onRemove,
                  icon: const Icon(CupertinoIcons.xmark, size: 11),
                  color: removeDisabled ? context.colors.textFaint : context.colors.destructive,
                  splashRadius: 12,
                  padding: EdgeInsets.zero,
                  visualDensity: VisualDensity.compact,
                  constraints: const BoxConstraints(minWidth: 18, minHeight: 18, maxWidth: 18, maxHeight: 18),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Expanded(
                child: ShadInput(
                  // `initialValue` only seeds the field's controller once
                  // (on first build) and doesn't sync on rebuild — since
                  // min is derived and can change from an edit to an
                  // earlier tier's max, key on the value itself so Flutter
                  // treats a changed min as a fresh field instead of
                  // reusing the old controller's stale text.
                  key: ValueKey('bw-min-$index-${breakweight.min}'),
                  placeholder: const Text('Min'),
                  initialValue: breakweight.min,
                  textAlign: TextAlign.center,
                  padding: _compactInputPadding,
                  enabled: false,
                  onChanged: onMinChanged,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Text('–', style: TextStyle(fontSize: 12, color: context.colors.textMuted)),
              ),
              Expanded(
                child: ShadInput(
                  placeholder: const Text('Max'),
                  initialValue: breakweight.max,
                  textAlign: TextAlign.center,
                  padding: _compactInputPadding,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: hasError
                      ? ShadDecoration(
                          border: ShadBorder.all(color: context.colors.destructive),
                          focusedBorder: ShadBorder.all(color: context.colors.destructive, width: 2),
                        )
                      : null,
                  onChanged: onMaxChanged,
                ),
              ),
            ],
          ),
          if (hasError) ...[
            const SizedBox(height: 3),
            Text(
              'Max must be greater than ${breakweight.min}',
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
              style: TextStyle(fontSize: 9.5, color: context.colors.destructive),
            ),
          ],
        ],
      ),
    );
  }
}
