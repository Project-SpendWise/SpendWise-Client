import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/transaction.dart';
import '../data/models/category.dart';

class TransactionNotifier extends StateNotifier<List<Transaction>> {
  TransactionNotifier() : super([]);

  void addTransaction(Transaction transaction) {
    state = [...state, transaction];
  }

  void addTransactions(List<Transaction> transactions) {
    print('TransactionProvider.addTransactions: Adding ${transactions.length} transactions');
    if (transactions.isNotEmpty) {
      print('  Sample transaction: id=${transactions.first.id}, type=${transactions.first.type}, category=${transactions.first.category}, amount=${transactions.first.amount}');
    }
    state = [...state, ...transactions];
    print('  Total transactions in provider: ${state.length}');
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
    
    // Debug logging
    print('TransactionProvider.categoryBreakdown:');
    print('  Total transactions: ${state.length}');
    print('  Expense transactions: ${state.where((t) => t.type == TransactionType.expense).length}');
    print('  Expenses with categories: ${state.where((t) => t.type == TransactionType.expense && t.category != null).length}');
    print('  Expenses by category map: $expenses');
    
    // First, try to match with default categories
    final matchedCategories = <String, Category>{};
    final defaultCategories = Category.defaultCategories;
    
    for (var defaultCat in defaultCategories) {
      if (expenses.containsKey(defaultCat.name)) {
        matchedCategories[defaultCat.name] = Category(
          id: defaultCat.id,
          name: defaultCat.name,
          color: defaultCat.color,
          totalAmount: expenses[defaultCat.name]!,
          icon: defaultCat.icon,
        );
      }
    }
    
    // Then, add any categories from backend that don't match default categories
    // Use "other" category styling for unknown categories
    final otherCategory = defaultCategories.firstWhere((c) => c.id == 'other');
    final allCategoryNames = expenses.keys.toSet();
    
    for (var categoryName in allCategoryNames) {
      if (!matchedCategories.containsKey(categoryName)) {
        // Use a color from the chart colors based on hash of category name
        final colorIndex = categoryName.hashCode.abs() % 8;
        matchedCategories[categoryName] = Category(
          id: categoryName.toLowerCase().replaceAll(' ', '_'),
          name: categoryName,
          color: defaultCategories[colorIndex].color,
          totalAmount: expenses[categoryName]!,
          icon: otherCategory.icon,
        );
      }
    }
    
    final result = matchedCategories.values.toList()
      ..sort((a, b) => b.totalAmount.compareTo(a.totalAmount));
    
    print('  Final category breakdown count: ${result.length}');
    if (result.isNotEmpty) {
      print('  Top category: ${result.first.name} - ${result.first.totalAmount}');
    }
    
    return result;
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

