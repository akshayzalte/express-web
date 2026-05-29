import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import '../../config/theme.dart';
import '../../controllers/technician_controller.dart';
import '../../services/database_service.dart';
import '../../services/auth_service.dart';
import '../../widgets/glass_container.dart';
import '../../widgets/status_badge.dart';

class TechnicianDashboard extends StatelessWidget {
  const TechnicianDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(TechnicianController());
    final db = Get.find<DatabaseService>();
    final auth = Get.find<AuthService>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Obx(() {
      final techUser = auth.currentUser.value;
      final assignedCases = db.orders
          .where((o) => o.technicianId == techUser?.id)
          .toList();

      return Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: Text(
            'Lab Desk',
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
                'Good morning, ${techUser?.name ?? "Technician"}',
                style: Theme.of(context).textTheme.displayLarge?.copyWith(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
              ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.1, end: 0),
              const SizedBox(height: 6),
              Text(
                'Here are your assigned lab cases for today.',
                style: TextStyle(color: isDark ? Colors.white70 : Colors.black54),
              ),
              const SizedBox(height: 24),

              // Cases List
              Text(
                'My Active Jobs (${assignedCases.length})',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontSize: 18),
              ),
              const SizedBox(height: 12),
              
              if (assignedCases.isEmpty)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 40.0),
                    child: Text(
                      'No cases assigned to you at the moment.',
                      style: TextStyle(color: isDark ? Colors.white54 : Colors.black45),
                    ),
                  ),
                )
              else
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: assignedCases.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final order = assignedCases[index];
                    return GestureDetector(
                      onTap: () => Get.toNamed('/technician-order-detail', arguments: order),
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
                                Icons.biotech_rounded,
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
                                    'Restoration: ${order.product} | Tooth #${order.toothNumbers.join(",")}',
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
                    ).animate().fadeIn(delay: (index * 60).ms).slideY(begin: 0.1, end: 0);
                  },
                ),
            ],
          ),
        ),
      );
    });
  }
}
