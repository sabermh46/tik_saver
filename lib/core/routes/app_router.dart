// lib/core/routes/app_router.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Import your new files
import 'package:tik_saver/features/auth/provider/auth_provider.dart';
import 'package:tik_saver/features/auth/presentation/login_page.dart';
import 'package:tik_saver/features/auth/presentation/register_page.dart'; // Import register page
import 'package:tik_saver/features/auth/presentation/forgot_password_page.dart'; // Import forgot password page
import 'package:tik_saver/features/home/presentation/home_page.dart';

import '../../features/downloads/presentation/downloads_page.dart';

final goRouterProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authProvider);

  return GoRouter(
    initialLocation: '/login',
    routes: [
      GoRoute(path: '/login', builder: (context, state) => const LoginPage()),
      GoRoute(path: '/register', builder: (context, state) => const RegisterPage()),
      GoRoute(path: '/forgot-password', builder: (context, state) => const ForgotPasswordPage()),
      GoRoute(path: '/home', builder: (context, state) => const HomePage()),
      GoRoute(path: '/downloads', builder: (context, state) => const DownloadsPage()),
      // Add other protected routes here
    ],
    redirect: (context, state) {
      final isLoggedIn = authState.user != null;
      final unauthenticatedRoutes = ['/login', '/register', '/forgot-password'];

      final isUnauthenticatedRoute = unauthenticatedRoutes.contains(state.uri.toString());

      if (!isLoggedIn && !isUnauthenticatedRoute) {
        return '/login';
      }
      if (isLoggedIn && isUnauthenticatedRoute) {
        return '/home';
      }
      return null;
    },
  );
});