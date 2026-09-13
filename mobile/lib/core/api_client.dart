import 'dart:convert';

import 'package:http/http.dart' as http;

import 'api_config.dart';
import 'api_exception.dart';
import 'token_storage.dart';

class ApiClient {
  ApiClient(this._tokenStorage, {http.Client? client})
    : _client = client ?? http.Client();

  final TokenStorage _tokenStorage;
  final http.Client _client;

  Future<Map<String, dynamic>> get(String path, {bool authenticated = false}) {
    return _request('GET', path, authenticated: authenticated);
  }

  Future<Map<String, dynamic>> post(
    String path, {
    Map<String, dynamic>? body,
    bool authenticated = false,
  }) {
    return _request('POST', path, body: body, authenticated: authenticated);
  }

  Future<Map<String, dynamic>> _request(
    String method,
    String path, {
    Map<String, dynamic>? body,
    required bool authenticated,
  }) async {
    final headers = <String, String>{
      'Accept': 'application/json',
      'Content-Type': 'application/json',
    };

    if (authenticated) {
      final token = await _tokenStorage.read();
      if (token != null) headers['Authorization'] = 'Bearer $token';
    }

    final uri = Uri.parse('${ApiConfig.baseUrl}$path');
    final response = method == 'GET'
        ? await _client.get(uri, headers: headers)
        : await _client.post(
            uri,
            headers: headers,
            body: jsonEncode(body ?? {}),
          );

    final decoded = response.body.isEmpty
        ? <String, dynamic>{}
        : jsonDecode(response.body);
    final json = Map<String, dynamic>.from(decoded as Map);

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw ApiException.fromResponse(response.statusCode, json);
    }

    return json;
  }
}
