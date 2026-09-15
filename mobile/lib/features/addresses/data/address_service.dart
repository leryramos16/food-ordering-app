import '../../../core/api_client.dart';
import '../domain/address.dart';

class AddressService {
  AddressService(this._api);

  final ApiClient _api;

  Future<List<Address>> getAddresses() async {
    final response = await _api.get('/addresses', authenticated: true);

    final data = response['data'] as List<dynamic>;

    return data
        .map(
          (item) => Address.fromJson(Map<String, dynamic>.from(item as Map)),
        )
        .toList();
  }

  Future<Address> createAddress({
    required String label,
    required String recipientName,
    required String phone,
    required String addressLine,
    String? barangay,
    required String city,
    required String province,
    String? postalCode,
    required bool isDefault,
  }) async {
    final response = await _api.post(
      '/addresses',
      authenticated: true,
      body: {
        'label': label.trim(),
        'recipient_name': recipientName.trim(),
        'phone': phone.trim(),
        'address_line': addressLine.trim(),
        'barangay': barangay?.trim().isEmpty == true ? null : barangay?.trim(),
        'city': city.trim(),
        'province': province.trim(),
        'postal_code': postalCode?.trim().isEmpty == true
            ? null
            : postalCode?.trim(),
        'is_default': isDefault,
      },
    );

    final data = Map<String, dynamic>.from(response['data'] as Map);
    return Address.fromJson(data);
  }

  Future<Address> updateAddress({
    required int id,
    required String label,
    required String recipientName,
    required String phone,
    required String addressLine,
    String? barangay,
    required String city,
    required String province,
    String? postalCode,
    required bool isDefault,
  }) async {
    final response = await _api.put(
      '/addresses/$id',
      authenticated: true,
      body: {
        'label': label.trim(),
        'recipient_name': recipientName.trim(),
        'phone': phone.trim(),
        'address_line': addressLine.trim(),
        'barangay': barangay?.trim().isEmpty == true ? null : barangay?.trim(),
        'city': city.trim(),
        'province': province.trim(),
        'postal_code': postalCode?.trim().isEmpty == true
            ? null
            : postalCode?.trim(),
        'is_default': isDefault,
      },
    );

    final data = Map<String, dynamic>.from(response['data'] as Map);
    return Address.fromJson(data);
  }

  Future<void> deleteAddress(int id) {
    return _api.delete('/addresses/$id', authenticated: true);
  }
}
