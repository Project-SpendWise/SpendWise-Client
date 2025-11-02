import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spendwise_client/l10n/app_localizations.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../data/models/category.dart';
import '../../../../providers/quick_stats_provider.dart';
import '../../../widgets/common/custom_card.dart';

class QuickStatsCard extends ConsumerWidget {
  const QuickStatsCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final stats = ref.watch(quickStatsProvider);

    // Find category icon for most used category
    final category = Category.defaultCategories.firstWhere(
      (c) => c.name == stats.mostUsedCategory,
      orElse: () => Category.defaultCategories.last,
    );

    return CustomCard(
      padding: const EdgeInsets.all(AppConstants.spacingLG),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.quickStats,
            style: AppTextStyles.h3,
          ),
          const SizedBox(height: AppConstants.spacingLG),
          Row(
            children: [
              Expanded(
                child: _StatItem(
                  icon: Icons.trending_up,
                  label: l10n.averageDailySpending,
                  value: DateFormatter.formatCurrency(stats.averageDailySpending),
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: AppConstants.spacingMD),
              Expanded(
                child: _StatItem(
                  icon: Icons.attach_money,
                  label: l10n.biggestExpense,
                  value: DateFormatter.formatCurrency(stats.biggestExpense),
                  color: AppColors.error,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppConstants.spacingMD),
          Row(
            children: [
              Expanded(
                child: _StatItem(
                  icon: Icons.receipt_long,
                  label: l10n.totalTransactions,
                  value: '${stats.transactionsCount}',
                  color: AppColors.info,
                ),
              ),
              const SizedBox(width: AppConstants.spacingMD),
              Expanded(
                child: _StatItem(
                  icon: category.icon,
                  label: l10n.mostUsedCategory,
                  value: stats.mostUsedCategory,
                  color: category.color,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatItem({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(AppConstants.spacingMD),
      decoration: BoxDecoration(
        color: color.withOpacity(isDark ? 0.15 : 0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: color.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(height: AppConstants.spacingSM),
          Text(
            label,
            style: AppTextStyles.labelSmall,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: AppTextStyles.bodyMedium.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

