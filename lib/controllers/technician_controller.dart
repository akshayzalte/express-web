import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../services/database_service.dart';
import '../services/auth_service.dart';
import '../services/fcm_service.dart';
import '../models/order.dart';
import '../models/bill.dart';

class TechnicianController extends GetxController {
  final DatabaseService _db = Get.find<DatabaseService>();
  final AuthService _auth = Get.find<AuthService>();
  final FCMService _fcm = Get.find<FCMService>();

  final labNotesController = TextEditingController();

  void saveTechnicianWork(OrderModel order, String newStatus) {
    final notes = labNotesController.text.trim();
    
    // Auto-calculates prices
    final prodItem = _db.products.firstWhereOrNull((p) => p.name == order.product);
    final price = prodItem != null ? (prodItem.price * order.toothNumbers.length) : 150.00;

    final updatedOrder = order.copyWith(
      status: newStatus,
      labNotes: notes.isEmpty ? order.labNotes : notes,
    );

    _db.saveOrder(updatedOrder);

    // Notify doctor
    _db.addNotification(
      order.doctorId,
      'Case Status Updated',
      'Case ${order.id} is now $newStatus.',
    );

    if (newStatus.toLowerCase() == 'delivered') {
      final billId = 'INV-${4000 + _db.bills.length + 1}';
      
      final existingBill = _db.bills.firstWhereOrNull((b) => b.orderId == order.id);
      if (existingBill == null) {
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
      }
    }

    _fcm.simulatePushNotification(
      'Case Status Updated',
      'Case ${order.id} is now $newStatus.',
    );

    labNotesController.clear();
    Get.back(); // Go back to dashboard
  }

  @override
  void dispose() {
    labNotesController.dispose();
    super.dispose();
  }
}
