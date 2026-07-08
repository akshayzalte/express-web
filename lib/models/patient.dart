class PatientModel {
  final String id;
  final String name;
  final int age;
  final String gender;
  final String bloodPressure;
  final bool hasAilment;
  final String ailmentDetails;
  final String doctorId;
  final String? dob;
  final String? clinicalHistory;

  PatientModel({
    required this.id,
    required this.name,
    required this.age,
    required this.gender,
    required this.bloodPressure,
    required this.hasAilment,
    required this.ailmentDetails,
    required this.doctorId,
    this.dob,
    this.clinicalHistory,
  });

  factory PatientModel.fromJson(Map<String, dynamic> json) {
    return PatientModel(
      id: json['id'] as String,
      name: json['name'] as String,
      age: json['age'] as int,
      gender: json['gender'] as String,
      bloodPressure: json['bloodPressure'] as String,
      hasAilment: json['hasAilment'] as bool? ?? false,
      ailmentDetails: json['ailmentDetails'] as String? ?? '',
      doctorId: json['doctorId'] as String,
      dob: json['dob'] as String?,
      clinicalHistory: json['clinicalHistory'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'age': age,
      'gender': gender,
      'bloodPressure': bloodPressure,
      'hasAilment': hasAilment,
      'ailmentDetails': ailmentDetails,
      'doctorId': doctorId,
      'dob': dob,
      'clinicalHistory': clinicalHistory,
    };
  }
}
