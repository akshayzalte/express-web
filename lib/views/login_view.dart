import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import '../config/theme.dart';
import '../controllers/login_controller.dart';
import '../widgets/glass_container.dart';
import '../widgets/glass_button.dart';
import '../widgets/glass_input.dart';

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
                                GlassInput(
                                  controller: controller.phoneController,
                                  labelText: 'Mobile Number',
                                  hintText: 'e.g. 9876543210',
                                  prefixIcon: Icons.phone_android_rounded,
                                  keyboardType: TextInputType.phone,
                                  validator: (v) => v!.isEmpty ? 'Enter mobile number' : null,
                                ),
                                GlassInput(
                                  controller: controller.regEmailController,
                                  labelText: 'Email Address',
                                  hintText: 'e.g. doctor@dental.com',
                                  prefixIcon: Icons.email_outlined,
                                  keyboardType: TextInputType.emailAddress,
                                  validator: (v) => v!.isEmpty ? 'Enter email address' : null,
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
                                const SizedBox(height: 16),
                                Center(
                                  child: Column(
                                    children: [
                                      Text(
                                        'Quick Fill Demo Account',
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: isDark ? Colors.white38 : Colors.black38,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          _demoFillChip(context, 'Doctor', () => controller.fillDemoCredentials('doctor')),
                                          const SizedBox(width: 8),
                                          _demoFillChip(context, 'Admin', () => controller.fillDemoCredentials('admin')),
                                          const SizedBox(width: 8),
                                          _demoFillChip(context, 'Technician', () => controller.fillDemoCredentials('technician')),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],

                              // Mode Toggle
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

  Widget _demoFillChip(
    BuildContext context,
    String label,
    VoidCallback onTap,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.03),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isDark ? Colors.white10 : Colors.black12,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.flash_on, size: 10, color: Colors.orangeAccent),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white70 : Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
