import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import '../../config/theme.dart';
import '../../controllers/admin_controller.dart';
import '../../services/database_service.dart';
import '../../widgets/glass_container.dart';
import '../../widgets/glass_input.dart';
import '../../widgets/tile_map_widget.dart';
import '../../models/user.dart';

class DoctorManagement extends StatelessWidget {
  const DoctorManagement({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AdminController>();
    final db = Get.find<DatabaseService>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Doctor Directory',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add_alt_1_outlined),
            onPressed: () => _showAddDocDialog(context),
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
          final doctors = db.users.where((u) => u.role == 'doctor').toList();

          if (doctors.isEmpty) {
            return Center(
              child: Text(
                'No doctors registered.',
                style: TextStyle(color: isDark ? Colors.white54 : Colors.black45),
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(20.0),
            itemCount: doctors.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final doc = doctors[index];
              
              // Calculate case count for this doctor
              final totalCases = db.orders.where((o) => o.doctorId == doc.id).length;

              return GlassContainer(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      backgroundImage: NetworkImage(
                        doc.profilePhotoUrl ?? 'https://images.unsplash.com/photo-1622253692010-333f2da6031d?q=80&w=200&auto=format&fit=crop',
                      ),
                      radius: 22,
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                doc.name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: doc.isApproved
                                      ? Colors.green.withOpacity(0.15)
                                      : Colors.amber.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(
                                    color: doc.isApproved
                                        ? Colors.green.withOpacity(0.3)
                                        : Colors.amber.withOpacity(0.3),
                                  ),
                                ),
                                child: Text(
                                  doc.isApproved ? 'Approved' : 'Pending Review',
                                  style: TextStyle(
                                    color: doc.isApproved 
                                        ? (isDark ? Colors.green[300] : Colors.green[800])
                                        : (isDark ? Colors.amber[300] : Colors.amber[800]),
                                    fontSize: 9,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 1),
                          Text(
                            doc.email,
                            style: TextStyle(
                              fontSize: 11,
                              color: isDark ? Colors.white60 : Colors.black54,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Clinic: ${doc.clinicName ?? "N/A"}',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: isDark ? GlacierColors.darkPrimary : GlacierColors.lightPrimary,
                            ),
                          ),
                          Text(
                            'Address: ${doc.address ?? "N/A"}',
                            style: const TextStyle(
                              fontSize: 11,
                              color: Colors.grey,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            'Password: ${doc.password ?? "password"}',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color: isDark ? Colors.white38 : Colors.black38,
                            ),
                          ),
                          const SizedBox(height: 8),
                          // Actions Row
                          Row(
                            children: [
                              if (!doc.isApproved) ...[
                                ElevatedButton.icon(
                                  onPressed: () => controller.approveDoctor(doc),
                                  icon: const Icon(Icons.check_circle_outline, size: 14),
                                  label: const Text('Approve', style: TextStyle(fontSize: 10)),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.green.withOpacity(0.2),
                                    foregroundColor: isDark ? Colors.green[300] : Colors.green[800],
                                    elevation: 0,
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                    minimumSize: Size.zero,
                                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                                  ),
                                ),
                                const SizedBox(width: 8),
                              ],
                              ElevatedButton.icon(
                                onPressed: () => _showResetPasswordDialog(context, doc),
                                icon: const Icon(Icons.lock_reset, size: 14),
                                label: const Text('Reset Pass', style: TextStyle(fontSize: 10)),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white10,
                                  foregroundColor: isDark ? Colors.white : Colors.black87,
                                  elevation: 0,
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  minimumSize: Size.zero,
                                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    
                    // Case count badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: isDark ? Colors.white10 : Colors.black.withOpacity(0.04),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        children: [
                          Text(
                            '$totalCases',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: isDark ? GlacierColors.darkPrimary : GlacierColors.lightPrimary,
                            ),
                          ),
                          const Text(
                            'cases',
                            style: TextStyle(fontSize: 8, color: Colors.grey),
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

  void _showAddDocDialog(BuildContext context) {
    final controller = Get.find<AdminController>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    controller.clearDoctorInputs();

    Get.dialog(
      Dialog(
        backgroundColor: Colors.transparent,
        child: GlassContainer(
          borderRadius: 24,
          padding: const EdgeInsets.all(20),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Register New Doctor',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontSize: 18),
                ),
                const SizedBox(height: 16),
                GlassInput(
                  controller: controller.docNameController,
                  labelText: 'Doctor Name',
                  hintText: 'e.g. Dr. John Watson',
                ),
                const SizedBox(height: 12),
                GlassInput(
                  controller: controller.docEmailController,
                  labelText: 'Email Address',
                  hintText: 'watson@dental.com',
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 12),
                GlassInput(
                  controller: controller.docClinicController,
                  labelText: 'Clinic Name',
                  hintText: 'e.g. Baker St Dental Care',
                ),
                const SizedBox(height: 12),
                GlassInput(
                  controller: controller.docAddressController,
                  labelText: 'Clinic Address',
                  hintText: 'e.g. Pune, Maharashtra',
                ),
                const SizedBox(height: 12),
                
                // Clinic Map Pin Preview
                Text(
                  'Clinic Map Pin Preview',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    width: double.infinity,
                    height: 120,
                    color: Colors.grey.withOpacity(0.2),
                    child: Obx(() => TileMapWidget(
                      latitude: controller.docLatitude.value,
                      longitude: controller.docLongitude.value,
                      height: 120,
                    )),
                  ),
                ),
                const SizedBox(height: 12),
                GlassInput(
                  controller: controller.docPasswordController,
                  labelText: 'Login Password',
                  hintText: 'e.g. watson123',
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
                      onPressed: controller.registerDoctorByAdmin,
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
      ),
    );
  }

  void _showResetPasswordDialog(BuildContext context, UserModel doctor) {
    final controller = Get.find<AdminController>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final passwordController = TextEditingController();

    Get.dialog(
      Dialog(
        backgroundColor: Colors.transparent,
        child: GlassContainer(
          borderRadius: 24,
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Reset Password',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontSize: 18),
              ),
              const SizedBox(height: 8),
              Text(
                'Enter new password for ${doctor.name}:',
                style: TextStyle(color: isDark ? Colors.white60 : Colors.black54, fontSize: 13),
              ),
              const SizedBox(height: 16),
              GlassInput(
                controller: passwordController,
                labelText: 'New Password',
                hintText: 'e.g. securePass123',
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
                    onPressed: () {
                      controller.resetDoctorPassword(doctor, passwordController.text);
                      Get.back();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isDark ? GlacierColors.darkPrimary : GlacierColors.lightPrimary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: const Text('Reset'),
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
