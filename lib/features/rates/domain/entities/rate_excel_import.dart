import 'package:excel_plus/excel_plus.dart';

import 'breakweight.dart';
import 'location_option.dart';
import 'matrix_row.dart';
import 'rate_excel_template.dart';
import 'rate_import_data.dart';
import 'rates_enums.dart';
import 'rates_fk_ids.dart';

/// Thrown when the uploaded file isn't a rate-import spreadsheet at all
/// (wrong file, wrong sheet name, or missing the Rate Setup fields) — a
/// user-facing message distinct from a bad individual row, which just gets
/// skipped instead of failing the whole import.
class RateImportFormatException implements Exception {
  const RateImportFormatException(this.message);
  final String message;

  @override
  String toString() => message;
}

String _cellText(Sheet sheet, int col, int row) {
  final cell = sheet.cell(
    CellIndex.indexByColumnRow(columnIndex: col, rowIndex: row),
  );
  final value = cell.value;
  if (value == null) return '';
  if (value is TextCellValue) return value.value.text?.trim() ?? '';
  return value.toString().trim();
}

/// Parses a bracket cell's `min-max` text (e.g. `"1-50"`) into a
/// [Breakweight]. Also accepts a bare number as an unbounded upper tier
/// (`"150"` -> max `150`, min left at its default) and dash-only variants
/// (en dash, em dash) since Excel autocorrect likes to swap those in.
Breakweight? _parseBracketText(String text) {
  final normalized = text.replaceAll(RegExp('[–—]'), '-');
  final parts = normalized.split('-').map((p) => p.trim()).toList();
  if (parts.length == 2 && parts[0].isNotEmpty && parts[1].isNotEmpty) {
    return Breakweight(min: parts[0], max: parts[1]);
  }
  if (parts.length == 1 && parts[0].isNotEmpty) {
    return Breakweight(max: parts[0]);
  }
  return null;
}

T? _matchByLabel<T>(Iterable<T> values, String Function(T) label, String text) {
  final normalized = text.trim().toLowerCase();
  if (normalized.isEmpty) return null;
  for (final v in values) {
    if (label(v).trim().toLowerCase() == normalized) return v;
  }
  return null;
}


/// Reverse of `RateExcelTemplateLayout`'s writer — reads an uploaded
/// workbook back into wizard-shaped data. [allCities] is the same full
/// city list the template's Origin/Destination dropdowns were built from;
/// matching against it (rather than re-querying search per row) is what
/// lets every dropdown-selected value resolve to a real [LocationOption]
/// without a network round trip per row.
///
/// Throws [RateImportFormatException] if the file doesn't look like a rate
/// template at all. Individual bad route rows are skipped and reported via
/// [RateImportData.skippedRows] rather than failing the whole import.
RateImportData parseRateImportWorkbook(
  List<int> bytes, {
  required List<LocationOption> allCities,
}) {
  final Excel excel;
  try {
    excel = Excel.decodeBytes(bytes);
  } catch (_) {
    throw const RateImportFormatException(
      "That doesn't look like a valid Excel file.",
    );
  }

  final sheet = excel.sheets[RateExcelTemplateLayout.sheetName];
  if (sheet == null) {
    throw RateImportFormatException(
      'Expected a "${RateExcelTemplateLayout.sheetName}" sheet — use the '
      "downloaded template rather than a blank workbook.",
    );
  }

  final freightModeText = _cellText(sheet, 1, RateExcelTemplateLayout.freightModeRow);
  final freightMode = _matchByLabel(FreightMode.values, (m) => m.label, freightModeText);
  if (freightMode == null) {
    throw RateImportFormatException(
      'Freight Mode "$freightModeText" isn\'t one of ${FreightMode.values.map((m) => m.label).join(', ')}.',
    );
  }

  final serviceMode = _matchByLabel(
        ServiceMode.values,
        (m) => m.label,
        _cellText(sheet, 1, RateExcelTemplateLayout.serviceModeRow),
      ) ??
      ServiceMode.doorToDoor;
  final chargeBasis = _matchByLabel(
        ChargeBasis.values,
        (m) => m.label,
        _cellText(sheet, 1, RateExcelTemplateLayout.chargeBasisRow),
      ) ??
      ChargeBasis.kilo;
  final pricingOption = _matchByLabel(
        PricingOption.values,
        (m) => m.label,
        _cellText(sheet, 1, RateExcelTemplateLayout.pricingOptionRow),
      ) ??
      PricingOption.fixedBreakweight;

  // The four Rate Setup dropdowns are independent lists in Excel (a
  // dependent/cascading dropdown needs either a formula-driven named range
  // per combination or VBA — the former is fragile to get exactly right
  // across every Freight Mode, the latter trips Excel's security warning
  // and is commonly IT-blocked), so nothing stops the sheet from combining
  // values the wizard itself would never allow together (e.g. Land with a
  // Service Mode other than Door to Door). Reject that combination here
  // instead of silently importing a rate the backend would reject anyway.
  final validServiceModes =
      RatesFkIds.serviceModeOptionsByFreightMode[freightMode] ?? const [];
  if (!validServiceModes.contains(serviceMode)) {
    throw RateImportFormatException(
      'Service Mode "${serviceMode.label}" isn\'t valid for ${freightMode.label} freight '
      '— use one of: ${validServiceModes.map((m) => m.label).join(', ')}.',
    );
  }
  final validChargeBases =
      RatesFkIds.chargeBasisOptionsByFreightMode[freightMode] ?? const [];
  if (!validChargeBases.contains(chargeBasis)) {
    throw RateImportFormatException(
      'Charge Basis "${chargeBasis.label}" isn\'t valid for ${freightMode.label} freight '
      '— use one of: ${validChargeBases.map((m) => m.label).join(', ')}.',
    );
  }
  final validPricingOptions =
      RatesFkIds.pricingOptionsByChargeBasis[chargeBasis] ?? const [];
  if (!validPricingOptions.contains(pricingOption)) {
    throw RateImportFormatException(
      'Pricing Option "${pricingOption.label}" isn\'t valid for ${chargeBasis.label} — '
      '${validPricingOptions.isEmpty ? "this Charge Basis has no supported pricing option yet." : "use one of: ${validPricingOptions.map((m) => m.label).join(', ')}."}',
    );
  }

  // Bracket columns: the number of Regular/Express bracket columns the
  // template shipped with is chosen per download (see the stepper dialog
  // in `rate_import_flow.dart`), so it isn't a fixed constant this reader
  // can assume — instead, find Express's actual start by scanning the
  // group-header row for its "Express" label, which is always present
  // regardless of the chosen count. Everything between Regular's start and
  // that point is a Regular bracket column (only those with a parseable
  // `min-max` value count as a real bracket — the rest may be blank if the
  // user didn't need that many).
  final regularStart = RateExcelTemplateLayout.firstBracketCol;
  var expressStart = regularStart;
  while (expressStart < regularStart + 200) {
    if (_cellText(sheet, expressStart, RateExcelTemplateLayout.groupHeaderRow) == 'Express') {
      break;
    }
    expressStart++;
  }
  if (expressStart >= regularStart + 200) {
    throw const RateImportFormatException(
      'Could not find the "Express" column group — use the downloaded '
      'template rather than a hand-built sheet.',
    );
  }

  // Tracks each real bracket's own Regular column alongside its value —
  // read back below when pulling `rates`, so a bracket the user left
  // blank in the middle of the group doesn't shift every column after it
  // out of alignment with Express's matching column (`col + expressOffset`
  // below relies on this).
  final brackets = <Breakweight>[];
  final bracketCols = <int>[];
  for (var col = regularStart; col < expressStart; col++) {
    final parsed = _parseBracketText(
      _cellText(sheet, col, RateExcelTemplateLayout.bracketRow),
    );
    if (parsed == null) continue;
    brackets.add(parsed);
    bracketCols.add(col);
  }
  if (brackets.isEmpty) {
    throw const RateImportFormatException(
      'No weight brackets found — fill in at least one bracket (e.g. '
      '"1-50") in the Regular columns (row 11).',
    );
  }

  final cityIndex = <String, LocationOption>{
    for (final c in allCities)
      _cityLabel(c).toLowerCase(): c,
  };

  final matrixRows = <MatrixRow>[];
  final skipped = <String>[];
  var row = RateExcelTemplateLayout.firstRouteRow;
  var consecutiveBlank = 0;
  while (consecutiveBlank < 5) {
    final originText = _cellText(sheet, RateExcelTemplateLayout.originCol, row);
    final destinationText = _cellText(sheet, RateExcelTemplateLayout.destinationCol, row);

    if (originText.isEmpty && destinationText.isEmpty) {
      consecutiveBlank++;
      row++;
      continue;
    }
    consecutiveBlank = 0;

    final originOption = cityIndex[originText.toLowerCase()];
    final destinationOption = cityIndex[destinationText.toLowerCase()];
    if (originOption == null || destinationOption == null) {
      skipped.add(
        'Row ${row + 1}: "$originText" → "$destinationText" — pick these '
        'from the dropdown, typed/pasted values that don\'t match a known '
        'city are skipped.',
      );
      row++;
      continue;
    }

    final rates = [
      for (final col in bracketCols) _cellText(sheet, col, row),
    ];
    final expressRates = [
      for (final col in bracketCols)
        _cellText(sheet, col + (expressStart - regularStart), row),
    ];

    matrixRows.add(
      MatrixRow(
        origin: originText,
        destination: destinationText,
        rates: rates,
        expressRates: expressRates,
        originOption: originOption,
        destinationOption: destinationOption,
      ),
    );
    row++;
  }

  if (matrixRows.isEmpty) {
    throw const RateImportFormatException(
      'No route rows found — fill in at least one Origin/Destination pair.',
    );
  }

  return RateImportData(
    freightMode: freightMode,
    serviceMode: serviceMode,
    chargeBasis: chargeBasis,
    pricingOption: pricingOption,
    breakweights: brackets,
    matrixRows: matrixRows,
    skippedRows: skipped,
  );
}

String _cityLabel(LocationOption city) {
  final name = city.cityName ?? city.label;
  final province = city.provinceName;
  return province != null && province.isNotEmpty ? '$name, $province' : name;
}
