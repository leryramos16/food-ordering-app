import '../../../core/api_client.dart';
import '../domain/restaurant.dart';

class RestaurantService {
  RestaurantService(this._api);

  final ApiClient _api;

  Future<List<Restaurant>> getRestaurants() async {
    final response = await _api.get('/restaurants');

    final data = response['data'] as List<dynamic>;

    return data
        .map(
          (item) => Restaurant.fromJson(Map<String, dynamic>.from(item as Map)),
        )
        .toList();
  }
}
