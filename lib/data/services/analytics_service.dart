import 'api_service.dart';
import 'api_models.dart';
import '../models/category.dart';
import '../mock/mock_data.dart';
import 'dart:math' as math;

class AnalyticsService {
  final ApiService _apiService;
  final bool _useMockData;

  AnalyticsService({ApiService? apiService, bool useMockData = false})
      : _apiService = apiService ?? ApiService(),
        _useMockData = useMockData;

  /// Get category breakdown
  Future<List<CategoryBreakdownResponse>> getCategoryBreakdown({
    String? statementId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    if (_useMockData) {
      await Future.delayed(const Duration(milliseconds: 400));
      final transactions = MockData.getMockTransactions();
      final expenses = transactions.where((t) => t.type == TransactionType.expense).toList();
      
      final categoryMap = <String, double>{};
      for (var transaction in expenses) {
        if (transaction.category != null) {
          categoryMap[transaction.category!] = 
              (categoryMap[transaction.category!] ?? 0) + transaction.amount;
        }
      }

      final total = categoryMap.values.fold<double>(0, (sum, amount) => sum + amount);
      
      return categoryMap.entries.map((entry) {
        return CategoryBreakdownResponse(
          category: entry.key,
          totalAmount: entry.value,
          percentage: total > 0 ? (entry.value / total * 100) : 0,
          transactionCount: expenses.where((t) => t.category == entry.key).length,
        );
      }).toList();
    }

    // Real API call
    final queryParams = <String, String>{};
    if (statementId != null) queryParams['statementId'] = statementId;
    if (startDate != null) {
      queryParams['startDate'] = startDate.toIso8601String();
    }
    if (endDate != null) {
      queryParams['endDate'] = endDate.toIso8601String();
    }

    final queryString = Uri(queryParameters: queryParams).query;
    final endpoint = '/analytics/categories${queryString.isNotEmpty ? '?$queryString' : ''}';

    // Backend returns: { "success": true, "data": [...] }
    // ApiService extracts data, but wraps arrays in {'items': [...]}
    final response = await _apiService.get<Map<String, dynamic>>(
      endpoint,
      (json) => json,
    );

    // Response format: { "items": [...] } (wrapped by ApiService) or direct array
    final categoriesList = response['items'] as List<dynamic>? ?? 
                          (response['categories'] as List<dynamic>? ?? []);
    return categoriesList.map((json) => CategoryBreakdownResponse.fromJson(json as Map<String, dynamic>)).toList();
  }

  /// Get spending trends
  Future<List<SpendingTrendsResponse>> getSpendingTrends({
    String? statementId,
    DateTime? startDate,
    DateTime? endDate,
    String period = 'day', // 'day', 'week', 'month'
  }) async {
    if (_useMockData) {
      await Future.delayed(const Duration(milliseconds: 400));
      final transactions = MockData.getMockTransactions();
      final expenses = transactions.where((t) => t.type == TransactionType.expense).toList();
      
      final now = DateTime.now();
      final trends = <SpendingTrendsResponse>[];
      
      // Generate last 7 days data
      for (int i = 6; i >= 0; i--) {
        final date = now.subtract(Duration(days: i));
        final dayExpenses = expenses.where((t) => 
          t.date.year == date.year &&
          t.date.month == date.month &&
          t.date.day == date.day
        ).toList();
        
        trends.add(SpendingTrendsResponse(
          date: date,
          totalAmount: dayExpenses.fold<double>(0, (sum, t) => sum + t.amount),
          transactionCount: dayExpenses.length,
        ));
      }
      
      return trends;
    }

    // Real API call
    final queryParams = <String, String>{'period': period};
    if (statementId != null) queryParams['statementId'] = statementId;
    if (startDate != null) {
      queryParams['startDate'] = startDate.toIso8601String();
    }
    if (endDate != null) {
      queryParams['endDate'] = endDate.toIso8601String();
    }

    final queryString = Uri(queryParameters: queryParams).query;
    final endpoint = '/analytics/trends${queryString.isNotEmpty ? '?$queryString' : ''}';

    final response = await _apiService.get<Map<String, dynamic>>(
      endpoint,
      (json) => json,
    );

    // Backend returns: { "success": true, "data": [{ "date": ..., "income": ..., "expenses": ..., "savings": ... }] }
    // ApiService wraps arrays in {'items': [...]}
    final trendsList = response['items'] as List<dynamic>? ?? 
                      (response['trends'] as List<dynamic>? ?? []);
    
    // Backend format: { "date": "...", "income": ..., "expenses": ..., "savings": ... }
    // Frontend expects: { "date": "...", "totalAmount": ..., "transactionCount": ... }
    return trendsList.map((json) {
      final item = json as Map<String, dynamic>;
      // Convert backend format to frontend format
      return SpendingTrendsResponse(
        date: DateTime.parse(item['date'] as String),
        totalAmount: (item['expenses'] as num? ?? 0.0).toDouble(),
        transactionCount: 0, // Backend doesn't provide this, calculate if needed
      );
    }).toList();
  }

  /// Get financial insights
  Future<List<FinancialInsight>> getFinancialInsights({
    String? statementId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    if (_useMockData) {
      await Future.delayed(const Duration(milliseconds: 300));
      final transactions = MockData.getMockTransactions();
      
      final income = transactions
          .where((t) => t.type == TransactionType.income)
          .fold<double>(0, (sum, t) => sum + t.amount);
      
      final expenses = transactions
          .where((t) => t.type == TransactionType.expense)
          .fold<double>(0, (sum, t) => sum + t.amount);
      
      final savings = income - expenses;
      final savingsPercentage = income > 0 ? (savings / income * 100) : 0;
      
      final insights = <FinancialInsight>[];
      
      // Low savings rate insight
      if (savingsPercentage < 10 && savingsPercentage >= 0) {
        insights.add(FinancialInsight(
          type: 'low_savings_rate',
          title: 'Low Savings Rate',
          message: 'You are saving ${savingsPercentage.toStringAsFixed(1)}% of your income. You should aim for at least 20%.',
          severity: 'warning',
        ));
      }
      
      // Excessive spending insight
      if (savingsPercentage < 0) {
        insights.add(FinancialInsight(
          type: 'excessive_spending',
          title: 'Excessive Spending',
          message: 'Your expenses exceed your income. We recommend making a budget plan.',
          severity: 'error',
        ));
      }
      
      // Highest spending category
      final categoryMap = <String, double>{};
      for (var transaction in transactions.where((t) => t.type == TransactionType.expense)) {
        if (transaction.category != null) {
          categoryMap[transaction.category!] = 
              (categoryMap[transaction.category!] ?? 0) + transaction.amount;
        }
      }
      
      if (categoryMap.isNotEmpty) {
        final topCategory = categoryMap.entries.reduce((a, b) => a.value > b.value ? a : b);
        insights.add(FinancialInsight(
          type: 'highest_spending_category',
          title: 'Highest Spending Category',
          message: 'You spend the most in ${topCategory.key} category. You can review your expenses in this category.',
          severity: 'info',
        ));
      }
      
      // Great savings insight
      if (savingsPercentage >= 20) {
        insights.add(FinancialInsight(
          type: 'great_savings',
          title: 'Great!',
          message: 'Your savings rate is at an ideal level. Keep it up!',
          severity: 'success',
        ));
      }
      
      return insights;
    }

    // Real API call
    final queryParams = <String, String>{};
    if (statementId != null) queryParams['statementId'] = statementId;
    if (startDate != null) {
      queryParams['startDate'] = startDate.toIso8601String();
    }
    if (endDate != null) {
      queryParams['endDate'] = endDate.toIso8601String();
    }

    final queryString = Uri(queryParameters: queryParams).query;
    final endpoint = '/analytics/insights${queryString.isNotEmpty ? '?$queryString' : ''}';

    final response = await _apiService.get<Map<String, dynamic>>(
      endpoint,
      (json) => json,
    );

    // Backend returns: { "success": true, "data": { "savingsRate": ..., "topSpendingCategory": ..., ... } }
    // ApiService extracts data, so response is the object directly
    // Convert backend object format to frontend array format
    final insights = <FinancialInsight>[];
    
    if (response.containsKey('savingsRate')) {
      final savingsRate = (response['savingsRate'] as num?)?.toDouble() ?? 0.0;
      if (savingsRate < 10 && savingsRate >= 0) {
        insights.add(FinancialInsight(
          type: 'low_savings_rate',
          title: 'Low Savings Rate',
          message: 'You are saving ${savingsRate.toStringAsFixed(1)}% of your income. You should aim for at least 20%.',
          severity: 'warning',
        ));
      } else if (savingsRate < 0) {
        insights.add(FinancialInsight(
          type: 'excessive_spending',
          title: 'Excessive Spending',
          message: 'Your expenses exceed your income. We recommend making a budget plan.',
          severity: 'error',
        ));
      } else if (savingsRate >= 20) {
        insights.add(FinancialInsight(
          type: 'great_savings',
          title: 'Great!',
          message: 'Your savings rate is at an ideal level. Keep it up!',
          severity: 'success',
        ));
      }
    }
    
    if (response.containsKey('topSpendingCategory')) {
      final topCategory = response['topSpendingCategory'] as String?;
      if (topCategory != null) {
        insights.add(FinancialInsight(
          type: 'highest_spending_category',
          title: 'Highest Spending Category',
          message: 'You spend the most in $topCategory category. You can review your expenses in this category.',
          severity: 'info',
        ));
      }
    }
    
    // Add recommendations if available
    final recommendations = response['recommendations'] as List<dynamic>?;
    if (recommendations != null) {
      for (var rec in recommendations) {
        insights.add(FinancialInsight(
          type: 'recommendation',
          title: 'Recommendation',
          message: rec as String,
          severity: 'info',
        ));
      }
    }
    
    return insights;
  }

  /// Get monthly trends
  Future<List<Map<String, dynamic>>> getMonthlyTrends({
    String? statementId,
    int? months,
  }) async {
    if (_useMockData) {
      await Future.delayed(const Duration(milliseconds: 400));
      // Return empty for now - will be calculated from transactions
      return [];
    }

    final queryParams = <String, String>{};
    if (statementId != null) queryParams['statementId'] = statementId;
    if (months != null) queryParams['months'] = months.toString();

    final queryString = Uri(queryParameters: queryParams).query;
    final endpoint = '/analytics/monthly-trends${queryString.isNotEmpty ? '?$queryString' : ''}';

    final response = await _apiService.get<Map<String, dynamic>>(
      endpoint,
      (json) => json,
    );

    // Backend returns: { "success": true, "data": [...] }
    // ApiService wraps arrays in {'items': [...]}
    final monthlyData = response['items'] as List<dynamic>? ?? 
                       (response['monthlyData'] as List<dynamic>? ?? []);
    return monthlyData.map((e) => e as Map<String, dynamic>).toList();
  }

  /// Get category trends over time
  Future<List<Map<String, dynamic>>> getCategoryTrends({
    String? statementId,
    int? topCategories,
    int? months,
  }) async {
    if (_useMockData) {
      await Future.delayed(const Duration(milliseconds: 400));
      return [];
    }

    final queryParams = <String, String>{};
    if (statementId != null) queryParams['statementId'] = statementId;
    if (topCategories != null) queryParams['topCategories'] = topCategories.toString();
    if (months != null) queryParams['months'] = months.toString();

    final queryString = Uri(queryParameters: queryParams).query;
    final endpoint = '/analytics/category-trends${queryString.isNotEmpty ? '?$queryString' : ''}';

    final response = await _apiService.get<Map<String, dynamic>>(
      endpoint,
      (json) => json,
    );

    // Response format: { "categoryTrends": [...] }
    final categoryTrends = response['categoryTrends'] as List<dynamic>;
    return categoryTrends.map((e) => e as Map<String, dynamic>).toList();
  }

  /// Get weekly patterns
  Future<List<Map<String, dynamic>>> getWeeklyPatterns({
    String? statementId,
    int? weeks,
  }) async {
    if (_useMockData) {
      await Future.delayed(const Duration(milliseconds: 400));
      return [];
    }

    final queryParams = <String, String>{};
    if (statementId != null) queryParams['statementId'] = statementId;
    if (weeks != null) queryParams['weeks'] = weeks.toString();

    final queryString = Uri(queryParameters: queryParams).query;
    final endpoint = '/analytics/weekly-patterns${queryString.isNotEmpty ? '?$queryString' : ''}';

    final response = await _apiService.get<Map<String, dynamic>>(
      endpoint,
      (json) => json,
    );

    // Response format: { "patterns": [...] }
    final patterns = response['patterns'] as List<dynamic>;
    return patterns.map((e) => e as Map<String, dynamic>).toList();
  }

  /// Get year-over-year comparison
  Future<List<Map<String, dynamic>>> getYearOverYear({
    String? statementId,
    int? year,
  }) async {
    if (_useMockData) {
      await Future.delayed(const Duration(milliseconds: 400));
      return [];
    }

    final queryParams = <String, String>{};
    if (statementId != null) queryParams['statementId'] = statementId;
    if (year != null) queryParams['year'] = year.toString();

    final queryString = Uri(queryParameters: queryParams).query;
    final endpoint = '/analytics/year-over-year${queryString.isNotEmpty ? '?$queryString' : ''}';

    final response = await _apiService.get<Map<String, dynamic>>(
      endpoint,
      (json) => json,
    );

    // Response format: { "comparisons": [...] }
    final comparisons = response['comparisons'] as List<dynamic>;
    return comparisons.map((e) => e as Map<String, dynamic>).toList();
  }

  /// Get spending forecast
  Future<Map<String, dynamic>> getForecast({
    String? statementId,
  }) async {
    if (_useMockData) {
      await Future.delayed(const Duration(milliseconds: 400));
      return {};
    }

    final queryParams = <String, String>{};
    if (statementId != null) queryParams['statementId'] = statementId;

    final queryString = Uri(queryParameters: queryParams).query;
    final endpoint = '/analytics/forecast${queryString.isNotEmpty ? '?$queryString' : ''}';

    final response = await _apiService.get<Map<String, dynamic>>(
      endpoint,
      (json) => json,
    );

    // Response format: { "forecast": {...} }
    return response['forecast'] as Map<String, dynamic>;
  }
}

