import 'package:flutter/material.dart';
import 'dart:async';
import 'package:linetheories/routes/app_routes.dart'; // import your AppRoutes

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _logoController;
  late Animation<Offset> _logoOffsetAnimation;

  late AnimationController _nameController;
  late Animation<Offset> _nameOffsetAnimation;

  @override
  void initState() {
    super.initState();

    // Logo animation (from top)
    _logoController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1200));
    _logoOffsetAnimation =
        Tween<Offset>(begin: const Offset(0, -2), end: Offset.zero).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.easeOutBack),
    );

    // Name animation (from left)
    _nameController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1200));
    _nameOffsetAnimation =
        Tween<Offset>(begin: const Offset(-2, 0), end: Offset.zero).animate(
      CurvedAnimation(parent: _nameController, curve: Curves.easeOutBack),
    );

    // Start animations
    _logoController.forward();
    _nameController.forward();

    // Navigate after delay
    Timer(const Duration(seconds: 3), () {
      _navigateNext();
    });
  }

  void _navigateNext() {
    bool isLoggedIn = false; // Replace with actual auth check logic

    if (isLoggedIn) {
      Navigator.pushReplacementNamed(context, AppRoutes.adminDashboard);
    } else {
      Navigator.pushReplacementNamed(context, AppRoutes.login);
    }
  }

  @override
  void dispose() {
    _logoController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE6F3FA), // light sky blue
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SlideTransition(
              position: _logoOffsetAnimation,
              child: Image.asset(
                "assets/images/logo.png",
                height: 120,
              ),
            ),
            const SizedBox(height: 20),
            SlideTransition(
              position: _nameOffsetAnimation,
              child: Image.asset(
                "assets/images/company_name.png",
                height: 50,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
