class ClientCompliance {
  const ClientCompliance({this.vatStatus, this.tinNo});

  final String? vatStatus;
  final String? tinNo;

  factory ClientCompliance.fromJson(Map<String, dynamic> json) => ClientCompliance(
        vatStatus: json['vat_status']?.toString(),
        tinNo: json['tin_no']?.toString(),
      );
}

class Client {
  const Client({
    required this.id,
    required this.accountNo,
    required this.name,
    this.tradeName,
    this.email,
    this.phoneNumber,
    this.businessType,
    this.organizationType,
    this.officeAddress,
    this.billingAddress,
    this.paymentTerms = 0,
    this.thresholdLimit = 0,
    this.creditLimit = 0,
    this.compliance,
    this.createdAt,
    this.updatedAt,
  });

  final int id;
  final String accountNo;
  final String name;
  final String? tradeName;
  final String? email;
  final String? phoneNumber;
  final String? businessType;
  final String? organizationType;
  final String? officeAddress;
  final String? billingAddress;
  final num paymentTerms;
  final num thresholdLimit;
  final num creditLimit;
  final ClientCompliance? compliance;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  factory Client.fromJson(Map<String, dynamic> json) => Client(
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
