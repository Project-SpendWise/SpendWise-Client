import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/transaction.dart';
import '../data/models/category.dart';

class TransactionNotifier extends StateNotifier<List<Transaction>> {
  TransactionNotifier() : super([]);

  void addTransaction(Transaction transaction) {
    state = [...state, transaction];
  }

  void addTransactions(List<Transaction> transactions) {
    state = [...state, ...transactions];
  }

  void removeTransaction(String id) {
    state = state.where((t) => t.id != id).toList();
  }

  void clearTransactions() {
    state = [];
  }

  double get totalIncome {
    return state
        .where((t) => t.type == TransactionType.income)
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  double get totalExpenses {
    return state
        .where((t) => t.type == TransactionType.expense)
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  double get savings => totalIncome - totalExpenses;

  Map<String, double> get expensesByCategory {
    final Map<String, double> categoryMap = {};
    for (var transaction in state) {
      if (transaction.type == TransactionType.expense &&
          transaction.category != null) {
        categoryMap[transaction.category!] =
            (categoryMap[transaction.category!] ?? 0) + transaction.amount;
      }
    }
    return categoryMap;
  }

  List<Category> get categoryBreakdown {
    final expenses = expensesByCategory;
    return Category.defaultCategories.map((category) {
      return Category(
        id: category.id,
        name: category.name,
        color: category.color,
        totalAmount: expenses[category.name] ?? 0.0,
        icon: category.icon,
      );
    }).where((c) => c.totalAmount > 0).toList()
      ..sort((a, b) => b.totalAmount.compareTo(a.totalAmount));
  }

  List<Transaction> getRecentTransactions(int count) {
    final sorted = List<Transaction>.from(state)
      ..sort((a, b) => b.date.compareTo(a.date));
    return sorted.take(count).toList();
  }
}

final transactionProvider =
    StateNotifierProvider<TransactionNotifier, List<Transaction>>((ref) {
  return TransactionNotifier();
});

// Computed providers
final totalIncomeProvider = Provider<double>((ref) {
  return ref.watch(transactionProvider.notifier).totalIncome;
});

final totalExpensesProvider = Provider<double>((ref) {
  return ref.watch(transactionProvider.notifier).totalExpenses;
});

final savingsProvider = Provider<double>((ref) {
  return ref.watch(transactionProvider.notifier).savings;
});

final categoryBreakdownProvider = Provider<List<Category>>((ref) {
  return ref.watch(transactionProvider.notifier).categoryBreakdown;
});

