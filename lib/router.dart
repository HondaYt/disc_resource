import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import 'package:sheet/route.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'providers/follow_list_provider.dart';
import 'components/app_navigation_bar.dart';
import 'providers/user_info_provider.dart';

import 'pages/liked_songs.dart';
import 'pages/select_music.dart';
import 'pages/user_search.dart';
import 'pages/user_info.dart';
import 'pages/user_info_edit.dart';
import 'pages/request_permission.dart';
import 'pages/request_sign_in.dart';
import 'pages/request_user_register.dart';
import 'pages/follow_list.dart';

final supabase = Supabase.instance.client;

// リダイレクト状態を管理するための変数

final rootNavigatorKey = GlobalKey<NavigatorState>();
final nestedNavigationKey = GlobalKey<NavigatorState>();

final router = Provider<GoRouter>((ref) {
  return GoRouter(
    debugLogDiagnostics: true,
    navigatorKey: rootNavigatorKey,
    initialLocation: '/',
    redirect: (context, state) async {
      final userInfo = ref.watch(userInfoProvider);
      final session = supabase.auth.currentSession;
      final permission = await Permission.mediaLibrary.status.isGranted;
      if (session == null) {
        return '/sign_in';
      } else if (userInfo == null || userInfo['user_id'] == null) {
        return '/user_register';
      } else if (!permission) {
        return '/permission';
      } else {
        return null;
      }
    },
    routes: <RouteBase>[
      StatefulShellRoute.indexedStack(
        pageBuilder: (BuildContext context, GoRouterState state,
            StatefulNavigationShell navigationShell) {
          return MaterialExtendedPage<void>(
            key: state.pageKey,
            child: AppNavigationBar(navigationShell: navigationShell),
          );
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/',
                builder: (BuildContext context, GoRouterState state) {
                  return const SelectMusicPage();
                },
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/liked',
                builder: (context, state) => const LikedSongsPage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/user_search',
                builder: (context, state) => const UserSearchPage(),
              ),
            ],
          ),
        ],
      ),
      ShellRoute(
        parentNavigatorKey: rootNavigatorKey,
        navigatorKey: nestedNavigationKey,
        pageBuilder: (context, state, child) {
          return CupertinoSheetPage<void>(child: child);
        },
        routes: [
          GoRoute(
            path: '/user_info',
            pageBuilder: (BuildContext context, GoRouterState state) {
              return MaterialPage<void>(
                key: state.pageKey,
                child: const UserInfoPage(),
              );
            },
            routes: [
              GoRoute(
                path: 'edit',
                parentNavigatorKey: nestedNavigationKey,
                pageBuilder: (context, state) {
                  return MaterialPage<void>(
                    key: state.pageKey,
                    child: const UserInfoEditPage(),
                  );
                },
              ),
              GoRoute(
                path: 'followers',
                parentNavigatorKey: nestedNavigationKey,
                pageBuilder: (context, state) {
                  return MaterialPage<void>(
                    key: state.pageKey,
                    child: FollowListPage(
                      title: 'フォロワー',
                      provider: followersListProvider,
                    ),
                  );
                },
              ),
              GoRoute(
                path: 'following',
                parentNavigatorKey: nestedNavigationKey,
                pageBuilder: (context, state) {
                  return MaterialPage<void>(
                    key: state.pageKey,
                    child: FollowListPage(
                      title: 'フォロー中',
                      provider: followingListProvider,
                    ),
                  );
                },
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
      GoRoute(
        path: '/user_register',
        builder: (context, state) => const UserRegisterPage(),
      ),
    ],
  );
});
