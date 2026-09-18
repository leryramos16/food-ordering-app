import '../../../core/api_client.dart';
import '../domain/order.dart';

class OwnerOrderService {
  OwnerOrderService(this._api);

  final ApiClient _api;

  Future<List<Order>> getOrders() async {
    final response = await _api.get('/owner/orders', authenticated: true);

    final data = response['data'] as List<dynamic>;

    return data
        .map((item) => Order.fromJson(Map<String, dynamic>.from(item as Map)))
        .toList();
  }

  Future<Order> updateStatus(int orderId, String status) async {
    final response = await _api.patch(
      '/owner/orders/$orderId/status',
      authenticated: true,
      body: {'status': status},
    );

    final data = Map<String, dynamic>.from(response['data'] as Map);
    return Order.fromJson(data);
  }

  Future<Order> markPaid(int orderId) async {
    final response = await _api.patch(
      '/owner/orders/$orderId/mark-paid',
      authenticated: true,
    );

    final data = Map<String, dynamic>.from(response['data'] as Map);
    return Order.fromJson(data);
  }
}
