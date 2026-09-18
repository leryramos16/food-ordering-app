import 'package:flutter/foundation.dart';

import '../../cart/state/cart_controller.dart';
import '../data/order_service.dart';
import '../data/payment_service.dart';
import '../domain/order.dart';

class CheckoutController extends ChangeNotifier {
  CheckoutController(this._service, this._paymentService);

  final OrderService _service;
  final PaymentService _paymentService;

  bool isSubmitting = false;
  String? errorMessage;

  Future<Order?> placeOrder({
    required CartController cart,
    required int addressId,
    required String paymentMethod,
    String? notes,
  }) async {
    isSubmitting = true;
    errorMessage = null;
    notifyListeners();

    try {
      final order = await _service.placeOrder(
        cart: cart,
        addressId: addressId,
        paymentMethod: paymentMethod,
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

  Future<String?> initiateGcashPayment(int orderId) async {
    isSubmitting = true;
    errorMessage = null;
    notifyListeners();

    try {
      return await _paymentService.initiate(orderId);
    } catch (error) {
      errorMessage = error.toString();
      return null;
    } finally {
      isSubmitting = false;
      notifyListeners();
    }
  }

  Future<Order?> refreshOrder(int orderId) async {
    try {
      return await _service.getOrder(orderId);
    } catch (_) {
      return null;
    }
  }
}
