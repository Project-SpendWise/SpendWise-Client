class BankStatement {
  final String id;
  final DateTime uploadDate;
  final String fileName;
  final String? filePath;
  final DateTime? statementPeriodStart;
  final DateTime? statementPeriodEnd;
  final int transactionCount;
  final bool isProcessed;
  
  // Profile fields
  final String? profileName;
  final String? profileDescription;
  final String? accountType;
  final String? bankName;
  final String? color;
  final String? icon;
  final bool isDefault;

  BankStatement({
    required this.id,
    required this.uploadDate,
    required this.fileName,
    this.filePath,
    this.statementPeriodStart,
    this.statementPeriodEnd,
    this.transactionCount = 0,
    this.isProcessed = false,
    this.profileName,
    this.profileDescription,
    this.accountType,
    this.bankName,
    this.color,
    this.icon,
    this.isDefault = false,
  });

  BankStatement copyWith({
    String? id,
    DateTime? uploadDate,
    String? fileName,
    String? filePath,
    DateTime? statementPeriodStart,
    DateTime? statementPeriodEnd,
    int? transactionCount,
    bool? isProcessed,
    String? profileName,
    String? profileDescription,
    String? accountType,
    String? bankName,
    String? color,
    String? icon,
    bool? isDefault,
  }) {
    return BankStatement(
      id: id ?? this.id,
      uploadDate: uploadDate ?? this.uploadDate,
      fileName: fileName ?? this.fileName,
      filePath: filePath ?? this.filePath,
      statementPeriodStart: statementPeriodStart ?? this.statementPeriodStart,
      statementPeriodEnd: statementPeriodEnd ?? this.statementPeriodEnd,
      transactionCount: transactionCount ?? this.transactionCount,
      isProcessed: isProcessed ?? this.isProcessed,
      profileName: profileName ?? this.profileName,
      profileDescription: profileDescription ?? this.profileDescription,
      accountType: accountType ?? this.accountType,
      bankName: bankName ?? this.bankName,
      color: color ?? this.color,
      icon: icon ?? this.icon,
      isDefault: isDefault ?? this.isDefault,
    );
  }

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
      'profileName': profileName,
      'profileDescription': profileDescription,
      'accountType': accountType,
      'bankName': bankName,
      'color': color,
      'icon': icon,
      'isDefault': isDefault,
    };
  }

  factory BankStatement.fromJson(Map<String, dynamic> json) {
    // Handle status field from API (processing, processed, failed)
    final status = json['status'] as String?;
    final isProcessed = status == 'processed' || (json['isProcessed'] as bool? ?? false);
    
    return BankStatement(
      id: json['id'] as String,
      uploadDate: DateTime.parse(json['uploadDate'] as String),
      fileName: json['fileName'] as String,
      filePath: json['filePath'] as String? ?? json['fileName'] as String? ?? '',
      statementPeriodStart: json['statementPeriodStart'] != null
          ? DateTime.parse(json['statementPeriodStart'] as String)
          : null,
      statementPeriodEnd: json['statementPeriodEnd'] != null
          ? DateTime.parse(json['statementPeriodEnd'] as String)
          : null,
      transactionCount: json['transactionCount'] as int? ?? 0,
      isProcessed: isProcessed,
      profileName: json['profileName'] as String?,
      profileDescription: json['profileDescription'] as String?,
      accountType: json['accountType'] as String?,
      bankName: json['bankName'] as String?,
      color: json['color'] as String?,
      icon: json['icon'] as String?,
      isDefault: json['isDefault'] as bool? ?? false,
    );
  }
}

