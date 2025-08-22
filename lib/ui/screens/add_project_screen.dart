import 'package:flutter/material.dart';
import 'package:linetheories/models/project.dart';
import 'package:linetheories/ui/widgets/project_form.dart';

class AddProjectScreen extends StatelessWidget {
  final void Function(Project) onAdd;

  const AddProjectScreen({Key? key, required this.onAdd}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Add Project")),
      body: ProjectForm(
        onSave: (project) {
          try {
            debugPrint('Saving project: ${project.customerName}, ${project.attachmentPath}');
            onAdd(project);
            debugPrint('Navigating back from AddProjectScreen');
            Navigator.pop(context);
          } catch (e, stackTrace) {
            debugPrint('Error in AddProjectScreen: $e\n$stackTrace');
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Error saving project: $e')),
            );
          }
        },
      ),
    );
  }
}