import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_models.dart';
import '../../../core/constants/api_constants.dart';

typedef TokenRefreshCallback = Future<String?> Function();

class ApiService {
  
  final http.Client _client;
  String? _authToken;
  TokenRefreshCallback? _tokenRefreshCallback;

  ApiService({http.Client? client, TokenRefreshCallback? tokenRefreshCallback}) 
      : _client = client ?? http.Client(),
        _tokenRefreshCallback = tokenRefreshCallback;

  void setAuthToken(String token) {
    _authToken = token;
  }

  void setTokenRefreshCallback(TokenRefreshCallback callback) {
    _tokenRefreshCallback = callback;
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
        Uri.parse(ApiConstants.buildUrl(endpoint)),
        headers: _headers,
      );
      return await _handleResponseWithRetry(response, fromJson, () => get(endpoint, fromJson));
    } catch (e) {
      if (e is ApiError) rethrow;
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
        Uri.parse(ApiConstants.buildUrl(endpoint)),
        headers: _headers,
        body: body != null ? jsonEncode(body) : null,
      );
      return await _handleResponseWithRetry(response, fromJson, () => post(endpoint, body, fromJson));
    } catch (e) {
      if (e is ApiError) rethrow;
      throw ApiError(message: 'Network error: $e');
    }
  }

  Future<T> put<T>(
    String endpoint,
    Map<String, dynamic>? body,
    T Function(Map<String, dynamic>) fromJson,
  ) async {
    try {
      final response = await _client.put(
        Uri.parse(ApiConstants.buildUrl(endpoint)),
        headers: _headers,
        body: body != null ? jsonEncode(body) : null,
      );
      return await _handleResponseWithRetry(response, fromJson, () => put(endpoint, body, fromJson));
    } catch (e) {
      if (e is ApiError) rethrow;
      throw ApiError(message: 'Network error: $e');
    }
  }

  Future<T> delete<T>(
    String endpoint,
    T Function(Map<String, dynamic>) fromJson,
  ) async {
    try {
      final response = await _client.delete(
        Uri.parse(ApiConstants.buildUrl(endpoint)),
        headers: _headers,
      );
      return await _handleResponseWithRetry(response, fromJson, () => delete(endpoint, fromJson));
    } catch (e) {
      if (e is ApiError) rethrow;
      throw ApiError(message: 'Network error: $e');
    }
  }

  Future<T> postMultipart<T>(
    String endpoint,
    String fieldName,
    List<int> fileBytes,
    String fileName,
    T Function(Map<String, dynamic>) fromJson, {
    Map<String, String>? fields,
  }) async {
    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse(ApiConstants.buildUrl(endpoint)),
      );

      // Set authorization header
      if (_authToken != null) {
        request.headers['Authorization'] = 'Bearer $_authToken';
      }
      
      // DO NOT set Content-Type header for multipart requests
      // The http package will automatically set it with the correct boundary

      // Add file to request
      request.files.add(
        http.MultipartFile.fromBytes(
          fieldName,
          fileBytes,
          filename: fileName,
        ),
      );

      // Add additional fields if provided
      if (fields != null && fields.isNotEmpty) {
        request.fields.addAll(fields);
      }

      final streamedResponse = await _client.send(request);
      final response = await http.Response.fromStream(streamedResponse);

      return await _handleResponseWithRetry(
        response, 
        fromJson, 
        () => postMultipart(endpoint, fieldName, fileBytes, fileName, fromJson, fields: fields),
      );
    } catch (e) {
      if (e is ApiError) rethrow;
      throw ApiError(message: 'Network error: $e');
    }
  }

  Future<T> _handleResponseWithRetry<T>(
    http.Response response,
    T Function(Map<String, dynamic>) fromJson,
    Future<T> Function() retryRequest,
  ) async {
    // Check if we got a 401 TOKEN_EXPIRED error
    if (response.statusCode == 401 && _tokenRefreshCallback != null) {
      try {
        if (response.body.isNotEmpty) {
          final json = jsonDecode(response.body) as Map<String, dynamic>;
          final errorCode = json['error']?['code'] as String? ?? 
                          json['error']?['errorCode'] as String?;
          
          if (errorCode == 'TOKEN_EXPIRED') {
            // Try to refresh token
            final newToken = await _tokenRefreshCallback!();
            if (newToken != null) {
              // Update token and retry request
              _authToken = newToken;
              return await retryRequest();
            }
          }
        } else {
          // Empty body but 401 - might be token expired, try refresh anyway
          final newToken = await _tokenRefreshCallback!();
          if (newToken != null) {
            _authToken = newToken;
            return await retryRequest();
          }
        }
      } catch (e) {
        // If parsing fails, continue with normal error handling
        print('Error parsing 401 response: $e');
      }
    }
    
    // Normal response handling
    return _handleResponse(response, fromJson);
  }

  T _handleResponse<T>(
    http.Response response,
    T Function(Map<String, dynamic>) fromJson,
  ) {
    if (response.body.isEmpty) {
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return fromJson({});
      } else {
        throw ApiError(
          message: 'Request failed with status ${response.statusCode}',
          statusCode: response.statusCode,
        );
      }
    }

    final json = jsonDecode(response.body) as Map<String, dynamic>;
    
    // Check for success field (backend format)
    if (json.containsKey('success')) {
      final success = json['success'] as bool? ?? false;
      
      if (!success) {
        // Handle error response: { "success": false, "error": {...} }
        if (json.containsKey('error')) {
          final errorData = json['error'] as Map<String, dynamic>;
          throw ApiError(
            message: errorData['message'] as String? ?? 'An error occurred',
            statusCode: errorData['statusCode'] as int? ?? response.statusCode,
            errorCode: errorData['code'] as String? ?? errorData['errorCode'] as String?,
          );
        } else {
          throw ApiError(
            message: 'Request failed',
            statusCode: response.statusCode,
          );
        }
      }
      
      // Success response: extract data field
      if (json.containsKey('data')) {
        final data = json['data'];
        // Data can be Map, List, or other types
        if (data is Map<String, dynamic>) {
          return fromJson(data);
        } else if (data is List) {
          // For endpoints that return arrays directly in data field
          // Wrap in a map so fromJson can process it
          return fromJson({'items': data} as Map<String, dynamic>);
        } else {
          // For primitive types or other structures
          return fromJson({'value': data} as Map<String, dynamic>);
        }
      } else {
        // Some endpoints might return data directly
        return fromJson(json);
      }
    }
    
    // Handle non-standard responses (backward compatibility)
    if (response.statusCode >= 200 && response.statusCode < 300) {
      // Check if response has error field (old format)
      if (json.containsKey('error')) {
        final errorData = json['error'] as Map<String, dynamic>;
        throw ApiError(
          message: errorData['message'] as String? ?? 'An error occurred',
          statusCode: errorData['statusCode'] as int? ?? response.statusCode,
          errorCode: errorData['code'] as String? ?? errorData['errorCode'] as String?,
        );
      }
      return fromJson(json);
    } else {
      // Error response
      if (json.containsKey('error')) {
        final errorData = json['error'] as Map<String, dynamic>;
        throw ApiError(
          message: errorData['message'] as String? ?? 'An error occurred',
          statusCode: errorData['statusCode'] as int? ?? response.statusCode,
          errorCode: errorData['code'] as String? ?? errorData['errorCode'] as String?,
        );
      } else {
        throw ApiError(
          message: 'Request failed with status ${response.statusCode}',
          statusCode: response.statusCode,
        );
      }
    }
  }
}

