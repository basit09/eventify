import 'package:event_management/features/profile/presentation/screens/profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/authentication/data/repositories/firebase_auth_repository.dart';
import '../../features/authentication/presentation/screens/login_screen.dart';
import '../../features/main_navigation/presentation/screens/main_scaffold.dart';
import '../../features/event/presentation/screens/home_screen.dart';
import '../../features/category/presentation/screens/category_screen.dart';
import '../../features/event/presentation/screens/create_event_screen.dart';
import '../../features/event/presentation/screens/all_events_screen.dart';
import '../../features/event/presentation/screens/event_detail_screen.dart';
import '../../features/event/presentation/screens/edit_event_screen.dart';
import '../../features/event/domain/entities/event_entity.dart';

final rootNavigatorKey = GlobalKey<NavigatorState>();

final routerNotifierProvider = Provider<RouterNotifier>((ref) {
  return RouterNotifier(ref);
});

class RouterNotifier extends ChangeNotifier {
  final Ref _ref;
  RouterNotifier(this._ref) {
    _ref.listen(authStateProvider, (previous, next) => notifyListeners());
  }
}

final goRouterProvider = Provider<GoRouter>((ref) {
  final notifier = ref.watch(routerNotifierProvider);

  return GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: '/home',
    refreshListenable: notifier,
    redirect: (context, state) {
      final authState = ref.read(authStateProvider);
      if (authState.isLoading || authState.hasError) return null;

      final isAuthenticated = authState.value != null;
      final isGoingToLogin = state.matchedLocation == '/login';

      if (!isAuthenticated && !isGoingToLogin) {
        return '/login';
      }

      if (isAuthenticated && isGoingToLogin) {
        return '/home';
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return MainScaffold(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/home',
                builder: (context, state) => const HomeScreen(),
                routes: [
                  GoRoute(
                    path: 'all-events',
                    builder: (context, state) => const AllEventsScreen(),
                  ),
                  GoRoute(
                    path: 'create-event',
                    parentNavigatorKey: rootNavigatorKey,
                    builder: (context, state) => const CreateEventScreen(),
                  ),
                  GoRoute(
                    path: 'event-detail',
                    parentNavigatorKey: rootNavigatorKey,
                    builder: (context, state) {
                      final event = state.extra as EventEntity;
                      return EventDetailScreen(event: event);
                    },
                    routes: [
                      GoRoute(
                        path: 'edit',
                        parentNavigatorKey: rootNavigatorKey,
                        builder: (context, state) {
                          final event = state.extra as EventEntity;
                          return EditEventScreen(event: event);
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/categories',
                builder: (context, state) => const CategoryScreen(),
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
