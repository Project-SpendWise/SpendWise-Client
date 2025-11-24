import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spendwise_client/l10n/app_localizations.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../providers/upload_provider.dart';
import '../../../../providers/transaction_provider.dart';
import '../../../../data/services/transaction_service.dart';
import '../../../../data/services/api_service.dart';
import '../../../../providers/auth_provider.dart';
import '../../../widgets/common/custom_button.dart';
import '../../../widgets/common/custom_card.dart';

class FilePickerButton extends ConsumerWidget {
  const FilePickerButton({super.key});

  Future<void> _pickFile(WidgetRef ref, BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'xlsx', 'xls', 'csv', 'docx'],
    );

    if (result != null && result.files.single.path != null) {
      final filePath = result.files.single.path!;
      final fileName = result.files.single.name;
      
      // Read file bytes
      final file = File(filePath);
      final fileBytes = await file.readAsBytes();

      // Check file size (10MB limit)
      if (fileBytes.length > 10 * 1024 * 1024) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('File size exceeds 10MB limit'),
              backgroundColor: AppColors.error,
            ),
          );
        }
        return;
      }

      try {
        // Upload statement using upload provider
        final uploadNotifier = ref.read(uploadProvider.notifier);
        await uploadNotifier.uploadFile(filePath, fileName);

        // Check final status after upload completes
        if (context.mounted) {
          // Wait a bit for state to update
          await Future.delayed(const Duration(milliseconds: 500));
          
          final uploadState = ref.read(uploadProvider);
          
          if (uploadState.status == UploadStatus.success) {
            // Show success message
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(l10n.fileProcessed),
                backgroundColor: AppColors.success,
                duration: const Duration(seconds: 2),
              ),
            );

            // Load transactions after upload completes
            await _loadTransactionsAfterUpload(ref);
          } else if (uploadState.status == UploadStatus.error) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(uploadState.errorMessage ?? l10n.error),
                backgroundColor: AppColors.error,
                duration: const Duration(seconds: 4),
              ),
            );
          }
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${l10n.error}: $e'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    }
  }

  /// Load transactions after file upload completes
  Future<void> _loadTransactionsAfterUpload(WidgetRef ref) async {
    try {
      final authState = ref.read(authProvider);
      if (authState.accessToken == null) return;

      final apiService = ApiService();
      apiService.setAuthToken(authState.accessToken!);
      
      // Set token refresh callback
      apiService.setTokenRefreshCallback(() async {
        final authNotifier = ref.read(authProvider.notifier);
        final refreshed = await authNotifier.refreshAccessToken();
        if (refreshed) {
          final newAuthState = ref.read(authProvider);
          return newAuthState.accessToken;
        }
        return null;
      });
      
      final transactionService = TransactionService(apiService: apiService);
      
      // Load ALL transactions (not filtered by statementId) so home/analytics show data
      final transactions = await transactionService.getTransactions();
      
      final transactionNotifier = ref.read(transactionProvider.notifier);
      // Clear old data and add new transactions
      transactionNotifier.clearTransactions();
      transactionNotifier.addTransactions(transactions);
      
      print('Loaded ${transactions.length} transactions after upload');
    } catch (e) {
      print('Failed to load transactions after upload: $e');
      print('Error details: ${e.toString()}');
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final uploadState = ref.watch(uploadProvider);

    return CustomCard(
      padding: const EdgeInsets.all(AppConstants.spacingXL),
      child: Column(
        children: [
          Icon(
            Icons.cloud_upload_outlined,
            size: 64,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(height: AppConstants.spacingLG),
          Text(
            l10n.uploadStatement,
            style: AppTextStyles.h3,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppConstants.spacingSM),
          Text(
            l10n.uploadPdfDescription,
            style: AppTextStyles.bodyMedium.copyWith(
              color: Theme.of(context).textTheme.bodySmall?.color,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppConstants.spacingXL),
          CustomButton(
            text: l10n.selectFile,
            icon: Icons.file_upload,
            onPressed: uploadState.status == UploadStatus.uploading || 
                      uploadState.status == UploadStatus.processing
                ? null
                : () => _pickFile(ref, context),
            isLoading: uploadState.status == UploadStatus.uploading || 
                      uploadState.status == UploadStatus.processing,
          ),
        ],
      ),
    );
  }
}

