import '../../../core/api_client.dart';

class PaymentService {
  PaymentService(this._api);

  final ApiClient _api;

  /// Asks the backend for the Dragonpay redirect URL for this order, so the
  /// app can open it in a WebView and let the customer pay via GCash.
  Future<String> initiate(int orderId) async {
    final response = await _api.post(
      '/orders/$orderId/payment',
      authenticated: true,
    );

    final data = Map<String, dynamic>.from(response['data'] as Map);
    return data['redirect_url'] as String;
  }
}
