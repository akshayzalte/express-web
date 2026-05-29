import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import '../config/theme.dart';
import '../controllers/login_controller.dart';
import '../widgets/glass_container.dart';
import '../widgets/glass_button.dart';
import '../widgets/glass_input.dart';
import '../widgets/tile_map_widget.dart';

class LoginView extends StatelessWidget {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(LoginController());
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
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 30.0),
              child: Form(
                key: controller.formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 30),
                    // Header Logo
                    Column(
                      children: [
                        Image.asset(
                          'assets/logo.png',
                          height: 140,
                          fit: BoxFit.contain,
                        ).animate().scale(delay: 100.ms, duration: 400.ms, curve: Curves.easeOutBack),
                        const SizedBox(height: 16),
                        Text(
                          'Precision lab workflows, simplified.',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: isDark ? Colors.white54 : const Color(0xFF44474E),
                              ),
                        ).animate().fadeIn(delay: 200.ms),
                      ],
                    ),

                    const SizedBox(height: 40),

                    // Main Glass Panel
                    Obx(() => GlassContainer(
                          borderRadius: 24,
                          padding: const EdgeInsets.all(24.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                controller.isRegisterMode.value
                                    ? 'Create Doctor Account'
                                    : 'Sign In',
                                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                      fontSize: 22,
                                    ),
                              ),
                              const SizedBox(height: 20),

                              // Role Selection Pills (Only in Login Mode)
                              if (!controller.isRegisterMode.value) ...[
                                Container(
                                  padding: const EdgeInsets.all(4.0),
                                  decoration: BoxDecoration(
                                    color: isDark ? Colors.white10 : Colors.black.withOpacity(0.04),
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  child: Row(
                                    children: [
                                      _roleTab(context, 'doctor', 'Doctor', controller),
                                      _roleTab(context, 'admin', 'Admin', controller),
                                      _roleTab(context, 'technician', 'Tech', controller),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 24),
                              ],

                              // Form Fields
                              if (controller.isRegisterMode.value) ...[
                                GlassInput(
                                  controller: controller.nameController,
                                  labelText: 'Full Name',
                                  hintText: 'Dr. Jane Smith',
                                  prefixIcon: Icons.person_outline_rounded,
                                  validator: (v) => v!.isEmpty ? 'Enter name' : null,
                                ),
                                const SizedBox(height: 16),
                                GlassInput(
                                  controller: controller.clinicController,
                                  labelText: 'Clinic Name',
                                  hintText: 'Smith Family Dentistry',
                                  prefixIcon: Icons.business_outlined,
                                  validator: (v) => v!.isEmpty ? 'Enter clinic name' : null,
                                ),
                                const SizedBox(height: 16),
                                GlassInput(
                                  controller: controller.addressController,
                                  labelText: 'Clinic Address',
                                  hintText: '123 Medical Plaza...',
                                  prefixIcon: Icons.location_on_outlined,
                                  maxLines: 2,
                                  validator: (v) => v!.isEmpty ? 'Enter clinic address' : null,
                                ),
                                const SizedBox(height: 16),
                                
                                // Map Location Pin Selection
                                Text(
                                  'Clinic Map Pin',
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
                                    child: Stack(
                                      children: [
                                        // Dynamic Static Maps Image
                                        Obx(() => TileMapWidget(
                                          latitude: controller.latitude.value,
                                          longitude: controller.longitude.value,
                                          height: 120,
                                        )),
                                        Positioned.fill(
                                          child: Container(
                                            color: Colors.transparent,
                                            child: InkWell(
                                              onTap: () {
                                                controller.setLocation(
                                                  controller.latitude.value + 0.001,
                                                  controller.longitude.value + 0.001,
                                                );
                                                Get.snackbar(
                                                  'Pin Set',
                                                  'Clinic location pin dropped!',
                                                  backgroundColor: Colors.white.withOpacity(0.9),
                                                  colorText: GlacierColors.lightPrimary,
                                                );
                                              },
                                              child: Center(
                                                child: Column(
                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                  children: [
                                                    Icon(
                                                      Icons.pin_drop,
                                                      size: 38,
                                                      color: isDark ? GlacierColors.darkPrimary : GlacierColors.lightPrimary,
                                                    ),
                                                    const SizedBox(height: 4),
                                                    Obx(() => Text(
                                                      controller.locationSet.value 
                                                          ? 'Coordinates: ${controller.latitude.value.toStringAsFixed(4)}, ${controller.longitude.value.toStringAsFixed(4)}'
                                                          : 'Tap to Drop Pin',

                                                      style: const TextStyle(
                                                        color: Colors.white,
                                                        fontWeight: FontWeight.bold,
                                                        fontSize: 12,
                                                        shadows: [
                                                          Shadow(
                                                            offset: Offset(0, 1),
                                                            blurRadius: 4,
                                                            color: Colors.black54,
                                                          )
                                                        ],
                                                      ),
                                                    )),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 24),
                              ] else ...[
                                GlassInput(
                                  controller: controller.emailController,
                                  labelText: 'Email Address',
                                  hintText: 'name@dental.com',
                                  prefixIcon: Icons.email_outlined,
                                  validator: (v) => v!.isEmpty ? 'Enter email' : null,
                                ),
                                const SizedBox(height: 16),
                                GlassInput(
                                  controller: controller.passwordController,
                                  labelText: 'Password',
                                  hintText: '••••••••',
                                  obscureText: true,
                                  prefixIcon: Icons.lock_outline_rounded,
                                  validator: (v) => v!.isEmpty ? 'Enter password' : null,
                                ),
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: TextButton(
                                    onPressed: () {},
                                    child: Text(
                                      'Forgot Password?',
                                      style: TextStyle(
                                        color: isDark ? GlacierColors.darkPrimary : GlacierColors.lightPrimary,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 8),
                              ],

                              // Submit Button
                              GlassButton(
                                label: controller.isRegisterMode.value
                                    ? 'Register Account'
                                    : 'Sign In',
                                onPressed: controller.handleLogin,
                              ),
                              const SizedBox(height: 12),

                              // Quick Fill Helper for Demo Users
                              if (!controller.isRegisterMode.value) ...[
                                Center(
                                  child: TextButton.icon(
                                    onPressed: controller.fillDemoCredentials,
                                    icon: const Icon(Icons.flash_on, size: 16),
                                    label: const Text('Auto-Fill Demo Credentials'),
                                    style: TextButton.styleFrom(
                                      foregroundColor: isDark ? Colors.white60 : Colors.black54,
                                    ),
                                  ),
                                ),
                              ],

                              // Mode Toggle
                              if (controller.selectedRole.value == 'doctor') ...[
                                const SizedBox(height: 16),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      controller.isRegisterMode.value
                                          ? 'Already have an account? '
                                          : 'Don\'t have an account? ',
                                      style: TextStyle(
                                        color: isDark ? Colors.white60 : Colors.black54,
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: controller.toggleMode,
                                      child: Text(
                                        controller.isRegisterMode.value ? 'Log In' : 'Register',
                                        style: TextStyle(
                                          color: isDark ? GlacierColors.darkPrimary : GlacierColors.lightPrimary,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ],
                          ),
                        )),
                    const SizedBox(height: 24),
                    Text(
                      '© 2026 Cloud Dental Express. Secure Gateway.',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
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
      ),
    );
  }

  Widget _roleTab(
    BuildContext context,
    String role,
    String label,
    LoginController controller,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Expanded(
      child: Obx(() {
        final isSelected = controller.selectedRole.value == role;
        
        Color tabBg = Colors.transparent;
        if (isSelected) {
          tabBg = isDark ? GlacierColors.darkPrimary : GlacierColors.lightPrimary;
        }

        return GestureDetector(
          onTap: () => controller.selectRole(role),
          child: Container(
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: tabBg,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              label,
              style: TextStyle(
                color: isSelected
                    ? Colors.white
                    : (isDark ? Colors.white70 : Colors.black54),
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ),
        );
      }),
    );
  }
}
