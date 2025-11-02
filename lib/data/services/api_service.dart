import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_models.dart';

class ApiService {
  // TODO: Replace with actual backend URL
  static const String baseUrl = 'https://api.spendwise.com/api';
  
  final http.Client _client;
  String? _authToken;

  ApiService({http.Client? client}) : _client = client ?? http.Client();

  void setAuthToken(String token) {
    _authToken = token;
  }

  Map<String, String> get _headers {
    final headers = <String, String>{
      'Content-Type': 'application/json',
    };
    if (_authToken != null) {
      headers['Authorization'] = 'Bearer $_authToken';
    }
    return headers;
  }

  Future<T> get<T>(String endpoint, T Function(Map<String, dynamic>) fromJson) async {
    try {
      final response = await _client.get(
        Uri.parse('$baseUrl$endpoint'),
        headers: _headers,
      );
      return _handleResponse(response, fromJson);
    } catch (e) {
      throw ApiError(message: 'Network error: $e');
    }
  }

  Future<T> post<T>(
    String endpoint,
    Map<String, dynamic>? body,
    T Function(Map<String, dynamic>) fromJson,
  ) async {
    try {
      final response = await _client.post(
        Uri.parse('$baseUrl$endpoint'),
        headers: _headers,
        body: body != null ? jsonEncode(body) : null,
      );
      return _handleResponse(response, fromJson);
    } catch (e) {
      throw ApiError(message: 'Network error: $e');
    }
  }

  Future<T> postMultipart<T>(
    String endpoint,
    String fieldName,
    List<int> fileBytes,
    String fileName,
    T Function(Map<String, dynamic>) fromJson,
  ) async {
    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl$endpoint'),
      );

      if (_authToken != null) {
        request.headers['Authorization'] = 'Bearer $_authToken';
      }

      request.files.add(
        http.MultipartFile.fromBytes(
          fieldName,
          fileBytes,
          filename: fileName,
        ),
      );

      final streamedResponse = await _client.send(request);
      final response = await http.Response.fromStream(streamedResponse);

      return _handleResponse(response, fromJson);
    } catch (e) {
      throw ApiError(message: 'Network error: $e');
    }
  }

  T _handleResponse<T>(
    http.Response response,
    T Function(Map<String, dynamic>) fromJson,
  ) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      final json = jsonDecode(response.body) as Map<String, dynamic>;
      return fromJson(json);
    } else {
      try {
        final errorJson = jsonDecode(response.body) as Map<String, dynamic>;
        throw ApiError.fromJson(errorJson);
      } catch (e) {
        throw ApiError(
          message: 'Request failed with status ${response.statusCode}',
          statusCode: response.statusCode,
        );
      }
    }
  }
}

