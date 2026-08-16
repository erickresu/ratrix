import 'package:freezed_annotation/freezed_annotation.dart';

part 'matrix_row.freezed.dart';

@freezed
abstract class MatrixRow with _$MatrixRow {
  const factory MatrixRow({
    @Default('') String origin,
    @Default('') String destination,
    @Default(<String>['']) List<String> rates,
  }) = _MatrixRow;
}
