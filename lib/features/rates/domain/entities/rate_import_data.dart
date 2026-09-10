import 'package:freezed_annotation/freezed_annotation.dart';

import 'breakweight.dart';
import 'matrix_row.dart';
import 'rates_enums.dart';

part 'rate_import_data.freezed.dart';

/// Fully-parsed result of reading an imported rate-creation spreadsheet —
/// shaped to drop straight into `RateWizardState` the same way an existing
/// `RatrixRate` does for edit mode (see `_buildStateFromExistingRate`). One
/// shared rate setup + one shared breakweight column set (from the sheet's
/// header row) applied across every route row.
@freezed
abstract class RateImportData with _$RateImportData {
  const factory RateImportData({
    required FreightMode freightMode,
    required ServiceMode serviceMode,
    required ChargeBasis chargeBasis,
    required PricingOption pricingOption,
    required List<Breakweight> breakweights,
    required List<MatrixRow> matrixRows,
    // Rows the parser couldn't use — bad/missing origin or destination,
    // unparseable rate cells — so the caller can tell the user what got
    // skipped instead of silently dropping them.
    @Default([]) List<String> skippedRows,
  }) = _RateImportData;
}
