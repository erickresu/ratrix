import 'package:freezed_annotation/freezed_annotation.dart';

part 'client.freezed.dart';

@freezed
abstract class ClientCompliance with _$ClientCompliance {
  const factory ClientCompliance({String? vatStatus, String? tinNo}) = _ClientCompliance;

  static ClientCompliance fromJson(Map<String, dynamic> json) => ClientCompliance(
        vatStatus: json['vat_status']?.toString(),
        tinNo: json['tin_no']?.toString(),
      );
}

@freezed
abstract class Client with _$Client {
  const factory Client({
    required int id,
    required String accountNo,
    required String name,
    String? tradeName,
    String? email,
    String? phoneNumber,
    String? businessType,
    String? organizationType,
    String? officeAddress,
    String? billingAddress,
    @Default(0) num paymentTerms,
    @Default(0) num thresholdLimit,
    @Default(0) num creditLimit,
    ClientCompliance? compliance,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _Client;

  static Client fromJson(Map<String, dynamic> json) => Client(
        id: json['id'] as int,
        accountNo: (json['account_no'] ?? '').toString(),
        name: (json['name'] ?? '').toString(),
        tradeName: json['trade_name']?.toString(),
        email: json['email']?.toString(),
        phoneNumber: json['phone_number']?.toString(),
        businessType: json['business_type']?.toString(),
        organizationType: json['organization_type']?.toString(),
        officeAddress: json['office_address']?.toString(),
        billingAddress: json['billing_address']?.toString(),
        paymentTerms: json['payment_terms'] as num? ?? 0,
        thresholdLimit: json['threshold_limit'] as num? ?? 0,
        creditLimit: json['credit_limit'] as num? ?? 0,
        compliance: json['compliance'] is Map<String, dynamic>
            ? ClientCompliance.fromJson(json['compliance'] as Map<String, dynamic>)
            : null,
        createdAt: DateTime.tryParse(json['created_at']?.toString() ?? ''),
        updatedAt: DateTime.tryParse(json['updated_at']?.toString() ?? ''),
      );
}
