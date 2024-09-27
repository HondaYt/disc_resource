import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';

import 'components/disc_main.dart';
import 'pages/liked_music.dart';
import 'pages/select_music.dart';
import 'pages/user_search.dart';
import 'pages/user_info.dart';
import 'pages/edit_user_info.dart';
import '../pages/request_permission.dart';
import '../pages/sign_in.dart';

import 'package:permission_handler/permission_handler.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final supabase = Supabase.instance.client;

// リダイレクト状態を管理するための変数

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();

final GoRouter router = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/',
  redirect: (context, state) async {
    final session = supabase.auth.currentSession;
    final permission = await Permission.mediaLibrary.status.isGranted;
    if (session == null) {
      return '/sign_in';
    } else if (!permission) {
      return '/permission';
    } else {
      return null;
    }
  },
  routes: <RouteBase>[
    StatefulShellRoute.indexedStack(
      builder: (BuildContext context, GoRouterState state,
          StatefulNavigationShell navigationShell) {
        return DiscMain(child: navigationShell);
      },
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/',
              builder: (context, state) => const SelectMusic(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/liked',
              builder: (context, state) => const LikedMusic(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/user_search',
              builder: (context, state) => const UserSearch(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/user_info',
              builder: (context, state) => const UserInfoPage(),
              routes: [
                GoRoute(
                  path: 'edit',
                  builder: (context, state) => const EditUserInfoPage(),
                ),
              ],
            ),
          ],
        ),
      ],
    ),
    GoRoute(
      path: '/sign_in',
      builder: (context, state) => SignInPage(),
    ),
    GoRoute(
      path: '/permission',
      builder: (context, state) => const PermissionPage(),
    ),
  ],
);
