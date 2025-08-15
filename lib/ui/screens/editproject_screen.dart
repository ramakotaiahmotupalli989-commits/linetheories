import 'package:flutter/material.dart';

class EditProjectScreen extends StatefulWidget {
  final Map<String, dynamic> project;
  final Function(Map<String, dynamic>) onSave;

  const EditProjectScreen({
    Key? key,
    required this.project,
    required this.onSave,
  }) : super(key: key);

  @override
  _EditProjectScreenState createState() => _EditProjectScreenState();
}

class _EditProjectScreenState extends State<EditProjectScreen> {
  late TextEditingController _customerNameController;
  late TextEditingController _phoneNumberController;

  @override
  void initState() {
    super.initState();
    _customerNameController =
        TextEditingController(text: widget.project['customer_name']);
    _phoneNumberController =
        TextEditingController(text: widget.project['phone_number']);
  }

  @override
  void dispose() {
    _customerNameController.dispose();
    _phoneNumberController.dispose();
    super.dispose();
  }

  void _saveChanges() {
    final updatedProject = {
      ...widget.project, // keep all old keys
      'customer_name': _customerNameController.text,
      'phone_number': _phoneNumberController.text,
    };
    widget.onSave(updatedProject);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Edit Project")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _customerNameController,
              decoration: const InputDecoration(labelText: "Customer Name"),
            ),
            TextField(
              controller: _phoneNumberController,
              decoration: const InputDecoration(labelText: "Phone Number"),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _saveChanges,
              child: const Text("Save"),
            ),
          ],
        ),
      ),
    );
  }
}
