import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:showcaseview/showcaseview.dart';

import '../../../../../core/utils/web_chat_widget.dart';
import '../../../../../core/widgets/mr_ratrix.dart';
import '../../../domain/entities/rates_enums.dart';
import '../../bloc/rate_wizard_bloc.dart';
import '../../bloc/rates_shell_bloc.dart';
import 'tour_keys.dart';
import 'tour_speech.dart';

final _kWizardKeys = [
  TourKeys.wizardStep0,
  TourKeys.wizardStep1,
  TourKeys.wizardStep2,
  TourKeys.wizardStep3,
];

/// One continuous, real-screen walkthrough: every dashboard nav item, in
/// order, ending with the Create Rate button → auto-navigates into the
/// actual wizard → narrates all 4 real steps, auto-advancing them → tour
/// ends there. Built on `showcaseview` spotlighting the real widgets (via
/// [TourKeys]) with each step's copy living beside the real widget it
/// describes (see `rates_sidebar.dart`, `dashboard_view.dart`, and
/// `wizard_page.dart`'s `tourShowcase` wraps) — not a mock scene, so
/// what's shown is exactly what the user will use afterward.
///
/// Only one tour runs at a time, tracked via [active] so the wizard's
/// `_StepContent` can find it (see [registerWizardBloc]) without the
/// wizard's own `BlocProvider` being an ancestor of [shellContext] — it
/// isn't; the wizard only exists as a sibling subtree while
/// `RatesView.create` is showing. Driven entirely through
/// `RatesShellPage`'s single `ShowCaseWidget.onComplete`/`onFinish`
/// (see [handleStepComplete] / [handleSequenceFinished]) — this class only
/// decides what happens at each step boundary.
class AppTour {
  AppTour({required this.shellContext, required this.onFinish});

  final BuildContext shellContext;
  final VoidCallback onFinish;

  static AppTour? active;

  RateWizardBloc? _wizardBloc;
  void registerWizardBloc(RateWizardBloc bloc) => _wizardBloc = bloc;

  bool _finished = false;
  bool _inWizard = false;

  void show(BuildContext context) {
    active = this;
    // The wyred.tech chat bubble floats fixed on top of everything,
    // including tour steps sitting right next to it — hide it for the
    // duration of the tour, restored in `_finish`.
    setWebChatVisible(false);
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => _IntroScene(
        onSkip: () {
          Navigator.of(dialogContext).pop();
          _finish();
        },
        onNext: () {
          Navigator.of(dialogContext).pop();
          _inWizard = false;
          ShowCaseWidget.of(shellContext).startShowCase(TourKeys.dashboardSteps);
        },
      ),
    );
  }

  /// Called from `RatesShellPage`'s `ShowCaseWidget.onComplete` — the one
  /// place that sees every step across every screen finish, in order.
  void handleStepComplete(GlobalKey key) {
    if (key == TourKeys.createRateButton) {
      shellContext.read<RatesShellBloc>().add(const PublishedRateChosen());
      _inWizard = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (shellContext.mounted) {
          ShowCaseWidget.of(shellContext).startShowCase([TourKeys.wizardStep0]);
        }
      });
      return;
    }

    if (!_inWizard) return;
    final wizardIndex = _kWizardKeys.indexOf(key);
    if (wizardIndex == -1) return;

    if (wizardIndex < _kWizardKeys.length - 1) {
      _advanceWizardTo(wizardIndex + 1);
    } else {
      _exitWizardToDashboard();
    }
  }

  void _advanceWizardTo(int step) {
    _wizardBloc?.add(TourStepChanged(step));
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (shellContext.mounted) {
        ShowCaseWidget.of(shellContext).startShowCase([_kWizardKeys[step]]);
      }
    });
  }

  void _exitWizardToDashboard() {
    _inWizard = false;
    _wizardBloc = null;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!shellContext.mounted) return;
      shellContext.read<RatesShellBloc>().add(
        WizardExitRequested(fallback: RatesView.dashboard),
      );
      _finish();
    });
  }

  /// Called from `ShowCaseWidget.onFinish` — fires once the dashboard
  /// sequence runs off its last step, i.e. `createRateButton`. That's not
  /// the real end of the tour though — it's the create-rate hand-off into
  /// the wizard, handled by [handleStepComplete] instead, so this is a
  /// no-op while the wizard portion is what actually ends the tour (see
  /// [_exitWizardToDashboard]).
  void handleSequenceFinished() {}

  /// Called from a step's "Skip tour" button — `ShowCaseWidget.dismiss()`
  /// (which that button also calls) tears down the overlay but does NOT
  /// invoke `onFinish`, so without this, skipping mid-tour would leave
  /// [active] set and the chat bubble hidden forever.
  void skip() => _finish();

  void _finish() {
    if (_finished) return;
    _finished = true;
    stopTourSpeech();
    setWebChatVisible(true);
    if (active == this) active = null;
    onFinish();
  }
}

class _IntroScene extends StatefulWidget {
  const _IntroScene({required this.onSkip, required this.onNext});

  final VoidCallback onSkip;
  final VoidCallback onNext;

  @override
  State<_IntroScene> createState() => _IntroSceneState();
}

class _IntroSceneState extends State<_IntroScene> {
  static const _title = 'Welcome to Ratrix!';
  static const _body =
      "Hi, I'm your friendly neighborhood rates robot! I'm here to help "
      "you find your way around — and by the end of this, we'll have "
      'walked through building one rate together, start to finish.';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      speakTourLine('$_title $_body');
      // Re-assert past the same `_AuthGate` race `handleStepComplete`
      // guards against (see its comment) — this dialog is the very first
      // frame of the tour, before any step has completed.
      setWebChatVisible(false);
    });
  }

  @override
  void dispose() {
    stopTourSpeech();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(24),
      child: Builder(
        builder: (context) {
          final screenWidth = MediaQuery.sizeOf(context).width;
          final isMobile = screenWidth < 600;
          return TourSpeechBubble(
            width: isMobile ? screenWidth - 48 : 560,
            mascot: MrRatrix(size: isMobile ? 80 : 150),
            scale: isMobile ? 1.0 : 1.25,
            title: _title,
            body: _body,
            onSpeak: () => speakTourLine('$_title $_body'),
            leftLabel: 'Skip tour',
            onLeft: widget.onSkip,
            rightLabel: "Let's go",
            onRight: widget.onNext,
          );
        },
      ),
    );
  }
}
