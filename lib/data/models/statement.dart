class BankStatement {
  final String id;
  final DateTime uploadDate;
  final String fileName;
  final String filePath;
  final DateTime? statementPeriodStart;
  final DateTime? statementPeriodEnd;
  final int transactionCount;
  final bool isProcessed;

  BankStatement({
    required this.id,
    required this.uploadDate,
    required this.fileName,
    required this.filePath,
    this.statementPeriodStart,
    this.statementPeriodEnd,
    this.transactionCount = 0,
    this.isProcessed = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'uploadDate': uploadDate.toIso8601String(),
      'fileName': fileName,
      'filePath': filePath,
      'statementPeriodStart': statementPeriodStart?.toIso8601String(),
      'statementPeriodEnd': statementPeriodEnd?.toIso8601String(),
      'transactionCount': transactionCount,
      'isProcessed': isProcessed,
    };
  }

  factory BankStatement.fromJson(Map<String, dynamic> json) {
    return BankStatement(
      id: json['id'] as String,
      uploadDate: DateTime.parse(json['uploadDate'] as String),
      fileName: json['fileName'] as String,
      filePath: json['filePath'] as String,
      statementPeriodStart: json['statementPeriodStart'] != null
          ? DateTime.parse(json['statementPeriodStart'] as String)
          : null,
      statementPeriodEnd: json['statementPeriodEnd'] != null
          ? DateTime.parse(json['statementPeriodEnd'] as String)
          : null,
      transactionCount: json['transactionCount'] as int? ?? 0,
      isProcessed: json['isProcessed'] as bool? ?? false,
    );
  }
}

