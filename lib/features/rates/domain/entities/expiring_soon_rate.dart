import 'package:freezed_annotation/freezed_annotation.dart';

part 'expiring_soon_rate.freezed.dart';

@freezed
abstract class ExpiringSoonRate with _$ExpiringSoonRate {
  const factory ExpiringSoonRate({
    required String client,
    required String chargeCode,
    required int daysLeft,
  }) = _ExpiringSoonRate;
}
