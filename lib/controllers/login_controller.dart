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
  final regEmailController = TextEditingController();
  final phoneController = TextEditingController();
  
  final isRegisterMode = false.obs;

  // Selected clinic location coordinates
  final latitude = 40.7128.obs;
  final longitude = (-74.0060).obs;
  final locationSet = false.obs;

  void toggleMode() {
    isRegisterMode.value = !isRegisterMode.value;
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
          email: regEmailController.text.trim(),
          mobileNumber: phoneController.text.trim(),
          clinicName: clinicController.text.trim(),
          address: addressController.text.trim(),
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
          'Invalid email address or password. Try doctor@dental.com, clouddentalexpress@gmail.com, or alex@dental.com',
          backgroundColor: Colors.red.withOpacity(0.8),
          colorText: Colors.white,
        );
      }
    }
  }

  // Pre-fill email based on role selection for easy demo testing
  void fillDemoCredentials(String role) {
    if (role == 'doctor') {
      emailController.text = 'doctor@dental.com';
    } else if (role == 'admin') {
      emailController.text = 'clouddentalexpress@gmail.com';
    } else if (role == 'technician') {
      emailController.text = 'alex@dental.com';
    }
    passwordController.text = 'password';
  }

  @override
  void onInit() {
    super.onInit();
    latitude.value = 19.0760;
    longitude.value = 72.8777;
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    nameController.dispose();
    clinicController.dispose();
    addressController.dispose();
    regEmailController.dispose();
    phoneController.dispose();
    super.dispose();
  }

}
