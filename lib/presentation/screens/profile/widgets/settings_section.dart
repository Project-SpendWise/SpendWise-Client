import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:spendwise_client/l10n/app_localizations.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../providers/theme_provider.dart';
import '../../../../providers/language_provider.dart';
import '../../../../providers/auth_provider.dart';
import '../../../widgets/common/custom_card.dart';
import 'change_password_dialog.dart';

class SettingsSection extends ConsumerWidget {
  const SettingsSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final themeMode = ref.watch(themeProvider);
    final currentLocale = ref.watch(languageProvider);

    return CustomCard(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          _SettingsItem(
            icon: Icons.dark_mode_outlined,
            title: l10n.darkMode,
            subtitle: themeMode == ThemeMode.dark
                ? l10n.on
                : themeMode == ThemeMode.light
                    ? l10n.off
                    : l10n.system,
            trailing: Switch(
              value: themeMode == ThemeMode.dark,
              onChanged: (value) {
                ref.read(themeProvider.notifier).setTheme(
                      value ? ThemeMode.dark : ThemeMode.light,
                    );
              },
            ),
          ),
          _Divider(),
          _SettingsItem(
            icon: Icons.language,
            title: l10n.language,
            subtitle: currentLocale.languageCode == 'tr' ? l10n.turkish : l10n.english,
            trailing: DropdownButton<Locale>(
              value: currentLocale,
              underline: const SizedBox(),
              items: [
                DropdownMenuItem(
                  value: const Locale('en'),
                  child: Text(l10n.english),
                ),
                DropdownMenuItem(
                  value: const Locale('tr'),
                  child: Text(l10n.turkish),
                ),
              ],
              onChanged: (Locale? newLocale) {
                if (newLocale != null) {
                  ref.read(languageProvider.notifier).setLanguage(newLocale);
                }
              },
            ),
          ),
          _Divider(),
          _SettingsItem(
            icon: Icons.notifications_outlined,
            title: l10n.notifications,
            subtitle: l10n.on,
            trailing: Switch(
              value: true,
              onChanged: (value) {
                // Handle notification toggle
              },
            ),
          ),
          _Divider(),
          _SettingsItem(
            icon: Icons.lock_outlined,
            title: l10n.changePassword,
            onTap: () {
              showDialog(
                context: context,
                builder: (context) => const ChangePasswordDialog(),
              );
            },
          ),
          _Divider(),
          _SettingsItem(
            icon: Icons.info_outline,
            title: l10n.about,
            subtitle: '${l10n.version} 1.0.0',
            onTap: () {
              showAboutDialog(
                context: context,
                applicationName: l10n.appName,
                applicationVersion: '1.0.0',
                applicationLegalese: l10n.appSlogan,
              );
            },
          ),
          _Divider(),
          _SettingsItem(
            icon: Icons.logout_outlined,
            title: l10n.signOut,
            titleColor: Colors.red,
            onTap: () async {
              final shouldLogout = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text(l10n.signOut),
                  content: Text(l10n.signOutConfirm),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      child: Text(l10n.cancel),
                    ),
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(true),
                      child: Text(
                        l10n.signOut,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
                  ],
                ),
              );

              if (shouldLogout == true && context.mounted) {
                await ref.read(authProvider.notifier).logout();
                if (context.mounted) {
                  context.go('/login');
                }
              }
            },
          ),
        ],
      ),
    );
  }
}

class _SettingsItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  final Color? titleColor;

  const _SettingsItem({
    required this.icon,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
    this.titleColor,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.spacingLG),
        child: Row(
          children: [
            Icon(
              icon,
              color: titleColor ??
                  (isDark
                      ? const Color(0xFFCBD5E1)
                      : const Color(0xFF111827)),
            ),
            const SizedBox(width: AppConstants.spacingMD),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: titleColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle!,
                      style: AppTextStyles.bodySmall,
                    ),
                  ],
                ],
              ),
            ),
            if (trailing != null) trailing!,
            if (trailing == null && onTap != null)
              Icon(
                Icons.chevron_right,
                color: isDark
                    ? const Color(0xFF94A3B8)
                    : const Color(0xFF9CA3AF),
              ),
          ],
        ),
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Divider(
      height: 1,
      thickness: 1,
      indent: AppConstants.spacingLG + 24 + AppConstants.spacingMD,
      color: isDark ? const Color(0xFF334155) : const Color(0xFFE5E7EB),
    );
  }
}

