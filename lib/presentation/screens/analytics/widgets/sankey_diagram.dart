import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spendwise_client/l10n/app_localizations.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../data/models/category.dart';
import '../../../../providers/transaction_provider.dart';
import '../../../widgets/common/custom_card.dart';
import '../../../widgets/common/empty_state.dart';

class SankeyDiagram extends ConsumerWidget {
  const SankeyDiagram({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final totalIncome = ref.watch(totalIncomeProvider);
    final totalExpenses = ref.watch(totalExpensesProvider);
    final categoryBreakdown = ref.watch(categoryBreakdownProvider);

    if (totalIncome == 0 && totalExpenses == 0) {
      return CustomCard(
        child: EmptyState(
          icon: Icons.account_tree_outlined,
          title: l10n.noData,
          message: l10n.uploadDataMessage,
        ),
      );
    }

    // Prepare data for Sankey diagram
    List<_SankeyNodeData> nodes = [];
    List<_SankeyLinkData> links = [];

    // Add income node
    nodes.add(_SankeyNodeData('Gelir', totalIncome));

    // Add expense categories
    for (var category in categoryBreakdown) {
      nodes.add(_SankeyNodeData(category.name, category.totalAmount));
      links.add(_SankeyLinkData('Gelir', category.name, category.totalAmount));
    }

    // Add savings if positive
    final savings = totalIncome - totalExpenses;
    if (savings > 0) {
      nodes.add(_SankeyNodeData('Tasarruf', savings));
      links.add(_SankeyLinkData('Gelir', 'Tasarruf', savings));
    }

    return CustomCard(
      padding: const EdgeInsets.all(AppConstants.spacingLG),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                l10n.moneyFlow,
                style: AppTextStyles.h3,
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.info_outline, size: 14, color: AppColors.primary),
                    const SizedBox(width: 6),
                    Text(
                      DateFormatter.formatCurrency(totalIncome),
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppConstants.spacingLG),
          SizedBox(
            height: 450,
            child: _CustomSankeyDiagram(
              nodes: nodes,
              links: links,
            ),
          ),
          const SizedBox(height: AppConstants.spacingMD),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _FlowIndicator(
                color: AppColors.success,
                label: l10n.income,
                amount: totalIncome,
              ),
              const SizedBox(width: AppConstants.spacingLG),
              Icon(Icons.arrow_forward, size: 16, color: AppColors.textTertiary),
              const SizedBox(width: AppConstants.spacingLG),
              _FlowIndicator(
                color: AppColors.error,
                label: l10n.expenses,
                amount: totalExpenses,
              ),
              const SizedBox(width: AppConstants.spacingLG),
              Icon(Icons.arrow_forward, size: 16, color: AppColors.textTertiary),
              const SizedBox(width: AppConstants.spacingLG),
              _FlowIndicator(
                color: totalIncome - totalExpenses >= 0 ? AppColors.success : AppColors.error,
                label: l10n.savings,
                amount: totalIncome - totalExpenses,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SankeyNodeData {
  final String label;
  final double value;

  _SankeyNodeData(this.label, this.value);
}

class _SankeyLinkData {
  final String source;
  final String target;
  final double value;

  _SankeyLinkData(this.source, this.target, this.value);
}

class _CustomSankeyDiagram extends StatelessWidget {
  final List<_SankeyNodeData> nodes;
  final List<_SankeyLinkData> links;

  const _CustomSankeyDiagram({
    required this.nodes,
    required this.links,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _SankeyPainter(nodes: nodes, links: links),
      size: Size.infinite,
    );
  }
}

class _SankeyPainter extends CustomPainter {
  final List<_SankeyNodeData> nodes;
  final List<_SankeyLinkData> links;

  _SankeyPainter({
    required this.nodes,
    required this.links,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (nodes.isEmpty) return;

    final total = nodes.fold<double>(0, (sum, node) => sum + node.value);
    if (total == 0) return;

    // Calculate node positions
    double currentY = 0;
    final nodeRects = <String, Rect>{};
    final nodeWidth = 80.0;
    final spacing = 20.0;
    final centerGap = size.width * 0.3;

    // Draw income node (left side)
    final incomeNode = nodes.firstWhere((n) => n.label == 'Gelir');
    final incomeHeight = (incomeNode.value / total) * size.height;
    final incomeRect = Rect.fromLTWH(
      spacing,
      currentY,
      nodeWidth,
      incomeHeight,
    );
    nodeRects['Gelir'] = incomeRect;
    currentY += incomeHeight;

    // Draw category nodes (right side)
    final categoryNodes = nodes.where((n) => n.label != 'Gelir').toList();
    currentY = 0;

    for (var node in categoryNodes) {
      if (node.label == 'Tasarruf') continue;
      final nodeHeight = (node.value / total) * size.height;
      final nodeRect = Rect.fromLTWH(
        size.width - nodeWidth - spacing,
        currentY,
        nodeWidth,
        nodeHeight,
      );
      nodeRects[node.label] = nodeRect;
      currentY += nodeHeight;
    }

    // Draw savings node if exists
    final savingsNode = categoryNodes.firstWhere(
      (n) => n.label == 'Tasarruf',
      orElse: () => _SankeyNodeData('', 0),
    );
    if (savingsNode.value > 0) {
      final savingsHeight = (savingsNode.value / total) * size.height;
      final savingsRect = Rect.fromLTWH(
        size.width - nodeWidth - spacing,
        size.height - savingsHeight,
        nodeWidth,
        savingsHeight,
      );
      nodeRects['Tasarruf'] = savingsRect;
    }

    // Draw links with different colors based on category
    for (var link in links) {
      final sourceRect = nodeRects[link.source];
      final targetRect = nodeRects[link.target];

      if (sourceRect != null && targetRect != null) {
        // Find category color if it's a category link
        Color linkColor = AppColors.primary.withOpacity(0.3);
        if (link.target != 'Tasarruf') {
          final categoryNodes = Category.defaultCategories;
          final category = categoryNodes.firstWhere(
            (c) => c.name == link.target,
            orElse: () => categoryNodes.first,
          );
          linkColor = category.color.withOpacity(0.4);
        } else {
          linkColor = AppColors.success.withOpacity(0.4);
        }

        final linkPaint = Paint()
          ..style = PaintingStyle.fill
          ..color = linkColor;

        // Create smooth curved path
        final path = Path()
          ..moveTo(sourceRect.right, sourceRect.top)
          ..cubicTo(
            sourceRect.right + centerGap * 0.5,
            sourceRect.top,
            targetRect.left - centerGap * 0.5,
            targetRect.top,
            targetRect.left,
            targetRect.top,
          )
          ..lineTo(targetRect.left, targetRect.bottom)
          ..cubicTo(
            targetRect.left - centerGap * 0.5,
            targetRect.bottom,
            sourceRect.right + centerGap * 0.5,
            sourceRect.bottom,
            sourceRect.right,
            sourceRect.bottom,
          )
          ..close();

        canvas.drawPath(path, linkPaint);
      }
    }

    // Draw nodes with category-specific colors
    final textPainter = TextPainter(
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    );

    for (var entry in nodeRects.entries) {
      Color nodeColor = AppColors.primary;
      
      // Color income node green
      if (entry.key == 'Gelir') {
        nodeColor = AppColors.success;
      } 
      // Color savings node
      else if (entry.key == 'Tasarruf') {
        nodeColor = AppColors.success;
      }
      // Color category nodes based on category
      else {
        final categoryNodes = Category.defaultCategories;
        final category = categoryNodes.firstWhere(
          (c) => c.name == entry.key,
          orElse: () => categoryNodes.first,
        );
        nodeColor = category.color;
      }

      final nodePaint = Paint()
        ..style = PaintingStyle.fill
        ..color = nodeColor;

      // Draw node rectangle with rounded corners
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          entry.value,
          const Radius.circular(6),
        ),
        nodePaint,
      );

      // Draw node label
      textPainter.text = TextSpan(
        text: entry.key,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      );
      textPainter.layout(maxWidth: entry.value.width - 4);
      textPainter.paint(
        canvas,
        Offset(
          entry.value.left + (entry.value.width - textPainter.width) / 2,
          entry.value.top + (entry.value.height - textPainter.height) / 2,
        ),
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class _FlowIndicator extends StatelessWidget {
  final Color color;
  final String label;
  final double amount;

  const _FlowIndicator({
    required this.color,
    required this.label,
    required this.amount,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: AppTextStyles.bodySmall.copyWith(fontSize: 10),
        ),
        Text(
          DateFormatter.formatCurrency(amount),
          style: AppTextStyles.bodySmall.copyWith(
            color: color,
            fontWeight: FontWeight.bold,
            fontSize: 10,
          ),
        ),
      ],
    );
  }
}

