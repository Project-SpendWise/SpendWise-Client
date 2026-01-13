import 'package:flutter/material.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_text_styles.dart';
import 'custom_card.dart';

/// A widget that catches errors and displays a fallback UI instead of a red box
class ErrorBoundary extends StatelessWidget {
  final Widget child;
  final String? errorMessage;

  const ErrorBoundary({
    super.key,
    required this.child,
    this.errorMessage,
  });

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (context) {
        try {
          return child;
        } catch (e, stackTrace) {
          // Log the error for debugging
          debugPrint('ErrorBoundary caught error: $e');
          debugPrint('Stack trace: $stackTrace');
          
          return CustomCard(
            padding: EdgeInsets.all(AppConstants.spacingLG),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.error_outline,
                  color: Theme.of(context).colorScheme.error,
                  size: 48,
                ),
                SizedBox(height: AppConstants.spacingMD),
                Text(
                  errorMessage ?? 'Something went wrong',
                  style: AppTextStyles.bodyMedium,
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: AppConstants.spacingSM),
                Text(
                  'Please try refreshing or contact support if the issue persists.',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: Theme.of(context).textTheme.bodySmall?.color,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }
      },
    );
  }
}
