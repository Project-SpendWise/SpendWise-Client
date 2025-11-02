import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spendwise_client/l10n/app_localizations.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../providers/transaction_provider.dart';
import '../../../widgets/common/custom_card.dart';
import '../../../widgets/common/empty_state.dart';

class InsightsCard extends ConsumerWidget {
  const InsightsCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final totalIncome = ref.watch(totalIncomeProvider);
    final totalExpenses = ref.watch(totalExpensesProvider);
    final savings = ref.watch(savingsProvider);
    final categoryBreakdown = ref.watch(categoryBreakdownProvider);

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
                size: 24,
              ),
              const SizedBox(width: AppConstants.spacingMD),
              Text(
                l10n.insights,
                style: AppTextStyles.h4,
              ),
            ],
          ),
          const SizedBox(height: AppConstants.spacingLG),
          if (savingsPercentage < 10 && savingsPercentage >= 0)
            _InsightItem(
              icon: Icons.trending_down,
              title: l10n.lowSavingsRate,
              message: l10n.lowSavingsMessage(savingsPercentage.toStringAsFixed(1)),
              color: AppColors.warning,
            ),
          if (savingsPercentage < 0)
            _InsightItem(
              icon: Icons.warning,
              title: l10n.excessiveSpending,
              message: l10n.excessiveSpendingMessage,
              color: AppColors.error,
            ),
          if (topCategory != null)
            _InsightItem(
              icon: Icons.category,
              title: l10n.highestSpendingCategory,
              message: l10n.highestSpendingMessage(topCategory.name),
              color: AppColors.info,
            ),
          if (savingsPercentage >= 20)
            _InsightItem(
              icon: Icons.check_circle,
              title: l10n.greatJob,
              message: l10n.greatJobMessage,
              color: AppColors.success,
            ),
        ],
      ),
    );
  }
}

class _InsightItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final Color color;

  const _InsightItem({
    required this.icon,
    required this.title,
    required this.message,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppConstants.spacingLG),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: AppConstants.spacingMD),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.labelLarge.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  message,
                  style: AppTextStyles.bodySmall,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

