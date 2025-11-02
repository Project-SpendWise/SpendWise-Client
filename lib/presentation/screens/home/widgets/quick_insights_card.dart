import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spendwise_client/l10n/app_localizations.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../providers/transaction_provider.dart';
import '../../../../providers/monthly_comparison_provider.dart';
import '../../../widgets/common/custom_card.dart';
import '../../../widgets/common/empty_state.dart';

class QuickInsightsCard extends ConsumerWidget {
  const QuickInsightsCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final totalIncome = ref.watch(currentPeriodIncomeProvider);
    final totalExpenses = ref.watch(currentPeriodExpensesProvider);
    final savings = ref.watch(currentPeriodSavingsProvider);
    final categoryBreakdown = ref.watch(categoryBreakdownProvider);
    final comparison = ref.watch(periodComparisonProvider);

    if (totalExpenses == 0) {
      return CustomCard(
        child: EmptyState(
          icon: Icons.lightbulb_outline,
          title: l10n.noData,
          message: l10n.uploadDataMessage,
        ),
      );
    }

    // Find top spending category
    final topCategory = categoryBreakdown.isNotEmpty
        ? categoryBreakdown.first
        : null;

    // Calculate savings percentage
    final savingsPercentage = totalIncome > 0
        ? (savings / totalIncome * 100)
        : 0.0;

    // Get top 1-2 insights
    final insights = <_QuickInsight>[];

    if (savingsPercentage < 10 && savingsPercentage >= 0) {
      insights.add(_QuickInsight(
        icon: Icons.trending_down,
        message: l10n.lowSavingsMessage(savingsPercentage.toStringAsFixed(1)),
        color: AppColors.warning,
      ));
    }

    if (savingsPercentage < 0) {
      insights.add(_QuickInsight(
        icon: Icons.warning,
        message: l10n.excessiveSpendingMessage,
        color: AppColors.error,
      ));
    }

    if (topCategory != null && insights.length < 2) {
      insights.add(_QuickInsight(
        icon: Icons.category,
        message: l10n.highestSpendingMessage(topCategory.name),
        color: AppColors.info,
      ));
    }

    if (savingsPercentage >= 20 && insights.isEmpty) {
      insights.add(_QuickInsight(
        icon: Icons.check_circle,
        message: l10n.greatJobMessage,
        color: AppColors.success,
      ));
    }

    if (insights.isEmpty) {
      return const SizedBox.shrink();
    }

    return CustomCard(
      padding: const EdgeInsets.all(AppConstants.spacingLG),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.lightbulb,
                color: AppColors.warning,
                size: 20,
              ),
              const SizedBox(width: AppConstants.spacingSM),
              Text(
                l10n.insights,
                style: AppTextStyles.h4,
              ),
            ],
          ),
          const SizedBox(height: AppConstants.spacingMD),
          ...insights.take(2).map((insight) => Padding(
                padding: const EdgeInsets.only(bottom: AppConstants.spacingMD),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: insight.color.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Icon(insight.icon, color: insight.color, size: 16),
                    ),
                    const SizedBox(width: AppConstants.spacingSM),
                    Expanded(
                      child: Text(
                        insight.message,
                        style: AppTextStyles.bodySmall,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }
}

class _QuickInsight {
  final IconData icon;
  final String message;
  final Color color;

  _QuickInsight({
    required this.icon,
    required this.message,
    required this.color,
  });
}

