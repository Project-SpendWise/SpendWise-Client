import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:spendwise_client/l10n/app_localizations.dart';
import '../../providers/auth_provider.dart';
import '../screens/home/home_screen.dart';
import '../screens/upload/upload_screen.dart';
import '../screens/analytics/analytics_screen.dart';
import '../screens/profile/profile_screen.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/register_screen.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

final routerProvider = Provider<GoRouter>((ref) {
  // Only watch isAuthenticated to prevent rebuilds on profile updates
  final isAuthenticated = ref.watch(authProvider.select((state) => state.isAuthenticated));

  return GoRouter(
    navigatorKey: navigatorKey,
    initialLocation: isAuthenticated ? '/home' : '/login',
    redirect: (context, state) {
      final isLoggingIn = state.matchedLocation == '/login' || state.matchedLocation == '/register';
      
      // Don't redirect if we're already on a protected route and authenticated
      // This prevents unnecessary redirects when profile is updated
      final isOnProtectedRoute = state.matchedLocation.startsWith('/home') ||
          state.matchedLocation.startsWith('/upload') ||
          state.matchedLocation.startsWith('/analytics') ||
          state.matchedLocation.startsWith('/profile');

      // If not authenticated and trying to access protected route
      if (!isAuthenticated && !isLoggingIn) {
        return '/login';
      }

      // If authenticated and trying to access auth routes
      if (isAuthenticated && isLoggingIn) {
        return '/home';
      }

      // Don't redirect if already on a valid protected route
      if (isAuthenticated && isOnProtectedRoute) {
        return null;
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return _NavigationWrapper(navigationShell: navigationShell);
      },
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/home',
              builder: (context, state) => const HomeScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/upload',
              builder: (context, state) => const UploadScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/analytics',
              builder: (context, state) => const AnalyticsScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/profile',
              builder: (context, state) => const ProfileScreen(),
            ),
          ],
        ),
      ],
    ),
    ],
  );
});

class _NavigationWrapper extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const _NavigationWrapper({required this.navigationShell});

  @override
  Widget build(BuildContext context) {
    return ScaffoldWithNavigationBar(navigationShell: navigationShell);
  }
}

class ScaffoldWithNavigationBar extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const ScaffoldWithNavigationBar({required this.navigationShell});

  void _onTap(int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: _BottomNavBar(
        currentIndex: navigationShell.currentIndex,
        onTap: _onTap,
      ),
    );
  }
}

class _BottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const _BottomNavBar({
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    const inactiveColor = Color(0xFF9CA3AF);
    const activeColor = Color(0xFF2563EB);

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        border: Border(
          top: BorderSide(
            color: isDark ? const Color(0xFF334155) : const Color(0xFFE5E7EB),
            width: 1,
          ),
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _NavItem(
                icon: Icons.dashboard_outlined,
                activeIcon: Icons.dashboard,
                label: l10n.home,
                isActive: currentIndex == 0,
                onTap: () => onTap(0),
                activeColor: activeColor,
                inactiveColor: inactiveColor,
              ),
              _NavItem(
                icon: Icons.cloud_upload_outlined,
                activeIcon: Icons.cloud_upload,
                label: l10n.upload,
                isActive: currentIndex == 1,
                onTap: () => onTap(1),
                activeColor: activeColor,
                inactiveColor: inactiveColor,
              ),
              _NavItem(
                icon: Icons.analytics_outlined,
                activeIcon: Icons.analytics,
                label: l10n.analytics,
                isActive: currentIndex == 2,
                onTap: () => onTap(2),
                activeColor: activeColor,
                inactiveColor: inactiveColor,
              ),
              _NavItem(
                icon: Icons.person_outline,
                activeIcon: Icons.person,
                label: l10n.profile,
                isActive: currentIndex == 3,
                onTap: () => onTap(3),
                activeColor: activeColor,
                inactiveColor: inactiveColor,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;
  final Color activeColor;
  final Color inactiveColor;

  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.isActive,
    required this.onTap,
    required this.activeColor,
    required this.inactiveColor,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isActive ? activeIcon : icon,
                color: isActive ? activeColor : inactiveColor,
                size: 24,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: isActive ? activeColor : inactiveColor,
                      fontSize: 11,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

