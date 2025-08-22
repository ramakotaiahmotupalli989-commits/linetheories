import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:linetheories/models/project.dart';

class ProjectForm extends StatefulWidget {
  final Project? project;
  final void Function(Project) onSave;

  const ProjectForm({Key? key, this.project, required this.onSave})
      : super(key: key);

  @override
  State<ProjectForm> createState() => _ProjectFormState();
}

class _ProjectFormState extends State<ProjectForm> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _customerName;
  late TextEditingController _phoneNumber;
  late TextEditingController _email;
  late TextEditingController _address;
  late TextEditingController _gpsLocation;
  late TextEditingController _size;
  late TextEditingController _remarks;
  File? attachment;

  @override
  void initState() {
    super.initState();
    _customerName = TextEditingController(text: widget.project?.customerName ?? "");
    _phoneNumber = TextEditingController(text: widget.project?.phoneNumber ?? "");
    _email = TextEditingController(text: widget.project?.email ?? "");
    _address = TextEditingController(text: widget.project?.address ?? "");
    _gpsLocation = TextEditingController(text: widget.project?.gpsLocation ?? "");
    _size = TextEditingController(text: widget.project?.size ?? "");
    _remarks = TextEditingController(text: widget.project?.remarks ?? "");
    if (widget.project?.attachmentPath != null) {
      try {
        final file = File(widget.project!.attachmentPath!);
        if (file.existsSync()) {
          attachment = file;
        }
      } catch (e) {
        debugPrint('Error loading attachment: $e');
      }
    }
  }

  @override
  void dispose() {
    _customerName.dispose();
    _phoneNumber.dispose();
    _email.dispose();
    _address.dispose();
    _gpsLocation.dispose();
    _size.dispose();
    _remarks.dispose();
    super.dispose();
  }

  Future<void> _pickFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf'], // Restrict file types
      );
      if (result != null && result.files.single.path != null) {
        final file = File(result.files.single.path!);
        if (file.existsSync()) {
          setState(() {
            attachment = file;
          });
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Selected file is invalid')),
          );
        }
      }
    } catch (e) {
      debugPrint('Error picking file: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error picking file')),
      );
    }
  }

  void _saveForm() {
    if (_formKey.currentState!.validate()) {
      final project = Project(
        id: widget.project?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
        customerName: _customerName.text,
        phoneNumber: _phoneNumber.text,
        email: _email.text,
        address: _address.text,
        gpsLocation: _gpsLocation.text,
        size: _size.text,
        remarks: _remarks.text,
        stage: widget.project?.stage ?? "Pitch Start",
        attachmentPath: attachment?.path,
      );
      try {
        widget.onSave(project);
      } catch (e, stackTrace) {
        debugPrint('Error saving project: $e\n$stackTrace');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving project: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          TextFormField(
            controller: _customerName,
            decoration: const InputDecoration(labelText: "Customer Name"),
            validator: (val) => val!.isEmpty ? "Customer Name is required" : null,
          ),
          TextFormField(
            controller: _phoneNumber,
            decoration: const InputDecoration(labelText: "Phone Number"),
            keyboardType: TextInputType.phone,
            validator: (val) => val!.isEmpty ? "Phone Number is required" : null,
          ),
          TextFormField(
            controller: _email,
            decoration: const InputDecoration(labelText: "Email"),
            keyboardType: TextInputType.emailAddress,
            validator: (val) {
              if (val!.isEmpty) return "Email is required";
              if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(val)) return "Invalid email format";
              return null;
            },
          ),
          TextFormField(
            controller: _address,
            decoration: const InputDecoration(labelText: "Address"),
            validator: (val) => val!.isEmpty ? "Address is required" : null,
          ),
          TextFormField(
            controller: _gpsLocation,
            decoration: const InputDecoration(labelText: "GPS Location"),
            validator: (val) => val!.isEmpty ? "GPS Location is required" : null,
          ),
          TextFormField(
            controller: _size,
            decoration: const InputDecoration(labelText: "Size of Project"),
            validator: (val) => val!.isEmpty ? "Project Size is required" : null,
          ),
          TextFormField(
            controller: _remarks,
            decoration: const InputDecoration(labelText: "Remarks"),
          ),
          const SizedBox(height: 10),
          ListTile(
            title: Text(attachment != null
                ? "Selected: ${attachment!.path.split('/').last}"
                : "No file selected"),
            trailing: IconButton(
              icon: const Icon(Icons.attach_file),
              onPressed: _pickFile,
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _saveForm,
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }
}