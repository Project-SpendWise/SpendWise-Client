import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spendwise_client/l10n/app_localizations.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../providers/budget_provider.dart';
import '../../../widgets/common/custom_card.dart';
import '../../../widgets/common/empty_state.dart';

class BudgetTrackingCard extends ConsumerWidget {
  const BudgetTrackingCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final comparisons = ref.watch(budgetComparisonProvider);

    if (comparisons.isEmpty) {
      return CustomCard(
        child: EmptyState(
          icon: Icons.account_balance_wallet_outlined,
          title: l10n.noData,
          message: l10n.uploadDataMessage,
        ),
      );
    }

    return CustomCard(
      padding: const EdgeInsets.all(AppConstants.spacingLG),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                l10n.budgetTracking,
                style: AppTextStyles.h3,
              ),
              Text(
                l10n.thisMonth,
                style: AppTextStyles.bodySmall.copyWith(
                  color: Theme.of(context).textTheme.bodySmall?.color,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppConstants.spacingLG),
          ...comparisons.map((comparison) {
            return _BudgetItem(comparison: comparison);
          }),
        ],
      ),
    );
  }
}

class _BudgetItem extends StatelessWidget {
  final BudgetComparison comparison;

  const _BudgetItem({required this.comparison});

  String _getStatusLabel(AppLocalizations l10n) {
    if (comparison.isOverBudget) {
      return l10n.overBudget;
    } else if (comparison.percentageUsed >= 80) {
      return l10n.approachingBudget;
    } else {
      return l10n.onTrack;
    }
  }

  Color _getStatusColor() {
    if (comparison.isOverBudget) {
      return AppColors.error;
    } else if (comparison.percentageUsed >= 80) {
      return AppColors.warning;
    } else {
      return AppColors.success;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final statusColor = _getStatusColor();
    final statusLabel = _getStatusLabel(l10n);

    return Padding(
      padding: const EdgeInsets.only(bottom: AppConstants.spacingLG),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                comparison.budget.categoryName,
                style: AppTextStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  statusLabel,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: statusColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppConstants.spacingSM),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${DateFormatter.formatCurrency(comparison.actualSpending)} / ${DateFormatter.formatCurrency(comparison.budget.amount)}',
                style: AppTextStyles.bodyMedium,
              ),
              Text(
                '${comparison.percentageUsed.toStringAsFixed(1)}%',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: statusColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppConstants.spacingSM),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: comparison.percentageUsed / 100,
              backgroundColor: AppColors.border.withOpacity(0.3),
              valueColor: AlwaysStoppedAnimation<Color>(
                comparison.isOverBudget ? AppColors.error : statusColor,
              ),
              minHeight: 8,
            ),
          ),
          if (comparison.remaining >= 0)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                '${l10n.remaining}: ${DateFormatter.formatCurrency(comparison.remaining)}',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.success,
                ),
              ),
            )
          else
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                '${l10n.overBudget}: ${DateFormatter.formatCurrency(-comparison.remaining)}',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.error,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

