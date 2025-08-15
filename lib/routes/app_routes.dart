import 'package:flutter/material.dart';
import 'package:linetheories/ui/screens/profile_screen.dart';
import 'package:linetheories/ui/screens/home_screen.dart';
import 'package:linetheories/ui/screens/splash_scereen.dart';
import '../ui/screens/login_screen.dart';
import '../ui/screens/signup_screen.dart';

// Dashboard
import '../ui/screens/dashboards/admin_dashboard.dart';

class AppRoutes {
  static const String splash = '/';
  static const String login = '/login';
  static const String signup = '/signup';
  static const String home = '/home';
  static const String profile = '/profile';

  // Dashboard
  static const String adminDashboard = '/adminDashboard';

  static Map<String, WidgetBuilder> getRoutes() {
    return {
      splash: (context) => const SplashScreen(),
      login: (context) => const LoginScreen(),
      signup: (context) => const SignUpScreen(),
      home: (context) => const HomeScreen(),
      profile: (context) => const ProfileScreen(),

      // Dashboard
      adminDashboard: (context) => const AdminDashboard(),
    };
  }
}
