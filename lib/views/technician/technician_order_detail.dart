import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import '../../controllers/technician_controller.dart';
import '../../models/order.dart';
import '../../widgets/glass_container.dart';
import '../../widgets/glass_button.dart';
import '../../widgets/glass_input.dart';
import '../../widgets/status_badge.dart';

class TechnicianOrderDetail extends StatelessWidget {
  const TechnicianOrderDetail({super.key});

  @override
  Widget build(BuildContext context) {
    final OrderModel order = Get.arguments as OrderModel;
    final controller = Get.find<TechnicianController>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (order.labNotes != null) {
      controller.labNotesController.text = order.labNotes!;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Case Work ${order.id}',
          style: const TextStyle(fontWeight: FontWeight.bold),
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
        child: ListView(
          padding: const EdgeInsets.all(20.0),
          children: [
            // Order Overview Card
            GlassContainer(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        order.patientName,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      StatusBadge(status: order.status),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _detailRow(context, 'Prescriber:', order.doctorName),
                  _detailRow(context, 'Restoration:', order.product),
                  _detailRow(context, 'Tooth Indices:', '#${order.toothNumbers.join(",")}'),
                  _detailRow(context, 'Shade Selection:', order.shade),
                  _detailRow(context, 'Branch Delivery:', order.branch),
                  _detailRow(context, 'Required Date:', order.dueDate.toString().split(' ')[0]),
                  
                  // Coping try in details
                  const SizedBox(height: 8),
                  Divider(color: isDark ? Colors.white12 : Colors.black12),
                  const SizedBox(height: 6),
                  _boolRow(context, 'Coping Try-in Required:', order.coping),
                  _boolRow(context, 'Bisque Bake Required:', order.bakeToggle),
                  
                  if (order.notes != null) ...[
                    const SizedBox(height: 12),
                    Text(
                      'Clinical Instructions:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white60 : Colors.black54,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      order.notes!,
                      style: const TextStyle(fontStyle: FontStyle.italic, fontSize: 13),
                    ),
                  ],
                ],
              ),
            ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.1, end: 0),
            const SizedBox(height: 20),

            // Lab notes and status override
            GlassContainer(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Lab Technical Logs',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontSize: 18),
                  ),
                  const SizedBox(height: 12),
                  
                  GlassInput(
                    controller: controller.labNotesController,
                    labelText: 'Technical Notes / Logs',
                    hintText: 'Enter casting details or milling check notes...',
                    maxLines: 3,
                    prefixIcon: Icons.rate_review_outlined,
                  ),
                  const SizedBox(height: 20),

                  Text(
                    'Update Case Progress:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white60 : Colors.black54,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 12),

                  Column(
                    children: [
                      GlassButton(
                        label: 'Mark as In Progress',
                        icon: Icons.play_arrow_rounded,
                        isPrimary: order.status.toLowerCase() == 'lab received' || order.status.toLowerCase() == 'pending',
                        onPressed: () => controller.saveTechnicianWork(order, 'In Progress'),
                      ),
                      const SizedBox(height: 12),
                      GlassButton(
                        label: 'Mark as Quality Check',
                        icon: Icons.check_circle_outline,
                        isPrimary: order.status.toLowerCase() == 'in progress',
                        onPressed: () => controller.saveTechnicianWork(order, 'Quality Check'),
                      ),
                      const SizedBox(height: 12),
                      GlassButton(
                        label: 'Mark as Delivered',
                        icon: Icons.local_shipping_outlined,
                        isPrimary: order.status.toLowerCase() == 'quality check',
                        onPressed: () => controller.saveTechnicianWork(order, 'Delivered'),
                      ),
                    ],
                  ),
                ],
              ),
            ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.1, end: 0),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _detailRow(BuildContext context, String label, String value) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.only(bottom: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white60 : Colors.black54,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  Widget _boolRow(BuildContext context, String label, bool value) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.only(bottom: 6.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              color: isDark ? Colors.white60 : Colors.black54,
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: value 
                  ? Colors.green.withOpacity(0.12)
                  : Colors.grey.withOpacity(0.12),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              value ? 'YES' : 'NO',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: value ? Colors.green : Colors.grey,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
