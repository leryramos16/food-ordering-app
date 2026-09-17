import 'package:flutter/foundation.dart';

import '../../cart/state/cart_controller.dart';
import '../data/order_service.dart';
import '../domain/order.dart';

class CheckoutController extends ChangeNotifier {
  CheckoutController(this._service);

  final OrderService _service;

  bool isSubmitting = false;
  String? errorMessage;

  Future<Order?> placeOrder({
    required CartController cart,
    required int addressId,
    String? notes,
  }) async {
    isSubmitting = true;
    errorMessage = null;
    notifyListeners();

    try {
      final order = await _service.placeOrder(
        cart: cart,
        addressId: addressId,
        notes: notes,
      );
      cart.clear();
      return order;
    } catch (error) {
      errorMessage = error.toString();
      return null;
    } finally {
      isSubmitting = false;
      notifyListeners();
    }
  }
}
