import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../services/database_service.dart';
import '../services/fcm_service.dart';
import '../models/order.dart';
import '../models/product.dart';
import '../models/branch.dart';
import '../models/user.dart';
import '../models/bill.dart';

class AdminController extends GetxController {
  final DatabaseService _db = Get.find<DatabaseService>();
  final FCMService _fcm = Get.find<FCMService>();

  // Filter for Order list screen
  final selectedFilter = 'All'.obs; // 'All', 'Pending', 'In Progress', 'Delivered'

  // Product management inputs
  final productNameController = TextEditingController();
  final productDescController = TextEditingController();
  final productPriceController = TextEditingController();

  // Branch management inputs
  final branchNameController = TextEditingController();
  final branchAddressController = TextEditingController();
  final branchLatController = TextEditingController();
  final branchLngController = TextEditingController();

  // Technician management inputs
  final techNameController = TextEditingController();
  final techEmailController = TextEditingController();

  // Doctor registration inputs (by Admin)
  final docNameController = TextEditingController();
  final docEmailController = TextEditingController();
  final docClinicController = TextEditingController();
  final docAddressController = TextEditingController();
  final docPasswordController = TextEditingController();

  // Doctor registration coordinates
  final docLatitude = 19.0760.obs;
  final docLongitude = 72.8777.obs;
  final docLocationSet = false.obs;

  @override
  void onInit() {
    super.onInit();
    docAddressController.addListener(() {
      final addr = docAddressController.text.trim();
      if (addr.isNotEmpty) {
        final coords = _simulateGeocode(addr);
        docLatitude.value = coords['lat']!;
        docLongitude.value = coords['lng']!;
        docLocationSet.value = true;
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
        final latVal = double.tryParse(parts[0].trim());
        final lngVal = double.tryParse(parts[1].trim());
        if (latVal != null && lngVal != null) {
          return {'lat': latVal, 'lng': lngVal};
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

  // Products CRUD
  void addProduct() {
    final name = productNameController.text.trim();
    final desc = productDescController.text.trim();

    if (name.isEmpty || desc.isEmpty) {
      Get.snackbar('Validation Error', 'Please fill all product fields.');
      return;
    }

    final newProd = ProductModel(
      id: 'prod_${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      description: desc,
      price: 0.0,
    );

    _db.saveProduct(newProd);
    clearProductInputs();
    Get.back();
    Get.snackbar('Success', 'Product catalog updated!');
  }

  void editProduct(ProductModel prod) {
    final updated = ProductModel(
      id: prod.id,
      name: productNameController.text.trim().isEmpty ? prod.name : productNameController.text.trim(),
      description: productDescController.text.trim().isEmpty ? prod.description : productDescController.text.trim(),
      price: 0.0,
    );

    _db.saveProduct(updated);
    clearProductInputs();
    Get.back();
    Get.snackbar('Success', 'Product updated!');
  }

  void deleteProduct(String id) {
    _db.deleteProduct(id);
    Get.snackbar('Deleted', 'Product removed from catalog.');
  }

  void clearProductInputs() {
    productNameController.clear();
    productDescController.clear();
    productPriceController.clear();
  }

  // Branches CRUD
  void addBranch() {
    final name = branchNameController.text.trim();
    final address = branchAddressController.text.trim();
    final lat = double.tryParse(branchLatController.text.trim()) ?? 40.7128;
    final lng = double.tryParse(branchLngController.text.trim()) ?? -74.0060;

    if (name.isEmpty || address.isEmpty) {
      Get.snackbar('Validation Error', 'Please enter branch details.');
      return;
    }

    final newBranch = BranchModel(
      id: 'branch_${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      address: address,
      latitude: lat,
      longitude: lng,
    );

    _db.saveBranch(newBranch);
    clearBranchInputs();
    Get.back();
    Get.snackbar('Success', 'Branch location added!');
  }

  void deleteBranch(String id) {
    _db.deleteBranch(id);
    Get.snackbar('Deleted', 'Branch removed.');
  }

  void clearBranchInputs() {
    branchNameController.clear();
    branchAddressController.clear();
    branchLatController.clear();
    branchLngController.clear();
  }

  // Technicians Management
  void addTechnician() {
    final name = techNameController.text.trim();
    final email = techEmailController.text.trim();

    if (name.isEmpty || email.isEmpty) {
      Get.snackbar('Validation Error', 'Please enter name and email.');
      return;
    }

    final newTech = UserModel(
      id: 'tech_${DateTime.now().millisecondsSinceEpoch}',
      email: email,
      name: name,
      role: 'technician',
      profilePhotoUrl: 'https://images.unsplash.com/photo-1537368910025-700350fe46c7?q=80&w=200&auto=format&fit=crop',
    );

    _db.users.add(newTech);
    techNameController.clear();
    techEmailController.clear();
    Get.back();
    Get.snackbar('Success', 'Lab Technician registered!');
  }

  // Doctor Directory management (by Admin)
  void registerDoctorByAdmin() {
    final name = docNameController.text.trim();
    final email = docEmailController.text.trim();
    final clinic = docClinicController.text.trim();
    final address = docAddressController.text.trim();
    final password = docPasswordController.text.trim();

    if (name.isEmpty || email.isEmpty || clinic.isEmpty || address.isEmpty || password.isEmpty) {
      Get.snackbar('Validation Error', 'Please fill all doctor registration fields.');
      return;
    }

    final newDoc = UserModel(
      id: 'doc_${DateTime.now().millisecondsSinceEpoch}',
      email: email,
      name: name,
      role: 'doctor',
      password: password,
      clinicName: clinic,
      address: address,
      latitude: docLatitude.value,
      longitude: docLongitude.value,
      profilePhotoUrl: 'https://images.unsplash.com/photo-1622253692010-333f2da6031d?q=80&w=200&auto=format&fit=crop',
    );

    _db.users.add(newDoc);
    clearDoctorInputs();
    Get.back();
    Get.snackbar('Success', 'Doctor registered successfully!');
  }

  void approveDoctor(UserModel doctor) {
    final updated = doctor.copyWith(isApproved: true);
    final idx = _db.users.indexWhere((u) => u.id == doctor.id);
    if (idx >= 0) {
      _db.users[idx] = updated;
      
      // Notify doctor
      _db.addNotification(
        doctor.id,
        'Account Approved',
        'Your registration has been approved by the Admin. You now have full access to Cloud Dental Express.',
      );
      
      Get.snackbar('Approved', 'Doctor ${doctor.name} has been approved successfully.');
    }
  }

  void resetDoctorPassword(UserModel doctor, String newPassword) {
    if (newPassword.trim().isEmpty) {
      Get.snackbar('Error', 'Password cannot be empty.');
      return;
    }
    
    final updated = doctor.copyWith(password: newPassword.trim());
    final idx = _db.users.indexWhere((u) => u.id == doctor.id);
    if (idx >= 0) {
      _db.users[idx] = updated;
      Get.snackbar('Success', 'Password reset successfully for ${doctor.name}!');
    }
  }

  void clearDoctorInputs() {
    docNameController.clear();
    docEmailController.clear();
    docClinicController.clear();
    docAddressController.clear();
    docPasswordController.clear();
    docLatitude.value = 19.0760;
    docLongitude.value = 72.8777;
    docLocationSet.value = false;
  }

  // Order Details: Assignment and Status Updates
  void assignTechnician(OrderModel order, UserModel tech) {

    final updatedOrder = order.copyWith(
      technicianId: tech.id,
      technicianName: tech.name,
      status: order.status == 'Pending' ? 'Lab Received' : order.status,
    );

    _db.saveOrder(updatedOrder);

    // Notify doctor
    _db.addNotification(
      order.doctorId,
      'Technician Assigned',
      'Case ${order.id} has been assigned to ${tech.name}.',
    );

    // Notify technician
    _db.addNotification(
      tech.id,
      'New Case Assigned',
      'You have been assigned Case ${order.id} for patient ${order.patientName}.',
    );

    // Push FCM simulation
    _fcm.simulatePushNotification(
      'Case Update',
      'Case ${order.id} assigned to ${tech.name}.',
    );

    Get.snackbar('Assigned', 'Case assigned to ${tech.name} successfully.');
  }

  void updateOrderStatus(OrderModel order, String newStatus) {
    final updatedOrder = order.copyWith(status: newStatus);
    _db.saveOrder(updatedOrder);

    // If delivered, auto-generate a Bill
    if (newStatus.toLowerCase() == 'delivered') {
      final billId = 'INV-${4000 + _db.bills.length + 1}';
      
      // Calculate matching product price
      final prodItem = _db.products.firstWhereOrNull((p) => p.name == order.product);
      final price = prodItem != null ? (prodItem.price * order.toothNumbers.length) : 150.00;

      final newBill = BillModel(
        id: billId,
        orderId: order.id,
        patientName: order.patientName,
        productName: order.product,
        price: price,
        dateCreated: DateTime.now(),
        isPaid: false,
      );

      _db.saveBill(newBill);

      _db.addNotification(
        order.doctorId,
        'Case Delivered & Bill Ready',
        'Case ${order.id} has been marked as delivered. Invoice $billId is available for download.',
      );
    } else {
      _db.addNotification(
        order.doctorId,
        'Case Status Updated',
        'Case ${order.id} is now $newStatus.',
      );
    }

    // Push FCM simulation
    _fcm.simulatePushNotification(
      'Case Update',
      'Case ${order.id} is now $newStatus.',
    );

    Get.snackbar('Status Updated', 'Case status set to $newStatus.');
  }

  @override
  void dispose() {
    productNameController.dispose();
    productDescController.dispose();
    productPriceController.dispose();
    branchNameController.dispose();
    branchAddressController.dispose();
    branchLatController.dispose();
    branchLngController.dispose();
    techNameController.dispose();
    techEmailController.dispose();
    docNameController.dispose();
    docEmailController.dispose();
    docClinicController.dispose();
    docAddressController.dispose();
    docPasswordController.dispose();
    super.dispose();
  }

}
