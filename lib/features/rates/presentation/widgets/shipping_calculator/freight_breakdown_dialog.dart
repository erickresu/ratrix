import 'dart:async';
import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../../../../core/widgets/mr_ratrix.dart';
import '../../../domain/entities/client.dart';
import '../../../domain/entities/ratrix_rate.dart';
import '../../../domain/entities/rates_enums.dart';
import '../../bloc/rates_shell_bloc.dart';
import '../../bloc/shipping_calculator_bloc.dart';
import '../../rates_colors.dart';
import 'invoice_pdf.dart';

/// Runs the Calculate flow in a blurred-backdrop dialog: computes the
/// result immediately, plays it back on a calculator-style LCD tape (typed
/// out line by line — however long that takes, no fixed clock), then the
/// same popup flips to the full breakdown with Close/Generate Invoice
/// actions — same sequence on every screen size. What differs by platform
/// is only what happens once Close is pressed and this popup closes:
///
/// - [keepResultForPanel] `true` (desktop/tablet): the result stays put
///   and [FreightBreakdownPanel]'s docked right-hand column reveals it —
///   closing the popup is how you "send" the answer over there.
/// - `false` (mobile, no room for a docked panel): the result is cleared,
///   same as before — there's nowhere else for it to live.
///
/// Mirrors the wizard's other modal (`NewRateModal`) but with its own
/// barrier since this one needs a real blur behind it instead of a flat
/// scrim.
Future<void> showFreightBreakdownDialog(
  BuildContext context, {
  required ShippingCalculatorBloc calcBloc,
  required RatesShellBloc shellBloc,
  required Client client,
  required bool keepResultForPanel,
}) async {
  calcBloc.add(const CalcSubmitRequested());
  await showShadDialog<void>(
    context: context,
    barrierColor: Colors.transparent,
    // `showShadDialog` pushes onto the root Navigator, outside the
    // RatesShellPage's `BlocProvider<RatesShellBloc>` subtree — re-provide
    // both blocs explicitly rather than relying on ambient lookup (the
    // "Edit this rate" button needs RatesShellBloc to navigate).
    builder: (dialogContext) => MultiBlocProvider(
      providers: [
        BlocProvider.value(value: calcBloc),
        BlocProvider.value(value: shellBloc),
      ],
      child: _BlurredBarrier(child: _FreightBreakdownFlow(client: client)),
    ),
  );
  // Whichever way the popup closed (Close button, barrier tap, back
  // button): on desktop, send the result over to the docked panel; on
  // mobile, clear it so the next Calculate press is guaranteed a fresh
  // null -> non-null transition.
  calcBloc.add(keepResultForPanel ? const CalcResultRevealed() : const CalcResultDismissed());
}

/// Calculating beat -> result reveal, in one dialog. Kept as a single
/// widget (rather than swapping dialogs) so the transition reads as one
/// continuous popup rather than a flicker of two.
class _FreightBreakdownFlow extends StatefulWidget {
  const _FreightBreakdownFlow({required this.client});

  final Client client;

  @override
  State<_FreightBreakdownFlow> createState() => _FreightBreakdownFlowState();
}

class _FreightBreakdownFlowState extends State<_FreightBreakdownFlow> {
  bool _revealed = false;

  @override
  Widget build(BuildContext context) {
    return _revealed
        ? _FreightBreakdownDialog(client: widget.client)
        : _CalculatingDialog(onFinished: () => setState(() => _revealed = true));
  }
}

/// Full-width cap shared by the calculating and result dialogs so the
/// reveal doesn't visibly resize the popup — `_BlurredBarrier` centers
/// with no horizontal padding of its own, so a flat 480px cap would
/// overflow off both edges of any screen narrower than that (every phone).
double _dialogMaxWidth(BuildContext context) {
  final screenWidth = MediaQuery.sizeOf(context).width;
  return screenWidth - 32 < 560 ? screenWidth - 32 : 560.0;
}

/// One line of the calculating popup's step-by-step arithmetic — built
/// straight from the already-computed [CalcResult]/state, the same numbers
/// [_ResultBody] renders, just presented as a running tally instead of a
/// finished table. [runningTotal] is null for the weight line (nothing
/// monetary yet) and the cumulative total *as of that line* everywhere
/// else — so it reads as pre-VAT until the VAT line lands, then post-VAT
/// from there on, same order a real calculator would show it in.
typedef _CalcStep = ({String text, num? runningTotal});

List<_CalcStep> _calculationSteps(ShippingCalculatorState state) {
  final result = state.calcResult;
  if (result == null || result.error != null) return const [];

  num displayValue(num v) => state.roundedDisplay ? v.roundToDouble() : v;
  String money(num v) => '₱${displayValue(v).toStringAsFixed(2)}';

  final steps = <_CalcStep>[];

  if (result.chargeableWeight != null) {
    steps.add((
      text: 'Chargeable weight = ${result.chargeableWeight!.toStringAsFixed(2)} kg',
      runningTotal: null,
    ));
  }

  final baseFreight = result.baseFreight ?? 0;
  num running = baseFreight;
  steps.add((
    text: result.tierRate != null && result.chargeableWeight != null
        ? '${result.chargeableWeight!.toStringAsFixed(2)} kg × ${money(result.tierRate!)}/kg = ${money(baseFreight)}'
        : 'Base freight = ${money(baseFreight)}',
    runningTotal: running,
  ));

  // All the add-on fees (fuel surcharge + every flat fee) land in one
  // combined line rather than one line per fee — a rate with a dozen
  // add-ons would otherwise turn the tape into a slog.
  final addonsTotal = (result.fuelSurcharge ?? 0) + result.flatFees.values.fold<num>(0, (sum, v) => sum + v);
  if (addonsTotal != 0) {
    running += addonsTotal;
    steps.add((text: '+ Add-ons = ${money(addonsTotal)}', runningTotal: running));
  }

  final subTotal = result.subTotal ?? running;
  steps.add((text: 'Sub-total = ${money(subTotal)}', runningTotal: subTotal));
  running = subTotal;

  if (state.vatMode == VatMode.standard) {
    running += state.vatAmount;
    steps.add((
      text: '+ VAT (${(ShippingCalculatorState.vatRate * 100).toStringAsFixed(0)}%) = ${money(state.vatAmount)}',
      runningTotal: running,
    ));
  }

  steps.add((
    text: 'Grand total = ${money(displayValue(state.grandTotal))}',
    runningTotal: displayValue(state.grandTotal),
  ));
  return steps;
}

/// Shown while [_FreightBreakdownFlowState] waits to reveal the
/// already-computed result — plays it back on a calculator-style LCD tape,
/// typing each line out character by character (like keying it into a real
/// calculator) with finished lines scrolling up as a running receipt above
/// the active one. Calls [onFinished] the moment the last line finishes
/// typing plus a short settle beat — there's no fixed clock, so the wait
/// naturally scales with how much there is to show instead of always
/// taking exactly one duration.
class _CalculatingDialog extends StatefulWidget {
  const _CalculatingDialog({required this.onFinished});

  final VoidCallback onFinished;

  @override
  State<_CalculatingDialog> createState() => _CalculatingDialogState();
}

class _CalculatingDialogState extends State<_CalculatingDialog> {
  static const _charDelay = Duration(milliseconds: 26);
  static const _linePause = Duration(milliseconds: 300);
  static const _settlePause = Duration(milliseconds: 550);
  static const _noStepsPause = Duration(milliseconds: 1300);

  late final List<_CalcStep> _steps;
  final List<String> _completedLines = [];
  String _typedText = '';
  int _currentLine = 0;

  /// The mascot's running total — updated once a line finishes typing
  /// (its arithmetic has "landed"), not preemptively while it's still
  /// being keyed in.
  num? _displayedTotal;
  Timer? _timer;
  bool _finished = false;

  @override
  void initState() {
    super.initState();
    _steps = _calculationSteps(context.read<ShippingCalculatorBloc>().state);
    if (_steps.isEmpty) {
      Future.delayed(_noStepsPause, _finish);
      return;
    }
    _typeLine();
  }

  void _typeLine() {
    final line = _steps[_currentLine].text;
    var charCount = 0;
    _timer = Timer.periodic(_charDelay, (timer) {
      charCount++;
      setState(() => _typedText = line.substring(0, charCount));
      if (charCount >= line.length) {
        timer.cancel();
        Future.delayed(_linePause, _advance);
      }
    });
  }

  void _advance() {
    if (!mounted) return;
    final finishedTotal = _steps[_currentLine].runningTotal;
    final isLastLine = _currentLine >= _steps.length - 1;
    setState(() {
      if (finishedTotal != null) _displayedTotal = finishedTotal;
      if (!isLastLine) {
        _completedLines.add(_typedText);
        _currentLine++;
        _typedText = '';
      }
    });
    if (isLastLine) {
      Future.delayed(_settlePause, _finish);
    } else {
      _typeLine();
    }
  }

  /// Guards against calling [widget.onFinished] twice — a pending
  /// [Future.delayed] from the natural typing sequence can still land after
  /// the user taps Skip, which already called this once.
  void _finish() {
    if (_finished) return;
    _finished = true;
    _timer?.cancel();
    widget.onFinished();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final previousLine = _completedLines.isEmpty ? '' : _completedLines.last;
    final activeChar = _typedText.isEmpty ? null : _typedText[_typedText.length - 1];

    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: _dialogMaxWidth(context)),
      child: ShadDialog(
        radius: BorderRadius.circular(16),
        backgroundColor: context.colors.surface,
        padding: EdgeInsets.zero,
        closeIcon: const SizedBox.shrink(),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Align(
                alignment: Alignment.topRight,
                child: _SkipButton(onTap: _finish),
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const MrRatrix(size: 76),
                  const SizedBox(width: 6),
                  Expanded(
                    child: _MascotSpeechBubble(
                      text: _displayedTotal == null
                          ? 'Let me work out your freight breakdown...'
                          : "That's ₱${_displayedTotal!.toStringAsFixed(2)} so far...",
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              if (_steps.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  child: SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(strokeWidth: 2.5),
                  ),
                )
              else
                _CalculatorBody(previousLine: previousLine, currentLine: _typedText, activeChar: activeChar),
            ],
          ),
        ),
      ),
    );
  }
}

/// A real-looking calculator: a two-line LCD screen (a dimmed previous
/// entry above the active one being keyed in, same idea as a physical
/// calculator's running-total display) sitting on a button pad that lights
/// up whichever key matches the character currently being typed.
/// Speech-bubble caption beside Mr. Ratrix — a small rotated-square tail
/// pointing back at him so the calculating message reads as him narrating
/// it, rather than a plain caption floating under the mascot.
class _MascotSpeechBubble extends StatelessWidget {
  const _MascotSpeechBubble({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final bg = context.colors.surfaceSubtle;
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Positioned(
          left: -5,
          top: 18,
          child: Transform.rotate(
            angle: math.pi / 4,
            child: Container(
              width: 14,
              height: 14,
              decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(3)),
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(14)),
          child: Text(
            text,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: context.colors.textBody,
            ),
          ),
        ),
      ],
    );
  }
}

class _CalculatorBody extends StatelessWidget {
  const _CalculatorBody({
    required this.previousLine,
    required this.currentLine,
    required this.activeChar,
  });

  final String previousLine;
  final String currentLine;
  final String? activeChar;

  static const _keyRows = [
    ['AC', '⌫', '%', '÷'],
    ['7', '8', '9', '×'],
    ['4', '5', '6', '−'],
    ['1', '2', '3', '+'],
    ['0', '.', '='],
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF2B2E33),
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 16, offset: Offset(0, 8))],
      ),
      child: Column(
        children: [
          _CalculatorScreen(previousLine: previousLine, currentLine: currentLine),
          const SizedBox(height: 12),
          for (final row in _keyRows) ...[
            Row(
              children: [
                for (final key in row)
                  Expanded(
                    // The bottom row's '0' key spans two columns on a real
                    // calculator (there's no second key after it).
                    flex: key == '0' ? 2 : 1,
                    child: Padding(
                      padding: const EdgeInsets.all(4),
                      child: _CalculatorKey(
                        label: key,
                        active: activeChar == key,
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _CalculatorScreen extends StatelessWidget {
  const _CalculatorScreen({required this.previousLine, required this.currentLine});

  final String previousLine;
  final String currentLine;

  @override
  Widget build(BuildContext context) {
    const lcdText = Color(0xFF7CF9A6);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFF16261C),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.black.withValues(alpha: 0.4), width: 2),
        boxShadow: [BoxShadow(color: lcdText.withValues(alpha: 0.15), blurRadius: 10)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            height: 20,
            child: Text(
              previousLine,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 13,
                fontFamily: 'monospace',
                fontWeight: FontWeight.w600,
                color: lcdText.withValues(alpha: 0.45),
              ),
            ),
          ),
          const SizedBox(height: 4),
          SizedBox(
            height: 34,
            child: Text(
              '$currentLine▏',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 23,
                fontFamily: 'monospace',
                fontWeight: FontWeight.w800,
                letterSpacing: 0.4,
                color: lcdText,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// One physical-looking calculator key — briefly "lit" (brighter fill,
/// slight press-down scale) whenever [active], as if the calculator is
/// pressing its own buttons to work the problem out.
/// Jumps straight to the result reveal for anyone who doesn't want to
/// watch the calculating animation play out.
class _SkipButton extends StatelessWidget {
  const _SkipButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: context.colors.surfaceMuted,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Skip',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: context.colors.textMutedStrong,
                ),
              ),
              const SizedBox(width: 4),
              Icon(CupertinoIcons.forward_end_fill, size: 12, color: context.colors.textMutedStrong),
            ],
          ),
        ),
      ),
    );
  }
}

class _CalculatorKey extends StatelessWidget {
  const _CalculatorKey({required this.label, required this.active});

  final String label;
  final bool active;

  bool get _isOperator => const {'AC', '⌫', '%', '÷', '×', '−', '+', '='}.contains(label);

  @override
  Widget build(BuildContext context) {
    final baseColor = _isOperator ? const Color(0xFF3D6B52) : const Color(0xFF454951);
    return AnimatedContainer(
      duration: const Duration(milliseconds: 90),
      curve: Curves.easeOut,
      height: 46,
      transform: active ? Matrix4.diagonal3Values(0.92, 0.92, 1) : Matrix4.identity(),
      transformAlignment: Alignment.center,
      decoration: BoxDecoration(
        color: active ? const Color(0xFF7CF9A6) : baseColor,
        borderRadius: BorderRadius.circular(10),
        boxShadow: active
            ? [BoxShadow(color: const Color(0xFF7CF9A6).withValues(alpha: 0.6), blurRadius: 8)]
            : null,
      ),
      alignment: Alignment.center,
      child: Text(
        label,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w700,
          color: active ? const Color(0xFF16261C) : Colors.white.withValues(alpha: 0.85),
        ),
      ),
    );
  }
}

/// Docked, always-in-page-flow version of the freight breakdown — used by
/// the calculator's desktop/tablet layout as the right-hand panel instead of
/// a modal (see `ShippingCalculatorFormWeb`). Shows a placeholder until a
/// result exists, then the same header/body/PDF button as the dialog minus
/// the close button and blur backdrop.
class FreightBreakdownPanel extends StatelessWidget {
  const FreightBreakdownPanel({
    super.key,
    required this.client,
    this.showButton = true,
  });

  final Client client;

  /// Set false when the caller renders the Generate Invoice PDF button
  /// itself in a separate slot (e.g. to bottom-align it against another
  /// column's own trailing button row).
  final bool showButton;

  @override
  Widget build(BuildContext context) {
    final state = context.watch<ShippingCalculatorBloc>().state;
    // Hidden until the calculating popup reveals it, even though the
    // result itself was computed the instant Calculate was pressed — see
    // `calcResultRevealed`'s doc comment.
    final result = state.calcResultRevealed ? state.calcResult : null;

    if (result == null) {
      return Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: context.colors.surface,
          border: Border.all(color: context.colors.border),
          borderRadius: BorderRadius.circular(16),
        ),
        alignment: Alignment.center,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              CupertinoIcons.arrow_down_circle,
              size: 32,
              color: context.colors.textFaint,
            ),
            const SizedBox(height: 12),
            Text(
              'Freight Breakdown',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: context.colors.textMutedStrong,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Fill in the details and calculate to see the breakdown here.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: context.colors.textMuted),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: _PulsingBorderCard(
            borderRadius: BorderRadius.circular(16),
            child: Column(
              children: [
                _DialogHeader(state: state),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
                    child: result.error != null
                        ? _ErrorBody(
                            message: result.error!,
                            origin: state.origin,
                            destination: state.destination,
                            tiers: result.routeTiers,
                            onEditRate: state.selectedRate == null
                                ? null
                                : () {
                                    final rateId = state.selectedRate!.id;
                                    context.read<RatesShellBloc>().add(
                                      EditRateRequested(rateId),
                                    );
                                  },
                          )
                        : const _ResultBody(),
                  ),
                ),
              ],
            ),
          ),
        ),
        if (showButton && result.error == null) ...[
          const SizedBox(height: 12),
          GeneratePdfButton(state: state, client: client),
        ],
      ],
    );
  }
}

/// Wraps the docked result card in a slow, continuous border-color pulse
/// (normal border <-> gold) so the panel keeps gently drawing the eye while
/// a result is showing — the panel would otherwise blend into the page next
/// to the plain-bordered form cards.
class _PulsingBorderCard extends StatefulWidget {
  const _PulsingBorderCard({required this.child, required this.borderRadius});

  final Widget child;
  final BorderRadius borderRadius;

  @override
  State<_PulsingBorderCard> createState() => _PulsingBorderCardState();
}

class _PulsingBorderCardState extends State<_PulsingBorderCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2600),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final borderColor = Color.lerp(
          context.colors.border,
          context.colors.primary,
          _controller.value,
        )!;
        return Container(
          decoration: BoxDecoration(
            borderRadius: widget.borderRadius,
            boxShadow: [
              BoxShadow(
                color: context.colors.primary.withValues(
                  alpha: 0.2 * _controller.value,
                ),
                blurRadius: 14,
                spreadRadius: 0.5,
              ),
            ],
          ),
          child: Container(
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              color: context.colors.surface,
              borderRadius: widget.borderRadius,
              border: Border.all(color: borderColor, width: 2),
            ),
            child: child,
          ),
        );
      },
      child: widget.child,
    );
  }
}

class _BlurredBarrier extends StatelessWidget {
  const _BlurredBarrier({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
            child: Container(color: Colors.black.withValues(alpha: 0.45)),
          ),
        ),
        Align(
          alignment: const Alignment(0, -0.6),
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: child,
          ),
        ),
      ],
    );
  }
}

/// Drives a slow, continuous pulse (normal border <-> gold, plus a matching
/// glow) directly through [ShadDialog]'s own `border`/`shadows` params,
/// instead of wrapping it in a second bordered container (which would
/// double up on top of the dialog's own border/background).
class _PulsingDialogBorder extends StatefulWidget {
  const _PulsingDialogBorder({required this.builder});

  final Widget Function(
    BuildContext context,
    Border border,
    List<BoxShadow> shadows,
  )
  builder;

  @override
  State<_PulsingDialogBorder> createState() => _PulsingDialogBorderState();
}

class _PulsingDialogBorderState extends State<_PulsingDialogBorder>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final borderColor = Color.lerp(
          context.colors.border,
          context.colors.primary,
          _controller.value,
        )!;
        return widget
            .builder(context, Border.all(color: borderColor, width: 2), [
              BoxShadow(
                color: context.colors.primary.withValues(
                  alpha: 0.3 * _controller.value,
                ),
                blurRadius: 18,
                spreadRadius: 1.5,
              ),
            ]);
      },
    );
  }
}

class _FreightBreakdownDialog extends StatelessWidget {
  const _FreightBreakdownDialog({required this.client});

  final Client client;

  @override
  Widget build(BuildContext context) {
    final state = context.watch<ShippingCalculatorBloc>().state;
    final result = state.calcResult;
    if (result == null) return const SizedBox.shrink();

    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: _dialogMaxWidth(context)),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 8, right: 4),
            child: Align(
              alignment: Alignment.centerRight,
              child: _CloseButton(onTap: () => Navigator.of(context).pop()),
            ),
          ),
          _PulsingDialogBorder(
            builder: (context, border, shadows) => ShadDialog(
              radius: BorderRadius.circular(16),
              backgroundColor: context.colors.surface,
              border: border,
              shadows: shadows,
              padding: EdgeInsets.zero,
              closeIcon: const SizedBox.shrink(),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _DialogHeader(state: state),
                    Flexible(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
                        child: result.error != null
                            ? _ErrorBody(
                                message: result.error!,
                                origin: state.origin,
                                destination: state.destination,
                                tiers: result.routeTiers,
                                onEditRate: state.selectedRate == null
                                    ? null
                                    : () {
                                        final rateId = state.selectedRate!.id;
                                        Navigator.of(context).pop();
                                        context.read<RatesShellBloc>().add(
                                          EditRateRequested(rateId),
                                        );
                                      },
                              )
                            : const _ResultBody(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (result.error == null) ...[
            const SizedBox(height: 12),
            GeneratePdfButton(state: state, client: client),
          ],
        ],
      ),
    );
  }
}

/// `Printing.layoutPdf` renders the whole document client-side before its
/// print/save dialog appears — on web especially, that can take a few
/// seconds with zero visual feedback otherwise, reading as a hang. Track a
/// local loading flag so the button shows a spinner and disables itself for
/// the duration instead of looking unresponsive.
class GeneratePdfButton extends StatefulWidget {
  const GeneratePdfButton({
    super.key,
    required this.state,
    required this.client,
  });

  final ShippingCalculatorState state;
  final Client client;

  @override
  State<GeneratePdfButton> createState() => _GeneratePdfButtonState();
}

class _GeneratePdfButtonState extends State<GeneratePdfButton> {
  bool _generating = false;

  Future<void> _handleTap() async {
    setState(() => _generating = true);
    try {
      await generateInvoicePdf(state: widget.state, client: widget.client);
    } finally {
      if (mounted) setState(() => _generating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ShadButton(
        gradient: context.colors.primaryButtonGradient,
        leading: _generating
            ? const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : const Icon(CupertinoIcons.arrow_down_doc, size: 16),
        onPressed: _generating ? null : _handleTap,
        child: Text(_generating ? 'Generating...' : 'Generate Invoice PDF'),
      ),
    );
  }
}

class _DialogHeader extends StatelessWidget {
  const _DialogHeader({required this.state});

  final ShippingCalculatorState state;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 18, 24, 18),
      decoration: BoxDecoration(gradient: context.colors.primaryButtonGradient),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Text(
                    '${state.rateType.label.toUpperCase()} RATE',
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      letterSpacing: 0.4,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      CupertinoIcons.arrow_down_circle_fill,
                      size: 16,
                      color: Colors.white,
                    ),
                    const SizedBox(width: 8),
                    const Flexible(
                      child: Text(
                        'Freight Breakdown',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (state.calcResult != null && state.calcResult!.error == null)
            Material(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
              child: InkWell(
                borderRadius: BorderRadius.circular(8),
                onTap: () => _showCalculationBreakdown(context, state),
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(CupertinoIcons.number, size: 13, color: Colors.white),
                      SizedBox(width: 6),
                      Text(
                        'How is this calculated?',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Plain-English description of the formula behind [PricingOption] — shown
/// in the Calculation Breakdown popup so the numbers below it aren't just
/// asserted, they're explained.
String _formulaFor(PricingOption option) => switch (option) {
      PricingOption.fixedBreakweight => 'Chargeable weight × the matched bracket\'s rate.',
      PricingOption.minimumFixedBreakweight =>
        'A flat fee within the first bracket, regardless of actual weight; weight × rate for any bracket beyond it.',
      PricingOption.flatBreakweight => 'A flat fee for whichever bracket the weight falls into — never multiplied by weight.',
      PricingOption.cummulativeBreakweight =>
        'Each bracket the weight passes through is charged separately at that bracket\'s rate, then summed.',
      PricingOption.minimumCummulativeBreakweight =>
        'A flat entrance fee for the first bracket, then each further bracket charged per kg and summed.',
      PricingOption.excessBreakweight =>
        'The base bracket priced per kg, plus everything beyond it priced at the excess bracket\'s rate.',
      PricingOption.minimumExcessBreakweight =>
        'A flat base-bracket fee, plus everything beyond it priced at the excess bracket\'s rate.',
      PricingOption.routeBased || PricingOption.timeBased =>
        'Not yet computed by this calculator.',
    };

void _showCalculationBreakdown(BuildContext context, ShippingCalculatorState state) {
  showShadDialog<void>(
    context: context,
    builder: (dialogContext) => _CalculationBreakdownDialog(state: state),
  );
}

/// "Show your work" popup — every figure in the freight breakdown, traced
/// back to the formula and the exact rate/route data it came from, instead
/// of just asserting the final numbers.
class _CalculationBreakdownDialog extends StatelessWidget {
  const _CalculationBreakdownDialog({required this.state});

  final ShippingCalculatorState state;

  @override
  Widget build(BuildContext context) {
    final result = state.calcResult!;
    num displayValue(num v) => state.roundedDisplay ? v.roundToDouble() : v;
    String money(num v) => '₱${displayValue(v).toStringAsFixed(2)}';

    final addons = state.selectedRate?.addons;
    final addonLines = <String>[];
    if (result.fuelSurcharge != null && result.fuelSurcharge != 0) {
      addonLines.add(
        addons?.fuelSurchargeType == 'percentage'
            ? 'Fuel surcharge: ${addons?.fuelSurcharge} % of base freight = ${money(result.fuelSurcharge!)}'
            : 'Fuel surcharge: ${money(result.fuelSurcharge!)} (flat, from rate config)',
      );
    }
    for (final entry in result.flatFees.entries) {
      if (entry.key == 'Valuation' && addons?.valuationType == 'percentage') {
        addonLines.add('${entry.key}: ${addons?.valuation} % of declared value = ${money(entry.value)}');
      } else {
        addonLines.add('${entry.key}: ${money(entry.value)} (flat, from rate config)');
      }
    }

    final grandTotalText = state.vatInclusive
        ? 'Sub-total (VAT already included) = ${money(displayValue(state.grandTotal))}'
        : 'Sub-total + VAT = ${money(displayValue(state.grandTotal))}';

    return ShadDialog(
      radius: BorderRadius.circular(20),
      backgroundColor: context.colors.surface,
      padding: EdgeInsets.zero,
      closeIcon: const SizedBox.shrink(),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 560, maxHeight: 680),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      gradient: context.colors.primaryButtonGradient,
                      borderRadius: BorderRadius.circular(11),
                    ),
                    child: const Icon(CupertinoIcons.number, size: 18, color: Colors.white),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Calculation Breakdown',
                          style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: context.colors.textBody),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Every figure, traced back to its source',
                          style: TextStyle(fontSize: 12, color: context.colors.textMuted),
                        ),
                      ],
                    ),
                  ),
                  Material(
                    color: context.colors.surfaceMuted,
                    shape: const CircleBorder(),
                    child: InkWell(
                      customBorder: const CircleBorder(),
                      onTap: () => Navigator.of(context).pop(),
                      child: Padding(
                        padding: const EdgeInsets.all(8),
                        child: Icon(CupertinoIcons.xmark, size: 15, color: context.colors.textMuted),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Flexible(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _BreakdownSection(
                        icon: CupertinoIcons.tag_fill,
                        title: 'Rate used',
                        lines: [
                          if (state.selectedChargeCode != null) 'Charge code: ${state.selectedChargeCode}',
                          if (state.pricingOption != null) ...[
                            'Pricing option: ${state.pricingOption!.label}',
                            'Formula: ${_formulaFor(state.pricingOption!)}',
                          ],
                          if (result.matchedTierMin != null && result.matchedTierMax != null)
                            'Matched bracket: ${result.matchedTierMin!.toStringAsFixed(0)}–${result.matchedTierMax!.toStringAsFixed(0)} kg'
                                '${result.tierRate != null ? ' @ ${money(result.tierRate!)}/kg' : ''}',
                        ],
                      ),
                      _BreakdownSection(
                        icon: CupertinoIcons.cube_box_fill,
                        title: 'Base freight',
                        lines: [
                          if (result.chargeableWeight != null) 'Chargeable weight: ${result.chargeableWeight!.toStringAsFixed(2)} kg',
                          if (result.tierRate != null && result.chargeableWeight != null)
                            '${result.chargeableWeight!.toStringAsFixed(2)} kg × ${money(result.tierRate!)}/kg = ${money(result.baseFreight ?? 0)}'
                          else
                            'Base freight = ${money(result.baseFreight ?? 0)}',
                        ],
                      ),
                      if (addonLines.isNotEmpty)
                        _BreakdownSection(icon: CupertinoIcons.plus_circle_fill, title: 'Add-ons', lines: addonLines),
                      _BreakdownSection(
                        icon: CupertinoIcons.equal_square_fill,
                        title: 'Sub-total',
                        lines: ['Base freight + add-ons = ${money(result.subTotal ?? 0)}'],
                      ),
                      _BreakdownSection(
                        icon: CupertinoIcons.percent,
                        title: 'VAT',
                        lines: switch (state.vatMode) {
                          VatMode.exempt => const ['VAT-Exempt Sale — no VAT applied.'],
                          VatMode.zeroRated => const ['Zero-Rated Sale — no VAT applied.'],
                          VatMode.standard => [
                              state.vatInclusive
                                  ? 'VAT already included in the sub-total — backed out as sub-total ÷ 1.12 × 0.12 = ${money(state.vatAmount)}'
                                  : '12% of the VATable sub-total = ${money(state.vatAmount)}',
                            ],
                        },
                      ),
                      const SizedBox(height: 4),
                      _GrandTotalCard(text: grandTotalText),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Renders `label = value`/`label: value` lines with the tail after the
/// last `=`/`:` bolded — the answer stands out, the working stays quiet.
Widget _emphasizedLine(BuildContext context, String text) {
  final baseStyle = TextStyle(fontSize: 13, color: context.colors.textMutedStrong, height: 1.5);
  final eqIndex = text.lastIndexOf(' = ');
  final colonIndex = text.indexOf(': ');
  final (cut, markerLength) = eqIndex != -1 ? (eqIndex, 3) : (colonIndex, 2);
  if (cut == -1) return Text(text, style: baseStyle);

  return RichText(
    text: TextSpan(
      style: baseStyle,
      children: [
        TextSpan(text: text.substring(0, cut + markerLength)),
        TextSpan(
          text: text.substring(cut + markerLength),
          style: TextStyle(fontWeight: FontWeight.w700, color: context.colors.textBody),
        ),
      ],
    ),
  );
}

class _BreakdownSection extends StatelessWidget {
  const _BreakdownSection({required this.icon, required this.title, required this.lines});

  final IconData icon;
  final String title;
  final List<String> lines;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: context.colors.surfaceSubtle,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 13, color: context.colors.primaryDeep),
              const SizedBox(width: 6),
              Text(
                title.toUpperCase(),
                style: TextStyle(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.4,
                  color: context.colors.primaryDeep,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          for (final line in lines)
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: _emphasizedLine(context, line),
            ),
        ],
      ),
    );
  }
}

/// The final answer, called out from the rest of the (quieter) working —
/// same gradient treatment as the popup's own header badge.
class _GrandTotalCard extends StatelessWidget {
  const _GrandTotalCard({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final splitAt = text.lastIndexOf(' = ');
    final prefix = splitAt == -1 ? text : text.substring(0, splitAt + 3);
    final suffix = splitAt == -1 ? '' : text.substring(splitAt + 3);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        gradient: context.colors.primaryButtonGradient,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              'GRAND TOTAL',
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.5,
                color: Colors.white,
              ).copyWith(color: Colors.white.withValues(alpha: 0.85)),
            ),
          ),
          if (suffix.isNotEmpty)
            Text(
              suffix,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Colors.white),
            )
          else
            Flexible(
              child: Text(
                prefix,
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Colors.white),
                textAlign: TextAlign.right,
              ),
            ),
        ],
      ),
    );
  }
}

class _CloseButton extends StatelessWidget {
  const _CloseButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Container(
          width: 24,
          height: 24,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.2),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            CupertinoIcons.xmark,
            size: 12,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}

class _ErrorBody extends StatelessWidget {
  const _ErrorBody({
    required this.message,
    this.origin = '',
    this.destination = '',
    this.tiers = const [],
    this.onEditRate,
  });

  final String message;
  final String origin;
  final String destination;

  /// The resolved route's breakweight brackets, if any — shown as a mini
  /// table so a "no tier covers this weight" error is self-explanatory
  /// without leaving the dialog to go check the rate.
  final List<RatrixBreakweight> tiers;

  /// Jumps straight to editing the selected rate in the wizard — shown for
  /// any calc error, since every one of them boils down to something
  /// missing/misconfigured on that specific rate.
  final VoidCallback? onEditRate;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: context.colors.destructive.withValues(alpha: 0.08),
            border: Border.all(
              color: context.colors.destructive.withValues(alpha: 0.3),
            ),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    CupertinoIcons.exclamationmark_triangle,
                    size: 16,
                    color: context.colors.destructive,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      message,
                      style: TextStyle(
                        fontSize: 13,
                        color: context.colors.destructive,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        if (tiers.isNotEmpty || onEditRate != null) ...[
          const SizedBox(height: 12),
          RouteTiersTable(
            origin: origin,
            destination: destination,
            tiers: tiers,
            onEdit: onEditRate,
          ),
        ],
      ],
    );
  }
}

/// Compact origin/destination + breakweight-bracket table, shown alongside
/// a calc error so the user can see what's actually configured on the route
/// without leaving the dialog.
class RouteTiersTable extends StatelessWidget {
  const RouteTiersTable({
    super.key,
    required this.origin,
    required this.destination,
    required this.tiers,
    this.onEdit,
  });

  final String origin;
  final String destination;
  final List<RatrixBreakweight> tiers;

  /// Jumps to editing the rate this route belongs to — shown as a small
  /// pencil icon next to the origin/destination line when set.
  final VoidCallback? onEdit;

  @override
  Widget build(BuildContext context) {
    TextStyle headerLabelStyle(BuildContext context) => TextStyle(
      fontSize: 9,
      fontWeight: FontWeight.w700,
      letterSpacing: 0.2,
      color: context.colors.textMutedStrong,
    );
    TextStyle headerRangeStyle(BuildContext context) => TextStyle(
      fontSize: 10,
      fontWeight: FontWeight.w600,
      color: context.colors.textBody,
    );
    TextStyle cellStyle(BuildContext context) => TextStyle(
      fontSize: 11,
      fontWeight: FontWeight.w500,
      color: context.colors.textBody,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (onEdit != null)
          Align(
            alignment: Alignment.centerRight,
            child: Material(
              color: context.colors.primary,
              borderRadius: BorderRadius.circular(8),
              child: InkWell(
                borderRadius: BorderRadius.circular(8),
                onTap: onEdit,
                child: const Padding(
                  padding: EdgeInsets.all(7),
                  child: Icon(
                    CupertinoIcons.pencil,
                    size: 16,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        if (tiers.isEmpty)
          Text(
            'No breakweight tiers found for this route.',
            style: cellStyle(context).copyWith(color: context.colors.textMuted),
          )
        else
          Container(
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              border: Border.all(color: context.colors.border),
              borderRadius: BorderRadius.circular(10),
            ),
            child: IntrinsicHeight(
              child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Origin/Destination pinned as the leftmost column, mirroring
                // the rate wizard's matrix table layout.
                Expanded(
                  flex: 3,
                  child: Column(
                    children: [
                      Container(
                        height: 48,
                        alignment: Alignment.centerLeft,
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        color: context.colors.surfaceSubtle,
                        child: Text('ROUTE', style: headerLabelStyle(context)),
                      ),
                      Expanded(
                        child: Container(
                          width: double.infinity,
                          alignment: Alignment.centerLeft,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            border: Border(
                              top: BorderSide(color: context.colors.border),
                            ),
                          ),
                          child: Text(
                            '${origin.isEmpty ? '—' : origin} → ${destination.isEmpty ? '—' : destination}',
                            style: cellStyle(
                              context,
                            ).copyWith(fontWeight: FontWeight.w700),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                for (var i = 0; i < tiers.length; i++)
                  Expanded(
                    flex: 2,
                    child: Column(
                      children: [
                        Container(
                          height: 48,
                          alignment: Alignment.center,
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            color: context.colors.surfaceSubtle,
                            border: Border(
                              left: BorderSide(color: context.colors.border),
                            ),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                i == 0 ? 'MINIMUM' : 'TIER ${i + 1}',
                                style: i == 0
                                    ? headerLabelStyle(context).copyWith(
                                        color: context.colors.primaryDeep,
                                      )
                                    : headerLabelStyle(context),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${tiers[i].min.toStringAsFixed(0)}–${tiers[i].max.toStringAsFixed(0)}',
                                style: headerRangeStyle(context),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Container(
                            width: double.infinity,
                            alignment: Alignment.center,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 14,
                            ),
                            decoration: BoxDecoration(
                              border: Border(
                                top: BorderSide(color: context.colors.border),
                                left: BorderSide(color: context.colors.border),
                              ),
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: context.colors.primaryChipBg,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    'REG ₱${tiers[i].rate.toStringAsFixed(2)}',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                      color: context.colors.primaryDeep,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                if (tiers[i].expressRate != null) ...[
                                  const SizedBox(height: 6),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: context.colors.accentChipBg,
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      'EXP ₱${tiers[i].expressRate!.toStringAsFixed(2)}',
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w700,
                                        color: context.colors.accent,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _ResultBody extends StatelessWidget {
  const _ResultBody();

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<ShippingCalculatorBloc>();
    final state = context.watch<ShippingCalculatorBloc>().state;
    final result = state.calcResult!;

    num displayValue(num v) => state.roundedDisplay ? v.roundToDouble() : v;
    String money(num? v) =>
        v == null ? '—' : displayValue(v).toStringAsFixed(2);

    final grandTotal = displayValue(state.grandTotal);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: _WeightStat(
                label: 'WT',
                value: result.chargeableWeight == null
                    ? '—'
                    : '${displayValue(result.chargeableWeight!).toStringAsFixed(state.roundedDisplay ? 0 : 1)}KG',
              ),
            ),
            Expanded(
              child: _WeightStat(
                label: 'VOL',
                value: result.volumetricWeight == null
                    ? '—'
                    : '${displayValue(result.volumetricWeight!).toStringAsFixed(state.roundedDisplay ? 0 : 1)}KG',
              ),
            ),
            Expanded(
              child: _WeightStat(
                label: 'CBM',
                value: result.cbm?.toStringAsFixed(4) ?? '—',
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Center(
          child: Text(
            'FINAL CHARGEABLE BASIS',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.6,
              color: context.colors.textMuted,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Center(
          child: RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: result.chargeableWeight?.toStringAsFixed(0) ?? '—',
                  style: TextStyle(
                    fontSize: 34,
                    fontWeight: FontWeight.w800,
                    color: context.colors.textBody,
                    height: 1,
                  ),
                ),
                TextSpan(
                  text: ' kg',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: context.colors.textMuted,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),
        const Divider(height: 1),
        const SizedBox(height: 20),
        Center(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: context.colors.successBg,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              'GRAND TOTAL PAYABLE',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.4,
                color: context.colors.successText,
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
        Center(
          child: RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: '₱',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: context.colors.primaryDeep,
                  ),
                ),
                TextSpan(
                  text: grandTotal.toStringAsFixed(2),
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.w800,
                    color: context.colors.primaryDeep,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        Center(
          child: _SegmentedToggle(
            leftLabel: 'Exact',
            rightLabel: 'Rounded',
            selectedLeft: !state.roundedDisplay,
            onSelect: (left) => bloc.add(CalcRoundedDisplayToggled(!left)),
          ),
        ),
        const SizedBox(height: 24),
        Row(
          children: [
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                color: context.colors.primary,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              'CHARGE DETAILS',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.4,
                color: context.colors.textMutedStrong,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _ChargeRow(
          label: 'Base Freight',
          value: money(result.baseFreight),
          bold: true,
        ),
        if (result.fuelSurcharge != null)
          _ChargeRow(
            label: 'Fuel Surcharge',
            value: money(result.fuelSurcharge),
          ),
        for (final entry in result.flatFees.entries)
          _ChargeRow(label: entry.key, value: money(entry.value)),
        const SizedBox(height: 12),
        const Divider(height: 1),
        const SizedBox(height: 12),
        _ChargeRow(
          label: 'Sub-Total',
          value: '₱${money(result.subTotal)}',
          bold: true,
        ),
        if (state.vatMode == VatMode.standard)
          _ChargeRow(
            label:
                'VAT (${(ShippingCalculatorState.vatRate * 100).toStringAsFixed(0)}%)',
            value: '₱${money(state.vatAmount)}',
            valueColor: context.colors.primaryDeep,
            labelColor: context.colors.primaryDeep,
          )
        else if (state.vatMode.saleLabel != null)
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Text(
              state.vatMode.saleLabel!,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                fontStyle: FontStyle.italic,
                color: context.colors.primaryDeep,
              ),
            ),
          ),
        const SizedBox(height: 16),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              ShadCheckbox(
                value: state.vatMode == VatMode.exempt,
                label: Text(
                  'VAT Exempt',
                  style: TextStyle(
                    fontSize: 11,
                    color: context.colors.textMutedStrong,
                  ),
                ),
                // Exempt/Zero Rated share one underlying VatMode — checking
                // either clears the other, same mutual-exclusivity as before.
                onChanged: (value) => bloc.add(
                  CalcVatModeChanged(value ? VatMode.exempt : VatMode.standard),
                ),
              ),
              const SizedBox(width: 20),
              ShadCheckbox(
                value: state.vatMode == VatMode.zeroRated,
                label: Text(
                  'VAT Zero Rated',
                  style: TextStyle(
                    fontSize: 11,
                    color: context.colors.textMutedStrong,
                  ),
                ),
                onChanged: (value) => bloc.add(
                  CalcVatModeChanged(
                    value ? VatMode.zeroRated : VatMode.standard,
                  ),
                ),
              ),
              const SizedBox(width: 20),
              ShadCheckbox(
                value: state.vatInclusive,
                label: Text(
                  'VAT Inclusive?',
                  style: TextStyle(
                    fontSize: 11,
                    color: context.colors.textMutedStrong,
                  ),
                ),
                onChanged: (value) => bloc.add(CalcVatInclusiveToggled(value)),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _WeightStat extends StatelessWidget {
  const _WeightStat({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          '$label: $value',
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: context.colors.textMutedStrong,
          ),
        ),
      ],
    );
  }
}

class _SegmentedToggle extends StatelessWidget {
  const _SegmentedToggle({
    required this.leftLabel,
    required this.rightLabel,
    required this.selectedLeft,
    required this.onSelect,
  });

  final String leftLabel;
  final String rightLabel;
  final bool selectedLeft;
  final ValueChanged<bool> onSelect;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: context.colors.surfaceMuted,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _SegmentButton(
            label: leftLabel,
            selected: selectedLeft,
            onTap: () => onSelect(true),
          ),
          _SegmentButton(
            label: rightLabel,
            selected: !selectedLeft,
            onTap: () => onSelect(false),
          ),
        ],
      ),
    );
  }
}

class _SegmentButton extends StatelessWidget {
  const _SegmentButton({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(6),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            color: selected ? context.colors.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: selected ? Colors.white : context.colors.textMutedStrong,
            ),
          ),
        ),
      ),
    );
  }
}

class _ChargeRow extends StatelessWidget {
  const _ChargeRow({
    required this.label,
    required this.value,
    this.bold = false,
    this.labelColor,
    this.valueColor,
  });

  final String label;
  final String value;
  final bool bold;
  final Color? labelColor;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: bold ? FontWeight.w700 : FontWeight.w500,
              color:
                  labelColor ??
                  (bold ? context.colors.textBody : context.colors.textMuted),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: bold ? FontWeight.w700 : FontWeight.w600,
              color:
                  valueColor ??
                  (bold
                      ? context.colors.textBody
                      : context.colors.textMutedStrong),
            ),
          ),
        ],
      ),
    );
  }
}
