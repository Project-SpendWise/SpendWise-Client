import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_text_styles.dart';
import '../../data/models/statement.dart';
import '../../providers/upload_provider.dart';
import '../../providers/profile_provider.dart';

class ProfileSelector extends ConsumerWidget {
  const ProfileSelector({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final uploadState = ref.watch(uploadProvider);
    final profileState = ref.watch(profileProvider);
    final statements = uploadState.statements.where((s) => s.isProcessed).toList();

    if (statements.isEmpty) {
      return const SizedBox.shrink();
    }

    // Auto-select default profile if no profile is selected
    if (profileState.selectedProfileId == null && statements.isNotEmpty) {
      final defaultStatement = statements.firstWhere(
        (s) => s.isDefault,
        orElse: () => statements.first,
      );
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(profileProvider.notifier).selectProfile(
          defaultStatement.id,
          defaultStatement,
        );
      });
    }

    // Find the selected statement
    BankStatement? selectedStatement;
    if (profileState.selectedProfileId != null) {
      try {
        selectedStatement = statements.firstWhere(
          (s) => s.id == profileState.selectedProfileId,
        );
      } catch (e) {
        // Selected profile not found, use default or first
        selectedStatement = statements.firstWhere(
          (s) => s.isDefault,
          orElse: () => statements.first,
        );
      }
    } else {
      // Default to the default profile or first one
      selectedStatement = statements.firstWhere(
        (s) => s.isDefault,
        orElse: () => statements.first,
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.spacingMD,
        vertical: AppConstants.spacingSM,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(AppConstants.radiusMD),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<BankStatement>(
          value: selectedStatement,
          isExpanded: true,
          icon: Icon(
            Icons.arrow_drop_down,
            color: Theme.of(context).colorScheme.onSurface,
          ),
          items: statements.map((statement) {
            final displayName = statement.profileName ?? statement.fileName;
            return DropdownMenuItem<BankStatement>(
              value: statement,
              child: Row(
                children: [
                  if (statement.color != null)
                    Container(
                      width: 16,
                      height: 16,
                      decoration: BoxDecoration(
                        color: _parseColor(statement.color!),
                        shape: BoxShape.circle,
                      ),
                      margin: const EdgeInsets.only(right: AppConstants.spacingSM),
                    ),
                  Expanded(
                    child: Text(
                      displayName,
                      style: AppTextStyles.bodyMedium,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (statement.isDefault)
                    Padding(
                      padding: const EdgeInsets.only(left: AppConstants.spacingSM),
                      child: Icon(
                        Icons.star,
                        size: 16,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                ],
              ),
            );
          }).toList(),
          onChanged: (BankStatement? newStatement) {
            if (newStatement != null) {
              ref.read(profileProvider.notifier).selectProfile(
                newStatement.id,
                newStatement,
              );
            }
          },
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
}

