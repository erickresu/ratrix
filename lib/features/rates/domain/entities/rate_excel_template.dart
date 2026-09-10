import 'package:excel_plus/excel_plus.dart';

import 'location_option.dart';
import 'rates_enums.dart';

/// Cell layout shared by the template writer ([buildRateImportTemplate])
/// and the reader ([parseRateImportWorkbook], in `rate_excel_import.dart`)
/// — keep both in sync if either changes.
///
/// Row 1: "RATE SETUP" banner. Rows 2-5: Freight Mode / Service Mode /
/// Charge Basis / Pricing Option, label in column A, value (a dropdown) in
/// column B. Row 10: "Origin (City, Province)" / "Destination (City,
/// Province)" / breakweight group headers ("Regular" / "Express" spanning
/// their bracket columns). Row 11: one `min-max` text value per bracket
/// column (e.g. `"1-50"`), typed by the user — a single cell per bracket
/// rather than a separate Min row and Max row, which read as two
/// disconnected things instead of one range. Row 12+: one route per row.
class RateExcelTemplateLayout {
  RateExcelTemplateLayout._();

  static const sheetName = 'Rate Setup';
  static const locationsSheetName = 'Locations';

  static const freightModeRow = 1; // 0-indexed row 1 = spreadsheet row 2
  static const serviceModeRow = 2;
  static const chargeBasisRow = 3;
  static const pricingOptionRow = 4;

  static const groupHeaderRow = 9; // spreadsheet row 10
  static const bracketRow = 10; // spreadsheet row 11
  static const firstRouteRow = 11; // spreadsheet row 12

  static const originCol = 0;
  static const destinationCol = 1;
  static const firstBracketCol = 2;

  /// Default weight-bracket column count per service level (Regular /
  /// Express) when [buildRateImportTemplate] isn't given an explicit
  /// [bracketCount] — generous enough that most rates need no more, without
  /// asking the user to decide anything up front.
  static const defaultBracketCount = 5;
}

/// Builds the downloadable "fill this in" workbook: a Rate Setup section
/// (freight/service mode, charge basis, pricing option — each a dropdown
/// constrained to the real enum labels) and a route table (Origin/
/// Destination dropdowns sourced from every known city, so a saved value is
/// always resolvable, plus Regular/Express weight-bracket price columns).
///
/// [bracketCount] sets how many bracket columns each of Regular/Express
/// gets, exactly — there's no way to add more from inside the spreadsheet
/// itself (a real "+" button needs VBA macros, which trip Excel's security
/// warning, are commonly blocked by IT policy, and don't work outside
/// Excel at all), so the choice lives here, in the app, before download —
/// see the stepper dialog in `rate_import_flow.dart`.
List<int> buildRateImportTemplate({
  required List<LocationOption> allCities,
  int bracketCount = RateExcelTemplateLayout.defaultBracketCount,
}) {
  final excel = Excel.createExcel();

  // `Excel.createExcel()` starts with one default sheet — rename it in
  // place instead of adding a new one and deleting the default, which
  // briefly leaves the workbook with zero visible sheets (rejected by
  // Excel's "at least one visible sheet" rule the package itself enforces).
  final defaultSheetName = excel.sheets.keys.first;
  excel.rename(defaultSheetName, RateExcelTemplateLayout.sheetName);
  final sheet = excel[RateExcelTemplateLayout.sheetName];

  _applyColumnWidths(sheet, bracketCount: bracketCount);
  _applyRowHeights(sheet);
  _writeRateSetupSection(sheet);
  _writeRouteTableHeader(sheet, bracketCount: bracketCount);
  _writeSampleRow(sheet);

  final locationsSheet = excel[RateExcelTemplateLayout.locationsSheetName];
  _writeLocationsReferenceSheet(locationsSheet, allCities);
  locationsSheet.visibility = SheetVisibility.hidden;

  _applyDropdowns(sheet, cityCount: allCities.length);

  excel.setDefaultSheet(RateExcelTemplateLayout.sheetName);
  return excel.save() ?? const [];
}

// Roughly double Excel's own default (8.43 units ~ 64px) — the original
// narrow columns truncated labels like "Freight Mode" down to "Freight M".
void _applyColumnWidths(Sheet sheet, {required int bracketCount}) {
  sheet.setDefaultColumnWidth(17);
  sheet.setColumnWidth(RateExcelTemplateLayout.originCol, 34);
  sheet.setColumnWidth(RateExcelTemplateLayout.destinationCol, 34);
  final expressStart = RateExcelTemplateLayout.firstBracketCol + bracketCount;
  for (var i = 0; i < bracketCount; i++) {
    sheet.setColumnWidth(RateExcelTemplateLayout.firstBracketCol + i, 17);
    sheet.setColumnWidth(expressStart + i, 17);
  }
}

// A touch taller than Excel's own default row (~15) so the doubled
// columns don't look cramped vertically — not scaled to match the fonts
// below, which stay close to normal spreadsheet size.
void _applyRowHeights(Sheet sheet) {
  sheet.setRowHeight(0, 20);
  for (
    var row = RateExcelTemplateLayout.freightModeRow;
    row <= RateExcelTemplateLayout.pricingOptionRow;
    row++
  ) {
    sheet.setRowHeight(row, 18);
  }
  sheet.setRowHeight(RateExcelTemplateLayout.groupHeaderRow, 18);
  sheet.setRowHeight(RateExcelTemplateLayout.bracketRow, 18);
}

const _bodyFontSize = 11;
const _headerFontSize = 13;

CellStyle _bannerStyle() => CellStyle(
  bold: true,
  fontSize: _headerFontSize,
  fontColorHex: ExcelColor.white,
  backgroundColorHex: ExcelColor.fromHexString('#0E9F6E'),
);

CellStyle _labelStyle() => CellStyle(
  bold: true,
  fontSize: _bodyFontSize,
  backgroundColorHex: ExcelColor.fromHexString('#F3F4F6'),
);

CellStyle _valueStyle() => CellStyle(fontSize: _bodyFontSize);

void _writeRateSetupSection(Sheet sheet) {
  sheet.merge(
    CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 0),
    CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: 0),
  );
  sheet.updateCell(
    CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 0),
    TextCellValue('RATE SETUP'),
    cellStyle: _bannerStyle(),
  );

  void labelRow(int row, String label, String defaultValue) {
    sheet.updateCell(
      CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: row),
      TextCellValue(label),
      cellStyle: _labelStyle(),
    );
    sheet.updateCell(
      CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: row),
      TextCellValue(defaultValue),
      cellStyle: _valueStyle(),
    );
  }

  labelRow(
    RateExcelTemplateLayout.freightModeRow,
    'Freight Mode',
    FreightMode.land.label,
  );
  labelRow(
    RateExcelTemplateLayout.serviceModeRow,
    'Service Mode',
    ServiceMode.doorToDoor.label,
  );
  labelRow(
    RateExcelTemplateLayout.chargeBasisRow,
    'Charge Basis',
    ChargeBasis.ltlKilo.label,
  );
  labelRow(
    RateExcelTemplateLayout.pricingOptionRow,
    'Pricing Option',
    PricingOption.flatBreakweight.label,
  );
}

void _writeRouteTableHeader(Sheet sheet, {required int bracketCount}) {
  final n = bracketCount;
  final regularStart = RateExcelTemplateLayout.firstBracketCol;
  final expressStart = regularStart + n;

  CellIndex at(int col, int row) =>
      CellIndex.indexByColumnRow(columnIndex: col, rowIndex: row);

  final groupStyle = CellStyle(
    bold: true,
    fontSize: _bodyFontSize,
    fontColorHex: ExcelColor.white,
    horizontalAlign: HorizontalAlign.Center,
  );

  sheet.merge(
    at(regularStart, RateExcelTemplateLayout.groupHeaderRow),
    at(regularStart + n - 1, RateExcelTemplateLayout.groupHeaderRow),
  );
  sheet.updateCell(
    at(regularStart, RateExcelTemplateLayout.groupHeaderRow),
    TextCellValue('Regular'),
    cellStyle: groupStyle.copyWith(
      backgroundColorHexVal: ExcelColor.fromHexString('#14B8A6'),
    ),
  );

  sheet.merge(
    at(expressStart, RateExcelTemplateLayout.groupHeaderRow),
    at(expressStart + n - 1, RateExcelTemplateLayout.groupHeaderRow),
  );
  sheet.updateCell(
    at(expressStart, RateExcelTemplateLayout.groupHeaderRow),
    TextCellValue('Express'),
    cellStyle: groupStyle.copyWith(
      backgroundColorHexVal: ExcelColor.fromHexString('#0F766E'),
    ),
  );

  sheet.updateCell(
    at(
      RateExcelTemplateLayout.originCol,
      RateExcelTemplateLayout.groupHeaderRow,
    ),
    TextCellValue('Origin (City, Province)'),
    cellStyle: _labelStyle(),
  );
  sheet.updateCell(
    at(
      RateExcelTemplateLayout.destinationCol,
      RateExcelTemplateLayout.groupHeaderRow,
    ),
    TextCellValue('Destination (City, Province)'),
    cellStyle: _labelStyle(),
  );
  sheet.merge(
    at(
      RateExcelTemplateLayout.originCol,
      RateExcelTemplateLayout.groupHeaderRow,
    ),
    at(RateExcelTemplateLayout.originCol, RateExcelTemplateLayout.bracketRow),
  );
  sheet.merge(
    at(
      RateExcelTemplateLayout.destinationCol,
      RateExcelTemplateLayout.groupHeaderRow,
    ),
    at(
      RateExcelTemplateLayout.destinationCol,
      RateExcelTemplateLayout.bracketRow,
    ),
  );

  // One `min-max` text cell per bracket column (e.g. "1-50") — typed by
  // the user, no formula. A sample value on the first Regular/Express
  // bracket shows the expected format; the rest start blank.
  final cellStyle = _labelStyle();
  for (final groupStart in [regularStart, expressStart]) {
    for (var i = 0; i < n; i++) {
      final col = groupStart + i;
      sheet.updateCell(
        at(col, RateExcelTemplateLayout.bracketRow),
        TextCellValue(i == 0 ? '1-50' : ''),
        cellStyle: cellStyle,
      );
    }
  }
}

void _writeSampleRow(Sheet sheet) {
  final row = RateExcelTemplateLayout.firstRouteRow;
  sheet.updateCell(
    CellIndex.indexByColumnRow(
      columnIndex: RateExcelTemplateLayout.originCol,
      rowIndex: row,
    ),
    TextCellValue(''),
  );
  sheet.updateCell(
    CellIndex.indexByColumnRow(
      columnIndex: RateExcelTemplateLayout.destinationCol,
      rowIndex: row,
    ),
    TextCellValue(''),
  );
}

void _writeLocationsReferenceSheet(
  Sheet sheet,
  List<LocationOption> allCities,
) {
  sheet.updateCell(
    CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 0),
    TextCellValue('City, Province'),
  );
  for (var i = 0; i < allCities.length; i++) {
    final city = allCities[i];
    final label = city.provinceName != null && city.provinceName!.isNotEmpty
        ? '${city.cityName ?? city.label}, ${city.provinceName}'
        : city.label;
    sheet.updateCell(
      CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: i + 1),
      TextCellValue(label),
    );
  }
}

void _applyDropdowns(Sheet sheet, {required int cityCount}) {
  sheet.setDataValidation(
    CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: RateExcelTemplateLayout.freightModeRow),
    DataValidation.list([for (final m in FreightMode.values) m.label]),
  );
  sheet.setDataValidation(
    CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: RateExcelTemplateLayout.serviceModeRow),
    DataValidation.list([for (final m in ServiceMode.values) m.label]),
  );
  sheet.setDataValidation(
    CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: RateExcelTemplateLayout.chargeBasisRow),
    DataValidation.list([for (final m in ChargeBasis.values) m.label]),
  );
  sheet.setDataValidation(
    CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: RateExcelTemplateLayout.pricingOptionRow),
    DataValidation.list([for (final m in PricingOption.values) m.label]),
  );

  // Origin/Destination dropdowns, sourced from the hidden Locations sheet
  // rather than an inline list — an inline `DataValidation.list` is capped
  // at ~255 characters total, nowhere near enough for ~1600+ city names.
  // Applied across a generous number of rows so pasting/typing extra routes
  // below the sample still gets the dropdown without the user having to
  // reapply it by hand.
  const maxRouteRows = 500;
  final locationRange =
      "'${RateExcelTemplateLayout.locationsSheetName}'!\$A\$2:\$A\$${cityCount + 1}";
  final originValidation = DataValidation.listFromRange(locationRange);
  final destinationValidation = DataValidation.listFromRange(locationRange);

  sheet.setDataValidation(
    CellIndex.indexByColumnRow(
      columnIndex: RateExcelTemplateLayout.originCol,
      rowIndex: RateExcelTemplateLayout.firstRouteRow,
    ),
    originValidation,
    end: CellIndex.indexByColumnRow(
      columnIndex: RateExcelTemplateLayout.originCol,
      rowIndex: RateExcelTemplateLayout.firstRouteRow + maxRouteRows,
    ),
  );
  sheet.setDataValidation(
    CellIndex.indexByColumnRow(
      columnIndex: RateExcelTemplateLayout.destinationCol,
      rowIndex: RateExcelTemplateLayout.firstRouteRow,
    ),
    destinationValidation,
    end: CellIndex.indexByColumnRow(
      columnIndex: RateExcelTemplateLayout.destinationCol,
      rowIndex: RateExcelTemplateLayout.firstRouteRow + maxRouteRows,
    ),
  );
}
