class Project {
  String id;
  String customerName;
  String phoneNumber;
  String email;
  String address;
  String gpsLocation;
  String size;
  String remarks;
  String stage;
  String? attachmentPath;

  Project({
    required this.id,
    required this.customerName,
    required this.phoneNumber,
    required this.email,
    required this.address,
    required this.gpsLocation,
    required this.size,
    required this.remarks,
    this.stage = "Pitch Start",
    this.attachmentPath,
  });

  // Add fromJson factory constructor
  factory Project.fromJson(Map<String, dynamic> json) {
    return Project(
      id: json['id']?.toString() ?? DateTime.now().millisecondsSinceEpoch.toString(),
      customerName: json['customerName'] ?? '',
      phoneNumber: json['phoneNumber'] ?? '',
      email: json['email'] ?? '',
      address: json['address'] ?? '',
      gpsLocation: json['gpsLocation'] ?? '',
      size: json['size'] ?? '',
      remarks: json['remarks'] ?? '',
      stage: json['stage']?.toString() ?? 'Pitch Start',
      attachmentPath: json['attachmentPath'] as String?,
    );
  }
}