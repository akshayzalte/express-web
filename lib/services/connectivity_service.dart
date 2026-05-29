import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ConnectivityService extends GetxService {
  final isConnected = true.obs;
  Timer? _timer;

  @override
  void onInit() {
    super.onInit();
    // Run initial check
    checkConnection();
    // Schedule periodic checks every 5 seconds
    _timer = Timer.periodic(const Duration(seconds: 5), (_) => checkConnection());
  }

  Future<void> checkConnection() async {
    if (kIsWeb) {
      // Web browser connection is managed by browser and always online for demo
      if (!isConnected.value) {
        isConnected.value = true;
      }
      return;
    }

    try {
      final result = await InternetAddress.lookup('google.com')
          .timeout(const Duration(seconds: 3));
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        if (!isConnected.value) {
          isConnected.value = true;
          Get.snackbar(
            'Back Online',
            'Internet connection restored successfully.',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: const Color(0xFF1D9E75).withOpacity(0.9),
            colorText: const Color(0xFFFFFFFF),
            duration: const Duration(seconds: 3),
          );
        }
      }
    } on TimeoutException catch (_) {
      if (isConnected.value) {
        isConnected.value = false;
        Get.snackbar(
          'Connection Timeout',
          'Internet connection is slow or timed out.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: const Color(0xFFD32F2F).withOpacity(0.9),
          colorText: const Color(0xFFFFFFFF),
          duration: const Duration(seconds: 4),
        );
      }
    } on SocketException catch (_) {
      if (isConnected.value) {
        isConnected.value = false;
        Get.snackbar(
          'Connection Offline',
          'Internet connection lost. Switched to offline mode.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: const Color(0xFFD32F2F).withOpacity(0.9),
          colorText: const Color(0xFFFFFFFF),
          duration: const Duration(seconds: 4),
        );
      }
    } catch (_) {
      if (isConnected.value) {
        isConnected.value = false;
      }
    }
  }

  @override
  void onClose() {
    _timer?.cancel();
    super.onClose();
  }
}
