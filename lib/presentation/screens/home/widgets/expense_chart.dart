import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spendwise_client/l10n/app_localizations.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../data/models/category.dart';
import '../../../../providers/transaction_provider.dart';
import '../../../widgets/common/custom_card.dart';
import '../../../widgets/common/empty_state.dart';

class ExpenseChart extends ConsumerWidget {
  const ExpenseChart({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final categories = ref.watch(categoryBreakdownProvider);

    if (categories.isEmpty) {
      return CustomCard(
        child: EmptyState(
          icon: Icons.pie_chart_outline,
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
          Text(
            l10n.expenseBreakdown,
            style: AppTextStyles.h3,
          ),
          const SizedBox(height: AppConstants.spacingXL),
          SizedBox(
            height: 220,
            child: PieChart(
              PieChartData(
                sectionsSpace: 2,
                centerSpaceRadius: 70,
                sections: categories.asMap().entries.map((entry) {
                  final index = entry.key;
                  final category = entry.value;
                  final percentage = categories.fold<double>(0, (sum, c) => sum + c.totalAmount) > 0
                      ? (category.totalAmount / categories.fold<double>(0, (sum, c) => sum + c.totalAmount) * 100)
                      : 0;
                  return PieChartSectionData(
                    value: category.totalAmount,
                    title: percentage > 5 ? '${percentage.toStringAsFixed(0)}%' : '',
                    color: category.color,
                    radius: 55,
                    titleStyle: AppTextStyles.bodySmall.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          const SizedBox(height: AppConstants.spacingLG),
          Wrap(
            spacing: AppConstants.spacingMD,
            runSpacing: AppConstants.spacingMD,
            children: categories.map((category) {
              final total = categories.fold<double>(0, (sum, c) => sum + c.totalAmount);
              final percentage = total > 0 ? (category.totalAmount / total * 100) : 0;
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: category.color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: category.color.withOpacity(0.3), width: 1),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(category.icon, color: category.color, size: 16),
                    const SizedBox(width: 6),
                    Text(
                      category.name,
                      style: AppTextStyles.bodySmall.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${percentage.toStringAsFixed(1)}%',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: category.color,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

