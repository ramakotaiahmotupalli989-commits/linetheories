import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

class ProjectDetailsScreen extends StatefulWidget {
  final Map<String, dynamic> project;
  final Function(Map<String, dynamic>) onProjectUpdate;

  const ProjectDetailsScreen({
    Key? key,
    required this.project,
    required this.onProjectUpdate,
  }) : super(key: key);

  @override
  State<ProjectDetailsScreen> createState() => _ProjectDetailsScreenState();
}

class _ProjectDetailsScreenState extends State<ProjectDetailsScreen> {
  File? floorPlan;
  File? moodBoard;
  File? quote;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Project Details")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            Text(
              "Customer: ${widget.project['customer_name'] ?? ''}",
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),

            _buildFileUploadTile(
              title: "Upload Floor Plan",
              file: floorPlan,
              onPick: () => _pickFile("floorPlan"),
            ),
            _buildFileUploadTile(
              title: "Upload Mood Board",
              file: moodBoard,
              onPick: () => _pickFile("moodBoard"),
            ),
            _buildFileUploadTile(
              title: "Upload Quote",
              file: quote,
              onPick: () => _pickFile("quote"),
            ),

            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _onSaveConfirm,
              child: const Text("Save & Confirm"),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFileUploadTile({
    required String title,
    File? file,
    required VoidCallback onPick,
  }) {
    return Card(
      child: ListTile(
        title: Text(title),
        subtitle: file != null
            ? Text("Selected: ${file.path.split('/').last}")
            : const Text("No file selected"),
        trailing: IconButton(
          icon: const Icon(Icons.upload_file),
          onPressed: onPick,
        ),
      ),
    );
  }

  Future<void> _pickFile(String type) async {
    final result = await FilePicker.platform.pickFiles(
      allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
      type: FileType.custom,
    );

    if (result != null && result.files.single.path != null) {
      setState(() {
        final file = File(result.files.single.path!);
        if (type == "floorPlan") {
          floorPlan = file;
        } else if (type == "moodBoard") {
          moodBoard = file;
        } else if (type == "quote") {
          quote = file;
        }
      });

      _checkForFirstUpload();
    }
  }

  void _checkForFirstUpload() {
    final currentStage = widget.project['stage'];
    if (currentStage == 'Pitch Start' &&
        (floorPlan != null || moodBoard != null || quote != null)) {
      widget.project['stage'] = 'Pitch In Progress';
      widget.onProjectUpdate(widget.project);
    }
  }

  void _onSaveConfirm() {
    if (floorPlan != null && moodBoard != null && quote != null) {
      widget.project['stage'] = 'DIP Start';
      widget.onProjectUpdate(widget.project);
    }
    Navigator.pop(context, widget.project);
  }
}
