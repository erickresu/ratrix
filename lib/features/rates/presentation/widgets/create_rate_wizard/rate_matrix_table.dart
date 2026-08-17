import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

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
  });

  final List<domain.MatrixRow> matrixRows;
  final List<Breakweight> breakweights;
  final String originPlaceholder;
  final String destinationPlaceholder;
  final void Function(int rowIndex, String value) onOriginChanged;
  final void Function(int rowIndex, String value) onDestinationChanged;
  final void Function(int rowIndex, int breakweightIndex, String value) onCellChanged;
  final void Function(int index, String value) onBreakweightMinChanged;
  final void Function(int index, String value) onBreakweightMaxChanged;
  final void Function(int index) onRemoveBreakweight;
  final void Function(int rowIndex)? onRemoveRoute;

  static const _headerHeight = 92.0;
  static const _rowHeight = 58.0;
  static const _bwColWidth = 156.0;
  static const _leftPaneWidth = 560.0;
  static const _removeColWidth = 40.0;
  static const _compactInputPadding = EdgeInsets.symmetric(horizontal: 6, vertical: 8);

  @override
  Widget build(BuildContext context) {
    final removeDisabled = matrixRows.length <= 1;
    final bwRemoveDisabled = breakweights.length <= 1;
    final leftPaneWidth = _leftPaneWidth + (onRemoveRoute != null ? _removeColWidth : 0);

    return Container(
      decoration: BoxDecoration(
        color: RatesColors.surface,
        border: Border.all(color: RatesColors.border),
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [BoxShadow(color: RatesColors.shadowSoft, blurRadius: 16, offset: Offset(0, 4))],
      ),
      clipBehavior: Clip.antiAlias,
      child: Row(
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
                  decoration: const BoxDecoration(
                    color: RatesColors.surfaceSubtle,
                    border: Border(
                      bottom: BorderSide(color: RatesColors.border),
                      right: BorderSide(color: RatesColors.border),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Expanded(child: _HeaderLabel(label: 'Origin')),
                      const Expanded(child: _HeaderLabel(label: 'Destination')),
                      if (onRemoveRoute != null) const SizedBox(width: _removeColWidth),
                    ],
                  ),
                ),
                for (var i = 0; i < matrixRows.length; i++)
                  Container(
                    height: _rowHeight,
                    decoration: const BoxDecoration(
                      border: Border(
                        top: BorderSide(color: RatesColors.surfaceMuted),
                        right: BorderSide(color: RatesColors.surfaceMuted),
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: ShadInput(
                              placeholder: Text(originPlaceholder),
                              initialValue: matrixRows[i].origin,
                              onChanged: (v) => onOriginChanged(i, v),
                            ),
                          ),
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: ShadInput(
                              placeholder: Text(destinationPlaceholder),
                              initialValue: matrixRows[i].destination,
                              onChanged: (v) => onDestinationChanged(i, v),
                            ),
                          ),
                        ),
                        if (onRemoveRoute != null)
                          SizedBox(
                            width: _removeColWidth,
                            child: IconButton(
                              onPressed: removeDisabled ? null : () => onRemoveRoute!(i),
                              icon: const Icon(CupertinoIcons.xmark, size: 14),
                              color: removeDisabled ? RatesColors.textFaint : RatesColors.destructive,
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
          // columns fit, otherwise switches to fixed-width + horizontal scroll.
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final naturalWidth = breakweights.length * _bwColWidth;
                final fillWidth = naturalWidth <= constraints.maxWidth;
                final columnWidth = fillWidth ? constraints.maxWidth / breakweights.length : _bwColWidth;

                final content = Column(
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
                        decoration: const BoxDecoration(
                          border: Border(top: BorderSide(color: RatesColors.surfaceMuted)),
                        ),
                        child: Row(
                          children: [
                            for (var bi = 0; bi < breakweights.length; bi++)
                              Container(
                                width: columnWidth,
                                alignment: Alignment.center,
                                padding: const EdgeInsets.symmetric(horizontal: 12),
                                decoration: const BoxDecoration(
                                  border: Border(left: BorderSide(color: RatesColors.surfaceMuted)),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Text(r'$', style: TextStyle(fontSize: 12, color: RatesColors.primaryDeep)),
                                    const SizedBox(width: 4),
                                    SizedBox(
                                      width: 68,
                                      child: ShadInput(
                                        placeholder: const Text('0.00'),
                                        initialValue: i < matrixRows.length && bi < matrixRows[i].rates.length
                                            ? matrixRows[i].rates[bi]
                                            : '',
                                        textAlign: TextAlign.center,
                                        padding: _compactInputPadding,
                                        decoration: const ShadDecoration(
                                          color: RatesColors.primarySoftBg,
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

                if (fillWidth) return content;
                return SingleChildScrollView(scrollDirection: Axis.horizontal, child: content);
              },
            ),
          ),
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
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: RatesColors.textMuted,
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

  static const _compactInputPadding = EdgeInsets.symmetric(horizontal: 6, vertical: 8);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
      decoration: const BoxDecoration(
        color: RatesColors.surfaceSubtle,
        border: Border(
          left: BorderSide(color: RatesColors.border),
          bottom: BorderSide(color: RatesColors.border),
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
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: RatesColors.textMutedStrong),
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
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 4),
                    child: Text('–', style: TextStyle(fontSize: 12, color: RatesColors.textMuted)),
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
              color: removeDisabled ? RatesColors.textFaint : RatesColors.destructive,
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
