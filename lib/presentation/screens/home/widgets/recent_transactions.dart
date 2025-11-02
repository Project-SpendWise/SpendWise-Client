import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spendwise_client/l10n/app_localizations.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../data/models/transaction.dart';
import '../../../../data/models/category.dart';
import '../../../../providers/transaction_provider.dart';
import '../../../widgets/common/custom_card.dart';
import '../../../widgets/common/empty_state.dart';

class RecentTransactions extends ConsumerWidget {
  const RecentTransactions({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final transactions = ref.watch(transactionProvider);

    if (transactions.isEmpty) {
      return CustomCard(
        child: EmptyState(
          icon: Icons.receipt_long_outlined,
          title: l10n.noData,
          message: l10n.uploadDataMessage,
        ),
      );
    }

    final recent = transactions
        .where((t) => t.type == TransactionType.expense)
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));

    return CustomCard(
      padding: EdgeInsets.zero,
      child: Column(
        children: recent.take(5).map((transaction) {
          return _TransactionItem(transaction: transaction);
        }).toList(),
      ),
    );
  }
}

class _TransactionItem extends StatelessWidget {
  final Transaction transaction;

  const _TransactionItem({required this.transaction});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(AppConstants.spacingLG),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: isDark ? AppColors.borderDark : AppColors.border,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Builder(
            builder: (context) {
              // Find category icon
              final category = Category.defaultCategories.firstWhere(
                (c) => c.name == transaction.category,
                orElse: () => Category.defaultCategories.last,
              );
              return Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: category.color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  category.icon,
                  color: category.color,
                  size: 20,
                ),
              );
            },
          ),
          const SizedBox(width: AppConstants.spacingLG),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transaction.description,
                  style: AppTextStyles.bodyMedium,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      DateFormatter.formatShort(transaction.date),
                      style: AppTextStyles.bodySmall,
                    ),
                    if (transaction.category != null) ...[
                      const SizedBox(width: 8),
                      Text(
                        '•',
                        style: AppTextStyles.bodySmall,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        transaction.category!,
                        style: AppTextStyles.bodySmall,
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          Text(
            DateFormatter.formatCurrency(transaction.amount),
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.error,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

