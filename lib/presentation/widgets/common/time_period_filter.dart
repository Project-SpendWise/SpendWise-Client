import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spendwise_client/l10n/app_localizations.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../providers/filter_provider.dart';

class TimePeriodFilter extends ConsumerWidget {
  const TimePeriodFilter({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final filterState = ref.watch(filterProvider);
    final filterNotifier = ref.read(filterProvider.notifier);

    return Container(
      padding: const EdgeInsets.symmetric(vertical: AppConstants.spacingSM),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _FilterChip(
              label: l10n.today,
              isSelected: filterState.timePeriod == TimePeriod.daily,
              onTap: () => filterNotifier.setTimePeriod(TimePeriod.daily),
            ),
            const SizedBox(width: AppConstants.spacingSM),
            _FilterChip(
              label: l10n.last7Days,
              isSelected: filterState.timePeriod == TimePeriod.weekly,
              onTap: () => filterNotifier.setTimePeriod(TimePeriod.weekly),
            ),
            const SizedBox(width: AppConstants.spacingSM),
            _FilterChip(
              label: l10n.thisMonth,
              isSelected: filterState.timePeriod == TimePeriod.monthly,
              onTap: () => filterNotifier.setTimePeriod(TimePeriod.monthly),
            ),
            const SizedBox(width: AppConstants.spacingSM),
            _FilterChip(
              label: l10n.thisYear,
              isSelected: filterState.timePeriod == TimePeriod.yearly,
              onTap: () => filterNotifier.setTimePeriod(TimePeriod.yearly),
            ),
          ],
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
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
          style: AppTextStyles.labelMedium.copyWith(
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

