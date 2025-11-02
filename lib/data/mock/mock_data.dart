import '../models/transaction.dart';
import '../models/category.dart';
import '../models/statement.dart';
import '../models/budget.dart';
import 'package:flutter/material.dart';
import 'dart:math' as math;

class MockData {
  static final math.Random _random = math.Random();

  // Monthly variation factors for different categories
  // Returns a multiplier based on month (1-12) for category spending
  static double _getMonthlyMultiplier(int month, String category) {
    // January: High shopping (post-holiday sales)
    if (month == 1) {
      if (category == 'Alışveriş') return 1.5;
      if (category == 'Eğitim') return 1.2; // New year courses
    }
    // Summer months (6, 7, 8): More entertainment and transport
    if (month >= 6 && month <= 8) {
      if (category == 'Eğlence') return 1.6;
      if (category == 'Ulaşım') return 1.3;
      if (category == 'Gıda') return 1.2;
    }
    // December: High shopping (holidays)
    if (month == 12) {
      if (category == 'Alışveriş') return 2.0;
      if (category == 'Eğlence') return 1.5;
      if (category == 'Gıda') return 1.3;
    }
    // November: Shopping (Black Friday)
    if (month == 11) {
      if (category == 'Alışveriş') return 1.8;
    }
    return 1.0;
  }

  // Generate comprehensive mock transactions with varied monthly patterns
  static List<Transaction> getMockTransactions() {
    final now = DateTime.now();
    final transactions = <Transaction>[];

    // Generate income for last 12 months (for year-over-year comparison)
    for (int monthOffset = 0; monthOffset < 12; monthOffset++) {
      final monthDate = DateTime(now.year, now.month - monthOffset, 1);
      // Slight income variation
      final incomeVariation = 14000 + (monthOffset % 3) * 500;
      transactions.add(Transaction(
        id: 'income_$monthOffset',
        date: monthDate,
        description: 'Maaş',
        amount: incomeVariation.toDouble(),
        type: TransactionType.income,
        account: 'Ana Hesap',
        category: 'Gelir',
      ));
    }

    // Generate previous year income for year-over-year
    for (int monthOffset = 0; monthOffset < 12; monthOffset++) {
      final monthDate = DateTime(now.year - 1, now.month - monthOffset, 1);
      final incomeVariation = 13500 + (monthOffset % 3) * 400;
      transactions.add(Transaction(
        id: 'income_prev_$monthOffset',
        date: monthDate,
        description: 'Maaş',
        amount: incomeVariation.toDouble(),
        type: TransactionType.income,
        account: 'Ana Hesap',
        category: 'Gelir',
      ));
    }

    // Generate transactions for each of the last 12 months with variations
    for (int monthOffset = 0; monthOffset < 12; monthOffset++) {
      final targetMonth = now.month - monthOffset;
      final targetYear = targetMonth <= 0 ? now.year - 1 : now.year;
      final actualMonth = targetMonth <= 0 ? 12 + targetMonth : targetMonth;
      
      final monthStart = DateTime(targetYear, actualMonth, 1);
      final daysInMonth = DateTime(targetYear, actualMonth + 1, 0).day;
      
      // Generate transactions for each day of the month
      for (int day = 1; day <= daysInMonth; day++) {
        final date = DateTime(targetYear, actualMonth, day);
        final isCurrentMonth = monthOffset == 0;
        final isWeekend = date.weekday == 6 || date.weekday == 7;

        // Food expenses (daily, more on weekends)
        if (_random.nextDouble() > (isCurrentMonth ? 0.2 : 0.3)) {
          final baseAmount = isWeekend ? 150.0 : 120.0;
          final multiplier = _getMonthlyMultiplier(actualMonth, 'Gıda');
          final foodAmounts = [
            baseAmount * multiplier * 0.6,
            baseAmount * multiplier * 0.8,
            baseAmount * multiplier,
            baseAmount * multiplier * 1.2,
            baseAmount * multiplier * 1.5,
            baseAmount * multiplier * 2.0,
          ];
          transactions.add(Transaction(
            id: 'food_${monthOffset}_${day}_1',
            date: date,
            description: _getRandomFoodMerchant(),
            amount: foodAmounts[_random.nextInt(foodAmounts.length)],
            type: TransactionType.expense,
            category: 'Gıda',
            account: 'Ana Hesap',
          ));
        }

        // Transport (daily, more frequent)
        if (_random.nextDouble() > 0.4) {
          final baseAmount = 50.0;
          final multiplier = _getMonthlyMultiplier(actualMonth, 'Ulaşım');
          final transportAmounts = [
            baseAmount * multiplier,
            baseAmount * multiplier * 1.3,
            baseAmount * multiplier * 1.5,
            baseAmount * multiplier * 2.0,
            baseAmount * multiplier * 3.0,
          ];
          transactions.add(Transaction(
            id: 'transport_${monthOffset}_$day',
            date: date,
            description: _getRandomTransportDescription(),
            amount: transportAmounts[_random.nextInt(transportAmounts.length)],
            type: TransactionType.expense,
            category: 'Ulaşım',
            account: 'Ana Hesap',
          ));
        }

        // Shopping (less frequent, seasonal patterns)
        final shoppingChance = isCurrentMonth ? 0.7 : 0.6;
        if (_random.nextDouble() > shoppingChance) {
          final baseAmount = 800.0;
          final multiplier = _getMonthlyMultiplier(actualMonth, 'Alışveriş');
          final shoppingAmounts = [
            baseAmount * multiplier * 0.5,
            baseAmount * multiplier,
            baseAmount * multiplier * 1.5,
            baseAmount * multiplier * 2.0,
            baseAmount * multiplier * 3.0,
          ];
          transactions.add(Transaction(
            id: 'shopping_${monthOffset}_$day',
            date: date,
            description: _getRandomShoppingMerchant(),
            amount: shoppingAmounts[_random.nextInt(shoppingAmounts.length)],
            type: TransactionType.expense,
            category: 'Alışveriş',
            account: 'Kredi Kartı',
          ));
        }

        // Bills (monthly, on specific days)
        if (day >= 1 && day <= 5) {
          transactions.addAll([
            Transaction(
              id: 'bill_electric_${monthOffset}_$day',
              date: date,
              description: 'Elektrik Faturası',
              amount: 400.0 + _random.nextDouble() * 150,
              type: TransactionType.expense,
              category: 'Faturalar',
              account: 'Ana Hesap',
            ),
            Transaction(
              id: 'bill_internet_${monthOffset}_$day',
              date: date,
              description: 'İnternet Faturası',
              amount: 299.00,
              type: TransactionType.expense,
              category: 'Faturalar',
              account: 'Ana Hesap',
            ),
            Transaction(
              id: 'bill_water_${monthOffset}_$day',
              date: date,
              description: 'Su Faturası',
              amount: 100.0 + _random.nextDouble() * 50,
              type: TransactionType.expense,
              category: 'Faturalar',
              account: 'Ana Hesap',
            ),
            Transaction(
              id: 'bill_mobile_${monthOffset}_$day',
              date: date,
              description: 'Mobil Fatura',
              amount: 199.00,
              type: TransactionType.expense,
              category: 'Faturalar',
              account: 'Ana Hesap',
            ),
          ]);
        }

        // Entertainment (more on weekends, seasonal)
        if (isWeekend && _random.nextDouble() > 0.4) {
          final baseAmount = 150.0;
          final multiplier = _getMonthlyMultiplier(actualMonth, 'Eğlence');
          final entertainmentAmounts = [
            baseAmount * multiplier * 0.5,
            baseAmount * multiplier,
            baseAmount * multiplier * 1.5,
            baseAmount * multiplier * 2.0,
          ];
          transactions.add(Transaction(
            id: 'entertainment_${monthOffset}_$day',
            date: date,
            description: _getRandomEntertainmentDescription(),
            amount: entertainmentAmounts[_random.nextInt(entertainmentAmounts.length)],
            type: TransactionType.expense,
            category: 'Eğlence',
            account: 'Ana Hesap',
          ));
        }

        // Health (occasional)
        if (_random.nextDouble() > 0.92) {
          final healthAmounts = [150.0, 300.0, 450.0, 600.0];
          transactions.add(Transaction(
            id: 'health_${monthOffset}_$day',
            date: date,
            description: _getRandomHealthDescription(),
            amount: healthAmounts[_random.nextInt(healthAmounts.length)],
            type: TransactionType.expense,
            category: 'Sağlık',
            account: 'Ana Hesap',
          ));
        }

        // Education (occasional, more in January)
        if (_random.nextDouble() > 0.88) {
          final multiplier = actualMonth == 1 ? 1.3 : 1.0;
          final educationAmounts = [
            200.0 * multiplier,
            300.0 * multiplier,
            450.0 * multiplier,
          ];
          transactions.add(Transaction(
            id: 'education_${monthOffset}_$day',
            date: date,
            description: _getRandomEducationDescription(),
            amount: educationAmounts[_random.nextInt(educationAmounts.length)],
            type: TransactionType.expense,
            category: 'Eğitim',
            account: 'Ana Hesap',
          ));
        }

        // Other (various)
        if (_random.nextDouble() > 0.85) {
          final otherAmounts = [100.0, 200.0, 300.0, 500.0];
          transactions.add(Transaction(
            id: 'other_${monthOffset}_$day',
            date: date,
            description: _getRandomOtherDescription(),
            amount: otherAmounts[_random.nextInt(otherAmounts.length)],
            type: TransactionType.expense,
            category: 'Diğer',
            account: 'Ana Hesap',
          ));
        }
      }
    }

    // Generate previous year expenses (simpler, slightly lower amounts)
    for (int monthOffset = 0; monthOffset < 12; monthOffset++) {
      final targetMonth = now.month - monthOffset;
      final targetYear = targetMonth <= 0 ? now.year - 1 : now.year - 1;
      final actualMonth = targetMonth <= 0 ? 12 + targetMonth : targetMonth;
      
      final monthStart = DateTime(targetYear, actualMonth, 1);
      final daysInMonth = DateTime(targetYear, actualMonth + 1, 0).day;
      
      for (int day = 1; day <= daysInMonth; day += 2) {
        final date = DateTime(targetYear, actualMonth, day);
        
        // Previous year spending is about 10-15% lower
        final prevYearMultiplier = 0.85 + _random.nextDouble() * 0.1;
        
        if (_random.nextDouble() > 0.3) {
          transactions.add(Transaction(
            id: 'prev_food_${monthOffset}_$day',
            date: date,
            description: _getRandomFoodMerchant(),
            amount: (120.0 * prevYearMultiplier),
            type: TransactionType.expense,
            category: 'Gıda',
            account: 'Ana Hesap',
          ));
        }
        
        if (_random.nextDouble() > 0.5) {
          transactions.add(Transaction(
            id: 'prev_transport_${monthOffset}_$day',
            date: date,
            description: _getRandomTransportDescription(),
            amount: (50.0 * prevYearMultiplier),
            type: TransactionType.expense,
            category: 'Ulaşım',
            account: 'Ana Hesap',
          ));
        }
        
        if (_random.nextDouble() > 0.7) {
          transactions.add(Transaction(
            id: 'prev_shopping_${monthOffset}_$day',
            date: date,
            description: _getRandomShoppingMerchant(),
            amount: (800.0 * prevYearMultiplier),
            type: TransactionType.expense,
            category: 'Alışveriş',
            account: 'Kredi Kartı',
          ));
        }
      }
    }

    return transactions;
  }

  // Get mock budgets
  static List<Budget> getMockBudgets() {
    final now = DateTime.now();
    final budgets = <Budget>[];
    
    final categories = Category.defaultCategories
        .where((c) => c.id != 'food' || c.name != 'Gelir')
        .toList();

    for (var category in categories) {
      // Set monthly budgets with some variation
      double monthlyBudget = 0;
      switch (category.id) {
        case 'food':
          monthlyBudget = 2500.0;
          break;
        case 'transport':
          monthlyBudget = 1500.0;
          break;
        case 'shopping':
          monthlyBudget = 2000.0;
          break;
        case 'bills':
          monthlyBudget = 1200.0;
          break;
        case 'entertainment':
          monthlyBudget = 800.0;
          break;
        case 'health':
          monthlyBudget = 500.0;
          break;
        case 'education':
          monthlyBudget = 600.0;
          break;
        case 'other':
          monthlyBudget = 400.0;
          break;
      }

      budgets.add(Budget(
        id: 'budget_${category.id}_monthly',
        categoryId: category.id,
        categoryName: category.name,
        amount: monthlyBudget,
        period: BudgetPeriod.monthly,
        startDate: DateTime(now.year, now.month, 1),
      ));
    }

    return budgets;
  }

  static String _getRandomFoodMerchant() {
    final merchants = [
      'Migros Market Alışverişi',
      'Getir Yemek',
      'CarrefourSA',
      'Restoran Ödeme',
      'Bim Market',
      'Şok Market',
      'Yemeksepeti',
      'A101 Market',
    ];
    return merchants[_random.nextInt(merchants.length)];
  }

  static String _getRandomTransportDescription() {
    final descriptions = [
      'IstanbulKart Yükleme',
      'Uber Yolculuk',
      'Benzin İstasyonu',
      'Otopark Ücreti',
      'Taksi',
      'Toplu Taşıma',
    ];
    return descriptions[_random.nextInt(descriptions.length)];
  }

  static String _getRandomShoppingMerchant() {
    final merchants = [
      'Amazon.com.tr',
      'H&M Mağaza',
      'Teknosa',
      'Zara',
      'MediaMarkt',
      'İkea',
    ];
    return merchants[_random.nextInt(merchants.length)];
  }

  static String _getRandomEntertainmentDescription() {
    final descriptions = [
      'Sinema Bileti',
      'Netflix Abonelik',
      'Spotify Premium',
      'Konser Bileti',
      'Kafe',
    ];
    return descriptions[_random.nextInt(descriptions.length)];
  }

  static String _getRandomHealthDescription() {
    final descriptions = [
      'Eczane Alışverişi',
      'Doktor Muayenesi',
      'Fitness Üyeliği',
      'Vitamin Takviyesi',
    ];
    return descriptions[_random.nextInt(descriptions.length)];
  }

  static String _getRandomEducationDescription() {
    final descriptions = [
      'Online Kurs',
      'Kitap Alışverişi',
      'Eğitim Materyali',
      'Udemy Kursu',
    ];
    return descriptions[_random.nextInt(descriptions.length)];
  }

  static String _getRandomOtherDescription() {
    final descriptions = [
      'ATM Para Çekme',
      'Bağış',
      'Nakit Ödeme',
      'Diğer Harcama',
    ];
    return descriptions[_random.nextInt(descriptions.length)];
  }

  static List<BankStatement> getMockStatements() {
    final now = DateTime.now();
    return [
      BankStatement(
        id: 'stmt_1',
        uploadDate: now.subtract(const Duration(days: 5)),
        fileName: 'bank_statement_${now.month}_2024.pdf',
        filePath: '/mock/path/statement1.pdf',
        statementPeriodStart: DateTime(now.year, now.month, 1),
        statementPeriodEnd: DateTime(now.year, now.month + 1, 0),
        transactionCount: 45,
        isProcessed: true,
      ),
      BankStatement(
        id: 'stmt_2',
        uploadDate: now.subtract(const Duration(days: 35)),
        fileName: 'bank_statement_${now.month - 1}_2024.pdf',
        filePath: '/mock/path/statement2.pdf',
        statementPeriodStart: DateTime(now.year, now.month - 1, 1),
        statementPeriodEnd: DateTime(now.year, now.month, 0),
        transactionCount: 52,
        isProcessed: true,
      ),
      BankStatement(
        id: 'stmt_3',
        uploadDate: now.subtract(const Duration(days: 65)),
        fileName: 'bank_statement_${now.month - 2}_2024.pdf',
        filePath: '/mock/path/statement3.pdf',
        statementPeriodStart: DateTime(now.year, now.month - 2, 1),
        statementPeriodEnd: DateTime(now.year, now.month - 1, 0),
        transactionCount: 48,
        isProcessed: true,
      ),
    ];
  }

  static List<String> getMockAccounts() {
    return [
      'Ana Hesap',
      'Kredi Kartı',
      'Birikim Hesabı',
    ];
  }
}
