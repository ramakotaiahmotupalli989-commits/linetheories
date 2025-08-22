import 'package:flutter/material.dart';
import 'package:linetheories/models/project.dart';
import 'package:linetheories/ui/screens/editproject_screen.dart';
import 'dart:io';

class ProjectDetailsScreen extends StatefulWidget {
  final Project project;
  final void Function(Project)? onProjectUpdate; // Made nullable

  const ProjectDetailsScreen({
    Key? key,
    required this.project,
    this.onProjectUpdate, // Changed to optional
  }) : super(key: key);

  @override
  State<ProjectDetailsScreen> createState() => _ProjectDetailsScreenState();
}

class _ProjectDetailsScreenState extends State<ProjectDetailsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Project Details"),
        actions: [
          if (widget.onProjectUpdate != null) // Show edit button only if editable
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: _editProject,
            ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            Text("Customer: ${widget.project.customerName}"),
            Text("Phone: ${widget.project.phoneNumber}"),
            Text("Email: ${widget.project.email}"),
            Text("Address: ${widget.project.address}"),
            Text("GPS Location: ${widget.project.gpsLocation}"),
            Text("Size: ${widget.project.size}"),
            Text("Remarks: ${widget.project.remarks}"),
            Text("Stage: ${widget.project.stage}"),
            if (widget.project.attachmentPath != null)
              ListTile(
                title: const Text("Attachment"),
                subtitle: Text(widget.project.attachmentPath!.split('/').last),
                trailing: _buildAttachmentIcon(),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildAttachmentIcon() {
    try {
      final file = File(widget.project.attachmentPath!);
      if (file.existsSync()) {
        final extension = widget.project.attachmentPath!.toLowerCase().split('.').last;
        if (['jpg', 'jpeg', 'png'].contains(extension)) {
          return const Icon(Icons.image);
        } else if (extension == 'pdf') {
          return const Icon(Icons.picture_as_pdf);
        }
      }
    } catch (e) {
      debugPrint('Error loading attachment icon: $e');
    }
    return const Icon(Icons.attach_file);
  }

  Future<void> _editProject() async {
    if (widget.onProjectUpdate == null) return; // Prevent editing if null

    final updatedProject = await Navigator.push<Project>(
      context,
      MaterialPageRoute(
        builder: (_) => EditProjectScreen(
          project: widget.project,
          onSave: (edited) => Navigator.pop(context, edited),
        ),
      ),
    );

    if (updatedProject != null) {
      setState(() {
        widget.project.customerName = updatedProject.customerName;
        widget.project.phoneNumber = updatedProject.phoneNumber;
        widget.project.email = updatedProject.email;
        widget.project.address = updatedProject.address;
        widget.project.gpsLocation = updatedProject.gpsLocation;
        widget.project.size = updatedProject.size;
        widget.project.remarks = updatedProject.remarks;
        widget.project.stage = updatedProject.stage;
        widget.project.attachmentPath = updatedProject.attachmentPath;
      });
      widget.onProjectUpdate!(updatedProject); // Safe to call since checked for null
    }
  }
}