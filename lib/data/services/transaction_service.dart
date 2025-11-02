import 'api_service.dart';
import 'api_models.dart';
import '../models/transaction.dart';
import '../mock/mock_data.dart';

class TransactionService {
  final ApiService _apiService;
  final bool _useMockData;

  TransactionService({ApiService? apiService, bool useMockData = true})
      : _apiService = apiService ?? ApiService(),
        _useMockData = useMockData;

  /// Get all transactions with optional filters
  Future<List<Transaction>> getTransactions({
    DateTime? startDate,
    DateTime? endDate,
    String? category,
    String? account,
    int? limit,
    int? offset,
  }) async {
    if (_useMockData) {
      await Future.delayed(const Duration(milliseconds: 500));
      var transactions = MockData.getMockTransactions();

      // Apply filters
      if (startDate != null) {
        transactions = transactions
            .where((t) => t.date.isAfter(startDate) || t.date.isAtSameMomentAs(startDate))
            .toList();
      }
      if (endDate != null) {
        transactions = transactions
            .where((t) => t.date.isBefore(endDate) || t.date.isAtSameMomentAs(endDate))
            .toList();
      }
      if (category != null) {
        transactions = transactions.where((t) => t.category == category).toList();
      }
      if (account != null) {
        transactions = transactions.where((t) => t.account == account).toList();
      }

      // Apply pagination
      if (offset != null && offset > 0) {
        transactions = transactions.skip(offset).toList();
      }
      if (limit != null) {
        transactions = transactions.take(limit).toList();
      }

      return transactions;
    }

    // Build query parameters
    final queryParams = <String, String>{};
    if (startDate != null) {
      queryParams['startDate'] = startDate.toIso8601String();
    }
    if (endDate != null) {
      queryParams['endDate'] = endDate.toIso8601String();
    }
    if (category != null) queryParams['category'] = category;
    if (account != null) queryParams['account'] = account;
    if (limit != null) queryParams['limit'] = limit.toString();
    if (offset != null) queryParams['offset'] = offset.toString();

    final queryString = Uri(queryParameters: queryParams).query;
    final endpoint = '/transactions${queryString.isNotEmpty ? '?$queryString' : ''}';

    // Real API call
    final response = await _apiService.get<List<dynamic>>(
      endpoint,
      (json) => (json['transactions'] as List).map((e) => e as Map<String, dynamic>).toList(),
    );

    return response.map((json) => _transactionFromJson(json)).toList();
  }

  Transaction _transactionFromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json['id'] as String,
      date: DateTime.parse(json['date'] as String),
      description: json['description'] as String,
      amount: (json['amount'] as num).toDouble(),
      type: json['type'] == 'income' ? TransactionType.income : TransactionType.expense,
      category: json['category'] as String?,
      account: json['account'] as String?,
    );
  }

  /// Get transaction summary
  Future<Map<String, dynamic>> getSummary({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    if (_useMockData) {
      await Future.delayed(const Duration(milliseconds: 300));
      final transactions = MockData.getMockTransactions();
      
      final income = transactions
          .where((t) => t.type == TransactionType.income)
          .fold<double>(0.0, (sum, t) => sum + t.amount);
      
      final expenses = transactions
          .where((t) => t.type == TransactionType.expense)
          .fold<double>(0.0, (sum, t) => sum + t.amount);

      return {
        'totalIncome': income,
        'totalExpenses': expenses,
        'savings': income - expenses,
        'transactionCount': transactions.length,
      };
    }

    // Real API call
    final queryParams = <String, String>{};
    if (startDate != null) {
      queryParams['startDate'] = startDate.toIso8601String();
    }
    if (endDate != null) {
      queryParams['endDate'] = endDate.toIso8601String();
    }

    final queryString = Uri(queryParameters: queryParams).query;
    final endpoint = '/transactions/summary${queryString.isNotEmpty ? '?$queryString' : ''}';

    return await _apiService.get<Map<String, dynamic>>(
      endpoint,
      (json) => json,
    );
  }
}

