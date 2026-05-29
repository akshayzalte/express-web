import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import '../../config/theme.dart';
import '../../controllers/admin_controller.dart';
import '../../services/database_service.dart';
import '../../models/order.dart';
import '../../widgets/glass_container.dart';
import '../../widgets/glass_button.dart';
import '../../widgets/status_badge.dart';

class AdminOrderDetail extends StatelessWidget {
  const AdminOrderDetail({super.key});

  @override
  Widget build(BuildContext context) {
    final OrderModel order = Get.arguments as OrderModel;
    final controller = Get.find<AdminController>();
    final db = Get.find<DatabaseService>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final techList = db.users.where((u) => u.role == 'technician').toList();
    final statusList = ['Pending', 'Lab Received', 'In Progress', 'Quality Check', 'Delivered'];

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Manage Case ${order.id}',
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
            // Order overview
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
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      StatusBadge(status: order.status),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _detailRow(context, 'Dentist:', order.doctorName),
                  _detailRow(context, 'Restoration:', order.product),
                  _detailRow(context, 'Teeth:', '#${order.toothNumbers.join(",")}'),
                  _detailRow(context, 'Shade:', order.shade),
                  _detailRow(context, 'Lab Branch:', order.branch),
                  _detailRow(context, 'Delivery Date:', order.dueDate.toString().split(' ')[0]),
                  if (order.notes != null) ...[
                    const SizedBox(height: 6),
                    Text(
                      'Doctor Notes:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white60 : Colors.black54,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      order.notes!,
                      style: const TextStyle(fontStyle: FontStyle.italic),
                    ),
                  ],
                ],
              ),
            ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.1, end: 0),
            const SizedBox(height: 20),

            // Technician Assignment Card
            Text(
              'Technician Assignment',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontSize: 18),
            ),
            const SizedBox(height: 12),
            GlassContainer(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (order.technicianId != null) ...[
                    Row(
                      children: [
                        CircleAvatar(
                          backgroundImage: NetworkImage(
                            order.technicianId == 'tech_1'
                                ? 'https://images.unsplash.com/photo-1622253692010-333f2da6031d?q=80&w=200&auto=format&fit=crop'
                                : (order.technicianId == 'tech_2' 
                                    ? 'https://images.unsplash.com/photo-1594824813573-246434de83fb?q=80&w=200&auto=format&fit=crop'
                                    : 'https://images.unsplash.com/photo-1537368910025-700350fe46c7?q=80&w=200&auto=format&fit=crop'),
                          ),
                          radius: 20,
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              order.technicianName!,
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            const Text(
                              'Assigned Technician',
                              style: TextStyle(fontSize: 11, color: Colors.grey),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                  ],
                  
                  // Assign / Re-assign Selector dropdown
                  Text(
                    order.technicianId != null ? 'Re-assign Technician' : 'Assign Lab Technician',
                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: isDark ? Colors.white.withOpacity(0.04) : Colors.black.withOpacity(0.02),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: isDark ? Colors.white24 : Colors.black12),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    ),
                    hint: const Text('Select Technician'),
                    dropdownColor: isDark ? const Color(0xFF0F1E31) : Colors.white,
                    items: techList.map((t) {
                      return DropdownMenuItem<String>(
                        value: t.id,
                        child: Text(t.name),
                      );
                    }).toList(),
                    onChanged: (v) {
                      final selectedTech = techList.firstWhereOrNull((t) => t.id == v);
                      if (selectedTech != null) {
                        controller.assignTechnician(order, selectedTech);
                        // Refresh details view
                        Get.back();
                      }
                    },
                  ),
                ],
              ),
            ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.1, end: 0),
            const SizedBox(height: 20),

            // Order Status Overrides
            Text(
              'Workflow Status Control',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontSize: 18),
            ),
            const SizedBox(height: 12),
            GlassContainer(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Manually Update Lab Status:',
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8.0,
                    runSpacing: 8.0,
                    children: statusList.map((status) {
                      final isActive = order.status.toLowerCase().replaceAll(' ', '') == 
                          status.toLowerCase().replaceAll(' ', '');
                      return ChoiceChip(
                        label: Text(status),
                        selected: isActive,
                        selectedColor: isDark ? GlacierColors.darkPrimary : GlacierColors.lightPrimary,
                        labelStyle: TextStyle(
                          color: isActive ? Colors.white : (isDark ? Colors.white70 : Colors.black87),
                          fontWeight: FontWeight.bold,
                        ),
                        backgroundColor: isDark ? Colors.white10 : Colors.black.withOpacity(0.04),
                        onSelected: (selected) {
                          if (selected) {
                            controller.updateOrderStatus(order, status);
                            // Refresh detail page
                            Get.back();
                          }
                        },
                      );
                    }).toList(),
                  ),
                ],
              ),
            ).animate().fadeIn(delay: 150.ms).slideY(begin: 0.1, end: 0),
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
            width: 100,
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
}
