/// API Request and Response Models

class UploadStatementRequest {
  final String fileName;
  final String filePath;
  final List<int> fileBytes;

  UploadStatementRequest({
    required this.fileName,
    required this.filePath,
    required this.fileBytes,
  });

  Map<String, dynamic> toJson() {
    return {
      'fileName': fileName,
      'filePath': filePath,
    };
  }
}

class UploadStatementResponse {
  final String id;
  final String fileName;
  final DateTime uploadDate;
  final String status;
  final int? transactionCount;

  UploadStatementResponse({
    required this.id,
    required this.fileName,
    required this.uploadDate,
    required this.status,
    this.transactionCount,
  });

  factory UploadStatementResponse.fromJson(Map<String, dynamic> json) {
    return UploadStatementResponse(
      id: json['id'] as String,
      fileName: json['fileName'] as String,
      uploadDate: DateTime.parse(json['uploadDate'] as String),
      status: json['status'] as String,
      transactionCount: json['transactionCount'] as int?,
    );
  }
}

class TransactionResponse {
  final String id;
  final DateTime date;
  final String description;
  final double amount;
  final String type;
  final String? category;
  final String? merchant;
  final String? account;
  final String? referenceNumber;

  TransactionResponse({
    required this.id,
    required this.date,
    required this.description,
    required this.amount,
    required this.type,
    this.category,
    this.merchant,
    this.account,
    this.referenceNumber,
  });

  factory TransactionResponse.fromJson(Map<String, dynamic> json) {
    return TransactionResponse(
      id: json['id'] as String,
      date: DateTime.parse(json['date'] as String),
      description: json['description'] as String,
      amount: (json['amount'] as num).toDouble(),
      type: json['type'] as String,
      category: json['category'] as String?,
      merchant: json['merchant'] as String?,
      account: json['account'] as String?,
      referenceNumber: json['referenceNumber'] as String?,
    );
  }
}

class CategoryBreakdownResponse {
  final String category;
  final double totalAmount;
  final double percentage;
  final int transactionCount;

  CategoryBreakdownResponse({
    required this.category,
    required this.totalAmount,
    required this.percentage,
    required this.transactionCount,
  });

  factory CategoryBreakdownResponse.fromJson(Map<String, dynamic> json) {
    return CategoryBreakdownResponse(
      category: json['category'] as String,
      totalAmount: (json['totalAmount'] as num).toDouble(),
      percentage: (json['percentage'] as num).toDouble(),
      transactionCount: json['transactionCount'] as int,
    );
  }
}

class SpendingTrendsResponse {
  final DateTime date;
  final double totalAmount;
  final int transactionCount;

  SpendingTrendsResponse({
    required this.date,
    required this.totalAmount,
    required this.transactionCount,
  });

  factory SpendingTrendsResponse.fromJson(Map<String, dynamic> json) {
    return SpendingTrendsResponse(
      date: DateTime.parse(json['date'] as String),
      totalAmount: (json['totalAmount'] as num).toDouble(),
      transactionCount: json['transactionCount'] as int,
    );
  }
}

class FinancialInsight {
  final String type;
  final String title;
  final String message;
  final String severity; // 'info', 'warning', 'error', 'success'

  FinancialInsight({
    required this.type,
    required this.title,
    required this.message,
    required this.severity,
  });

  factory FinancialInsight.fromJson(Map<String, dynamic> json) {
    return FinancialInsight(
      type: json['type'] as String,
      title: json['title'] as String,
      message: json['message'] as String,
      severity: json['severity'] as String,
    );
  }
}

class ApiError implements Exception {
  final String message;
  final int? statusCode;
  final String? errorCode;

  ApiError({
    required this.message,
    this.statusCode,
    this.errorCode,
  });

  factory ApiError.fromJson(Map<String, dynamic> json) {
    return ApiError(
      message: json['message'] as String,
      statusCode: json['statusCode'] as int?,
      errorCode: json['errorCode'] as String?,
    );
  }

  @override
  String toString() {
    if (statusCode != null && errorCode != null) {
      return '$message (Status: $statusCode, Code: $errorCode)';
    } else if (statusCode != null) {
      return '$message (Status: $statusCode)';
    }
    return message;
  }
}

