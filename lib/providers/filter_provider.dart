import 'package:flutter_riverpod/flutter_riverpod.dart';

enum TimePeriod { daily, weekly, monthly, yearly }

class FilterState {
  final TimePeriod timePeriod;
  final DateTime? startDate;
  final DateTime? endDate;
  final String? selectedCategory;

  FilterState({
    this.timePeriod = TimePeriod.monthly,
    this.startDate,
    this.endDate,
    this.selectedCategory,
  });

  FilterState copyWith({
    TimePeriod? timePeriod,
    DateTime? startDate,
    DateTime? endDate,
    String? selectedCategory,
  }) {
    return FilterState(
      timePeriod: timePeriod ?? this.timePeriod,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      selectedCategory: selectedCategory ?? this.selectedCategory,
    );
  }
}

class FilterNotifier extends StateNotifier<FilterState> {
  FilterNotifier() : super(FilterState()) {
    // Initialize with monthly period dates
    setTimePeriod(TimePeriod.monthly);
  }

  void setTimePeriod(TimePeriod period) {
    final now = DateTime.now();
    DateTime? start;
    DateTime? end = now;

    switch (period) {
      case TimePeriod.daily:
        start = DateTime(now.year, now.month, now.day);
        break;
      case TimePeriod.weekly:
        start = now.subtract(const Duration(days: 7));
        break;
      case TimePeriod.monthly:
        start = DateTime(now.year, now.month, 1);
        break;
      case TimePeriod.yearly:
        start = DateTime(now.year, 1, 1);
        break;
    }

    state = state.copyWith(
      timePeriod: period,
      startDate: start,
      endDate: end,
    );
  }

  void setDateRange(DateTime? start, DateTime? end) {
    state = state.copyWith(startDate: start, endDate: end);
  }

  void setCategory(String? category) {
    state = state.copyWith(selectedCategory: category);
  }

  void reset() {
    state = FilterState();
  }
}

final filterProvider =
    StateNotifierProvider<FilterNotifier, FilterState>((ref) {
  return FilterNotifier();
});

