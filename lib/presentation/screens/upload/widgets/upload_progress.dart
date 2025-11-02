import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../providers/upload_provider.dart';
import '../../../widgets/common/custom_card.dart';
import '../../../widgets/common/empty_state.dart';

class UploadProgress extends ConsumerWidget {
  const UploadProgress({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final uploadState = ref.watch(uploadProvider);

    if (uploadState.statements.isEmpty) {
      return CustomCard(
        child: EmptyState(
          icon: Icons.description_outlined,
          title: 'Henüz dosya yüklenmedi',
          message: 'Yüklediğiniz PDF\'ler burada görünecek',
        ),
      );
    }

    return CustomCard(
      padding: const EdgeInsets.all(AppConstants.spacingLG),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Yüklenen Dosyalar',
            style: AppTextStyles.h3,
          ),
          const SizedBox(height: AppConstants.spacingLG),
          ...uploadState.statements.map((statement) {
            return _StatementItem(statement: statement);
          }),
          if (uploadState.status == UploadStatus.uploading ||
              uploadState.status == UploadStatus.processing)
            Padding(
              padding: const EdgeInsets.only(top: AppConstants.spacingLG),
              child: LinearProgressIndicator(
                value: uploadState.progress,
                backgroundColor: Colors.grey[200],
              ),
            ),
        ],
      ),
    );
  }
}

class _StatementItem extends StatelessWidget {
  final statement;

  const _StatementItem({required this.statement});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppConstants.spacingLG),
      child: Row(
        children: [
          Icon(
            Icons.description,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(width: AppConstants.spacingMD),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  statement.fileName,
                  style: AppTextStyles.bodyMedium,
                ),
                Text(
                  DateFormatter.formatShort(statement.uploadDate),
                  style: AppTextStyles.bodySmall,
                ),
              ],
            ),
          ),
          if (statement.isProcessed)
            Icon(
              Icons.check_circle,
              color: Theme.of(context).colorScheme.primary,
              size: 20,
            )
          else
            Icon(
              Icons.pending,
              color: Colors.grey,
              size: 20,
            ),
        ],
      ),
    );
  }
}

