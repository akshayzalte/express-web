import 'package:get/get.dart';
import '../models/user.dart';
import 'database_service.dart';

class AuthService extends GetxService {
  final DatabaseService _db = Get.find<DatabaseService>();

  final currentUser = Rxn<UserModel>();

  bool get isLoggedIn => currentUser.value != null;
  String get activeRole => currentUser.value?.role ?? '';

  @override
  void onInit() {
    super.onInit();
    // Default to guest/logged-out state.
    // In demo mode, we can auto-login a Doctor so the app starts fully populated,
    // or let the user choose their role on the login screen. We will let them choose,
    // but default to Doctor doc_1.
    autoLogin('doctor');
  }

  void autoLogin(String role) {
    final defaultUser = _db.users.firstWhereOrNull((u) => u.role == role);
    if (defaultUser != null) {
      currentUser.value = defaultUser;
    }
  }

  bool login(String email, String password) {
    // Simple mock auth matching seeded email addresses
    final user = _db.users.firstWhereOrNull(
      (u) => u.email.toLowerCase() == email.trim().toLowerCase(),
    );
    if (user != null) {
      final expectedPassword = user.password ?? 'password';
      if (password == expectedPassword) {
        currentUser.value = user;
        return true;
      }
    }
    return false;
  }

  void registerDoctor({
    required String name,
    required String clinicName,
    required String address,
    required double latitude,
    required double longitude,
    String? password,
    String? profilePhotoUrl,
  }) {
    final newDoc = UserModel(
      id: 'doc_${DateTime.now().millisecondsSinceEpoch}',
      email: '${name.toLowerCase().replaceAll(' ', '')}@dental.com',
      name: name,
      role: 'doctor',
      password: password ?? 'password',
      clinicName: clinicName,
      address: address,
      latitude: latitude,
      longitude: longitude,
      profilePhotoUrl: profilePhotoUrl,
      isApproved: false,
    );

    // Save user to DB and log them in
    _db.users.add(newDoc);
    currentUser.value = newDoc;
  }


  void logout() {
    currentUser.value = null;
  }

  void updateProfilePhoto(String url) {
    if (currentUser.value != null) {
      final updated = currentUser.value!.copyWith(profilePhotoUrl: url);
      currentUser.value = updated;
      
      // Update in db users list
      final idx = _db.users.indexWhere((u) => u.id == updated.id);
      if (idx >= 0) {
        _db.users[idx] = updated;
      }
    }
  }
}
