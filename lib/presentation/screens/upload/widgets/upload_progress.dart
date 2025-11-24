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
    final displayName = statement.profileName ?? statement.fileName;
    final hasProfileInfo = statement.profileName != null || 
                          statement.bankName != null ||
                          statement.accountType != null;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppConstants.spacingLG),
      child: Container(
        padding: const EdgeInsets.all(AppConstants.spacingMD),
        decoration: BoxDecoration(
          color: statement.color != null 
              ? _parseColor(statement.color!).withOpacity(0.1)
              : Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(AppConstants.radiusMD),
          border: Border.all(
            color: statement.color != null 
                ? _parseColor(statement.color!).withOpacity(0.3)
                : Theme.of(context).colorScheme.outline.withOpacity(0.2),
          ),
        ),
        child: Row(
          children: [
            // Color indicator or icon
            if (statement.color != null)
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: _parseColor(statement.color!),
                  shape: BoxShape.circle,
                ),
                child: statement.icon != null
                    ? Icon(
                        _getIcon(statement.icon!),
                        color: Colors.white,
                        size: 20,
                      )
                    : null,
              )
            else
              Icon(
                Icons.description,
                color: Theme.of(context).colorScheme.primary,
                size: 24,
              ),
            const SizedBox(width: AppConstants.spacingMD),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          displayName,
                          style: AppTextStyles.bodyMedium.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      if (statement.isDefault)
                        Icon(
                          Icons.star,
                          size: 16,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                    ],
                  ),
                  if (hasProfileInfo) ...[
                    const SizedBox(height: 4),
                    if (statement.bankName != null)
                      Text(
                        statement.bankName!,
                        style: AppTextStyles.bodySmall,
                      ),
                    if (statement.accountType != null)
                      Text(
                        statement.accountType!,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: Theme.of(context).textTheme.bodySmall?.color,
                        ),
                      ),
                  ] else
                    Text(
                      DateFormatter.formatShort(statement.uploadDate),
                      style: AppTextStyles.bodySmall,
                    ),
                ],
              ),
            ),
            const SizedBox(width: AppConstants.spacingSM),
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
      ),
    );
  }

  Color _parseColor(String colorString) {
    try {
      return Color(int.parse(colorString.replaceFirst('#', '0xFF')));
    } catch (e) {
      return Colors.blue;
    }
  }

  IconData _getIcon(String iconName) {
    // Map common icon names to Material icons
    switch (iconName.toLowerCase()) {
      case 'wallet':
        return Icons.account_balance_wallet;
      case 'bank':
        return Icons.account_balance;
      case 'card':
        return Icons.credit_card;
      case 'savings':
        return Icons.savings;
      case 'investment':
        return Icons.trending_up;
      default:
        return Icons.account_balance_wallet;
    }
  }
}

