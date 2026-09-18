import 'package:flutter/foundation.dart';

import '../data/order_service.dart';
import '../domain/order.dart';

class MyOrdersController extends ChangeNotifier {
  MyOrdersController(this._service);

  final OrderService _service;

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
