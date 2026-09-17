import 'package:flutter/foundation.dart';

import '../data/owner_order_service.dart';
import '../domain/order.dart';

class OwnerOrderController extends ChangeNotifier {
  OwnerOrderController(this._service);

  final OwnerOrderService _service;

  List<Order> orders = [];

  bool isLoading = false;
  String? errorMessage;

  Future<void> loadOrders() async {
    if (isLoading) return;

    isLoading = true;
    errorMessage = null;

    notifyListeners();

    try {
      orders = await _service.getOrders();
    } catch (error) {
      errorMessage = error.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
