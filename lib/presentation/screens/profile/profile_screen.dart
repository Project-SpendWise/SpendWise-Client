import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spendwise_client/l10n/app_localizations.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../providers/auth_provider.dart';
import '../../widgets/layout/app_scaffold.dart';
import '../../widgets/common/custom_card.dart';
import 'widgets/settings_section.dart';
import 'widgets/edit_profile_dialog.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    return AppScaffold(
      title: l10n.profile,
      currentIndex: 3,
      showBottomNav: false,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppConstants.spacingLG),
        child: Column(
          children: [
            // User Info Card
            CustomCard(
              padding: const EdgeInsets.all(AppConstants.spacingXL),
              child: Column(
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                    ),
                    child: Icon(
                      Icons.person,
                      size: 40,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: AppConstants.spacingLG),
                  Text(
                    ref.watch(authProvider).user?.displayName ?? l10n.user,
                    style: AppTextStyles.h3,
                  ),
                  const SizedBox(height: AppConstants.spacingSM),
                  Text(
                    ref.watch(authProvider).user?.email ?? 'user@example.com',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: Theme.of(context).textTheme.bodySmall?.color,
                    ),
                  ),
                  const SizedBox(height: AppConstants.spacingLG),
                  OutlinedButton.icon(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) => const EditProfileDialog(),
                      );
                    },
                    icon: const Icon(Icons.edit_outlined),
                    label: Text(l10n.editProfile),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppConstants.spacingXL),

            // Settings
            const SettingsSection(),
          ],
        ),
      ),
    );
  }
}

