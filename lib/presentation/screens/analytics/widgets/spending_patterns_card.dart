import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spendwise_client/l10n/app_localizations.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../data/models/transaction.dart';
import '../../../../providers/analytics_provider.dart';
import '../../../../providers/transaction_provider.dart';
import '../../../widgets/common/custom_card.dart';
import '../../../widgets/common/empty_state.dart';

class SpendingPatternsCard extends ConsumerWidget {
  const SpendingPatternsCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final transactions = ref.watch(transactionProvider);
    final weeklyPatterns = ref.watch(weeklyPatternsProvider);

    if (transactions.isEmpty) {
      return CustomCard(
        child: EmptyState(
          icon: Icons.trending_up_outlined,
          title: l10n.noData,
          message: l10n.uploadDataMessage,
        ),
      );
    }

    // Calculate weekend vs weekday spending
    final now = DateTime.now();
    final fourWeeksAgo = now.subtract(const Duration(days: 28));
    final recentTransactions = transactions.where((t) =>
      t.type == TransactionType.expense &&
      t.date.isAfter(fourWeeksAgo)
    ).toList();

    double weekendSpending = 0;
    double weekdaySpending = 0;
    int weekendCount = 0;
    int weekdayCount = 0;

    for (var transaction in recentTransactions) {
      final isWeekend = transaction.date.weekday == 6 || transaction.date.weekday == 7;
      if (isWeekend) {
        weekendSpending += transaction.amount;
        weekendCount++;
      } else {
        weekdaySpending += transaction.amount;
        weekdayCount++;
      }
    }

    final weekendAvg = weekendCount > 0 ? (weekendSpending / weekendCount).toDouble() : 0.0;
    final weekdayAvg = weekdayCount > 0 ? (weekdaySpending / weekdayCount).toDouble() : 0.0;
    final weekendPercent = (weekendSpending + weekdaySpending) > 0
        ? (weekendSpending / (weekendSpending + weekdaySpending) * 100)
        : 0;

    // Find peak spending day
    final maxDay = weeklyPatterns.isNotEmpty
        ? weeklyPatterns.reduce((a, b) => a.averageSpending > b.averageSpending ? a : b)
        : null;

    final dayNames = ['Pazartesi', 'Salı', 'Çarşamba', 'Perşembe', 'Cuma', 'Cumartesi', 'Pazar'];

    return CustomCard(
      padding: const EdgeInsets.all(AppConstants.spacingLG),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.spendingPatterns,
            style: AppTextStyles.h3,
          ),
          const SizedBox(height: AppConstants.spacingLG),
          if (maxDay != null)
            _PatternInsightCard(
              icon: Icons.calendar_today,
              title: l10n.peakSpendingDays,
              description: '${dayNames[maxDay.dayOfWeek - 1]} gününde en çok harcama yapıyorsunuz (${DateFormatter.formatCurrency(maxDay.averageSpending)})',
              color: AppColors.primary,
            ),
          const SizedBox(height: AppConstants.spacingMD),
          if (weekendPercent > 50)
            _PatternInsightCard(
              icon: Icons.weekend,
              title: 'Hafta Sonu Harcamaları',
              description: 'Harcamalarınızın %${weekendPercent.toStringAsFixed(1)}\'i hafta sonu yapılıyor',
              color: AppColors.warning,
            ),
          const SizedBox(height: AppConstants.spacingMD),
          Row(
            children: [
              Expanded(
                child: _PatternStatCard(
                  label: 'Hafta İçi Ort.',
                  value: DateFormatter.formatCurrency(weekdayAvg),
                  icon: Icons.today,
                  color: AppColors.info,
                ),
              ),
              const SizedBox(width: AppConstants.spacingMD),
              Expanded(
                child: _PatternStatCard(
                  label: 'Hafta Sonu Ort.',
                  value: DateFormatter.formatCurrency(weekendAvg),
                  icon: Icons.weekend,
                  color: AppColors.warning,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PatternInsightCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final Color color;

  const _PatternInsightCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.spacingMD),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3), width: 1),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
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
                  style: AppTextStyles.labelMedium.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
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

class _PatternStatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _PatternStatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.spacingMD),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.2), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: AppConstants.spacingSM),
          Text(
            label,
            style: AppTextStyles.labelSmall,
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: AppTextStyles.bodyMedium.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

