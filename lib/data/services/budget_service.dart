import 'api_service.dart';
import '../models/budget.dart';
import '../../../core/constants/api_constants.dart';

class BudgetService {
  final ApiService _apiService;

  BudgetService({ApiService? apiService})
      : _apiService = apiService ?? ApiService();

  /// Get all budgets
  Future<List<Budget>> getBudgets({
    String? period,
    String? categoryId,
  }) async {
    final queryParams = <String, String>{};
    if (period != null) queryParams['period'] = period;
    if (categoryId != null) queryParams['categoryId'] = categoryId;

    final queryString = Uri(queryParameters: queryParams).query;
    final endpoint = '${ApiConstants.budgets}${queryString.isNotEmpty ? '?$queryString' : ''}';

    final response = await _apiService.get<Map<String, dynamic>>(
      endpoint,
      (json) => json,
    );

    // Response format: { "budgets": [...] }
    final budgetsList = response['budgets'] as List<dynamic>;
    return budgetsList.map((json) => Budget.fromJson(json as Map<String, dynamic>)).toList();
  }

  /// Create or update a budget
  Future<Budget> createOrUpdateBudget({
    required String categoryId,
    required String categoryName,
    required double amount,
    required BudgetPeriod period,
    required DateTime startDate,
  }) async {
    final body = {
      'categoryId': categoryId,
      'categoryName': categoryName,
      'amount': amount,
      'period': period.toString().split('.').last,
      'startDate': startDate.toIso8601String(),
    };

    final response = await _apiService.post<Map<String, dynamic>>(
      ApiConstants.budgets,
      body,
      (json) => json,
    );

    // Response format: { "id": ..., "categoryId": ..., ... }
    return Budget.fromJson(response);
  }

  /// Get budget comparison (budget vs actual)
  Future<List<Map<String, dynamic>>> getBudgetComparison({
    String? statementId,
    String? period,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final queryParams = <String, String>{};
    if (statementId != null) queryParams['statementId'] = statementId;
    if (period != null) queryParams['period'] = period;
    if (startDate != null) {
      queryParams['startDate'] = startDate.toIso8601String();
    }
    if (endDate != null) {
      queryParams['endDate'] = endDate.toIso8601String();
    }

    final queryString = Uri(queryParameters: queryParams).query;
    final endpoint = '${ApiConstants.budgetsCompare}${queryString.isNotEmpty ? '?$queryString' : ''}';

    final response = await _apiService.get<Map<String, dynamic>>(
      endpoint,
      (json) => json,
    );

    // Response format: { "comparisons": [...], "period": {...} }
    final comparisons = response['comparisons'] as List<dynamic>;
    return comparisons.map((e) => e as Map<String, dynamic>).toList();
  }

  /// Delete a budget
  Future<void> deleteBudget(String budgetId) async {
    await _apiService.delete<Map<String, dynamic>>(
      ApiConstants.budgetDelete(budgetId),
      (json) => json,
    );
  }
}

