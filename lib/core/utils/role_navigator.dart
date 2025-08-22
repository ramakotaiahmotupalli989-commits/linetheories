import 'package:flutter/material.dart';
import 'package:linetheories/routes/app_routes.dart';

/// Define roles in a single place (avoids typos)
class UserRoles {
  static const String admin = "Admin";
  static const String designTeam = "Design Team";
  static const String siteIncharge = "Site Incharge";
  static const String projectManager = "Project Manager";
}

class RoleNavigator {
  // Role → Route mapping
  static final Map<String, String> _roleRoutes = {
    UserRoles.admin: AppRoutes.adminDashboard,
    UserRoles.designTeam: AppRoutes.designTeamDashboard,
    UserRoles.siteIncharge: AppRoutes.siteInchargeDashboard,
    UserRoles.projectManager: AppRoutes.projectManagerDashboard,
  };

  // Navigate based on role
  static void navigateToDashboard(BuildContext context, String role) {
    final route = _roleRoutes[role] ?? AppRoutes.login;

    if (!_roleRoutes.containsKey(role)) {
      debugPrint("⚠️ Unknown role: $role, redirecting to login");
    }

    Navigator.pushReplacementNamed(context, route);
  }
}
