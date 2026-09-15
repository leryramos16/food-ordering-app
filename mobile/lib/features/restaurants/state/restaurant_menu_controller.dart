import 'package:flutter/foundation.dart';

import '../data/restaurant_service.dart';
import '../domain/restaurant.dart';

class RestaurantMenuController extends ChangeNotifier {
  RestaurantMenuController(this._service);

  final RestaurantService _service;

  Restaurant? restaurant;

  bool isLoading = false;

  String? errorMessage;

  Future<void> loadMenu(int restaurantId) async {
    if (isLoading) return;

    isLoading = true;
    errorMessage = null;

    notifyListeners();

    try {
      restaurant = await _service.getMenu(restaurantId);
    } catch (error) {
      errorMessage = error.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
