import 'package:flutter/material.dart';
import 'bottom_nav_bar.dart';

class AppScaffold extends StatelessWidget {
  final String title;
  final Widget body;
  final int currentIndex;
  final Function(int)? onNavTap;
  final List<Widget>? actions;
  final bool showBottomNav;

  const AppScaffold({
    super.key,
    required this.title,
    required this.body,
    this.currentIndex = 0,
    this.onNavTap,
    this.actions,
    this.showBottomNav = true,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: actions,
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

