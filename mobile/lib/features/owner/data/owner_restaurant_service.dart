import '../../../core/api_client.dart';
import '../../restaurants/domain/restaurant.dart';

class OwnerRestaurantService {
  OwnerRestaurantService(this._api);

  final ApiClient _api;

  Future<Restaurant?> getMyRestaurant() async {
    final response = await _api.get('/owner/restaurant', authenticated: true);

    final data = response['data'];
    if (data == null) return null;

    return Restaurant.fromJson(Map<String, dynamic>.from(data as Map));
  }

  Future<Restaurant> createRestaurant({
    required String name,
    String? description,
    String? phone,
    required String address,
    required double deliveryFee,
    required double minimumOrder,
    required bool isOpen,
  }) async {
    final response = await _api.post(
      '/owner/restaurant',
      authenticated: true,
      body: _body(
        name: name,
        description: description,
        phone: phone,
        address: address,
        deliveryFee: deliveryFee,
        minimumOrder: minimumOrder,
        isOpen: isOpen,
      ),
    );

    final data = Map<String, dynamic>.from(response['data'] as Map);
    return Restaurant.fromJson(data);
  }

  Future<Restaurant> updateRestaurant({
    required String name,
    String? description,
    String? phone,
    required String address,
    required double deliveryFee,
    required double minimumOrder,
    required bool isOpen,
  }) async {
    final response = await _api.put(
      '/owner/restaurant',
      authenticated: true,
      body: _body(
        name: name,
        description: description,
        phone: phone,
        address: address,
        deliveryFee: deliveryFee,
        minimumOrder: minimumOrder,
        isOpen: isOpen,
      ),
    );

    final data = Map<String, dynamic>.from(response['data'] as Map);
    return Restaurant.fromJson(data);
  }

  Map<String, dynamic> _body({
    required String name,
    String? description,
    String? phone,
    required String address,
    required double deliveryFee,
    required double minimumOrder,
    required bool isOpen,
  }) {
    return {
      'name': name.trim(),
      'description': description?.trim().isEmpty == true
          ? null
          : description?.trim(),
      'phone': phone?.trim().isEmpty == true ? null : phone?.trim(),
      'address': address.trim(),
      'delivery_fee': deliveryFee,
      'minimum_order': minimumOrder,
      'is_open': isOpen,
    };
  }
}
