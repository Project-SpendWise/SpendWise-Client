import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/statement.dart';

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
  UploadNotifier() : super(UploadState());

  Future<void> uploadFile(String filePath, String fileName) async {
    state = state.copyWith(
      status: UploadStatus.uploading,
      progress: 0.0,
    );

    try {
      // Simulate upload progress
      for (double i = 0; i <= 1.0; i += 0.1) {
        await Future.delayed(const Duration(milliseconds: 100));
        state = state.copyWith(progress: i);
      }

      // Simulate processing
      state = state.copyWith(status: UploadStatus.processing);
      await Future.delayed(const Duration(seconds: 1));

      final statement = BankStatement(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        uploadDate: DateTime.now(),
        fileName: fileName,
        filePath: filePath,
        transactionCount: 0,
        isProcessed: false,
      );

      state = state.copyWith(
        status: UploadStatus.success,
        statements: [...state.statements, statement],
        progress: null,
      );
    } catch (e) {
      state = state.copyWith(
        status: UploadStatus.error,
        errorMessage: e.toString(),
        progress: null,
      );
    }
  }

  void resetStatus() {
    state = state.copyWith(
      status: UploadStatus.idle,
      errorMessage: null,
      progress: null,
    );
  }

  void removeStatement(String id) {
    state = state.copyWith(
      statements: state.statements.where((s) => s.id != id).toList(),
    );
  }
}

final uploadProvider =
    StateNotifierProvider<UploadNotifier, UploadState>((ref) {
  return UploadNotifier();
});

