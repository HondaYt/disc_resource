import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import 'pages/disc_main.dart';
import 'pages/liked_music.dart';
import 'pages/select_music.dart';
import 'pages/user_search.dart';
import 'pages/user_info.dart';
import 'pages/edit_user_info.dart';
import '../pages/request_permission.dart';
import '../pages/sign_in.dart';
import 'components/auth_state.dart';

final GoRouter router = GoRouter(
  routes: <RouteBase>[
    GoRoute(
      path: '/',
      builder: (context, state) => const AuthState(),
      routes: [
        GoRoute(
          path: 'sign_in',
          builder: (context, state) => SignInPage(),
        ),
        GoRoute(
          path: 'permission',
          builder: (context, state) => const PermissionPage(),
        ),
        StatefulShellRoute.indexedStack(
          builder: (BuildContext context, GoRouterState state,
              StatefulNavigationShell navigationShell) {
            return DiscMain(child: navigationShell);
          },
          branches: [
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: 'select_music',
                  builder: (context, state) => const SelectMusic(),
                ),
              ],
            ),
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: 'liked',
                  builder: (context, state) => const LikedMusic(),
                ),
              ],
            ),
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: 'user_search',
                  builder: (context, state) => const UserSearch(),
                ),
              ],
            ),
          ],
        ),
      ],
    ),
    GoRoute(
      path: '/user_info',
      builder: (context, state) => const UserInfoPage(),
      routes: [
        GoRoute(
          path: 'edit_user_info',
          builder: (context, state) => const EditUserInfoPage(),
        ),
      ],
    ),
  ],
);
