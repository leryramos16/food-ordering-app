import 'package:flutter/foundation.dart';

import '../data/address_service.dart';
import '../domain/address.dart';

class AddressController extends ChangeNotifier {
  AddressController(this._service);

  final AddressService _service;

  List<Address> addresses = [];

  bool isLoading = false;
  bool isSubmitting = false;
  String? errorMessage;

  Future<void> loadAddresses() async {
    if (isLoading) return;

    isLoading = true;
    errorMessage = null;

    notifyListeners();

    try {
      addresses = await _service.getAddresses();
    } catch (error) {
      errorMessage = error.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createAddress({
    required String label,
    required String recipientName,
    required String phone,
    required String addressLine,
    String? barangay,
    required String city,
    required String province,
    String? postalCode,
    required bool isDefault,
  }) {
    return _submit(
      () => _service.createAddress(
        label: label,
        recipientName: recipientName,
        phone: phone,
        addressLine: addressLine,
        barangay: barangay,
        city: city,
        province: province,
        postalCode: postalCode,
        isDefault: isDefault,
      ),
    );
  }

  Future<bool> updateAddress({
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
  }) {
    return _submit(
      () => _service.updateAddress(
        id: id,
        label: label,
        recipientName: recipientName,
        phone: phone,
        addressLine: addressLine,
        barangay: barangay,
        city: city,
        province: province,
        postalCode: postalCode,
        isDefault: isDefault,
      ),
    );
  }

  Future<bool> deleteAddress(int id) async {
    isSubmitting = true;
    errorMessage = null;
    notifyListeners();

    try {
      await _service.deleteAddress(id);
      addresses.removeWhere((address) => address.id == id);
      return true;
    } catch (error) {
      errorMessage = error.toString();
      return false;
    } finally {
      isSubmitting = false;
      notifyListeners();
    }
  }

  Future<bool> _submit(Future<Address> Function() action) async {
    isSubmitting = true;
    errorMessage = null;
    notifyListeners();

    try {
      final saved = await action();

      addresses = [
        for (final address in addresses)
          if (address.id != saved.id)
            saved.isDefault ? address.copyWith(isDefault: false) : address,
        saved,
      ]..sort((a, b) => (b.isDefault ? 1 : 0) - (a.isDefault ? 1 : 0));

      return true;
    } catch (error) {
      errorMessage = error.toString();
      return false;
    } finally {
      isSubmitting = false;
      notifyListeners();
    }
  }
}
