import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/transaction.dart';
import '../providers/transaction_provider.dart';
import '../providers/filter_provider.dart';

class QuickStats {
  final double averageDailySpending;
  final double biggestExpense;
  final int totalTransactions;
  final String mostUsedCategory;
  final int transactionsCount;

  QuickStats({
    required this.averageDailySpending,
    required this.biggestExpense,
    required this.totalTransactions,
    required this.mostUsedCategory,
    required this.transactionsCount,
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
({DateTime start, DateTime end}) _getPeriodRange(TimePeriod period) {
  final now = DateTime.now();

  switch (period) {
    case TimePeriod.daily:
      return (
        start: DateTime(now.year, now.month, now.day),
        end: DateTime(now.year, now.month, now.day, 23, 59, 59)
      );
    case TimePeriod.weekly:
      final weekStart = now.subtract(Duration(days: 7));
      return (
        start: DateTime(weekStart.year, weekStart.month, weekStart.day),
        end: now
      );
    case TimePeriod.monthly:
      return (
        start: DateTime(now.year, now.month, 1),
        end: now
      );
    case TimePeriod.yearly:
      return (
        start: DateTime(now.year, 1, 1),
        end: now
      );
  }
}

// Provider for quick stats
final quickStatsProvider = Provider<QuickStats>((ref) {
  final transactions = ref.watch(transactionProvider);
  final filterState = ref.watch(filterProvider);
  final period = filterState.timePeriod;

  // Get period range
  final range = _getPeriodRange(period);
  final periodTransactions = _filterByDateRange(
    transactions,
    range.start,
    range.end,
  );

  // Calculate days in period
  final daysInPeriod = period == TimePeriod.daily
      ? 1
      : period == TimePeriod.weekly
          ? 7
          : period == TimePeriod.monthly
              ? range.end.difference(range.start).inDays + 1
              : range.end.difference(range.start).inDays + 1;

  // Filter expenses only
  final expenses = periodTransactions
      .where((t) => t.type == TransactionType.expense)
      .toList();

  // Calculate average daily spending
  final totalExpenses = expenses.fold<double>(0.0, (sum, t) => sum + t.amount);
  final averageDailySpending = daysInPeriod > 0 ? totalExpenses / daysInPeriod : 0.0;

  // Find biggest expense
  final biggestExpense = expenses.isEmpty
      ? 0.0
      : expenses.map((t) => t.amount).reduce((a, b) => a > b ? a : b);

  // Count total transactions
  final totalTransactions = periodTransactions.length;
  final transactionsCount = expenses.length;

  // Find most used category
  final categoryCounts = <String, int>{};
  for (var expense in expenses) {
    if (expense.category != null) {
      categoryCounts[expense.category!] = (categoryCounts[expense.category!] ?? 0) + 1;
    }
  }

  final mostUsedCategory = categoryCounts.isEmpty
      ? '-'
      : categoryCounts.entries.reduce((a, b) => a.value > b.value ? a : b).key;

  return QuickStats(
    averageDailySpending: averageDailySpending,
    biggestExpense: biggestExpense,
    totalTransactions: totalTransactions,
    mostUsedCategory: mostUsedCategory,
    transactionsCount: transactionsCount,
  );
});

