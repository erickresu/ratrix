import 'package:freezed_annotation/freezed_annotation.dart';

part 'matrix_row.freezed.dart';

@freezed
abstract class MatrixRow with _$MatrixRow {
  const factory MatrixRow({
    @Default('') String origin,
    @Default('') String destination,
    @Default(<String>['']) List<String> rates,
    // Original route/location ids from the loaded rate (edit mode only).
    // Sent back as-is when the user hasn't touched origin/destination, so
    // the API can identify the same location instead of treating a
    // relabeled-but-unidentified route as ambiguous/duplicate. Cleared the
    // moment the user edits that row's origin or destination text, since
    // the id then no longer matches what's displayed.
    String? routeId,
    int? originId,
    int? destinationId,
  }) = _MatrixRow;
}
