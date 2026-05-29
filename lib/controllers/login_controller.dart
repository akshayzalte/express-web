import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../services/auth_service.dart';
import '../services/connectivity_service.dart';

class LoginController extends GetxController {
  final AuthService _auth = Get.find<AuthService>();

  final formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  // Registration fields (Doctor specific)
  final nameController = TextEditingController();
  final clinicController = TextEditingController();
  final addressController = TextEditingController();
  
  final selectedRole = 'doctor'.obs; // 'doctor', 'admin', 'technician'
  final isRegisterMode = false.obs;

  // Selected clinic location coordinates
  final latitude = 40.7128.obs;
  final longitude = (-74.0060).obs;
  final locationSet = false.obs;

  void toggleMode() {
    isRegisterMode.value = !isRegisterMode.value;
  }

  void selectRole(String role) {
    selectedRole.value = role;
    if (role != 'doctor') {
      isRegisterMode.value = false;
    }
  }

  void setLocation(double lat, double lng) {
    latitude.value = lat;
    longitude.value = lng;
    locationSet.value = true;
  }

  void handleLogin() {
    final connectivity = Get.find<ConnectivityService>();
    if (!connectivity.isConnected.value) {
      Get.snackbar(
        'Offline Mode',
        'Authentication requires an active internet connection. Please verify your connection.',
        backgroundColor: Colors.redAccent.withOpacity(0.9),
        colorText: Colors.white,
      );
      return;
    }

    if (isRegisterMode.value) {
      if (formKey.currentState!.validate()) {
        _auth.registerDoctor(
          name: nameController.text.trim(),
          clinicName: clinicController.text.trim(),
          address: addressController.text.trim(),
          latitude: latitude.value,
          longitude: longitude.value,
        );
        Get.offAllNamed('/dashboard');
      }
    } else {
      if (emailController.text.isEmpty) {
        Get.snackbar('Error', 'Please enter email');
        return;
      }
      
      // Auto fill passwords or check
      final success = _auth.login(
        emailController.text,
        passwordController.text,
      );

      if (success) {
        Get.offAllNamed('/dashboard');
      } else {
        Get.snackbar(
          'Login Failed',
          'Invalid email address or role combination. Try doctor@dental.com, admin@dental.com, or alex@dental.com',
          backgroundColor: Colors.red.withOpacity(0.8),
          colorText: Colors.white,
        );
      }
    }
  }

  // Pre-fill email based on role selection for easy demo testing
  void fillDemoCredentials() {
    if (selectedRole.value == 'doctor') {
      emailController.text = 'doctor@dental.com';
    } else if (selectedRole.value == 'admin') {
      emailController.text = 'admin@dental.com';
    } else if (selectedRole.value == 'technician') {
      emailController.text = 'alex@dental.com';
    }
    passwordController.text = 'password';
  }

  @override
  void onInit() {
    super.onInit();
    latitude.value = 19.0760;
    longitude.value = 72.8777;

    addressController.addListener(() {
      final addr = addressController.text.trim();
      if (addr.isNotEmpty) {
        final coords = _simulateGeocode(addr);
        latitude.value = coords['lat']!;
        longitude.value = coords['lng']!;
        locationSet.value = true;
      }
    });
  }

  Map<String, double> _simulateGeocode(String address) {
    final addr = address.toLowerCase().trim();
    if (addr.isEmpty) {
      return {'lat': 19.0760, 'lng': 72.8777};
    }
    
    if (addr.contains(',')) {
      final parts = addr.split(',');
      if (parts.length == 2) {
        final lat = double.tryParse(parts[0].trim());
        final lng = double.tryParse(parts[1].trim());
        if (lat != null && lng != null) {
          return {'lat': lat, 'lng': lng};
        }
      }
    }
    
    if (addr.contains('mumbai') || addr.contains('bandra') || addr.contains('dadar') || addr.contains('andheri') || addr.contains('colaba') || addr.contains('chembur')) {
      double offset = (address.length % 5) * 0.003;
      return {'lat': 19.0760 + offset, 'lng': 72.8777 - offset};
    }
    if (addr.contains('pune') || addr.contains('kothrud') || addr.contains('hinjewadi') || addr.contains('hadapsar') || addr.contains('chinchwad')) {
      double offset = (address.length % 5) * 0.003;
      return {'lat': 18.5204 + offset, 'lng': 73.8567 - offset};
    }
    if (addr.contains('nagpur')) {
      return {'lat': 21.1458, 'lng': 79.0882};
    }
    if (addr.contains('nashik') || addr.contains('nasik')) {
      return {'lat': 19.9975, 'lng': 73.7898};
    }
    if (addr.contains('thane')) {
      return {'lat': 19.2183, 'lng': 72.9781};
    }
    
    final int hash = address.hashCode;
    final double latOffset = (hash % 100) / 2000.0;
    final double lngOffset = ((hash >> 2) % 100) / 2000.0;
    return {'lat': 19.0760 + latOffset, 'lng': 72.8777 + lngOffset};
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    nameController.dispose();
    clinicController.dispose();
    addressController.dispose();
    super.dispose();
  }

}
