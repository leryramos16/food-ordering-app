import '../../../core/api_client.dart';
import '../../cart/state/cart_controller.dart';
import '../domain/order.dart';

class OrderService {
  OrderService(this._api);

  final ApiClient _api;

  Future<Order> placeOrder({
    required CartController cart,
    required int addressId,
    String? notes,
  }) async {
    final response = await _api.post(
      '/orders',
      authenticated: true,
      body: {
        'restaurant_id': cart.restaurantId,
        'address_id': addressId,
        'payment_method': 'cash_on_delivery',
        'notes': notes?.trim().isEmpty == true ? null : notes?.trim(),
        'items': [
          for (final cartItem in cart.items)
            {
              'menu_item_id': cartItem.menuItem.id,
              'quantity': cartItem.quantity,
            },
        ],
      },
    );

    final data = Map<String, dynamic>.from(response['data'] as Map);
    return Order.fromJson(data);
  }
}
