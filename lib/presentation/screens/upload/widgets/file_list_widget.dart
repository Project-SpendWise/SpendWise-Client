import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spendwise_client/l10n/app_localizations.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_filex/open_filex.dart';
import 'dart:io';
import 'dart:typed_data';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../data/models/file_model.dart';
import '../../../../data/services/api_models.dart';
import '../../../../providers/file_provider.dart';
import '../../../widgets/common/custom_card.dart';
import '../../../widgets/common/empty_state.dart';
import 'file_viewer_screen.dart';

class FileListWidget extends ConsumerWidget {
  const FileListWidget({super.key});

  String _getFileTypeIcon(String fileType) {
    switch (fileType.toLowerCase()) {
      case 'pdf':
        return '📄';
      case 'xlsx':
      case 'xls':
        return '📊';
      case 'csv':
        return '📈';
      case 'docx':
        return '📝';
      default:
        return '📎';
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'completed':
        return AppColors.success;
      case 'processing':
        return AppColors.warning;
      case 'pending':
        return AppColors.info;
      case 'failed':
        return AppColors.error;
      default:
        return AppColors.textSecondary;
    }
  }

  Future<void> _viewFile(
    BuildContext context,
    FileModel file,
  ) async {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => FileViewerScreen(file: file),
      ),
    );
  }

  Future<void> _downloadFile(
    BuildContext context,
    WidgetRef ref,
    FileModel file,
  ) async {
    final l10n = AppLocalizations.of(context)!;
    try {
      // Show loading indicator
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Downloading file...'),
            duration: Duration(seconds: 1),
          ),
        );
      }

      final fileNotifier = ref.read(fileListProvider.notifier);
      
      // Show error from provider if any
      final currentError = ref.read(fileListProvider).error;
      if (currentError != null) {
        debugPrint('File provider error: $currentError');
      }
      
      final fileBytes = await fileNotifier.downloadFile(file.id);

      if (fileBytes != null && fileBytes.isNotEmpty) {
        debugPrint('File downloaded successfully: ${fileBytes.length} bytes');
        // Try to save to Downloads folder first (Android) or Documents (iOS)
        Directory? targetDirectory;
        try {
          if (Platform.isAndroid) {
            // For Android, try to get external storage downloads directory
            final externalDir = await getExternalStorageDirectory();
            if (externalDir != null) {
              // Navigate to Downloads folder
              targetDirectory = Directory('${externalDir.parent.path}/Download');
              if (!targetDirectory.existsSync()) {
                targetDirectory = Directory('${externalDir.parent.path}/Downloads');
              }
              if (!targetDirectory.existsSync()) {
                // Fallback to external storage root
                targetDirectory = externalDir.parent;
              }
            }
          } else if (Platform.isIOS) {
            // For iOS, use documents directory
            targetDirectory = await getApplicationDocumentsDirectory();
          } else {
            // For other platforms, use documents directory
            targetDirectory = await getApplicationDocumentsDirectory();
          }
        } catch (e) {
          // Fallback to application documents directory
          targetDirectory = await getApplicationDocumentsDirectory();
        }

        if (targetDirectory != null) {
          // Ensure directory exists
          if (!targetDirectory.existsSync()) {
            targetDirectory.createSync(recursive: true);
          }

          // Create file path
          final filePath = '${targetDirectory.path}/${file.originalFilename}';

          // Handle duplicate files by adding a number suffix
          String finalPath = filePath;
          int counter = 1;
          File savedFile = File(finalPath);
          while (savedFile.existsSync()) {
            final fileName = file.originalFilename;
            final lastDotIndex = fileName.lastIndexOf('.');
            if (lastDotIndex > 0) {
              final nameWithoutExt = fileName.substring(0, lastDotIndex);
              final extension = fileName.substring(lastDotIndex);
              finalPath = '${targetDirectory.path}/${nameWithoutExt}_$counter$extension';
            } else {
              finalPath = '${targetDirectory.path}/${fileName}_$counter';
            }
            counter++;
            savedFile = File(finalPath);
          }

          // Write file bytes
          final finalFile = File(finalPath);
          await finalFile.writeAsBytes(Uint8List.fromList(fileBytes));

          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('File saved to ${finalFile.path}'),
                backgroundColor: AppColors.success,
                action: SnackBarAction(
                  label: 'Open',
                  onPressed: () async {
                    final result = await OpenFilex.open(finalFile.path);
                    if (result.type != ResultType.done && context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Could not open file: ${result.message}'),
                          backgroundColor: AppColors.error,
                        ),
                      );
                    }
                  },
                ),
                duration: const Duration(seconds: 4),
              ),
            );
          }
        } else {
          // Fallback to file picker save dialog
          final savedPath = await FilePicker.platform.saveFile(
            fileName: file.originalFilename,
            bytes: Uint8List.fromList(fileBytes),
          );

          if (context.mounted && savedPath != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('File saved to $savedPath'),
                backgroundColor: AppColors.success,
              ),
            );
          } else if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('File download cancelled'),
                backgroundColor: AppColors.warning,
              ),
            );
          }
        }
      } else {
        if (context.mounted) {
          final error = ref.read(fileListProvider).error;
          final errorMessage = error ?? 'Failed to download file: No data received';
          debugPrint('Download failed: $errorMessage');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(errorMessage),
              backgroundColor: AppColors.error,
              duration: const Duration(seconds: 5),
            ),
          );
        }
      }
    } catch (e, stackTrace) {
      debugPrint('Download exception: $e');
      debugPrint('Stack trace: $stackTrace');
      if (context.mounted) {
        String errorMessage;
        if (e is ApiError) {
          errorMessage = e.message;
        } else {
          errorMessage = e.toString();
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${l10n.error}: $errorMessage'),
            backgroundColor: AppColors.error,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
  }

  Future<void> _deleteFile(
    BuildContext context,
    WidgetRef ref,
    FileModel file,
  ) async {
    final l10n = AppLocalizations.of(context)!;
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete File'),
        content: Text('Are you sure you want to delete ${file.originalFilename}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: Text('Delete'),
          ),
        ],
      ),
    );

    if (shouldDelete == true) {
      final fileNotifier = ref.read(fileListProvider.notifier);
      final success = await fileNotifier.deleteFile(file.id);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              success ? 'File deleted successfully' : 'Failed to delete file',
            ),
            backgroundColor: success ? AppColors.success : AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final fileState = ref.watch(fileListProvider);

    if (fileState.isLoading && fileState.files.isEmpty) {
      return CustomCard(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(AppConstants.spacingXL),
            child: CircularProgressIndicator(),
          ),
        ),
      );
    }

    if (fileState.files.isEmpty) {
      return CustomCard(
        child: EmptyState(
          icon: Icons.folder_outlined,
          title: l10n.noFileUploaded,
          message: l10n.uploadedFilesDescription,
        ),
      );
    }

    return CustomCard(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(AppConstants.spacingLG),
            child: Row(
              children: [
                Text(
                  l10n.uploadedFiles,
                  style: AppTextStyles.h4,
                ),
                const Spacer(),
                if (fileState.isLoading)
                  const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: fileState.isLoading
                      ? null
                      : () => ref.read(fileListProvider.notifier).refresh(),
                ),
              ],
            ),
          ),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: fileState.files.length,
            separatorBuilder: (context, index) => Divider(height: 1),
            itemBuilder: (context, index) {
              final file = fileState.files[index];
              return ListTile(
                leading: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text(
                      _getFileTypeIcon(file.fileType),
                      style: const TextStyle(fontSize: 24),
                    ),
                  ),
                ),
                title: Text(
                  file.originalFilename,
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 4),
                    Text(
                      file.formattedSize,
                      style: AppTextStyles.bodySmall,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: _getStatusColor(file.processingStatus)
                                .withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            file.processingStatus.toUpperCase(),
                            style: AppTextStyles.labelSmall.copyWith(
                              color: _getStatusColor(file.processingStatus),
                              fontSize: 10,
                            ),
                          ),
                        ),
                        if (file.description != null) ...[
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              file.description!,
                              style: AppTextStyles.bodySmall,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.visibility_outlined),
                      onPressed: () => _viewFile(context, file),
                      tooltip: 'View',
                    ),
                    IconButton(
                      icon: const Icon(Icons.download_outlined),
                      onPressed: () => _downloadFile(context, ref, file),
                      tooltip: 'Download',
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline),
                      onPressed: () => _deleteFile(context, ref, file),
                      tooltip: 'Delete',
                      color: AppColors.error,
                    ),
                  ],
                ),
              );
            },
          ),
          if (fileState.pagination != null) ...[
            Divider(height: 1),
            Padding(
              padding: const EdgeInsets.all(AppConstants.spacingMD),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Page ${fileState.pagination!.page} of ${fileState.pagination!.pages}',
                    style: AppTextStyles.bodySmall,
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.chevron_left),
                        onPressed: fileState.pagination!.hasPreviousPage
                            ? () => ref
                                .read(fileListProvider.notifier)
                                .previousPage()
                            : null,
                      ),
                      IconButton(
                        icon: const Icon(Icons.chevron_right),
                        onPressed: fileState.pagination!.hasNextPage
                            ? () => ref
                                .read(fileListProvider.notifier)
                                .nextPage()
                            : null,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

