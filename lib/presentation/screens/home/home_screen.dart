import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spendwise_client/l10n/app_localizations.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/app_initializer.dart';
import '../../widgets/layout/app_scaffold.dart';
import 'widgets/overview_cards.dart';
import 'widgets/expense_chart.dart';
import 'widgets/recent_transactions.dart';
import 'widgets/spending_trends_card.dart';
import 'widgets/monthly_comparison_card.dart';
import 'widgets/quick_insights_card.dart';
import 'widgets/top_categories_card.dart';
import 'widgets/quick_stats_card.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // Initialize mock data when home screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      AppInitializer.initialize(ref);
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return AppScaffold(
      title: l10n.appName,
      currentIndex: 0,
      showBottomNav: false,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppConstants.spacingLG),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Greeting
            Text(
              '${l10n.hello} 👋',
              style: AppTextStyles.h2,
            ),
            const SizedBox(height: 4),
            Text(
              l10n.appSlogan,
              style: AppTextStyles.bodyMedium.copyWith(
                color: Theme.of(context).textTheme.bodySmall?.color,
              ),
            ),
            const SizedBox(height: AppConstants.spacingXL),

            // Overview Cards (with period selector)
            const OverviewCards(),
            const SizedBox(height: AppConstants.spacingXL),

            // Spending Trends (compact)
            const SpendingTrendsCard(),
            const SizedBox(height: AppConstants.spacingXL),

            // Monthly Comparison
            const MonthlyComparisonCard(),
            const SizedBox(height: AppConstants.spacingXL),

            // Top Categories
            const TopCategoriesCard(),
            const SizedBox(height: AppConstants.spacingXL),

            // Quick Stats
            const QuickStatsCard(),
            const SizedBox(height: AppConstants.spacingXL),

            // Quick Insights
            const QuickInsightsCard(),
            const SizedBox(height: AppConstants.spacingXL),

            // Expense Chart
            const ExpenseChart(),
            const SizedBox(height: AppConstants.spacingXL),

            // Recent Transactions
            Text(
              l10n.recentTransactions,
              style: AppTextStyles.h3,
            ),
            const SizedBox(height: AppConstants.spacingLG),
            const RecentTransactions(),
          ],
        ),
      ),
    );
  }
}

