import 'package:flutter/material.dart';
import '../../routes/app_routes.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: Colors.lightBlueAccent),
              child: Text(
                'Menu',
                style: TextStyle(color: Colors.white, fontSize: 24),
              ),
            ),
            const ListTile(title: Text('Level 1')),

            // Level 2
            ExpansionTile(
              title: const Text('Level 2'),
              children: [
                ExpansionTile(
                  title: const Text('Sub-level A'),
                  children: const [
                    ListTile(title: Text('A1')),
                    ListTile(title: Text('A2')),
                  ],
                ),
                ExpansionTile(
                  title: const Text('Sub-level Y'),
                  children: const [
                    ListTile(title: Text('Y1')),
                    ListTile(title: Text('Y2')),
                  ],
                ),
              ],
            ),

            // Level 3
            ExpansionTile(
              title: const Text('Level 3'),
              children: [
                ExpansionTile(
                  title: const Text('Sub-level A'),
                  children: const [
                    ListTile(title: Text('A3')),
                    ListTile(title: Text('A4')),
                  ],
                ),
                ExpansionTile(
                  title: const Text('Sub-level Y'),
                  children: const [
                    ListTile(title: Text('Y3')),
                    ListTile(title: Text('Y4')),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
      appBar: AppBar(
        backgroundColor: Colors.lightBlueAccent,
        title: const Text('Home'),
        centerTitle: true,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () {
              Scaffold.of(context).openDrawer();
            },
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              Navigator.pushNamed(context, AppRoutes.profile);
            },
          ),
        ],
      ),
      body: const Center(
        child: Text(
          'Welcome to Home Screen!',
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
