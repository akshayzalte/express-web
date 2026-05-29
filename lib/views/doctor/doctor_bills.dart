import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import '../../config/theme.dart';
import '../../controllers/doctor_controller.dart';
import '../../services/database_service.dart';
import '../../widgets/glass_container.dart';
import '../../widgets/glass_button.dart';

class DoctorBills extends StatelessWidget {
  const DoctorBills({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<DoctorController>();
    final db = Get.find<DatabaseService>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Billing & Invoices',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.topCenter,
            radius: 1.5,
            colors: isDark
                ? [const Color(0xFF0F2B48), const Color(0xFF0A1628)]
                : [const Color(0xFFDCE6F1), const Color(0xFFEAF0F6)],
          ),
        ),
        child: Obx(() {
          final billsList = db.bills.toList();

          if (billsList.isEmpty) {
            return Center(
              child: Text(
                'No invoices available.',
                style: TextStyle(color: isDark ? Colors.white54 : Colors.black45),
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(20.0),
            itemCount: billsList.length,
            separatorBuilder: (context, index) => const SizedBox(height: 16),
            itemBuilder: (context, index) {
              final bill = billsList[index];
              final statusColor = bill.isPaid 
                  ? GlacierColors.badgeDeliveredText
                  : GlacierColors.badgePendingText;
              final statusBg = bill.isPaid
                  ? GlacierColors.badgeDeliveredBg
                  : GlacierColors.badgePendingBg;

              return GlassContainer(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          bill.id,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        // Paid Status pill
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: statusBg,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: statusColor.withOpacity(0.2)),
                          ),
                          child: Text(
                            bill.isPaid ? 'PAID' : 'PENDING',
                            style: TextStyle(
                              color: statusColor,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Patient: ${bill.patientName}',
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    Text(
                      'Product Item: ${bill.productName}',
                      style: TextStyle(color: isDark ? Colors.white60 : Colors.black54),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Total Charges:',
                          style: TextStyle(color: isDark ? Colors.white60 : Colors.black54),
                        ),
                        Text(
                          '\$${bill.price.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: isDark ? GlacierColors.darkPrimary : GlacierColors.lightPrimary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Divider(color: isDark ? Colors.white12 : Colors.black12),
                    const SizedBox(height: 8),
                    
                    // Buttons list
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () => controller.downloadInvoice(bill),
                            icon: const Icon(Icons.print_outlined, size: 18),
                            label: const Text('Print/PDF'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: isDark ? Colors.white : GlacierColors.lightPrimary,
                              side: BorderSide(color: isDark ? Colors.white24 : Colors.black26),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () => controller.shareInvoiceWhatsApp(bill),
                            icon: const Icon(Icons.share, size: 18),
                            label: const Text('WhatsApp'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF25D366),
                              foregroundColor: Colors.white,
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ).animate().fadeIn(delay: (index * 60).ms).slideY(begin: 0.1, end: 0);
            },
          );
        }),
      ),
    );
  }
}
