class OrderModel {
  final String id;
  final String patientName;
  final List<int> toothNumbers;
  final String product;
  final String shade;
  final bool coping;
  final bool bakeToggle;
  final String? photoUrl;
  final String branch;
  final bool callMeToggle;
  final String? notes;
  final String status; // 'Pending', 'Lab Received', 'In Progress', 'Quality Check', 'Delivered'
  final String? technicianId;
  final String? technicianName;
  final String doctorId;
  final String doctorName;
  final DateTime dateCreated;
  final DateTime dueDate;
  final String? labNotes;

  OrderModel({
    required this.id,
    required this.patientName,
    required this.toothNumbers,
    required this.product,
    required this.shade,
    required this.coping,
    required this.bakeToggle,
    this.photoUrl,
    required this.branch,
    required this.callMeToggle,
    this.notes,
    required this.status,
    this.technicianId,
    this.technicianName,
    required this.doctorId,
    required this.doctorName,
    required this.dateCreated,
    required this.dueDate,
    this.labNotes,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      id: json['id'] as String,
      patientName: json['patientName'] as String,
      toothNumbers: (json['toothNumbers'] as List).map((e) => e as int).toList(),
      product: json['product'] as String,
      shade: json['shade'] as String,
      coping: json['coping'] as bool,
      bakeToggle: json['bakeToggle'] as bool,
      photoUrl: json['photoUrl'] as String?,
      branch: json['branch'] as String,
      callMeToggle: json['callMeToggle'] as bool,
      notes: json['notes'] as String?,
      status: json['status'] as String,
      technicianId: json['technicianId'] as String?,
      technicianName: json['technicianName'] as String?,
      doctorId: json['doctorId'] as String,
      doctorName: json['doctorName'] as String,
      dateCreated: DateTime.parse(json['dateCreated'] as String),
      dueDate: DateTime.parse(json['dueDate'] as String),
      labNotes: json['labNotes'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'patientName': patientName,
      'toothNumbers': toothNumbers,
      'product': product,
      'shade': shade,
      'coping': coping,
      'bakeToggle': bakeToggle,
      'photoUrl': photoUrl,
      'branch': branch,
      'callMeToggle': callMeToggle,
      'notes': notes,
      'status': status,
      'technicianId': technicianId,
      'technicianName': technicianName,
      'doctorId': doctorId,
      'doctorName': doctorName,
      'dateCreated': dateCreated.toIso8601String(),
      'dueDate': dueDate.toIso8601String(),
      'labNotes': labNotes,
    };
  }

  OrderModel copyWith({
    String? status,
    String? technicianId,
    String? technicianName,
    String? labNotes,
  }) {
    return OrderModel(
      id: id,
      patientName: patientName,
      toothNumbers: toothNumbers,
      product: product,
      shade: shade,
      coping: coping,
      bakeToggle: bakeToggle,
      photoUrl: photoUrl,
      branch: branch,
      callMeToggle: callMeToggle,
      notes: notes,
      status: status ?? this.status,
      technicianId: technicianId ?? this.technicianId,
      technicianName: technicianName ?? this.technicianName,
      doctorId: doctorId,
      doctorName: doctorName,
      dateCreated: dateCreated,
      dueDate: dueDate,
      labNotes: labNotes ?? this.labNotes,
    );
  }
}
