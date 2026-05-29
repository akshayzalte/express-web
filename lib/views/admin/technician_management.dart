import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import '../../config/theme.dart';
import '../../controllers/admin_controller.dart';
import '../../services/database_service.dart';
import '../../widgets/glass_container.dart';
import '../../widgets/glass_input.dart';

class TechnicianManagement extends StatelessWidget {
  const TechnicianManagement({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AdminController>();
    final db = Get.find<DatabaseService>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Lab Technicians',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add_alt_1_outlined),
            onPressed: () => _showAddTechDialog(context),
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
        child: Obx(() {
          final technicians = db.users.where((u) => u.role == 'technician').toList();

          if (technicians.isEmpty) {
            return Center(
              child: Text(
                'No technicians registered.',
                style: TextStyle(color: isDark ? Colors.white54 : Colors.black45),
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(20.0),
            itemCount: technicians.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final tech = technicians[index];
              
              // Calculate active caseload for this tech
              final activeJobs = db.orders
                  .where((o) => o.technicianId == tech.id && o.status.toLowerCase() != 'delivered')
                  .length;

              return GlassContainer(
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundImage: NetworkImage(
                        tech.id == 'tech_1'
                            ? 'https://images.unsplash.com/photo-1622253692010-333f2da6031d?q=80&w=200&auto=format&fit=crop'
                            : (tech.id == 'tech_2' 
                                ? 'https://images.unsplash.com/photo-1594824813573-246434de83fb?q=80&w=200&auto=format&fit=crop'
                                : 'https://images.unsplash.com/photo-1537368910025-700350fe46c7?q=80&w=200&auto=format&fit=crop'),
                      ),
                      radius: 24,
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            tech.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            tech.email,
                            style: TextStyle(
                              fontSize: 12,
                              color: isDark ? Colors.white60 : Colors.black54,
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    // Caseload Badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: isDark ? Colors.white10 : Colors.black.withOpacity(0.04),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        children: [
                          Text(
                            '$activeJobs',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: isDark ? GlacierColors.darkPrimary : GlacierColors.lightPrimary,
                            ),
                          ),
                          const Text(
                            'active cases',
                            style: TextStyle(fontSize: 9, color: Colors.grey),
                          ),
                        ],
                      ),
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

  void _showAddTechDialog(BuildContext context) {
    final controller = Get.find<AdminController>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    controller.techNameController.clear();
    controller.techEmailController.clear();

    Get.dialog(
      Dialog(
        backgroundColor: Colors.transparent,
        child: GlassContainer(
          borderRadius: 24,
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Register Lab Technician',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontSize: 18),
              ),
              const SizedBox(height: 16),
              GlassInput(
                controller: controller.techNameController,
                labelText: 'Technician Name',
                hintText: 'e.g. Alex Rivers',
              ),
              const SizedBox(height: 12),
              GlassInput(
                controller: controller.techEmailController,
                labelText: 'Email Address',
                hintText: 'alex@dental.com',
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Get.back(),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: controller.addTechnician,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isDark ? GlacierColors.darkPrimary : GlacierColors.lightPrimary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: const Text('Register'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
