import 'dart:io';
import 'api_service.dart';
import 'api_models.dart';
import '../models/statement.dart';
import '../mock/mock_data.dart';

class UploadService {
  final ApiService _apiService;
  final bool _useMockData;

  UploadService({ApiService? apiService, bool useMockData = true})
      : _apiService = apiService ?? ApiService(),
        _useMockData = useMockData;

  /// Upload a PDF bank statement file
  Future<UploadStatementResponse> uploadStatement({
    required String filePath,
    required String fileName,
    required List<int> fileBytes,
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

    // Real API call
    return await _apiService.postMultipart<UploadStatementResponse>(
      '/statements/upload',
      'file',
      fileBytes,
      fileName,
      (json) => UploadStatementResponse.fromJson(json),
    );
  }

  /// Get list of uploaded statements
  Future<List<BankStatement>> getStatements() async {
    if (_useMockData) {
      await Future.delayed(const Duration(milliseconds: 500));
      return MockData.getMockStatements();
    }

    // Real API call would go here
    // final response = await _apiService.get('/statements', ...);
    throw UnimplementedError('Real API not implemented yet');
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
}

