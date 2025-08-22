import 'package:flutter/material.dart';
import 'package:linetheories/ui/screens/dashboards/dashboard_base.dart';
import 'package:linetheories/ui/widgets/bottom_nav_bar.dart';
import '../../../core/constants/app_colors.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  int _currentIndex = 1;

  void _onNavTap(int index) {
    if (index == _currentIndex) return;

    setState(() => _currentIndex = index);

    if (index == 0) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const AdminDashboard()),
      );
    }
  }

  void _logout() {
    // TODO: implement logout logic (clear token, navigate to login)
    Navigator.pushNamedAndRemoveUntil(context, '/login', (_) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: AppColors.headerColor,
        title: const Text("Profile"),
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const SizedBox(height: 20),
            // Profile Image
            CircleAvatar(
              radius: 60,
              backgroundImage: const AssetImage('assets/images/profile.jpg'),
              backgroundColor: Colors.grey[300],
            ),
            const SizedBox(height: 16),
            Text(
              "Admin Name",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.grey[900],
              ),
            ),
            Text(
              "admin@example.com",
              style: TextStyle(fontSize: 16, color: Colors.grey[700]),
            ),
            const SizedBox(height: 24),
            // Card with profile details
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 3,
              child: ListTile(
                leading: Icon(Icons.phone, color: AppColors.headerColor),
                title: const Text("Phone Number"),
                subtitle: const Text("+91 9876543210"),
              ),
            ),
            const SizedBox(height: 12),
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 3,
              child: ListTile(
                leading: Icon(Icons.location_on, color: AppColors.headerColor),
                title: const Text("Branch"),
                subtitle: const Text("Hyderabad Office"),
              ),
            ),
            const SizedBox(height: 40),
            // Logout Button
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              icon: const Icon(Icons.logout, color: Colors.white),
              label: const Text(
                "Logout",
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
              onPressed: _logout,
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: _currentIndex,
        onTap: _onNavTap,
      ),
    );
  }
}
