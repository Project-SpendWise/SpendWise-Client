import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:spendwise_client/l10n/app_localizations.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../providers/analytics_provider.dart';
import '../../../widgets/common/custom_card.dart';
import '../../../widgets/common/empty_state.dart';

class CategoryTrendsChart extends ConsumerStatefulWidget {
  const CategoryTrendsChart({super.key});

  @override
  ConsumerState<CategoryTrendsChart> createState() => _CategoryTrendsChartState();
}

class _CategoryTrendsChartState extends ConsumerState<CategoryTrendsChart> {
  final Set<String> _visibleCategories = {};

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final trends = ref.watch(categoryTrendsProvider);

    if (trends.isEmpty) {
      return CustomCard(
        child: EmptyState(
          icon: Icons.show_chart_outlined,
          title: l10n.noData,
          message: l10n.uploadDataMessage,
        ),
      );
    }

    // Initialize visible categories
    if (_visibleCategories.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        setState(() {
          _visibleCategories.addAll(trends.map((t) => t.categoryName));
        });
      });
    }

    // Find max value
    double maxValue = 0;
    for (var trend in trends) {
      for (var data in trend.monthlyData) {
        if (_visibleCategories.contains(trend.categoryName)) {
          maxValue = maxValue > data.amount ? maxValue : data.amount;
        }
      }
    }
    maxValue = maxValue > 0 ? maxValue * 1.2 : 1000.0; // Ensure maxValue is never zero

    return CustomCard(
      padding: const EdgeInsets.all(AppConstants.spacingLG),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.categoryTrends,
            style: AppTextStyles.h3,
          ),
          const SizedBox(height: AppConstants.spacingMD),
          // Legend with toggle
          Wrap(
            spacing: AppConstants.spacingMD,
            runSpacing: AppConstants.spacingSM,
            children: trends.map((trend) {
              final isVisible = _visibleCategories.contains(trend.categoryName);
              return GestureDetector(
                onTap: () {
                  setState(() {
                    if (isVisible) {
                      _visibleCategories.remove(trend.categoryName);
                    } else {
                      _visibleCategories.add(trend.categoryName);
                    }
                  });
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: isVisible
                        ? trend.color.withOpacity(0.1)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isVisible ? trend.color : AppColors.border,
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: isVisible ? trend.color : trend.color.withOpacity(0.3),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        trend.categoryName,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: isVisible ? null : AppColors.textTertiary,
                          fontWeight: isVisible ? FontWeight.w600 : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: AppConstants.spacingLG),
          SizedBox(
            height: 250,
            child: LineChart(
              LineChartData(
                minY: 0,
                maxY: maxValue,
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: maxValue > 0 ? maxValue / 5 : 200.0, // Ensure interval is never zero
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: AppColors.border.withOpacity(0.3),
                      strokeWidth: 1,
                      dashArray: [3, 3],
                    );
                  },
                ),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 50,
                      getTitlesWidget: (value, meta) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: Text(
                            '₺${value.toInt()}',
                            style: AppTextStyles.bodySmall.copyWith(fontSize: 10),
                          ),
                        );
                      },
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        if (trends.isNotEmpty && value.toInt() >= 0 && value.toInt() < trends.first.monthlyData.length) {
                          final month = trends.first.monthlyData[value.toInt()].month;
                          final monthNames = ['Oca', 'Şub', 'Mar', 'Nis', 'May', 'Haz', 'Tem', 'Ağu', 'Eyl', 'Eki', 'Kas', 'Ara'];
                          return Text(
                            monthNames[month.month - 1],
                            style: AppTextStyles.bodySmall.copyWith(fontSize: 10),
                          );
                        }
                        return const Text('');
                      },
                    ),
                  ),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                borderData: FlBorderData(show: false),
                lineBarsData: trends.where((t) => _visibleCategories.contains(t.categoryName)).map((trend) {
                  final spots = trend.monthlyData.asMap().entries.map((e) {
                    return FlSpot(e.key.toDouble(), e.value.amount);
                  }).toList();

                  return LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    color: trend.color,
                    barWidth: 3,
                    dotData: FlDotData(
                      show: false,
                    ),
                    belowBarData: BarAreaData(
                      show: false,
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

