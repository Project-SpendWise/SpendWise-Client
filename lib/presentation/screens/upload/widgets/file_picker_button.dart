import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spendwise_client/l10n/app_localizations.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../providers/file_provider.dart';
import '../../../../providers/transaction_provider.dart';
import '../../../../data/mock/mock_data.dart';
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
        // Upload file using file service
        final fileNotifier = ref.read(fileListProvider.notifier);
        final uploadedFile = await fileNotifier.uploadFile(
          filePath: filePath,
          fileName: fileName,
          fileBytes: fileBytes,
        );

        if (uploadedFile != null && context.mounted) {
          // Add mock transactions (until backend processes the file)
          final mockTransactions = MockData.getMockTransactions();
          final transactionNotifier = ref.read(transactionProvider.notifier);
          transactionNotifier.addTransactions(mockTransactions);

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.fileProcessed),
              backgroundColor: AppColors.success,
            ),
          );
        } else if (context.mounted) {
          final error = ref.read(fileListProvider).error;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(error ?? l10n.error),
              backgroundColor: AppColors.error,
            ),
          );
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

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final fileState = ref.watch(fileListProvider);

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
            onPressed: fileState.isLoading
                ? null
                : () => _pickFile(ref, context),
            isLoading: fileState.isLoading,
          ),
        ],
      ),
    );
  }
}

