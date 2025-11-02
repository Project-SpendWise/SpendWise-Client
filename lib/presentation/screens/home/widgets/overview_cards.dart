import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spendwise_client/l10n/app_localizations.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../providers/transaction_provider.dart';
import '../../../../providers/filter_provider.dart';
import '../../../../providers/monthly_comparison_provider.dart';
import '../../../widgets/common/custom_card.dart';

class OverviewCards extends ConsumerWidget {
  const OverviewCards({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final filterState = ref.watch(filterProvider);
    final comparison = ref.watch(periodComparisonProvider);
    
    final totalIncome = comparison.currentIncome;
    final totalExpenses = comparison.currentExpenses;
    final savings = comparison.currentSavings;

    return Column(
      children: [
        // Period Selector
        Row(
          children: [
            _PeriodChip(
              label: l10n.today,
              period: TimePeriod.daily,
              isSelected: filterState.timePeriod == TimePeriod.daily,
              onTap: () => ref.read(filterProvider.notifier).setTimePeriod(TimePeriod.daily),
            ),
            const SizedBox(width: AppConstants.spacingSM),
            _PeriodChip(
              label: l10n.last7Days,
              period: TimePeriod.weekly,
              isSelected: filterState.timePeriod == TimePeriod.weekly,
              onTap: () => ref.read(filterProvider.notifier).setTimePeriod(TimePeriod.weekly),
            ),
            const SizedBox(width: AppConstants.spacingSM),
            _PeriodChip(
              label: l10n.thisMonth,
              period: TimePeriod.monthly,
              isSelected: filterState.timePeriod == TimePeriod.monthly,
              onTap: () => ref.read(filterProvider.notifier).setTimePeriod(TimePeriod.monthly),
            ),
          ],
        ),
        const SizedBox(height: AppConstants.spacingLG),
        Row(
          children: [
            Expanded(
              child: _OverviewCard(
                title: l10n.income,
                amount: totalIncome,
                icon: Icons.trending_up,
                color: AppColors.success,
                changePercent: comparison.incomeChangePercent,
                isPositive: true,
              ),
            ),
            const SizedBox(width: AppConstants.spacingLG),
            Expanded(
              child: _OverviewCard(
                title: l10n.expenses,
                amount: totalExpenses,
                icon: Icons.trending_down,
                color: AppColors.error,
                changePercent: comparison.expensesChangePercent,
                isPositive: false, // For expenses, decrease is positive
              ),
            ),
          ],
        ),
        const SizedBox(height: AppConstants.spacingLG),
        _OverviewCard(
          title: l10n.savings,
          amount: savings,
          icon: Icons.savings,
          color: savings >= 0 ? AppColors.success : AppColors.error,
          isFullWidth: true,
          changePercent: comparison.savingsChangePercent,
          isPositive: true,
        ),
      ],
    );
  }
}

class _PeriodChip extends StatelessWidget {
  final String label;
  final TimePeriod period;
  final bool isSelected;
  final VoidCallback onTap;

  const _PeriodChip({
    required this.label,
    required this.period,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(
          horizontal: AppConstants.spacingMD,
          vertical: AppConstants.spacingSM,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary
              : (isDark ? AppColors.surfaceDark : AppColors.surface),
          borderRadius: BorderRadius.circular(AppConstants.radiusSM),
          border: Border.all(
            color: isSelected
                ? AppColors.primary
                : (isDark ? AppColors.borderDark : AppColors.border),
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: AppTextStyles.labelSmall.copyWith(
            color: isSelected
                ? Colors.white
                : (isDark
                    ? AppColors.textPrimaryDark
                    : AppColors.textPrimary),
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}

class _OverviewCard extends StatelessWidget {
  final String title;
  final double amount;
  final IconData icon;
  final Color color;
  final bool isFullWidth;
  final double? changePercent;
  final bool isPositive;

  const _OverviewCard({
    required this.title,
    required this.amount,
    required this.icon,
    required this.color,
    this.isFullWidth = false,
    this.changePercent,
    this.isPositive = true,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    // For expenses, decrease is good (positive)
    final isGood = changePercent != null
        ? (isPositive ? changePercent! >= 0 : changePercent! <= 0)
        : null;
    
    final changeColor = isGood == null
        ? null
        : isGood
            ? AppColors.success
            : AppColors.error;
    
    final changeIcon = isGood == null
        ? null
        : isGood
            ? Icons.trending_up
            : Icons.trending_down;
    
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            color.withOpacity(isDark ? 0.2 : 0.1),
            color.withOpacity(isDark ? 0.1 : 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(AppConstants.radiusMD),
        border: Border.all(
          color: color.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: CustomCard(
        padding: const EdgeInsets.all(AppConstants.spacingLG),
        backgroundColor: Colors.transparent,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: AppTextStyles.labelMedium.copyWith(
                    color: color.withOpacity(0.8),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: color, size: 20),
                ),
              ],
            ),
            const SizedBox(height: AppConstants.spacingMD),
            Text(
              DateFormatter.formatCurrency(amount),
              style: AppTextStyles.h2.copyWith(
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (changePercent != null && changeColor != null && changeIcon != null)
              Padding(
                padding: const EdgeInsets.only(top: AppConstants.spacingSM),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(changeIcon, size: 14, color: changeColor),
                    const SizedBox(width: 4),
                    Text(
                      '${changePercent! >= 0 ? '+' : ''}${changePercent!.toStringAsFixed(1)}%',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: changeColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

