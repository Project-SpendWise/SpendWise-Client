import 'package:flutter/material.dart';
import 'package:spendwise_client/l10n/app_localizations.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../widgets/layout/app_scaffold.dart';
import '../../widgets/common/time_period_filter.dart';
import 'widgets/category_breakdown.dart';
import 'widgets/spending_trends.dart';
import 'widgets/insights_card.dart';
import 'widgets/sankey_diagram.dart';
import 'widgets/monthly_trends_chart.dart';
import 'widgets/category_trends_chart.dart';
import 'widgets/weekly_patterns_chart.dart';
import 'widgets/income_expenses_chart.dart';
import 'widgets/budget_tracking_card.dart';
import 'widgets/spending_patterns_card.dart';
import 'widgets/year_over_year_chart.dart';
import 'widgets/category_detail_card.dart';
import 'widgets/spending_forecast_card.dart';

class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return AppScaffold(
      title: l10n.analytics,
      currentIndex: 2,
      showBottomNav: false,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppConstants.spacingLG),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Time Period Filter
            const TimePeriodFilter(),
            const SizedBox(height: AppConstants.spacingXL),

            // Main Charts Section
            // Sankey Diagram
            const SankeyDiagram(),
            const SizedBox(height: AppConstants.spacingXL),

            // Income vs Expenses
            const IncomeExpensesChart(),
            const SizedBox(height: AppConstants.spacingXL),

            // Monthly Trends
            const MonthlyTrendsChart(),
            const SizedBox(height: AppConstants.spacingXL),

            // Category Analysis Section
            Text(
              l10n.categoryDistribution,
              style: AppTextStyles.h3,
            ),
            const SizedBox(height: AppConstants.spacingLG),
            const CategoryBreakdown(),
            const SizedBox(height: AppConstants.spacingXL),

            // Category Trends
            const CategoryTrendsChart(),
            const SizedBox(height: AppConstants.spacingXL),

            // Category Details
            const CategoryDetailCard(),
            const SizedBox(height: AppConstants.spacingXL),

            // Patterns Section
            // Weekly Patterns
            const WeeklyPatternsChart(),
            const SizedBox(height: AppConstants.spacingXL),

            // Spending Patterns
            const SpendingPatternsCard(),
            const SizedBox(height: AppConstants.spacingXL),

            // Budget Tracking
            const BudgetTrackingCard(),
            const SizedBox(height: AppConstants.spacingXL),

            // Forecasts
            const SpendingForecastCard(),
            const SizedBox(height: AppConstants.spacingXL),

            // Year-over-Year
            const YearOverYearChart(),
            const SizedBox(height: AppConstants.spacingXL),

            // Spending Trends (Daily/Weekly based on filter)
            Text(
              l10n.spendingTrends,
              style: AppTextStyles.h3,
            ),
            const SizedBox(height: AppConstants.spacingLG),
            const SpendingTrends(),
            const SizedBox(height: AppConstants.spacingXL),

            // Insights
            Text(
              l10n.insights,
              style: AppTextStyles.h3,
            ),
            const SizedBox(height: AppConstants.spacingLG),
            const InsightsCard(),
          ],
        ),
      ),
    );
  }
}

