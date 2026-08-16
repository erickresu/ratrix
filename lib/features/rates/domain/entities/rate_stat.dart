import 'package:freezed_annotation/freezed_annotation.dart';

part 'rate_stat.freezed.dart';

@freezed
abstract class RateStat with _$RateStat {
  const factory RateStat({
    required String label,
    required String value,
    required String delta,
  }) = _RateStat;
}
