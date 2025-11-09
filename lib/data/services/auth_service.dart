import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user.dart';
import 'api_models.dart';
import 'api_service.dart';
import '../../../core/constants/api_constants.dart';

class AuthResult {
  final User user;
  final String accessToken;
  final String refreshToken;

  AuthResult({
    required this.user,
    required this.accessToken,
    required this.refreshToken,
  });
}

class AuthService {
  final ApiService _apiService;

  AuthService({ApiService? apiService}) : _apiService = apiService ?? ApiService();

  /// Register a new user
  Future<AuthResult> register({
    required String email,
    required String password,
    String? username,
    String? firstName,
    String? lastName,
  }) async {
    final body = <String, dynamic>{
      'email': email,
      'password': password,
    };

    if (username != null && username.isNotEmpty) {
      body['username'] = username;
    }
    if (firstName != null && firstName.isNotEmpty) {
      body['first_name'] = firstName;
    }
    if (lastName != null && lastName.isNotEmpty) {
      body['last_name'] = lastName;
    }

      final response = await http.post(
        Uri.parse(ApiConstants.buildUrl(ApiConstants.authRegister)),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );

    if (response.statusCode == 201) {
      final json = jsonDecode(response.body) as Map<String, dynamic>;
      final data = json['data'] as Map<String, dynamic>;
      final userJson = data['user'] as Map<String, dynamic>;
      
      final user = User.fromJson(userJson);
      
      // For registration, we need to login to get tokens
      // Or the backend might return tokens in registration response
      // For now, we'll login after registration
      return await login(email: email, password: password);
    } else {
      final errorJson = jsonDecode(response.body) as Map<String, dynamic>;
      if (errorJson.containsKey('error')) {
        final errorData = errorJson['error'] as Map<String, dynamic>;
        throw ApiError(
          message: errorData['message'] as String? ?? 'Registration failed',
          statusCode: response.statusCode,
          errorCode: errorData['errorCode'] as String?,
        );
      }
      throw ApiError(
        message: 'Registration failed',
        statusCode: response.statusCode,
      );
    }
  }

  /// Login user
  Future<AuthResult> login({
    required String email,
    required String password,
  }) async {
      final response = await http.post(
        Uri.parse(ApiConstants.buildUrl(ApiConstants.authLogin)),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'password': password,
      }),
    );

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body) as Map<String, dynamic>;
      final data = json['data'] as Map<String, dynamic>;
      
      final accessToken = data['access_token'] as String;
      final refreshToken = data['refresh_token'] as String;
      final userJson = data['user'] as Map<String, dynamic>;
      
      final user = User.fromJson(userJson);
      
      return AuthResult(
        user: user,
        accessToken: accessToken,
        refreshToken: refreshToken,
      );
    } else {
      final errorJson = jsonDecode(response.body) as Map<String, dynamic>;
      if (errorJson.containsKey('error')) {
        final errorData = errorJson['error'] as Map<String, dynamic>;
        throw ApiError(
          message: errorData['message'] as String? ?? 'Login failed',
          statusCode: response.statusCode,
          errorCode: errorData['errorCode'] as String?,
        );
      }
      throw ApiError(
        message: 'Login failed',
        statusCode: response.statusCode,
      );
    }
  }

  /// Get current user profile
  Future<User> getCurrentUser(String accessToken) async {
    _apiService.setAuthToken(accessToken);
    
    final json = await _apiService.get<Map<String, dynamic>>(
      ApiConstants.authMe,
      (json) => json,
    );

    final data = json['data'] as Map<String, dynamic>;
    final userJson = data['user'] as Map<String, dynamic>;
    
    return User.fromJson(userJson);
  }

  /// Update user profile
  Future<User> updateProfile({
    required String accessToken,
    String? username,
    String? firstName,
    String? lastName,
  }) async {
    _apiService.setAuthToken(accessToken);
    
    final body = <String, dynamic>{};
    if (username != null && username.isNotEmpty) {
      body['username'] = username;
    }
    if (firstName != null && firstName.isNotEmpty) {
      body['first_name'] = firstName;
    }
    if (lastName != null && lastName.isNotEmpty) {
      body['last_name'] = lastName;
    }

    final json = await _apiService.put<Map<String, dynamic>>(
      ApiConstants.authMe,
      body.isNotEmpty ? body : null,
      (json) => json,
    );

    final data = json['data'] as Map<String, dynamic>;
    final userJson = data['user'] as Map<String, dynamic>;
    
    return User.fromJson(userJson);
  }

  /// Change password
  Future<void> changePassword({
    required String accessToken,
    required String currentPassword,
    required String newPassword,
  }) async {
    _apiService.setAuthToken(accessToken);
    
    await _apiService.post<Map<String, dynamic>>(
      ApiConstants.authChangePassword,
      {
        'current_password': currentPassword,
        'new_password': newPassword,
      },
      (json) => json,
    );
  }

  /// Refresh access token
  Future<AuthResult> refreshToken(String refreshToken) async {
    final response = await http.post(
      Uri.parse(ApiConstants.buildUrl(ApiConstants.authRefresh)),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $refreshToken',
      },
    );

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body) as Map<String, dynamic>;
      final data = json['data'] as Map<String, dynamic>;
      
      final accessToken = data['access_token'] as String;
      final newRefreshToken = data['refresh_token'] as String;
      
      // Get user info with new token
      _apiService.setAuthToken(accessToken);
      final user = await getCurrentUser(accessToken);
      
      return AuthResult(
        user: user,
        accessToken: accessToken,
        refreshToken: newRefreshToken,
      );
    } else {
      final errorJson = jsonDecode(response.body) as Map<String, dynamic>;
      if (errorJson.containsKey('error')) {
        final errorData = errorJson['error'] as Map<String, dynamic>;
        throw ApiError(
          message: errorData['message'] as String? ?? 'Token refresh failed',
          statusCode: response.statusCode,
          errorCode: errorData['errorCode'] as String?,
        );
      }
      throw ApiError(
        message: 'Token refresh failed',
        statusCode: response.statusCode,
      );
    }
  }

  /// Logout
  Future<void> logout(String accessToken) async {
    try {
      _apiService.setAuthToken(accessToken);
      await _apiService.post<Map<String, dynamic>>(
        ApiConstants.authLogout,
        null,
        (json) => json,
      );
    } catch (e) {
      // Even if logout fails on backend, we should still clear local state
      // So we don't throw here
    }
  }
}
