import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/budget.dart';
import '../data/models/transaction.dart';
import '../data/models/category.dart';
import 'transaction_provider.dart';

class BudgetNotifier extends StateNotifier<List<Budget>> {
  BudgetNotifier() : super([]);

  void addBudget(Budget budget) {
    state = [...state, budget];
  }

  void updateBudget(Budget budget) {
    state = state.map((b) => b.id == budget.id ? budget : b).toList();
  }

  void removeBudget(String id) {
    state = state.where((b) => b.id != id).toList();
  }

  void clearBudgets() {
    state = [];
  }

  Budget? getBudgetForCategory(String categoryId, BudgetPeriod period) {
    try {
      return state.firstWhere(
        (b) => b.categoryId == categoryId && b.period == period,
      );
    } catch (e) {
      return null;
    }
  }

  List<Budget> getBudgetsForPeriod(BudgetPeriod period) {
    return state.where((b) => b.period == period).toList();
  }
}

final budgetProvider =
    StateNotifierProvider<BudgetNotifier, List<Budget>>((ref) {
  return BudgetNotifier();
});

// Budget vs Actual calculations
class BudgetComparison {
  final Budget budget;
  final double actualSpending;
  final double remaining;
  final double percentageUsed;
  final bool isOverBudget;

  BudgetComparison({
    required this.budget,
    required this.actualSpending,
    required this.remaining,
    required this.percentageUsed,
    required this.isOverBudget,
  });
}

// Provider for budget comparisons for current period
final budgetComparisonProvider = Provider<List<BudgetComparison>>((ref) {
  final budgets = ref.watch(budgetProvider);
  final transactions = ref.watch(transactionProvider);
  final now = DateTime.now();
  final currentMonthStart = DateTime(now.year, now.month, 1);

  // Filter transactions for current month
  final currentMonthTransactions = transactions.where((t) =>
    t.date.year == now.year &&
    t.date.month == now.month &&
    t.type == TransactionType.expense
  ).toList();

  // Calculate spending per category
  final spendingByCategory = <String, double>{};
  for (var transaction in currentMonthTransactions) {
    if (transaction.category != null) {
      try {
        final category = Category.defaultCategories.firstWhere(
          (c) => c.name == transaction.category,
        );
        spendingByCategory[category.id] =
            (spendingByCategory[category.id] ?? 0) + transaction.amount;
      } catch (e) {
        // Category not found, skip
      }
    }
  }

  // Create budget comparisons
  return budgets.map((budget) {
    final actualSpending = spendingByCategory[budget.categoryId] ?? 0.0;
    final remaining = budget.amount - actualSpending;
    final percentageUsed = budget.amount > 0
        ? (actualSpending / budget.amount * 100)
        : 0.0;
    final isOverBudget = actualSpending > budget.amount;

    return BudgetComparison(
      budget: budget,
      actualSpending: actualSpending,
      remaining: remaining,
      percentageUsed: percentageUsed,
      isOverBudget: isOverBudget,
    );
  }).toList();
});

