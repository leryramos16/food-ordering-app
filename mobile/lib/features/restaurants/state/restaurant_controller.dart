import 'package:flutter/foundation.dart';

import '../data/restaurant_service.dart';
import '../domain/restaurant.dart';

class RestaurantController extends ChangeNotifier {
  RestaurantController(this._service);

  final RestaurantService _service;

  List<Restaurant> restaurants = [];

  bool isLoading = false;

  String? errorMessage;

  Future<void> loadRestaurants() async {
    if (isLoading) return;

    isLoading = true;
    errorMessage = null;

    notifyListeners();

    try {
      restaurants = await _service.getRestaurants();
    } catch (error) {
      errorMessage = error.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
