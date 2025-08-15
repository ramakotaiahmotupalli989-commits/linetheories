import 'package:flutter/material.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(color: Colors.black87),
            child: Text(
              'Line Theories',
              style: TextStyle(color: Colors.white, fontSize: 24),
            ),
          ),

          ExpansionTile(
            title: const Text('Level 1 - A'),
            children: [
              ListTile(title: const Text('Level 2 - A1')),
              ExpansionTile(
                title: const Text('Level 2 - A2'),
                children: [
                  ListTile(title: const Text('Level 3 - A2.1')),
                  ListTile(title: const Text('Level 3 - A2.2')),
                ],
              ),
            ],
          ),

          ExpansionTile(
            title: const Text('Level 1 - B'),
            children: [
              ListTile(title: const Text('Level 2 - B1')),
              ListTile(title: const Text('Level 2 - B2')),
            ],
          ),
        ],
      ),
    );
  }
}
