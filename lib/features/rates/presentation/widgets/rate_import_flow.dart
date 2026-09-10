import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../../../core/di/injection_container.dart';
import '../../../../core/utils/browser_download.dart';
import '../../data/repositories/rates_repository.dart';
import '../../domain/entities/rate_excel_import.dart';
import '../../domain/entities/rate_excel_template.dart';
import '../bloc/rates_shell_bloc.dart';
import '../rates_colors.dart';
import 'status_toast.dart';

/// Downloads the fill-in-offline rate import template. Shared by the New
/// Rate modal and anywhere else a "Download template" action lives, so
/// there's one place that knows how to build it. Asks how many weight
/// brackets to build via [_BracketCountDialog] first — a spreadsheet has no
/// way to add more bracket columns itself once downloaded (that would need
/// VBA macros: a security-warning trigger, commonly blocked by IT policy,
/// and Excel-only — doesn't work in Google Sheets/LibreOffice), so the
/// choice has to happen here, before the file exists. A no-op if the user
/// cancels the dialog.
Future<void> downloadRateImportTemplate(BuildContext context) async {
  final bracketCount = await showShadDialog<int>(
    context: context,
    builder: (_) => const _BracketCountDialog(),
  );
  if (bracketCount == null) return; // user cancelled
  if (!context.mounted) return;

  try {
    final cities = await getIt<RatesRepository>().searchLocations(
      q: '',
      type: 'city',
    );
    final bytes = buildRateImportTemplate(
      allCities: cities,
      bracketCount: bracketCount,
    );
    downloadBytesAsFile(bytes, 'ratrix-rate-import-template.xlsx');
  } catch (e) {
    if (context.mounted) {
      showStatusToast(
        context,
        title: "Couldn't build the template",
        description: e.toString(),
        isError: true,
      );
    }
  }
}

/// "How many weight brackets?" prompt with a real +/- stepper — shown
/// before every template download. Defaults to
/// [RateExcelTemplateLayout.defaultBracketCount] so someone who doesn't
/// know the exact count yet can just hit Download without deciding
/// anything; the stepper is there for whoever does know they need more or
/// fewer. Applies to both Regular and Express — the wizard's own data
/// model shares one set of bracket boundaries between the two service
/// levels, so there's no sense letting them diverge here either.
class _BracketCountDialog extends StatefulWidget {
  const _BracketCountDialog();

  @override
  State<_BracketCountDialog> createState() => _BracketCountDialogState();
}

class _BracketCountDialogState extends State<_BracketCountDialog> {
  var _count = RateExcelTemplateLayout.defaultBracketCount;

  static const _min = 1;
  static const _max = 30;

  void _adjust(int delta) {
    setState(() => _count = (_count + delta).clamp(_min, _max));
  }

  @override
  Widget build(BuildContext context) {
    return ShadDialog(
      radius: BorderRadius.circular(16),
      backgroundColor: context.colors.surface,
      title: Text(
        'How many weight brackets?',
        style: TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.w700,
          color: context.colors.textBody,
        ),
      ),
      description: Padding(
        padding: const EdgeInsets.only(top: 4),
        child: Text(
          "Not sure yet? $_count is a good default — you can always come "
          'back and download a fresh template with more.',
          style: TextStyle(fontSize: 13, color: context.colors.textMuted),
        ),
      ),
      actions: [
        ShadButton.outline(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ShadButton(
          backgroundColor: context.colors.primary,
          onPressed: () => Navigator.of(context).pop(_count),
          child: const Text('Download'),
        ),
      ],
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _StepperButton(
              icon: CupertinoIcons.minus,
              onTap: _count > _min ? () => _adjust(-1) : null,
            ),
            SizedBox(
              width: 64,
              child: Text(
                '$_count',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: context.colors.textBody,
                ),
              ),
            ),
            _StepperButton(
              icon: CupertinoIcons.plus,
              onTap: _count < _max ? () => _adjust(1) : null,
            ),
          ],
        ),
      ),
    );
  }
}

class _StepperButton extends StatelessWidget {
  const _StepperButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;
    return Material(
      color: enabled ? context.colors.primaryChipBg : context.colors.surfaceMuted,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Icon(
            icon,
            size: 18,
            color: enabled ? context.colors.primaryDeep : context.colors.textFaint,
          ),
        ),
      ),
    );
  }
}

/// Opens the file picker, parses whatever `.xlsx` comes back, and — on
/// success — dispatches `RateImportRequested` to land the wizard pre-filled
/// for review. Shared by the New Rate modal's "Import from Excel" card, the
/// sidebar's "Import" shortcut, and the Published/Custom Client Rates
/// pages' own "Create New Rate" menus, so picking/parsing/error-toasting
/// only lives in one place. A no-op if the user cancels the picker.
///
/// [isCustom] should be `true` only when triggered from inside a specific
/// client's page (Custom Client Rates) — see `RateImportRequested`.
Future<void> runRateImportFlow(BuildContext context, {bool isCustom = false}) async {
  final result = await FilePicker.platform.pickFiles(
    type: FileType.custom,
    allowedExtensions: const ['xlsx'],
    withData: true,
  );
  final bytes = result?.files.single.bytes;
  if (bytes == null) return; // user cancelled the picker
  if (!context.mounted) return;

  final bloc = context.read<RatesShellBloc>();
  try {
    final cities = await getIt<RatesRepository>().searchLocations(
      q: '',
      type: 'city',
    );
    final data = parseRateImportWorkbook(bytes, allCities: cities);
    if (!context.mounted) return;

    if (data.skippedRows.isNotEmpty) {
      showStatusToast(
        context,
        title: '${data.skippedRows.length} row${data.skippedRows.length == 1 ? '' : 's'} skipped',
        description: data.skippedRows.first,
        isError: true,
      );
    }
    bloc.add(RateImportRequested(data, isCustom: isCustom));
  } on RateImportFormatException catch (e) {
    if (context.mounted) {
      showStatusToast(
        context,
        title: "Couldn't read that file",
        description: e.message,
        isError: true,
      );
    }
  } catch (e) {
    if (context.mounted) {
      showStatusToast(
        context,
        title: "Couldn't read that file",
        description: e.toString(),
        isError: true,
      );
    }
  }
}

/// A "Create New Rate" button that offers Manual vs. Import from Excel on
/// tap, rather than jumping straight into manual creation — shared by
/// Published Rates and Custom Client Rates, whose own "create" buttons
/// previously dispatched [onManual] directly with no import option at all.
class CreateRateSplitButton extends StatelessWidget {
  const CreateRateSplitButton({
    super.key,
    required this.label,
    required this.onManual,
    this.isCustom = false,
  });

  final String label;
  final VoidCallback onManual;

  /// Passed through to [runRateImportFlow] — `true` only when this button
  /// lives on the Custom Client Rates page, so an import started here
  /// still creates a rate for the currently-selected client rather than a
  /// published one.
  final bool isCustom;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<void>(
      offset: const Offset(0, 44),
      itemBuilder: (menuContext) => [
        PopupMenuItem(
          onTap: onManual,
          child: const _CreateRateMenuRow(
            icon: CupertinoIcons.slider_horizontal_3,
            label: 'Create manually',
          ),
        ),
        PopupMenuItem(
          onTap: () => runRateImportFlow(context, isCustom: isCustom),
          child: const _CreateRateMenuRow(
            icon: CupertinoIcons.doc_on_doc,
            label: 'Import from Excel',
          ),
        ),
        PopupMenuItem(
          onTap: () => downloadRateImportTemplate(context),
          child: const _CreateRateMenuRow(
            icon: CupertinoIcons.arrow_down_doc,
            label: 'Download template',
          ),
        ),
      ],
      // `PopupMenuButton` already wraps `child` in its own tap detector
      // (that's what opens the menu) — `IgnorePointer` stops the `ShadButton`
      // underneath from also trying to handle the tap itself, which would
      // otherwise race PopupMenuButton for the gesture.
      child: IgnorePointer(
        child: ShadButton(
          backgroundColor: context.colors.primary,
          hoverBackgroundColor: context.colors.primaryHover,
          leading: const Icon(CupertinoIcons.add, size: 17, color: Colors.white),
          onPressed: () {},
          child: Text(label),
        ),
      ),
    );
  }
}

class _CreateRateMenuRow extends StatelessWidget {
  const _CreateRateMenuRow({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: context.colors.textMuted),
        const SizedBox(width: 10),
        Text(label),
      ],
    );
  }
}
