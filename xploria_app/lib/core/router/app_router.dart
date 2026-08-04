import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:xploria_app/features/splash/presentation/pages/splash_screen.dart';
import 'package:xploria_app/features/auth/presentation/pages/welcome_screen.dart';
import 'package:xploria_app/features/auth/presentation/pages/login_screen.dart';
import 'package:xploria_app/features/auth/presentation/pages/register_screen.dart';
import 'package:xploria_app/features/dashboard/presentation/pages/dashboard_screen.dart';
import 'package:xploria_app/features/projects/presentation/pages/project_list_screen.dart';
import 'package:xploria_app/features/lessons_modules/presentation/pages/lessons_modules_page.dart';
import 'package:xploria_app/features/device/presentation/pages/device_connection_screen.dart';
import 'package:xploria_app/features/blockly_workspace/presentation/pages/blockly_workspace_screen.dart';
import 'package:xploria_app/features/auth/data/data_sources/auth_storage_service.dart';

import 'package:xploria_app/features/account/presentation/pages/account_page.dart';
import 'package:xploria_app/features/content/presentation/pages/module_detail_screen.dart';
import 'package:xploria_app/features/iot_blynk/presentation/screens/blynk_canvas_screen.dart';
import 'package:xploria_app/features/blockly_workspace/presentation/pages/python_editor_screen.dart';
import 'package:xploria_app/features/projects/domain/models/project_model.dart';
import 'package:xploria_app/features/subscriptions/presentation/pages/paywall_screen.dart';
import 'package:xploria_app/features/content/domain/models/learning_module_model.dart';

class AppRouter {
  static final _rootNavigatorKey = GlobalKey<NavigatorState>();

  static final GoRouter router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/',
    redirect: (context, state) {
      final authStorage = AuthStorageService();
      
      // Jangan redirect jika masih di splash screen (sedang memuat info auth)
      if (state.matchedLocation == '/') {
        return null;
      }
      
      final bool isAuthenticated = authStorage.isAuthenticated;
      final bool isGoingToAuth = state.matchedLocation == '/welcome' || 
                                 state.matchedLocation == '/login' || 
                                 state.matchedLocation == '/register';

      // Proteksi rute internal
      if (!isAuthenticated && !isGoingToAuth) {
        return '/welcome';
      }
      
      // Cegah user yang sudah login kembali ke layar auth
      if (isAuthenticated && isGoingToAuth) {
        return '/dashboard';
      }
      
      return null;
    },
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => SplashScreen(
          onFinished: () async {
            final authStorage = AuthStorageService();
            await authStorage.init();
            
            if (context.mounted) {
              if (authStorage.isAuthenticated) {
                context.go('/dashboard');
              } else {
                context.go('/welcome');
              }
            }
          },
        ),
      ),
      GoRoute(
        path: '/welcome',
        builder: (context, state) => const WelcomeScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/dashboard',
        builder: (context, state) => const DashboardScreen(),
      ),
      GoRoute(
        path: '/projects',
        builder: (context, state) => const ProjectListScreen(),
      ),
      GoRoute(
        path: '/lessons',
        builder: (context, state) => const LessonsModulesPage(),
      ),
      GoRoute(
        path: '/device-connection',
        builder: (context, state) => const DeviceConnectionScreen(),
      ),
      GoRoute(
        path: '/blockly',
        builder: (context, state) {
          final project = state.extra as ProjectModel?;
          return BlocklyWorkspaceScreen(project: project);
        },
      ),
      GoRoute(
        path: '/account',
        builder: (context, state) => const AccountPage(),
      ),
      GoRoute(
        path: '/module-detail',
        builder: (context, state) {
          final args = state.extra as Map<String, dynamic>? ?? {};
          final module = args['module'] as LearningModuleModel;
          final canAccess = args['canAccess'] as bool? ?? false;
          return ModuleDetailScreen(module: module, canAccess: canAccess);
        },
      ),
      GoRoute(
        path: '/python-editor',
        builder: (context, state) {
          final code = state.extra as String? ?? '';
          return PythonEditorScreen(initialCode: code);
        },
      ),
      GoRoute(
        path: '/blynk-canvas',
        builder: (context, state) {
          final args = state.extra as Map<String, dynamic>? ?? {};
          final project = args['project'] as ProjectModel;
          final onSave = args['onSave'] as ValueChanged<ProjectModel>?;
          return BlynkCanvasScreen(project: project, onSaveBlynkConfig: onSave);
        },
      ),
      GoRoute(
        path: '/paywall',
        builder: (context, state) => const PaywallScreen(),
      ),
    ],
  );
}
