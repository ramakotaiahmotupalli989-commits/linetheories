import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';

class AddProjectScreen extends StatefulWidget {
  const AddProjectScreen({Key? key}) : super(key: key);

  @override
  State<AddProjectScreen> createState() => _AddProjectScreenState();
}

class _AddProjectScreenState extends State<AddProjectScreen> {
  final _formKey = GlobalKey<FormState>();
  final Map<String, dynamic> _formData = {};

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles();
    if (result != null) {
      setState(() {
        _formData['attachment'] = result.files.single.name;
      });
    }
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      _formData['id'] = DateTime.now().millisecondsSinceEpoch;
      Navigator.pop(context, _formData);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Add New Project")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              _buildTextField("Customer Name", "customer_name"),
              _buildTextField("Phone Number", "phone_number"),
              _buildTextField("Email", "email"),
              _buildTextField("Address", "address"),
              _buildTextField("GPS", "gps"),
              _buildTextField("Size of Project", "size_of_project"),
              _buildTextField("Remarks", "remarks"),
              const SizedBox(height: 10),
              ElevatedButton.icon(
                onPressed: _pickFile,
                icon: const Icon(Icons.attach_file),
                label: Text(_formData['attachment'] ?? "Attach File"),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submit,
                child: const Text("Save"),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, String key) {
    return TextFormField(
      decoration: InputDecoration(labelText: label),
      onSaved: (val) => _formData[key] = val,
      validator: (val) => val == null || val.isEmpty ? "Required" : null,
    );
  }
}
