import 'dart:io';
import 'api_service.dart';
import 'api_models.dart';
import '../models/statement.dart';
import '../mock/mock_data.dart';

class UploadService {
  final ApiService _apiService;
  final bool _useMockData;

  UploadService({ApiService? apiService, bool useMockData = false})
      : _apiService = apiService ?? ApiService(),
        _useMockData = useMockData;

  /// Update the auth token on the underlying ApiService
  void setAuthToken(String token) {
    _apiService.setAuthToken(token);
  }

  /// Upload a PDF bank statement file with optional profile metadata
  Future<UploadStatementResponse> uploadStatement({
    required String filePath,
    required String fileName,
    required List<int> fileBytes,
    String? profileName,
    String? profileDescription,
    String? accountType,
    String? bankName,
    String? color,
    String? icon,
  }) async {
    if (_useMockData) {
      // Simulate API delay
      await Future.delayed(const Duration(seconds: 2));

      // Return mock response
      final mockStatements = MockData.getMockStatements();
      if (mockStatements.isNotEmpty) {
        final mockStatement = mockStatements.first;
        return UploadStatementResponse(
          id: mockStatement.id,
          fileName: fileName,
          uploadDate: DateTime.now(),
          status: 'processed',
          transactionCount: mockStatement.transactionCount,
        );
      }

      // Generate new mock statement
      return UploadStatementResponse(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        fileName: fileName,
        uploadDate: DateTime.now(),
        status: 'processed',
        transactionCount: 25,
      );
    }

    // Build additional fields for profile metadata
    final fields = <String, String>{};
    if (profileName != null && profileName.isNotEmpty) {
      fields['profileName'] = profileName;
    }
    if (profileDescription != null && profileDescription.isNotEmpty) {
      fields['profileDescription'] = profileDescription;
    }
    if (accountType != null && accountType.isNotEmpty) {
      fields['accountType'] = accountType;
    }
    if (bankName != null && bankName.isNotEmpty) {
      fields['bankName'] = bankName;
    }
    if (color != null && color.isNotEmpty) {
      fields['color'] = color;
    }
    if (icon != null && icon.isNotEmpty) {
      fields['icon'] = icon;
    }

    // Real API call
    // Backend expects field name "file" for multipart upload
    final response = await _apiService.postMultipart<Map<String, dynamic>>(
      '/statements/upload',
      'file',
      fileBytes,
      fileName,
      (json) => json,
      fields: fields.isNotEmpty ? fields : null,
    );
    
    // Response format from backend: { "success": true, "data": { "id": "...", "fileName": "...", ... } }
    // ApiService._handleResponse() already extracts the "data" field, so response is the statement object directly
    // The backend returns the statement directly in the data field, not nested
    try {
      return UploadStatementResponse.fromJson(response);
    } catch (e) {
      // If parsing fails, try nested format (backward compatibility)
      final statementData = response['statement'] as Map<String, dynamic>?;
      if (statementData != null) {
        return UploadStatementResponse.fromJson(statementData);
      }
      // If still fails, rethrow with more context
      throw ApiError(
        message: 'Failed to parse upload response: $e. Response: $response',
        statusCode: null,
      );
    }
  }

  /// Get list of uploaded statements
  Future<List<BankStatement>> getStatements() async {
    if (_useMockData) {
      await Future.delayed(const Duration(milliseconds: 500));
      return MockData.getMockStatements();
    }

    // Real API call
    final response = await _apiService.get<Map<String, dynamic>>(
      '/statements',
      (json) => json,
    );

    // Response format: { "statements": [...] }
    final statementsList = response['statements'] as List<dynamic>;
    return statementsList.map((json) => BankStatement.fromJson(json as Map<String, dynamic>)).toList();
  }

  /// Get statement details by ID
  Future<BankStatement> getStatement(String statementId) async {
    if (_useMockData) {
      await Future.delayed(const Duration(milliseconds: 300));
      final statements = MockData.getMockStatements();
      return statements.firstWhere(
        (s) => s.id == statementId,
        orElse: () => statements.first,
      );
    }

    // Real API call
    final response = await _apiService.get<Map<String, dynamic>>(
      '/statements/$statementId',
      (json) => json,
    );

    // Response format: { "statement": {...} } or direct statement object
    final statementData = response['statement'] as Map<String, dynamic>? ?? response;
    return BankStatement.fromJson(statementData);
  }

  /// Delete a statement
  Future<void> deleteStatement(String statementId) async {
    if (_useMockData) {
      await Future.delayed(const Duration(milliseconds: 300));
      return;
    }

    // Real API call
    await _apiService.post(
      '/statements/$statementId/delete',
      null,
      (json) => json,
    );
  }

  /// Get list of profiles (simplified for dropdowns)
  Future<List<Map<String, dynamic>>> getProfiles() async {
    if (_useMockData) {
      await Future.delayed(const Duration(milliseconds: 300));
      final statements = MockData.getMockStatements();
      return statements.map((s) => {
        'id': s.id,
        'profileName': s.fileName,
        'isDefault': false,
      }).toList();
    }

    // Real API call
    final response = await _apiService.get<Map<String, dynamic>>(
      '/statements/profiles',
      (json) => json,
    );

    // Response format: { "profiles": [...] }
    final profilesList = response['profiles'] as List<dynamic>? ?? [];
    return profilesList.map((json) => json as Map<String, dynamic>).toList();
  }

  /// Update profile metadata
  Future<BankStatement> updateProfile({
    required String statementId,
    String? profileName,
    String? profileDescription,
    String? accountType,
    String? bankName,
    String? color,
    String? icon,
  }) async {
    if (_useMockData) {
      await Future.delayed(const Duration(milliseconds: 300));
      final statements = MockData.getMockStatements();
      final statement = statements.firstWhere(
        (s) => s.id == statementId,
        orElse: () => statements.first,
      );
      return statement;
    }

    // Build request body
    final body = <String, dynamic>{};
    if (profileName != null) body['profileName'] = profileName;
    if (profileDescription != null) body['profileDescription'] = profileDescription;
    if (accountType != null) body['accountType'] = accountType;
    if (bankName != null) body['bankName'] = bankName;
    if (color != null) body['color'] = color;
    if (icon != null) body['icon'] = icon;

    // Real API call
    final response = await _apiService.put<Map<String, dynamic>>(
      '/statements/$statementId/profile',
      body,
      (json) => json,
    );

    // Response format: { "statement": {...} } or direct statement object
    final statementData = response['statement'] as Map<String, dynamic>? ?? response;
    return BankStatement.fromJson(statementData);
  }

  /// Set a profile as default
  Future<void> setDefaultProfile(String statementId) async {
    if (_useMockData) {
      await Future.delayed(const Duration(milliseconds: 300));
      return;
    }

    // Real API call
    await _apiService.post(
      '/statements/$statementId/set-default',
      null,
      (json) => json,
    );
  }
}

