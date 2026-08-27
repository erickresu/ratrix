import 'dart:async';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../rates_colors.dart';

/// A centered, blurred-backdrop status notification — replaces the plain
/// corner toast for rate create/edit/delete success and error. Auto-closes
/// after [autoCloseAfter] (skipped for errors, which need to be read and
/// dismissed deliberately) and always has a dismiss (X) button.
Future<void> showStatusDialog(
  BuildContext context, {
  required String title,
  String? description,
  bool isError = false,
  Duration autoCloseAfter = const Duration(seconds: 2),
}) async {
  Timer? autoCloseTimer;
  await showShadDialog<void>(
    context: context,
    barrierColor: Colors.transparent,
    builder: (dialogContext) {
      if (!isError) {
        autoCloseTimer = Timer(autoCloseAfter, () {
          if (Navigator.of(dialogContext).canPop()) {
            Navigator.of(dialogContext).pop();
          }
        });
      }
      return _BlurredStatusBarrier(
        child: _StatusDialogCard(
          title: title,
          description: description,
          isError: isError,
        ),
      );
    },
  );
  autoCloseTimer?.cancel();
}

class _BlurredStatusBarrier extends StatelessWidget {
  const _BlurredStatusBarrier({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
            child: Container(color: Colors.black.withValues(alpha: 0.5)),
          ),
        ),
        Center(child: child),
      ],
    );
  }
}

class _StatusDialogCard extends StatelessWidget {
  const _StatusDialogCard({
    required this.title,
    required this.description,
    required this.isError,
  });

  final String title;
  final String? description;
  final bool isError;

  @override
  Widget build(BuildContext context) {
    final accent = isError ? context.colors.destructive : context.colors.primary;
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 440),
      child: ShadDialog(
        radius: BorderRadius.circular(24),
        backgroundColor: context.colors.surface,
        border: Border.all(color: accent.withValues(alpha: 0.35), width: 1.5),
        shadows: [
          BoxShadow(
            color: accent.withValues(alpha: 0.2),
            blurRadius: 40,
            spreadRadius: 2,
          ),
        ],
        closeIcon: const SizedBox.shrink(),
        padding: const EdgeInsets.fromLTRB(32, 28, 32, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 56,
                  height: 56,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [accent.withValues(alpha: 0.18), accent.withValues(alpha: 0.06)],
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isError ? CupertinoIcons.exclamationmark_circle_fill : CupertinoIcons.checkmark_circle_fill,
                    color: accent,
                    size: 30,
                  ),
                ),
                const Spacer(),
                _DismissButton(onTap: () => Navigator.of(context).pop()),
              ],
            ),
            const SizedBox(height: 20),
            Text(
              title,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, letterSpacing: -0.3, color: context.colors.textBody),
            ),
            if (description != null) ...[
              const SizedBox(height: 8),
              Text(
                description!,
                style: TextStyle(fontSize: 14, color: context.colors.textMuted, height: 1.5),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _DismissButton extends StatelessWidget {
  const _DismissButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Container(
          width: 32,
          height: 32,
          alignment: Alignment.center,
          decoration: BoxDecoration(color: context.colors.surfaceMuted, shape: BoxShape.circle),
          child: Icon(CupertinoIcons.xmark, size: 15, color: context.colors.textMuted),
        ),
      ),
    );
  }
}
