import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spendwise_client/l10n/app_localizations.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../data/services/upload_service.dart';
import '../../../../data/mock/mock_data.dart';
import '../../../../providers/upload_provider.dart';
import '../../../../providers/transaction_provider.dart';
import '../../../widgets/common/custom_button.dart';
import '../../../widgets/common/custom_card.dart';

class FilePickerButton extends ConsumerWidget {
  const FilePickerButton({super.key});

  Future<void> _pickFile(WidgetRef ref, BuildContext context) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );

    if (result != null && result.files.single.path != null) {
      final uploadNotifier = ref.read(uploadProvider.notifier);
      final filePath = result.files.single.path!;
      final fileName = result.files.single.name;
      
      // Read file bytes for mock upload
      final file = File(filePath);
      final fileBytes = await file.readAsBytes();

      // Use upload service (mock implementation)
      final uploadService = UploadService(useMockData: true);
      
      uploadNotifier.uploadFile(filePath, fileName);
      
      try {
        // Simulate upload
        final response = await uploadService.uploadStatement(
          filePath: filePath,
          fileName: fileName,
          fileBytes: fileBytes,
        );

        // Add mock transactions from the uploaded statement
        final mockTransactions = MockData.getMockTransactions();
        final transactionNotifier = ref.read(transactionProvider.notifier);
        transactionNotifier.addTransactions(mockTransactions);

        uploadNotifier.resetStatus();
        
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppLocalizations.of(context)!.fileProcessed),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        uploadNotifier.resetStatus();
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${AppLocalizations.of(context)!.error}: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
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

