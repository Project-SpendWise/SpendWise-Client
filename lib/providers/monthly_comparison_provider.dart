import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/transaction.dart';
import '../providers/transaction_provider.dart';
import '../providers/filter_provider.dart';

class PeriodComparison {
  final double currentIncome;
  final double currentExpenses;
  final double currentSavings;
  final double previousIncome;
  final double previousExpenses;
  final double previousSavings;
  final double incomeChangePercent;
  final double expensesChangePercent;
  final double savingsChangePercent;

  PeriodComparison({
    required this.currentIncome,
    required this.currentExpenses,
    required this.currentSavings,
    required this.previousIncome,
    required this.previousExpenses,
    required this.previousSavings,
    required this.incomeChangePercent,
    required this.expensesChangePercent,
    required this.savingsChangePercent,
  });
}

// Helper function to filter transactions by date range
List<Transaction> _filterByDateRange(
  List<Transaction> transactions,
  DateTime start,
  DateTime end,
) {
  return transactions.where((t) {
    return t.date.isAfter(start.subtract(const Duration(days: 1))) &&
        t.date.isBefore(end.add(const Duration(days: 1)));
  }).toList();
}

// Helper function to get date range for period
({DateTime start, DateTime end}) _getPeriodRange(TimePeriod period, {bool previous = false}) {
  final now = DateTime.now();
  int offset = previous ? 1 : 0;

  switch (period) {
    case TimePeriod.daily:
      final targetDate = now.subtract(Duration(days: offset));
      return (
        start: DateTime(targetDate.year, targetDate.month, targetDate.day),
        end: DateTime(targetDate.year, targetDate.month, targetDate.day, 23, 59, 59)
      );
    case TimePeriod.weekly:
      final targetDate = now.subtract(Duration(days: 7 * offset));
      final weekStart = targetDate.subtract(Duration(days: targetDate.weekday - 1));
      return (
        start: DateTime(weekStart.year, weekStart.month, weekStart.day),
        end: targetDate
      );
    case TimePeriod.monthly:
      final targetMonth = now.month - offset;
      final targetYear = targetMonth <= 0 ? now.year - 1 : now.year;
      final actualMonth = targetMonth <= 0 ? 12 + targetMonth : targetMonth;
      return (
        start: DateTime(targetYear, actualMonth, 1),
        end: DateTime(targetYear, actualMonth + 1, 0, 23, 59, 59)
      );
    case TimePeriod.yearly:
      final targetYear = now.year - offset;
      return (
        start: DateTime(targetYear, 1, 1),
        end: DateTime(targetYear, 12, 31, 23, 59, 59)
      );
  }
}

// Calculate percentage change
double _calculatePercentChange(double current, double previous) {
  if (previous == 0) return current > 0 ? 100 : 0;
  return ((current - previous) / previous) * 100;
}

// Provider for period comparison
final periodComparisonProvider = Provider<PeriodComparison>((ref) {
  final transactions = ref.watch(transactionProvider);
  final filterState = ref.watch(filterProvider);
  final period = filterState.timePeriod;

  // Get current period range
  final currentRange = _getPeriodRange(period, previous: false);
  final currentTransactions = _filterByDateRange(
    transactions,
    currentRange.start,
    currentRange.end,
  );

  // Get previous period range
  final previousRange = _getPeriodRange(period, previous: true);
  final previousTransactions = _filterByDateRange(
    transactions,
    previousRange.start,
    previousRange.end,
  );

  // Calculate current period stats
  final currentIncome = currentTransactions
      .where((t) => t.type == TransactionType.income)
      .fold<double>(0.0, (sum, t) => sum + t.amount);
  final currentExpenses = currentTransactions
      .where((t) => t.type == TransactionType.expense)
      .fold<double>(0.0, (sum, t) => sum + t.amount);
  final currentSavings = currentIncome - currentExpenses;

  // Calculate previous period stats
  final previousIncome = previousTransactions
      .where((t) => t.type == TransactionType.income)
      .fold<double>(0.0, (sum, t) => sum + t.amount);
  final previousExpenses = previousTransactions
      .where((t) => t.type == TransactionType.expense)
      .fold<double>(0.0, (sum, t) => sum + t.amount);
  final previousSavings = previousIncome - previousExpenses;

  // Calculate percentage changes
  final incomeChangePercent = _calculatePercentChange(currentIncome, previousIncome);
  final expensesChangePercent = _calculatePercentChange(currentExpenses, previousExpenses);
  final savingsChangePercent = _calculatePercentChange(currentSavings, previousSavings);

  return PeriodComparison(
    currentIncome: currentIncome,
    currentExpenses: currentExpenses,
    currentSavings: currentSavings,
    previousIncome: previousIncome,
    previousExpenses: previousExpenses,
    previousSavings: previousSavings,
    incomeChangePercent: incomeChangePercent,
    expensesChangePercent: expensesChangePercent,
    savingsChangePercent: savingsChangePercent,
  );
});

// Providers for filtered totals based on current period
final currentPeriodIncomeProvider = Provider<double>((ref) {
  final comparison = ref.watch(periodComparisonProvider);
  return comparison.currentIncome;
});

final currentPeriodExpensesProvider = Provider<double>((ref) {
  final comparison = ref.watch(periodComparisonProvider);
  return comparison.currentExpenses;
});

final currentPeriodSavingsProvider = Provider<double>((ref) {
  final comparison = ref.watch(periodComparisonProvider);
  return comparison.currentSavings;
});

