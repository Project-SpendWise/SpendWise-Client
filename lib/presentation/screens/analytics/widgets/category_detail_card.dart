import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spendwise_client/l10n/app_localizations.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../data/models/category.dart';
import '../../../../data/models/transaction.dart';
import '../../../../providers/transaction_provider.dart';
import '../../../../providers/analytics_provider.dart';
import '../../../widgets/common/custom_card.dart';
import '../../../widgets/common/empty_state.dart';

class CategoryDetailCard extends ConsumerStatefulWidget {
  const CategoryDetailCard({super.key});

  @override
  ConsumerState<CategoryDetailCard> createState() => _CategoryDetailCardState();
}

class _CategoryDetailCardState extends ConsumerState<CategoryDetailCard> {
  String? _selectedCategory;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final categories = ref.watch(categoryBreakdownProvider);
    final transactions = ref.watch(transactionProvider);

    if (categories.isEmpty) {
      return CustomCard(
        child: EmptyState(
          icon: Icons.category_outlined,
          title: l10n.noCategory,
          message: l10n.categoryDescription,
        ),
      );
    }

    // Select first category by default
    if (_selectedCategory == null && categories.isNotEmpty) {
      _selectedCategory = categories.first.id;
    }

    final selectedCat = categories.firstWhere(
      (c) => c.id == _selectedCategory,
      orElse: () => categories.first,
    );

    // Get transactions for selected category
    final categoryTransactions = transactions.where((t) =>
      t.type == TransactionType.expense &&
      t.category == selectedCat.name
    ).toList();

    final avgTransaction = categoryTransactions.isNotEmpty
        ? categoryTransactions.fold<double>(0, (sum, t) => sum + t.amount) / categoryTransactions.length
        : 0.0;

    final biggestTransaction = categoryTransactions.isNotEmpty
        ? categoryTransactions.reduce((a, b) => a.amount > b.amount ? a : b)
        : null;

    return CustomCard(
      padding: const EdgeInsets.all(AppConstants.spacingLG),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.categoryDetails,
            style: AppTextStyles.h3,
          ),
          const SizedBox(height: AppConstants.spacingMD),
          // Category selector
          Wrap(
            spacing: AppConstants.spacingSM,
            runSpacing: AppConstants.spacingSM,
            children: categories.map((category) {
              final isSelected = category.id == _selectedCategory;
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedCategory = category.id;
                  });
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected ? category.color : Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isSelected ? category.color : AppColors.border,
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        category.icon,
                        size: 16,
                        color: isSelected ? Colors.white : category.color,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        category.name,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: isSelected ? Colors.white : null,
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: AppConstants.spacingLG),
          // Category stats
          Row(
            children: [
              Expanded(
                child: _StatItem(
                  label: l10n.averageTransaction,
                  value: DateFormatter.formatCurrency(avgTransaction),
                  icon: Icons.calculate_outlined,
                  color: AppColors.info,
                ),
              ),
              const SizedBox(width: AppConstants.spacingMD),
              Expanded(
                child: _StatItem(
                  label: l10n.transactionCount,
                  value: '${categoryTransactions.length}',
                  icon: Icons.receipt_long_outlined,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppConstants.spacingMD),
          Row(
            children: [
              Expanded(
                child: _StatItem(
                  label: 'Toplam',
                  value: DateFormatter.formatCurrency(selectedCat.totalAmount),
                  icon: Icons.attach_money_outlined,
                  color: AppColors.success,
                ),
              ),
              if (biggestTransaction != null)
                Expanded(
                  child: _StatItem(
                    label: l10n.biggestTransaction,
                    value: DateFormatter.formatCurrency(biggestTransaction.amount),
                    icon: Icons.arrow_upward_outlined,
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

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _StatItem({
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

