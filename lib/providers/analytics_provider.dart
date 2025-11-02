import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/transaction.dart';
import '../data/models/category.dart';
import 'transaction_provider.dart';

// Monthly aggregated data
class MonthlyData {
  final DateTime month;
  final double income;
  final double expenses;
  final double savings;

  MonthlyData({
    required this.month,
    required this.income,
    required this.expenses,
    required this.savings,
  });
}

// Category trend data
class CategoryTrendData {
  final String categoryName;
  final Color color;
  final List<({DateTime month, double amount})> monthlyData;

  CategoryTrendData({
    required this.categoryName,
    required this.color,
    required this.monthlyData,
  });
}

// Weekly pattern data
class WeeklyPatternData {
  final int dayOfWeek; // 1 = Monday, 7 = Sunday
  final double averageSpending;
  final int transactionCount;

  WeeklyPatternData({
    required this.dayOfWeek,
    required this.averageSpending,
    required this.transactionCount,
  });
}

// Year-over-year comparison
class YearOverYearData {
  final DateTime month;
  final double currentYear;
  final double previousYear;
  final double changePercent;

  YearOverYearData({
    required this.month,
    required this.currentYear,
    required this.previousYear,
    required this.changePercent,
  });
}

// Provider for monthly aggregated data (last 12 months)
final monthlyDataProvider = Provider<List<MonthlyData>>((ref) {
  final transactions = ref.watch(transactionProvider);
  final now = DateTime.now();
  final monthlyData = <MonthlyData>[];

  for (int monthOffset = 0; monthOffset < 12; monthOffset++) {
    final targetMonth = now.month - monthOffset;
    final targetYear = targetMonth <= 0 ? now.year - 1 : now.year;
    final actualMonth = targetMonth <= 0 ? 12 + targetMonth : targetMonth;
    
    final monthStart = DateTime(targetYear, actualMonth, 1);
    final monthEnd = DateTime(targetYear, actualMonth + 1, 0, 23, 59, 59);

    final monthTransactions = transactions.where((t) =>
      t.date.isAfter(monthStart.subtract(const Duration(days: 1))) &&
      t.date.isBefore(monthEnd.add(const Duration(days: 1)))
    ).toList();

    final income = monthTransactions
        .where((t) => t.type == TransactionType.income)
        .fold<double>(0.0, (sum, t) => sum + t.amount);

    final expenses = monthTransactions
        .where((t) => t.type == TransactionType.expense)
        .fold<double>(0.0, (sum, t) => sum + t.amount);

    monthlyData.add(MonthlyData(
      month: monthStart,
      income: income,
      expenses: expenses,
      savings: income - expenses,
    ));
  }

  return monthlyData.reversed.toList();
});

// Provider for category trends over time
final categoryTrendsProvider = Provider<List<CategoryTrendData>>((ref) {
  final transactions = ref.watch(transactionProvider);
  final now = DateTime.now();
  final trends = <CategoryTrendData>[];

  // Get top 5 categories from category breakdown provider
  final categoryBreakdown = ref.watch(categoryBreakdownProvider);

  final topCategories = categoryBreakdown.take(5).toList();

  for (var category in topCategories) {
    final monthlyData = <({DateTime month, double amount})>[];

    for (int monthOffset = 0; monthOffset < 12; monthOffset++) {
      final targetMonth = now.month - monthOffset;
      final targetYear = targetMonth <= 0 ? now.year - 1 : now.year;
      final actualMonth = targetMonth <= 0 ? 12 + targetMonth : targetMonth;
      
      final monthStart = DateTime(targetYear, actualMonth, 1);
      final monthEnd = DateTime(targetYear, actualMonth + 1, 0, 23, 59, 59);

      final monthTransactions = transactions.where((t) =>
        t.type == TransactionType.expense &&
        t.category == category.name &&
        t.date.isAfter(monthStart.subtract(const Duration(days: 1))) &&
        t.date.isBefore(monthEnd.add(const Duration(days: 1)))
      ).toList();

      final amount = monthTransactions.fold<double>(0.0, (sum, t) => sum + t.amount);
      monthlyData.add((month: monthStart, amount: amount));
    }

    trends.add(CategoryTrendData(
      categoryName: category.name,
      color: category.color,
      monthlyData: monthlyData.reversed.toList(),
    ));
  }

  return trends;
});

// Provider for weekly patterns
final weeklyPatternsProvider = Provider<List<WeeklyPatternData>>((ref) {
  final transactions = ref.watch(transactionProvider);
  final now = DateTime.now();
  final patterns = <WeeklyPatternData>[];

  // Calculate for last 4 weeks
  final fourWeeksAgo = now.subtract(const Duration(days: 28));
  final recentTransactions = transactions.where((t) =>
    t.type == TransactionType.expense &&
    t.date.isAfter(fourWeeksAgo.subtract(const Duration(days: 1)))
  ).toList();

  // Group by day of week (1 = Monday, 7 = Sunday)
  final spendingByDay = <int, List<double>>{};
  for (var transaction in recentTransactions) {
    final dayOfWeek = transaction.date.weekday;
    spendingByDay.putIfAbsent(dayOfWeek, () => []).add(transaction.amount);
  }

  for (int day = 1; day <= 7; day++) {
    final amounts = spendingByDay[day] ?? [];
    final average = amounts.isEmpty
        ? 0.0
        : amounts.reduce((a, b) => a + b) / amounts.length;

    patterns.add(WeeklyPatternData(
      dayOfWeek: day,
      averageSpending: average,
      transactionCount: amounts.length,
    ));
  }

  return patterns;
});

// Provider for year-over-year comparison
final yearOverYearProvider = Provider<List<YearOverYearData>>((ref) {
  final transactions = ref.watch(transactionProvider);
  final now = DateTime.now();
  final comparisons = <YearOverYearData>[];

  for (int monthOffset = 0; monthOffset < 12; monthOffset++) {
    final targetMonth = now.month - monthOffset;
    final targetYear = targetMonth <= 0 ? now.year - 1 : now.year;
    final actualMonth = targetMonth <= 0 ? 12 + targetMonth : targetMonth;
    
    // Current year
    final currentMonthStart = DateTime(targetYear, actualMonth, 1);
    final currentMonthEnd = DateTime(targetYear, actualMonth + 1, 0, 23, 59, 59);
    
    final currentYearTransactions = transactions.where((t) =>
      t.date.year == targetYear &&
      t.date.month == actualMonth &&
      t.type == TransactionType.expense
    ).toList();
    
    final currentYearTotal = currentYearTransactions
        .fold<double>(0.0, (sum, t) => sum + t.amount);

    // Previous year
    final previousYearTransactions = transactions.where((t) =>
      t.date.year == targetYear - 1 &&
      t.date.month == actualMonth &&
      t.type == TransactionType.expense
    ).toList();
    
    final previousYearTotal = previousYearTransactions
        .fold<double>(0.0, (sum, t) => sum + t.amount);

    final changePercent = previousYearTotal > 0
        ? ((currentYearTotal - previousYearTotal) / previousYearTotal * 100).toDouble()
        : (currentYearTotal > 0 ? 100.0 : 0.0);

    comparisons.add(YearOverYearData(
      month: currentMonthStart,
      currentYear: currentYearTotal,
      previousYear: previousYearTotal,
      changePercent: changePercent,
    ));
  }

  return comparisons.reversed.toList();
});

// Provider for spending forecast (simple moving average)
final spendingForecastProvider = Provider<({double nextMonth, Map<String, double> byCategory})>((ref) {
  final monthlyData = ref.watch(monthlyDataProvider);
  final transactions = ref.watch(transactionProvider);
  final now = DateTime.now();

  if (monthlyData.length < 3) {
    return (nextMonth: 0, byCategory: {});
  }

  // Calculate 3-month moving average
  final last3Months = monthlyData.length >= 3
      ? monthlyData.sublist(monthlyData.length - 3)
      : monthlyData;
  final avgExpenses = last3Months
      .map((m) => m.expenses)
      .reduce((a, b) => a + b) / last3Months.length;

  // Forecast by category (last 3 months average)
  final categoryForecasts = <String, double>{};
  final last3MonthsTransactions = transactions.where((t) {
    final threeMonthsAgo = now.subtract(const Duration(days: 90));
    return t.type == TransactionType.expense &&
        t.date.isAfter(threeMonthsAgo);
  }).toList();

  final spendingByCategory = <String, List<double>>{};
  for (var transaction in last3MonthsTransactions) {
    if (transaction.category != null) {
      spendingByCategory.putIfAbsent(
        transaction.category!,
        () => [],
      ).add(transaction.amount);
    }
  }

  for (var entry in spendingByCategory.entries) {
    final monthlyAvg = entry.value.reduce((a, b) => a + b) / 3;
    categoryForecasts[entry.key] = monthlyAvg;
  }

  return (nextMonth: avgExpenses, byCategory: categoryForecasts);
});

