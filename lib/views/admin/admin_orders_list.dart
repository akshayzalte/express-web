import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import '../../config/theme.dart';
import '../../controllers/admin_controller.dart';
import '../../services/database_service.dart';
import '../../widgets/glass_container.dart';
import '../../widgets/status_badge.dart';

class AdminOrdersList extends StatelessWidget {
  const AdminOrdersList({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AdminController>();
    final db = Get.find<DatabaseService>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final filterOptions = ['All', 'Pending', 'In Progress', 'Delivered'];

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Lab Case Queue',
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
        child: Column(
          children: [
            // Filter Selector row
            Container(
              height: 50,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: filterOptions.length,
                itemBuilder: (context, index) {
                  final filter = filterOptions[index];
                  return Obx(() {
                    final isSelected = controller.selectedFilter.value == filter;
                    return GestureDetector(
                      onTap: () => controller.selectedFilter.value = filter,
                      child: Container(
                        margin: const EdgeInsets.only(right: 12),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? (isDark ? GlacierColors.darkPrimary : GlacierColors.lightPrimary)
                              : Colors.white.withOpacity(isDark ? 0.08 : 0.4),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected 
                                ? Colors.transparent 
                                : Colors.white.withOpacity(0.2),
                          ),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          filter,
                          style: TextStyle(
                            color: isSelected 
                                ? Colors.white 
                                : (isDark ? Colors.white70 : Colors.black87),
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    );
                  });
                },
              ),
            ),
            const SizedBox(height: 12),

            // Orders list
            Expanded(
              child: Obx(() {
                var list = db.orders.toList();
                final currentFilter = controller.selectedFilter.value;
                
                if (currentFilter == 'Pending') {
                  list = list.where((o) => o.status.toLowerCase() == 'pending').toList();
                } else if (currentFilter == 'In Progress') {
                  list = list.where((o) => o.status.toLowerCase() == 'in progress' || o.status.toLowerCase() == 'lab received').toList();
                } else if (currentFilter == 'Delivered') {
                  list = list.where((o) => o.status.toLowerCase() == 'delivered').toList();
                }

                if (list.isEmpty) {
                  return Center(
                    child: Text(
                      'No cases match this filter.',
                      style: TextStyle(color: isDark ? Colors.white54 : Colors.black45),
                    ),
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.all(20),
                  itemCount: list.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final order = list[index];
                    return GestureDetector(
                      onTap: () => Get.toNamed('/admin-order-detail', arguments: order),
                      child: GlassContainer(
                        child: Row(
                          children: [
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: isDark ? Colors.white10 : Colors.black.withOpacity(0.04),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(
                                Icons.folder_open_outlined,
                                color: isDark ? GlacierColors.darkPrimary : GlacierColors.lightPrimary,
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${order.id} - ${order.patientName}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'Doctor: ${order.doctorName} | ${order.product}',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: isDark ? Colors.white54 : Colors.black54,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            StatusBadge(status: order.status),
                          ],
                        ),
                      ),
                    ).animate().fadeIn(delay: (index * 50).ms).slideY(begin: 0.1, end: 0);
                  },
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}
