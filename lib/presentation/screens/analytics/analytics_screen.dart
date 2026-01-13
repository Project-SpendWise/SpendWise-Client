import 'package:flutter/material.dart';
import 'package:spendwise_client/l10n/app_localizations.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../widgets/layout/app_scaffold.dart';
import '../../widgets/common/time_period_filter.dart';
import '../../widgets/common/error_boundary.dart';
import 'widgets/spending_trends.dart';
import 'widgets/monthly_trends_chart.dart';
import 'widgets/income_expenses_chart.dart';
import 'widgets/spending_patterns_card.dart';
import 'widgets/year_over_year_chart.dart';
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
            // Income vs Expenses
            ErrorBoundary(
              errorMessage: 'Failed to load income vs expenses chart',
              child: const IncomeExpensesChart(),
            ),
            const SizedBox(height: AppConstants.spacingXL),

            // Monthly Trends
            ErrorBoundary(
              errorMessage: 'Failed to load monthly trends',
              child: const MonthlyTrendsChart(),
            ),
            const SizedBox(height: AppConstants.spacingXL),

            // Spending Patterns
            ErrorBoundary(
              errorMessage: 'Failed to load spending patterns',
              child: const SpendingPatternsCard(),
            ),
            const SizedBox(height: AppConstants.spacingXL),

            // Forecasts
            ErrorBoundary(
              errorMessage: 'Failed to load spending forecast',
              child: const SpendingForecastCard(),
            ),
            const SizedBox(height: AppConstants.spacingXL),

            // Year-over-Year
            ErrorBoundary(
              errorMessage: 'Failed to load year-over-year comparison',
              child: const YearOverYearChart(),
            ),
            const SizedBox(height: AppConstants.spacingXL),

            // Spending Trends (Daily/Weekly based on filter)
            Text(
              l10n.spendingTrends,
              style: AppTextStyles.h3,
            ),
            const SizedBox(height: AppConstants.spacingLG),
            ErrorBoundary(
              errorMessage: 'Failed to load spending trends',
              child: const SpendingTrends(),
            ),
          ],
        ),
      ),
    );
  }
}

