class FileModel {
  final String id;
  final String userId;
  final String originalFilename;
  final String storedFilename;
  final String filePath;
  final String fileType;
  final String mimeType;
  final int fileSize;
  final String fileHash;
  final String processingStatus;
  final String? description;
  final DateTime createdAt;
  final DateTime updatedAt;

  FileModel({
    required this.id,
    required this.userId,
    required this.originalFilename,
    required this.storedFilename,
    required this.filePath,
    required this.fileType,
    required this.mimeType,
    required this.fileSize,
    required this.fileHash,
    required this.processingStatus,
    this.description,
    required this.createdAt,
    required this.updatedAt,
  });

  factory FileModel.fromJson(Map<String, dynamic> json) {
    return FileModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      originalFilename: json['original_filename'] as String,
      storedFilename: json['stored_filename'] as String,
      filePath: json['file_path'] as String,
      fileType: json['file_type'] as String,
      mimeType: json['mime_type'] as String,
      fileSize: json['file_size'] as int,
      fileHash: json['file_hash'] as String,
      processingStatus: json['processing_status'] as String,
      description: json['description'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'original_filename': originalFilename,
      'stored_filename': storedFilename,
      'file_path': filePath,
      'file_type': fileType,
      'mime_type': mimeType,
      'file_size': fileSize,
      'file_hash': fileHash,
      'processing_status': processingStatus,
      'description': description,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  // Helper to format file size
  String get formattedSize {
    if (fileSize < 1024) {
      return '$fileSize B';
    } else if (fileSize < 1024 * 1024) {
      return '${(fileSize / 1024).toStringAsFixed(1)} KB';
    } else {
      return '${(fileSize / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
  }

  // Helper to check if file is processed
  bool get isProcessed => processingStatus == 'completed';
  bool get isProcessing => processingStatus == 'processing';
  bool get isPending => processingStatus == 'pending';
  bool get hasFailed => processingStatus == 'failed';
}

class FileListResponse {
  final List<FileModel> files;
  final PaginationInfo pagination;

  FileListResponse({
    required this.files,
    required this.pagination,
  });

  factory FileListResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>;
    final filesList = data['files'] as List<dynamic>;
    final paginationData = data['pagination'] as Map<String, dynamic>;

    return FileListResponse(
      files: filesList.map((f) => FileModel.fromJson(f as Map<String, dynamic>)).toList(),
      pagination: PaginationInfo.fromJson(paginationData),
    );
  }
}

class PaginationInfo {
  final int page;
  final int perPage;
  final int total;
  final int pages;

  PaginationInfo({
    required this.page,
    required this.perPage,
    required this.total,
    required this.pages,
  });

  factory PaginationInfo.fromJson(Map<String, dynamic> json) {
    return PaginationInfo(
      page: json['page'] as int,
      perPage: json['per_page'] as int,
      total: json['total'] as int,
      pages: json['pages'] as int,
    );
  }

  bool get hasNextPage => page < pages;
  bool get hasPreviousPage => page > 1;
}

