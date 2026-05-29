import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import '../../config/theme.dart';
import '../../services/auth_service.dart';
import '../../services/database_service.dart';
import '../../widgets/glass_container.dart';
import '../../widgets/glass_button.dart';

class DoctorUnderReviewView extends StatelessWidget {
  const DoctorUnderReviewView({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Get.find<AuthService>();
    final db = Get.find<DatabaseService>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.topCenter,
            radius: 1.5,
            colors: isDark
                ? [const Color(0xFF0F2B48), const Color(0xFF0A1628)]
                : [const Color(0xFFDCE6F1), const Color(0xFFEAF0F6)],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  GlassContainer(
                    borderRadius: 24,
                    padding: const EdgeInsets.all(32.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Animated Clock Icon
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: isDark ? Colors.white10 : Colors.black.withOpacity(0.04),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.hourglass_empty_rounded,
                            size: 40,
                            color: isDark ? GlacierColors.darkPrimary : GlacierColors.lightPrimary,
                          ),
                        )
                            .animate(onPlay: (controller) => controller.repeat(reverse: true))
                            .scale(begin: const Offset(0.95, 0.95), end: const Offset(1.05, 1.05), duration: 1500.ms, curve: Curves.easeInOut)
                            .custom(builder: (context, value, child) => Opacity(opacity: 0.8 + (value * 0.2), child: child)),
                        const SizedBox(height: 24),
                        
                        Text(
                          'Account Under Review',
                          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ).animate().fadeIn(delay: 100.ms),
                        const SizedBox(height: 12),
                        
                        Obx(() {
                          final currentDoctorName = auth.currentUser.value?.name ?? 'Doctor';
                          return Text(
                            'Hello $currentDoctorName,\nYour registration is currently pending admin approval. You will receive access to features once the administrator reviews and approves your account details.',
                            style: TextStyle(
                              fontSize: 14,
                              height: 1.5,
                              color: isDark ? Colors.white70 : Colors.black87,
                            ),
                            textAlign: TextAlign.center,
                          );
                        }).animate().fadeIn(delay: 200.ms),
                        const SizedBox(height: 32),
                        
                        // Check Status button
                        GlassButton(
                          label: 'Check Status',
                          icon: Icons.refresh_rounded,
                          onPressed: () {
                            // Find latest details in DB
                            final userId = auth.currentUser.value?.id;
                            if (userId != null) {
                              final latestUser = db.users.firstWhereOrNull((u) => u.id == userId);
                              if (latestUser != null) {
                                if (latestUser.isApproved) {
                                  // Update session user and reload
                                  auth.currentUser.value = latestUser;
                                  Get.offAllNamed('/dashboard');
                                  Get.snackbar(
                                    'Approved!',
                                    'Your account has been approved by the Admin.',
                                    backgroundColor: const Color(0xFF1D9E75),
                                    colorText: Colors.white,
                                  );
                                  return;
                                }
                              }
                            }
                            Get.snackbar(
                              'Still Pending',
                              'Your registration is still being reviewed by the administrator.',
                              backgroundColor: Colors.amber.withOpacity(0.8),
                              colorText: Colors.black,
                            );
                          },
                        ).animate().fadeIn(delay: 300.ms),
                        const SizedBox(height: 16),
                        
                        // Logout Button
                        TextButton.icon(
                          onPressed: () {
                            auth.logout();
                            Get.offAllNamed('/login');
                          },
                          icon: const Icon(Icons.logout, size: 16),
                          label: const Text('Sign Out'),
                          style: TextButton.styleFrom(
                            foregroundColor: isDark ? Colors.white60 : Colors.black54,
                          ),
                        ).animate().fadeIn(delay: 400.ms),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Cloud Dental Express • Verified Lab Access',
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? Colors.white38 : Colors.black38,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
