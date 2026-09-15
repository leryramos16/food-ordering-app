import '../../../core/api_client.dart';
import '../../../core/token_storage.dart';
import '../domain/app_user.dart';

class AuthService {
  AuthService(this._api, this._storage);

  final ApiClient _api;
  final TokenStorage _storage;

  Future<AppUser> register({
    required String name,
    required String email,
    String? phone,
    required String password,
    required String role,
  }) async {
    final response = await _api.post(
      '/auth/register',
      body: {
        'name': name.trim(),
        'email': email.trim(),
        'phone': phone?.trim().isEmpty == true ? null : phone?.trim(),
        'password': password,
        'password_confirmation': password,
        'role': role,
        'device_name': 'food-ordering-mobile',
      },
    );
    return _saveSession(response);
  }

  Future<AppUser> login({
    required String email,
    required String password,
  }) async {
    final response = await _api.post(
      '/auth/login',
      body: {
        'email': email.trim(),
        'password': password,
        'device_name': 'food-ordering-mobile',
      },
    );
    return _saveSession(response);
  }

  Future<AppUser?> restoreSession() async {
    if (await _storage.read() == null) return null;

    try {
      final response = await _api.get('/auth/me', authenticated: true);
      final data = Map<String, dynamic>.from(response['data'] as Map);
      return AppUser.fromJson(Map<String, dynamic>.from(data['user'] as Map));
    } catch (_) {
      await _storage.clear();
      return null;
    }
  }

  Future<void> logout() async {
    try {
      await _api.post('/auth/logout', authenticated: true);
    } finally {
      await _storage.clear();
    }
  }

  Future<AppUser> _saveSession(Map<String, dynamic> response) async {
    final data = Map<String, dynamic>.from(response['data'] as Map);
    await _storage.save(data['token'] as String);
    return AppUser.fromJson(Map<String, dynamic>.from(data['user'] as Map));
  }
}
