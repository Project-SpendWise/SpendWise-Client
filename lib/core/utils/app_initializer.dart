import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../utils/mock_data_initializer.dart';

class AppInitializer {
  static Future<void> initialize(WidgetRef ref) async {
    // Initialize mock data
    MockDataInitializer.initializeMockData(ref);
  }
}

