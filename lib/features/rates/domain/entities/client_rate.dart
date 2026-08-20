import 'package:freezed_annotation/freezed_annotation.dart';

import 'rates_enums.dart';

part 'client_rate.freezed.dart';

@freezed
abstract class ClientRate with _$ClientRate {
  const factory ClientRate({
    required String id,
    required String clientId,
    required String chargeCode,
    required FreightMode freightMode,
    required ServiceMode serviceMode,
    required int routeCount,
    required RateStatus status,
    required String expiryLabel,
    DateTime? expiryDate,
  }) = _ClientRate;
}
