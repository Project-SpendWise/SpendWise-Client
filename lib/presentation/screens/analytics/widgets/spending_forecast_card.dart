import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spendwise_client/l10n/app_localizations.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../providers/analytics_provider.dart';
import '../../../widgets/common/custom_card.dart';
import '../../../widgets/common/empty_state.dart';

class SpendingForecastCard extends ConsumerWidget {
  const SpendingForecastCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final forecast = ref.watch(spendingForecastProvider);

    if (forecast.nextMonth == 0) {
      return CustomCard(
        child: EmptyState(
          icon: Icons.trending_up_outlined,
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
            children: [
              Icon(
                Icons.auto_awesome,
                color: AppColors.warning,
                size: 24,
              ),
              const SizedBox(width: AppConstants.spacingSM),
              Text(
                l10n.forecast,
                style: AppTextStyles.h3,
              ),
            ],
          ),
          const SizedBox(height: AppConstants.spacingMD),
          Text(
            l10n.predictedSpending,
            style: AppTextStyles.bodySmall.copyWith(
              color: Theme.of(context).textTheme.bodySmall?.color,
            ),
          ),
          const SizedBox(height: AppConstants.spacingLG),
          Container(
            padding: const EdgeInsets.all(AppConstants.spacingLG),
            decoration: BoxDecoration(
              color: AppColors.warning.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.warning.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.arrow_forward, color: AppColors.warning, size: 28),
                const SizedBox(width: AppConstants.spacingMD),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Gelecek Ay',
                        style: AppTextStyles.labelMedium,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        DateFormatter.formatCurrency(forecast.nextMonth),
                        style: AppTextStyles.h2.copyWith(
                          color: AppColors.warning,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (forecast.byCategory.isNotEmpty) ...[
            const SizedBox(height: AppConstants.spacingLG),
            Text(
              'Kategori Bazında Tahmin',
              style: AppTextStyles.labelLarge.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: AppConstants.spacingMD),
            ...forecast.byCategory.entries.take(5).map((entry) {
              return Padding(
                padding: const EdgeInsets.only(bottom: AppConstants.spacingSM),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      entry.key,
                      style: AppTextStyles.bodyMedium,
                    ),
                    Text(
                      DateFormatter.formatCurrency(entry.value),
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ],
      ),
    );
  }
}

