class UserModel {
  final String id;
  final String email;
  final String name;
  final String role; // 'doctor', 'admin', 'technician'
  final String? password;
  final String? clinicName;
  final String? address;
  final double? latitude;
  final double? longitude;
  final String? profilePhotoUrl;
  final bool isApproved;
  final String? mobileNumber;
  final bool mustChangePassword;

  UserModel({
    required this.id,
    required this.email,
    required this.name,
    required this.role,
    this.password,
    this.clinicName,
    this.address,
    this.latitude,
    this.longitude,
    this.profilePhotoUrl,
    this.isApproved = true,
    this.mobileNumber,
    this.mustChangePassword = false,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      email: json['email'] as String,
      name: json['name'] as String,
      role: json['role'] as String,
      password: json['password'] as String?,
      clinicName: json['clinicName'] as String?,
      address: json['address'] as String?,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      profilePhotoUrl: json['profilePhotoUrl'] as String?,
      isApproved: json['isApproved'] as bool? ?? true,
      mobileNumber: json['mobileNumber'] as String?,
      mustChangePassword: json['mustChangePassword'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'role': role,
      'password': password,
      'clinicName': clinicName,
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
      'profilePhotoUrl': profilePhotoUrl,
      'isApproved': isApproved,
      'mobileNumber': mobileNumber,
      'mustChangePassword': mustChangePassword,
    };
  }

  UserModel copyWith({
    String? name,
    String? password,
    String? clinicName,
    String? address,
    double? latitude,
    double? longitude,
    String? profilePhotoUrl,
    bool? isApproved,
    String? mobileNumber,
    bool? mustChangePassword,
  }) {
    return UserModel(
      id: id,
      email: email,
      name: name ?? this.name,
      role: role,
      password: password ?? this.password,
      clinicName: clinicName ?? this.clinicName,
      address: address ?? this.address,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      profilePhotoUrl: profilePhotoUrl ?? this.profilePhotoUrl,
      isApproved: isApproved ?? this.isApproved,
      mobileNumber: mobileNumber ?? this.mobileNumber,
      mustChangePassword: mustChangePassword ?? this.mustChangePassword,
    );
  }
}

