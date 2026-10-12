import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../domain/entities/book.dart';
import '../../presentation/auth/auth_bloc.dart';
import '../../presentation/auth/auth_page.dart';
import '../../presentation/auth/splash_page.dart';
import '../../presentation/library/add_book_page.dart';
import '../../presentation/library/book_details_page.dart';
import '../../presentation/library/library_page.dart';
import '../../presentation/search/search_page.dart';
import '../../presentation/settings/settings_page.dart';
import '../../presentation/shell/home_shell.dart';
import '../../presentation/stats/stats_page.dart';

/// Имена маршрутов (именованная навигация).
abstract final class AppRoutes {
  static const splash = 'splash';
  static const login = 'login';
  static const register = 'register';
  static const library = 'library';
  static const bookDetails = 'bookDetails';
  static const search = 'search';
  static const stats = 'stats';
  static const settings = 'settings';
  static const add = 'add';
}

/// Заставляет GoRouter перечитывать redirect при каждом новом состоянии потока.
class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    _subscription = stream.listen((_) => notifyListeners());
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}

GoRouter createRouter(AuthBloc authBloc) {
  final rootKey = GlobalKey<NavigatorState>(debugLabel: 'root');

  return GoRouter(
    navigatorKey: rootKey,
    initialLocation: '/splash',
    refreshListenable: GoRouterRefreshStream(authBloc.stream),
    // Защита маршрутов: без входа доступны только /login и /register.
    redirect: (context, state) {
      final status = authBloc.state.status;
      final location = state.matchedLocation;
      final onAuthPage = location == '/login' || location == '/register';

      if (status == AuthStatus.unknown) {
        return location == '/splash' ? null : '/splash';
      }
      if (status == AuthStatus.unauthenticated) {
        return onAuthPage ? null : '/login';
      }
      // authenticated
      if (onAuthPage || location == '/splash') return '/library';
      return null;
    },
    routes: [
      GoRoute(
        path: '/splash',
        name: AppRoutes.splash,
        builder: (context, state) => const SplashPage(),
      ),
      GoRoute(
        path: '/login',
        name: AppRoutes.login,
        builder: (context, state) => const AuthPage(isRegister: false),
      ),
      GoRoute(
        path: '/register',
        name: AppRoutes.register,
        builder: (context, state) => const AuthPage(isRegister: true),
      ),
      // Полноэкранная форма поверх нижней навигации; параметр передаётся через extra.
      GoRoute(
        path: '/add',
        name: AppRoutes.add,
        parentNavigatorKey: rootKey,
        builder: (context, state) => AddBookPage(initial: state.extra as Book?),
      ),
      // Вложенная навигация: каждая вкладка хранит свой стек.
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            HomeShell(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/library',
                name: AppRoutes.library,
                builder: (context, state) => const LibraryPage(),
                routes: [
                  GoRoute(
                    path: 'book/:id',
                    name: AppRoutes.bookDetails,
                    builder: (context, state) =>
                        BookDetailsPage(bookId: state.pathParameters['id']!),
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/search',
                name: AppRoutes.search,
                builder: (context, state) => const SearchPage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/stats',
                name: AppRoutes.stats,
                builder: (context, state) => const StatsPage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/settings',
                name: AppRoutes.settings,
                builder: (context, state) => const SettingsPage(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
}
