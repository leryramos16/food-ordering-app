import 'package:flutter/foundation.dart';

import '../data/owner_order_service.dart';
import '../domain/order.dart';

class OwnerOrderController extends ChangeNotifier {
  OwnerOrderController(this._service);

  final OwnerOrderService _service;

  List<Order> orders = [];

  bool isLoading = false;
  String? errorMessage;

  /// Order ids currently being updated, so a card can show a small spinner
  /// on just its own action instead of blocking the whole list.
  final Set<int> submittingOrderIds = {};

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

  Future<bool> updateStatus(int orderId, String status) {
    return _mutate(orderId, () => _service.updateStatus(orderId, status));
  }

  Future<bool> markPaid(int orderId) {
    return _mutate(orderId, () => _service.markPaid(orderId));
  }

  Future<bool> _mutate(int orderId, Future<Order> Function() action) async {
    submittingOrderIds.add(orderId);
    errorMessage = null;
    notifyListeners();

    try {
      final updated = await action();

      final index = orders.indexWhere((order) => order.id == orderId);
      if (index != -1) orders[index] = updated;

      return true;
    } catch (error) {
      errorMessage = error.toString();
      return false;
    } finally {
      submittingOrderIds.remove(orderId);
      notifyListeners();
    }
  }
}
