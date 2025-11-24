import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/statement.dart';
import '../data/services/upload_service.dart';
import '../data/services/api_service.dart';
import 'auth_provider.dart';
import 'profile_provider.dart';

enum UploadStatus { idle, uploading, processing, success, error }

class UploadState {
  final UploadStatus status;
  final double? progress;
  final String? errorMessage;
  final List<BankStatement> statements;

  UploadState({
    this.status = UploadStatus.idle,
    this.progress,
    this.errorMessage,
    List<BankStatement>? statements,
  }) : statements = statements ?? [];

  UploadState copyWith({
    UploadStatus? status,
    double? progress,
    String? errorMessage,
    List<BankStatement>? statements,
  }) {
    return UploadState(
      status: status ?? this.status,
      progress: progress ?? this.progress,
      errorMessage: errorMessage ?? this.errorMessage,
      statements: statements ?? this.statements,
    );
  }
}

class UploadNotifier extends StateNotifier<UploadState> {
  final UploadService _uploadService;

  UploadNotifier(this._uploadService) : super(UploadState()) {
    loadStatements();
  }

  /// Load statements from backend
  Future<void> loadStatements() async {
    try {
      final statements = await _uploadService.getStatements();
      state = state.copyWith(statements: statements);
    } catch (e) {
      // If loading fails, continue with empty list
      print('Failed to load statements: $e');
    }
  }

  Future<void> uploadFile(
    String filePath,
    String fileName, {
    String? profileName,
    String? profileDescription,
    String? accountType,
    String? bankName,
    String? color,
    String? icon,
  }) async {
    state = state.copyWith(
      status: UploadStatus.uploading,
      progress: 0.0,
      errorMessage: null,
    );

    try {
      // Read file bytes
      final file = File(filePath);
      final fileBytes = await file.readAsBytes();

      // Simulate upload progress
      for (double i = 0; i <= 0.9; i += 0.1) {
        await Future.delayed(const Duration(milliseconds: 100));
        if (state.status == UploadStatus.uploading) {
          state = state.copyWith(progress: i);
        }
      }

      // Upload statement
      state = state.copyWith(
        status: UploadStatus.processing,
        progress: 0.9,
      );

      final response = await _uploadService.uploadStatement(
        filePath: filePath,
        fileName: fileName,
        fileBytes: fileBytes,
        profileName: profileName,
        profileDescription: profileDescription,
        accountType: accountType,
        bankName: bankName,
        color: color,
        icon: icon,
      );

      // Get full statement details to include profile fields
      final fullStatement = await _uploadService.getStatement(response.id);
      
      // Use the full statement which includes all profile fields
      final statement = fullStatement;

      // Add statement to list immediately
      state = state.copyWith(
        statements: [...state.statements, statement],
      );

      // Poll for processing status if still processing
      if (response.status == 'processing') {
        await _pollForProcessingStatus(response.id);
      } else {
        // Already processed, reload statements to get latest data
        await loadStatements();
        state = state.copyWith(
          status: UploadStatus.success,
          progress: null,
        );
      }
    } catch (e) {
      print('Upload error: $e');
      state = state.copyWith(
        status: UploadStatus.error,
        errorMessage: e.toString(),
        progress: null,
      );
    }
  }

  /// Poll for processing status until statement is processed
  Future<void> _pollForProcessingStatus(String statementId) async {
    const maxAttempts = 30; // Poll for up to 30 seconds
    int attempts = 0;

    while (attempts < maxAttempts) {
      await Future.delayed(const Duration(seconds: 2)); // Poll every 2 seconds
      attempts++;

      try {
        // Get statement details directly
        final statement = await _uploadService.getStatement(statementId);

        if (statement.isProcessed) {
          // Reload all statements to get the latest list
          await loadStatements();
          
          // Get the updated statement from the list
          final updatedStatements = state.statements;
          final updatedStatement = updatedStatements.firstWhere(
            (s) => s.id == statementId,
            orElse: () => statement,
          );
          
          state = state.copyWith(
            status: UploadStatus.success,
            statements: updatedStatements,
            progress: null,
          );
          
          print('Statement $statementId processed successfully with ${updatedStatement.transactionCount} transactions');
          return;
        }
      } catch (e) {
        // Continue polling on error
        print('Error polling for status: $e');
      }
    }

    // Timeout - mark as error
    state = state.copyWith(
      status: UploadStatus.error,
      errorMessage: 'Processing timeout',
      progress: null,
    );
  }

  void resetStatus() {
    state = state.copyWith(
      status: UploadStatus.idle,
      errorMessage: null,
      progress: null,
    );
  }

  Future<void> removeStatement(String id) async {
    try {
      await _uploadService.deleteStatement(id);
      state = state.copyWith(
        statements: state.statements.where((s) => s.id != id).toList(),
      );
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
    }
  }
}

final uploadProvider =
    StateNotifierProvider<UploadNotifier, UploadState>((ref) {
  // Only watch auth state to get token, don't recreate provider on every change
  final authState = ref.read(authProvider);
  final apiService = ApiService();
  
  if (authState.accessToken != null) {
    apiService.setAuthToken(authState.accessToken!);
  }
  
  // Set token refresh callback to automatically refresh tokens on 401 errors
  apiService.setTokenRefreshCallback(() async {
    final authNotifier = ref.read(authProvider.notifier);
    final refreshed = await authNotifier.refreshAccessToken();
    if (refreshed) {
      final newAuthState = ref.read(authProvider);
      return newAuthState.accessToken;
    }
    return null;
  });
  
  final uploadService = UploadService(apiService: apiService);
  return UploadNotifier(uploadService);
});

