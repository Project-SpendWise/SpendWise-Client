import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spendwise_client/l10n/app_localizations.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../providers/monthly_comparison_provider.dart';
import '../../../../providers/filter_provider.dart';
import '../../../widgets/common/custom_card.dart';

class MonthlyComparisonCard extends ConsumerWidget {
  const MonthlyComparisonCard({super.key});

  String _getPeriodLabel(TimePeriod period, AppLocalizations l10n) {
    switch (period) {
      case TimePeriod.daily:
        return l10n.today;
      case TimePeriod.weekly:
        return l10n.last7Days;
      case TimePeriod.monthly:
        return l10n.thisMonth;
      case TimePeriod.yearly:
        return l10n.thisYear;
    }
  }

  String _getPreviousPeriodLabel(TimePeriod period, AppLocalizations l10n) {
    switch (period) {
      case TimePeriod.daily:
        return l10n.yesterday;
      case TimePeriod.weekly:
        return l10n.vsLastWeek;
      case TimePeriod.monthly:
        return l10n.vsLastMonth;
      case TimePeriod.yearly:
        return l10n.vsLastYear;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final comparison = ref.watch(periodComparisonProvider);
    final period = ref.watch(filterProvider).timePeriod;

    return CustomCard(
      padding: const EdgeInsets.all(AppConstants.spacingLG),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.monthlyComparison,
            style: AppTextStyles.h3,
          ),
          const SizedBox(height: AppConstants.spacingSM),
          Text(
            _getPreviousPeriodLabel(period, l10n),
            style: AppTextStyles.bodySmall.copyWith(
              color: Theme.of(context).textTheme.bodySmall?.color,
            ),
          ),
          const SizedBox(height: AppConstants.spacingLG),
          Row(
            children: [
              Expanded(
                child: _ComparisonItem(
                  label: l10n.income,
                  current: comparison.currentIncome,
                  previous: comparison.previousIncome,
                  changePercent: comparison.incomeChangePercent,
                  isPositive: true,
                ),
              ),
              const SizedBox(width: AppConstants.spacingMD),
              Expanded(
                child: _ComparisonItem(
                  label: l10n.expenses,
                  current: comparison.currentExpenses,
                  previous: comparison.previousExpenses,
                  changePercent: comparison.expensesChangePercent,
                  isPositive: false, // For expenses, decrease is positive
                ),
              ),
              const SizedBox(width: AppConstants.spacingMD),
              Expanded(
                child: _ComparisonItem(
                  label: l10n.savings,
                  current: comparison.currentSavings,
                  previous: comparison.previousSavings,
                  changePercent: comparison.savingsChangePercent,
                  isPositive: true,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ComparisonItem extends StatelessWidget {
  final String label;
  final double current;
  final double previous;
  final double changePercent;
  final bool isPositive;

  const _ComparisonItem({
    required this.label,
    required this.current,
    required this.previous,
    required this.changePercent,
    required this.isPositive,
  });

  @override
  Widget build(BuildContext context) {
    // For expenses, decrease is good (positive)
    final isGood = isPositive
        ? changePercent >= 0
        : changePercent <= 0;
    
    final color = isGood ? AppColors.success : AppColors.error;
    final icon = isGood ? Icons.trending_up : Icons.trending_down;

    return Container(
      padding: const EdgeInsets.all(AppConstants.spacingMD),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: color.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: AppTextStyles.labelSmall,
          ),
          const SizedBox(height: AppConstants.spacingSM),
          Text(
            DateFormatter.formatCurrency(current),
            style: AppTextStyles.bodyMedium.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 14, color: color),
              const SizedBox(width: 4),
              Text(
                '${changePercent >= 0 ? '+' : ''}${changePercent.toStringAsFixed(1)}%',
                style: AppTextStyles.bodySmall.copyWith(
                  color: color,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

