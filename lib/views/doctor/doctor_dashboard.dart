import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import '../../config/theme.dart';
import '../../controllers/doctor_controller.dart';
import '../../services/database_service.dart';
import '../../services/auth_service.dart';
import '../../widgets/glass_container.dart';
import '../../widgets/status_badge.dart';
import '../../widgets/number_counter.dart';

class DoctorDashboard extends StatelessWidget {
  const DoctorDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(DoctorController());
    final db = Get.find<DatabaseService>();
    final auth = Get.find<AuthService>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Obx(() {
      final doctorOrders = db.orders
          .where((o) => o.doctorId == auth.currentUser.value?.id)
          .toList();
      final pendingCount = doctorOrders
          .where((o) => o.status.toLowerCase() == 'pending')
          .length;
      final inProgressCount = doctorOrders
          .where((o) => o.status.toLowerCase() == 'in progress' || o.status.toLowerCase() == 'lab received')
          .length;

      return Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: Text(
            'Cloud Dental Express',
            style: TextStyle(
              color: isDark ? Colors.white : GlacierColors.lightPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
          actions: [
            IconButton(
              icon: const Icon(Icons.notifications_outlined),
              onPressed: () => Get.toNamed('/notifications'),
            ),
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
              // Doctor Welcome Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Good morning,',
                        style: TextStyle(
                          fontSize: 16,
                          color: isDark ? Colors.white70 : const Color(0xFF44474E),
                        ),
                      ),
                      Text(
                        auth.currentUser.value?.name ?? 'Doctor',
                        style: Theme.of(context).textTheme.displayLarge?.copyWith(
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ],
                  ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.1, end: 0),
                  
                  // Profile Photo Avatar
                  GestureDetector(
                    onTap: () => Get.toNamed('/profile'),
                    child: Hero(
                      tag: 'profile_avatar',
                      child: Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white24,
                            width: 2.0,
                          ),
                          image: DecorationImage(
                            image: NetworkImage(auth.currentUser.value?.profilePhotoUrl ?? 
                              'https://lh3.googleusercontent.com/aida-public/AB6AXuBXTsdQ9rxXIR53E5FHjR7Nq0G8JRYwpimfOrwhzc0OQD7ANSgIzzu220BIo6T1NWoZbuwytqRxHXsEfPWN2UefBL5PdSg5buqDYgw20h6W3V4oS6dA9K5NXSYpmkyYnUUUPhTrhwSxLkcoRnJJbR8q3g4xi80xsRRY54_1SPEviCFtBLTeFr_u6uH5Wuu-s_Xy47HwmW4TRPdEHcmOb3gilhqopFxCTV2IyO2nWeJPDNXWF08hSAfu0S0hPEIO0ZGZtIIMjqrPwAqe'),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Bento Box Grid Overview
              Row(
                children: [
                  // Pending count card
                  Expanded(
                    child: GlassContainer(
                      height: 120,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Pending',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: isDark ? Colors.white70 : GlacierColors.lightPrimary,
                                ),
                              ),
                              Icon(Icons.hourglass_empty_rounded, 
                                  color: isDark ? GlacierColors.darkPrimary : GlacierColors.lightPrimary),
                            ],
                          ),
                          NumberCounter(
                            targetValue: pendingCount,
                            style: TextStyle(
                              fontSize: 36,
                              fontWeight: FontWeight.bold,
                              color: isDark ? Colors.white : GlacierColors.lightPrimary,
                            ),
                          ),
                        ],
                      ),
                    ).animate().fadeIn(delay: 50.ms).slideY(begin: 0.1, end: 0),
                  ),
                  const SizedBox(width: 16),
                  
                  // In Progress count card
                  Expanded(
                    child: GlassContainer(
                      height: 120,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'In Lab',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: isDark ? Colors.white70 : GlacierColors.lightPrimary,
                                ),
                              ),
                              Icon(Icons.biotech_rounded,
                                  color: isDark ? GlacierColors.darkPrimary : GlacierColors.lightPrimary),
                            ],
                          ),
                          NumberCounter(
                            targetValue: inProgressCount,
                            style: TextStyle(
                              fontSize: 36,
                              fontWeight: FontWeight.bold,
                              color: isDark ? Colors.white : GlacierColors.lightPrimary,
                            ),
                          ),
                        ],
                      ),
                    ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.1, end: 0),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Recent cases list title
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Recent Lab Cases',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontSize: 20,
                        ),
                  ),
                  TextButton(
                    onPressed: () {},
                    child: Text(
                      'View All',
                      style: TextStyle(
                        color: isDark ? GlacierColors.darkPrimary : GlacierColors.lightPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ).animate().fadeIn(delay: 150.ms),
              const SizedBox(height: 12),

              // List of Cases
              if (doctorOrders.isEmpty)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 40.0),
                    child: Text(
                      'No cases submitted yet.',
                      style: TextStyle(color: isDark ? Colors.white54 : Colors.black45),
                    ),
                  ),
                )
              else
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: doctorOrders.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final order = doctorOrders[index];
                    return GestureDetector(
                      onTap: () => Get.toNamed('/order-tracker', arguments: order),
                      child: GlassContainer(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
                        child: Row(
                          children: [
                            Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                color: isDark ? Colors.white10 : Colors.black.withOpacity(0.04),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                Icons.settings_backup_restore,
                                color: isDark ? GlacierColors.darkPrimary : GlacierColors.lightPrimary,
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Patient: ${order.patientName}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${order.product} - Tooth #${order.toothNumbers.join(',')}',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: isDark ? Colors.white60 : Colors.black54,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    order.technicianName != null
                                        ? 'Tech: ${order.technicianName}'
                                        : 'Tech: Pending Lab Assignment',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w500,
                                      color: order.technicianName != null
                                          ? (isDark ? GlacierColors.darkPrimary : GlacierColors.lightPrimary)
                                          : Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            StatusBadge(status: order.status),
                          ],
                        ),
                      ).animate().fadeIn(delay: (200 + index * 60).ms).slideY(begin: 0.1, end: 0),
                    );
                  },
                ),
            ],
          ),
        ),
        bottomNavigationBar: _buildBottomNav(context, 0),
      );
    });
  }

  Widget _buildBottomNav(BuildContext context, int activeIndex) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final db = Get.find<DatabaseService>();
    final auth = Get.find<AuthService>();
    
    // Calculate unread notifications count for the current doctor
    final unreadCount = db.notifications
        .where((n) => n.userId == auth.currentUser.value?.id && !n.isRead)
        .length;

    return Container(
      height: 80,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0F1E31).withOpacity(0.9) : Colors.white.withOpacity(0.8),
        border: Border(
          top: BorderSide(
            color: isDark ? Colors.white12 : Colors.black12,
            width: 1.0,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _navItem(context, Icons.assignment, 'Cases', activeIndex == 0, () {}),
          _navItem(context, Icons.inventory_2_outlined, 'Inventory', activeIndex == 2, () => Get.toNamed('/inventory')),
          _addCaseButton(context),
          _navItem(
            context,
            Icons.notifications_outlined,
            'Alerts',
            activeIndex == 4,
            () => Get.toNamed('/notifications'),
            badgeCount: unreadCount,
          ),
          _navItem(context, Icons.person_rounded, 'Profile', activeIndex == 3, () => Get.toNamed('/profile')),
        ],
      ),
    );
  }

  Widget _navItem(
    BuildContext context,
    IconData icon,
    String label,
    bool isSelected,
    VoidCallback onTap, {
    int badgeCount = 0,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final activeColor = isDark ? GlacierColors.darkPrimary : GlacierColors.lightPrimary;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Icon(
                  icon,
                  color: isSelected ? activeColor : Colors.grey,
                ),
                if (badgeCount > 0)
                  Positioned(
                    right: -6,
                    top: -6,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: const BoxDecoration(
                        color: Colors.redAccent,
                        shape: BoxShape.circle,
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 14,
                        minHeight: 14,
                      ),
                      child: Text(
                        '$badgeCount',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 8,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? activeColor : Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }


  Widget _addCaseButton(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final activeColor = isDark ? GlacierColors.darkPrimary : GlacierColors.lightPrimary;

    return Transform.translate(
      offset: const Offset(0, -10),
      child: GestureDetector(
        onTap: () => Get.toNamed('/new-order'),
        child: Container(
          width: 54,
          height: 54,
          decoration: BoxDecoration(
            color: activeColor,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: activeColor.withOpacity(0.3),
                blurRadius: 12,
                offset: const Offset(0, 4),
              )
            ],
          ),
          child: const Icon(
            Icons.add,
            color: Colors.white,
            size: 28,
          ),
        ),
      ),
    );
  }
}
