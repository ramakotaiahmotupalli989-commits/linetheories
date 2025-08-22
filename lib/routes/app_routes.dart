import 'package:flutter/material.dart';
import 'package:linetheories/ui/screens/add_project_screen.dart';
import 'package:linetheories/ui/screens/editproject_screen.dart';
import 'package:linetheories/ui/screens/project_details_screen.dart';
import 'package:linetheories/ui/screens/splash_screen.dart';
import 'package:linetheories/ui/screens/login_screen.dart';
import 'package:linetheories/ui/screens/home_screen.dart';
import 'package:linetheories/ui/screens/profile_screen.dart';
import 'package:linetheories/ui/screens/dashboards/dashboard_base.dart';
import 'package:linetheories/models/project.dart';

class AppRoutes {
  // Common
  static const String splash = '/';
  static const String login = '/login';
  static const String home = '/home';
  static const String profile = '/profile';

  // Dashboards
  static const String adminDashboard = '/adminDashboard';
  static const String designTeamDashboard = '/designTeamDashboard';
  static const String siteInchargeDashboard = '/siteInchargeDashboard';
  static const String projectManagerDashboard = '/projectManagerDashboard';

  // Projects
  static const String addProject = '/addProject';
  static const String projectDetails = '/projectDetails';
  static const String editProject = '/editProject';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case splash:
        return MaterialPageRoute(builder: (_) => const SplashScreen());

      case login:
        return MaterialPageRoute(builder: (_) => const LoginScreen());

      case home:
        return MaterialPageRoute(builder: (_) => const HomeScreen());

      case profile:
        return MaterialPageRoute(builder: (_) => const ProfileScreen());

      // Dashboards
      case adminDashboard:
        return MaterialPageRoute(builder: (_) => const AdminDashboard());

      case designTeamDashboard:
        return MaterialPageRoute(builder: (_) => const DesignTeamDashboard());

      case siteInchargeDashboard:
        return MaterialPageRoute(builder: (_) => const SiteInchargeDashboard());

      case projectManagerDashboard:
        return MaterialPageRoute(builder: (_) => const ProjectManagerDashboard());

      // Add Project
      case addProject:
        final args = settings.arguments as Map<String, dynamic>?;
        final onAdd = args?['onAdd'] as Function(Project)?;
        return MaterialPageRoute(
          builder: (_) => AddProjectScreen(onAdd: onAdd ?? (p) {}),
        );

      // Project Details
      case projectDetails:
        final args = settings.arguments as Map<String, dynamic>;
        final project = args['project'] is Project
            ? args['project'] as Project
            : Project.fromJson(args['project'] as Map<String, dynamic>);

        final onUpdate = args['onProjectUpdate'] as Function(Project);

        return MaterialPageRoute(
          builder: (_) => ProjectDetailsScreen(
            project: project,
            onProjectUpdate: onUpdate,
          ),
        );

      // Edit Project
      case editProject:
        final args = settings.arguments as Map<String, dynamic>;
        final project = args['project'] is Project
            ? args['project'] as Project
            : Project.fromJson(args['project'] as Map<String, dynamic>);

        final onSave = args['onSave'] as Function(Project);

        return MaterialPageRoute(
          builder: (_) => EditProjectScreen(
            project: project,
            onSave: onSave,
          ),
        );

      default:
        return MaterialPageRoute(
          builder: (_) => const Scaffold(
            body: Center(child: Text("⚠️ Route not found")),
          ),
        );
    }
  }
}
