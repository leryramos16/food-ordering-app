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

  Future<Map<String, dynamic>> put(
    String path, {
    Map<String, dynamic>? body,
    bool authenticated = false,
  }) {
    return _request('PUT', path, body: body, authenticated: authenticated);
  }

  Future<Map<String, dynamic>> delete(String path, {bool authenticated = false}) {
    return _request('DELETE', path, authenticated: authenticated);
  }

  /// Uploads a single file as multipart/form-data under the given field
  /// name (e.g. "image"). Used for photo uploads, where a JSON body isn't
  /// an option.
  Future<Map<String, dynamic>> uploadFile(
    String path, {
    required String fieldName,
    required String filePath,
    bool authenticated = true,
  }) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}$path');
    final request = http.MultipartRequest('POST', uri)
      ..headers['Accept'] = 'application/json';

    if (authenticated) {
      final token = await _tokenStorage.read();
      if (token != null) request.headers['Authorization'] = 'Bearer $token';
    }

    request.files.add(
      await http.MultipartFile.fromPath(fieldName, filePath),
    );

    final streamedResponse = await _client.send(request);
    final response = await http.Response.fromStream(streamedResponse);

    final decoded = response.body.isEmpty
        ? <String, dynamic>{}
        : jsonDecode(response.body);
    final json = Map<String, dynamic>.from(decoded as Map);

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw ApiException.fromResponse(response.statusCode, json);
    }

    return json;
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
    final response = switch (method) {
      'GET' => await _client.get(uri, headers: headers),
      'DELETE' => await _client.delete(uri, headers: headers),
      'PUT' => await _client.put(
        uri,
        headers: headers,
        body: jsonEncode(body ?? {}),
      ),
      _ => await _client.post(
        uri,
        headers: headers,
        body: jsonEncode(body ?? {}),
      ),
    };

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
