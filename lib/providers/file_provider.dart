import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/file_model.dart';
import '../data/services/file_service.dart';
import 'auth_provider.dart';

class FileListState {
  final List<FileModel> files;
  final PaginationInfo? pagination;
  final bool isLoading;
  final String? error;
  final String? fileTypeFilter;
  final int currentPage;

  FileListState({
    this.files = const [],
    this.pagination,
    this.isLoading = false,
    this.error,
    this.fileTypeFilter,
    this.currentPage = 1,
  });

  FileListState copyWith({
    List<FileModel>? files,
    PaginationInfo? pagination,
    bool? isLoading,
    String? error,
    String? fileTypeFilter,
    int? currentPage,
  }) {
    return FileListState(
      files: files ?? this.files,
      pagination: pagination ?? this.pagination,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      fileTypeFilter: fileTypeFilter ?? this.fileTypeFilter,
      currentPage: currentPage ?? this.currentPage,
    );
  }
}

class FileListNotifier extends StateNotifier<FileListState> {
  final FileService _fileService;
  final Ref _ref;

  FileListNotifier(this._fileService, this._ref) : super(FileListState()) {
    // Only load files if user is authenticated
    final isAuthenticated = _ref.read(authProvider).isAuthenticated;
    if (isAuthenticated) {
      loadFiles();
    }
  }

  Future<void> loadFiles({String? fileType, int? page}) async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      
      final accessToken = _ref.read(authProvider).accessToken;
      if (accessToken == null) {
        state = state.copyWith(
          isLoading: false,
          error: 'Not authenticated',
        );
        return;
      }

      _fileService.setAuthToken(accessToken);
      
      final response = await _fileService.getFiles(
        fileType: fileType ?? state.fileTypeFilter,
        page: page ?? state.currentPage,
        perPage: 20,
      );

      state = state.copyWith(
        files: response.files,
        pagination: response.pagination,
        isLoading: false,
        fileTypeFilter: fileType ?? state.fileTypeFilter,
        currentPage: page ?? state.currentPage,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> refresh() async {
    await loadFiles();
  }

  Future<void> setFileTypeFilter(String? fileType) async {
    await loadFiles(fileType: fileType, page: 1);
  }

  Future<void> nextPage() async {
    if (state.pagination?.hasNextPage == true) {
      await loadFiles(page: state.currentPage + 1);
    }
  }

  Future<void> previousPage() async {
    if (state.pagination?.hasPreviousPage == true) {
      await loadFiles(page: state.currentPage - 1);
    }
  }

  Future<FileModel?> uploadFile({
    required String filePath,
    required String fileName,
    required List<int> fileBytes,
    String? description,
  }) async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      
      final accessToken = _ref.read(authProvider).accessToken;
      if (accessToken == null) {
        state = state.copyWith(
          isLoading: false,
          error: 'Not authenticated',
        );
        return null;
      }

      _fileService.setAuthToken(accessToken);
      
      final file = await _fileService.uploadFile(
        filePath: filePath,
        fileName: fileName,
        fileBytes: fileBytes,
        description: description,
      );

      // Refresh file list
      await loadFiles();
      
      return file;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      return null;
    }
  }

  Future<bool> deleteFile(String fileId) async {
    try {
      final accessToken = _ref.read(authProvider).accessToken;
      if (accessToken == null) {
        state = state.copyWith(error: 'Not authenticated');
        return false;
      }

      _fileService.setAuthToken(accessToken);
      await _fileService.deleteFile(fileId);

      // Refresh file list
      await loadFiles();
      
      return true;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }

  Future<List<int>?> downloadFile(String fileId) async {
    try {
      final accessToken = _ref.read(authProvider).accessToken;
      if (accessToken == null) {
        return null;
      }

      _fileService.setAuthToken(accessToken);
      return await _fileService.downloadFile(fileId);
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return null;
    }
  }
}

final fileServiceProvider = Provider<FileService>((ref) {
  return FileService();
});

final fileListProvider = StateNotifierProvider<FileListNotifier, FileListState>((ref) {
  final fileService = ref.watch(fileServiceProvider);
  return FileListNotifier(fileService, ref);
});

