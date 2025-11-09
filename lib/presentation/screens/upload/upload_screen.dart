import 'package:flutter/material.dart';
import 'package:spendwise_client/l10n/app_localizations.dart';
import '../../../../core/constants/app_constants.dart';
import '../../widgets/layout/app_scaffold.dart';
import 'widgets/file_picker_button.dart';
import 'widgets/file_list_widget.dart';

class UploadScreen extends StatelessWidget {
  const UploadScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return AppScaffold(
      title: l10n.uploadStatement,
      currentIndex: 1,
      showBottomNav: false,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppConstants.spacingLG),
        child: const Column(
          children: [
            FilePickerButton(),
            SizedBox(height: AppConstants.spacingXL),
            FileListWidget(),
          ],
        ),
      ),
    );
  }
}

