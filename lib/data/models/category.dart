import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class Category {
  final String id;
  final String name;
  final Color color;
  final double totalAmount;
  final IconData icon;

  Category({
    required this.id,
    required this.name,
    required this.color,
    this.totalAmount = 0.0,
    required this.icon,
  });

  static List<Category> get defaultCategories => [
        Category(id: 'food', name: 'Gıda', color: AppColors.chartColors[0], icon: Icons.restaurant),
        Category(id: 'transport', name: 'Ulaşım', color: AppColors.chartColors[1], icon: Icons.directions_car),
        Category(id: 'shopping', name: 'Alışveriş', color: AppColors.chartColors[2], icon: Icons.shopping_bag),
        Category(id: 'bills', name: 'Faturalar', color: AppColors.chartColors[3], icon: Icons.receipt_long),
        Category(id: 'entertainment', name: 'Eğlence', color: AppColors.chartColors[4], icon: Icons.movie),
        Category(id: 'health', name: 'Sağlık', color: AppColors.chartColors[5], icon: Icons.health_and_safety),
        Category(id: 'education', name: 'Eğitim', color: AppColors.chartColors[6], icon: Icons.school),
        Category(id: 'other', name: 'Diğer', color: AppColors.chartColors[7], icon: Icons.more_horiz),
      ];
}

