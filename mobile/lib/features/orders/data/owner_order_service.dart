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
}
