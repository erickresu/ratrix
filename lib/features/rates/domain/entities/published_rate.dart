import 'package:freezed_annotation/freezed_annotation.dart';

import 'rates_enums.dart';

part 'published_rate.freezed.dart';

@freezed
abstract class PublishedRate with _$PublishedRate {
  const factory PublishedRate({
    required String id,
    required String chargeCode,
    required FreightMode freightMode,
    required ServiceMode serviceMode,
    required String routeLabel,
    required int routeCount,
    required RateStatus status,
    required String expiryLabel,
    DateTime? expiryDate,
    DateTime? createdAt,
  }) = _PublishedRate;
}
