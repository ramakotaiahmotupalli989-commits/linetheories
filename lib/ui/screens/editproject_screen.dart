import 'package:flutter/material.dart';
import 'package:linetheories/models/project.dart';
import 'package:linetheories/ui/widgets/project_form.dart';

class EditProjectScreen extends StatelessWidget {
  final Project project;
  final void Function(Project) onSave;

  const EditProjectScreen({
    Key? key,
    required this.project,
    required this.onSave,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Edit Project")),
      body: ProjectForm(
        project: project,
        onSave: (updatedProject) {
          onSave(updatedProject);
          Navigator.pop(context, updatedProject);
        },
      ),
    );
  }
}
