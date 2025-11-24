import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../profile_selector.dart';
import 'bottom_nav_bar.dart';

class AppScaffold extends ConsumerWidget {
  final String title;
  final Widget body;
  final int currentIndex;
  final Function(int)? onNavTap;
  final List<Widget>? actions;
  final bool showBottomNav;
  final bool showProfileSelector;

  const AppScaffold({
    super.key,
    required this.title,
    required this.body,
    this.currentIndex = 0,
    this.onNavTap,
    this.actions,
    this.showBottomNav = true,
    this.showProfileSelector = true,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allActions = <Widget>[];
    
    // Add profile selector if enabled
    if (showProfileSelector) {
      allActions.add(
        Padding(
          padding: const EdgeInsets.only(right: 8.0),
          child: SizedBox(
            width: 200,
            child: ProfileSelector(),
          ),
        ),
      );
    }
    
    // Add custom actions
    if (actions != null) {
      allActions.addAll(actions!);
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: allActions.isEmpty ? null : allActions,
      ),
      body: body,
      bottomNavigationBar: showBottomNav && onNavTap != null
          ? BottomNavBar(
              currentIndex: currentIndex,
              onTap: onNavTap!,
            )
          : null,
    );
  }
}

