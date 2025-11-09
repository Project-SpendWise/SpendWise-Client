import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/models/user.dart';
import '../data/services/auth_service.dart';
import '../data/services/api_models.dart';

class AuthState {
  final User? user;
  final String? accessToken;
  final String? refreshToken;
  final bool isLoading;
  final String? error;

  AuthState({
    this.user,
    this.accessToken,
    this.refreshToken,
    this.isLoading = false,
    this.error,
  });

  bool get isAuthenticated => user != null && accessToken != null;

  AuthState copyWith({
    User? user,
    String? accessToken,
    String? refreshToken,
    bool? isLoading,
    String? error,
  }) {
    return AuthState(
      user: user ?? this.user,
      accessToken: accessToken ?? this.accessToken,
      refreshToken: refreshToken ?? this.refreshToken,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthService _authService;
  static const String _accessTokenKey = 'access_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _userKey = 'user_data';

  AuthNotifier(this._authService) : super(AuthState()) {
    _loadAuthState();
  }

  Future<void> _loadAuthState() async {
    try {
      state = state.copyWith(isLoading: true);
      final prefs = await SharedPreferences.getInstance();
      final accessToken = prefs.getString(_accessTokenKey);
      final refreshToken = prefs.getString(_refreshTokenKey);
      final userJson = prefs.getString(_userKey);

      if (accessToken != null && userJson != null) {
        try {
          // Restore user from stored JSON
          final userMap = jsonDecode(userJson) as Map<String, dynamic>;
          final user = User.fromJson(userMap);
          
          // Try to validate token by getting current user from backend
          try {
            final currentUser = await _authService.getCurrentUser(accessToken);
            state = AuthState(
              user: currentUser,
              accessToken: accessToken,
              refreshToken: refreshToken,
            );
          } catch (e) {
            // Token might be expired, try to refresh
            if (refreshToken != null) {
              try {
                final result = await _authService.refreshToken(refreshToken);
                await _saveAuthState(result);
                state = AuthState(
                  user: result.user,
                  accessToken: result.accessToken,
                  refreshToken: result.refreshToken,
                );
              } catch (refreshError) {
                // Both tokens are invalid, use stored user for now
                // User will be logged out on next API call
                state = AuthState(
                  user: user,
                  accessToken: accessToken,
                  refreshToken: refreshToken,
                );
              }
            } else {
              // No refresh token, use stored user
              state = AuthState(
                user: user,
                accessToken: accessToken,
                refreshToken: refreshToken,
              );
            }
          }
        } catch (e) {
          // If parsing fails, clear stored data
          await prefs.remove(_accessTokenKey);
          await prefs.remove(_refreshTokenKey);
          await prefs.remove(_userKey);
        }
      }
    } catch (e) {
      state = AuthState(error: e.toString());
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  Future<void> _saveAuthState(AuthResult result) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_accessTokenKey, result.accessToken);
    if (result.refreshToken.isNotEmpty) {
      await prefs.setString(_refreshTokenKey, result.refreshToken);
    }
    await prefs.setString(_userKey, jsonEncode(result.user.toJson()));
  }

  Future<bool> login(String email, String password) async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      
      final result = await _authService.login(email: email, password: password);
      await _saveAuthState(result);
      
      state = AuthState(
        user: result.user,
        accessToken: result.accessToken,
        refreshToken: result.refreshToken,
      );
      return true;
    } on ApiError catch (e) {
      state = state.copyWith(error: e.message);
      return false;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  Future<bool> register({
    required String email,
    required String password,
    String? username,
    String? firstName,
    String? lastName,
  }) async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      
      final result = await _authService.register(
        email: email,
        password: password,
        username: username,
        firstName: firstName,
        lastName: lastName,
      );
      await _saveAuthState(result);
      
      state = AuthState(
        user: result.user,
        accessToken: result.accessToken,
        refreshToken: result.refreshToken,
      );
      return true;
    } on ApiError catch (e) {
      state = state.copyWith(error: e.message);
      return false;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  Future<bool> refreshAccessToken() async {
    try {
      if (state.refreshToken == null) {
        return false;
      }

      final result = await _authService.refreshToken(state.refreshToken!);
      await _saveAuthState(result);
      
      state = state.copyWith(
        user: result.user,
        accessToken: result.accessToken,
        refreshToken: result.refreshToken,
      );
      return true;
    } catch (e) {
      // Refresh failed, logout user
      await logout();
      return false;
    }
  }

  Future<User?> getCurrentUser() async {
    try {
      if (state.accessToken == null) {
        return null;
      }

      final user = await _authService.getCurrentUser(state.accessToken!);
      state = state.copyWith(user: user);
      return user;
    } catch (e) {
      // If getting user fails, try to refresh token
      if (await refreshAccessToken()) {
        return await getCurrentUser();
      }
      return null;
    }
  }

  Future<bool> updateProfile({
    String? username,
    String? firstName,
    String? lastName,
  }) async {
    try {
      if (state.accessToken == null) {
        state = state.copyWith(error: 'Not authenticated');
        return false;
      }

      state = state.copyWith(isLoading: true, error: null);
      
      final user = await _authService.updateProfile(
        accessToken: state.accessToken!,
        username: username,
        firstName: firstName,
        lastName: lastName,
      );
      
      // Update stored user data
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_userKey, jsonEncode(user.toJson()));
      
      state = state.copyWith(user: user);
      return true;
    } on ApiError catch (e) {
      state = state.copyWith(error: e.message);
      return false;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  Future<bool> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      if (state.accessToken == null) {
        state = state.copyWith(error: 'Not authenticated');
        return false;
      }

      state = state.copyWith(isLoading: true, error: null);
      
      await _authService.changePassword(
        accessToken: state.accessToken!,
        currentPassword: currentPassword,
        newPassword: newPassword,
      );
      
      return true;
    } on ApiError catch (e) {
      state = state.copyWith(error: e.message);
      return false;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  Future<void> logout() async {
    try {
      if (state.accessToken != null) {
        await _authService.logout(state.accessToken!);
      }
    } catch (e) {
      // Even if logout fails, clear local state
    } finally {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_accessTokenKey);
      await prefs.remove(_refreshTokenKey);
      await prefs.remove(_userKey);
      
      state = AuthState();
    }
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(AuthService());
});
