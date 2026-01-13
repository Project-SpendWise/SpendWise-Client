import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:spendwise_client/l10n/app_localizations.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../data/models/transaction.dart';
import '../../../../providers/transaction_provider.dart';
import '../../../widgets/common/custom_card.dart';
import '../../../widgets/common/empty_state.dart';

class SpendingTrends extends ConsumerWidget {
  const SpendingTrends({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final transactions = ref.watch(transactionProvider);

    if (transactions.isEmpty) {
      return CustomCard(
        child: EmptyState(
          icon: Icons.show_chart_outlined,
          title: l10n.noData,
          message: l10n.uploadDataMessage,
        ),
      );
    }

    // Calculate daily spending for last 7 days
    final now = DateTime.now();
    final spots = <FlSpot>[];
    
    for (int i = 6; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      final dayTransactions = transactions.where((t) =>
        t.type == TransactionType.expense &&
        t.date.year == date.year &&
        t.date.month == date.month &&
        t.date.day == date.day
      ).toList();
      
      final dayTotal = dayTransactions.fold<double>(0, (sum, t) => sum + t.amount);
      spots.add(FlSpot((6 - i).toDouble(), dayTotal));
    }

    // Safely calculate maxY
    double maxY = 1000.0;
    if (spots.isNotEmpty) {
      final maxSpotValue = spots.map((s) => s.y).reduce((a, b) => a > b ? a : b);
      if (maxSpotValue > 0) {
        maxY = maxSpotValue * 1.2;
      }
    }
    // Ensure maxY is never zero
    if (maxY <= 0) maxY = 1000.0;

    return CustomCard(
      padding: const EdgeInsets.all(AppConstants.spacingLG),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.last7Days,
            style: AppTextStyles.bodySmall,
          ),
          const SizedBox(height: AppConstants.spacingLG),
          SizedBox(
            height: 220,
            child: LineChart(
              LineChartData(
                minY: 0,
                maxY: maxY,
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: maxY > 0 ? maxY / 4 : 250.0, // Ensure interval is never zero
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: AppColors.border.withOpacity(0.3),
                      strokeWidth: 1,
                      dashArray: [5, 5],
                    );
                  },
                ),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          '₺${value.toInt()}',
                          style: AppTextStyles.bodySmall.copyWith(fontSize: 10),
                        );
                      },
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        final days = ['Pzt', 'Sal', 'Çar', 'Per', 'Cum', 'Cmt', 'Paz'];
                        if (value.toInt() < days.length) {
                          return Text(
                            days[value.toInt()],
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
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    color: AppColors.primary,
                    barWidth: 3,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, percent, barData, index) {
                        return FlDotCirclePainter(
                          radius: 4,
                          color: AppColors.primary,
                          strokeWidth: 2,
                          strokeColor: Colors.white,
                        );
                      },
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        colors: [
                          AppColors.primary.withOpacity(0.3),
                          AppColors.primary.withOpacity(0.05),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

