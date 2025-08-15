import 'package:flutter/material.dart';
import '../../ui/screens/dashboards/admin_dashboard.dart';

class RoleNavigator {
  /// Navigates user to AdminDashboard (other roles removed)
  static void navigateToDashboard(BuildContext context, String role) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const AdminDashboard()),
    );
  }
}
