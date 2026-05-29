import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../services/auth_service.dart';
import '../services/database_service.dart';
import '../services/fcm_service.dart';
import '../services/pdf_service.dart';
import '../services/connectivity_service.dart';
import '../models/order.dart';
import '../models/bill.dart';

class DoctorController extends GetxController {
  final DatabaseService _db = Get.find<DatabaseService>();
  final AuthService _auth = Get.find<AuthService>();
  final FCMService _fcm = Get.find<FCMService>();

  // New Order Form state fields
  final formKey = GlobalKey<FormState>();
  final patientNameController = TextEditingController();
  final shadeController = TextEditingController();
  final notesController = TextEditingController();
  
  final selectedProduct = ''.obs;
  final selectedBranch = ''.obs;
  final selectedTeeth = <int>[].obs;
  final selectedTechnicianId = 'auto'.obs; // 'auto' or technician user ID
  
  final returnForCoping = false.obs;
  final returnForBisque = false.obs;
  final callMe = false.obs;

  final selectedPhotoPath = ''.obs;
  final selectedDueDate = Rx<DateTime>(DateTime.now().add(const Duration(days: 7)));

  final isSubmitting = false.obs;

  @override
  void onInit() {
    super.onInit();
    // Default form dropdowns
    if (_db.products.isNotEmpty) {
      selectedProduct.value = _db.products.first.name;
    }
    if (_db.branches.isNotEmpty) {
      selectedBranch.value = _db.branches.first.name;
    }
  }

  // Tooth selection helper
  void toggleTooth(int number) {
    if (selectedTeeth.contains(number)) {
      selectedTeeth.remove(number);
    } else {
      selectedTeeth.add(number);
    }
  }

  // Photo Upload helper
  Future<void> pickPhoto() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        selectedPhotoPath.value = image.path;
        Get.snackbar('Photo Selected', 'Image successfully attached to order.');
      }
    } catch (e) {
      Get.snackbar('Picker Error', 'Unable to open gallery: $e');
    }
  }

  // Form Submit
  Future<void> submitOrder() async {
    final connectivity = Get.find<ConnectivityService>();
    if (!connectivity.isConnected.value) {
      Get.snackbar(
        'Offline Mode',
        'Cannot submit prescription. An active internet connection is required.',
        backgroundColor: Colors.redAccent.withOpacity(0.9),
        colorText: Colors.white,
      );
      return;
    }

    if (!formKey.currentState!.validate()) return;
    if (selectedTeeth.isEmpty) {
      Get.snackbar('Validation Error', 'Please select at least one tooth for the restoration.');
      return;
    }

    isSubmitting.value = true;

    // Simulate short loader
    await Future.delayed(const Duration(milliseconds: 800));

    final doctor = _auth.currentUser.value;
    final orderId = 'ORD-${9800 + _db.orders.length + 1}';

    String status = 'Pending';
    String? techId;
    String? techName;
    
    if (selectedTechnicianId.value.isNotEmpty && selectedTechnicianId.value != 'auto') {
      final tech = _db.users.firstWhereOrNull((u) => u.id == selectedTechnicianId.value);
      if (tech != null) {
        status = 'Lab Received';
        techId = tech.id;
        techName = tech.name;
      }
    }

    final newOrder = OrderModel(
      id: orderId,
      patientName: patientNameController.text.trim(),
      toothNumbers: List<int>.from(selectedTeeth),
      product: selectedProduct.value,
      shade: shadeController.text.trim().isEmpty ? 'A2' : shadeController.text.trim(),
      coping: returnForCoping.value,
      bakeToggle: returnForBisque.value,
      photoUrl: selectedPhotoPath.value.isEmpty ? null : selectedPhotoPath.value,
      branch: selectedBranch.value,
      callMeToggle: callMe.value,
      notes: notesController.text.trim().isEmpty ? null : notesController.text.trim(),
      status: status,
      technicianId: techId,
      technicianName: techName,
      doctorId: doctor?.id ?? 'doc_1',
      doctorName: doctor?.name ?? 'Dr. Jane Smith',
      dateCreated: DateTime.now(),
      dueDate: selectedDueDate.value,
    );

    // Save order
    _db.saveOrder(newOrder);

    // Add Doctor Notification
    _db.addNotification(
      doctor?.id ?? 'doc_1',
      'Order Submitted Successfully',
      techId != null 
          ? 'Case $orderId is assigned directly to $techName and is now in progress.'
          : 'Case $orderId for ${newOrder.patientName} is now pending lab receipt.',
    );

    // Add Tech Notification if assigned
    if (techId != null) {
      _db.addNotification(
        techId,
        'New Case Assigned directly by Doctor',
        'Dr. ${doctor?.name ?? 'Jane Smith'} assigned Case $orderId for patient ${newOrder.patientName} directly to you.',
      );
    }

    // Simulate Push FCM message
    _fcm.simulatePushNotification(
      'Cloud Dental Express',
      'New Order $orderId has been placed successfully.',
    );

    isSubmitting.value = false;
    clearForm();

    Get.snackbar(
      'Success',
      'Prescription order submitted successfully!',
      backgroundColor: const Color(0xFF1D9E75),
      colorText: Colors.white,
    );

    // Go back to dashboard
    Get.back();
  }

  void clearForm() {
    patientNameController.clear();
    shadeController.clear();
    notesController.clear();
    selectedTeeth.clear();
    selectedTechnicianId.value = 'auto';
    returnForCoping.value = false;
    returnForBisque.value = false;
    callMe.value = false;
    selectedPhotoPath.value = '';
    selectedDueDate.value = DateTime.now().add(const Duration(days: 7));
  }


  // Generate Invoices from Order Completed
  void downloadInvoice(BillModel bill) {
    PDFService.printInvoice(bill);
  }

  void shareInvoiceWhatsApp(BillModel bill) {
    PDFService.shareInvoice(bill);
  }
}
