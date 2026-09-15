import 'package:flutter/foundation.dart';

import '../../restaurants/domain/restaurant.dart';
import '../data/owner_restaurant_service.dart';

class OwnerRestaurantController extends ChangeNotifier {
  OwnerRestaurantController(this._service);

  final OwnerRestaurantService _service;

  Restaurant? restaurant;

  bool isLoading = false;
  bool isSubmitting = false;
  String? errorMessage;

  Future<void> loadMyRestaurant() async {
    if (isLoading) return;

    isLoading = true;
    errorMessage = null;

    notifyListeners();

    try {
      restaurant = await _service.getMyRestaurant();
    } catch (error) {
      errorMessage = error.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> saveRestaurant({
    required String name,
    String? description,
    String? phone,
    required String address,
    required double deliveryFee,
    required double minimumOrder,
    required bool isOpen,
  }) async {
    isSubmitting = true;
    errorMessage = null;
    notifyListeners();

    try {
      restaurant = restaurant == null
          ? await _service.createRestaurant(
              name: name,
              description: description,
              phone: phone,
              address: address,
              deliveryFee: deliveryFee,
              minimumOrder: minimumOrder,
              isOpen: isOpen,
            )
          : await _service.updateRestaurant(
              name: name,
              description: description,
              phone: phone,
              address: address,
              deliveryFee: deliveryFee,
              minimumOrder: minimumOrder,
              isOpen: isOpen,
            );
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
