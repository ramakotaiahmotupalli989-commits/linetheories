import 'package:flutter/material.dart';
import 'package:linetheories/models/project.dart';
import 'package:linetheories/ui/screens/add_project_screen.dart';
import 'package:linetheories/ui/screens/project_details_screen.dart';

class ProjectListScreen extends StatefulWidget {
  const ProjectListScreen({Key? key}) : super(key: key);

  @override
  State<ProjectListScreen> createState() => _ProjectListScreenState();
}

class _ProjectListScreenState extends State<ProjectListScreen> {
  List<Project> projects = [];

  void _addProject(Project project) {
    setState(() {
      projects.add(project);
    });
  }

  void _updateProject(Project updated) {
    setState(() {
      final index = projects.indexWhere((p) => p.id == updated.id);
      if (index != -1) {
        projects[index] = updated;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Projects")),
      body: projects.isEmpty
          ? const Center(child: Text("No projects available"))
          : ListView.builder(
              itemCount: projects.length,
              itemBuilder: (context, index) {
                final project = projects[index];
                return ListTile(
                  title: Text(project.customerName.isNotEmpty ? project.customerName : 'Unnamed Project'),
                  subtitle: Text(project.stage.isNotEmpty ? project.stage : 'Unknown Stage'),
                  onTap: () {
                    try {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ProjectDetailsScreen(
                            project: project,
                            onProjectUpdate: _updateProject,
                          ),
                          settings: RouteSettings(name: '/projectDetails'),
                        ),
                      );
                    } catch (e, stackTrace) {
                      debugPrint('Error navigating to ProjectDetails: $e\n$stackTrace');
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error: $e')),
                      );
                    }
                  },
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          try {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => AddProjectScreen(onAdd: _addProject),
                settings: RouteSettings(name: '/addProject'),
              ),
            );
          } catch (e, stackTrace) {
            debugPrint('Error navigating to AddProject: $e\n$stackTrace');
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Error: $e')),
            );
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}