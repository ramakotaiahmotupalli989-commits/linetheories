import 'package:flutter/material.dart';
import 'package:linetheories/core/utils/role_navigator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:linetheories/ui/screens/dashboards/dashboard_base.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // Role mapping for dummy login
  final Map<String, String> _userRoles = {
    "admin": "Admin",
    "designer": "Design Team",
    "site": "Site Incharge",
    "manager": "Project Manager",
  };

  void _login() async {
    String username = _usernameController.text.trim();
    String password = _passwordController.text.trim();

    if (_userRoles.containsKey(username) && password == "1234") {
      String role = _userRoles[username]!;

      // Save role to SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString("role", role);

      // Navigate to the correct dashboard
      Widget dashboard;
      switch (role) {
        case "Admin":
          dashboard = const AdminDashboard();
          break;
        case "Design Team":
          dashboard = const DesignTeamDashboard();
          break;
        case "Site Incharge":
          dashboard = const SiteInchargeDashboard();
          break;
        case "Project Manager":
          dashboard = const ProjectManagerDashboard();
          break;
        default:
          return;
      }

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => dashboard),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Invalid username or password")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Login")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _usernameController,
              decoration: const InputDecoration(labelText: "Username"),
            ),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: const InputDecoration(labelText: "Password"),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _login,
              child: const Text("Login"),
            ),
          ],
        ),
      ),
    );
  }
}
