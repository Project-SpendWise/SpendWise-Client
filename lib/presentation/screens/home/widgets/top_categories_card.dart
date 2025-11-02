import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spendwise_client/l10n/app_localizations.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../providers/transaction_provider.dart';
import '../../../widgets/common/custom_card.dart';
import '../../../widgets/common/empty_state.dart';

class TopCategoriesCard extends ConsumerWidget {
  const TopCategoriesCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final categories = ref.watch(categoryBreakdownProvider);
    final totalExpenses = ref.watch(totalExpensesProvider);

    if (categories.isEmpty) {
      return CustomCard(
        child: EmptyState(
          icon: Icons.category_outlined,
          title: l10n.noCategory,
          message: l10n.categoryDescription,
        ),
      );
    }

    final topCategories = categories.take(4).toList();

    return CustomCard(
      padding: const EdgeInsets.all(AppConstants.spacingLG),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.topCategories,
            style: AppTextStyles.h3,
          ),
          const SizedBox(height: AppConstants.spacingLG),
          ...topCategories.asMap().entries.map((entry) {
            final index = entry.key;
            final category = entry.value;
            final percentage = totalExpenses > 0
                ? (category.totalAmount / totalExpenses * 100)
                : 0.0;

            return Padding(
              padding: EdgeInsets.only(
                bottom: index < topCategories.length - 1
                    ? AppConstants.spacingMD
                    : 0,
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: category.color.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Icon(
                          category.icon,
                          color: category.color,
                          size: 18,
                        ),
                      ),
                      const SizedBox(width: AppConstants.spacingMD),
                      Expanded(
                        child: Text(
                          category.name,
                          style: AppTextStyles.bodyMedium.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      Text(
                        DateFormatter.formatCurrency(category.totalAmount),
                        style: AppTextStyles.bodyMedium.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: AppConstants.spacingSM),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: category.color.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${percentage.toStringAsFixed(0)}%',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: category.color,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppConstants.spacingSM),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: percentage / 100,
                      backgroundColor: category.color.withOpacity(0.2),
                      valueColor: AlwaysStoppedAnimation<Color>(category.color),
                      minHeight: 4,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

