import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import '../../config/theme.dart';
import '../../controllers/admin_controller.dart';
import '../../services/database_service.dart';
import '../../services/auth_service.dart';
import '../../widgets/glass_container.dart';
import '../../widgets/number_counter.dart';

class AdminDashboard extends StatelessWidget {
  const AdminDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(AdminController());
    final db = Get.find<DatabaseService>();
    final auth = Get.find<AuthService>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Obx(() {
      final totalOrders = db.orders.length;
      final pendingCount = db.orders.where((o) => o.status.toLowerCase() == 'pending').length;
      final inLabCount = db.orders.where((o) => o.status.toLowerCase() == 'in progress' || o.status.toLowerCase() == 'lab received').length;
      final qcCount = db.orders.where((o) => o.status.toLowerCase() == 'quality check' || o.status.toLowerCase() == 'qc').length;
      final deliveredCount = db.orders.where((o) => o.status.toLowerCase() == 'delivered').length;

      return Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: Text(
            'Admin Portal',
            style: TextStyle(
              color: isDark ? Colors.white : GlacierColors.lightPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
          actions: [
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () {
                auth.logout();
                Get.offAllNamed('/login');
              },
            ),
          ],
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
              // Welcome header
              Text(
                'Good morning, Admin',
                style: Theme.of(context).textTheme.displayLarge?.copyWith(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
              ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.1, end: 0),
              const SizedBox(height: 6),
              Text(
                'Lab performance summary and order queues.',
                style: TextStyle(color: isDark ? Colors.white70 : Colors.black54),
              ),
              const SizedBox(height: 24),

              // Bento Grid of counters
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 1.3,
                children: [
                  _statCard(context, 'Pending Queues', pendingCount, Icons.hourglass_empty_rounded, () {
                    controller.selectedFilter.value = 'Pending';
                    Get.toNamed('/admin-orders');
                  }, 0),
                  _statCard(context, 'In Progress', inLabCount, Icons.construction_rounded, () {
                    controller.selectedFilter.value = 'In Progress';
                    Get.toNamed('/admin-orders');
                  }, 1),
                  _statCard(context, 'Quality Check', qcCount, Icons.verified_user_outlined, () {
                    controller.selectedFilter.value = 'All'; // or QC
                    Get.toNamed('/admin-orders');
                  }, 2),
                  _statCard(context, 'Delivered Cases', deliveredCount, Icons.check_circle_outline_rounded, () {
                    controller.selectedFilter.value = 'Delivered';
                    Get.toNamed('/admin-orders');
                  }, 3),
                ],
              ),
              const SizedBox(height: 28),

              // Quick management controls title
              Text(
                'System Directories',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontSize: 20,
                    ),
              ),
              const SizedBox(height: 12),

              // Directory Row
              Column(
                children: [
                  _directoryTile(context, Icons.assignment, 'All Active Cases', 'Manage all clinical orders ($totalOrders cases)', () {
                    controller.selectedFilter.value = 'All';
                    Get.toNamed('/admin-orders');
                  }, 0),
                  const SizedBox(height: 12),
                  _directoryTile(context, Icons.shopping_bag_outlined, 'Product Catalog', 'Configure laboratory crown catalog', () {
                    Get.toNamed('/products-mgmt');
                  }, 1),
                  const SizedBox(height: 12),
                  _directoryTile(context, Icons.storefront, 'Lab Branches', 'Manage branch location coordinates', () {
                    Get.toNamed('/branches-mgmt');
                  }, 2),
                  const SizedBox(height: 12),
                  _directoryTile(context, Icons.engineering_outlined, 'Lab Technicians', 'Oversee and assign lab staff', () {
                    Get.toNamed('/technicians-mgmt');
                  }, 3),
                  const SizedBox(height: 12),
                  _directoryTile(context, Icons.medical_services_outlined, 'Doctors Directory', 'Register and manage client accounts', () {
                    Get.toNamed('/doctors-mgmt');
                  }, 4),

                ],
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget _statCard(
    BuildContext context,
    String label,
    int count,
    IconData icon,
    VoidCallback onTap,
    int index,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: GlassContainer(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    label,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white70 : Colors.black54,
                    ),
                  ),
                ),
                Icon(
                  icon,
                  size: 18,
                  color: isDark ? GlacierColors.darkPrimary : GlacierColors.lightPrimary,
                ),
              ],
            ),
            NumberCounter(
              targetValue: count,
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : GlacierColors.lightPrimary,
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(delay: (index * 60).ms).scale(begin: const Offset(0.9, 0.9), end: const Offset(1, 1));
  }

  Widget _directoryTile(
    BuildContext context,
    IconData icon,
    String title,
    String subtitle,
    VoidCallback onTap,
    int index,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: GlassContainer(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: isDark ? Colors.white10 : Colors.black.withOpacity(0.04),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: isDark ? GlacierColors.darkPrimary : GlacierColors.lightPrimary,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? Colors.white60 : Colors.black54,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: isDark ? Colors.white54 : Colors.black54,
            ),
          ],
        ),
      ),
    ).animate().fadeIn(delay: (200 + index * 60).ms).slideY(begin: 0.1, end: 0);
  }
}
