import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/services/transaction_service.dart';
import '../../data/services/budget_service.dart';
import '../../data/services/api_service.dart';
import '../../providers/transaction_provider.dart';
import '../../providers/budget_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/profile_provider.dart';

class AppInitializer {
  static Future<void> initialize(WidgetRef ref) async {
    final authState = ref.read(authProvider);
    
    // Only load data if user is authenticated
    if (!authState.isAuthenticated || authState.accessToken == null) {
      return;
    }

    try {
      // Get selected profile
      final profileState = ref.read(profileProvider);
      final statementId = profileState.selectedProfileId;

      // Set auth token on API service
      final apiService = ApiService();
      apiService.setAuthToken(authState.accessToken!);
      
      // Set token refresh callback
      apiService.setTokenRefreshCallback(() async {
        final authNotifier = ref.read(authProvider.notifier);
        final refreshed = await authNotifier.refreshAccessToken();
        if (refreshed) {
          final newAuthState = ref.read(authProvider);
          return newAuthState.accessToken;
        }
        return null;
      });

      // Initialize services with API service
      final transactionService = TransactionService(apiService: apiService);
      final budgetService = BudgetService(apiService: apiService);

      // Load transactions from API (filtered by selected profile if any)
      final transactions = await transactionService.getTransactions(
        statementId: statementId,
      );
      final transactionNotifier = ref.read(transactionProvider.notifier);
      transactionNotifier.clearTransactions();
      transactionNotifier.addTransactions(transactions);

      // Load budgets from API
      final budgets = await budgetService.getBudgets();
      final budgetNotifier = ref.read(budgetProvider.notifier);
      budgetNotifier.clearBudgets();
      for (var budget in budgets) {
        budgetNotifier.addBudget(budget);
      }
    } catch (e) {
      // If loading fails, continue without data
      // User can retry by refreshing
      print('Failed to load initial data: $e');
    }
  }

  /// Reload data when profile changes
  static Future<void> reloadData(WidgetRef ref) async {
    await initialize(ref);
  }
}

