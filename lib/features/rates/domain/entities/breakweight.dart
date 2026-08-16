import 'package:freezed_annotation/freezed_annotation.dart';

part 'breakweight.freezed.dart';

@freezed
abstract class Breakweight with _$Breakweight {
  const factory Breakweight({
    @Default('1') String min,
    @Default('') String max,
  }) = _Breakweight;
}
