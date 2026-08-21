import 'package:freezed_annotation/freezed_annotation.dart';

import 'rates_enums.dart';

part 'client.freezed.dart';

@freezed
abstract class Client with _$Client {
  const factory Client({
    required String id,
    required String accountNumber,
    required String name,
    required String email,
    required String businessType,
    required VatStatus vatStatus,
    String? phoneNumber,
    String? officeAddress,
  }) = _Client;

  const Client._();

  String get initials {
    final words = name.split(' ').where((w) => w.isNotEmpty && RegExp(r'[A-Za-z]').hasMatch(w[0]));
    return words.take(2).map((w) => w[0].toUpperCase()).join();
  }
}
