import 'package:intl/intl.dart';
import '../constants/app_constants.dart';

class DateFormatter {
  static String formatShort(DateTime date) {
    return DateFormat(AppConstants.dateFormatShort).format(date);
  }

  static String formatLong(DateTime date) {
    return DateFormat(AppConstants.dateFormatLong, 'tr_TR').format(date);
  }

  static String formatMonthYear(DateTime date) {
    return DateFormat(AppConstants.dateFormatMonthYear, 'tr_TR').format(date);
  }

  static String formatCurrency(double amount) {
    return NumberFormat.currency(
      locale: 'tr_TR',
      symbol: '₺',
      decimalDigits: 2,
    ).format(amount);
  }

  static String formatRelative(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Bugün';
    } else if (difference.inDays == 1) {
      return 'Dün';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} gün önce';
    } else if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      return '$weeks hafta önce';
    } else if (difference.inDays < 365) {
      final months = (difference.inDays / 30).floor();
      return '$months ay önce';
    } else {
      final years = (difference.inDays / 365).floor();
      return '$years yıl önce';
    }
  }
}

