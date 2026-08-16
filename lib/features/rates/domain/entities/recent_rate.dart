import 'package:freezed_annotation/freezed_annotation.dart';

import 'rates_enums.dart';

part 'recent_rate.freezed.dart';

@freezed
abstract class RecentRate with _$RecentRate {
  const factory RecentRate({
    required String route,
    required String client,
    required RateType type,
    required String price,
    required RateStatus status,
  }) = _RecentRate;
}
