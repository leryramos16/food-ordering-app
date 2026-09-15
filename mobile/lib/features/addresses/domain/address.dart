class Address {
  const Address({
    required this.id,
    required this.label,
    required this.recipientName,
    required this.phone,
    required this.addressLine,
    required this.barangay,
    required this.city,
    required this.province,
    required this.postalCode,
    required this.isDefault,
  });

  final int id;
  final String label;
  final String recipientName;
  final String phone;
  final String addressLine;
  final String? barangay;
  final String city;
  final String province;
  final String? postalCode;
  final bool isDefault;

  Address copyWith({bool? isDefault}) {
    return Address(
      id: id,
      label: label,
      recipientName: recipientName,
      phone: phone,
      addressLine: addressLine,
      barangay: barangay,
      city: city,
      province: province,
      postalCode: postalCode,
      isDefault: isDefault ?? this.isDefault,
    );
  }

  factory Address.fromJson(Map<String, dynamic> json) {
    return Address(
      id: json['id'] as int,
      label: json['label'] as String,
      recipientName: json['recipient_name'] as String,
      phone: json['phone'] as String,
      addressLine: json['address_line'] as String,
      barangay: json['barangay'] as String?,
      city: json['city'] as String,
      province: json['province'] as String,
      postalCode: json['postal_code'] as String?,
      isDefault: json['is_default'] as bool,
    );
  }
}
