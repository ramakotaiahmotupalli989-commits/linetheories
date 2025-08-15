import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:linetheories/ui/screens/add_project_screen.dart';
import 'package:linetheories/ui/screens/project_details_screen.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({Key? key}) : super(key: key);

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  int _selectedMainTab = 0; // 0: Pitch, 1: DIP, 2: WIP, 3: Handedover
  final Color headerColor = Colors.teal.shade600;

  // Sample project data lists
  List<Map<String, dynamic>> pitchStart = [];
  List<Map<String, dynamic>> pitchInProgress = [];
  List<Map<String, dynamic>> dipStart = [];
  List<Map<String, dynamic>> dipInProgress = [];
  List<Map<String, dynamic>> wipStart = [];
  List<Map<String, dynamic>> wipInProgress = [];
  List<Map<String, dynamic>> handedover = [];

  void _addProject(Map<String, dynamic> newProject) {
    setState(() {
      newProject['stage'] = 'Pitch Start';
      pitchStart.add(newProject);
    });
  }

  void _updateProject(Map<String, dynamic> updatedProject) {
    setState(() {
      // Remove from all lists first
      pitchStart.removeWhere((p) => p['id'] == updatedProject['id']);
      pitchInProgress.removeWhere((p) => p['id'] == updatedProject['id']);
      dipStart.removeWhere((p) => p['id'] == updatedProject['id']);
      dipInProgress.removeWhere((p) => p['id'] == updatedProject['id']);
      wipStart.removeWhere((p) => p['id'] == updatedProject['id']);
      wipInProgress.removeWhere((p) => p['id'] == updatedProject['id']);
      handedover.removeWhere((p) => p['id'] == updatedProject['id']);

      // Add to the correct list based on stage
      switch (updatedProject['stage']) {
        case 'Pitch Start':
          pitchStart.add(updatedProject);
          break;
        case 'Pitch In Progress':
          pitchInProgress.add(updatedProject);
          break;
        case 'DIP Start':
          dipStart.add(updatedProject);
          break;
        case 'DIP In Progress':
          dipInProgress.add(updatedProject);
          break;
        case 'WIP Start':
          wipStart.add(updatedProject);
          break;
        case 'WIP In Progress':
          wipInProgress.add(updatedProject);
          break;
        case 'Handedover':
          handedover.add(updatedProject);
          break;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F8),
      appBar: AppBar(
        backgroundColor: headerColor,
        title: Text(
          "Welcome, Admin",
          style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold),
        ),
        automaticallyImplyLeading: false,
      ),
      body: Column(
        children: [
          _buildMainTabs(),
          Expanded(
            child: _buildMainTabContent(),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomNav(),
      floatingActionButton: _selectedMainTab == 0
          ? FloatingActionButton(
              backgroundColor: headerColor,
              child: const Icon(Icons.add),
              onPressed: () async {
                final newProject = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const AddProjectScreen(),
                  ),
                );
                if (newProject != null) {
                  _addProject(Map<String, dynamic>.from(newProject));
                }
              },
            )
          : null,
    );
  }

  Widget _buildMainTabs() {
    final List<String> tabs = [
      "Pitch (${_totalCount(pitchStart, pitchInProgress)})",
      "DIP (${_totalCount(dipStart, dipInProgress)})",
      "WIP (${_totalCount(wipStart, wipInProgress)})",
      "Handedover (${handedover.length})"
    ];

    return Row(
      children: List.generate(tabs.length, (index) {
        bool isSelected = _selectedMainTab == index;
        return Expanded(
          child: GestureDetector(
            onTap: () => setState(() => _selectedMainTab = index),
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 12.h),
              color: isSelected ? headerColor : Colors.grey.shade300,
              child: Text(
                tabs[index],
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.black87,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
          ),
        );
      }),
    );
  }

  int _totalCount(List a, List b) => a.length + b.length;

  Widget _buildMainTabContent() {
    switch (_selectedMainTab) {
      case 0:
        return _buildStageSection("Pitch", pitchStart, pitchInProgress);
      case 1:
        return _buildStageSection("DIP", dipStart, dipInProgress);
      case 2:
        return _buildStageSection("WIP", wipStart, wipInProgress);
      case 3:
        return _buildHandedoverSection();
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildStageSection(String section, List start, List progress) {
    return ListView(
      padding: EdgeInsets.all(12.w),
      children: [
        _buildSubStageCard("$section Start", start),
        _buildSubStageCard("$section In Progress", progress),
      ],
    );
  }

  Widget _buildSubStageCard(String title, List projects) {
    return Card(
      elevation: 3,
      margin: EdgeInsets.symmetric(vertical: 8.h),
      child: ExpansionTile(
        title: Text("$title (${projects.length})"),
        children: projects.map<Widget>((proj) {
          return ListTile(
            title: Text(proj['customer_name'] ?? ''),
            subtitle: Text("ID: ${proj['id']} • ${proj['phone_number']}"),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ProjectDetailsScreen(
                    project: Map<String, dynamic>.from(proj), // ✅ type fix
                    onProjectUpdate: (updated) =>
                        _updateProject(Map<String, dynamic>.from(updated)), // ✅ type fix
                  ),
                ),
              );
            },
          );
        }).toList(),
      ),
    );
  }

  Widget _buildHandedoverSection() {
    return ListView.builder(
      itemCount: handedover.length,
      itemBuilder: (_, index) {
        final proj = handedover[index];
        return Card(
          child: ListTile(
            title: Text("ID: ${proj['id']} • ${proj['customer_name']}"),
            subtitle: Text("Phone: ${proj['phone_number']}"),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ProjectDetailsScreen(
                    project: Map<String, dynamic>.from(proj), // ✅ type fix
                    onProjectUpdate: (updated) =>
                        _updateProject(Map<String, dynamic>.from(updated)), // ✅ type fix
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildBottomNav() {
    return BottomNavigationBar(
      currentIndex: 0,
      selectedItemColor: headerColor,
      onTap: (index) {
        if (index == 1) {
          Navigator.pushNamed(context, '/profile');
        }
      },
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
      ],
    );
  }
}
