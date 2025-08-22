import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'package:linetheories/models/project.dart';
import 'package:linetheories/ui/screens/add_project_screen.dart';
import 'package:linetheories/ui/screens/project_details_screen.dart';

/// ================== BASE DASHBOARD ==================
abstract class DashboardBase extends StatefulWidget {
  final String role;
  const DashboardBase({Key? key, required this.role}) : super(key: key);
}

abstract class DashboardBaseState<T extends DashboardBase> extends State<T> {
  late int _selectedMainTab; // 0: Pitch, 1: DIP, 2: WIP, 3: Handedover
  final Color headerColor = Colors.black;

  // Project stage lists (in-memory)
  List<Map<String, dynamic>> pitchStart = [];
  List<Map<String, dynamic>> pitchInProgress = [];
  List<Map<String, dynamic>> dipStart = [];
  List<Map<String, dynamic>> dipInProgress = [];
  List<Map<String, dynamic>> wipStart = [];
  List<Map<String, dynamic>> wipInProgress = [];
  List<Map<String, dynamic>> handedover = [];

  @override
  void initState() {
    super.initState();
    switch (widget.role) {
      case "Admin":
        _selectedMainTab = 0; // Pitch
        break;
      case "Design Team":
        _selectedMainTab = 1; // DIP
        break;
      case "Site Incharge":
      case "Project Manager":
        _selectedMainTab = 2; // WIP
        break;
      default:
        _selectedMainTab = 0;
    }
  }

  /// -------- Project <-> Map bridges --------
  Map<String, dynamic> _projectToMap(Project p, {Map<String, dynamic>? preserveExtras}) {
    final m = <String, dynamic>{
      'id': p.id,
      'customerName': p.customerName,
      'phoneNumber': p.phoneNumber,
      'email': p.email,
      'address': p.address,
      'gpsLocation': p.gpsLocation,
      'size': p.size,
      'remarks': p.remarks,
      'stage': p.stage,
      'attachmentPath': p.attachmentPath,
    };

    // Seed/keep extras required by workflow
    m['pitchFiles'] = preserveExtras?['pitchFiles'] ?? [
      {'name': 'Floor Plan', 'uploaded': false, 'path': null},
      {'name': 'Mood Board', 'uploaded': false, 'path': null},
      {'name': 'Quote', 'uploaded': false, 'path': null},
    ];
    m['dipFiles'] = preserveExtras?['dipFiles'] ?? [
      {'name': 'Working Drawings', 'uploaded': false, 'path': null},
      {'name': 'Renders', 'uploaded': false, 'path': null},
      {'name': 'Quote', 'uploaded': false, 'path': null},
    ];
    m['uploadedImages'] = List<String>.from(preserveExtras?['uploadedImages'] ?? []);
    m['dipConfirmed'] = preserveExtras?['dipConfirmed'] ?? false;
    m['readyForPM'] = preserveExtras?['readyForPM'] ?? false;

    return m;
  }

  Project _mapToProject(Map<String, dynamic> m) {
    String str(dynamic v) => (v ?? '').toString();

    return Project(
      id: str(m['id'].toString().isNotEmpty ? m['id'] : DateTime.now().millisecondsSinceEpoch),
      customerName: str(m['customerName'] ?? m['customer_name']),
      phoneNumber: str(m['phoneNumber'] ?? m['phone_number']),
      email: str(m['email']),
      address: str(m['address']),
      gpsLocation: str(m['gpsLocation'] ?? m['gps_location']),
      size: str(m['size']),
      remarks: str(m['remarks']),
      stage: str(m['stage'].toString().isNotEmpty ? m['stage'] : 'Pitch Start'),
      attachmentPath: (m['attachmentPath'] ?? m['attachment_path']) as String?,
    );
  }

  /// Add new project (Admin only)
  void _addProject(Project project) {
    setState(() {
      final proj = _projectToMap(project);
      proj['stage'] = 'Pitch Start';
      pitchStart.add(proj);
      debugPrint('Added project: ${proj['customerName']}, ID: ${proj['id']}');
    });
  }

  /// Update project and handle stage transitions
  void _updateProject(Map<String, dynamic> updatedProject) {
    final proj = Map<String, dynamic>.from(updatedProject);

    // Ensure required fields
    proj.putIfAbsent('pitchFiles', () => [
      {'name': 'Floor Plan', 'uploaded': false, 'path': null},
      {'name': 'Mood Board', 'uploaded': false, 'path': null},
      {'name': 'Quote', 'uploaded': false, 'path': null},
    ]);
    proj.putIfAbsent('dipFiles', () => [
      {'name': 'Working Drawings', 'uploaded': false, 'path': null},
      {'name': 'Renders', 'uploaded': false, 'path': null},
      {'name': 'Quote', 'uploaded': false, 'path': null},
    ]);
    proj.putIfAbsent('uploadedImages', () => []);
    proj.putIfAbsent('dipConfirmed', () => false);
    proj.putIfAbsent('readyForPM', () => false);

    setState(() {
      // Remove from all lists
      pitchStart.removeWhere((p) => p['id'] == proj['id']);
      pitchInProgress.removeWhere((p) => p['id'] == proj['id']);
      dipStart.removeWhere((p) => p['id'] == proj['id']);
      dipInProgress.removeWhere((p) => p['id'] == proj['id']);
      wipStart.removeWhere((p) => p['id'] == proj['id']);
      wipInProgress.removeWhere((p) => p['id'] == proj['id']);
      handedover.removeWhere((p) => p['id'] == proj['id']);

      switch (proj['stage']) {
        case 'Pitch Start':
          pitchStart.add(proj);
          break;
        case 'Pitch In Progress':
          pitchInProgress.add(proj);
          break;
        case 'DIP Start':
          dipStart.add(proj);
          break;
        case 'DIP In Progress':
          dipInProgress.add(proj);
          break;
        case 'WIP Start':
          wipStart.add(proj);
          break;
        case 'WIP In Progress':
          wipInProgress.add(proj);
          break;
        case 'Handedover':
          handedover.add(proj);
          break;
      }
      debugPrint('Updated project: ${proj['customerName']}, Stage: ${proj['stage']}');
    });
  }

  /// Role-based permissions for stage actions
  bool _canActInStage(String stage) {
    if (widget.role == "Admin" && stage.startsWith("Pitch")) return true;
    if (widget.role == "Design Team" && (stage.startsWith("Pitch") || stage.startsWith("DIP"))) return true;
    if (widget.role == "Site Incharge" && stage.startsWith("WIP")) return true;
    if (widget.role == "Project Manager" && stage == "WIP In Progress") return true;
    return false;
  }

  /// Role-based stage options
  List<String> _stageOptions(String currentStage) {
    if (widget.role == "Admin" && currentStage == "Pitch Start") {
      return ["Pitch In Progress"];
    }
    if (widget.role == "Design Team" && currentStage == "Pitch In Progress") {
      return ["DIP Start"];
    }
    if (widget.role == "Design Team" && currentStage == "DIP In Progress") {
      return ["WIP Start"];
    }
    if (widget.role == "Project Manager" && currentStage == "WIP In Progress") {
      return ["Handedover"];
    }
    return [];
  }

  /// ==== UI ====
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F8),
      appBar: AppBar(
        backgroundColor: headerColor,
        title: Text(
          "Welcome, ${widget.role}",
          style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold),
        ),
        automaticallyImplyLeading: false,
      ),
      body: Column(
        children: [
          _buildMainTabs(),
          Expanded(child: _buildMainTabContent()),
        ],
      ),
      bottomNavigationBar: _buildBottomNav(),
      floatingActionButton: widget.role == "Admin" && _selectedMainTab == 0
          ? FloatingActionButton(
              backgroundColor: headerColor,
              child: const Icon(Icons.add),
              onPressed: () async {
                try {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => AddProjectScreen(
                        onAdd: (Project p) => _addProject(p),
                      ),
                      settings: const RouteSettings(name: '/addProject'),
                    ),
                  );
                } catch (e, stackTrace) {
                  debugPrint('Error navigating to AddProjectScreen: $e\n$stackTrace');
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error adding project: $e')),
                    );
                  }
                }
              },
            )
          : null,
    );
  }

  Widget _buildMainTabs() {
    final tabs = [
      "Pitch (${_totalCount(pitchStart, pitchInProgress)})",
      "DIP (${_totalCount(dipStart, dipInProgress)})",
      "WIP (${_totalCount(wipStart, wipInProgress)})",
      "Handedover (${handedover.length})"
    ];

    return Row(
      children: List.generate(tabs.length, (i) {
        final selected = _selectedMainTab == i;
        return Expanded(
          child: GestureDetector(
            onTap: () => setState(() => _selectedMainTab = i),
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 12.h),
              color: selected ? headerColor : Colors.grey.shade300,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (selected)
                    Container(
                      width: 8,
                      height: 8,
                      margin: const EdgeInsets.only(right: 6),
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                      ),
                    ),
                  Text(
                    tabs[i],
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: selected ? Colors.white : Colors.black,
                      fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ],
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
      margin: EdgeInsets.symmetric(vertical: 8.h),
      child: ExpansionTile(
        title: Text("$title (${projects.length})"),
        children: projects.isEmpty
            ? [const ListTile(title: Text("No projects in this stage"))]
            : projects.map<Widget>((raw) {
                var proj = Map<String, dynamic>.from(raw);

                // Normalize
                proj.putIfAbsent('pitchFiles', () => [
                      {'name': 'Floor Plan', 'uploaded': false, 'path': null},
                      {'name': 'Mood Board', 'uploaded': false, 'path': null},
                      {'name': 'Quote', 'uploaded': false, 'path': null},
                    ]);
                proj.putIfAbsent('dipFiles', () => [
                      {'name': 'Working Drawings', 'uploaded': false, 'path': null},
                      {'name': 'Renders', 'uploaded': false, 'path': null},
                      {'name': 'Quote', 'uploaded': false, 'path': null},
                    ]);
                proj.putIfAbsent('uploadedImages', () => []);
                proj.putIfAbsent('dipConfirmed', () => false);
                proj.putIfAbsent('readyForPM', () => false);

                List<String> uploadedImages = List<String>.from(proj['uploadedImages'] ?? []);
                bool allPitchFilesUploaded = (proj['pitchFiles'] as List).every((f) => f['uploaded'] == true);
                bool allDipFilesUploaded = (proj['dipFiles'] as List).every((f) => f['uploaded'] == true);
                bool confirmed = proj['dipConfirmed'] == true;

                final canAct = _canActInStage(title);

                Widget _stageActions() {
                  final options = _stageOptions(proj['stage']);
                  return options.isNotEmpty
                      ? PopupMenuButton<String>(
                          onSelected: (choice) {
                            setState(() {
                              proj['stage'] = choice;
                              _updateProject(proj);
                            });
                          },
                          itemBuilder: (_) => options
                              .map((s) => PopupMenuItem(
                                    value: s,
                                    child: Text("Move to $s"),
                                  ))
                              .toList(),
                        )
                      : const SizedBox.shrink();
                }

                Widget _pitchSection() {
                  if (!(widget.role == "Design Team" && title.startsWith("Pitch"))) {
                    return Column(
                      children: (proj['pitchFiles'] as List).map<Widget>((f) {
                        return ListTile(
                          dense: true,
                          leading: Icon(
                              f['uploaded'] ? Icons.check_circle : Icons.circle_outlined),
                          title: Text(f['name']?.toString() ?? 'Unknown File'),
                          subtitle: Text(f['uploaded'] ? "Uploaded" : "Pending"),
                        );
                      }).toList(),
                    );
                  }

                  return Column(
                    children: [
                      ...((proj['pitchFiles'] as List).map<Widget>((f) {
                        return ListTile(
                          title: Text(f['name']?.toString() ?? 'Unknown File'),
                          subtitle: Text(f['uploaded'] ? "Uploaded: ${f['path']?.split('/').last ?? 'N/A'}" : "Pending"),
                          trailing: IconButton(
                            icon: Icon(f['uploaded'] ? Icons.check_circle : Icons.upload_file),
                            onPressed: !canAct
                                ? null
                                : () async {
                                    try {
                                      final result = await FilePicker.platform.pickFiles(
                                        type: FileType.custom,
                                        allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf'],
                                      );
                                      if (result != null && result.files.single.path != null) {
                                        setState(() {
                                          f['uploaded'] = true;
                                          f['path'] = result.files.single.path;
                                          if ((proj['pitchFiles'] as List).any((f) => f['uploaded'])) {
                                            proj['stage'] = "Pitch In Progress";
                                          }
                                          _updateProject(proj);
                                        });
                                      }
                                    } catch (e, stackTrace) {
                                      debugPrint('Error uploading pitch file: $e\n$stackTrace');
                                      if (mounted) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(content: Text('Error uploading file: $e')),
                                        );
                                      }
                                    }
                                  },
                          ),
                        );
                      }).toList()),
                      if (allPitchFilesUploaded)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12.0),
                          child: ElevatedButton(
                            onPressed: !canAct
                                ? null
                                : () {
                                    setState(() {
                                      proj['dipConfirmed'] = true;
                                      proj['stage'] = "DIP Start";
                                      _updateProject(proj);
                                    });
                                  },
                            child: const Text("Confirm Pitch & Move to DIP Start"),
                          ),
                        ),
                    ],
                  );
                }

                Widget _dipSection() {
                  if (!(widget.role == "Design Team" && title.startsWith("DIP"))) {
                    return Column(
                      children: (proj['dipFiles'] as List).map<Widget>((f) {
                        return ListTile(
                          dense: true,
                          leading: Icon(
                              f['uploaded'] ? Icons.check_circle : Icons.circle_outlined),
                          title: Text(f['name']?.toString() ?? 'Unknown File'),
                          subtitle: Text(f['uploaded'] ? "Uploaded" : "Pending"),
                        );
                      }).toList(),
                    );
                  }

                  return Column(
                    children: [
                      ...((proj['pitchFiles'] as List).map<Widget>((f) {
                        return ListTile(
                          dense: true,
                          leading: const Icon(Icons.insert_drive_file),
                          title: Text(f['name']?.toString() ?? 'Unknown File'),
                          subtitle: Text("Uploaded: ${f['path']?.split('/').last ?? 'N/A'}"),
                        );
                      }).toList()),
                      const Divider(),
                      ...((proj['dipFiles'] as List).map<Widget>((f) {
                        return ListTile(
                          title: Text(f['name']?.toString() ?? 'Unknown File'),
                          subtitle: Text(f['uploaded'] ? "Uploaded: ${f['path']?.split('/').last ?? 'N/A'}" : "Pending"),
                          trailing: IconButton(
                            icon: Icon(f['uploaded'] ? Icons.check_circle : Icons.upload_file),
                            onPressed: !canAct
                                ? null
                                : () async {
                                    try {
                                      final result = await FilePicker.platform.pickFiles(
                                        type: FileType.custom,
                                        allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf'],
                                      );
                                      if (result != null && result.files.single.path != null) {
                                        setState(() {
                                          f['uploaded'] = true;
                                          f['path'] = result.files.single.path;
                                          if ((proj['dipFiles'] as List).any((f) => f['uploaded'])) {
                                            proj['stage'] = "DIP In Progress";
                                          }
                                          _updateProject(proj);
                                        });
                                      }
                                    } catch (e, stackTrace) {
                                      debugPrint('Error uploading DIP file: $e\n$stackTrace');
                                      if (mounted) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(content: Text('Error uploading file: $e')),
                                        );
                                      }
                                    }
                                  },
                          ),
                        );
                      }).toList()),
                      if (allDipFilesUploaded)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12.0),
                          child: Row(
                            children: [
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: !canAct
                                      ? null
                                      : () {
                                          setState(() {
                                            proj['dipConfirmed'] = !confirmed;
                                          });
                                        },
                                  child: Text(confirmed ? "Unconfirm DIP" : "Confirm DIP"),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: !(canAct && allDipFilesUploaded && confirmed)
                                      ? null
                                      : () {
                                          setState(() {
                                            proj['stage'] = "WIP Start";
                                            _updateProject(proj);
                                          });
                                        },
                                  child: const Text("Move to WIP Start"),
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  );
                }

                Widget _wipSection() {
                  if (widget.role == "Site Incharge" && title.startsWith("WIP")) {
                    return Column(
                      children: [
                        ...((proj['pitchFiles'] as List).map<Widget>((f) {
                          return ListTile(
                            dense: true,
                            leading: const Icon(Icons.insert_drive_file),
                            title: Text(f['name']?.toString() ?? 'Unknown File'),
                            subtitle: Text("Uploaded: ${f['path']?.split('/').last ?? 'N/A'}"),
                          );
                        }).toList()),
                        ...((proj['dipFiles'] as List).map<Widget>((f) {
                          return ListTile(
                            dense: true,
                            leading: const Icon(Icons.insert_drive_file),
                            title: Text(f['name']?.toString() ?? 'Unknown File'),
                            subtitle: Text("Uploaded: ${f['path']?.split('/').last ?? 'N/A'}"),
                          );
                        }).toList()),
                        const Divider(),
                        ListTile(
                          title: const Text("Upload Progress Image"),
                          trailing: IconButton(
                            icon: const Icon(Icons.upload_file),
                            onPressed: !canAct
                                ? null
                                : () async {
                                    try {
                                      final result = await FilePicker.platform.pickFiles(
                                        type: FileType.custom,
                                        allowedExtensions: ['jpg', 'jpeg', 'png'],
                                      );
                                      if (result != null && result.files.single.path != null) {
                                        setState(() {
                                          uploadedImages.add(result.files.single.path!);
                                          proj['uploadedImages'] = uploadedImages;
                                          if (uploadedImages.isNotEmpty) {
                                            proj['stage'] = "WIP In Progress";
                                          }
                                          _updateProject(proj);
                                        });
                                      }
                                    } catch (e, stackTrace) {
                                      debugPrint('Error uploading WIP image: $e\n$stackTrace');
                                      if (mounted) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(content: Text('Error uploading image: $e')),
                                        );
                                      }
                                    }
                                  },
                          ),
                        ),
                        if (uploadedImages.isNotEmpty)
                          const Padding(
                            padding: EdgeInsets.only(bottom: 8),
                            child: Text("Image(s) uploaded"),
                          ),
                        SwitchListTile(
                          title: const Text("Ready for PM review"),
                          value: proj['readyForPM'] == true,
                          onChanged: !canAct
                              ? null
                              : (v) {
                                  setState(() {
                                    proj['readyForPM'] = v;
                                    _updateProject(proj);
                                  });
                                },
                        ),
                      ],
                    );
                  }

                  if (widget.role == "Project Manager" && title == "WIP In Progress") {
                    final ready = proj['readyForPM'] == true;
                    return Column(
                      children: [
                        ...((proj['pitchFiles'] as List).map<Widget>((f) {
                          return ListTile(
                            dense: true,
                            leading: const Icon(Icons.insert_drive_file),
                            title: Text(f['name']?.toString() ?? 'Unknown File'),
                            subtitle: Text("Uploaded: ${f['path']?.split('/').last ?? 'N/A'}"),
                          );
                        }).toList()),
                        ...((proj['dipFiles'] as List).map<Widget>((f) {
                          return ListTile(
                            dense: true,
                            leading: const Icon(Icons.insert_drive_file),
                            title: Text(f['name']?.toString() ?? 'Unknown File'),
                            subtitle: Text("Uploaded: ${f['path']?.split('/').last ?? 'N/A'}"),
                          );
                        }).toList()),
                        if (uploadedImages.isNotEmpty)
                          const Padding(
                            padding: EdgeInsets.only(bottom: 8),
                            child: Text("Image(s) uploaded"),
                          ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12.0),
                          child: ElevatedButton.icon(
                            icon: const Icon(Icons.verified),
                            label: Text(
                                ready ? "Finalize to Handedover" : "Waiting for Site Incharge"),
                            onPressed: ready
                                ? () {
                                    setState(() {
                                      proj['stage'] = "Handedover";
                                      _updateProject(proj);
                                    });
                                  }
                                : null,
                          ),
                        ),
                      ],
                    );
                  }

                  return Column(
                    children: [
                      ...((proj['pitchFiles'] as List).map<Widget>((f) {
                        return ListTile(
                          dense: true,
                          leading: const Icon(Icons.insert_drive_file),
                          title: Text(f['name']?.toString() ?? 'Unknown File'),
                          subtitle: Text("Uploaded: ${f['path']?.split('/').last ?? 'N/A'}"),
                        );
                      }).toList()),
                      ...((proj['dipFiles'] as List).map<Widget>((f) {
                        return ListTile(
                          dense: true,
                          leading: const Icon(Icons.insert_drive_file),
                          title: Text(f['name']?.toString() ?? 'Unknown File'),
                          subtitle: Text("Uploaded: ${f['path']?.split('/').last ?? 'N/A'}"),
                        );
                      }).toList()),
                      if (uploadedImages.isNotEmpty)
                        const Padding(
                          padding: EdgeInsets.only(bottom: 8),
                          child: Text("Image(s) uploaded"),
                        ),
                      if (proj['readyForPM'] == true)
                        const Padding(
                          padding: EdgeInsets.only(bottom: 8),
                          child: Text("Ready for PM review"),
                        ),
                    ],
                  );
                }

                return Column(
                  children: [
                    ListTile(
                      title: Text(proj['customerName']?.toString() ?? 'Unnamed Project'),
                      subtitle: Text("ID: ${proj['id']?.toString() ?? 'N/A'} • ${proj['phoneNumber']?.toString() ?? 'N/A'}"),
                      trailing: _stageActions(),
                      onTap: () async {
                        try {
                          final extras = {
                            'pitchFiles': proj['pitchFiles'],
                            'dipFiles': proj['dipFiles'],
                            'uploadedImages': proj['uploadedImages'],
                            'dipConfirmed': proj['dipConfirmed'],
                            'readyForPM': proj['readyForPM'],
                          };

                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ProjectDetailsScreen(
                                project: _mapToProject(proj),
                                onProjectUpdate: widget.role == "Admin" && proj['stage'] != "Pitch Start" && proj['stage'] != "Pitch In Progress"
                                    ? null // Admin has read-only access outside Pitch
                                    : (Project u) {
                                        final updatedMap = _projectToMap(u, preserveExtras: extras);
                                        _updateProject(updatedMap);
                                      },
                              ),
                              settings: const RouteSettings(name: '/projectDetails'),
                            ),
                          );
                        } catch (e, stackTrace) {
                          debugPrint('Error navigating to ProjectDetails: $e\n$stackTrace');
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Error viewing project: $e')),
                            );
                          }
                        }
                      },
                    ),
                    if (title.startsWith("Pitch")) _pitchSection(),
                    if (title.startsWith("DIP")) _dipSection(),
                    if (title.startsWith("WIP")) _wipSection(),
                    const SizedBox(height: 8),
                  ],
                );
              }).toList(),
      ),
    );
  }

  Widget _buildHandedoverSection() {
    return ListView(
      padding: EdgeInsets.all(12.w),
      children: [
        Card(
          margin: EdgeInsets.symmetric(vertical: 8.h),
          child: ExpansionTile(
            title: Text("Handedover (${handedover.length})"),
            children: handedover.isEmpty
                ? [const ListTile(title: Text("No projects in this stage"))]
                : handedover.map<Widget>((proj) {
                    return ListTile(
                      title: Text(proj['customerName']?.toString() ?? 'Unnamed Project'),
                      subtitle: Text("ID: ${proj['id']?.toString() ?? 'N/A'} • ${proj['phoneNumber']?.toString() ?? 'N/A'}"),
                      onTap: () async {
                        try {
                          final extras = {
                            'pitchFiles': proj['pitchFiles'],
                            'dipFiles': proj['dipFiles'],
                            'uploadedImages': proj['uploadedImages'],
                            'dipConfirmed': proj['dipConfirmed'],
                            'readyForPM': proj['readyForPM'],
                          };

                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ProjectDetailsScreen(
                                project: _mapToProject(proj),
                                onProjectUpdate: widget.role == "Admin"
                                    ? null // Admin has read-only access
                                    : (Project u) {
                                        final updatedMap = _projectToMap(u, preserveExtras: extras);
                                        _updateProject(updatedMap);
                                      },
                              ),
                              settings: const RouteSettings(name: '/projectDetails'),
                            ),
                          );
                        } catch (e, stackTrace) {
                          debugPrint('Error navigating to ProjectDetails: $e\n$stackTrace');
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Error viewing project: $e')),
                            );
                          }
                        }
                      },
                    );
                  }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildBottomNav() {
    return BottomNavigationBar(
      currentIndex: 0,
      selectedItemColor: headerColor,
      onTap: (i) {
        if (i == 1) {
          try {
            Navigator.pushNamed(context, '/profile');
          } catch (e, stackTrace) {
            debugPrint('Error navigating to Profile: $e\n$stackTrace');
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Error navigating to profile: $e')),
              );
            }
          }
        }
      },
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
      ],
    );
  }
}

/// ================== SPECIFIC DASHBOARDS ==================
class AdminDashboard extends DashboardBase {
  const AdminDashboard({Key? key}) : super(key: key, role: "Admin");
  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}
class _AdminDashboardState extends DashboardBaseState<AdminDashboard> {}

class DesignTeamDashboard extends DashboardBase {
  const DesignTeamDashboard({Key? key}) : super(key: key, role: "Design Team");
  @override
  State<DesignTeamDashboard> createState() => _DesignTeamDashboardState();
}
class _DesignTeamDashboardState extends DashboardBaseState<DesignTeamDashboard> {}

class SiteInchargeDashboard extends DashboardBase {
  const SiteInchargeDashboard({Key? key}) : super(key: key, role: "Site Incharge");
  @override
  State<SiteInchargeDashboard> createState() => _SiteInchargeDashboardState();
}
class _SiteInchargeDashboardState extends DashboardBaseState<SiteInchargeDashboard> {}

class ProjectManagerDashboard extends DashboardBase {
  const ProjectManagerDashboard({Key? key}) : super(key: key, role: "Project Manager");
  @override
  State<ProjectManagerDashboard> createState() => _ProjectManagerDashboardState();
}
class _ProjectManagerDashboardState extends DashboardBaseState<ProjectManagerDashboard> {}